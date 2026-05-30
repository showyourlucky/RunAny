Menu_Tray_Show:
	if(GetKeyState("Ctrl") && GetKeyState("Shift")){
		Gosub,Menu_Config
		return
	}
	if(GetKeyState("Shift")){
		Gosub,Menu_Ini
		return
	}
	if(GetKeyState("Ctrl")){
		Open_Folder_Path(A_ScriptDir)
		return
	}
	Gosub,Menu_Show1
return
Menu_Show1:
	MENU_NO:=1
	iniFileShow:=iniPath
	Gosub,Menu_Show
return
Menu_Show2:
	MENU_NO:=2
	iniFileShow:=iniPath2
	Gosub,Menu_Show
return
Menu_NoGet_Show:
	MENU_NO:=1
	iniFileShow:=iniPath
	noGetZz:=true
	getZz:=""
	Gosub,Menu_Show
	noGetZz:=false
return
MenuShowTime:
	MenuShowTimeFlag:=true
	if(MenuShowFlag){
		SetTimer,MenuShowTime,Off
		Gosub,Menu_Show
	}
return
;══════════════════════════════════════════════════════════════════
;~;【——📺显示菜单——】
;══════════════════════════════════════════════════════════════════
Menu_Show:
	try{
		if(!MenuShowFlag && !MenuShowTimeFlag){
			SetTimer,MenuShowTime,10
			return
		}
		if(!extMenuHideFlag && !noGetZz)
			getZz:=Get_Zz()
		selectCheck:=Trim(getZz," `t`r`n")
		if(selectCheck=""){
			;#无选中内容
			;加载顺序：无Everything菜单 -> 无图标菜单 -> 有图标无路径识别菜单
			if(MenuIconFlag && MenuShowFlag){
				WinGet,pname,ProcessName,A
				WinGetClass,pclass,A
				ctrlgMenuItem:=Object()
				if(MenuObjWindowFlag && (MenuObjWindow[pclass])){
					ctrlgMenuName:=MenuObjWindow[pclass][1]
					;添加后缀公共菜单
					showPublicMenu:=Var_Read("ShowPublicMenu",1)
					publicMenuMaxNum:=MenuObjExt["public"].MaxIndex()
					if(showPublicMenu && publicMenuMaxNum>0){
						Loop {
							v:=MenuObjExt["public"][publicMenuMaxNum]
							vn:=RegExReplace(v,"S)^-+")
							Menu,%ctrlgMenuName%,Insert, 1&, %vn%, :%vn%
							Menu_Item_Icon(ctrlgMenuName,vn,TreeIconS[1],TreeIconS[2],v)
							publicMenuMaxNum--
						} Until % publicMenuMaxNum<1
						publicMaxNum:=MenuObjExt["public"].MaxIndex() + 1
						Menu,%ctrlgMenuName%,Insert, %publicMaxNum%&
					}
					Gosub,CtrlGQuickSwitch
					Menu_Show_Show(ctrlgMenuName,"")
					Loop,% ctrlgMenuItem.Count()
					{
						Menu,%ctrlgMenuName%,Delete,1&
					}
					;删除临时添加的菜单
					if(showPublicMenu && MenuObjExt["public"].MaxIndex()>0){
						Menu,%ctrlgMenuName%,Delete, %publicMaxNum%&
						for k,v in MenuObjExt["public"]
						{
							vn:=RegExReplace(v,"S)^-+")
							Menu,%ctrlgMenuName%,Delete,%vn%
						}
					}
				}else if(MenuObjWindowFlag && (MenuObjWindow[pname])){
					Menu_Show_Show(MenuObjWindow[pname][1],"")
				}else{
					if(pclass="#32770"){
						ctrlgMenuName:=menuDefaultRoot%MENU_NO%[1]
						Gosub,CtrlGQuickSwitch
					}
					Menu,% menuDefaultRoot%MENU_NO%[1],Show
					if(pclass="#32770"){
						Loop,% ctrlgMenuItem.Count()
						{
							Menu,%ctrlgMenuName%,Delete,1&
						}
					}
				}
			}else{
				try{
					Menu,% menuRoot%MENU_NO%[1],Show
				}catch e{
					TrayTip,RunAny菜单还没准备好，请稍后再试,% "错误信息：" e.extra "`n" e.message,10,3
				}
			}
			return
		}
		if(Candy_isFile){
			SplitPath, getZz,FileName,, FileExt  ; 获取文件扩展名.
			if(InStr(FileExist(getZz), "D")){  ; {目录}
				FileExt:="folder"
			}
			try{
				extMenuName:=MenuObjExt[FileExt]
				if(MENU_NO=1 && extMenuName && !extMenuHideFlag){
					if(MenuObjTree%MENU_NO%[extMenuName].MaxIndex()=1){
						itemContent:=MenuObjTree%MENU_NO%[extMenuName][1]
						OutsideMenuItem:=Get_Obj_Transform_Name(itemContent)
						Gosub,Menu_Run
					}else{
						if(!HideAddItem){
							MenuObjTreeMaxSepNum:=MenuObjTree%MENU_NO%[extMenuName].MaxIndex() + 1
							Menu,%extMenuName%,Insert,
							Menu,%extMenuName%,Insert, ,%RUNANY_SELF_MENU_ITEM3%,Menu_Add_File_Item
							Menu,%extMenuName%,Default,%RUNANY_SELF_MENU_ITEM3%
							Menu,%extMenuName%,Icon,%RUNANY_SELF_MENU_ITEM3%,SHELL32.dll,166,%MenuIconSize%
						}
						;添加后缀公共菜单
						publicMenuMaxNum:=MenuObjExt["public"].MaxIndex()
						if(publicMenuMaxNum>0){
							Loop {
								v:=MenuObjExt["public"][publicMenuMaxNum]
								vn:=RegExReplace(v,"S)^-+")
								Menu,%extMenuName%,Insert, 1&, %vn%, :%vn%
								Menu_Item_Icon(extMenuName,vn,TreeIconS[1],TreeIconS[2],v)
								publicMenuMaxNum--
							} Until % publicMenuMaxNum<1
							publicMaxNum:=MenuObjExt["public"].MaxIndex() + 1
							Menu,%extMenuName%,Insert, %publicMaxNum%&
						}
						;[显示自定义后缀菜单]
						Menu_Show_Show(extMenuName, FileName, Candy_isFile)
						;删除临时添加的菜单
						if(MenuObjExt["public"].MaxIndex()>0){
							Menu,%extMenuName%,Delete, %publicMaxNum%&
							for k,v in MenuObjExt["public"]
							{
								vn:=RegExReplace(v,"S)^-+")
								Menu,%extMenuName%,Delete,%vn%
							}
						}
						if(!HideAddItem){
							try Menu,%extMenuName%,Delete,%RUNANY_SELF_MENU_ITEM3%
							item_count := DllCall("GetMenuItemCount", "ptr", MenuGetHandle(extMenuName))
							try Menu,%extMenuName%,Delete, %item_count%&
						}
					}
				}else{
					if(!HideAddItem){
						Menu_Add_Del_Temp(1,MENU_NO,RUNANY_SELF_MENU_ITEM3,"Menu_Add_File_Item","SHELL32.dll","166")
						if(!MenuObjTree%MENU_NO%[M%MENU_NO% "   "]){
							;如果根目录下没有程序时
							Menu,% M%MENU_NO% "   ",Insert, ,%RUNANY_SELF_MENU_ITEM3%,Menu_Add_File_Item
							Menu,% M%MENU_NO% "   ",Icon,%RUNANY_SELF_MENU_ITEM3%,SHELL32.dll,166,%MenuIconSize%
						}
						try Menu,% menuFileRoot%MENU_NO%[1],Default,%RUNANY_SELF_MENU_ITEM3%
					}
					Menu_Show_Show(menuFileRoot%MENU_NO%[1], FileName, Candy_isFile)
					if(!HideAddItem){
						try Menu,% menuFileRoot%MENU_NO%[1],Delete, %RUNANY_SELF_MENU_ITEM3%
						Menu_Add_Del_Temp(0,MENU_NO,RUNANY_SELF_MENU_ITEM3)
					}
				}
			}catch e{
				menuName:=extMenuName!="" ? extMenuName : menuFileRoot%MENU_NO%[1]
				TrayTip,,% "[显示菜单]：" menuName "`n出错命令：" e.What
					. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
				Menu_Show_Show(menuFileRoot%MENU_NO%[1], FileName, Candy_isFile)
			}
			return
		}
		if(GetZzTransformVal)
			getZz:=Get_Transform_Val(getZz)
		if(MENU_NO=1){
			openFlag:=false
			;~;[多行内容一键直达正则匹配]
			For name, regex in OneKeyRegexMultilineList
			{
				if(name !="一键公式计算" && !OneKeyDisableList[name] && OneKeyRunList[name] && RegExMatch(getZz, regex)){
					Remote_Dyna_Run(OneKeyRunList[name], getZz)
					openFlag:=true
					continue
				}
			}
			if(openFlag)
				return
			calcFlag:=false
			notCalcFlag:=false
			calcResult:=""
			selectResult:=""
			Loop, parse, getZz, `n, `r
			{
				S_LoopField=%A_LoopField%
				if(S_LoopField=""){
					if(calcResult)
						calcResult.=A_LoopField "`n"
					if(selectResult)
						selectResult.=A_LoopField "`n"
					continue
				}
				;一键计算公式数字加减乘除
				calcRegex:=OneKeyRegexList["一键公式计算"]
				if(calcRegex!="" && !OneKeyDisableList["一键公式计算"] && RegExMatch(S_LoopField,calcRegex)){
					formula:=S_LoopField
					if(RegExMatch(S_LoopField,"S)=$")){
						StringTrimRight, formula, formula, 1
					}
					calc:=js_eval(formula)
					selectResult.=A_LoopField
					if(RegExMatch(S_LoopField,"S)=$")){
						calcFlag:=true
						selectResult.=calc
					}else{
						calcResult.=calc "`n"
					}
					selectResult.="`n"
					if(!notCalcFlag)
						openFlag:=true
					continue
				}else{
					notCalcFlag:=true
				}
				;一键直达动态正则匹配
				For name, regex in OneKeyRegexList
				{
					if(name !="一键公式计算" && !OneKeyDisableList[name] && regex!="" && OneKeyRunList[name] && RegExMatch(S_LoopField, regex)){
						if((name="一键打开目录" && !InStr(FileExist(S_LoopField), "D"))
							|| (name="一键打开文件" && (!FileExist(S_LoopField) || InStr(FileExist(S_LoopField), "D")))){
							continue
						}
						Remote_Dyna_Run(OneKeyRunList[name], S_LoopField)
						openFlag:=true
						continue
					}
				}
			}
			if(calcResult){
				StringTrimRight, calcResult, calcResult, 1
				MouseGetPos, MouseX, MouseY
				ToolTip,%calcResult%,% MouseX-25,% MouseY+5
				Clipboard:=calcResult
				SetTimer,RemoveToolTip,% (calcResult="?") ? 1000 : 3000
			}
			if(calcFlag && !notCalcFlag && selectResult){  ;选中内容多种类型时不输出公式结果
				StringTrimRight, selectResult, selectResult, 1
				Send_Str_Zz(selectResult)
			}
			if(openFlag)
				return
			;#绑定菜单1为一键搜索
			if(OneKeyMenu){
				Gosub,One_Search
				return
			}
		}
		showTheMenuName:=menuWebRoot%MENU_NO%[1]
		WinGet,pname,ProcessName,A
		;#选中文本弹出网址菜单#
		if(!MenuObjTextRootFlag%MENU_NO% && MenuObjText%MENU_NO%.MaxIndex()=1
			&& (!MenuObjWindowFlag || !MenuObjWindow[pname]
			|| (MenuObjWindowFlag && MenuObjWindow[pname].Length()=1 && MenuObjWindow[pname][1]=MenuObjText%MENU_NO%[1]))){
			;如果根目录没有%getZz%或%s且text菜单只有1个+没有软件专属菜单或与软件专属菜单相同，直接显示这个text菜单
			Menu_Show_Show(MenuObjText%MENU_NO%[1],getZz)
			return
		}
		if(MenuObjWindowFlag && MenuObjWindow[pname]){
			;添加自定义软件专属菜单
			publicMenuMaxNum:=MenuObjWindow[pname].MaxIndex()
			if(publicMenuMaxNum>0){
				Loop {
					menuObjTextStrs:=StrListJoin(",",MenuObjText%MENU_NO%)
					vn:=MenuObjWindow[pname][publicMenuMaxNum]
					v:=MenuObjTreeLevel[vn] . vn
					if vn in %menuObjTextStrs%
					{
						try Menu,% showTheMenuName,Delete,% vn "  "
					}
					Menu,% showTheMenuName,Insert, 1&, %vn%, :%vn%
					Menu_Item_Icon(showTheMenuName,vn,TreeIconS[1],TreeIconS[2],v)
					publicMenuMaxNum--
				} Until % publicMenuMaxNum<1
				publicMaxNum:=MenuObjWindow[pname].MaxIndex() + 1
				Menu,% showTheMenuName,Insert, %publicMaxNum%&
			}
		}
		Menu_Show_Show(showTheMenuName,getZz)
		;删除临时添加的菜单
		if(MenuObjWindowFlag && MenuObjWindow[pname]){
			Menu,% showTheMenuName,Delete, %publicMaxNum%&
			for k,v in MenuObjWindow[pname]
			{
				Menu,% showTheMenuName,Delete,%v%
			}
		}
	}catch e{
		TrayTip,,% "显示菜单出错：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
	}
return
;~;【显示菜单-热键】
Menu_Key_Show:
	getZz:=Get_Zz()
	try {
		Menu_Show_Show(menuTreekey[(A_ThisHotkey)],getZz)
	}catch{}
		return
Menu_All_Show:
	Menu_Show_Show(menuDefaultRoot%MENU_NO%[1],getZz)
return
Menu_Show_Show(menuName, itemName, Candy_isFile:=0){
	selectCheck:=Trim(itemName," `t`r`n")

	if(menuName!=menuDefaultRoot%MENU_NO%[1]){
		try Menu,%menuName%,Delete,%RUNANY_SELF_MENU_ITEM4%
	}

	if(!HideSelectZz && selectCheck!=""){
		itemName:=Trim(itemName," `t`r`n")
		if(StrLen(itemName)>ShowGetZzLen){
			itemName:=SubStr(itemName, 1, ShowGetZzLen) . "..."
			Select_itemName:= itemName
		}
		Menu,%menuName%,Insert, 1&,%itemName%,Menu_Show_Select_Clipboard
		Menu,%menuName%,ToggleCheck, 1&
		Menu,%menuName%,Insert, 2&
	}
	if(menuName!=menuDefaultRoot%MENU_NO%[1]){
		Menu,%menuName%,Insert, ,%RUNANY_SELF_MENU_ITEM4%,Menu_All_Show
		Menu,%menuName%,Icon,%RUNANY_SELF_MENU_ITEM4%,SHELL32.dll,40,%MenuIconSize%
	}
	;[显示菜单]
	Menu,%menuName%,Show
	if(!HideSelectZz && selectCheck!=""){
		Menu,%menuName%,Delete, 2&
		Menu,%menuName%,Delete,%itemName%
	}
	if(menuName!=menuDefaultRoot%MENU_NO%[1]){
		try Menu,%menuName%,Delete,%RUNANY_SELF_MENU_ITEM4%
	}
}
Menu_Show_Select_Clipboard:
	Clipboard:=Candy_Select
return
;[所有菜单(添加/删除)临时项]
Menu_Add_Del_Temp(addDel=1,TREE_NO=1,mName="",LabelName="",mIcon="",mIconNum=""){
	if(!mName)
		return
	For mn, vv in MenuObjTree%TREE_NO%
	{
		if(RegExMatch(mn,"S)[^\s]+\s{3}$")){
			if(addDel){
				Menu,%mn%,Insert, ,%mName%,%LabelName%
				Menu,%mn%,Icon,%mName%,%mIcon%,%mIconNum%,%MenuIconSize%
			}else{
				try Menu,%mn%,Delete,%mName%
			}
		}
	}
}
CtrlGQuickSwitch:
	ctrlgMenuItemNum:=0
	;---------------[ File Explorer ]----------------------------------------
	try{
		For $Exp in ComObjCreate("Shell.Application").Windows {
			try folder := $Exp.Document.Folder.Self.Path
			if(!folder || ctrlgMenuItem[folder]){
				Continue
			}
			ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, "shell32.dll", 5)
		}
		$Exp := ""
		if(ctrlgMenuItem.Count()>0){
			ctrlgMenuItem["-"]:=true
			Menu %ctrlgMenuName%, Insert,% ctrlgMenuItem.Count() "&"
		}
	}catch e{
		TrayTip,无法显示资源管理器当前目录：,% e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
	}
	;---------------[ Total Commander ]--------------------------------------
	tcIcon:=get_process_path("totalcmd.exe")
	tcIcon:=tcIcon ? tcIcon : get_process_path("TotalCMD64.exe")
	if(tcIcon){
		DetectHiddenWindows,On
		try{
			; Total Commander internal codes
			cm_CopySrcPathToClip  := 2029
			cm_CopyTrgPathToClip  := 2030
			ClipSaved := ClipboardAll
			Clipboard := ""
			SendMessage 1075, %cm_CopySrcPathToClip%, 0, , ahk_class TTOTAL_CMD
			folder:=RegExReplace(clipboard,"S)^\\\\(?!file)")
			If (ErrorLevel = 0 && folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, tcIcon)
			}
			SendMessage 1075, %cm_CopyTrgPathToClip%, 0, , ahk_class TTOTAL_CMD
			folder:=RegExReplace(clipboard,"S)^\\\\(?!file)")
			If (ErrorLevel = 0 && folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, tcIcon)
			}
			Clipboard := ClipSaved
			ClipSaved := ""
		}catch e{
			TrayTip,无法显示TC当前目录：,% e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
		}
		DetectHiddenWindows,Off
	}
	WinGet, doIcon, ProcessPath,ahk_exe dopus.exe
	if(doIcon){
		try{
			ControlGetText,folder, Edit1,ahk_class dopus.lister
			If (folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, doIcon)
			}
			try ControlGetText,folder, Edit2,ahk_class dopus.lister
			If (folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, doIcon)
			}
		}catch e{
			TrayTip,,% "无法获取DO当前目录，不建议最小化到托盘：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
		}
	}
	WinGet, xyIcon, ProcessPath,ahk_exe XYplorer.exe
	if(!xyIcon)
		WinGet, xyIcon, ProcessPath,ahk_exe XYplorerFree.exe
	if(xyIcon){
		try{
			SplitPath, xyIcon, xyName
			ControlGetText,folder,Edit18, ahk_exe %xyName%
			If (folder && !ctrlgMenuItem[folder]) {
				ctrlgMenuItemAdd(ctrlgMenuName, ctrlgMenuItem, ctrlgMenuItemNum, folder, xyIcon)
			}
		}catch e{
			TrayTip,,% "无法获取XYplorer当前目录，不建议最小化到托盘：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
		}
	}
	if(tcIcon || doIcon || xyIcon){
		ctrlgMenuItem["--"]:=true
		Menu %ctrlgMenuName%, Insert,% ctrlgMenuItem.Count() "&"
	}
return
ctrlgMenuItemAdd(ByRef ctrlgMenuName,ByRef ctrlgMenuItem,ByRef ctrlgMenuItemNum,ByRef folder,menuIcon,menuIconNum:=1){
	Menu %ctrlgMenuName%, Insert,% ctrlgMenuItem.Count() + 1 "&",% "&" ++ctrlgMenuItemNum A_Space folder, Choice
	Menu %ctrlgMenuName%, Icon,% "&" ctrlgMenuItemNum A_Space folder, %menuIcon%, %menuIconNum%, %MenuIconSize%
	ctrlgMenuItem[folder]:=true
}

Choice:
	$FolderPath := RegExReplace(A_ThisMenuItem,"^&\d+ ","")
	Gosub FeedExplorerOpenSave
return
;_____________________________________________________________________________
;
FeedExplorerOpenSave:
	;_____________________________________________________________________________
	;
	$WinID := WinExist("A")
	WinActivate, ahk_id %$WinID%
	if(RegExMatch($FolderPath,"S)^.:\\") || RegExMatch($FolderPath,"S)^\\\\file"))
		Gosub,FeedExplorerOpenSaveEdit1
	else
		Gosub,FeedExplorerOpenSaveEdit2
return
FeedExplorerOpenSaveEdit1:
	; Read the current text in the "File Name:" box (= $OldText)
	ControlGetText $OldText, Edit1
	ControlFocus Edit1
	; Go to Folder
	Loop, 5
	{
		ControlSetText, Edit1, %$FolderPath%		; set
		Sleep, 50
		ControlGetText, $CurControlText, Edit1		; check
		if ($CurControlText = $FolderPath)
			break
	}
	Sleep, 50
	ControlSend Edit1, {Enter}
	Sleep, 50
	; Insert original filename
	If !$OldText
		return
	Loop, 5
	{
		ControlSetText, Edit1, %$OldText%		; set
		Sleep, 50
		ControlGetText, $CurControlText, Edit1		; check
		if ($CurControlText = $OldText)
			break
	}
return
FeedExplorerOpenSaveEdit2:
	ControlFocus,Edit2
	ControlSend,Edit2,{f4}
	Sleep, 50
	ControlSetText,Edit2,%$FolderPath%
	Sleep, 50
	ControlSend,Edit2,{Enter}
return
;══════════════════════════════════════════════════════════════════
