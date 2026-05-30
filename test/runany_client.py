r"""
RunAny Python 客户端库
通过 WMCOPYDATA / COM 两种机制从 Python 调用 RunAny

特性：
- WMCOPYDATA：同步阻塞，无法获取函数返回值（只有成功/失败），纯 ctypes
- COM IDispatch：同步阻塞，可以获取函数返回值，纯 ctypes（无 pywin32 依赖）

注意：AHK v1 主脚本窗口类名为 AutoHotkey，标题为完整脚本路径
如: L:\winTool\RunAny-5.8.2\RunAny.ahk - AutoHotkey v1.1.33.10
必须用 EnumWindows 模糊匹配，不能用 FindWindowW 精确匹配
"""

import ctypes
import ctypes.wintypes
from ctypes import (
    CFUNCTYPE,
    HRESULT,
    POINTER,
    Structure,
    Union,
    byref,
    c_double,
    c_int,
    c_long,
    c_uint,
    c_ulong,
    c_ushort,
    c_void_p,
    c_wchar_p,
    windll,
)

# ============================================================
# COM 类型定义（纯 ctypes，替代 comtypes 依赖）
# ============================================================


class GUID(Structure):
    """COM 接口标识符"""
    _fields_ = [
        ("Data1", c_uint),
        ("Data2", c_ushort),
        ("Data3", c_ushort),
        ("Data4", ctypes.c_ubyte * 8),
    ]

    def __init__(self, guid_str=None):
        super().__init__()
        if guid_str:
            # 解析 "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}" 格式
            h = guid_str.strip("{}").replace("-", "")
            self.Data1 = int(h[0:8], 16)
            self.Data2 = int(h[8:12], 16)
            self.Data3 = int(h[12:16], 16)
            for i in range(8):
                self.Data4[i] = int(h[16 + i * 2:18 + i * 2], 16)


# VARIANT 类型常量
VT_EMPTY = 0
VT_I4 = 3
VT_BSTR = 8


class DISPPARAMS(Structure):
    """IDispatch::Invoke 参数结构"""
    _fields_ = [
        ("rgvarg", c_void_p),
        ("rgdispidNamedArgs", c_void_p),
        ("cArgs", c_uint),
        ("cNamedArgs", c_uint),
    ]


# DISPID 类型（long）
DISPID = c_long


class _VARIANT_DATA(Union):
    """VARIANT 数据联合体（偏移量 8，8 字节）"""
    _fields_ = [
        ("val_long", c_long),      # VT_I4
        ("val_ptr", c_void_p),     # VT_BSTR / 其他指针类型
        ("val_double", c_double),  # VT_R8
    ]

class VARIANT(Structure):
    """COM 变体类型（24 字节，匹配 64 位 Windows VARIANT 布局）

    内存布局：[vt(2) + reserved(6)] + [值联合体(8)] + [对齐填充(8)] = 24 字节
    """
    _fields_ = [
        ("vt", c_ushort),
        ("wReserved1", c_ushort),
        ("wReserved2", c_ushort),
        ("wReserved3", c_ushort),
        ("_data", _VARIANT_DATA),
        ("_reserved2", c_void_p),   # 8 字节对齐填充，确保结构体大小 = 24
    ]

    @property
    def value(self):
        """读取 VARIANT 值"""
        if self.vt == VT_BSTR and self._data.val_ptr:
            return ctypes.wstring_at(self._data.val_ptr)
        if self.vt == VT_I4:
            return self._data.val_long
        return None

    @value.setter
    def value(self, val):
        """设置 VARIANT 值"""
        if isinstance(val, str):
            self.vt = VT_BSTR
            self._data.val_ptr = windll.oleaut32.SysAllocString(val)
        elif isinstance(val, int):
            self.vt = VT_I4
            self._data.val_long = val
        else:
            self.vt = VT_EMPTY


# COM 接口 IID（常量）
IID_NULL = GUID("{00000000-0000-0000-0000-000000000000}")
IID_IDISPATCH = GUID("{00020400-0000-0000-C000-000000000046}")

# oleaut32 函数签名修正（64 位指针必须用 c_void_p，否则截断为 32 位）
windll.oleaut32.SysAllocString.restype = c_void_p
windll.oleaut32.SysAllocString.argtypes = [c_wchar_p]
windll.oleaut32.SysFreeString.argtypes = [c_void_p]
windll.oleaut32.SysFreeString.restype = None
windll.oleaut32.VariantInit.restype = None
windll.oleaut32.VariantClear.argtypes = [POINTER(VARIANT)]

# ============================================================
# WMCOPYDATA 通信类
# ============================================================

WMCOPYDATA = 0x004A


class COPYDATASTRUCT(ctypes.Structure):
    _fields_ = [
        ("dwData", ctypes.c_void_p),
        ("cbData", ctypes.c_uint32),
        ("lpData", ctypes.c_void_p),
    ]


class RunAnyClient:
    """通过 WMCOPYDATA 与 RunAny 通信（无额外依赖）"""

    def __init__(self):
        self.hwnd = None
        self._find_window()

    def _find_window(self):
        """查找 RunAny 隐藏窗口
        AHK v1 主脚本窗口类名为 AutoHotkey（子 GUI 为 AutoHotkeyGUI）
        标题为完整脚本路径 + AHK 版本号
        """
        found = []

        def enum_cb(hwnd, _):
            cls = ctypes.create_unicode_buffer(256)
            ctypes.windll.user32.GetClassNameW(hwnd, cls, 256)
            # 只匹配主脚本窗口，排除子 GUI 窗口
            if cls.value != "AutoHotkey":
                return True
            length = ctypes.windll.user32.GetWindowTextLengthW(hwnd)
            if length > 0:
                buf = ctypes.create_unicode_buffer(length + 1)
                ctypes.windll.user32.GetWindowTextW(hwnd, buf, length + 1)
                if "RunAny" in buf.value:  # 模糊匹配标题
                    found.append(hwnd)
            return True

        ENUMPROC = ctypes.WINFUNCTYPE(
            ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p
        )
        ctypes.windll.user32.EnumWindows(ENUMPROC(enum_cb), 0)
        if found:
            self.hwnd = found[0]

    def is_running(self) -> bool:
        """检查 RunAny 是否运行"""
        if self.hwnd:
            return ctypes.windll.user32.IsWindow(self.hwnd) != 0
        self._find_window()
        return self.hwnd is not None

    def send(self, message: str) -> bool:
        """发送消息到 RunAny（同步阻塞，返回是否成功送达）"""
        if not self.is_running():
            raise ConnectionError("RunAny 未运行")
        msg_bytes = message.encode("utf-16-le") + b"\x00\x00"
        cds = COPYDATASTRUCT()
        cds.dwData = 0
        cds.cbData = len(msg_bytes)
        cds.lpData = ctypes.cast(
            ctypes.create_string_buffer(msg_bytes), ctypes.c_void_p
        )
        ctypes.windll.user32.SendMessageW(
            self.hwnd, WMCOPYDATA, 0, ctypes.byref(cds)
        )
        return True

    def run_menu_item(self, name: str):
        """运行指定菜单项"""
        return self.send(name)

    def call_function(self, func: str, *args):
        """调用 RunAny 内置函数（无法获取返回值）"""
        arg_str = ",".join(repr(a) for a in args)
        return self.send(f"runany[{func}]({arg_str})")

    def call_plugin(self, plugin: str, func: str, *args):
        """调用插件函数（无法获取返回值）"""
        arg_str = ",".join(repr(a) for a in args)
        return self.send(f"{plugin}[{func}]({arg_str})")

    def reload(self):
        """重载 RunAny 配置"""
        return self.send("Menu_Reload")

    def list_windows(self):
        """调试用：列出所有 AHK 相关窗口"""
        windows = []

        def enum_cb(hwnd, _):
            cls = ctypes.create_unicode_buffer(256)
            ctypes.windll.user32.GetClassNameW(hwnd, cls, 256)
            if "AutoHotkey" in cls.value or "AHK" in cls.value:
                length = ctypes.windll.user32.GetWindowTextLengthW(hwnd)
                buf = (
                    ctypes.create_unicode_buffer(length + 1)
                    if length
                    else ctypes.create_unicode_buffer(1)
                )
                ctypes.windll.user32.GetWindowTextW(hwnd, buf, length + 1)
                windows.append(
                    {"hwnd": hwnd, "class": cls.value, "title": buf.value}
                )
            return True

        ENUMPROC = ctypes.WINFUNCTYPE(
            ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p
        )
        ctypes.windll.user32.EnumWindows(ENUMPROC(enum_cb), 0)
        return windows


# ============================================================
# 消息格式说明
# ============================================================
#
# | 格式                     | 含义               | 示例                                    |
# |--------------------------|--------------------|-----------------------------------------|
# | 菜单项名称               | 运行该菜单项       | "Chrome浏览器"                          |
# | runany[函数名](参数)     | 调用内置函数       | "runany[ShowTrayTip](标题,内容,3,1)"    |
# | 插件名[函数名](参数)     | 调用插件COM函数    | "huiZz_Text[runany_decrypt](密文,key)"  |
# | 标签名                   | 跳转到标签执行     | "Menu_Reload"                           |
#
# 限制：WMCOPYDATA 只能触发动作，无法获取函数返回值
# 如需返回值，请使用 COM 方式（见下方 RunAnyCOMClient）
#


# ============================================================
# 使用示例
# ============================================================

def main():
    """WM_COPYDATA 方式使用示例"""
    ra = RunAnyClient()

    if not ra.is_running():
        print("错误：RunAny 未运行，请先启动 RunAny")
        print("\n当前 AHK 相关窗口：")
        for w in ra.list_windows():
            print(f"  hwnd={w['hwnd']:#x}  class={w['class']!r}  title={w['title']!r}")
        return

    print(f"已连接 RunAny (hwnd={ra.hwnd:#x})\n")

    # ---- 1. 显示托盘提示（最基础的连通性测试）----
    print("[1] 显示托盘提示...")
    ra.call_function("ShowTrayTip", "Python测试", "消息已送达", 3, 1)
    print("    已发送\n")

    # ---- 2. 运行菜单项 ----
    print("[2] 运行菜单项...")
    # ra.run_menu_item("Chrome浏览器")  # 取消注释测试
    print("    跳过（取消注释可测试）\n")

    # ---- 3. 显示指定分类菜单 ----
    print("[3] 显示指定分类菜单...")
    # ra.call_function("Remote_Menuname_Show", "常用")  # 取消注释测试
    print("    跳过（取消注释可测试）\n")

    # ---- 4. 显示后缀菜单（需要先选中文件）----
    print("[4] 显示后缀菜单...")
    # ra.call_function("Remote_Menu_Ext_Show", "txt")  # 取消注释测试
    print("    跳过（取消注释可测试，注意：需要先选中 .txt 文件）\n")

    # ---- 5. 调用插件函数 ----
    print("[5] 调用插件函数...")
    # ra.call_plugin("huiZz_Text", "runany_encrypt", "Hello", "mykey")
    print("    跳过（取消注释可测试）\n")

    # ---- 6. 重载 RunAny 配置 ----
    print("[6] 重载配置...")
    # ra.reload()  # 取消注释测试
    print("    跳过（取消注释可测试）\n")

    print("全部测试完成")


# ============================================================
# COM 方式示例（纯 ctypes，无额外依赖）
# 可以获取函数返回值
# 原理：oleaut32.GetActiveObject → IUnknown → QueryInterface(IDispatch) → Invoke
# ============================================================


class RunAnyCOMClient:
    """通过 COM IDispatch 与 RunAny 插件通信（可获取返回值）

    使用纯 ctypes 调用 oleaut32 API，绕过 comtypes/win32com 的包装缺陷。
    仅支持调用插件注册的 COM 函数（如 runany_encrypt/runany_decrypt），
    不支持 RunAny 内置函数（如 ShowTrayTip），内置函数请用 WM_COPYDATA 方式。
    """

    def __init__(self, guid: str):
        self._guid = GUID(guid)
        self._pdisp = None  # IDispatch 指针
        self._oleaut32 = windll.oleaut32
        self._ole32 = windll.ole32
        self._connect()

    def _connect(self):
        """初始化 COM 并获取 IDispatch 接口指针"""
        # 0. 初始化 COM（必须，否则 GetActiveObject 返回 CO_E_NOTINITIALIZED）
        self._ole32.CoInitialize(None)

        punk = c_void_p()
        # 1. GetActiveObject → IUnknown
        hr = self._oleaut32.GetActiveObject(byref(self._guid), None, byref(punk))
        if hr != 0:
            raise ConnectionError(f"COM 对象未注册或未运行 (hr={hr:#x})")

        # 2. QueryInterface → IDispatch
        vtable = ctypes.cast(punk, POINTER(POINTER(c_void_p))).contents
        QueryInterface = CFUNCTYPE(
            HRESULT, c_void_p, POINTER(GUID), POINTER(c_void_p)
        )(vtable[0])

        self._pdisp = c_void_p()
        hr = QueryInterface(punk, byref(IID_IDISPATCH), byref(self._pdisp))
        # 释放 IUnknown
        Release = CFUNCTYPE(c_ulong, c_void_p)(vtable[2])
        Release(punk)

        if hr != 0:
            raise ConnectionError(f"QueryInterface(IDispatch) 失败 (hr={hr:#x})")

        # 缓存 IDispatch vtable 函数指针
        disp_vt = ctypes.cast(
            self._pdisp, POINTER(POINTER(c_void_p))
        ).contents
        self._GetIDsOfNames = CFUNCTYPE(
            HRESULT, c_void_p, POINTER(GUID),
            POINTER(c_wchar_p), c_int, c_int, POINTER(DISPID),
        )(disp_vt[5])
        self._Invoke = CFUNCTYPE(
            HRESULT, c_void_p, DISPID, POINTER(GUID), c_int, c_int,
            POINTER(DISPPARAMS), POINTER(VARIANT), c_void_p, POINTER(c_int),
        )(disp_vt[6])
        self._Release = CFUNCTYPE(c_ulong, c_void_p)(disp_vt[2])

    def call(self, method: str, *args):
        """调用 COM 对象方法并返回结果

        Args:
            method: 方法名（如 'runany_encrypt'）
            *args: 参数（支持 str / int）

        Returns:
            方法返回值（str / int / None）
        """
        # 1. 获取 dispatch ID
        rg_names = (c_wchar_p * 1)(method)
        rg_dispid = (DISPID * 1)()
        hr = self._GetIDsOfNames(
            self._pdisp, byref(IID_NULL), rg_names, 1, 0x0409, rg_dispid
        )
        if hr != 0:
            raise AttributeError(f"方法 '{method}' 不存在 (hr={hr:#x})")

        # 2. 构造参数（VARIANT 数组）
        # COM 标准要求 DISPPARAMS.rgvarg 以反序存储参数。
        # AHK v1 的 ObjRegisterActive 会反转数组还原正序，
        # 但实测发现 AHK 只反转了一次（从 DISPPARAMS 顺序 → 正序），
        # 因此此处需将参数反序存储，使 AHK 反转后得到正确顺序。
        nargs = len(args)
        vargs = (VARIANT * max(nargs, 1))()
        reversed_args = list(reversed(args))
        for i, val in enumerate(reversed_args):
            self._oleaut32.VariantInit(byref(vargs[i]))
            if isinstance(val, str):
                vargs[i].vt = VT_BSTR
                vargs[i].value = val
            elif isinstance(val, int):
                vargs[i].vt = VT_I4
                vargs[i].value = val
            else:
                vargs[i].vt = VT_BSTR
                vargs[i].value = str(val)

        dp = DISPPARAMS()
        dp.rgvarg = ctypes.cast(vargs, c_void_p) if nargs else None
        dp.cArgs = nargs
        dp.rgdispidNamedArgs = None
        dp.cNamedArgs = 0

        result = VARIANT()
        self._oleaut32.VariantInit(byref(result))

        # 3. 调用 Invoke
        hr = self._Invoke(
            self._pdisp, rg_dispid[0], byref(IID_NULL),
            0x0409, 1, byref(dp), byref(result), None, None,
        )

        # 4. 提取返回值
        ret = None
        if hr == 0 and result.vt != VT_EMPTY:
            ret = result.value

        # 5. 清理 VARIANT
        for i in range(nargs):
            self._oleaut32.VariantClear(byref(vargs[i]))
        self._oleaut32.VariantClear(byref(result))

        if hr != 0:
            raise RuntimeError(f"Invoke '{method}' 失败 (hr={hr:#x})")
        return ret

    def close(self):
        """释放 COM 接口并反初始化"""
        if self._pdisp:
            self._Release(self._pdisp)
            self._pdisp = None
        self._ole32.CoUninitialize()

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    def __del__(self):
        self.close()


# ============================================================
# COM 使用示例
# ============================================================

def com_example():
    """COM 方式调用插件函数并获取返回值"""
    # 插件 GUID（来自 RunPlugins/RunAny_ObjReg.ini）
    PLUGIN_GUID = "{81AFC7E8-17FF-4760-9E3F-E4736EA38459}"

    try:
        with RunAnyCOMClient(PLUGIN_GUID) as ra:
            # 加密测试
            encrypted = ra.call("runany_encrypt", "didid", "mykey")
            print(f"加密结果: {encrypted}")

            # 解密测试
            decrypted = ra.call("runany_decrypt", encrypted, "mykey")
            print(f"解密结果: {decrypted}")

    except ConnectionError as e:
        print(f"连接失败: {e}")
        print("请确保 RunAny 已运行，且插件已加载")
    except Exception as e:
        print(f"COM 调用失败: {type(e).__name__}: {e}")


if __name__ == "__main__":
    # main()
    com_example()  # 取消注释测试 COM 方式
