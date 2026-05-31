;*************************************************
;* 【ObjReg菜单项搜索插件】
;*             by RunAny
;*************************************************
global RunAny_Plugins_Name:="ObjReg菜单项搜索插件"
global RunAny_Plugins_Version:="1.0.0"
global RunAny_Plugins_Icon:="SHELL32.dll,22"

;【使用说明】
; 在RunAny.ini中添加菜单项（任选一个）：
;   搜索菜单项|RunAny_MenuSearch[show_menu_search]()
;   搜索菜单项|RunAny_MenuSearch[show_menu_search](%getZz%)
; 配置后选中目标 -> 触发菜单 -> 点击"搜索菜单项" -> 弹出搜索GUI
;
; 需将本插件设置为【自启】，以便读取菜单数据

#NoTrayIcon
#Persistent
#WinActivateForce
#SingleInstance,Force
ListLines,Off
SendMode,Input
SetBatchLines,-1
SetControlDelay,0
SetWinDelay,0
SetTitleMatchMode,2
CoordMode,Menu,Window
CoordMode,Mouse,Screen

;WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
#Include %A_ScriptDir%\..\RunAny_ObjReg.ahk

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【全局变量】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
global rAAhkMatch := "RunAny.ahk ahk_class AutoHotkey"
global MenuSearchIndex := Object()   ;搜索索引：{菜单项全名: 分类名}
global MenuSearchIndexBuilt := false  ;索引是否已构建
global MenuSearchGuiVisible := false ;搜索GUI是否可见

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【ObjReg类 - 菜单项搜索入口】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class RunAnyObj {
	;[搜索菜单项]
	;写入RA配置文件：搜索菜单项|RunAny_MenuSearch[show_menu_search]()
	;或：搜索菜单项|RunAny_MenuSearch[show_menu_search](%getZz%)
	show_menu_search(getZz:=""){
		Gosub, Label_Menu_Search_Show
	}
}

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【构建搜索索引】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label_Menu_Search_Build_Index:
	MenuSearchIndex := Object()

	;读取RunAny配置目录
	SplitPath, A_AhkPath, , RunAnyConfigDir
	IniRead, RunAEvFullPathIniDir, %RunAnyConfigDir%\RunAnyConfig.ini, Config, RunAEvFullPathIniDir, %A_Space%
	if(RunAEvFullPathIniDir="")
		INI_Path := A_AppData "\RunAny"
	else {
		Transform, INI_Path, Deref, % RunAEvFullPathIniDir
	}

	;读取菜单项数据（RunAnyMenuObj.ini 由主进程导出）
	INI_MenuObj := INI_Path "\RunAnyMenuObj.ini"
	if(!FileExist(INI_MenuObj)){
		Send_WM_COPYDATA("runany[ShowTrayTip](菜单项搜索,首次运行无法读取菜单信息，请将本插件设置为【自启】后重启RunAny！,20,17)", rAAhkMatch)
		return
	}

	;从RunAny.ini解析分类信息
	catMap := Object()

	;第一步：从RunAny.ini解析分类结构
	RA_INI := RunAnyConfigDir "\RunAny.ini"
	if(FileExist(RA_INI)){
		currentCat1 := ""
		currentCat2 := ""
		Loop, Read, %RA_INI%
		{
			line := A_LoopReadLine
			;跳过注释和空行
			if(SubStr(line,1,1)=";")
				continue
			if(Trim(line)="")
				continue

			;检测一级分类（-开头，但不是--）
			if(RegExMatch(line, "^-[^-]")){
				currentCat1 := RegExReplace(line, "^-+")
				currentCat2 := ""
				continue
			}
			;检测二级分类（--开头）
			if(RegExMatch(line, "^--")){
				currentCat2 := RegExReplace(line, "^-+")
				continue
			}
			;检测分类结束（单独的--）
			if(RegExMatch(line, "^--\s*$")){
				currentCat2 := ""
				continue
			}

			;菜单项行：提取名称
			if(currentCat1!="" && RegExMatch(line, "^[^\s]")){
				;去掉Tab后的热键部分
				itemName := RegExReplace(line, "\t.*$", "")
				;去掉|后面的路径部分
				itemName := RegExReplace(itemName, "\|.*$", "")
				itemName := Trim(itemName)
				if(itemName!="" && !catMap.HasKey(itemName)){
					category := currentCat2!="" ? currentCat1 "\" currentCat2 : currentCat1
					catMap[itemName] := category
				}
			}
		}
	}

	;第二步：从RunAnyMenuObj.ini读取所有菜单项
	Loop, Read, %INI_MenuObj%
	{
		if(A_Index=1)
			continue  ;跳过[section]行
		equalPos := InStr(A_LoopReadLine, "=")
		if(!equalPos)
			continue
		name := SubStr(A_LoopReadLine, 1, equalPos-1)
		if(name="")
			continue

		;查找分类
		searchName := RegExReplace(name, "\t.*$", "")
		searchName := RegExReplace(searchName, "重名$", "")
		category := catMap.HasKey(searchName) ? catMap[searchName] : ""

		MenuSearchIndex[name] := category
	}

	MenuSearchIndexBuilt := true
return

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【显示搜索GUI】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Label_Menu_Search_Show:
	if(!MenuSearchIndexBuilt)
		Gosub, Label_Menu_Search_Build_Index

	if(MenuSearchIndexBuilt=false || MenuSearchIndex.Count()=0){
		Send_WM_COPYDATA("runany[ShowTrayTip](菜单项搜索,菜单数据为空，请将本插件设置为【自启】后重启RunAny！,20,17)", rAAhkMatch)
		return
	}

	;获取鼠标位置
	CoordMode, Mouse, Screen
	MouseGetPos, searchX, searchY

	searchGuiW := 320, searchGuiH := 260
	if(searchX+searchGuiW>A_ScreenWidth)
		searchX := A_ScreenWidth-searchGuiW-5
	if(searchY+searchGuiH>A_ScreenHeight)
		searchY := A_ScreenHeight-searchGuiH-5
	if(searchX<0)
		searchX := 5
	if(searchY<0)
		searchY := 5

	;创建搜索GUI
	Gui, MenuSearchGui:Destroy
	Gui, MenuSearchGui:New, +ToolWindow +AlwaysOnTop -Caption +Border, 搜索菜单项
	Gui, MenuSearchGui:Font, s10, Microsoft YaHei
	Gui, MenuSearchGui:Add, Edit, vMenuSearchEdit gMenuSearchEditChange w300 x5 y5,
	Gui, MenuSearchGui:Add, ListView, vMenuSearchList gMenuSearchListEvent w300 h200 x5 y35 -Multi +AltSubmit -Hdr, 名称|分类|_key
	Gui, MenuSearchGui:Add, Text, vMenuSearchStatus w300 x5 y240 +0x200, 输入关键字搜索菜单项
	Gui, MenuSearchGui:Show, x%searchX% y%searchY% w310 h260

	;设置列宽
	LV_ModifyCol(1, 200)
	LV_ModifyCol(2, 95)
	LV_ModifyCol(3, 0)  ;隐藏第3列（存储完整key）

	;聚焦搜索框
	GuiControl, MenuSearchGui:Focus, MenuSearchEdit

	;启动失焦检测定时器
	MenuSearchGuiVisible := true
	SetTimer, MenuSearchCheckFocus, 200
return

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【搜索框输入变化 - 实时搜索】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MenuSearchEditChange:
	GuiControlGet, searchText, MenuSearchGui:, MenuSearchEdit
	Gui, MenuSearchGui:Default
	GuiControl, MenuSearchGui:-Redraw, MenuSearchList
	LV_Delete()

	matchCount := 0

	if(searchText!="")
	{
		For itemName, category in MenuSearchIndex
		{
			;匹配可见部分（去掉Tab热键部分）
			visibleName := RegExReplace(itemName, "\t.*$", "")
			if(InStr(visibleName, searchText, false))
			{
				displayCategory := category!="" ? category : "—"
				LV_Add("", visibleName, displayCategory, itemName)
				matchCount++
			}
		}
	}

	;按名称排序
	LV_ModifyCol(1, "Sort")

	GuiControl, MenuSearchGui:+Redraw, MenuSearchList

	;更新状态栏
	if(searchText="")
		GuiControl, MenuSearchGui:, MenuSearchStatus, 输入关键字搜索菜单项
	else if(matchCount=0)
		GuiControl, MenuSearchGui:, MenuSearchStatus, 无匹配结果
	else
		GuiControl, MenuSearchGui:, MenuSearchStatus, 匹配 %matchCount% 项

	;选中第一项
	if(matchCount>0)
		LV_Modify(1, "Select Vis Focus")
return

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【列表事件处理（双击/Enter）】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MenuSearchListEvent:
	if(A_GuiEvent="DoubleClick")
		Gosub, Menu_Search_Run
	else if(A_GuiEvent="K" && ErrorLevel=13)  ;Enter键
		Gosub, Menu_Search_Run
return

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【运行选中项】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Menu_Search_Run:
	Gui, MenuSearchGui:Default
	focusedRow := LV_GetNext(0, "Focused")
	if(!focusedRow)
		return

	;从隐藏列获取完整key
	LV_GetText(selectedFullKey, focusedRow, 3)

	if(selectedFullKey="")
		return

	;关闭搜索GUI
	Gui, MenuSearchGui:Destroy
	SetTimer, MenuSearchCheckFocus, Off
	MenuSearchGuiVisible := false

	;通过WM_COPYDATA调用主进程的Remote_Menu_Run运行菜单项
	result := Send_WM_COPYDATA("runany[Remote_Menu_Run](" selectedFullKey ")", rAAhkMatch)
return

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【搜索GUI关闭/ESC】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MenuSearchGuiEscape:
MenuSearchGuiClose:
	Gui, MenuSearchGui:Destroy
	SetTimer, MenuSearchCheckFocus, Off
	MenuSearchGuiVisible := false
return

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【失焦自动关闭】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MenuSearchCheckFocus:
	Gui, MenuSearchGui:+LastFound
	if(!WinExist() || !WinActive())
	{
		Gui, MenuSearchGui:Destroy
		SetTimer, MenuSearchCheckFocus, Off
		MenuSearchGuiVisible := false
	}
return

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【搜索GUI键盘快捷键】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#If WinActive("搜索菜单项 ahk_class AutoHotkeyGUI")
Esc::
	Gosub, MenuSearchGuiEscape
return
Enter::
	Gosub, Menu_Search_Run
return
Down::
	GuiControlGet, ctrlName, FocusV
	if(ctrlName="MenuSearchEdit") {
		Gui, MenuSearchGui:Default
		focusedRow := LV_GetNext(0, "Focused")
		if(!focusedRow)
			LV_Modify(1, "Select Vis Focus")
		GuiControl, MenuSearchGui:Focus, MenuSearchList
	} else {
		Send, {Down}
	}
return
Up::
	GuiControlGet, ctrlName, FocusV
	if(ctrlName="MenuSearchList") {
		Gui, MenuSearchGui:Default
		focusedRow := LV_GetNext(0, "Focused")
		if(focusedRow<=1) {
			GuiControl, MenuSearchGui:Focus, MenuSearchEdit
		} else {
			Send, {Up}
		}
	} else {
		Send, {Up}
	}
return
#If

;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;~;【进程间通信】
;━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle, ByRef TimeOutTime:=4000){
	VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
	SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
	NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	SendMessage, 0x004A, 0, &CopyDataStruct,, %TargetScriptTitle%, , , , %TimeOutTime%
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	SetTitleMatchMode %Prev_TitleMatchMode%
	return ErrorLevel
}
