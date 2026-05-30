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
├── lib/                    ← [重构中] 模块化文件
│   ├── 04_utility.ahk      ← 通用工具函数 (936行)
│   └── 08_search.ahk       ← 搜索功能 (111行)
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
├── #Include *i lib\13_icon.ahk           (122行) 图标管理
├── #Include *i lib\10_plugins.ahk        (198行) 插件系统
├── #Include *i lib\11_runctrl.ahk        (388行) 规则引擎
├── #Include *i lib\14_tray_update.ahk    (205行) 托盘+更新
└── #Include *i lib\12_everything.ahk     (325行) Everything集成
```

## 开发注意事项

- 修改代码后必须验证 RunAny.exe 能正常启动
- 不改动已有注释内容
- 每个模块文件保留原始注释
- 使用 `#Include *i` (忽略错误) 防止文件缺失导致崩溃
