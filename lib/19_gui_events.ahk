;TreeView自定义项目颜色
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=2632
class treeview{
	static list:=[]
	__New(hwnd){
		this.list[hwnd]:=this
		OnMessage(0x4e,"WM_NOTIFY_TV")
		this.hwnd:=hwnd,this.selectcolor:=""
	}
	add(info){
		Gui,TreeView,% this.hwnd
		hwnd:=TV_Add(info.Label,info.parent,info.option)
		if info.fore!=""
			this.control["|" hwnd,"fore"]:=info.fore
		if info.back!=""
			this.control["|" hwnd,"back"]:=info.back
		return hwnd
	}
	modify(info){
		this.control["|" info.hwnd,"fore"]:=info.fore
		this.control["|" info.hwnd,"back"]:=info.back
		WinSet,Redraw,,A
	}
	Remove(hwnd){
		this.control.Remove("|" hwnd)
	}
}
WM_NOTIFY_TV(Param*){
	static list:=[],ll:=""
	control:=""
	if (this:=treeview.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001&&info:=this.control["|" numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")]){ ;NM_CUSTOMDRAW && Control is in the list
			if info.fore!=""
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
		if (this.selectcolor){
			Gui,TreeView,% NumGet(param.2)
			if (NumGet(param.2,9*A_PtrSize)=TV_GetSelection())
				NumPut(this.selectcolor,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}
;ListView自定义行颜色
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3286&p=304384
class ListView{
	static list:=[]
	__New(hwnd){
		this.list[hwnd]:=this
		OnMessage(0x4e,"WM_NOTIFY")
		this.hwnd:=hwnd
		this.control:=[]
	}
	add(options,items*){
		Gui,ListView,% this.hwnd
		for a,b in items{
			if A_Index=1
				item:=LV_Add(options,b)
			Else
				LV_Modify(item,"col" A_Index,b)
		}
	}
	clear(){
		this.control:=[]
	}
	Color(item,fore="",back=""){
		LV_GetText(text,item)
		if fore!=""
			this.Control[text,"fore"]:=fore
		if Back!=""
			this.Control[text,"back"]:=back
	}
}
WM_NOTIFY(Param*){
	Critical
	control:=
	if (this:=ListView.list[NumGet(Param.2)])&&(NumGet(Param.2,2*A_PtrSize,"int")=-12){
		stage:=NumGet(Param.2,3*A_PtrSize,"uint")
		if (stage=1)
			return 0x20 ;sets CDRF_NOTIFYITEMDRAW
		if (stage=0x10001){ ;NM_CUSTOMDRAW && Control is in the list
			index:=numget(Param.2,A_PtrSize=4?9*A_PtrSize:7*A_PtrSize,"uint")
			LV_GetText(text,index+1)
			info:=this.Control[text]
			if info.fore!=""
				NumPut(info.fore,Param.2,A_PtrSize=4?12*A_PtrSize:10*A_PtrSize,"int") ;sets the foreground
			if info.back!=""
				NumPut(info.back,Param.2,A_PtrSize=4?13*A_PtrSize:10.5*A_PtrSize,"int") ;sets the background
		}
	}
}
;--------------------------------------------------------------------------------------------
listviewAdvancedConfig:
	if A_GuiEvent = DoubleClick
	{
		SendInput,{F2}
	}else if A_GuiEvent = e
	{
		Gui, ListView, AdvancedConfigLV
		AdvancedConfigFlag:=true
		LV_GetText(vn, A_EventInfo, 1)
		LV_Modify(A_EventInfo, vn ? "Icon1" : "Icon2")
	}
return
;[窗口控件控制函数]
GuiControlShow(guiName,controls*){
	For k,v in controls
	{
		GuiControl, %guiName%:Show, %v%
	}
}
GuiControlHide(guiName,controls*){
	For k,v in controls
	{
		GuiControl, %guiName%:Hide, %v%
	}
}
GuiControlSet(guiName,controlName,controlVal:=""){
	GuiControl, %guiName%:, %controlName%, %controlVal%
}
;~;【——🗔窗口事件Gui——】
MenuEditGuiClose:
	if(TVFlag){
		MsgBox,51,菜单树退出,已修改过菜单信息，是否保存修改再退出？
		IfMsgBox Yes
		{
			Gosub,Menu_Save
			Gosub,Menu_Reload
		}
		IfMsgBox No
			Gui, Destroy
	}else{
		Gui, Destroy
	}
return
;[GuiDropFiles]  ; 对拖放提供支持.
MenuEditGuiDropFiles:
SaveItemGuiDropFiles:
	Loop, Parse, A_GuiEvent, `n
	{
		SelectedFileName = %A_LoopField%  ; 仅获取首个文件 (如果有多个文件的时候).
		break
	}
	;获取鼠标下面的控件
	MouseGetPos, , , id, control
	WinGetClass, class, ahk_id %id%
	if(control="SysTreeView321"){
		Loop, Parse, A_GuiEvent, `n
		{
			fileID:=TV_Add(Get_Item_Run_Path(A_LoopField),0,Set_Icon(TreeImageListID,A_LoopField))
			TVFlag:=true
		}
	}
	if(control="Edit1"){
		GuiControl,SaveItem:, vitemName, % Get_Item_Run_Path(SelectedFileName)
	}
	if(control="Edit4"){
		GuiControl,SaveItem:, vitemPath, % Get_Item_Run_Path(SelectedFileName)
	}
	Gosub,EditItemPathChange
return
PluginsManageGuiDropFiles:
	MsgBox,33,RunAny新增插件,是否复制脚本文件到插件目录？`n%A_ScriptDir%\%PluginsDir%
	IfMsgBox Ok
	{
		Loop, Parse, A_GuiEvent, `n
		{
			FileCopy, %A_LoopField%, %A_ScriptDir%\%PluginsDir%
		}
		Gosub,Plugins_Gui
	}
return
;[GuiContextMenu]
MenuEditGuiContextMenu:
PluginsManageGuiContextMenu:
	If (A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
		Menu, TVMenu, Show
	}
	If (A_GuiControl = "RunAnyPluginsLV1" || A_GuiControl = "RunAnyPluginsLV2") {
		LV_Modify(A_EventInfo, "Select Vis")
		Menu, LVMenu, Show
	}
return
RunCtrlManageGuiContextMenu:
	If (A_GuiControl = "RunCtrlListBox" || A_GuiControl = "RunCtrlLV") {
		TV_Modify(A_EventInfo, "Select Vis")
		Menu, RunCtrlLVMenu, Show
	}
return
;[GuiSize]
MenuEditGuiSize:
MenuObjShowGuiSize:
RuleManageGuiSize:
RunCtrlConfigGuiSize:
RunCtrlFuncGuiSize:
PluginsManageGuiSize:
PluginsDownloadGuiSize:
OneKeyDownGuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunAnyTV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyPluginsLV1, % "H" . (A_GuiHeight * 0.50) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyPluginsLV2, % "H" . (A_GuiHeight * 0.49) . " W" . (A_GuiWidth - 20) . " y" . (A_GuiHeight * 0.50 + 10)
	GuiControl, Move, RuleLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyDownLV, % "H" . (A_GuiHeight-10) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, RunAnyOneKeyDownLV, % "H" . (A_GuiHeight-20) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, RunAnyMenuObjShowLV, % "H" . (A_GuiHeight-20) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, FuncGroup, % "H" . (A_GuiHeight-130) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, FuncLV, % "H" . (A_GuiHeight-270) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, vFuncValue, % "H" . (A_GuiHeight-230) . " W" . (A_GuiWidth - 40)
	GuiControl, MoveDraw, vFuncSave, % " X" . (A_GuiWidth * 0.30) . " Y" . (A_GuiHeight - 50)
	GuiControl, MoveDraw, vFuncCancel, % " X" . (A_GuiWidth * 0.30 + 100) . " Y" . (A_GuiHeight - 50)
return
66GuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, ConfigTab, % "H" . (A_GuiHeight * 0.88) . " W" . (A_GuiWidth - 20)
	GuiControl, Move, vDisableAppGroup, % "H" . (A_GuiHeight * 0.88 - 395) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, vDisableApp, % "H" . (A_GuiHeight * 0.88 - 435) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyHotkeyLV, % "H" . (A_GuiHeight * 0.88 - 214) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyMenuVarLV, % "H" . (A_GuiHeight * 0.88 - 121) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyMenuObjPathLV, % "H" . (A_GuiHeight * 0.88 - 121) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, vRunAEvFullPathIniDir, % " W" . (A_GuiWidth - 388)
	GuiControl, Move, vEvSetupGroup, % " W" . (A_GuiWidth - 40)
	GuiControl, Move, vEvPath, % " W" . (A_GuiWidth - 120)
	GuiControl, Move, vEvCommandGroup, % "H" . (A_GuiHeight * 0.88 - 248) . " W" . (A_GuiWidth - 40)
	GuiControl, Move, vEvCommand, % "H" . (A_GuiHeight * 0.88 - 408) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, RunAnyOneKeyLV, % " W" . (A_GuiWidth - 40)
	GuiControl, Move, vOneKeyUrlGroup, % " W" . (A_GuiWidth - 40)
	GuiControl, Move, vOneKeyUrl, % " W" . (A_GuiWidth - 60)
	GuiControl, Move, vBrowserPath, % " W" . (A_GuiWidth - 120)
	GuiControl, Move, RunAnyOpenExtLV, % "H" . (A_GuiHeight * 0.88 - 121 ) . " W" . (A_GuiWidth - 60)
	GuiControl, Move, vHotStrGroup, % "H" . (A_GuiHeight * 0.80)
	GuiControl, Move, AdvancedConfigLV, % "H" . (A_GuiHeight * 0.88 - 76) " W" . (A_GuiWidth - 60)
	GuiControl, MoveDraw, vSetOK, % " X" . (A_GuiWidth * 0.30) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vSetCancel, % " X" . (A_GuiWidth * 0.30 + 90) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vSetReSet, % " X" . (A_GuiWidth * 0.30 + 180) . " Y" . (A_GuiHeight * 0.92)
	GuiControl, MoveDraw, vMenu_Config, % " X" . (A_GuiWidth * 0.30 + 310) . " Y" . (A_GuiHeight * 0.925)
return
SaveItemGuiSize:
	if A_EventInfo = 1
		return
	GuiControl,SaveItem:MoveDraw, vitemName, % "W" . (A_GuiWidth-450)
	GuiControl,SaveItem:MoveDraw, vitemAdminRun, % "x" . (A_GuiWidth-330)
	GuiControl,SaveItem:MoveDraw, vitemPath, % "H" . (A_GuiHeight-260) . " W" . (A_GuiWidth - 120)
	GuiControl,SaveItem:MoveDraw, vPictureIconAdd,% "x" . (A_GuiWidth-130)
	GuiControl,SaveItem:MoveDraw, vTextIconAdd,% "x" . (A_GuiWidth-150)
	GuiControl,SaveItem:MoveDraw, vTextIconDown,% "x" . (A_GuiWidth-100)
	GuiControl,SaveItem:MoveDraw, vSaveItemSaveBtn,% "x" . (A_GuiWidth / 2 - 100) . " y" . (A_GuiHeight-85)
	GuiControl,SaveItem:MoveDraw, vSaveItemCancelBtn,% "x" . (A_GuiWidth / 2 + 10) . " y" . (A_GuiHeight-85)
	GuiControl,SaveItem:MoveDraw, vExplain,% "x30" . " y" . (A_GuiHeight-45)
return
RunCtrlManageGuiSize:
	if A_EventInfo = 1
		return
	GuiControl, Move, RunCtrlListBox, % "H" . (A_GuiHeight-15)
	GuiControl, Move, RunCtrlLV, % "H" . (A_GuiHeight-20) . " W" . (A_GuiWidth - 175)
return
;[GuiEscape]
MenuEditGuiEscape:
MenuObjShowGuiEscape:
SaveItemGuiEscape:
PluginsManageGuiEscape:
PluginsDownloadGuiEscape:
PluginsLibGuiEscape:
PluginsIconGuiEscape:
RunCtrlManageGuiEscape:
RunCtrlConfigGuiEscape:
RunCtrlFuncGuiEscape:
CtrlRunGuiEscape:
RuleManageGuiEscape:
RuleConfigGuiEscape:
99GuiEscape:
keyGuiEscape:
OneKeyGuiEscape:
OneKeyDownGuiEscape:
SavePathGuiEscape:
SaveExtGuiEscape:
SaveVarGuiEscape:
SetCancel:
	Gui,Destroy
return

