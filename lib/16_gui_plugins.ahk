;══════════════════════════════════════════════════════════════════
;~;【——🧩插件Gui——】
;══════════════════════════════════════════════════════════════════
Plugins_Gui:
	if(A_ThisHotkey!=PluginsManageKey && GetKeyState("Ctrl")){
		Open_Folder_Path(A_ScriptDir "\" PluginsDir)
		return
	}
	Critical  ;防止短时间内打开多次界面出现问题
	Gosub,Plugins_Read
	;根据网络自动选择对应插件说明网页地址
	pagesPluginsUrl:=RunAnyGiteePages . "/runany/#"
	if(!rule_check_network(RunAnyGiteePages)){
		pagesPluginsUrl:=RunAnyGithubPages . "/RunAny/#"
	}
	pagesPlugins:=pagesPluginsUrl . "/plugins-help?id="
	pagesRunCtrl:=pagesPluginsUrl . "/run-ctrl?id="
	global PluginsHelpList:={"huiZz_QRCode.ahk":pagesPlugins "huizz_qrcode二维码脚本使用方法"}
	PluginsHelpList["huiZz_Window.ahk"]:=pagesPlugins "huizz_window窗口操作插件使用方法"
	PluginsHelpList["huiZz_System.ahk"]:=pagesPlugins "huizz_system系统操作插件使用方法"
	PluginsHelpList["huiZz_Text.ahk"]:=pagesPlugins "huizz_text文本操作插件使用方法"
	PluginsHelpList["RunAny_SearchBar.ahk"]:=pagesPluginsUrl "/plugins/runany-searchbar"
	PluginsHelpList["RunCtrl_Common.ahk"]:=pagesRunCtrl "runctrl_commonahk插件-公共规则函数库"
	PluginsHelpList["RunCtrl_Network.ahk"]:=pagesRunCtrl "runctrl_networkahk插件-网络规则函数库"
	global ColumnName:=1
	global ColumnStatus:=2
	global ColumnAutoRun:=3
	global ColumnContent:=5
	global PluginsImageListID:=IL_Create(6)
	Plugins_LV_Icon_Set(PluginsImageListID)
	listViewColumnName1:=!PluginsListViewSwap ? "独立" : RunAnyZz
	listViewColumnName2:=!PluginsListViewSwap ? RunAnyZz : "独立"
	Gui,PluginsManage:Destroy
	Gui,PluginsManage:Default
	Gui,PluginsManage:+Resize
	Gui,PluginsManage:Font, s10, Microsoft YaHei
	Gui,PluginsManage:Add, Listview, xm w730 r13 grid AltSubmit Checked vRunAnyPluginsLV1 hwndPLLV1 gPluginsListView1
		, %listViewColumnName1%插件脚本|运行状态|自动启动|插件描述|插件说明地址
	GuiControl,PluginsManage: -Redraw, RunAnyPluginsLV1
	LV_SetImageList(PluginsImageListID)
	NPLLV1 := New ListView(PLLV1)
	NPLLV_Index:=0
	For runn, runv in PluginsObjList
	{
		SplitPath,runn,,,,pname_no_ext
		if(!PluginsListViewSwap){
			if(PluginsObjRegGUID[pname_no_ext] || pname_no_ext="RunAny_Menu" || pname_no_ext="RunAny_ObjReg")
				Continue
		}else if(!PluginsObjRegGUID[pname_no_ext] && pname_no_ext!="RunAny_Menu" && pname_no_ext!="RunAny_ObjReg"){
			Continue
		}
		NPLLV_Index++
		runStatus:=rule_check_is_run(PluginsPathList[runn]) ? "启动" : ""
		pluginsConfig:=runv ? "自启" : ""
		if(!PluginsPathList[runn])
			pluginsConfig:="未找到"
		pluginsConfigChenk:=pluginsConfig="自启" ? "Check" : ""
		LV_Add(LVPluginsSetIcon(PluginsImageListID,runn) " " pluginsConfigChenk, runn, runStatus, pluginsConfig, PluginsNameList[runn], PluginsHelpList[runn])
		if(pluginsConfig!="自启" && !runStatus)
			NPLLV1.Color(NPLLV_Index,0x999999)
	}
	LV_ModifyCol(ColumnStatus, "SortDesc")  ; 排序
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	GuiControl,PluginsManage: +Redraw, RunAnyPluginsLV1

	Gui,PluginsManage:Add, Listview, xm y+10 w730 r12 grid AltSubmit Checked vRunAnyPluginsLV2 hwndPLLV2 gPluginsListView2
		, %listViewColumnName2%插件脚本|运行状态|自动启动|插件描述|插件说明地址
	GuiControl,PluginsManage: -Redraw, RunAnyPluginsLV2
	LV_SetImageList(PluginsImageListID)
	NPLLV2 := New ListView(PLLV2)
	NPLLV_Index:=0
	For runn, runv in PluginsObjList
	{
		SplitPath,runn,,,,pname_no_ext
		if(!PluginsListViewSwap){
			if(!PluginsObjRegGUID[pname_no_ext] && pname_no_ext!="RunAny_Menu" && pname_no_ext!="RunAny_ObjReg")
				Continue
		}else if(PluginsObjRegGUID[pname_no_ext] || pname_no_ext="RunAny_Menu" || pname_no_ext="RunAny_ObjReg"){
			Continue
		}
		NPLLV_Index++
		runStatus:=rule_check_is_run(PluginsPathList[runn]) ? "启动" : ""
		pluginsConfig:=runv ? "自启" : ""
		if(!PluginsPathList[runn])
			pluginsConfig:="未找到"
		pluginsConfigChenk:=pluginsConfig="自启" ? "Check" : ""
		LV_Add(LVPluginsSetIcon(PluginsImageListID,runn) " " pluginsConfigChenk, runn, runStatus, pluginsConfig, PluginsNameList[runn], PluginsHelpList[runn])
		if(pluginsConfig!="自启" && !runStatus)
			NPLLV2.Color(NPLLV_Index,0x999999)
	}
	LV_ModifyCol(ColumnStatus, "SortDesc")  ; 排序
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	GuiControl,PluginsManage: +Redraw, RunAnyPluginsLV2
	LVMenu("LVMenu")
	LVMenu("ahkGuiMenu")
	Gui,PluginsManage: Menu, ahkGuiMenu
	Gui,PluginsManage:Show, , %RunAnyZz% 插件管理 - 支持拖放 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	Critical,Off
return

LVMenu(addMenu){
	flag:=addMenu="ahkGuiMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "启动" : "启动`tF1", LVPluginsRun
	try Menu, %addMenu%, Icon,% flag ? "启动" : "启动`tF1", %A_AhkPath%,2
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", LVPluginsEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "自启" : "自启`tF3", LVPluginsEnable
	Menu, %addMenu%, Icon,% flag ? "自启" : "自启`tF3", SHELL32.dll,166
	Menu, %addMenu%, Add,% flag ? "关闭" : "关闭`tF4", LVPluginsClose
	Menu, %addMenu%, Icon,% flag ? "关闭" : "关闭`tF4", SHELL32.dll,28
	Menu, %addMenu%, Add,% flag ? "挂起" : "挂起`tF5", LVPluginsSuspend
	try Menu, %addMenu%, Icon,% flag ? "挂起" : "挂起`tF5", %A_AhkPath%,3
	Menu, %addMenu%, Add,% flag ? "暂停" : "暂停`tF6", LVPluginsPause
	try Menu, %addMenu%, Icon,% flag ? "暂停" : "暂停`tF6", %A_AhkPath%,4
	Menu, %addMenu%, Add,% flag ? "移除" : "移除`tF7", LVPluginsDel
	Menu, %addMenu%, Icon,% flag ? "移除" : "移除`tF7", SHELL32.dll,132
	Menu, %addMenu%, Add,% flag ? "下载插件" : "下载插件`tF8", LVPluginsAdd
	Menu, %addMenu%, Icon,% flag ? "下载插件" : "下载插件`tF8", SHELL32.dll,123
	Menu, %addMenu%, Add,% flag ? "插件说明" : "插件说明`tF9", LVPluginsHelp
	Menu, %addMenu%, Icon,% flag ? "插件说明" : "插件说明`tF9", SHELL32.dll,92
	Menu, %addMenu%, Add,% flag ? "插件库" : "插件库`tF10", LVPluginsLib
	Menu, %addMenu%, Icon,% flag ? "插件库" : "插件库`tF10", SHELL32.dll,42
	Menu, %addMenu%, Add,% flag ? "新建插件" : "新建插件`tF11", LVPluginsCreate
	Menu, %addMenu%, Icon,% flag ? "新建插件" : "新建插件`tF11", SHELL32.dll,1
	if(!flag)
		Menu, %addMenu%, Add, 上下交换, LVPluginsSwap
}
LVPluginsRun:
	menuItem:="启动"
	Gosub,LVApply
return
LVPluginsEdit:
	menuItem:="编辑"
	Gosub,LVApply
return
LVPluginsEnable:
	menuItem:="自启"
	Gosub,LVApply
return
LVPluginsClose:
	menuItem:="关闭"
	Gosub,LVApply
return
LVPluginsSuspend:
	menuItem:="挂起"
	Gosub,LVApply
return
LVPluginsPause:
	menuItem:="暂停"
	Gosub,LVApply
return
LVPluginsDel:
	menuItem:="移除"
	Gosub,LVApply
return
LVPluginsHelp:
	menuItem:="帮助"
	Gosub,LVApply
return
LVPluginsSwap:
	IniWrite,% !PluginsListViewSwap,%RunAnyConfig%,Config,PluginsListViewSwap
	Gosub,Plugins_Gui
return
LVApply:
	Gui,PluginsManage:Default
	GuiControlGet, focusGuiName, FocusV
	if(focusGuiName="RunAnyPluginsLV1"){
		Gui, ListView, RunAnyPluginsLV1
	}else if(focusGuiName="RunAnyPluginsLV2"){
		Gui, ListView, RunAnyPluginsLV2
	}
	DetectHiddenWindows,On      ;~显示隐藏窗口
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row && menuItem="移除"){
		MsgBox,35,确认移除？(Esc取消),确定移除选中的插件配置？(不会删除文件)
		DelRowList:=""
	}
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(FileName, RowNumber, ColumnName)
		LV_GetText(FileStatus, RowNumber, ColumnStatus)
		LV_GetText(FileAutoRun, RowNumber, ColumnAutoRun)
		FilePath:=PluginsPathList[FileName]
		if(menuItem="启动"){
			runValue:=RegExReplace(FilePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			try {
				SplitPath, runValue, name, dir, ext  ; 获取扩展名
				if(dir && FileExist(dir)){
					SetWorkingDir,%dir%
				}
				if(A_AhkPath && ext="ahk"){
					Run,%A_AhkPath%%A_Space%"%FilePath%"
				}else{
					Run,%FilePath%
				}
				LV_Modify(RowNumber, "", , "启动")
			} finally {
				SetWorkingDir,%A_ScriptDir%
			}
		}else if(menuItem="编辑"){
			Plugins_Edit(FilePath)
		}else if(menuItem="挂起"){
			PostMessage, 0x111, 65404,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(PluginsImageListID,RowNumber,FileStatus,"挂起",FileName)
		}else if(menuItem="暂停"){
			PostMessage, 0x111, 65403,,, %FilePath% ahk_class AutoHotkey
			LVStatusChange(PluginsImageListID,RowNumber,FileStatus,"暂停",FileName)
		}else if(menuItem="关闭"){
			runValue:=RegExReplace(FilePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			SplitPath, runValue, name,, ext  ; 获取扩展名
			if(ext="ahk"){
				PostMessage, 0x111, 65405,,, %FilePath% ahk_class AutoHotkey
				runStatus:=""
			}else if(name){
				Process,Close,%name%
				if ErrorLevel
					runStatus:=""
			}
			LV_Modify(RowNumber, "", , runStatus)
		}else if(menuItem="自启"){
			if(FileAutoRun!="未找到" && FileAutoRun!="自启"){
				IniWrite,1,%RunAnyConfig%,Plugins,%FileName%
				LV_Modify(RowNumber, "", , ,"自启")
			}else if(FileAutoRun="自启"){
				IniWrite,0,%RunAnyConfig%,Plugins,%FileName%
				LV_Modify(RowNumber, "", , ,"禁用")
			}
		}else if(menuItem="移除"){
			IfMsgBox Yes
			{
				DelRowList := RowNumber . ":" . DelRowList
				IniDelete,%RunAnyConfig%,Plugins,%FileName% ;删除插件管理数据
				SplitPath,FileName,,,,o_name_no_ext
				IniDelete,%RunAny_ObjReg_Path%,objreg,%o_name_no_ext% ;删除插件注册数据
			}
		}else if(menuItem="帮助"){
			if(PluginsHelpList[FileName]){
				Run,% PluginsHelpList[FileName]
			}else{
				Plugins_Edit(FilePath)
			}
		}
	}
	if(menuItem="移除"){
		IfMsgBox Yes
		{
			stringtrimright, DelRowList, DelRowList, 1
			loop, parse, DelRowList, :
				LV_Delete(A_loopfield)
		}
	}
	DetectHiddenWindows,Off
return
;[插件脚本编辑操作]
Plugins_Edit(FilePath){
	try{
		if(Trim(PluginsEditor," `t`r`n")!=""){
			Run,% Get_Obj_Path_Transform(PluginsEditor) A_Space """" FilePath """"
		}else{
			PostMessage, 0x111, 65401,,, %FilePath% ahk_class AutoHotkey
		}
	}catch{
		try{
			RegRead, AhkSetup, HKEY_LOCAL_MACHINE\SOFTWARE\Classes\AutoHotkeyScript
			if(AhkSetup){
				Run,edit "%FilePath%"
			}else{
				Run,notepad.exe "%FilePath%"
			}
		}catch{
			Run,notepad.exe "%FilePath%"
		}
	}
}
#If WinActive(RunAnyZz " 插件管理 - 支持拖放 " RunAny_update_version A_Space RunAny_update_time)
	F1::Gosub,LVPluginsRun
	F2::Gosub,LVPluginsEdit
	F3::Gosub,LVPluginsEnable
	F4::Gosub,LVPluginsClose
	F5::Gosub,LVPluginsSuspend
	F6::Gosub,LVPluginsPause
	F7::Gosub,LVPluginsDel
	F8::Gosub,LVPluginsAdd
	F9::Gosub,LVPluginsHelp
	F10::Gosub,LVPluginsLib
	F11::Gosub,LVPluginsCreate
#If
PluginsListView1:
PluginsListView2:
	LV_Num:=A_ThisLabel="PluginsListView1" ? 1 : 2
	if A_GuiEvent = DoubleClick
	{
		menuItem:="启动"
		Gosub,LVApply
	}else if(A_GuiEvent = "I"){
		Gui,ListView,% PLLV%LV_Num%
		LV_GetText(FileName, A_EventInfo, 1)
		LV_GetText(FileAutoRun, A_EventInfo, 3)
		if(errorlevel == "c" && FileAutoRun="自启"){
			IniWrite,0,%RunAnyConfig%,Plugins,%FileName%
			NPLLV%LV_Num%.Color(A_EventInfo,0x999999)
			LV_Modify(A_EventInfo, "", , ,"禁用")
		}else if(errorlevel == "C" && FileAutoRun="禁用"){
			IniWrite,1,%RunAnyConfig%,Plugins,%FileName%
			NPLLV%LV_Num%.Color(A_EventInfo,0x000000)
			LV_Modify(A_EventInfo, "", , ,"自启")
		}
	}
return
;~;【插件-下载插件】
LVPluginsAdd:
	Gosub,PluginsDownVersion
	Gui,PluginsDownload:Destroy
	Gui,PluginsDownload:Default
	Gui,PluginsDownload:+Resize
	Gui,PluginsDownload:Font, s10, Microsoft YaHei
	Gui,PluginsDownload:Add, Listview, xm w620 r17 grid AltSubmit Checked BackgroundF6F6E8 vRunAnyDownLV, 插件文件|状态|版本号|最新版本|插件描述
	GuiControl,PluginsDownload: -Redraw, RunAnyDownLV
	global PluginsDownImageListID:=IL_Create(6)
	Plugins_LV_Icon_Set(PluginsDownImageListID)
	LV_SetImageList(PluginsDownImageListID)
	For pk, pv in pluginsDownList
	{
		runStatus:=PluginsPathList[pk] ? "已下载" : "未下载"
		if(runStatus="已下载" && checkGithub)
			runStatus:=PluginsVersionList[pk] < pv ? "可更新" : "已最新"
		runCheck:=runStatus="可更新" ? " Select Check" : ""
		LV_Add(LVPluginsSetIcon(PluginsDownImageListID,pk) runCheck, pk, runStatus, PluginsVersionList[pk]
			, checkGithub ? pv : "网络异常",checkGithub ? pluginsNameList[pk] : PluginsNameList[pk])
	}
	GuiControl,PluginsDownload: +Redraw, RunAnyDownLV
	Menu, ahkDownMenu, Add,全部勾选, LVPluginsCheck
	Menu, ahkDownMenu, Icon,全部勾选, SHELL32.dll,145
	Menu, ahkDownMenu, Add,下载勾选的插件脚本, LVDown
	Menu, ahkDownMenu, Icon,下载勾选的插件脚本, SHELL32.dll,123
	Gui,PluginsDownload: Menu, ahkDownMenu
	LVModifyCol(65,ColumnStatus,ColumnAutoRun)
	Gui,PluginsDownload:Show, , %RunAnyZz% 插件下载 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
LVPluginsCheck:
	LV_Modify(0, "Check Focus")   ; 勾选所有.
return
LVPluginsCreate:
	newObjRegCount:=1
	Loop,%A_ScriptDir%\%PluginsDir%\RunAny_NewObjReg_*.ahk
	{
		newObjRegCount++
	}
	loop
	{
		InputBox, newObjRegInput, ObjReg新建插件脚本名称,`n  新建插件脚本（默认自动启动），名称建议为`n`n  作者名_功能.ahk,,,,,,,,RunAny_NewObjReg_%newObjRegCount%.ahk
		if !ErrorLevel
		{
			if(!FileExist(A_ScriptDir "\" PluginsDir "\" newObjRegInput))
				break
			else
				MsgBox, 48, 文件重名, 已有同名的脚本存在，请重新输入
		}else{
			return
		}
	}
	SplitPath, newObjRegInput,,,,inputNameNotExt
	;[新建ObjReg插件脚本模板]
	FileAppend,
(
;************************
;* 【ObjReg插件脚本 %newObjRegCount%】
;************************
global RunAny_Plugins_Version:="1.0.0"
#NoTrayIcon             ;~不显示托盘图标
#Persistent             ;~让脚本持久运行
#SingleInstance,Force   ;~运行替换旧实例
;********************************************************************************
#Include `%A_ScriptDir`%\RunAny_ObjReg.ahk

class RunAnyObj {
;[新建：你自己的函数]
;保存到RunAny.ini为：菜单项名|你的脚本文件名%inputNameNotExt%[你的函数名](参数1,参数2)
;你的函数名(参数1,参数2){
;函数内容写在这里
`t`t
;}
`t

	;══════════════════════════大括号以上是RunAny菜单调用的函数══════════════════════════

}

;═══════════════════════════以下是脚本自己调用依赖的函数═══════════════════════════

;独立使用方式
;F1::
;RunAnyObj.你的函数名(参数1,参数2)
;return
),%A_ScriptDir%\%PluginsDir%\%newObjRegInput%,UTF-8
	IniWrite,1,%RunAnyConfig%,Plugins,%newObjRegInput%
	Gosub,Plugins_Gui
	Run,notepad.exe %A_ScriptDir%\%PluginsDir%\%newObjRegInput%
return
;~;【插件-脚本库Gui】
LVPluginsLib:
	PluginsDirPath:=StrReplace(PluginsDirPath, "|", "`n")
	Gui,PluginsLib:Destroy
	Gui,PluginsLib:Default
	Gui,PluginsLib:+OwnerPluginsManage
	Gui,PluginsLib:Margin,20,20
	Gui,PluginsLib:Font,,Microsoft YaHei
	Gui,PluginsLib:Add, GroupBox,xm y+10 w460 h220
	Gui,PluginsLib:Add, Text, xm+5 y+35 y35 w80,%A_Space%默认插件库：
	Gui,PluginsLib:Add, Text, x+5 yp,%A_ScriptDir%\%PluginsDir%
	Gui,PluginsLib:Add, Button, xm+10 y+15 w80 gSetPluginsDirPath,其他插件库：`n支持多行`n支持变量
	Gui,PluginsLib:Add, Edit, x+5 yp w350 r5 vvPluginsDirPath, %PluginsDirPath%
	Gui,PluginsLib:Add, Button, xm+10 y+10 w80 gSetPluginsEditor,插件编辑器：`n支持无路径%A_Tab%
	Gui,PluginsLib:Add, Edit, x+5 yp w350 r2 vvPluginsEditor, %PluginsEditor%
	Gui,PluginsLib:Font
	Gui,PluginsLib:Add,Button,Default xm+130 y+35 w75 GSavePluginsLib,保存(&S)
	Gui,PluginsLib:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,PluginsLib:Show,,%RunAnyZz% - 插件脚本库 %RunAny_update_version% %RunAny_update_time%
return
SetPluginsDirPath:
	Gui,PluginsLib:Submit, NoHide
	FileSelectFolder, pluginsLibFolder, , 0
	if(pluginsLibFolder){
		if(vPluginsDirPath){
			GuiControl,, vPluginsDirPath, %vPluginsDirPath%`n%pluginsLibFolder%
		}else{
			GuiControl,, vPluginsDirPath, %pluginsLibFolder%
		}
	}
return
SetPluginsEditor:
	FileSelectFile, pluginsLibFile, , , 插件编辑器路径
	if(pluginsLibFile){
		GuiControl,, vPluginsEditor, %pluginsLibFile%
	}
return
SavePluginsLib:
	Gui,PluginsLib:Submit, NoHide
	vPluginsDirPath:=RegExReplace(vPluginsDirPath,"S)[\n]+","|")
	IniWrite,%vPluginsDirPath%,%RunAnyConfig%,Config,PluginsDirPath
	IniWrite,%vPluginsEditor%,%RunAnyConfig%,Config,PluginsEditor
	Gui,PluginsLib:Destroy
	Gui,PluginsManage:Destroy
	Gosub,Plugins_Gui
return

LVDown:
	MsgBox,33,RunAny下载插件,是否下载插件？如有修改过插件代码请注意备份！`n
	(
仅仅更新下载 %A_ScriptDir%\%PluginsDir% 目录下的插件
(旧版文件会转移到%A_Temp%\%RunAnyZz%\%PluginsDir%)
	)
	IfMsgBox Ok
	{
		if(!rule_check_network(giteeUrl)){
			RunAnyDownDir:=githubUrl . RunAnyGithubDir
			if(!rule_check_network(githubUrl)){
				MsgBox,48,,网络异常，无法连接网络读取最新版本文件，请手动下载
				return
			}
		}
		downFlag:=false
		firstUpdateFlag:=false
		Loop
		{
			RowNumber := LV_GetNext(RowNumber, "Checked")  ; 再找勾选的行
			if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
				break
			LV_GetText(FileName, RowNumber, ColumnName)
			LV_GetText(FileStatus, RowNumber, ColumnStatus)
			LV_GetText(FileContent, RowNumber, ColumnContent)
			TrayTip,,RunAny开始下载%FileName%，请稍等……,3,17
			SetTimer, HideTrayTip, -3000
			pluginsDownPath=%PluginsDir%
			;如果插件需要创建目录
			if(RegExMatch(FileContent,"iS)\{\}$")){
				SplitPath, FileName, fName,, fExt, name_no_ext
				pluginsDownPath.="\" name_no_ext
				CreateDir(A_ScriptDir "\" pluginsDownPath)
			}
			;特殊插件下载依赖
			if(FileName="huiZz_QRCode.ahk"){
				TrayTip,,huiZz_QRCode需要下载quricol32.dll，请稍等……,3,17
				SetTimer, HideTrayTip, -3000
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/" name_no_ext "/quricol32.dll",A_ScriptDir "\" pluginsDownPath "\quricol32.dll")
				Plugins_Down_Check("二维码插件quricol32.dll", A_ScriptDir "\" pluginsDownPath "\quricol32.dll")
				if(A_Is64bitOS){
					URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/" name_no_ext "/quricol64.dll",A_ScriptDir "\" pluginsDownPath "\quricol64.dll")
					Plugins_Down_Check("二维码插件quricol64.dll", A_ScriptDir "\" pluginsDownPath "\quricol64.dll")
				}
			}else if(FileName="RunCtrl_Network.ahk"){
				TrayTip,,RunCtrl_Network.ahk需要下载组件JSON.ahk，请稍等……,3,17
				SetTimer, HideTrayTip, -3000
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/Lib/JSON.ahk",A_ScriptDir "\" PluginsDir "\Lib\JSON.ahk")
				Plugins_Down_Check("RunCtrl_Network.ahk需要下载组件JSON.ahk", A_ScriptDir "\" PluginsDir "\Lib\JSON.ahk")
			}else if(FileName="RunAny_SearchBar.ahk"){
				TrayTip,,RunAny_SearchBar.ahk需要下载汉字转拼音组件ChToPy.ahk，请稍等……,3,17
				SetTimer, HideTrayTip, -3000
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/Lib/ChToPy.ahk",A_ScriptDir "\" PluginsDir "\Lib\ChToPy.ahk")
				CreateDir(A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_32")
				URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/Lib/ChToPy_dll_32/cpp2ahk.dll",A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_32\cpp2ahk.dll")
				if(A_Is64bitOS){
					CreateDir(A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_64")
					URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/Lib/ChToPy_dll_64/cpp2ahk.dll",A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_64\cpp2ahk.dll")
					Sleep, 1000
					Plugins_Down_Check(PluginsDir "\Lib\ChToPy_dll_64\cpp2ahk.dll", A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_64\cpp2ahk.dll")
				}
				Sleep, 1000
				Plugins_Down_Check("RunAny_SearchBar.ahk需要下载汉字转拼音组件ChToPy.ahk", A_ScriptDir "\" PluginsDir "\Lib\ChToPy.ahk")
				Plugins_Down_Check(PluginsDir "\Lib\ChToPy_dll_32\cpp2ahk.dll", A_ScriptDir "\" PluginsDir "\Lib\ChToPy_dll_32\cpp2ahk.dll")
			}
			;[下载插件脚本]
			IfExist,%A_ScriptDir%\%pluginsDownPath%\%FileName%
				FileMove,%A_ScriptDir%\%pluginsDownPath%\%FileName%,%A_Temp%\%RunAnyZz%\%pluginsDownPath%\%FileName%,1
			URLDownloadToFile(RunAnyDownDir "/" StrReplace(pluginsDownPath,"\","/") "/" FileName,A_ScriptDir "\" pluginsDownPath "\" FileName)
			Sleep,1000
			Plugins_Down_Check(FileName, A_ScriptDir "\" pluginsDownPath "\" FileName)
			downFlag:=true
			if(FileStatus="未下载"){
				firstUpdateFlag:=true
			}
		}
		if(downFlag){
			if(firstUpdateFlag){
				if(PluginsHelpList[FileName]){
					Run,%pagesPluginsUrl%
					Sleep,1000
					MsgBox, 64, ,RunAny插件下载成功，请在网页上阅读对应插件使用说明后使用
				}else{
					MsgBox, 64, ,RunAny插件下载成功，在插件管理界面点击“编辑”按钮可以阅读说明和进行配置
				}
			}
			RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, ReloadGosub, Plugins_Gui
			Gosub,Menu_Reload
		}else{
			ToolTip,请至少选中一项
			SetTimer,RemoveToolTip,2000
		}
	}
return
;[加载插件脚本图标]
Plugins_LV_Icon_Set(PluginsImageListID){
	IL_Add(PluginsImageListID, A_AhkPath, 1)
	IL_Add(PluginsImageListID, A_AhkPath, 2)
	IL_Add(PluginsImageListID, A_AhkPath, 3)
	IL_Add(PluginsImageListID, A_AhkPath, 4)
	IL_Add(PluginsImageListID, A_AhkPath, 5)
	IL_Add(PluginsImageListID, FuncIconS[1], FuncIconS[2])
}
;[插件管理独立脚本一键关闭]
Plugins_Alone_Pause:
	Plugins_Alone("暂停")
return
Plugins_Alone_Suspend:
	Plugins_Alone("挂起")
return
Plugins_Alone_Close:
	Plugins_Alone("关闭")
return
Plugins_Alone(r){
	DetectHiddenWindows,On      ;~显示隐藏窗口
	For runn, runv in PluginsPathList
	{
		SplitPath,runv,,,,pname_no_ext
		if(PluginsObjRegGUID[pname_no_ext]){
			continue
		}
		if(r="暂停"){
			PostMessage, 0x111, 65403,,, %runv% ahk_class AutoHotkey
		}else if(r="挂起"){
			PostMessage, 0x111, 65404,,, %runv% ahk_class AutoHotkey
		}else if(r="关闭"){
			PostMessage, 0x111, 65405,,, %runv% ahk_class AutoHotkey
		}
	}
	DetectHiddenWindows,Off
}

LVPluginsSetIcon(PluginsImageListID,pname){
	if(PluginsIconList[pname]){
		FileIconS:=StrSplit(Get_Transform_Val(PluginsIconList[pname]),",")
		addNum:=IL_Add(PluginsImageListID, FileIconS[1], FileIconS[2])
		return "Icon" addNum
	}
	SplitPath,pname,,,,pname_no_ext
	if(PluginsObjRegGUID[pname_no_ext]){
		return "Icon6"
	}
	return "Icon2"
}
;[判断脚本当前状态]
LVStatusChange(PluginsImageListID,RowNumber,FileStatus,lvItem,FileName){
	item:=lvItem
	if(FileStatus="挂起" && lvItem="暂停"){
		LV_Modify(RowNumber, "Icon5", ,"挂起暂停")
		LV_ModifyCol()
		return
	}else if(FileStatus="暂停" && lvItem="挂起"){
		LV_Modify(RowNumber, "Icon5", ,"暂停挂起")
		LV_ModifyCol()
		return
	}else if(FileStatus!="启动"){
		StringReplace, lvItem, FileStatus, %item%
	}
	if(lvItem="")
		lvItem:="启动"
	if(lvItem="启动"){
		LV_Modify(RowNumber, LVPluginsSetIcon(PluginsImageListID,FileName), ,lvItem)
	}else if(lvItem="挂起"){
		LV_Modify(RowNumber, "Icon3", ,lvItem)
	}else if(lvItem="暂停"){
		LV_Modify(RowNumber, "Icon4", ,lvItem)
	}
	LV_ModifyCol()
}
;══════════════════════════════════════════════════════════════════
