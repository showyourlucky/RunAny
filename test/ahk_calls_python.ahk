/*
【AHK 调用 Python — base64 编码/解码调试脚本】

原理：
  AHK 通过 WMCOPYDATA 发送文本到 Python 服务器
  Python 执行 base64 编码/解码后，将结果通过 WMCOPYDATA 发回给本脚本
  本脚本用 OnMessage 回调接收回复

启动顺序：
  1. 先运行 python_server_wmcdata.py（Python 服务器）
  2. 再运行本脚本（或在 RunAny 中触发）

依赖：
  - Python 服务器窗口类名: RunAnyPythonServer
*/
#NoEnv
#SingleInstance,Force
SetBatchLines,-1
DetectHiddenWindows,On
SetTitleMatchMode,2

; Python 服务器窗口标识
global PYTHON_CLASS := "RunAnyPythonServer"
global PYTHON_TITLE := "RunAny-Python-Bridge"

; 接收回复的全局变量
global _reply_text := ""
global _reply_received := false
global MY_WINDOW_TITLE := "AHK-Test-Client"

; 日志文件
global LOG_FILE := A_ScriptDir "\test_log.txt"
FileDelete, %LOG_FILE%

; ── 创建本脚本的隐藏窗口用于接收回复 ──
Gui, +HwndMyHwnd
Gui, Show, Hide, %MY_WINDOW_TITLE%
Log("[AHK] 测试客户端窗口已创建: " MyHwnd)

; 注册接收 WMCOPYDATA 消息
OnMessage(0x004A, "Receive_WM_COPYDATA")

; ── 测试用例 ──
test_cases := [{text: "Hello World", key: "test1"}
    , {text: "你好世界", key: "test2"}
    , {text: "base64 encode me!", key: "test3"}]

; ── 主流程 ──
Log("[AHK] 开始测试 AHK→Python base64 通信")

; 1. 查找 Python 服务器窗口
python_hwnd := FindPythonWindow()
if (!python_hwnd) {
    MsgBox, 16, 错误, 未找到 Python 服务器窗口`n请先运行: python python_server_wmcdata.py
    ExitApp
}
Log("[AHK] 已找到 Python 窗口: " python_hwnd)

; 2. 逐个发送测试用例
all_pass := true
For i, tc in test_cases {
    ; 发送编码请求（附带回复窗口标题）
    msg := "base64_encode:" tc.text "|" MY_WINDOW_TITLE
    Log("[AHK] 测试 " i ": " tc.text)
    Log("[AHK] 发送编码请求: base64_encode:" tc.text)
    SendToPython(python_hwnd, msg)

    ; 等待 Python 回复
    result := WaitForReply(3000)
    Log("[AHK] 编码结果: " result)

    ; 发送解码请求（用编码结果）
    if (result && !InStr(result, "Error")) {
        msg2 := "base64_decode:" result "|" MY_WINDOW_TITLE
        Log("[AHK] 发送解码请求: base64_decode:" result)
        SendToPython(python_hwnd, msg2)

        ; 等待 Python 回复
        result2 := WaitForReply(3000)
        Log("[AHK] 解码结果: " result2)

        ; 验证可逆性
        if (result2 = tc.text) {
            Log("[AHK] ✓ 验证通过")
        } else {
            Log("[AHK] ✗ 验证失败: 期望 """ tc.text """, 实际 """ result2 """")
            all_pass := false
        }
    } else {
        all_pass := false
    }
    Log("[AHK] ---")
}

if (all_pass)
    Log("[AHK] 全部测试通过 ✓")
else
    Log("[AHK] 存在失败用例 ✗")

Log("[AHK] 测试完成")
MsgBox, 64, 测试完成, AHK→Python base64 测试完成`n日志文件: %LOG_FILE%
Run, %LOG_FILE%
ExitApp

; ── 日志函数 ──
Log(text) {
    global LOG_FILE
    FormatTime, ts,, HH:mm:ss
    line := ts " " text "`n"
    OutputDebug, %text%
    FileAppend, %line%, %LOG_FILE%, UTF-8
}

; ── 接收 WMCOPYDATA 回调 ──
Receive_WM_COPYDATA(wParam, lParam) {
    global _reply_text, _reply_received

    ; 解析 WMCOPYDATA 结构
    cbData := NumGet(lParam + A_PtrSize, 0, "UInt")
    lpData := NumGet(lParam + 2 * A_PtrSize, 0, "Ptr")

    ; 读取文本
    if (cbData > 0) {
        _reply_text := StrGet(lpData, cbData // 2, "UTF-16")
        _reply_received := true
        Log("[AHK] 收到回复: " _reply_text)
    }
    return 1
}

; ── 等待回复（带超时）──
WaitForReply(timeout_ms) {
    global _reply_text, _reply_received

    _reply_text := ""
    _reply_received := false

    start := A_TickCount
    while (!_reply_received && (A_TickCount - start) < timeout_ms) {
        Sleep, 50
    }

    if (!_reply_received) {
        Log("[AHK] 等待回复超时")
        return ""
    }

    ; 从 result:XXX 格式中提取结果
    if (InStr(_reply_text, "result:")) {
        return SubStr(_reply_text, 8)  ; 跳过 "result:" 前缀
    }

    return _reply_text
}

; ── 查找 Python 服务器窗口 ──
FindPythonWindow() {
    ; 方式1：通过窗口标题精确匹配
    WinGet, hwnd, ID, %PYTHON_TITLE% ahk_class %PYTHON_CLASS%
    if (hwnd)
        return hwnd

    ; 方式2：通过类名模糊匹配
    WinGet, hwnd, ID, ahk_class %PYTHON_CLASS%
    return hwnd
}

; ── 通过 WMCOPYDATA 发送消息到 Python（使用 SetTimer 异步）──
SendToPython(target_hwnd, message) {
    global _send_target_hwnd, _send_message

    ; 保存要发送的消息
    _send_target_hwnd := target_hwnd
    _send_message := message

    ; 使用 SetTimer 异步发送，避免 SendMessage 阻塞导致死锁
    SetTimer, DoSendWMCopyData, -1
}

DoSendWMCopyData:
    global _send_target_hwnd, _send_message

    ; 构造 WMCOPYDATA 结构
    VarSetCapacity(CopyDataStruct, 3 * A_PtrSize, 0)
    ; 计算字节数（含 null 终止符）
    SizeInBytes := (StrLen(_send_message) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize, "UInt")       ; cbData
    NumPut(&_send_message, CopyDataStruct, 2 * A_PtrSize, "Ptr") ; lpData

    ; 发送消息
    SendMessage, 0x004A, 0, &CopyDataStruct,, ahk_id %_send_target_hwnd%
    return
