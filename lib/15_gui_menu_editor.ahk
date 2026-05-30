;══════════════════════════════════════════════════════════════════
;~;[添加编辑新添加的菜单项]
Menu_Add_File_Item:
	if(iniFileShow=iniPath){
		iniFileVar:=iniVar1
		TREE_NO:=1
	}else{
		iniFileVar:=iniVar2
		TREE_NO:=2
	}
	;初始化要添加的内容
	itemGlobalWinKey:=itemAdminRun:=0
	hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=X_ThisMenuItem:=ItemText:=""
	itemPath:=Get_Item_Run_Path(getZz)
	SplitPath, itemPath, fName,, fExt, itemName
	Z_ThisMenu:=RTrim(A_ThisMenu)
	Z_ThisMenuItem:=A_ThisMenuItem
	if(Z_ThisMenuItem=RUNANY_SELF_MENU_ITEM3){
		X_ThisMenuItem:=Z_ThisMenuItem
		itemContent:=MenuObjTree%TREE_NO%[Z_ThisMenu][(MenuObjTree%TREE_NO%[Z_ThisMenu].MaxIndex())]
		Z_ThisMenuItem:=Get_Obj_Transform_Name(itemContent)
	}
	if(!Z_ThisMenu)
		return
	menuGuiFlag:=false
	menuGuiEditFlag:=false
	thisMenuItemStr:=X_ThisMenuItem=RUNANY_SELF_MENU_ITEM3 ? "" : "菜单项（" Z_ThisMenuItem "）的上面"
	thisMenuStr:=Z_ThisMenu=RunAnyZz . "File" . TREE_NO
		? "新增项会在『根目录』分类下（如果没有用“-”回归1级会添加在最末的菜单内）"
		: "新增项会在『" Z_ThisMenu "』分类下"
	Gosub,Menu_Item_Edit
return
;~;[保存新添加的菜单项]
SetSaveItem:
	Gui,SaveItem:Submit,NoHide
	saveText:=tabText:=itemGlobalKeyStr:=""
	menuFlag:=false		;判断是否定位到要插入的菜单位置
	endFlag:=false		;判断是否插入到末尾
	rootFlag:=true		;判断是否为根目录
	inputFlag:=false	;判断是否插入
	itemIndex:=0
	splitStr:=vitemName && vitemPath ? "|" : ""
	if(vitemGlobalKey){
		if(!vitemName){
			MsgBox, 48, ,设置热键后必须填写菜单项名
			return
		}
		if(!vitemPath && InStr(vitemName,"-")!=1){
			MsgBox, 48, ,应用设置热键后必须填写启动路径
			return
		}
		itemGlobalKeySave:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:=A_Tab . itemGlobalKeySave
		if(vitemGlobalKey!=itemGlobalKey || vitemGlobalWinKey!=itemGlobalWinKey){
			if(InStr(iniVar1,itemGlobalKeyStr "|") || InStr(iniVar2,itemGlobalKeyStr "|")){
				MsgBox, 48, ,该全局热键已经被其他菜单应用使用
				return
			}
		}
	}
	vitemName.=vitemAdminRun ? "[#]" : ""
	;保存热字符串
	if(vhotStrShow){
		if(vhotStrShow!=hotStrShow || vhotStrOption!=hotStrOption){
			vhotStrSave:=vhotStrOption ? vhotStrOption . vhotStrShow : ":*X:" vhotStrShow
			if(InStr(iniVar1,vhotStrSave "|") || InStr(iniVar2,vhotStrSave "|")){
				MsgBox, 48, ,该热字符串已经被其他菜单应用使用
				return
			}
		}
		vitemName.=vhotStrSave
	}
	if(vitemTrNum && vitemTrNum<100){
		vitemName.="_:" vitemTrNum
	}
	Gui,SaveItem:Destroy
	;[读取菜单内容插入新菜单项到RunAny.ini]
	Loop, parse, iniFileVar, `n, `r
	{
		itemContent=%A_LoopField%
		if(InStr(itemContent,"-")=1){
			rootFlag:=false
			treeContent:=Get_Tree_Name(itemContent,false)
			if(itemContent="-")
				rootFlag:=true
			if(treeContent=Z_ThisMenu){	;定位到要插入的菜单位置
				menuFlag:=true
				;计算出前面添加的制表符数量
				treeLevel:=StrLen(RegExReplace(itemContent,"S)(^-+).+","$1"))
				tabText:=Set_Tab(treeLevel)
			}
		}else if(rootFlag && (Z_ThisMenu=RunAnyZz . TREE_NO)){	;如果要添加到根目录
			menuFlag:=true
		}
		if(menuFlag){
			menuItem:=Get_Obj_Transform_Name(itemContent)
			if(menuItem=Z_ThisMenuItem){
				if(X_ThisMenuItem!=RUNANY_SELF_MENU_ITEM3){
					saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
					inputFlag:=true
				}else{
					endFind:=true
				}
				menuFlag:=false
			}else if (Z_ThisMenuItem="" && (X_ThisMenuItem="" || X_ThisMenuItem=RUNANY_SELF_MENU_ITEM3)){
				endFind:=true
				menuFlag:=false
			}
		}
		saveText.=A_LoopField . "`n"
		if(endFind && !inputFlag){
			saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
			endFind:=false
			inputFlag:=true
		}
	}
	if(saveText){
		if(!inputFlag){
			saveText.=tabText . vitemName . itemGlobalKeyStr . splitStr . vitemPath . "`n"
		}
		stringtrimright, saveText, saveText, 1
		FileDelete,%iniFileShow%
		FileAppend,%saveText%,%iniFileShow%
		Gosub,Menu_Reload
	}
return
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——🎫菜单配置Gui——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Menu_Edit_Gui:
	global TVFlag:=false
	global FailFlag:=false
	;[功能菜单初始化]
	treeRoot:=Object()
	global moveRoot:=Object()
	moveRoot[1]:="moveMenu" . both
	Menu,% moveRoot[1],add
	global moveLevel:=0
	;[树型菜单初始化]
	Gui, MenuEdit:Destroy
	Gui, MenuEdit:Default
	Gui, MenuEdit:+Resize
	Gui, MenuEdit:Font,s10, Microsoft YaHei
	Gui, MenuEdit:Add, TreeView,vRunAnyTV w600 r30 -Readonly AltSubmit Checked hwndHTV gTVClick ImageList%TreeImageListID%
	Gui, MenuEdit:Add, Progress,vMyProgress w450 cBlue
	GuiControl, MenuEdit:Hide, MyProgress
	GuiControl, MenuEdit:-Redraw, RunAnyTV
	Tv:=new treeview(HTV)
	;[读取菜单配置内容写入树形菜单]
	Loop, parse, iniFileVar, `n, `r, %A_Space%%A_Tab%
	{
		if(A_LoopField=""){
			continue
		}
		if(InStr(A_LoopField,"-")=1){
			;[生成节点树层级结构]
			treeLevel:=StrLen(RegExReplace(A_LoopField,"S)(^-+).+","$1"))
			if(RegExMatch(A_LoopField,"S)^-+[^-]+.*")){
				if(treeLevel=1){
					treeRoot.InsertAt(treeLevel,TV_Add(A_LoopField,,Set_Icon(TreeImageListID,A_LoopField,false)))
				}else{
					treeRoot.InsertAt(treeLevel,TV_Add(A_LoopField,treeRoot[treeLevel-1],Set_Icon(TreeImageListID,A_LoopField,false)))
				}
				TV_MoveMenu(A_LoopField)
			}else if(A_LoopField="-"){
				treeLevel:=0
				TV_Add(A_LoopField,,"Bold Icon8")
			}else{
				TV_Add(A_LoopField,treeRoot[treeLevel],"Bold Icon8")
			}
		}else if(A_LoopField="|" || A_LoopField="||"){
			TV_Add(A_LoopField,treeRoot[treeLevel],"Bold Icon8")
		}else if(InStr(A_LoopField,";")=1){
			hwnd:=TV_Add(A_LoopField,treeRoot[treeLevel],"Icon8")
			Tv.modify({hwnd:hwnd,fore:0x00A000})
		}else{
			FailFlag:=false
			itemIcon:=Set_Icon(TreeImageListID,A_LoopField,false)
			hwnd:=TV_Add(A_LoopField,treeRoot[treeLevel],itemIcon)
			if(itemIcon="Icon3" || FailFlag){
				Tv.modify({hwnd:hwnd,fore:0x999999})
			}
		}
	}
	GuiControl, MenuEdit:+Redraw, RunAnyTV
	TVMenu("TVMenu")
	TVMenu("GuiMenu")
	Gui, MenuEdit:Menu, GuiMenu
	Gui, MenuEdit:Show, , %RunAnyZz%菜单树管理【%both%】%RunAny_update_version% %RunAny_update_time%%AdminMode%(双击修改，右键操作)
	if(TVEditItem!=""){
		ItemEdit:=Get_Obj_Name(TVEditItem)
		ItemID = 0
		Loop
		{
			ItemID := TV_GetNext(ItemID, "Full")
			if not ItemID
				break
			TV_GetText(ItemText, ItemID)
			ItemName:=Get_Obj_Transform_Name(ItemText)
			if(ItemName=ItemEdit){
				TV_Modify(ItemID, "Expand Select")
				selIDTVEdit:=ItemID
				Gosub,TVEdit
				break
			}
		}
		TVEditItem=
	}
return
Menu_Edit1:
	both:=1
	iniFileWrite:=iniPath
	iniFileVar:=iniVar1
	Gosub,Menu_Edit_Gui
return
Menu_Edit2:
	both:=2
	iniFileWrite:=iniPath2
	iniFileVar:=iniVar2
	Gosub,Menu_Edit_Gui
return
#If WinActive(RunAnyZz "菜单树管理【" both "】")
	F5::
	PGDN::
		Gosub,TVDown
	return
	F6::
	PGUP::
		Gosub,TVUp
	return
	F3::Gosub,TVAdd
	F4::Gosub,TVAddTree
	F8::Gosub,TVImportFile
	F9::Gosub,TVImportFolder
	^s::Gosub,TVSave
	Esc::Gosub,MenuEditGuiClose
	F2::Gosub,TVEdit
	Tab::Send_Str_Zz(A_Tab)
#If
;~;[创建头部及右键功能菜单]
TVMenu(addMenu){
	flag:=(addMenu="GuiMenu") ? true : false
	Menu, %addMenu%, Add,% flag ? "保存" : "保存`tCtrl+S", TVSave
	Menu, %addMenu%, Icon,% flag ? "保存" : "保存`tCtrl+S", SHELL32.dll,194
	Menu, %addMenu%, Add,% flag ? "添加应用" : "添加应用`tF3", TVAdd
	Menu, %addMenu%, Icon,% flag ? "添加应用" : "添加应用`tF3", SHELL32.dll,3
	Menu, %addMenu%, Add,% flag ? "添加分类" : "添加分类`tF4", TVAddTree
	Menu, %addMenu%, Icon,% flag ? "添加分类" : "添加分类`tF4", SHELL32.dll,4
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", TVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "删除" : "删除`tDel", TVDel
	Menu, %addMenu%, Icon,% flag ? "删除" : "删除`tDel", SHELL32.dll,132
	if(!flag)
		Menu, %addMenu%, Add,注释, TVComments
	;~ Menu, %addMenu%, Add
	Menu, %addMenu%, Add,移动到..., :moveMenu%both%
	try Menu, %addMenu%, Icon,移动到...,% MoveIconS[1],% MoveIconS[2]
	Menu, %addMenu%, Add,% flag ? "向下" : "向下`t(F5/PgDn)", TVDown
	try Menu, %addMenu%, Icon,% flag ? "向下" : "向下`t(F5/PgDn)",% DownIconS[1],% DownIconS[2]
	Menu, %addMenu%, Add,% flag ? "向上" : "向上`t(F6/PgUp)", TVUp
	try Menu, %addMenu%, Icon,% flag ? "向上" : "向上`t(F6/PgUp)",% UpIconS[1],% UpIconS[2]
	Menu, %addMenu%, Add
	Menu, %addMenu%, Add,% flag ? "多选导入" : "多选导入`tF8", TVImportFile
	Menu, %addMenu%, Icon,% flag ? "多选导入" : "多选导入`tF8", SHELL32.dll,55
	Menu, %addMenu%, Add,% flag ? "批量导入" : "批量导入`tF9", TVImportFolder
	Menu, %addMenu%, Icon,% flag ? "批量导入" : "批量导入`tF9", SHELL32.dll,46
	Menu, %addMenu%, Add,桌面导入, Desktop_Import
	Menu, %addMenu%, Icon,桌面导入, SHELL32.dll,35
	Menu, %addMenu%, Add,网站图标, Website_Icon
	Menu, %addMenu%, Icon,网站图标, SHELL32.dll,14
}
TVClick:
	if (A_GuiEvent == "e"){
		;~;完成编辑时
		TV_GetText(selVar, A_EventInfo)
		TV_Modify(A_EventInfo, Set_Icon(TreeImageListID,selVar))
		if(addID && RegExMatch(selVar,"S)^-+[^-]+.*")){
			insertID:=TV_Add("",A_EventInfo)
			TV_Modify(A_EventInfo, "Bold Expand")
			TV_Modify(insertID, "Select Vis")
			SendMessage, 0x110E, 0, TV_GetSelection(), , ahk_id %HTV%
			addID:=
			Gosub,TV_MoveMenuClean
		}
		TVFlag:=true
	}else if (A_GuiEvent == "K"){
		if (A_EventInfo = 46)
			Gosub,TVDel
	}else if (A_GuiEvent == "DoubleClick"){
		TV_GetText(selVar, A_EventInfo)
		if(!RegExMatch(selVar,"S)^-+[^-]+.*"))
			Gosub,TVEdit
	}else if (A_GuiEvent == "Normal" && A_GuiControl = "RunAnyTV") {
		TV_Modify(A_EventInfo, "Select Vis")
		TV_CheckUncheckWalk(A_GuiEvent,A_EventInfo,A_GuiControl)
	}
return
TVAdd:
	Gui, MenuEdit:Default
	selID:=TV_Add("",TV_GetParent(TV_GetSelection()),TV_GetSelection())
	itemGlobalWinKey:=itemAdminRun:=0
	itemName:=itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	menuGuiFlag:=true
	menuGuiEditFlag:=false
	Gosub,Menu_Item_Edit
return
TVAddTree:
	Gui, MenuEdit:Default
	selID:=TV_Add("",TV_GetParent(TV_GetSelection()),TV_GetSelection())
	TV_GetText(parentTreeName, TV_GetParent(TV_GetSelection()))
	itemName:=RegExReplace(parentTreeName,"S)(^-+).*","$1") "-"
	itemGlobalWinKey:=0
	itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	menuGuiFlag:=true
	menuGuiEditFlag:=false
	ToolTip,% "菜单分类开头是" itemName "表示新建 " StrLen(itemName) "级目录",195,270
	SetTimer,RemoveToolTip,3500
	Gosub,Menu_Item_Edit
return
TVEdit:
	Gui,MenuEdit:Default
	selID:=TV_GetSelection()
	if(selIDTVEdit!="")
		selID:=selIDTVEdit
	TV_GetText(ItemText, selID)
	;分解已有菜单项到编辑框中
	Gosub,TVEdit_GuiVal
	menuGuiFlag:=true
	menuGuiEditFlag:=true
	selIDTVEdit:=""
	if(RunCtrlMenuItemFlag){
		Gui, MenuEdit:Destroy
		GuiControlSet("CtrlRun","vRunCtrlRunValue"
			,(itemName!="" && itemTrNum!="" && itemTrNum!=0) ? itemName "_:" itemTrNum : (itemName!="") ? itemName : itemPath)
		RunCtrlMenuItemFlag:=false
	}else{
		Gosub,Menu_Item_Edit
	}
return
TVEdit_GuiVal:
	itemGlobalWinKey:=itemTrNum:=setItemMode:=itemAdminRun:=0
	itemName:=itemPath:=hotStrOption:=hotStrShow:=itemGlobalHotKey:=itemGlobalKey:=getZz:=""
	if(ItemText="|" || ItemText=";|" || ItemText="||" || ItemText=";||"){
		itemPath:=ItemText
	}else if(InStr(ItemText,"|") || InStr(ItemText,"-")=1){
		menuDiy:=StrSplit(ItemText,"|",,2)
		itemName:=menuDiy[1]
		itemPath:=menuDiy[2]
		;[分割Tab获取应用自定义热键]
		menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
		menuKeys:=StrSplit(menuKeyStr,"`t")
		itemName:=menuKeys[1]
		if(InStr(menuKeyStr,"`t") && menuKeys[2]){
			itemGlobalHotKey:=menuKeys[2]
			itemGlobalKey:=menuKeys[2]
			if(InStr(menuKeys[2],"#")){
				itemGlobalWinKey:=1
				itemGlobalKey:=StrReplace(menuKeys[2], "#")
			}
		}
		;[设置透明度]
		if(RegExMatch(itemName,"S).*?_:(\d{1,2})$")){
			itemTrNum:=RegExReplace(itemName,"S).*?_:(\d{1,2})$","$1")
			itemName:=RegExReplace(itemName,"S)(.*)_:\d{1,2}$","$1")
		}
		;[设置热字符串启动方式]
		if(RegExMatch(itemName,"S):[*?a-zA-Z0-9]+?:[^:]*")){
			hotStr:=RegExReplace(itemName,"S)^[^:]*?(:[*?a-zA-Z0-9]+?:[^:]*)","$1")
			hotStrOption:=RegExReplace(hotstr,"S)^(:[*?a-zA-Z0-9]+?:)[^:]*","$1")
			hotStrShow:=RegExReplace(hotstr,"S)^:[^:]*?X[^:]*?:")
			itemName:=RegExReplace(itemName,"S)^([^:]*?):[*?a-zA-Z0-9]+?:[^:]*","$1")
		}
		;[设置管理员权限启动]
		if(RegExMatch(itemName,"S)\[#\]$")){
			itemAdminRun:=1
			itemName:=RegExReplace(itemName,"S)^(.*?)\[#\]$","$1")
		}
	}else{
		itemPath:=ItemText
	}
return
;~;【新增修改菜单项Gui】
Menu_Item_Edit:
	SaveLabel:=menuGuiFlag ? "SetSaveItemGui" : "SetSaveItem"
	PromptStr:=menuGuiFlag ? "需要" : "点击此处"
	setItemMode:=Get_Menu_Item_Mode(ItemText,true)
	If(setItemMode=2 || setItemMode=3){
		itemPath:=StrReplace(itemPath,"``t","`t")
		itemPath:=StrReplace(itemPath,"``n","`n")
	}
	if(InStr(itemName,"-")=1){
		treeYNum:=20
		itemNameText:="菜单分类"
	}else{
		treeYNum:=10
		itemNameText:="菜单项名"
	}
	SplitPath, itemPath, fName,, fExt, name_no_ext
	itemIconName:=itemName ? itemName : name_no_ext
	itemIconFile:=IconFolderList[menuItemIconFileName(itemIconName)]
	Gui,SaveItem:Destroy
	if(menuGuiFlag)
		Gui,SaveItem:+ownerMenuEdit
	Gui,SaveItem:Margin,20,20
	Gui,SaveItem:+Resize
	Gui,SaveItem:Font,,Microsoft YaHei
	Gui,SaveItem:Add, Text, xm+10 y+20 y20 w60, %itemNameText%：
	Gui,SaveItem:Add, Edit, x+5 yp-3 w350 vvitemName gEditItemPathChange, %itemName%
	Gui,SaveItem:Add, Checkbox,Checked%itemAdminRun% x+15 yp+3 vvitemAdminRun gEditItemPathChange,管理员运行
	Gui,SaveItem:Add, Picture, x+50 yp+3 w64 h-1 vvPictureIconAdd gSetItemIconPath, %itemIconFile%
	Gui,SaveItem:Add, Text,yp+8 w72 cGreen vvTextIconAdd gSetItemIconPath BackgroundTrans, 点击添加图标
	Gui,SaveItem:Add, Text,yp w72 cGreen vvTextIconDown gSetItemIconDown BackgroundTrans, 下载网站图标
	if(InStr(itemName,"-")!=1){
		Gui,SaveItem:Add, Text, xm+10 y+5 w60 vvTextHotStr, 热字符串：
		Gui,SaveItem:Font,,Consolas
		Gui,SaveItem:Add, Edit, x+5 yp-1 w60 vvhotStrOption gEditItemPathChange, % hotStrShow="" ? ":*X:" : hotStrOption
		Gui,SaveItem:Add, Edit, x+5 yp w90 vvhotStrShow gHotStrShowChange, %hotStrShow%
		Gui,SaveItem:Font,,Microsoft YaHei
		Gui,SaveItem:Add, Text, x+5 yp+3 w55 vvTextTransparent,透明度(`%)
		Gui,SaveItem:Add, Slider, x+5 yp ToolTip w135 r1 vvitemTrNum gEditItemPathChange,%itemTrNum%
	}
	Gui,SaveItem:Add,Text, xm+10 y+%treeYNum%+10 w100, 制 表 符 ：  Tab
	Gui,SaveItem:Add,Text, xm+10 y+%treeYNum% w60, 全局热键：
	Gui,SaveItem:Add,Hotkey,x+5 yp-3 w150 vvitemGlobalKey gEditItemPathChange,%itemGlobalKey%
	Gui,SaveItem:Add,Checkbox,Checked%itemGlobalWinKey% x+5 yp+3 vvitemGlobalWinKey gEditItemPathChange,Win
	Gui,SaveItem:Add,Text, x+5 yp cBlue w200 BackgroundTrans, %itemGlobalHotKey%
	Gui,SaveItem:Add,Text, xm+10 y+15 w100, 分 隔 符 ：  |
	Gui,SaveItem:Add,Text, xm+90 yp w355 cRed vvExtPrompt GSetSaveItemFullPath, 注意：RunAny不支持当前后缀无路径运行，%PromptStr%使用全路径
	Gui,SaveItem:Add, DropDownList,x+30 yp-5 w120 AltSubmit vvItemMode GChooseItemMode Choose%setItemMode%
		,启动路径|短语模式|模拟打字短语|热键映射|AHK热键映射|网址|文件夹|插件脚本函数

	Gui,SaveItem:Add,Text, xm+10 yp w60 vvSetFileSuffix,后缀菜单：
	Gui,SaveItem:Add,Button, xm+6 y+%treeYNum% w60 vvSetItemPath GSetItemPath,启动路径
	Gui,SaveItem:Font,,Consolas
	Gui,SaveItem:Add,Edit, x+10 yp WantTab w510 r5 vvitemPath gEditItemPathChange, %itemPath%
	Gui,SaveItem:Font,,Microsoft YaHei
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuPublic GSetMenuPublic,公共菜单
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuText GSetMenuText,文本菜单
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuFile GSetMenuFile,文件菜单
	Gui,SaveItem:Add,Button, xm+6 yp w60 vvSetMenuWindow GSetMenuWindow,软件菜单
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetFileRelativePath GSetFileRelativePath,相对路径
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetItemPathGetZz GSetItemPathGetZz,选中变量
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetItemPathClipboard GSetItemPathClipboard, 剪贴板
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetShortcut GSetShortcut,快捷目标
	Gui,SaveItem:Add,Button, xm+6 yp+27 w60 vvSetSendStrEncrypt GSetSendStrEncrypt,加密短语

	Gui,SaveItem:Add,Button,Default xm+220 y+15 w75 vvSaveItemSaveBtn G%SaveLabel%,保存
	Gui,SaveItem:Add,Button,x+20 w75 vvSaveItemCancelBtn GSetCancel,取消
	Gui,SaveItem:Add,Text, xm+10 w590 cBlue vvExplain, %thisMenuStr% %thisMenuItemStr%
	Gui,SaveItem:Font,,Consolas
	Gui,SaveItem:Add,StatusBar, xm+10 w590 vvStatusBar,

	Gui,SaveItem:Show,H385,新增修改菜单项 - %RunAnyZz% - 支持拖放应用 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	GuiControl,SaveItem:Hide, vExtPrompt
	if(fExt!="lnk")
		GuiControl,SaveItem:Hide, vSetShortcut
	if(itemIconFile || setItemMode!=6){
		GuiControl,SaveItem:Hide, vTextIconDown
		if(itemIconFile){
			GuiControl,SaveItem:Hide, vTextIconAdd
		}
	}
	if(hotStrShow=""){
		GuiControl,SaveItem:Hide, vhotStrOption
		GuiControl,SaveItem:Move, vhotStrShow, x95 y52
	}
	itemNameText:=thisMenuStr:=thisMenuItemStr:=""
	Gosub,EditItemPathChange
return
;[保存新增修改菜单项内容]
SetSaveItemGui:
	Gui,SaveItem:Submit,NoHide
	itemGlobalKeyStr:=""
	if(vitemGlobalKey){
		if(!vitemName){
			MsgBox, 48, ,设置热键后必须填写菜单项名
			return
		}
		if(!vitemPath && InStr(vitemName,"-")!=1){
			MsgBox, 48, ,应用设置热键后必须填写启动路径
			return
		}
		itemGlobalKeySave:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:=A_Tab . itemGlobalKeySave
		if(vitemGlobalKey!=itemGlobalKey || vitemGlobalWinKey!=itemGlobalWinKey){
			if(InStr(iniVar1,itemGlobalKeyStr "|") || InStr(iniVar2,itemGlobalKeyStr "|")){
				MsgBox, 48, ,该全局热键已经被其他菜单应用使用
				return
			}
		}
	}
	vitemName.=vitemAdminRun ? "[#]" : ""
	;保存热字符串
	if(vhotStrShow && vhotStrOption){
		vhotStrSave:=vhotStrOption ? vhotStrOption . vhotStrShow : ":*X:" vhotStrShow
		if(InStr(iniVar1,vhotStrSave "|") || InStr(iniVar2,vhotStrSave "|")){
			MsgBox, 48, ,该热字符串已经被其他菜单应用使用
			return
		}
		vitemName.=vhotStrSave
	}
	if(vitemTrNum && vitemTrNum<100){
		vitemName.="_:" vitemTrNum
	}
	splitStr:=vitemName && vitemPath ? "|" : ""
	vitemPath:=StrReplace(vitemPath,"`t","``t")
	vitemPath:=StrReplace(vitemPath,"`n","``n")
	saveText:=vitemName . itemGlobalKeyStr . splitStr . vitemPath
	Gui,SaveItem:Destroy
	Gui,MenuEdit:Default
	TV_Modify(selID, , saveText)
	TV_Modify(selID, "Select Vis")
	TV_Modify(selID, Set_Icon(TreeImageListID,saveText))
	if(ItemText!=saveText)
		TVFlag:=true
	if(!menuGuiEditFlag && selID && RegExMatch(saveText,"S)^-+[^-]+.*")){
		insertID:=TV_Add("",selID)
		TV_Modify(selID, "Bold Expand")
		TV_Modify(insertID, "Select Vis")
		SendMessage, 0x110E, 0, TV_GetSelection(), , ahk_id %HTV%
		addID:=
		Gosub,TV_MoveMenuClean
	}
return
#If WinActive("新增修改菜单项 - " RunAnyZz " - 支持拖放应用")
	~^v::
		if(InStr(Clipboard,"|")){
			Sleep,200
			ItemText:=Trim(Clipboard)
			MsgBox,36,,是否需要把RunAny菜单项值，自动添加到各个编辑框中？
			IfMsgBox Yes
			{
				Gosub,TVEdit_GuiVal
				GuiControlSet("SaveItem","vitemGlobalKey",itemGlobalKey)
				GuiControlSet("SaveItem","vitemPath",itemPath)
				Gui,SaveItem:Submit, NoHide
				if(itemGlobalKey!="" && vitemGlobalKey=""){
					MsgBox, 48,,% itemGlobalHotKey "`n无法设置到全局热键的编辑框里，变为保存在菜单项名中`n"
						. "建议有特殊热键的菜单项，后续修改直接打开RunAny.ini来编辑生效"
					GuiControlSet("SaveItem","vitemName",menuDiy[1])
					GuiControlSet("SaveItem","vitemAdminRun")
					GuiControlSet("SaveItem","vhotStrOption")
					GuiControlSet("SaveItem","vhotStrShow")
					GuiControlSet("SaveItem","vitemTrNum")
					GuiControlSet("SaveItem","vitemGlobalWinKey")
					Sleep,200
					GuiControlHide("SaveItem","vitemAdminRun","vhotStrOption","vhotStrShow","vitemTrNum","vitemGlobalKey","vitemGlobalWinKey")
				}else{
					GuiControlSet("SaveItem","vitemName",itemName)
					GuiControlSet("SaveItem","vitemAdminRun",itemAdminRun)
					GuiControlSet("SaveItem","vhotStrOption",hotStrOption)
					GuiControlSet("SaveItem","vhotStrShow",hotStrShow)
					GuiControlSet("SaveItem","vitemTrNum",itemTrNum)
					GuiControlSet("SaveItem","vitemGlobalWinKey",itemGlobalWinKey)
				}
			}
		}
	return
#If
EditItemPathChange:
	Gui,SaveItem:Submit, NoHide
	if(InStr(vitemName,"-")=1){
		GuiControlHide("SaveItem","vItemMode","vSetItemPath","vSetFileRelativePath","vSetItemPathGetZz","vSetItemPathClipboard","vSetShortcut","vitemAdminRun")
		GuiControlShow("SaveItem","vSetFileSuffix","vSetMenuPublic","vSetMenuText","vSetMenuFile","vSetMenuWindow")
		GuiControl,SaveItem:Move, vSetFileSuffix, y+160
		GuiControl,SaveItem:Move, vSetMenuPublic, y+180
		GuiControl,SaveItem:Move, vSetMenuText, y+210
		GuiControl,SaveItem:Move, vSetMenuFile, y+240
		GuiControl,SaveItem:Move, vSetMenuWindow, y+270
	}else{
		GuiControlHide("SaveItem","vSetFileSuffix","vSetMenuPublic","vSetMenuText","vSetMenuFile","vSetMenuWindow")
		GuiControlShow("SaveItem","vItemMode","vSetItemPath","vSetFileRelativePath","vSetItemPathGetZz","vSetItemPathClipboard")
		filePath:=!vitemPath && vitemName ? vitemName : vitemPath
		itemPathMode:=StrReplace(filePath,"%getZz%",Chr(3))
		itemPathMode:=Get_Transform_Val(itemPathMode)
		getItemMode:=Get_Menu_Item_Mode(itemPathMode)
		if(filePath){
			if(getItemMode!=1 || EvDemandSearch || Check_Obj_Ext(filePath)){
				GuiControl, SaveItem:Hide, vExtPrompt
			}else{
				GuiControl, SaveItem:Show, vExtPrompt
			}
			filePath:=Get_Obj_Path_Transform(filePath)
			fileValue:=RegExReplace(filePath,"iS)(.*?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数
			SplitPath, fileValue, fName,, fExt  ; 获取扩展名
			if fExt in exe,lnk,bat,cmd,vbs,ps1,ahk
			{
				GuiControlShow("SaveItem","vitemAdminRun","vTextTransparent","vitemTrNum")
				if(fExt="lnk")
					GuiControlShow("SaveItem","vSetShortcut")
			}else{
				GuiControlHide("SaveItem","vitemAdminRun","vTextTransparent","vitemTrNum")
			}
		}
		GuiControl, SaveItem:Choose, vItemMode,% getItemMode=60 ? 1 : getItemMode
	}
	if(SendStrDcKey!="" && encryptFlag && (getItemMode=2 || getItemMode=3)){
		GuiControlShow("SaveItem","vSetSendStrEncrypt")
	}else{
		GuiControlHide("SaveItem","vSetSendStrEncrypt")
	}
	; 状态栏直观实时显示菜单项编辑结果
	itemGlobalKeyStr:=""
	if(vitemGlobalKey){
		itemGlobalKeySave:=vitemGlobalWinKey ? "#" . vitemGlobalKey : vitemGlobalKey
		itemGlobalKeyStr:="　　" . itemGlobalKeySave
	}
	vitemName.=vitemAdminRun ? "[#]" : ""
	if(vhotStrShow && vhotStrOption){
		vitemName.=vhotStrOption ? vhotStrOption . vhotStrShow : ":*X:" vhotStrShow
	}
	if(vitemTrNum && vitemTrNum<100){
		vitemName.="_:" vitemTrNum
	}
	splitStr:=vitemName && vitemPath ? "|" : ""
	vitemPath:=StrReplace(vitemPath,"`t","``t")
	vitemPath:=StrReplace(vitemPath,"`n","``n")
	SB_SetText("　　" vitemName . itemAdminRunStr . itemGlobalKeyStr . splitStr . vitemPath)
return
HotStrShowChange:
	Gui,SaveItem:Submit, NoHide
	if(vhotStrShow){
		GuiControl,SaveItem:Show, vhotStrOption
		GuiControl,SaveItem:Move, vhotStrShow, x160 y52
	}
	Gosub,EditItemPathChange
return
;[启动模式变换]
ChooseItemMode:
	Gui,SaveItem:Submit, NoHide
	itemPathMode:=StrReplace(vitemPath,"%getZz%",Chr(3))
	itemPathMode:=Get_Transform_Val(itemPathMode)
	getItemMode:=Get_Menu_Item_Mode(itemPathMode)
	if((vItemMode=1 || vItemMode!=2) && getItemMode=2){	;清除短语
		StringTrimRight, vitemPath, vitemPath, 1
	}else if((vItemMode=1 || vItemMode!=3) && getItemMode=3){		;清除打字短语
		StringTrimRight, vitemPath, vitemPath, 2
	}else if((vItemMode=1 || vItemMode!=4) && getItemMode=4){		;清除热键映射
		StringTrimRight, vitemPath, vitemPath, 2
	}else if((vItemMode=1 || vItemMode!=5) && getItemMode=5){		;清除AHK热键映射
		StringTrimRight, vitemPath, vitemPath, 3
	}
	if(InStr(vitemName,"-")=1)
		return
	if(vItemMode=2 && getItemMode!=2){
		vitemPath.=";"
		GuiControl, SaveItem:,vExplain,此模式可把保存的短语 输出到任意位置
	}else if(vItemMode=3 && getItemMode!=3){
		vitemPath.=";;"
		GuiControl, SaveItem:,vExplain,此模式除输出短语外 ``n和``r转换为Enter键击  ``t转换为Tab键击  ``b转换为Backspace键击
	}else if(vItemMode=4 && getItemMode!=4){
		vitemPath.="::"
		GuiControl, SaveItem:,vExplain,此模式可以模拟人手发送键击 把全局热键映射成其他热键 ^代表Ctrl键 !代表Alt键 #代表Win键 +代表Shift键
	}else if(vItemMode=5 && getItemMode!=5){
		vitemPath.=":::"
		GuiControl, SaveItem:,vExplain,此模式可以映射发送任意已运行AHK脚本中的热键键击
	}
	GuiControl, SaveItem:, vitemPath, %vitemPath%
	Gosub,EditItemPathChange
return
SetMenuPublic:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vExplain,有public的菜单分类在任意不同情况菜单中都会显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% public
	Gosub,EditItemPathChange
return
SetMenuFile:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vExplain,有file的菜单分类会在选中文件内容的时候显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% file
	Gosub,EditItemPathChange
return
SetMenuWindow:
	webUrl:=rule_check_network(RunAnyGiteePages) ? RunAnyGiteePages : RunAnyGithubPages
	Run,% webUrl "/RunAny/#/CONFIG?id=软件专属菜单"
return
SetMenuText:
	Gui,SaveItem:Submit, NoHide
	GuiControl, SaveItem:, vExplain,有text的菜单分类会在选中文本内容的时候显示
	GuiControl, SaveItem:, vitemPath, %vitemPath% text
	Gosub,EditItemPathChange
return
SetItemPath:
	FileSelectFile, fileSelPath, , , 启动文件路径
	if(fileSelPath){
		GuiControl, SaveItem:, vitemPath, % Get_Item_Run_Path(fileSelPath)
		Gosub,EditItemPathChange
	}
return
SetItemPathGetZz:
	GuiControl, SaveItem:, vExplain,`%getZz`%在运行时会转换为你鼠标选中的文本内容
	GuiControl, SaveItem:Focus, vitemPath
	Send_Str_Zz("%getZz%")
return
SetItemPathClipboard:
	GuiControl, SaveItem:, vExplain,`%Clipboard`%在运行时会转换为剪贴板里的文本内容
	GuiControl, SaveItem:Focus, vitemPath
	Send_Str_Zz("%Clipboard%")
return
SetSendStrEncrypt:
	Gui,SaveItem:Submit, NoHide
	if(vItemMode=2){
		if(RegExMatch(vitemPath,"S).+\$;$")){
			vitemPath:=RegExReplace(vitemPath,"\$;$")
			GuiControl, SaveItem:, vitemPath, % SendStrDecrypt(vitemPath) ";"
			return
		}
		vitemPath:=RegExReplace(vitemPath,";$")
		GuiControl, SaveItem:, vitemPath, % SendStrEncrypt(vitemPath) "$;"
	}else if(vItemMode=3){
		if(RegExMatch(vitemPath,"S).+\$;;$")){
			vitemPath:=RegExReplace(vitemPath,"\$;;$")
			GuiControl, SaveItem:, vitemPath, % SendStrDecrypt(vitemPath) ";;"
			return
		}
		vitemPath:=RegExReplace(vitemPath,";;$")
		GuiControl, SaveItem:, vitemPath, % SendStrEncrypt(vitemPath) "$;;"
	}
return
;[全路径转换为RunAnyCtrl的相对路径]
SetFileRelativePath:
	Gui,SaveItem:Submit, NoHide
	if(InStr(vitemPath,"`%A_ScriptDir`%\")=1){
		funcResult:=RegExReplace(vitemPath,"S)^`%A_ScriptDir`%\\")
		funcResult:=funcPath2AbsoluteZz(funcResult,A_ScriptFullPath)
		headPath=
	}else{
		headPath=`%A_ScriptDir`%\
		funcResult:=funcPath2RelativeZz(vitemPath,A_ScriptFullPath)
	}
	if(funcResult=-1){
		GuiControl, SaveItem:,vExplain,路径有误
		return
	}
	if(funcResult=-2){
		GuiControl, SaveItem:,vExplain,与RunAny不在同一磁盘，不能转换为相对路径
		return
	}
	if(funcResult){
		GuiControl, SaveItem:, vitemPath, %headPath%%funcResult%
		Gosub,EditItemPathChange
	}
return
SetItemIconPath:
	Gui,SaveItem:Submit, NoHide
	if(!vitemName && !vitemPath){
		MsgBox, 48, ,菜单项名和启动路径不能同时为空时设置图标
		return
	}
	FileSelectFile, iconSelPath, , , 图标文件路径, (%IconFileSuffix%)
	if(iconSelPath){
		SplitPath, vitemPath, fName,, fExt, name_no_ext
		itemIconName:=vitemName ? vitemName : name_no_ext
		itemIconName:=menuItemIconFileName(itemIconName)
		if(FileExist(itemIconFile) && iconSelPath!=itemIconFile){
			CreateDir(A_Temp "\" RunAnyZz "\" RunIcon)
			SplitPath, itemIconFile, iName
			FileMove, %itemIconFile%, %A_Temp%\%RunAnyZz%\RunIcon\%iName%,1
		}
		if(InStr(vitemName,"-")=1){
			iconCopyDir:=MenuIconDir
		}else if(RegExMatch(vitemPath,"iS)([\w-]+://?|www[.]).*")){
			iconCopyDir:=WebIconDir
		}else{
			iconCopyDir:=ExeIconDir
		}
		SplitPath, iconSelPath,,, iExt
		FileCopy, %iconSelPath%, %iconCopyDir%\%itemIconName%.%iExt%, 1
		Gosub,SetSaveItemGui
	}
return
SetItemIconDown:
	try {
		Gui,SaveItem:Submit, NoHide
		if(!vitemName && !vitemPath){
			MsgBox, 48, ,菜单项名和启动路径不能同时为空时设置图标
			return
		}
		if(RegExMatch(vitemPath,"iS)^([\w-]+://?|www[.]).*")){
			website:=RegExReplace(vitemPath,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=WebIconDir "\" menuItemIconFileName(vitemName) ".ico"
			InputBox, webSiteInput, 下载网站图标,确认或修改下面的默认地址并下载图标ico文件`n`n如果下载错误或界面变空要重新下载图标`n`n
			(
请打开【修改菜单】界面选中后点“网站图标”按钮,,,,,,,,http://%website%/favicon.ico
			)
			if !ErrorLevel
			{
				URLDownloadToFile(webSiteInput,webIcon)
				MsgBox,65,,图标下载成功，是否要重新打开RunAny生效？
				IfMsgBox Ok
					Gosub,Menu_Reload
			}
		}
	} catch e {
		WebsiteIconError(webSiteInput)
	}
return
SetSaveItemFullPath:
	if(getZz && !menuGuiFlag){
		GuiControl, SaveItem:, vitemPath, %getZz%
		GuiControl, SaveItem:Hide, vPrompt
	}
return
SetShortcut:
	Gui,SaveItem:Submit, NoHide
	filePath:=!vitemPath && vitemName ? vitemName : vitemPath
	filePath:=Get_Obj_Path(filePath)	;补全路径
	if(!filePath)	;如果没补全，还原原选中文件地址
		filePath:=getZz
	SplitPath, filePath, ,, fExt  ; 获取扩展名
	if(filePath && fExt="lnk"){
		FileGetShortcut, %filePath%, exePath, OutDir, exeArgs
		exeArgs:=exeArgs ? A_Space exeArgs : ""
		if(exePath){
			GuiControl, SaveItem:, vitemPath, %exePath%%exeArgs%
		}
	}else{
		Gosub,SetSaveItemFullPath
	}
	Gosub,EditItemPathChange
return
TVDown:
	TV_Move(true)
return
TVUp:
	TV_Move(false)
return
TVDel:
	Gui, MenuEdit:Default
	selText:=""
	DelListID:=Object()
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		selText.=ItemText "`n"
		DelListID.Push(CheckID)
	}
	if(!selText){
		MsgBox,64,,请最少勾选一项
		return
	}
	if(RegExMatch(selText,"S)^-+[^-]+.*"))
		MsgBox,51,请确认(Esc取消),确定删除勾中的【以及它下面的所有子项目】？(注意)`n%selText%
	else
		MsgBox,51,请确认(Esc取消),确定删除勾中的？`n%selText%
	IfMsgBox Yes
	{
		Loop,% DelListID.MaxIndex()
		{
			TV_Delete(DelListID[A_Index])
		}
		TVFlag:=true
		Gosub,TV_MoveMenuClean
	}
return
TVComments:
	Gui, MenuEdit:Default
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		if(InStr(ItemText,";")=1){
			StringTrimLeft, ItemText, ItemText, 1
			Tv.modify({hwnd:CheckID,fore:0x000000})
		}else{
			ItemText:=";" ItemText
			Tv.modify({hwnd:CheckID,fore:0x00A000})
		}
		TV_Modify(CheckID, ,ItemText)
	}
return
TVSave:
	MsgBox, 4131, 菜单树保存, 是：保存后重启生效`n否：保存重启后继续修改`n取消：取消保存
	IfMsgBox Yes
	{
		Gosub,Menu_Save
		Gosub,Menu_Reload
	}
	IfMsgBox No
	{
		RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, ReloadGosub, Menu_Edit%both%
		Gosub,Menu_Save
		Gosub,Menu_Reload
	}
return
Menu_Save:
	ItemID = 0
	tabText:=""
	saveText:=""
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		;~;根据保存菜单树生成菜单ini文件
		treeLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).+","$1"))
		if(RegExMatch(ItemText,"S)^-+[^-]+.*")){
			saveText.=Set_Tab(treeLevel-1) . ItemText . "`n"
			tabText:=Set_Tab(treeLevel)
		}else if(ItemText="-"){
			tabText:=""
			saveText.=tabText . ItemText . "`n"
		}else if(RegExMatch(ItemText,"S)^-+")){
			tabText:=Set_Tab(treeLevel)
			saveText.=tabText . ItemText . "`n"
		}else{
			saveText.=tabText . ItemText . "`n"
		}
	}
	if(saveText){
		FileDelete,%iniFileWrite%
		FileAppend,%saveText%,%iniFileWrite%
	}
return
;[制表符设置]
Set_Tab(tabNum){
	tabText:=""
	Loop,%tabNum%
	{
		tabText.=A_Tab
	}
	return tabText
}
;~;[多选导入]
TVImportFile:
	Gui, MenuEdit:Default
	selID:=TV_GetSelection()
	TV_GetText(ItemText, selID)
	if(InStr(ItemText,"-")=1){
		parentID:=selID
		TV_Modify(selID, "Bold Expand")
	}else{
		parentID:=TV_GetParent(selID)
	}
	FileSelectFile, exeName, M35, , 选择多项要导入的EXE(快捷方式), (*.exe;*.lnk)
	Loop,parse,exeName,`n
	{
		if(A_Index=1){
			lnkPath:=A_LoopField
		}else{
			I_LoopField:=A_LoopField
			exePath:=lnkPath "\" I_LoopField
			if Ext_Check(I_LoopField,StrLen(I_LoopField),".lnk"){
				FileGetShortcut,%lnkPath%\%I_LoopField%,exePath
				if Ext_Check(exePath,StrLen(exePath),".exe")
					SplitPath,exePath,I_LoopField
			}
			fileID:=TV_Add(I_LoopField,parentID,Set_Icon(TreeImageListID,exePath))
			TVFlag:=true
		}
	}
return
;~;[批量导入]
TVImportFolder:
	Gui, MenuEdit:Default
	selID:=TV_GetSelection()
	TV_GetText(ItemText, selID)
	if(InStr(ItemText,"-")=1){
		parentID:=selID
		TV_Modify(selID, "Bold Expand")
	}else{
		parentID:=TV_GetParent(selID)
	}
	FileSelectFolder, folderName, , 0
	if(folderName){
		MsgBox,33,导入文件夹所有exe和lnk,确定导入  %folderName%  及子文件夹下所有程序和快捷方式吗？
		IfMsgBox Ok
		{
			Loop,%folderName%\*.lnk,0,1
			{
				lnkID:=TV_Add(A_LoopFileName,parentID,Set_Icon(TreeImageListID,A_LoopFileFullPath))
			}
			Loop,%folderName%\*.exe,0,1
			{
				folderID:=TV_Add(A_LoopFileName,parentID,Set_Icon(TreeImageListID,A_LoopFileFullPath))
			}
			TVFlag:=true
		}
	}
return
Website_Icon:
	selText:=""
	selTextList:=Object()
	CheckID = 0
	Loop
	{
		CheckID := TV_GetNext(CheckID, "Checked")
		if not CheckID
			break
		TV_GetText(ItemText, CheckID)
		selText.=ItemText "`n"
		selTextList.Push(ItemText)
	}
	if(selTextList.MaxIndex()=1){
		try {
			diyText:=StrSplit(ItemText,"|",,2)
			webText:=(diyText[2]) ? diyText[2] : diyText[1]
			if(RegExMatch(webText,"iS)^([\w-]+://?|www[.]).*")){
				website:=RegExReplace(webText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
				webIcon:=WebIconDir "\" menuItemIconFileName(diyText[1]) ".ico"
				InputBox, webSiteInput, 重新下载网站图标,可以重新下载图标并匹配网址`n`n请修改以下网址再点击下载,,,,,,,,http://%website%/favicon.ico
				if !ErrorLevel
				{
					URLDownloadToFile(webSiteInput,webIcon)
					MsgBox,65,,图标下载成功，是否要重新打开RunAny生效？
					IfMsgBox Ok
						Gosub,Menu_Reload
				}
			}
		} catch e {
			WebsiteIconError(webSiteInput)
		}
		return
	}
	if(selText){
		MsgBox,33,下载网站图标,确定下载以下选中的网站图标：`n(下载的图标在%WebIconDir%)`n%selText%
		IfMsgBox Ok
		{
			Loop,% selTextList.MaxIndex()
			{
				GuiControl, Show, MyProgress
				ItemText:=selTextList[A_Index]
				Gosub,Website_Icon_Down
			}
			if(errDown!="")
				WebsiteIconError(errDown)
			GuiControl, Hide, MyProgress
			MsgBox,65,,图标下载完成，是否要重新打开RunAny生效？
			IfMsgBox Ok
				Gosub,Menu_Reload
		}
		return
	}
	MsgBox,33,下载网站图标,确定下载RunAny内所有网站图标吗？`n(下载的图标在%WebIconDir%)
	IfMsgBox Ok
	{
		errDown:=""
		ItemID = 0
		Loop
		{
			ItemID := TV_GetNext(ItemID, "Full")
			if not ItemID
				break
			TV_GetText(ItemText, ItemID)
			if(InStr(ItemText,";")=1 || ItemText="")
				continue
			GuiControl, Show, MyProgress
			Gosub,Website_Icon_Down
		}
		if(errDown!="")
			WebsiteIconError(errDown)
		GuiControl, Hide, MyProgress
		MsgBox,65,,图标下载完成，是否要重新打开RunAny生效？
		IfMsgBox Ok
			Gosub,Menu_Reload
	}
return
Website_Icon_Down:
	try {
		diyText:=StrSplit(ItemText,"|",,2)
		webText:=(diyText[2]) ? diyText[2] : diyText[1]
		if(RegExMatch(webText,"iS)^([\w-]+://?|www[.]).*")){
			website:=RegExReplace(webText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=WebIconDir "\" menuItemIconFileName(diyText[1]) ".ico"
			URLDownloadToFile("http://" website "/favicon.ico",webIcon)
			GuiControl,, MyProgress, +10
		}
	} catch e {
		errDown.="http://" website "/favicon.ico`n"
	}
return
WebsiteIconError(errDown){
	MsgBox,64,,以下网站图标无法下载，请单选后点[网站图标]按钮重新指定网址下载，`n或手动添加对应图标到[%WebIconDir%]`n`n%errDown%
}
;~;[上下移动项目]
TV_Move(moveMode = true){
	Gui, MenuEdit:Default
	selID:=TV_GetSelection()
	moveID:=moveMode ? TV_GetNext(selID) : TV_GetPrev(selID)	; 向下：moveID为下个节点ID，向上：上个节点ID
	if(moveID!=0){
		TV_GetText(selVar, selID)
		TV_GetText(moveVar, moveID)
		selTreeFlag:=RegExMatch(selVar,"S)^-+[^-]+.*")
		moveTreeFlag:=RegExMatch(moveVar,"S)^-+[^-]+.*")
		selNextID:=moveMode ? moveID : TV_GetNext(selID)	; 向下：moveID即为树末节点，向上：选中树的下个同级节点为树末节点
		moveNextID:=!moveMode ? selID : TV_GetNext(moveID)	; 向上：selID即为树末节点，向下：目标树的下个同级节点为树末节点
		if((selTreeFlag || moveTreeFlag) && selNextID && moveNextID){
			DelListID:=Object()		; 需要删除的旧节点
			selTextList:=Object()	; 选中树的所有节点名列表
			moveTextList:=Object()	; 目标树的所有节点名列表
			ItemID:=selID
			Loop
			{
				ItemID := TV_GetNext(ItemID, "Full")
				if(ItemID=selNextID)	; 如果遍历到树末节点则跳出
					break
				TV_GetText(ItemText, ItemID)
				selTextList.Push(ItemText)
				DelListID.Push(ItemID)
			}
			ItemID:=moveID
			Loop
			{
				ItemID := TV_GetNext(ItemID, "Full")
				if(ItemID=moveNextID)	; 如果遍历到树末节点则跳出
					break
				TV_GetText(ItemText, ItemID)
				moveTextList.Push(ItemText)
				DelListID.Push(ItemID)
			}
			; 遍历旧节点数组删除
			Loop,% DelListID.MaxIndex()
			{
				TV_Delete(DelListID[A_Index])
			}
			; 遍历添加选中树内容到目标树
			Loop,% selTextList.MaxIndex()
			{
				TV_Add(selTextList[A_Index],moveID,Set_Icon(TreeImageListID,selTextList[A_Index]))
			}
			; 遍历添加目标树内容到选中树
			Loop,% moveTextList.MaxIndex()
			{
				TV_Add(moveTextList[A_Index],selID,Set_Icon(TreeImageListID,moveTextList[A_Index]))
			}
		}
		;~ [互换选中目标节点的名称]
		TV_Modify(selID, , moveVar)
		TV_Modify(moveID, , selVar)
		TV_Modify(selID, "-Select -focus")
		TV_Modify(moveID, "Select Vis")
		TV_Modify(selID, Set_Icon(TreeImageListID,moveVar))
		TV_Modify(moveID, Set_Icon(TreeImageListID,selVar))
		TVFlag:=true
	}
}
;~;[批量移动项目到指定树节点]
TV_MoveMenu(moveMenuName){
	moveItem:=RegExReplace(moveMenuName,"S)^-+")
	moveLevel:=StrLen(RegExReplace(moveMenuName,"S)(^-+).*","$1"))
	Menu,%moveMenuName%,add,%moveMenuName%,Move_Menu
	try {
		Menu,% moveRoot[moveLevel],add,%moveItem%, :%moveMenuName%
	} catch e {
		TrayTip,,% "右键操作菜单创建错误：" moveMenuName "`n出错命令：" e.What
			. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,10,3
	}
	try Menu,% moveRoot[moveLevel],Icon,%moveItem%,% TreeIconS[1],% TreeIconS[2]
	moveLevel+=1
	moveRoot[moveLevel]:=moveMenuName
}
TV_MoveMenuClean:
	Gui, MenuEdit:Default
	try{
		;[清空功能菜单]
		Menu,TVMenu,DeleteAll
		Menu,GuiMenu,DeleteAll
		Menu,moveMenu%both%,DeleteAll
	}catch{}
		;[重建]
		ItemID = 0
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		if(RegExMatch(ItemText,"S)^-+[^-]+.*")){
			TV_MoveMenu(ItemText)
		}
	}
	TVMenu("TVMenu")
	TVMenu("GuiMenu")
	Gui, MenuEdit:Menu, GuiMenu
return
;~;[移动节点后保存原来级别和自动变更名称(死了好多脑细胞)]
Move_Menu:
	Gui, MenuEdit:Default
	ItemID = 0
	MoveID = 0
	CheckID = 0
	DelListID:=Object()
	;[获取目标节点]
	Loop
	{
		ItemID := TV_GetNext(ItemID, "Full")
		if not ItemID
			break
		TV_GetText(ItemText, ItemID)
		if(ItemText=A_ThisMenuItem){
			MoveID:=ItemID
		}
	}
	;[获取选中节点并移动到目标节点下]
	if(MoveID){
		parentL:=StrLen(RegExReplace(A_ThisMenuItem,"S)(^-+).*","$1"))
		moveLevelID:=
		moveLevelList:=Object()
		moveLevelList[parentL]:=MoveID
		cpLevel:=0
		Loop
		{
			CheckID := TV_GetNext(CheckID, "Checked")
			if not CheckID
				break
			TV_GetText(ItemText, CheckID)
			;[对比选中节点到目标节点的级别，进行加减"-"级别匹配]
			if(InStr(ItemText,"-")=1){
				cItem:=RegExReplace(ItemText,"S)^-+")
				cLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).*","$1"))
				;[如已有比选中节点高一级则它为父级,否则为目标节点级别]
				pLevel:=(moveLevelList[cLevel+Abs(cpLevel)]) ? cLevel+Abs(cpLevel) : parentL
				cpLevel:=cLevel-pLevel	;选中节点与目标的级别差
				if(cpLevel>1){	;选中节点比目标大于1级
					Loop,% cpLevel - 1
					{
						ItemText:=RegExReplace(ItemText,"S)^-")
					}
				}else if(cpLevel<1){	;选中节点比目标小于1级
					Loop,% Abs(1 - cpLevel)
					{
						ItemText:="-" . ItemText
					}
				}
				cLevel:=StrLen(RegExReplace(ItemText,"S)(^-+).*","$1"))
				if(Abs(cLevel-pLevel)=1){	;选中节点与目标差1级
					if(cItem){
						;[是节点不是分隔符]
						moveLevelID:=TV_Add(ItemText,moveLevelList[cLevel-1],Set_Icon(TreeImageListID,ItemText))
						moveLevelList[cLevel]:=moveLevelID
						MoveID:=moveLevelID
					}else{
						;[遇到分隔符则改变树型]
						TV_Add(ItemText,moveLevelList[cLevel-1],Set_Icon(TreeImageListID,ItemText))
						MoveID:=moveLevelList[cLevel-1]
					}
				}
			}else{
				moveLevelID:=TV_Add(ItemText,MoveID,Set_Icon(TreeImageListID,ItemText))
			}
			DelListID.Push(CheckID)
			TVFlag:=true
		}
		;[删除原先节点]
		Loop,% DelListID.MaxIndex()
		{
			TV_Delete(DelListID[A_Index])
		}
		;[焦点到移动后新节点]
		TV_Modify(moveLevelID, "VisFirst")
		TV_Modify(moveLevelID, "Select")
		Gosub,TV_MoveMenuClean
	}
return
;~;[菜单树项目根据后缀或模式设置图标和样式]
Set_Icon(ImageListID,itemVar,editVar=true,fullItemFlag=true,itemName=""){
	;变量转换实际值
	itemVar:=Get_Transform_Val(itemVar)
	;菜单项启动模式
	setItemMode:=Get_Menu_Item_Mode(itemVar,fullItemFlag)
	itemStyle:=setItemMode=10 ? "Bold " : ""
	SplitPath,itemVar,,,FileExt,name_no_ext  ; 获取文件扩展名.
	;[获取全路径]
	if(setItemMode=1 || setItemMode=60){
		FileName:=Get_Obj_Path(itemVar)
		if(!FileExist(FileName))
			FailFlag:=true
	}
	diyText:=StrSplit(itemVar,"|",,2)
	objText:=(diyText[2]) ? diyText[2] : diyText[1]
	;[优先加载自定义图标]
	if(itemName!=""){
		itemIcon:=itemName
	}else if(InStr(itemVar,"|")){
		itemIcon:=diyText[1]
	}else{
		itemIcon:=name_no_ext
	}
	itemIconFile:=IconFolderList[menuItemIconFileName(itemIcon)]
	if(itemIconFile && FileExist(itemIconFile)){
		try{
			Menu,exeTestMenu,Icon,donothing,%itemIconFile%,0
			addNum:=IL_Add(ImageListID, itemIconFile, 0)
			return itemStyle . "Icon" . addNum
		}catch{}
	}
	if(setItemMode=2 || setItemMode=3)
		return "Icon2"
	if(setItemMode=10)
		return itemStyle . "Icon6"
	if(setItemMode=11)
		return "Icon8"
	if(setItemMode=7 || setItemMode=71)
		return "Icon4"
	if(setItemMode=4)	; {发送热键}
		return "Icon9"
	if(setItemMode=5)
		return "Icon10"
	if(setItemMode=8){  ; {脚本插件函数}
		appPlugins:=RegExReplace(objText,"iS)(.+?)\[.+?\]%?\(.*?\)$","$1")	;取插件名
		if(PluginsIconList[appPlugins ".ahk"]){
			PluginsIconS:=StrSplit(Get_Transform_Val(PluginsIconList[appPlugins ".ahk"]),",")
			addNum:=IL_Add(ImageListID, PluginsIconS[1], PluginsIconS[2])
			return "Icon" addNum
		}
		return "Icon11"
	}
	if(!editVar && FileName="" && FileExt="exe")
		return "Icon3"
	;[获取网址图标]
	if(setItemMode=6){
		try{
			website:=RegExReplace(objText,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=A_ScriptDir "\RunIcon\" website ".ico"
			if(FileExist(webIcon)){
				Menu,exeTestMenu,Icon,donothing,%webIcon%,0
				addNum:=IL_Add(ImageListID, webIcon, 0)
				return "Icon" . addNum
			}else{
				return "Icon7"
			}
		} catch e {
			return "Icon7"
		}
	}
	;[编辑后图标重新加载]
	if(editVar && FailFlag){
		;[编辑后通过everything重新添加应用图标]
		if(FileExt="exe"){
			if(!EvNo)
				exeQueryPath:=exeQuery(FileName="" ? objText : FileName)
			if(exeQueryPath){
				FileName:=exeQueryPath
			}else{
				return "Icon3"
			}
		}else{
			FileName:=objText!="" ? objText : FileName
		}
	}
	; 计算 SHFILEINFO 结构需要的缓存大小.
	sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
	VarSetCapacity(sfi, sfi_size)
	;【下面开始处理未知的项目图标】
	if FileExt in EXE,ICO,ANI,CUR
	{
		ExtID := FileExt  ; 特殊 ID 作为占位符.
		IconNumber := 0  ; 进行标记这样每种类型就含有唯一的图标.
	}
	else  ; 其他的扩展名/文件类型, 计算它们的唯一 ID.
	{
		ExtID := 0  ; 进行初始化来处理比其他更短的扩展名.
		Loop 7     ; 限制扩展名为 7 个字符, 这样之后计算的结果才能存放到 64 位值.
		{
			ExtChar := SubStr(FileExt, A_Index, 1)
			if not ExtChar  ; 没有更多字符了.
				break
			; 把每个字符与不同的位置进行运算来得到唯一 ID:
			ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
		}
		; 检查此文件扩展名的图标是否已经在图像列表中. 如果是,
		; 可以避免多次调用并极大提高性能,
		; 尤其对于包含数以百计文件的文件夹而言:
		if(ExtID>0)
			IconNumber := IconArray%ExtID%
		noEXE:=true
	}
	if not IconNumber  ; 此扩展名还没有相应的图标, 所以进行加载.
	{
		; 获取与此文件扩展名关联的高质量小图标:
		if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "str", FileName
			, "uint", 0, "ptr", &sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 为 SHGFI_ICON+SHGFI_SMALLICON
		{
			IconNumber = 3  ; 显示默认应用图标.
			if(noEXE)
				IconNumber = 1
		}
		else ; 成功加载图标.
		{
			; 从结构中提取 hIcon 成员:
			hIcon := NumGet(sfi, 0)
			; 直接添加 HICON 到小图标和大图标列表.
			; 下面加上 1 来把返回的索引从基于零转换到基于一:
			IconNumber := DllCall("ImageList_ReplaceIcon", "ptr", ImageListID, "int", -1, "ptr", hIcon) + 1
			; 现在已经把它复制到图像列表, 所以应销毁原来的:
			DllCall("DestroyIcon", "ptr", hIcon)
			; 缓存图标来节省内存并提升加载性能:
			if(ExtID>0)
				IconArray%ExtID% := IconNumber
		}
	}
	return "Icon" . IconNumber
}
;修改于ahk论坛全选全不选
TV_CheckUncheckWalk(_GuiEvent, _EventInfo, _GuiControl)
{
	static  TV_SuspendEvents := False                                           ;最初接受事件并保持跟踪
	If ( TV_SuspendEvents || !_GuiEvent || !_EventInfo || !_GuiControl )        ;无所事事：跳出
		Return
	If _GuiEvent = Normal                                                       ;这是一个左键：继续
	{
		Critical                                                                ;不能被中断。
		TV_SuspendEvents := True                                                ;在工作时停止对功能的进一步调用
		Gui, TreeView, %_GuiControl%                                            ;激活正确的TV
		TV_Modify(_EventInfo, "Select")                                         ;选择项目反正...这一行可能在这里取消和分散进一步
		If TV_Get( _EventInfo, "Checked" )                                      ;项目的复选标记
		{
			If TV_GetChild( _EventInfo )                                        ;项目的节点
				ToggleAllTheWay( _EventInfo, False )                            ;复选标记所有的子节点一路下来
		}
		Else                                                                    ;它未被选中
		{
			If TV_GetChild( _EventInfo )                                        ;它是一个节点
				ToggleAllTheWay( _EventInfo, True )                             ;取消选中所有的子节点一直向下
			If TV_Get( TV_GetParent( _EventInfo ), "Checked")                   ;父节点选中怎么样？
			{
				locItemId := TV_GetParent( _EventInfo )                         ;父节点检查标记：获取父ID
				While locItemId                                                 ;循环一路向上
				{
					TV_Modify( locItemId , "-Check" )                           ;取消选中
					locItemId := TV_GetParent( locItemId )                      ;获取下一个父ID
				}
			}
		}
	}
	TV_SuspendEvents := False                                                   ;激活事件
	Return
}
; ToggleAllTheWay：内部使用
ToggleAllTheWay(_ItemID=0, _ChkUchk=True ) {
	If !_ItemID		;停止递归
		Return
	_ItemID := TV_GetChild( _ItemID ) 	;得到下一个孩子
	Loop
	{
		If  !_ItemID 					;工作结束：出去
			Break
		If _ChkUchk        ;区分条件检索
		{
			If TV_Get( _ItemID , "Checked" )
				TV_Modify( _ItemID , "-Check" )
		}
		Else
		{
			If !TV_Get( _ItemID , "Checked" )
				TV_Modify( _ItemID , "Check" )
		}
		ToggleAllTheWay( _ItemID, _ChkUchk )			;使用递归
		_ItemID := TV_GetNext( _ItemID )
	}
	Return
}

