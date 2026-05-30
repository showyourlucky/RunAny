# RunAny ↔ Python 通信调试示例

三种通信方式的完整测试，验证 AHK 和 Python 之间的消息传递和函数调用。

## 通信方式总览

| 方式 | 方向 | 能获取返回值 | 依赖 | 入口文件 |
|------|------|-------------|------|----------|
| WM_COPYDATA（单向） | Python→AHK | 否（仅成功/失败） | 无（纯 ctypes） | `runany_client.py` `RunAnyClient` |
| WM_COPYDATA（双向） | AHK↔Python | 是（通过回复消息） | 无（纯 ctypes） | `python_server_wmcdata.py` + `ahk_calls_python.ahk` |
| COM IDispatch | Python→AHK | 是（同步返回） | 无（纯 ctypes） | `runany_client.py` `RunAnyCOMClient` |

## 目录结构

```
test/
├── README.md                    ← 本文档
├── runany_client.py             ← 核心客户端库（RunAnyClient + RunAnyCOMClient）
├── python_server_wmcdata.py     ← 场景1: Python 服务器（接收 AHK 消息）
├── ahk_calls_python.ahk         ← 场景1: AHK 客户端（发送到 Python）
└── python_calls_ahk.py          ← 场景2: Python 客户端（调用 AHK 插件）
```

---

## 核心客户端库 `runany_client.py`

提供两种 Python→AHK 通信客户端，均为纯 ctypes 实现，无 pywin32/comtypes 依赖。

### RunAnyClient（WM_COPYDATA 方式）

通过 Windows 消息机制向 RunAny 发送指令，同步阻塞，**无法获取函数返回值**。

```python
from runany_client import RunAnyClient

ra = RunAnyClient()
if not ra.is_running():
    print("RunAny 未运行")

# 运行菜单项
ra.run_menu_item("Chrome浏览器")

# 调用内置函数（无返回值）
ra.call_function("ShowTrayTip", "标题", "内容", 3, 1)

# 调用插件函数（无返回值）
ra.call_plugin("huiZz_Text", "runany_encrypt", "Hello", "mykey")

# 重载配置
ra.reload()
```

**可用方法：**

| 方法 | 签名 | 说明 |
|------|------|------|
| `is_running()` | `() -> bool` | 检查 RunAny 是否运行 |
| `send(message)` | `(str) -> bool` | 发送原始消息 |
| `run_menu_item(name)` | `(str) -> bool` | 运行指定菜单项 |
| `call_function(func, *args)` | `(str, ...) -> bool` | 调用 RunAny 内置函数 |
| `call_plugin(plugin, func, *args)` | `(str, str, ...) -> bool` | 调用插件 COM 函数 |
| `reload()` | `() -> bool` | 重载 RunAny 配置 |
| `list_windows()` | `() -> list[dict]` | 调试用：列出所有 AHK 窗口 |

**消息格式（内部协议）：**

| 格式 | 含义 | 示例 |
|------|------|------|
| `菜单项名称` | 运行该菜单项 | `"Chrome浏览器"` |
| `runany[函数名](参数)` | 调用内置函数 | `"runany[ShowTrayTip](标题,内容,3,1)"` |
| `插件名[函数名](参数)` | 调用插件COM函数 | `"huiZz_Text[runany_decrypt](密文,key)"` |
| `标签名` | 跳转到标签执行 | `"Menu_Reload"` |

### RunAnyCOMClient（COM IDispatch 方式）

通过 COM 接口调用 RunAny 插件注册的函数，同步阻塞，**可以获取函数返回值**。

原理：`oleaut32.GetActiveObject` → `IUnknown` → `QueryInterface(IDispatch)` → `Invoke`

```python
from runany_client import RunAnyCOMClient

# 插件 GUID（来自 RunPlugins/RunAny_ObjReg.ini）
PLUGIN_GUID = "{81AFC7E8-17FF-4760-9E3F-E4736EA38459}"

with RunAnyCOMClient(PLUGIN_GUID) as ra:
    # 调用插件函数并获取返回值
    encrypted = ra.call("runany_encrypt", "Hello", "mykey")
    decrypted = ra.call("runany_decrypt", encrypted, "mykey")
    print(decrypted)  # "Hello"
```

**可用方法：**

| 方法 | 签名 | 说明 |
|------|------|------|
| `call(method, *args)` | `(str, ...) -> str\|int\|None` | 调用 COM 对象方法并返回结果 |
| `close()` | `()` | 释放 COM 接口并反初始化 |
| 支持 `with` 语句 | — | 自动管理 COM 生命周期 |

**限制：** 仅支持调用插件注册的 COM 函数（如 `runany_encrypt`/`runany_decrypt`），不支持 RunAny 内置函数（如 `ShowTrayTip`），内置函数请用 WM_COPYDATA 方式。

### COM 类型定义（纯 ctypes）

`runany_client.py` 包含完整的 COM 类型基础设施，可独立复用：

| 类型 | 说明 |
|------|------|
| `GUID` | COM 接口标识符，支持 `{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}` 字符串解析 |
| `VARIANT` | COM 变体类型（24 字节，64 位布局），支持 `VT_BSTR`/`VT_I4`/`VT_EMPTY` |
| `DISPPARAMS` | `IDispatch::Invoke` 参数结构 |

---

## 场景 1：AHK 调用 Python（双向 WM_COPYDATA）

```
AHK --[WM_COPYDATA]--> Python 服务器 --> base64 编码/解码
                                                  |
AHK <--[WM_COPYDATA]--- Python 服务器 <-----------┘
```

**文件：**
- `python_server_wmcdata.py` — Python 服务器，创建隐藏窗口接收 AHK 消息
- `ahk_calls_python.ahk` — AHK 客户端，发送测试用例并验证可逆性

**启动步骤：**

```bash
# 终端 1：启动 Python 服务器
cd f:\autohotkey\RunAny\test
python python_server_wmcdata.py

# 终端 2：运行 AHK 客户端
# 双击 ahk_calls_python.ahk 或在 RunAny 中触发
```

**协议格式：**

| AHK→Python | Python→AHK |
|------------|------------|
| `base64_encode:原文` | `result:编码结果` |
| `base64_decode:密文` | `result:解码结果` |
| `base64_encode:原文\|回复窗口标题` | 通过指定窗口标题回复 |

---

## 场景 2：Python 调用 AHK 插件（COM IDispatch）

```
Python --[COM IDispatch]--> RunAny huiZz_Text 插件 --> XOR + base64
                                                              |
Python <--[COM 返回值]---- RunAny huiZz_Text 插件 <-----------┘
```

**文件：**
- `python_calls_ahk.py` — 测试脚本，复用 `runany_client.py` 中的 `RunAnyCOMClient`

**启动步骤：**

```bash
# 确保 RunAny 已运行且 huiZz_Text 插件已加载
cd f:\autohotkey\RunAny\test
python python_calls_ahk.py
```

**测试内容：**
1. AHK 加密→解密可逆性（中英文、特殊字符）
2. Python base64 vs AHK XOR+base64 对比
3. 边界情况（单字符、长文本、Unicode emoji、换行符）
