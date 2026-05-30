"""Python WMCOPYDATA 双向通信服务器

用途：接收 AHK 发来的文本，执行 base64 编码/解码，将结果返回给 AHK。
协议：
  AHK → Python:  "base64_encode:原文" 或 "base64_decode:密文"
  Python → AHK:  通过 WMCOPYDATA 发回 RunAny，AHK 用 OnMessage 回调接收

启动方式：先运行本脚本，再运行 ahk_calls_python.ahk
按 Ctrl+C 停止服务器。
"""

import ctypes
import ctypes.wintypes
import base64
import sys
import os

# ── Windows API 常量 ──
WM_COPYDATA = 0x004A
WM_CLOSE = 0x0010
WS_EX_NOACTIVATE = 0x08000000
CW_USEDEFAULT = 0x80000000
SW_HIDE = 0
CS_HREDRAW = 0x0002
CS_VREDRAW = 0x0004

# ── 窗口类名和标题（AHK 通过此名称查找 Python 窗口）──
WINDOW_CLASS = "RunAnyPythonServer"
WINDOW_TITLE = "RunAny-Python-Bridge"


# ============================================================
# WMCOPYDATA 结构
# ============================================================

class COPYDATASTRUCT(ctypes.Structure):
    _fields_ = [
        ("dwData", ctypes.c_void_p),
        ("cbData", ctypes.c_uint32),
        ("lpData", ctypes.c_void_p),
    ]


class WNDCLASS(ctypes.Structure):
    _fields_ = [
        ("style", ctypes.c_uint),
        ("lpfnWndProc", ctypes.c_void_p),
        ("cbClsExtra", ctypes.c_int),
        ("cbWndExtra", ctypes.c_int),
        ("hInstance", ctypes.c_void_p),
        ("hIcon", ctypes.c_void_p),
        ("hCursor", ctypes.c_void_p),
        ("hbrBackground", ctypes.c_void_p),
        ("lpszMenuName", ctypes.c_wchar_p),
        ("lpszClassName", ctypes.c_wchar_p),
    ]


class MSG(ctypes.Structure):
    _fields_ = [
        ("hwnd", ctypes.c_void_p),
        ("message", ctypes.c_uint),
        ("wParam", ctypes.c_void_p),
        ("lParam", ctypes.c_void_p),
        ("time", ctypes.c_uint),
        ("pt", ctypes.wintypes.POINT),
    ]


# ============================================================
# WMCOPYDATA 发送工具
# ============================================================

def send_wmcdata(hwnd, text: str) -> bool:
    """通过 WMCOPYDATA 发送文本到目标窗口"""
    msg_bytes = text.encode("utf-16-le") + b"\x00\x00"
    cds = COPYDATASTRUCT()
    cds.dwData = 0
    cds.cbData = len(msg_bytes)
    cds.lpData = ctypes.cast(
        ctypes.create_string_buffer(msg_bytes), ctypes.c_void_p
    )
    # 使用 SendMessage 同步发送，确保数据在接收方处理前保持有效
    ctypes.windll.user32.SendMessageW(hwnd, WM_COPYDATA, 0, ctypes.byref(cds))
    return True


def find_runany_window():
    """查找 RunAny 隐藏窗口（类名 AutoHotkey，标题含 RunAny）"""
    found = []

    def enum_cb(hwnd, _):
        cls = ctypes.create_unicode_buffer(256)
        ctypes.windll.user32.GetClassNameW(hwnd, cls, 256)
        if cls.value != "AutoHotkey":
            return True
        length = ctypes.windll.user32.GetWindowTextLengthW(hwnd)
        if length > 0:
            buf = ctypes.create_unicode_buffer(length + 1)
            ctypes.windll.user32.GetWindowTextW(hwnd, buf, length + 1)
            if "RunAny" in buf.value:
                found.append(hwnd)
        return True

    ENUMPROC = ctypes.WINFUNCTYPE(
        ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p
    )
    ctypes.windll.user32.EnumWindows(ENUMPROC(enum_cb), 0)
    return found[0] if found else None


# ============================================================
# base64 处理
# ============================================================

def handle_message(msg: str):
    """解析 AHK 消息并返回处理结果

    协议格式：
      基础: "base64_encode:原文" 或 "base64_decode:密文"
      带回复窗口: "base64_encode:原文|回复窗口标题"

    返回: (result: str, reply_title: str | None)
    """
    # 解析回复窗口标题
    reply_title = None
    if "|" in msg:
        parts = msg.rsplit("|", 1)
        msg = parts[0]
        reply_title = parts[1]

    if msg.startswith("base64_encode:"):
        text = msg[len("base64_encode:"):]
        result = base64.b64encode(text.encode("utf-8")).decode("ascii")
        print(f"  编码: {text!r} → {result!r}")
        return result, reply_title

    if msg.startswith("base64_decode:"):
        cipher = msg[len("base64_decode:"):]
        try:
            result = base64.b64decode(cipher).decode("utf-8")
        except Exception as e:
            result = f"Error: {e}"
        print(f"  解码: {cipher!r} → {result!r}")
        return result, reply_title

    print(f"  未知消息: {msg!r}")
    return "Error: unknown command", reply_title


# ============================================================
# 窗口过程（处理 WMCOPYDATA 消息）
# ============================================================

# 全局引用，防止回调被 GC
_runany_hwnd = None


def wnd_proc(hwnd, msg, wparam, lparam):
    """窗口消息回调"""
    global _runany_hwnd

    if msg == WM_COPYDATA:
        # 解析收到的 WMCOPYDATA 数据
        cds = ctypes.cast(lparam, ctypes.POINTER(COPYDATASTRUCT)).contents
        text = ctypes.wstring_at(cds.lpData)
        print(f"[收到] {text!r}")

        # 处理并返回结果（带回复窗口标题）
        result, reply_title = handle_message(text)

        # 构造回复消息
        reply = f"result:{result}"

        # 优先回复到指定窗口标题（测试场景），否则回复给 RunAny（生产场景）
        if reply_title:
            # 通过窗口标题查找回复目标
            reply_hwnd = find_window_by_title(reply_title)
            if reply_hwnd:
                send_wmcdata(reply_hwnd, reply)
                print(f"  [回复] 已发送到: {reply_title} ({reply_hwnd:#x})")
            else:
                print(f"  [错误] 未找到窗口: {reply_title}")
        else:
            # 回复给 RunAny（兼容原有逻辑）
            runany_hwnd = _runany_hwnd or find_runany_window()
            if runany_hwnd:
                reply_runany = f"runany[ShowTrayTip](Python结果,{result},5,1)"
                send_wmcdata(runany_hwnd, reply_runany)
                _runany_hwnd = runany_hwnd
                print("  [回复] 已发送到 RunAny")
            else:
                print("  [错误] 未找到 RunAny 窗口")

        return 1

    if msg == WM_CLOSE:
        ctypes.windll.user32.DestroyWindow(hwnd)
        return 0

    return ctypes.windll.user32.DefWindowProcW(
        ctypes.c_void_p(hwnd), ctypes.c_uint(msg),
        ctypes.c_void_p(wparam), ctypes.c_void_p(lparam)
    )


def find_window_by_title(title: str):
    """通过窗口标题查找窗口（使用 FindWindowW）"""
    # 精确匹配
    hwnd = ctypes.windll.user32.FindWindowW(None, title)
    if hwnd:
        return hwnd

    # 备用方案：枚举所有 AutoHotkey 窗口模糊匹配
    found = []

    def enum_cb(hwnd, _):
        cls = ctypes.create_unicode_buffer(256)
        ctypes.windll.user32.GetClassNameW(hwnd, cls, 256)
        # 只检查 AutoHotkey 相关类名的窗口
        if cls.value not in ("AutoHotkey", "AutoHotkeyGUI"):
            return True
        length = ctypes.windll.user32.GetWindowTextLengthW(hwnd)
        if length > 0:
            buf = ctypes.create_unicode_buffer(length + 1)
            ctypes.windll.user32.GetWindowTextW(hwnd, buf, length + 1)
            if title in buf.value:
                found.append(hwnd)
        return True

    ENUMPROC = ctypes.WINFUNCTYPE(
        ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p
    )
    ctypes.windll.user32.EnumWindows(ENUMPROC(enum_cb), 0)
    return found[0] if found else None


# ============================================================
# 主函数：注册窗口类 + 创建窗口 + 消息循环
# ============================================================

def main():
    global _runany_hwnd

    h_instance = ctypes.windll.kernel32.GetModuleHandleW(None)

    # 1. 注册窗口类
    WNDPROC = ctypes.WINFUNCTYPE(
        ctypes.c_long, ctypes.c_void_p, ctypes.c_uint,
        ctypes.c_void_p, ctypes.c_void_p
    )
    wnd_proc_ptr = WNDPROC(wnd_proc)

    wc = WNDCLASS()
    wc.style = CS_HREDRAW | CS_VREDRAW
    wc.lpfnWndProc = ctypes.cast(wnd_proc_ptr, ctypes.c_void_p)
    wc.hInstance = h_instance
    wc.lpszClassName = WINDOW_CLASS

    if not ctypes.windll.user32.RegisterClassW(ctypes.byref(wc)):
        err = ctypes.windll.kernel32.GetLastError()
        # 1410 = ERROR_CLASS_ALREADY_EXISTS，可忽略
        if err != 1410:
            print(f"RegisterClass 失败: {err}")
            sys.exit(1)

    # 2. 创建隐藏窗口（WS_EX_NOACTIVATE 避免抢焦点）
    hwnd = ctypes.windll.user32.CreateWindowExW(
        WS_EX_NOACTIVATE,
        WINDOW_CLASS,
        WINDOW_TITLE,
        0,  # style
        CW_USEDEFAULT, CW_USEDEFAULT,
        CW_USEDEFAULT, CW_USEDEFAULT,
        None, None, h_instance, None,
    )
    if not hwnd:
        print(f"CreateWindowEx 失败: {ctypes.windll.kernel32.GetLastError()}")
        sys.exit(1)

    print(f"Python 服务器已启动")
    print(f"  窗口句柄: {hwnd:#x}")
    print(f"  窗口类名: {WINDOW_CLASS}")
    print(f"  窗口标题: {WINDOW_TITLE}")
    print(f"  等待 AHK 消息... (Ctrl+C 停止)")
    print()

    # 3. 预查找 RunAny 窗口
    _runany_hwnd = find_runany_window()
    if _runany_hwnd:
        print(f"  已找到 RunAny 窗口: {_runany_hwnd:#x}")
    else:
        print(f"  警告：未找到 RunAny 窗口，回复将延迟查找")
    print()

    # 4. 消息循环
    msg = MSG()
    while True:
        bRet = ctypes.windll.user32.GetMessageW(ctypes.byref(msg), None, 0, 0)
        if bRet == 0 or bRet == -1:
            break
        ctypes.windll.user32.TranslateMessage(ctypes.byref(msg))
        ctypes.windll.user32.DispatchMessageW(ctypes.byref(msg))

    print("服务器已停止")


if __name__ == "__main__":
    main()
