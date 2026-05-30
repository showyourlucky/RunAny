# RunAny 项目 CLAUDE.md

## 项目概述

RunAny 是一个 Windows 快速启动工具（v5.9.3），基于 AutoHotkey v1.1.31+ 开发。
- 作者：hui-Zz
- 仓库：https://github.com/hui-Zz/RunAny
- 主文件：`RunAny.ahk`

## 项目结构

```
RunAny/
├── RunAny.ahk              ← 主入口 + 核心逻辑
├── RunAny.exe              ← 编译后的可执行文件
├── RunAnyConfig.ini        ← 主配置文件
├── RunAny.ini / RunAny2.ini ← 菜单定义文件
├── lib/                    ← 模块化文件 (18个)
│   ├── 04_utility.ahk      ← 通用工具函数 (936行)
│   ├── 05_menu_util.ahk    ← 菜单过滤工具 (167行)
│   ├── 05_menu_build.ahk   ← 菜单读取与构建 (523行)
│   ├── 06_menu_display.ahk ← 菜单显示 (515行)
│   ├── 07_menu_run.ahk     ← 菜单执行引擎 (709行)
│   ├── 08_search.ahk       ← 搜索功能 (111行)
│   ├── 09_config.ahk       ← 配置初始化 (409行)
│   ├── 10_plugins.ahk      ← 插件系统 (198行)
│   ├── 11_runctrl.ahk      ← 规则引擎 (388行)
│   ├── 12_everything.ahk   ← Everything集成 (325行)
│   ├── 13_icon.ahk         ← 图标管理 (251行)
│   ├── 14_tray_update.ahk  ← 托盘+更新 (321行)
│   ├── 15_gui_menu_editor.ahk ← 菜单编辑器GUI (1461行)
│   ├── 16_gui_plugins.ahk  ← 插件管理GUI (620行)
│   ├── 17_gui_settings.ahk ← 设置GUI (1323行)
│   ├── 18_gui_runctrl_rule.ahk ← 规则管理GUI (1065行)
│   ├── 19_gui_events.ahk   ← GUI事件+控件类 (288行)
│   └── 20_hotstring.ahk    ← 热字符串GUI (75行)
├── RunPlugins/             ← 插件目录
│   ├── RunAny_ObjReg.ahk   ← COM插件注册框架
│   ├── RunAny_ObjReg.ini   ← 插件GUID注册表
│   ├── Lib/                ← 内置库 (JSON.ahk, ChToPy.ahk)
│   └── *.ahk               ← 功能插件
├── Everything/             ← Everything搜索工具
├── RunIcon/                ← 图标资源
├── Everything.dll/64.dll   ← Everything DLL
└── ZzIcon.dll              ← 图标DLL
```

## 技术栈

- **语言**：AutoHotkey v1 (AHK v1.1.31+)
- **架构**：Gosub标签驱动（非函数式）
- **配置**：INI文件 (IniRead/IniWrite)
- **插件**：COM对象注册 + 跨进程IPC
- **搜索**：Everything SDK (DLL调用)
- **GUI**：AHK原生Gui命令

## 关键约束

1. **AHK v1 特性**：
   - `#Include` 是文本拼接，拆分不影响运行时行为
   - `Gosub` 可跳转到脚本中任何位置的标签
   - `global` 变量在函数内需显式声明
   - 自动执行段（auto-execute section）从文件顶部到第一个 `return`

2. **不能改动的**：
   - 插件COM注册机制 (RunAny_ObjReg.ahk)
   - INI配置文件格式
   - 热键注册模式
   - 菜单构建逻辑

3. **依赖关系**：
   - 主文件唯一 #Include：`RunPlugins\RunAny_ObjReg.ahk` (L7136)
   - 插件通过 COM IPC 通信，非代码级依赖

## 重构进度

**分支**：`refactor/modular-split`
**目标**：将 10128 行单文件拆分为 18 个模块文件
**结果**：主文件 10128 行 → 481 行（-95.2%），18 个模块文件共 9440 行

| 阶段 | 状态 | 模块 |
|------|------|------|
| 0. 准备工作 | ✅ 完成 | lib/目录、备份 |
| 1. 纯函数提取 | ✅ 完成 | 04_utility.ahk, 08_search.ahk |
| 2. 配置/基础设施 | ✅ 完成 | 09_config, 12_everything, 13_icon, 14_tray_update |
| 3. 菜单核心 | ✅ 完成 | 05_menu_util, 05_menu_build, 06_menu_display, 07_menu_run |
| 4. 插件/规则 | ✅ 完成 | 10_plugins, 11_runctrl |
| 5. GUI模块 | ✅ 完成 | 15-20号GUI模块 |
| 6. 主文件重组 | ✅ 完成 | 精简入口 + 全量#Include |

## 文件架构

```
RunAny.ahk (481行) ← 主入口 + 自动执行段 + 初始化标签
│
├── #Include *i lib\05_menu_util.ahk      (167行) 菜单过滤工具函数
├── #Include *i lib\05_menu_build.ahk     (523行) 菜单读取与构建
├── #Include *i lib\06_menu_display.ahk   (515行) 菜单显示与热键
├── #Include *i lib\07_menu_run.ahk       (709行) 菜单执行引擎
├── #Include *i lib\15_gui_menu_editor.ahk(1461行) 菜单编辑器GUI
├── #Include *i lib\16_gui_plugins.ahk    (620行) 插件管理GUI
├── #Include *i lib\18_gui_runctrl_rule.ahk(1065行) 规则管理GUI
├── #Include *i lib\17_gui_settings.ahk   (1323行) 设置GUI
├── #Include *i lib\19_gui_events.ahk     (288行) GUI事件+控件类
├── #Include *i lib\20_hotstring.ahk      (75行) 热字符串GUI
├── #Include *i lib\08_search.ahk         (111行) 搜索功能
├── #Include *i lib\04_utility.ahk        (936行) 通用工具函数
├── #Include *i lib\09_config.ahk         (409行) 配置初始化
├── #Include *i lib\13_icon.ahk           (251行) 图标管理
├── #Include *i lib\10_plugins.ahk        (198行) 插件系统
├── #Include *i lib\11_runctrl.ahk        (388行) 规则引擎
├── #Include *i lib\14_tray_update.ahk    (321行) 托盘+更新
└── #Include *i lib\12_everything.ahk     (325行) Everything集成
```

## 可调用函数/方法清单（107个函数 + 7个类）

### 通用工具函数 `lib/04_utility.ahk`（55个）

| 函数名 | 签名 | 用途 |
|--------|------|------|
| `CreateDir` | `(dir)` | 创建文件夹 |
| `DeleteFile` | `(filePath)` | 删除已有文件 |
| `Ext_Check` | `(name,len,ext)` | 检查后缀名 |
| `Send_Or_Show` | `(textResult,isSend:=false,sTime:=1000)` | 输出结果或显示ToolTip |
| `Send_Str_Zz` | `(strZz,tf=false)` | 粘贴输出短语 |
| `Send_Str_Input_Zz` | `(strZz,tf=false)` | 键盘输出短语 |
| `Send_Key_Zz` | `(keyZz,keyLevel=0)` | 输出热键 |
| `Get_Zz` | `(copyKey:="^c")` | 获取选中文字 |
| `SkSub_UrlEncode` | `(str, enc="UTF-8")` | 文本转URL编码 |
| `StrJoin` | `(sep, params*)` | 拼接字符 |
| `StrListJoin` | `(sep, paramList, join:=":")` | 数组拼接字符 |
| `StrListBatchReplace` | `(paramList, regExStr, replaceStr:="")` | 批量正则替换 |
| `StrListEscapeReplace` | `(str, paramList, replaceStr:="\")` | 批量转义替换 |
| `GetKeyByVal` | `(obj, val)` | 反向获取val对应的key |
| `Get_Transform_Val` | `(string)` | 变量展开转换 |
| `Get_Transform_Val_GetZz` | `(string)` | 含getZz的变量转换 |
| `Variable_Boolean_Reverse` | `(vars*)` | 布尔值反转 |
| `time_format` | `(t, f:="yyyy-MM-dd HH:mm:ss")` | 时间格式转换 |
| `get_process_path` | `(process)` | 获取进程路径 |
| `rule_boot_time` | `()` | 开机运行时长(秒) |
| `rule_chassis_types` | `()` | 获取电脑机型 |
| `rule_check_network` | `(lpszUrl="")` | 检查网络状态 |
| `rule_check_is_run` | `(runNamePath)` | 判断进程是否运行 |
| `funcPath2AbsoluteZz` | `(aPath,ahkPath)` | 相对路径→绝对路径 |
| `funcPath2RelativeZz` | `(fPath,ahkPath)` | 绝对路径→相对路径 |
| `js_eval` | `(exp)` | JS eval计算 |
| `escapeString` | `(string)` | 字符串转义 |
| `cmdClipReturn` | `(command)` | 运行cmd取回结果 |
| `Receive_WM_COPYDATA` | `(wParam, lParam)` | 接收跨脚本消息 |
| `WM_QUERYENDSESSION` | `(wParam, lParam)` | 系统关机前操作 |
| `ExitFunc` | `(ExitReason, ExitCode)` | 脚本退出前操作 |
| `DynaExpr_ObjRegisterActive` | `(GUID,appFunc,appParms:="",getZz:="")` | 动态执行COM脚本 |
| `DynaExpr_EvalToVar` | `(sExpr,getZz:="")` | 动态执行取结果 |
| `DynaRun` | `(TempScript, pipename="", params="")` | 动态执行AHK代码 |
| `URLDownloadToFile` | `(URL, FilePath, Options:="", RequestHeaders:="")` | HTTP下载文件 |
| `Var_Set` | `(vGui, var, sz)` | 写入INI配置 |
| `Var_Read` | `(rValue,defVar="")` | 读取INI配置 |
| `HideTrayTip` | `()` | 隐藏托盘提示 |
| `ShowTrayTip` | `(title,text,seconds,options)` | 临时托盘提示 |
| `Menu_Tray_Tip` | `(tText,tmpText:="")` | 托盘悬停提示 |
| `Menu_Run_Tray_Tip` | `(tText,tmpText:="")` | 运行路径提示 |
| `Menu_Debug_Mode` | `(tText,tmpText:="")` | 调试模式信息 |
| `Get_Menu_Item_Mode` | `(item,fullItemFlag:=false)` | 获取菜单项模式(1-12) |
| `Get_Tree_Name` | `(z_item,show_key=true)` | 获取分类名称 |
| `Get_Obj_Transform_Name` | `(z_item)` | 获取应用名(含变量) |
| `Get_Obj_Name` | `(z_item)` | 获取应用名称 |
| `Get_Obj_Path` | `(z_item)` | 获取应用路径 |
| `Get_Obj_Path_Transform` | `(z_item)` | 变量转换后路径 |
| `Get_Item_Run_Path` | `(z_item_path)` | 最佳启动路径 |
| `Open_Folder_Path` | `(path)` | 打开文件夹 |
| `Check_Obj_Ext` | `(filePath)` | 检查后缀支持 |
| `LVModifyCol` | `(width, colList*)` | 自动调整列表宽度 |
| `Remote_Dyna_Run` | `(remoteRun, remoteGetZz, remoteFlag:=false)` | 外部动态运行 |
| `Remote_Menu_Run` | `(remoteRun, remoteGetZz:="")` | 外部运行菜单项 |
| `Remote_Menu_Ext_Show` | `(fileExt)` | 外部显示后缀菜单 |
| `Remote_PMI_run` | `(caidanxiang)` | 外部悬浮菜单 |
| `Remote_Menuname_Show` | `(Menu_name)` | 外部指定菜单 |
| `SendStrDecrypt` | `(any,key:="")` | 插件解密 |
| `SendStrEncrypt` | `(any,key:="")` | 插件加密 |
| `Plugins_Down_Check` | `(name, path)` | 插件下载检查 |

### 搜索功能 `lib/08_search.ahk`（1个）

| `Run_Search` | `(anyUrl, getZz="", browser="")` | 通用搜索URL执行 |

### 菜单工具 `lib/05_menu_util.ahk`（4个）

| `Menu_Item_List_Filter` | `(M_Index,MenuTypeList,HideFlag,MenuType:=1)` | 菜单项过滤 |
| `Menu_Tree_List_Filter` | `(M_Index,MenuTypeList,MenuType)` | 菜单节点过滤 |
| `RunABackup` | `(backupDir,backupName,fileContent,filePath,formatStr)` | 自动备份配置 |
| `RunABackupClear` | `(backupDir, backupMax)` | 清理过期备份 |

### 菜单构建 `lib/05_menu_build.ahk`（7个）

| `Menu_Read` | `(iniReadVar,menuRootFn,TREE_TYPE,TREE_NO)` | 读取INI构建菜单树 |
| `MenuExeArrayPush` | `(menuName,menuItem,itemFile,itemAny,TREE_NO)` | EXE数组入栈 |
| `Menu_HotStr_Hint_Read` | `(hotstr,hotStrName,itemParam)` | 读取热字串提示 |
| `Menu_Add` | `(menuName,menuItem,itemContent,itemMode,TREE_NO)` | 添加菜单项 |
| `MenuObjTree_Delete_NoFind` | `(MenuObjTreeNum,menuName,menuItem)` | 删除无效菜单项 |
| `Menu_Item_Icon` | `(menuName,menuItem,iconPath,iconNo=0,treeLevel="")` | 设置菜单项图标 |
| `menuItemIconFileName` | `(menuItem)` | 获取图标文件名 |

### 菜单显示 `lib/06_menu_display.ahk`（3个）

| `Menu_Show_Show` | `(menuName, itemName, Candy_isFile:=0)` | 显示指定菜单 |
| `Menu_Add_Del_Temp` | `(addDel=1,TREE_NO=1,mName="",LabelName="",mIcon="",mIconNum="")` | 临时菜单项增删 |
| `ctrlgMenuItemAdd` | `(ctrlgMenu,FolderMenuItem,FolderVar)` | Ctrl+G菜单项 |

### 菜单执行 `lib/07_menu_run.ahk`（6个）

| `MenuRunHoldKey` | `()` | 按住键显示菜单 |
| `Run_Any` | `(runPath,runParm:="",runWorkDir:="",runState:="")` | 运行程序 |
| `Run_Zz` | `(runZz,runMode:=1)` | 运行短语/热键 |
| `Run_Wait` | `(runPath,runParm:="",runState:="")` | 等待运行 |
| `PluginsObjRegRun` | `(appPlugins,appFunc,appParms,getZz)` | 插件COM运行 |
| `MenuRunDebugModeShow` | `(runPath,adminRun,runState)` | 调试模式显示 |

### 插件系统 `lib/10_plugins.ahk`（3个）

| `Plugins_Read_Name` | `(filePath)` | 读取插件名称 |
| `Plugins_Read_Version` | `(filePath)` | 读取插件版本 |
| `Plugins_Read_Icon` | `(filePath)` | 读取插件图标路径 |

### 规则引擎 `lib/11_runctrl.ahk`（5个函数 + 3个类）

| `RunCtrl_RunRules` | `(ruleGroupKey)` | 执行规则组 |
| `RunCtrl_RunApps` | `(runGroupKey,runFlag:=true)` | 执行启动项 |
| `RunCtrl_LastRunTime` | `(ruleGroupKey)` | 上次运行时间 |
| `RunCtrl_RuleEffect` | `(ruleName)` | 规则生效判断 |
| `RunCtrl_RuleResult` | `(ruleName)` | 规则结果返回 |

类：`RunCtrl`（核心）、`RunCtrlRun`（执行）、`RunCtrlRunRule`（规则判断）

### Everything集成 `lib/12_everything.ahk`（4个函数 + 1个类）

| `EverythingIsRun` | `()` | 检测Everything运行 |
| `EverythingQuery` | `(EvCommandStr)` | Everything搜索 |
| `EverythingNoPathSearchStr` | `()` | 无路径搜索字符串 |
| `exeQuery` | `(exeName,noSystemExe:=" !C:\Windows*")` | EXE查询 |

类：`everything`（Everything搜索引擎封装）

### 图标管理 `lib/13_icon.ahk`（3个）

| `Icon_Image_Set` | `(ImageListID)` | 图标集初始化 |
| `Icon_Tree_Image_Set` | `(ImageListID)` | 菜单树图标预加载 |
| `Menu_Exe_Icon_Set` | `()` | 提取EXE图标 |

### GUI菜单编辑器 `lib/15_gui_menu_editor.ahk`（8个）

| `TVMenu` | `(addMenu)` | 右键功能菜单 |
| `TV_Move` | `(moveMode = true)` | 上下移动项目 |
| `TV_MoveMenu` | `(moveMode)` | 批量移动项目 |
| `TV_CheckUncheckWalk` | `(_ItemID, _ChkUchk)` | 递归勾选/取消 |
| `Set_Tab` | `(tabNum)` | Tab切换 |
| `Set_Icon` | `(ImageListID,itemVar,editVar=true,...)` | 菜单树图标设置 |
| `ToggleAllTheWay` | `(_ItemID=0, _ChkUchk=True)` | 全选/全不选 |
| `WebsiteIconError` | `(errDown)` | 图标下载错误 |

### GUI插件管理 `lib/16_gui_plugins.ahk`（6个函数 + 1个类）

| `LVMenu` | `()` | 插件右键菜单 |
| `Plugins_Edit` | `(FilePath)` | 编辑插件文件 |
| `Plugins_LV_Icon_Set` | `(PluginsImageListID)` | 插件列表图标 |
| `Plugins_Alone` | `(r)` | 独立插件操作 |
| `LVPluginsSetIcon` | `(PluginsImageListID,pname)` | 设置插件图标 |
| `LVStatusChange` | `(PluginsImageListID,RowNumber,FileStatus,lvItem,FileName)` | 状态变更 |

类：`RunAnyObj`（插件COM对象注册）

### GUI规则管理 `lib/18_gui_runctrl_rule.ahk`（5个）

| `RunCtrlLVMenu` | `()` | 启动控制右键菜单 |
| `RunCtrlRunIniKeyJoin` | `(key1,key2)` | INI键名拼接 |
| `Get_Rule_Func_Name` | `(rulePath,vRuleFunction)` | 获取规则函数名 |
| `Change_Rule_Name` | `(rname,rnew)` | 修改规则名称 |
| `KnowAhkFuncZz` | `(ahkPath)` | 识别AHK脚本函数 |

### GUI事件处理 `lib/19_gui_events.ahk`（5个函数 + 2个类）

| `WM_NOTIFY_TV` | `(Param*)` | TreeView自定义绘制 |
| `WM_NOTIFY` | `(Param*)` | ListView自定义绘制 |
| `GuiControlShow` | `(ctrlName,ctrlID)` | 显示控件 |
| `GuiControlHide` | `(ctrlName,ctrlID)` | 隐藏控件 |
| `GuiControlSet` | `(ctrlName,ctrlID,var)` | 设置控件值 |

类：`treeview`（TreeView封装）、`ListView`（ListView封装）

### 热字符串GUI `lib/20_hotstring.ahk`（2个）

| `CreateHotStrGui` | `(msg:="",Byref HotStrGuiW="", Byref HotStrGuiH="")` | 热字符串Gui |
| `GetCaret` | `(Byref CaretX="", Byref CaretY="",...)` | 获取光标位置 |

### 主文件 `RunAny.ahk`

无函数定义。仅包含自动执行段（变量声明 + Gosub调用）和 18 个 `#Include` 指令。

## 外部脚本集成

RunAny 支持从外部脚本（AHK / Python）调用，通过 WM_COPYDATA 消息机制通信。RunAny 以托盘方式运行（无可见窗口），AHK 脚本始终有一个隐藏窗口（类名 `AutoHotkey`，标题 `RunAny.ahk`），外部脚本通过查找该隐藏窗口发送消息。

### 消息格式

| 格式 | 含义 | 示例 |
|------|------|------|
| `菜单项名称` | 运行该菜单项 | `"Chrome浏览器"` |
| `runany[函数名](参数)` | 调用 RunAny 内置函数 | `"runany[Get_Zz]()"` |
| `插件名[函数名](参数)` | 调用插件注册的 COM 函数 | `"huiZz_Text[runany_decrypt](密文,key)"` |
| `标签名` | 直接跳转到标签执行 | `"Menu_Reload"` |

### AHK 外部脚本示例

```ahk
; external.ahk - 从外部 AHK 脚本调用 RunAny
#NoEnv
#SingleInstance,Force

; 运行菜单项
RunAny_Send_WM_COPYDATA("Chrome浏览器", "RunAny.ahk ahk_class AutoHotkey")

; 调用 RunAny 内置函数
RunAny_Send_WM_COPYDATA("runany[ShowTrayTip](外部调用,成功,3,1)", "RunAny.ahk ahk_class AutoHotkey")

; 显示后缀菜单
RunAny_Send_WM_COPYDATA("runany[Remote_Menu_Ext_Show](txt)", "RunAny.ahk ahk_class AutoHotkey")

; 重载配置
RunAny_Send_WM_COPYDATA("Menu_Reload", "RunAny.ahk ahk_class AutoHotkey")

; ---- WM_COPYDATA 发送函数（必须）----
RunAny_Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle)
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    SendMessage, 0x004A, 0, &CopyDataStruct,, %TargetScriptTitle%
    DetectHiddenWindows %Prev_DetectHiddenWindows%
    SetTitleMatchMode %Prev_TitleMatchMode%
    return ErrorLevel
}
```

### Python 外部脚本示例

```python
"""
Python 调用 RunAny - WM_COPYDATA 方式（纯 ctypes，无额外依赖）
RunAny 托盘状态下一样可以调用，无需可见窗口

注意：AHK v1 主脚本窗口类名为 AutoHotkey，标题为完整脚本路径
如: L:\winTool\RunAny-5.8.2\RunAny.ahk - AutoHotkey v1.1.33.10
必须用 EnumWindows 模糊匹配，不能用 FindWindowW 精确匹配
"""
import ctypes
import ctypes.wintypes

WM_COPYDATA = 0x004A

class COPYDATASTRUCT(ctypes.Structure):
    _fields_ = [
        ("dwData", ctypes.c_void_p),
        ("cbData", ctypes.c_uint32),
        ("lpData", ctypes.c_void_p),
    ]

class RunAnyClient:
    def __init__(self):
        self.hwnd = None
        self._find_window()

    def _find_window(self):
        """查找 RunAny 隐藏窗口
        AHK v1 主脚本窗口类名固定为 AutoHotkey，标题为完整脚本路径
        如: L:\winTool\RunAny-5.8.2\RunAny.ahk - AutoHotkey v1.1.33.10
        子 GUI 窗口类名为 AutoHotkeyGUI，不匹配
        """
        found = []
        def enum_cb(hwnd, _):
            cls = ctypes.create_unicode_buffer(256)
            ctypes.windll.user32.GetClassNameW(hwnd, cls, 256)
            if cls.value != "AutoHotkey":  # 只匹配主脚本窗口
                return True
            length = ctypes.windll.user32.GetWindowTextLengthW(hwnd)
            if length > 0:
                buf = ctypes.create_unicode_buffer(length + 1)
                ctypes.windll.user32.GetWindowTextW(hwnd, buf, length + 1)
                if "RunAny" in buf.value:  # 模糊匹配标题
                    found.append(hwnd)
            return True
        ENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)
        ctypes.windll.user32.EnumWindows(ENUMPROC(enum_cb), 0)
        if found:
            self.hwnd = found[0]

    def is_running(self) -> bool:
        if self.hwnd:
            return ctypes.windll.user32.IsWindow(self.hwnd) != 0
        self._find_window()
        return self.hwnd is not None

    def send(self, message: str) -> bool:
        if not self.is_running():
            raise ConnectionError("RunAny 未运行")
        msg_bytes = message.encode("utf-16-le") + b"\x00\x00"
        cds = COPYDATASTRUCT()
        cds.dwData = 0
        cds.cbData = len(msg_bytes)
        cds.lpData = ctypes.cast(ctypes.create_string_buffer(msg_bytes), ctypes.c_void_p)
        ctypes.windll.user32.SendMessageW(self.hwnd, WM_COPYDATA, 0, ctypes.byref(cds))
        return True

    def run_menu_item(self, name: str):
        """运行指定菜单项"""
        return self.send(name)

    def call_function(self, func: str, *args):
        """调用 RunAny 内置函数"""
        arg_str = ",".join(repr(a) for a in args)
        return self.send(f"runany[{func}]({arg_str})")

    def call_plugin(self, plugin: str, func: str, *args):
        """调用插件函数"""
        arg_str = ",".join(repr(a) for a in args)
        return self.send(f"{plugin}[{func}]({arg_str})")

    def reload(self):
        """重载 RunAny 配置"""
        return self.send("Menu_Reload")

# 使用示例
if __name__ == "__main__":
    ra = RunAnyClient()
    if not ra.is_running():
        print("RunAny 未运行")
        exit(1)
    ra.run_menu_item("Chrome浏览器")
    ra.call_function("ShowTrayTip", "Python", "调用成功", 3, 1)
    ra.call_function("Remote_Menu_Ext_Show", "txt")
    ra.reload()
```

### 方式对比

| 方式 | 依赖 | 适用场景 | 获取返回值 |
|------|------|---------|-----------|
| WM_COPYDATA | 无（纯 ctypes） | 触发动作（运行菜单项、调用内置函数） | 否 |
| COM IDispatch | 无（纯 ctypes） | 调用插件注册的 COM 函数 | 是 |

> 两种方式均为纯 ctypes 实现，无需 pywin32/comtypes 依赖。完整实现见 `test/runany_client.py`。

## 开发注意事项

- 修改代码后必须验证 RunAny.exe 能正常启动
- 不改动已有注释内容
- 每个模块文件保留原始注释
- 使用 `#Include *i` (忽略错误) 防止文件缺失导致崩溃
