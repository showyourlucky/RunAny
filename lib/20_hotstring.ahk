CreateHotStrGui(msg:="",Byref HotStrGuiW="", Byref HotStrGuiH=""){ ;生成热字符串Gui
	;配置文件配置项
	HotStrGuiBackColor := "333434"		;背景颜色
	HotStrGuiFontColor_cover := "red"	;覆盖文字颜色
	HotStrGuiFontColor := "02ecfb"		;文字颜色
	HotStrGuiFontSize := 15 			;文字大小

	static msgold:="",HotStrGui_Edit_Hwnd1
	global HotStrGui_id
	DetectHiddenWindows on
	Gui, HotStrGui:+AlwaysOnTop
	If (msgold=msg[2]){
		Gui, HotStrGui_Ref:-SysMenu +ToolWindow +AlwaysOnTop -Caption +E0x20
		Gui, HotStrGui_Ref:Font, c%HotStrGuiFontColor% s%HotStrGuiFontSize%, Segoe UI
		Gui, HotStrGui_Ref:Add,Text, HwndHotStrGui_Ref_Edit_Hwnd1, % msg[1]
		ControlGetPos, , , Text_W, Text_H, , ahk_id %HotStrGui_Ref_Edit_Hwnd1%
		Gui, HotStrGui_Ref:Destroy
		GuiControl, , %HotStrGui_Edit_Hwnd1% , % msg[1]
		GuiControl, Hide, %HotStrGui_Edit_Hwnd1%
		GuiControl, Move, %HotStrGui_Edit_Hwnd1%, w%Text_W%
		GuiControl, Show, %HotStrGui_Edit_Hwnd1%
		DetectHiddenWindows off
		Return
	}Else
		msgold := msg[2]
	Gui, HotStrGui:Destroy
	Gui, HotStrGui:-SysMenu +ToolWindow +AlwaysOnTop -Caption +HwndHotStrGui_id +E0x20
	Gui, HotStrGui:Color, %HotStrGuiBackColor%
	Gui, HotStrGui:Font, c%HotStrGuiFontColor% s%HotStrGuiFontSize%, Segoe UI
	Gui, HotStrGui:Add,Text, x25 y3 HwndHotStrGui_Edit_Hwnd2, % msg[2]
	ControlGetPos, , , Text_W, Text_H, , ahk_id %HotStrGui_Edit_Hwnd2%
	HotStrGuiW := Text_W+25+35
	HotStrGuiH := Text_H+10
	Gui, HotStrGui:Add,Text, c%HotStrGuiFontColor_cover% x25 y3 HwndHotStrGui_Edit_Hwnd1, % msg[1]
	Gui, HotStrGui:Add,Text, x%HotStrGuiW% y3 HwndHotStrGui_Edit_Hwnd3, % msg[3]
	ControlGetPos, , , Text_W, Text_H, , ahk_id %HotStrGui_Edit_Hwnd3%
	HotStrGuiW += Text_W+35
	Gui, HotStrGui:Add,Text, x%HotStrGuiW% y3 HwndHotStrGui_Edit_Hwnd4, % msg[4]
	ControlGetPos, , , Text_W, Text_H, , ahk_id %HotStrGui_Edit_Hwnd4%
	HotStrGuiW += Text_W
	WinSet, Transparent, % HotStrShowTransparent/100*255, ahk_id %HotStrGui_id%
	WinSet, Region, 10-0 W%HotStrGuiW% H%HotStrGuiH% R5-5, ahk_id %HotStrGui_id%
	DetectHiddenWindows off
	return {w:HotStrGuiW, h:HotStrGuiH}
}

;获取输入光标位置，源代码来源：https://www.autoahk.com/archives/16443
GetCaret(Byref CaretX="", Byref CaretY="",Byref CaretW=0, Byref CaretH=0, Byref Flag=1) {
	static init
	CoordMode, Caret, Screen
	CaretX:=A_CaretX, CaretY:=A_CaretY,CaretW:=0,CaretH:=0, Flag:=1
	if (!CaretX or !CaretY){
		Try {
			if (!init)
				init:=DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "oleacc", "Ptr"), "AStr", "AccessibleObjectFromWindow", "Ptr")
			VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8
				, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
				, NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
			if DllCall(init, "Ptr",WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0 {
				Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
					, Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0)
					, ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
					, CaretX:=NumGet(x,0,"int"), CaretY:=NumGet(y,0,"int")
					, CaretW:=NumGet(w,0,"int"), CaretH:=NumGet(h,0,"int")
				ObjRelease(pacc)
			}
		}
	}
	If (CaretX=0 && CaretY=0){
		CoordMode, Mouse, Screen
		MouseGetPos, CaretX, CaretY
		Flag:=0
	}
	return {x:CaretX, y:CaretY,w:CaretW, h:CaretW, f:Flag}
}
