/*
╔══════════════════════════════════════════════════
║【RunAny】一劳永逸的快速启动工具 v5.9.3 @2025.12.11
║ 国内Gitee文档：https://hui-zz.gitee.io/RunAny
║ Github文档：https://hui-zz.github.io/RunAny
║ Github地址：https://github.com/hui-Zz/RunAny
║ 直接运行本脚本需要AutoHotKey版本：1.1.31 以上
║ by hui-Zz 建议：hui0.0713@gmail.com
║ 讨论QQ群：246308937
╚══════════════════════════════════════════════════
*/
#NoEnv                  ;~;不检查空变量为环境变量
#Persistent             ;~;让脚本持久运行
#WinActivateForce       ;~;强制激活窗口
#SingleInstance,Force   ;~;运行替换旧实例
ListLines,Off           ;~;不显示最近执行的脚本行
AutoTrim,On             ;~;自动去除变量中前导和尾随空格制表符
SendMode,Input          ;~;使用更速度和可靠方式发送键鼠点击
CoordMode,Menu          ;~;相对于整个屏幕
SetBatchLines,-1        ;~;脚本全速执行
SetWorkingDir,%A_ScriptDir%                  ;~;脚本当前工作目录
global StartTick:=A_TickCount                ;~;评估初始化时间
global RunAnyZz:="RunAny"                    ;~;名称
global PluginsDir:="RunPlugins"              ;~;插件目录
global RunAnyConfig:="RunAnyConfig.ini"      ;~;配置文件
global RunAny_ObjReg:="RunAny_ObjReg.ini"    ;~;插件注册配置文件
global RunAny_update_version:="5.9.3"        ;~;版本号
global RunAny_update_time:="2025.05.16"      ;~;更新日期
global iniPath:=A_ScriptDir "\RunAny.ini"    ;~;菜单1
global iniPath2:=A_ScriptDir "\RunAny2.ini"  ;~;菜单2
Gosub,Config_Set        ;~;01.配置初始化
Gosub,Menu_Var_Set      ;~;02.自定义变量
Gosub,Icon_Set          ;~;03.图标初始化
Gosub,Run_Exist         ;~;04.调用环境判断

;适配Everything1.5（逍遥添加）
DetectHiddenWindows,On
global Everything_exe:="Everything.exe"
if(WinExist("ahk_exe Everything64.exe"))
	global Everything_exe:="Everything64.exe"
DetectHiddenWindows,off
;══════════════════════════════════════════════════════════════════
;~;[05.初始化菜单显示热键]
HotKeyList:=["MenuHotKey","MenuHotKey2","MenuNoGetHotKey","EvHotKey","OneHotKey"]
RunHotKeyList:=HotKeyList.Clone()
HotKeyList.Push("TreeHotKey1","TreeHotKey2","TreeIniHotKey1","TreeIniHotKey2"
	,"RunATrayHotKey","RunASetHotKey","RunAReloadHotKey","RunASuspendHotKey","RunAExitHotKey"
	,"PluginsManageHotKey","RunCtrlManageHotKey","PluginsAlonePauseHotKey","PluginsAloneSuspendHotKey","PluginsAloneCloseHotKey")
HotKeyTextList:=["RunAny菜单显示热键","RunAny菜单2热键","RunAny菜单热键(不获取选中内容)","一键Everything热键","一键搜索热键"]
HotKeyTextList.Push("修改菜单管理(1)","修改菜单管理(2)","修改菜单文件(1)","修改菜单文件(2)")
HotKeyTextList.Push("RunAny托盘菜单","设置RunAny","重启RunAny","停用RunAny","退出RunAny"
	,"插件管理","启动管理","独立插件脚本一键暂停","独立插件脚本挂起热键","独立插件脚本一键关闭")
RunList:=["Menu_Show1","Menu_Show2","Menu_NoGet_Show","Ev_Show","One_Show","Menu_Edit1","Menu_Edit2","Menu_Ini","Menu_Ini2"]
RunList.Push("Menu_Tray","Settings_Gui","Menu_Reload","Menu_Suspend","Menu_Exit"
	,"Plugins_Gui","RunCtrl_Manage_Gui","Plugins_Alone_Pause","Plugins_Alone_Suspend","Plugins_Alone_Close")
Hotkey, IfWinNotActive, ahk_group DisableGUI
For ki, kv in HotKeyList
{
	StringReplace,keyV,kv,Hot
	%keyV%:=Var_Read(keyV)
	StringReplace,winkeyV,kv,Hot,Win
	%winkeyV%:=Var_Read(winkeyV,0)
	if(ki=1 && !%keyV%){
		%keyV%:="``"
	}
}
errorKeyStr:=""
For ki, kv in HotKeyList
{
	StringReplace,keyV,kv,Hot
	StringReplace,winkeyV,kv,Hot,Win
	if(%keyV%){
		if(!MENU2FLAG){
			if ki in 2,7,9
			{
				continue
			}
		}
		%kv%:=%winkeyV% ? "#" . %keyV% : %keyV%
		try{
			if(IsLabel(RunList[ki]))
				Hotkey,% %kv%,% RunList[ki],On
		}catch{
			errorKeyStr.=kv "`n"
		}
	}
}
if(errorKeyStr){
	Gosub,Settings_Gui
	if(ki!=1 && ki!=2)
		SendInput,^{Tab}
	MsgBox,16,RunAny热键配置不正确,% "热键错误：`n" errorKeyStr "`n请设置正确热键后重启RunAny"
	return
}
if(A_AhkVersion < 1.1.31){
	MsgBox, 16, AutoHotKey版本过低！, 由于你的AHK版本没有高于1.1.31，会影响RunAny功能的使用!`n
	(
1. 不支持StrSplit()函数的MaxParts`n2. 不支持动态Hotstring创建`n3. 不支持Switch Case的语法
	)
}
;══════════════════════════════════════════════════════════════════
Gosub,Menu_Tray_Add                         ;~;06.托盘菜单
Gosub,Icon_FileExt_Set                      ;~;07.后缀图标初始化
t1:=A_TickCount-StartTick
if(!iniFlag){
	Gosub,Plugins_Read                      ;~;08.插件脚本读取
	Gosub,AutoClose_Plugins                 ;~;09.关闭插件脚本
	Gosub,AutoRun_Plugins                   ;~;10.运行插件脚本
	Gosub,Plugins_Object_Register           ;~;11.插件对象注册
	Gosub,RunCtrl_Read                      ;~;12.启动规则读取
}
;══════════════════════════════════════════════════════════════════
;~;[13.创建初始菜单]
t2:=t3:=A_TickCount-StartTick
Menu_Tray_Tip("初始化+运行插件：" Round(t2/1000,3) "s`n","开始创建无图标菜单...")
global MenuObj:=Object()                    ;~程序全路径
global MenuObjKey:=Object()                 ;~程序热键
global MenuObjKeyName:=Object()             ;~程序热键关联菜单项名称
global MenuObjKeyList:=Object()             ;~程序热键关联菜单项列表
global MenuObjExt:=Object()                 ;~后缀对应的菜单
global MenuObjWindow:=Object()              ;~软件窗口对应的菜单
global MenuHotStrList:=Object()             ;~热字符串对象数组
global MenuTreeKey:=Object()                ;~菜单树分类热键
global MenuObjIconList:=Object()            ;~菜单项对应图标对象
global MenuObjIconNoList:=Object()          ;~菜单项对应图标位置对象
global MenuExeArray:=Object()               ;~EXE程序对象数组
global MenuExeIconArray:=Object()           ;~EXE程序优先加载图标对象数组
global MenuObjTreeLevel:=Object()           ;~菜单对应级别
global MenuObjPublic:=[]                    ;~后缀公共菜单
global MenuShowFlag:=false                  ;~菜单功能是否可以显示
global MenuIconFlag:=false                  ;~菜单图标是否加载完成
global MenuObjName:=Object()                ;~程序菜单项名称
global MenuBar:=""                          ;~菜单分列标记
global MenuCount:=MENU2FLAG ? 2 : 1
MenuObj.SetCapacity(10240)
MenuExeArray.SetCapacity(1024)
MenuExeIconArray.SetCapacity(3072)
Loop,%MenuCount%
{
	M%A_Index%:=RunAnyZz . A_Index
	MenuSendStrList%A_Index%:=Object()      ;菜单中短语项列表
	MenuWebList%A_Index%:=Object()          ;菜单中网址%s搜索项列表
	MenuGetZzList%A_Index%:=Object()        ;菜单中GetZz搜索项列表
	MenuExeList%A_Index%:=Object()          ;菜单中的exe列表
	MenuObjList%A_Index%:=Object()          ;菜单分类运行项列表
	MenuObjText%A_Index%:=[]                ;选中文字菜单
	MenuObjFile%A_Index%:=[]                ;选中文件菜单
	MenuObjTree%A_Index%:=Object()          ;分类目录程序全数据
	MenuObjTree%A_Index%[M%A_Index%]:=Object()
	;菜单级别：初始为根菜单RunAny
	menuRoot%A_Index%:=[M%A_Index%]
}
;══════════════════════════════════════════════════════════════════
global NoPathFlag:=false                    ;是否拿到无路径搜索结果
global MenuObjEv:=Object()                  ;Everything搜索结果程序全路径
global MenuObjSame:=Object()                ;Everything搜索结果重名程序全路径
global MenuObjSearch:=Object()              ;Everything搜索无路径菜单项
global MenuObjCache:=Object()               ;Everything搜索无路径应用缓存
global MenuObjNew:=Object()                 ;Everything搜索新增加
global MenuObjEvPathEmptyReason:=Object()   ;Everything无路径应用搜索不到的原因
EvCommandStr:=""                            ;Everything搜索字符
;~;[14.获取无路径应用的运行全路径缓存]
if(EvDemandSearch){
	EvCommandStr:=EverythingNoPathSearchStr()
	Loop, parse, evFullPathIniVar, `n, `r
	{
		varList:=StrSplit(A_LoopField,"=",,2)
		outVarStr:=varList[1]
		objFileNameNoExeExt:=RegExReplace(outVarStr,"iS)\.exe$","")
		MenuObj[objFileNameNoExeExt]:=varList[2]
		MenuObjCache[outVarStr]:=varList[2]
		;检查缓存中的无路径应用被删除或移动
		if(Trim(varList[2]," `t`r`n")!="" && !FileExist(varList[2])){
			MenuObjCache[outVarStr]:=""  ;缓存失效则置空
			if(RegExMatch(outVarStr, RegexEscapeNoPointStr)){
				outVarStr:=StrListEscapeReplace(outVarStr, RegexEscapeNoPointList, "\")
			}
			outVarStr:=StrReplace(outVarStr,".","\.")
			MenuObjNew.push("^" outVarStr "$")
		}
		;无路径应用被删除自动清除对应的缓存
		if(!MenuObjSearch.HasKey(outVarStr)){
			IniDelete, %RunAnyEvFullPathIni%, FullPath, %outVarStr%
		}
	}
	;发现有新增的无路径菜单项
	if(Trim(evFullPathIniVar," `t`r`n")!=""){
		NoPathFlag:=true
		for k,v in MenuObjSearch
		{
			;发现有新的无路径应用
			if(!MenuObjCache.HasKey(k)){
				MenuObjCache[k]:=""
				if(RegExMatch(k, RegexEscapeNoPointStr)){
					k:=StrListEscapeReplace(k, RegexEscapeNoPointList, "\")
				}
				k:=StrReplace(k,".","\.")
				MenuObjNew.push("^" k "$")
			}else{
				MenuObjSearch[k]:=MenuObjCache[k]
			}
		}
		if(MenuObjNew.Length()>0){
			NoPathFlag:=false
			EvCommandStr:=StrListJoin("|",MenuObjNew)
			EvCommandStr:="regex:""" EvCommandStr """"
		}
	}
}
MenuObjEv:=MenuObj.Clone()
;~;[15.判断有无路径应用则需要使用Everything]
if(!NoPathFlag && !EvNo){
	if(!EvDemandSearch || (EvDemandSearch && EvCommandStr!="")){
		t3:=A_TickCount-StartTick
		if(EverythingIsRun()){
			Menu_Tray_Tip("","开始调用Everything搜索菜单内应用全路径...")
			RegRead,EvTotResults,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults
			if(EvTotResults>0){
				EverythingQuery(EvCommandStr)
				NoPathFlag:=true
				for k,v in MenuObjSearch
				{
					IniWrite, %v%, %RunAnyEvFullPathIni%, FullPath, %k%
				}
			}else{
				Gosub,EverythingCheck
				Loop, 30
				{
					RegRead,EvTotResults,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults
					if(EvTotResults>0){
						EverythingQuery(EvCommandStr)
						NoPathFlag:=true
						for k,v in MenuObjSearch
						{
							IniWrite, %v%, %RunAnyEvFullPathIni%, FullPath, %k%
						}
						break
					}
					Sleep, 100
				}
				RegRead,EvTotResults,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults
				if(!EvTotResults){
					SetTimer,EverythingCheckResults,100
				}
			}
		}
	}
}
;══════════════════════════════════════════════════════════════════
t4:=A_TickCount-StartTick
t32:=t3-t2 ? Round((t3-t2)/1000,3) "+" : ""
Menu_Tray_Tip("调用Everything搜索应用全路径：" t32 Round((t4-t3)/1000,3) "s`n","开始加载完整菜单功能...")
Menu_Read(iniVar1,menuRoot1,"",1)
;~;[16.如果有第2菜单则开始加载]
if(MENU2FLAG){
	Menu_Tray_Tip("","开始创建菜单2内容...")
	Menu_Read(iniVar2,menuRoot2,"",2)
}
MenuShowFlag:=true
t5:=A_TickCount-StartTick
Menu_Tray_Tip("菜单创建：" Round((t5-t4)/1000,3) "s`n")
;~;[17.初始菜单加载后操作]
if(SendStrEcKey!="")
	SendStrDcKey:=SendStrDecrypt(SendStrEcKey,RunAnyZz ConfigDate)

t6:=t7:=A_TickCount-StartTick
;~;[18.规则启动程序]
if(RunCtrlListBoxVar!=""){
	Gosub,Rule_Effect
	t7:=A_TickCount-StartTick
	Menu_Tray_Tip("规则启动：" Round((t7-t6)/1000,3) "s`n")
}
;~;[19.对菜单内容项进行过滤调整]
Loop,%MenuCount%
{
	M_Index:=A_Index
	menuDefaultRoot%A_Index%:=[M%A_Index% " "]
	Menu_Read(iniVar%A_Index%,menuDefaultRoot%A_Index%," ",A_Index)

	menuWebRoot%A_Index%:=[M%A_Index% "  "]
	Menu_Read(iniVar%A_Index%,menuWebRoot%A_Index%,"  ",A_Index)

	menuFileRoot%A_Index%:=[M%A_Index% "   "]
	Menu_Read(iniVar%A_Index%,menuFileRoot%A_Index%,"   ",A_Index)

	Menu_Item_List_Filter(A_Index,"MenuSendStrList",HideSend)
	Menu_Item_List_Filter(A_Index,"MenuWebList",HideWeb)
	Menu_Item_List_Filter(A_Index,"MenuGetZzList",HideGetZz)

	;带%s的网址菜单分类下增加批量搜索功能项
	For mn,items in MenuWebList%A_Index%
	{
		if(!RegExMatch(mn,"S)[^\s]+\s$")){
			Menu,%mn%,add
			Menu,%mn%,add,%RUNANY_SELF_MENU_ITEM1%%mn%,Web_Run
			Menu,%mn%,Icon,%RUNANY_SELF_MENU_ITEM1%%mn%,% UrlIconS[1],% UrlIconS[2],%MenuIconSize%
		}
	}
	;设置后缀公共菜单
	MenuObjExt["public"]:=MenuObjPublic

	;选中文本菜单过滤分类
	if(MenuObjText%A_Index%.MaxIndex()>0){
		Menu_Tree_List_Filter(A_Index,"MenuObjText",2)
		rootName:=menuWebRoot%A_Index%[1]
		;开启选中文字菜单后，主菜单里面不带%getZz%或%s的都不再显示
		for k,v in MenuObjTree%A_Index%[rootName]
		{
			if(v!="" && Get_Menu_Item_Mode(v,true)<10){
				if(!InStr(v,"%getZz%") && !InStr(v,"%s")){
					try Menu,%rootName%,Delete,% Get_Obj_Name(v)
				}else{
					MenuObjTextRootFlag%M_Index%:=true
				}
			}
		}
	}
	;选中文件菜单过滤分类
	if(MenuObjFile%A_Index%.MaxIndex()>0){
		Menu_Tree_List_Filter(A_Index,"MenuObjFile",3)
		rootName:=menuFileRoot%A_Index%[1]
		;开启选中文件菜单后，主菜单里面不带%getZz%或%s的都不再显示
		for k,v in MenuObjTree%A_Index%[rootName]
		{
			if(v!="" && !InStr(v,"%getZz%") && !InStr(v,"%s")
				&& Get_Menu_Item_Mode(v,true)!=1 && Get_Menu_Item_Mode(v,true)<10){
				try Menu,%rootName%,Delete,% Get_Obj_Name(v)
			}
		}
	}
	;~;[20.最近运行项]
	if(RecentMax>0){
		For mci, mcItem in MenuCommonList
		{
			if(A_Index>RecentMax)
				break
			obj:=RegExReplace(mcItem,"^&\d+ ")
			MenuObj[mcItem]:=MenuObj[obj]
			Menu,% menuDefaultRoot%M_Index%[1],Add,%mcItem%,Menu_Run
			Menu,% menuWebRoot%M_Index%[1],Add,%mcItem%,Menu_Run
			Menu,% menuFileRoot%M_Index%[1],Add,%mcItem%,Menu_Run
			fullpath:=Get_Obj_Path(MenuObj[mcItem])
			SplitPath,fullpath, , , ext
			if(ext="exe"){
				Menu_Item_Icon(menuDefaultRoot%M_Index%[1],mcItem,fullpath)
				Menu_Item_Icon(menuWebRoot%M_Index%[1],mcItem,fullpath)
				Menu_Item_Icon(menuFileRoot%M_Index%[1],mcItem,fullpath)
			}else{
				recentItemMode:=Get_Menu_Item_Mode(MenuObj[mcItem])
				Menu_Add(menuDefaultRoot%M_Index%[1],mcItem,MenuObj[mcItem],recentItemMode,"")
				Menu_Add(menuWebRoot%M_Index%[1],mcItem,MenuObj[mcItem],recentItemMode,"")
				Menu_Add(menuFileRoot%M_Index%[1],mcItem,MenuObj[mcItem],recentItemMode,"")
			}
		}
	}
}
t8:=A_TickCount-StartTick
Menu_Tray_Tip("菜单加载：" Round((t8-t7)/1000,3) "s`n")

;~;[21.内部关联后缀打开方式]
Gosub,Open_Ext_Set
Menu_Tray_Tip("","菜单已经可以正常使用`n开始为菜单中exe程序加载图标...")
;~;[22.菜单中EXE程序加载图标，有ico图标更快]
For k, v in MenuExeIconArray
{
	if(DisableExeIcon){
		Menu_Item_Icon(v["menuName"],v["menuItem"],EXEIconS[1],EXEIconS[2])
	}else{
		Menu_Item_Icon(v["menuName"],v["menuItem"],v["itemFile"])
	}
}
For k, v in MenuExeArray
{
	if(DisableExeIcon){
		Menu_Item_Icon(v["menuName"],v["menuItem"],EXEIconS[1],EXEIconS[2])
	}else{
		Menu_Item_Icon(v["menuName"],v["menuItem"],v["itemFile"])
	}
}
;-------------------------------------------------------------------------------------------
;~;[23.菜单已经加载完毕，托盘图标变化]
t9:=A_TickCount-StartTick
Menu_Tray_Tip("菜单加载exe图标：" Round((t9-t8)/1000,3) "s`n","总加载时间：" Round(t9/1000,3) "s")
Menu,Tray,Icon,% AnyIconS[1],% AnyIconS[2]
MenuIconFlag:=true

;#如果是第一次运行#
if(iniFlag){
	iniFlag:=false
	TrayTip,,RunAny菜单初始化完成`n右击任务栏图标设置,5,1
	Gosub,Menu_About
	Gosub,Menu_Show1
}
;~;[24.检查无路径应用缓存是否有新的版本]
if(NoPathFlag && !EvNo && Trim(evFullPathIniVar," `t`r`n")!="" && rule_check_is_run(Everything_exe)){
	Gosub,RunAEvFullPathSync
}
;~;[25.记录ini文件修改时间]
FileGetTime,MTimeIniPath, %iniPath%, M  ; 获取修改时间.
RegRead, MTimeIniPathReg, HKEY_CURRENT_USER\Software\RunAny, %iniPath%
RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, %iniPath%, %MTimeIniPath%
IniChangeFlag:=MTimeIniPathReg=MTimeIniPath
if(MENU2FLAG){
	FileGetTime,MTimeIniPath2, %iniPath2%, M  ; 获取修改时间.
	RegRead, MTimeIniPath2Reg, HKEY_CURRENT_USER\Software\RunAny, %iniPath2%
	RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, %iniPath2%, %MTimeIniPath2%
	IniChangeFlag:=IniChangeFlag && (MTimeIniPath2Reg=MTimeIniPath2)
}
if(rule_check_is_run(PluginsPathList["RunAny_SearchBar.ahk"])
	&& (!IniChangeFlag || !FileExist(RunAEvFullPathIniDirPath "\RunAnyMenuObj.ini")
	|| !FileExist(RunAEvFullPathIniDirPath "\RunAnyMenuObjExt.ini")
	|| !FileExist(RunAEvFullPathIniDirPath "\RunAnyMenuObjIcon.ini"))){
	Gosub,RunAny_SearchBar
	Run,% A_AhkPath A_Space """" PluginsPathList["RunAny_SearchBar.ahk"] """"
}
;如果有需要继续执行的操作
RegRead, ReloadGosub, HKEY_CURRENT_USER\Software\RunAny, ReloadGosub
if(ReloadGosub){
	RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, ReloadGosub, 0
	Gosub,%ReloadGosub%
}
;提前加载菜单树图标缓存
global TreeImageListID := IL_Create(11)
Icon_Image_Set(TreeImageListID)
Icon_Tree_Image_Set(TreeImageListID)
;~;[26.自动备份配置文件]
if(RunABackupRule && RunABackupDirPath!=A_ScriptDir){
	RunABackupFormatStr:=Get_Transform_Val(RunABackupFormat)
	RunABackup(RunABackupDirPath "\", RunAnyZz ".ini*", iniVar1, iniPath, RunAnyZz ".ini" RunABackupFormatStr)
	RunABackup(RunABackupDirPath "\" RunAnyZz "2.ini\", RunAnyZz "2.ini*", iniVar2, iniPath2, RunAnyZz "2.ini" RunABackupFormatStr)
	FileRead, iniVarBak, %RunAnyConfig%
	RunABackup(RunABackupDirPath "\" RunAnyConfig "\", RunAnyConfig "*", iniVarBak, RunAnyConfig, RunAnyConfig RunABackupFormatStr)
}
if(AutoReloadMTime>0){
	SetTimer,AutoReloadMTime,%AutoReloadMTime%
}
;如果需要自动关闭everything
if(EvAutoClose && EvPathRun){
	Run,%EvPathRun% -exit
}
return

;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

;━━━━ 模块引入：菜单工具函数 ━━━━
#Include *i lib\05_menu_util.ahk
;━━━━ 模块引入：菜单构建 ━━━━
#Include *i lib\05_menu_build.ahk
;━━━━ 模块引入：菜单显示 ━━━━
#Include *i lib\06_menu_display.ahk
;━━━━ 模块引入：菜单执行 ━━━━
#Include *i lib\07_menu_run.ahk
;━━━━ 模块引入：菜单编辑器GUI ━━━━
#Include *i lib\15_gui_menu_editor.ahk
;━━━━ 模块引入：插件管理GUI ━━━━
#Include *i lib\16_gui_plugins.ahk
;━━━━ 模块引入：规则管理GUI ━━━━
#Include *i lib\18_gui_runctrl_rule.ahk
;━━━━ 模块引入：设置GUI ━━━━
#Include *i lib\17_gui_settings.ahk
;━━━━ 模块引入：GUI事件处理 ━━━━
#Include *i lib\19_gui_events.ahk
;━━━━ 模块引入：热字符串GUI ━━━━
#Include *i lib\20_hotstring.ahk
;━━━━ 模块引入：搜索功能 ━━━━
#Include *i lib\08_search.ahk
;━━━━ 模块引入：通用函数方法 ━━━━
#Include *i lib\04_utility.ahk
;━━━━ 模块引入：配置初始化 ━━━━
#Include *i lib\09_config.ahk
;━━━━ 模块引入：图标管理 ━━━━
#Include *i lib\13_icon.ahk
;━━━━ 模块引入：插件系统 ━━━━
#Include *i lib\10_plugins.ahk
;━━━━ 模块引入：规则引擎 ━━━━
#Include *i lib\11_runctrl.ahk
;━━━━ 模块引入：托盘+更新 ━━━━
#Include *i lib\14_tray_update.ahk
;━━━━ 模块引入：Everything集成 ━━━━
#Include *i lib\12_everything.ahk
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
