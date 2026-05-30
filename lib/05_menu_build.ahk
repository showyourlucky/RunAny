;~;【——🏗创建菜单——】
;══════════════════════════════════════════════════════════════════
Menu_Read(iniReadVar,menuRootFn,TREE_TYPE,TREE_NO){
	MenuObjName:=Object()    ;~程序菜单项名称
	MenuBar:=""              ;~菜单分列标记
	MenuObjParam:=Object()   ;~程序参数
	menuLevel:=1
	Loop, parse, iniReadVar, `n, `r
	{
		try{
			Z_LoopField=%A_LoopField%
			if(InStr(Z_LoopField,";")=1 || Z_LoopField=""){
				continue
			}
			TREE_TYPE_FLAG:=(TREE_TYPE="" || TREE_TYPE="    ")
			;[生成节点树层级结构]
			if(InStr(Z_LoopField,"-")=1){
				menuItem:=RegExReplace(Z_LoopField,"S)^-+")
				treeLevel:=RegExReplace(Z_LoopField,"S)(^-+).*","$1")
				menuLevel:=StrLen(treeLevel)
				if(InStr(menuItem,"|")){
					menuItems:=StrSplit(menuItem,"|",,2)
					menuItem:=menuItems[1]
					;[读取菜单关联后缀][不重复]
					if(TREE_TYPE=""){
						Loop, parse,% menuItems[2],%A_Space%
						{
							;选中文件后显示的公共后缀菜单
							if(A_LoopField="public"){
								MenuObjPublic.Push(treeLevel . menuItem)
							}else if(A_LoopField="text"){
								MenuObjText%TREE_NO%.Push(menuItem)
							}else if(A_LoopField="file"){
								MenuObjFile%TREE_NO%.Push(menuItem)
							}else if(RegExMatch(A_LoopField,"iS).+\.(exe|class)$")){
								global MenuObjWindowFlag:=true
								windowItem:=RegExReplace(A_LoopField,"iS)\.class$")
								if(!IsObject(MenuObjWindow[(windowItem)]))
									MenuObjWindow[(windowItem)]:=Object()
								MenuObjWindow[(windowItem)].Push(menuItem)
							}else{
								MenuObjExt[(A_LoopField)]:=menuItem
							}
						}
					}
				}
				if(menuItem!=""){
					menuItemType:=menuItem . TREE_TYPE
					Menu,%menuItemType%,add
					try Menu,% menuRootFn[menuLevel],add,%menuItemType%,:%menuItemType%,%MenuBar%
					Menu_Item_Icon(menuRootFn[menuLevel],menuItemType,TreeIconS[1],TreeIconS[2],treeLevel . menuItemType)
					Menu,%menuItemType%,Delete, 1&
					menuLevel+=1	;比初始根菜单加一级
					menuRootFn[menuLevel]:=menuItemType		;从这之后内容项都添加到该级别菜单中

					;记录全局菜单数据
					if(!IsObject(MenuObjTree%TREE_NO%[menuItemType]))
						MenuObjTree%TREE_NO%[menuItemType]:=Object()
					MenuObjTreeLevel[menuItemType]:=treeLevel

					;[分割Tab获取菜单自定义热键][不重复]
					if(TREE_TYPE_FLAG && InStr(menuItem,"`t")){
						menuKeyStr:=RegExReplace(menuItem, "S)\t+", A_Tab)
						menuKeys:=StrSplit(menuKeyStr,"`t")
						if(menuKeys[2]){
							MenuTreeKey[menuKeys[2]]:=menuItemType
							Hotkey,% menuKeys[2],Menu_Key_Show,On
						}
					}
				}else if(menuRootFn[menuLevel]){	;[添加分隔符]
					menuRootFnLevel:=menuRootFn[menuLevel]
					Menu,%menuRootFnLevel%,Add
					MenuObjTree%TREE_NO%[menuRootFnLevel].Push(Z_LoopField)
				}
				MenuBar:=""
				continue
			}
			if(Z_LoopField="|" || Z_LoopField="||"){
				MenuBar:=(Z_LoopField="||") ? "+BarBreak" : "+Break"
				continue
			}
			if(menuRootFn[menuLevel]="")
				continue

			itemMode:=Get_Menu_Item_Mode(Z_LoopField,true)
			if(TREE_TYPE="" && itemMode=60 && RegExMatch(Z_LoopField,"iS).*?%s[^%]*$")){
				MsgBox,48,请修改菜单项 `%s不能识别,% "菜单项：" Get_Obj_Transform_Name(Z_LoopField)
					. "`n里面的`%s 仅支持在纯网址模式，`n在参数中请替换使用%getZz%表示选中文字"
			}
			;短语、网址、脚本插件函数除外的菜单项直接转换%%为系统变量值
			transformValFlag:=false
			if(itemMode!=2 && itemMode!=3 && itemMode!=8){
				Z_LoopField:=StrReplace(Z_LoopField,"%getZz%",Chr(3))
				Z_LoopField:=StrReplace(Z_LoopField,"%Clipboard%",Chr(4))
				Z_LoopField:=StrReplace(Z_LoopField,"%ClipboardAll%",Chr(5))
				Z_LoopField:=StrReplace(Z_LoopField,"%A_ThisMenuItem%",Chr(6))
				Z_LoopField:=Get_Transform_Val(Z_LoopField)
				Z_LoopField:=StrReplace(Z_LoopField,Chr(3),"%getZz%")
				Z_LoopField:=StrReplace(Z_LoopField,Chr(4),"%Clipboard%")
				Z_LoopField:=StrReplace(Z_LoopField,Chr(5),"%ClipboardAll%")
				Z_LoopField:=StrReplace(Z_LoopField,Chr(6),"%A_ThisMenuItem%")
				transformValFlag:=true
			}
			itemMode:=Get_Menu_Item_Mode(Z_LoopField,true)
			;~添加到分类目录程序全数据
			if(!IsObject(MenuObjTree%TREE_NO%[(menuRootFn[menuLevel])]))
				MenuObjTree%TREE_NO%[(menuRootFn[menuLevel])]:=Object()
			MenuObjTree%TREE_NO%[(menuRootFn[menuLevel])].Push(Z_LoopField)
			flagEXE:=false      ;~添加exe菜单项目
			flagSys:=false      ;~添加系统项目文件
			IconFail:=false     ;~是否显示无效项图标
			;[生成有前缀备注的应用]
			if(InStr(Z_LoopField,"|")){
				menuDiy:=StrSplit(Z_LoopField,"|",,2)
				menuItemDiy:=menuDiy[1]
				appName:=RegExReplace(menuDiy[2],"iS)(.*?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数，取应用名
				appName:=RegExReplace(appName,"iS)\.exe$")	;去掉exe后缀，取应用名
				;[分割Tab获取应用自定义热键]
				menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
				menuKeys:=StrSplit(menuKeyStr,"`t",,2)
				if(MenuObjName.HasKey(menuItemDiy) || MenuObjParam.HasKey(menuItemDiy)){
					if(menuKeys[2]){
						menuItemDiy:=menuKeys[1] "重名" A_Tab menuKeys[2]
					}else{
						menuItemDiy.="重名"
					}
				}
				itemContent:=MenuObjEv[appName]
				if(itemContent){
					SplitPath, itemContent,,, FileExt  ; 获取文件扩展名.
					appParm:=RegExReplace(menuDiy[2],"iS).*?\." FileExt "($| .*)","$1")	;去掉应用名，取参数
					;非exe后缀的菜单项名与无路径exe的名称相同，则自动在菜单项名末尾添加后缀标记
					if(FileExt!="exe" && appName!=menuItemDiy && MenuObjEv[menuItemDiy]){
						menuItemDiy.="." FileExt
					}
					MenuObjParam[menuItemDiy]:=itemContent . appParm
					itemParam:=itemContent . appParm
					flagEXE:=true
				}else{
					itemContent:=menuDiy[2]
					itemParam:=menuDiy[2]
					if(transformValFlag && RegExMatch(itemContent,"iS).*?\.(exe|lnk|bat|cmd|vbs|ps1|ahk) .*"))
						itemContent:=RegExReplace(itemContent,"iS)(.*?\.(exe|lnk|bat|cmd|vbs|ps1|ahk)) .*","$1")	;只去参数
					SplitPath, itemContent,,, FileExt  ; 获取文件扩展名.
					;~;如果是有效全路径或系统程序则保留显示
					if(RegExMatch(itemContent,"iS)^(\\\\|.:\\).*?\.(exe|lnk|bat|cmd|vbs|ps1|ahk)$") && FileExist(itemContent)){
						flagEXE:=true
					}else if(FileExist(A_WinDir "\" itemContent) || FileExist(A_WinDir "\system32\" itemContent)){
						flagEXE:=true
						if(FileExt!="exe"){
							flagSys:=true
							flagSysPath:=FileExist(A_WinDir "\" itemContent) ? A_WinDir "\" itemContent : ""
							if(flagSysPath="" && FileExist(A_WinDir "\system32\" itemContent))
								flagSysPath:=A_WinDir "\system32\" itemContent
						}
					}
					;~;如果是有效程序、不隐藏失效、不是exe程序则添加该菜单项功能
					if(FileExt!="exe"){
						MenuObj[menuItemDiy]:=menuDiy[2]
					}else if(flagEXE || !HideFail){
						MenuObjParam[menuItemDiy]:=menuDiy[2]
					}
				}
				if(FileExt="exe"){
					if(flagEXE){
						MenuExeArrayPush(menuRootFn[menuLevel],menuItemDiy,itemContent,menuDiy[2],TREE_NO)
					}else{
						IconFail:=true
					}
					if(!HideFail)
						flagEXE:=true
					;添加菜单项
					if(flagEXE){
						Menu,% menuRootFn[menuLevel],add,% menuItemDiy,Menu_Run,%MenuBar%
						if(IconFail)
							Menu_Item_Icon(menuRootFn[menuLevel],menuItemDiy,"SHELL32.dll","124")
					}else{
						MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuRootFn[menuLevel],menuItemDiy)
					}
				}else if FileExt in lnk,bat,cmd,vbs,ps1,ahk
				{
					Menu_Add(menuRootFn[menuLevel],menuItemDiy,itemContent,itemMode,TREE_NO)
				}else if(flagSys){
					Menu_Add(menuRootFn[menuLevel],menuItemDiy,flagSysPath="" ? itemContent : flagSysPath,itemMode,TREE_NO)
				}else{
					Menu_Add(menuRootFn[menuLevel],menuItemDiy,itemParam,itemMode,TREE_NO)
				}
				;[设置热键启动方式][不重复]
				if(TREE_TYPE_FLAG && InStr(menuDiy[1],"`t") && menuKeys[2]){
					; MenuObj[menuKeys[1]]:=itemParam
					MenuObjKey[menuKeys[2]]:=itemParam
					MenuObjKeyName[menuKeys[2]]:=menuKeys[1]
					MenuObjKeyList[menuDiy[1]]:=menuKeys[2]
					if(!InStr(menuDiy[2],"%getZz%") && RegExMatch(menuDiy[2],"iS).+?\[.+?\]%?\(.*?\)")){
						Hotkey,% menuKeys[2],Menu_Key_NoGet_Run,On
					}else if(itemMode=4 || itemMode=5){ ;热键映射不去获取当前选中内容
						Hotkey,% menuKeys[2],Menu_Key_NoGet_Run,On
					}else{
						Hotkey,% menuKeys[2],Menu_Key_Run,On
					}
				}
				;[设置热字符串启动方式][不重复]
				if(TREE_TYPE="" && RegExMatch(menuKeys[1],"S):[*?a-zA-Z0-9]+?:[^:]*")){
					hotStrName:=menuKeys[1]
					if(RegExMatch(hotStrName,"S).*_:\d{1,2}$"))
						hotStrName:=RegExReplace(hotStrName,"S)(.*)_:\d{1,2}$","$1")
					hotstr:=RegExReplace(hotStrName,"S)^[^:]*?(:[*?a-zA-Z0-9]+?:[^:]*)","$1")
					hotStrName:=RegExReplace(hotStrName,"S)^([^:]*?):[*?a-zA-Z0-9]+?:[^:]*","$1")
					if(hotstr){
						MenuObjKey[hotstr]:=itemParam
						MenuObjKeyName[hotstr]:=menuKeys[1]
						if(RegExMatch(hotstr,"S):[^:]*?X[^:]*?:[^:]*")){
							;热字符串运行不传递选中内容：不带%getZz%的运行项、不带%getZz%或%s的网址
							if(itemMode=6 && !InStr(menuDiy[2],"%getZz%") && !InStr(menuDiy[2],"%s")){
								Hotstring(hotstr,"Menu_Key_NoGet_Run","On")
							}else if(!InStr(menuDiy[2],"%getZz%")){
								Hotstring(hotstr,"Menu_Key_NoGet_Run","On")
							}else{
								Hotstring(hotstr,"Menu_Key_Run","On")
							}
							if(!HideHotStr)
								Menu_HotStr_Hint_Read(hotstr,hotStrName,itemParam)
						}else{
							Hotstring(hotstr,itemParam,"On")
						}
					}
				}
				MenuBar:=""
				continue
			}
			;[生成完全路径的应用]
			if(RegExMatch(Z_LoopField,"iS)^(\\\\|.:\\).*?\.exe($| .*)")){
				appParm:=RegExReplace(Z_LoopField,"iS).*?\.exe($| .*)","$1")	;去掉应用名，取参数
				Z_LoopField:=RegExReplace(Z_LoopField,"iS)(.*?\.exe)($| .*)","$1")
				SplitPath,Z_LoopField,fileName,,,nameNotExt
				menuAppName:=appParm!="" ? nameNotExt A_Space : nameNotExt
				MenuObjParam[menuAppName]:=Z_LoopField . appParm
				if(FileExist(Z_LoopField)){
					MenuExeArrayPush(menuRootFn[menuLevel],menuAppName,Z_LoopField,Z_LoopField . appParm,TREE_NO)
					flagEXE:=true
				}else{
					IconFail:=true
				}
				if(!HideFail)
					flagEXE:=true
				;添加菜单项
				if(flagEXE){
					Menu,% menuRootFn[menuLevel],add,% menuAppName,Menu_Run,%MenuBar%
					if(IconFail){
						Menu_Item_Icon(menuRootFn[menuLevel],menuAppName,"SHELL32.dll","124")
					}
				}else{
					MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuRootFn[menuLevel],menuAppName)
				}
				MenuBar:=""
				continue
			}
			;[生成通过Everything取到的无路径应用]
			if(RegExMatch(Z_LoopField,"iS)\.exe($| .*)")){
				appParm:=RegExReplace(Z_LoopField,"iS).*?\.exe($| .*)","$1")	;去掉应用名，取参数
				Z_LoopField:=RegExReplace(Z_LoopField,"iS)(.*?\.exe)($| .*)","$1")
				appName:=RegExReplace(Z_LoopField,"iS)\.exe$")
				menuAppName:=appParm!="" ? appName A_Space A_Space : appName
				if(MenuObjEv[appName]){
					flagEXE:=true
					MenuObj[menuAppName]:=MenuObjEv[appName]
					MenuObjParam[menuAppName]:=MenuObjEv[appName] . appParm
				}else if(FileExist(A_WinDir "\" Z_LoopField) || FileExist(A_WinDir "\system32\" Z_LoopField)){
					flagEXE:=true
					MenuObj[menuAppName]:=Z_LoopField
					MenuObjParam[menuAppName]:=Z_LoopField . appParm
				}else if(!HideFail){
					MenuObj[menuAppName]:=Z_LoopField
					MenuObjParam[menuAppName]:=Z_LoopField . appParm
				}
				if(flagEXE){
					MenuExeArrayPush(menuRootFn[menuLevel],menuAppName,MenuObj[menuAppName],MenuObj[menuAppName] . appParm,TREE_NO)
				}else{
					IconFail:=true
				}
				if(!HideFail)
					flagEXE:=true
				;添加菜单项
				if(flagEXE){
					Menu,% menuRootFn[menuLevel],add,% menuAppName,Menu_Run,%MenuBar%
					if(IconFail)
						Menu_Item_Icon(menuRootFn[menuLevel],menuAppName,"SHELL32.dll","124")
				}else{
					MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuRootFn[menuLevel],menuAppName)
				}
			}else{
				if(!MenuObjEv[Z_LoopField])
					MenuObj[Z_LoopField]:=Z_LoopField
				else
					MenuObj[Z_LoopField]:=MenuObjEv[Z_LoopField]
				Menu_Add(menuRootFn[menuLevel],Z_LoopField,MenuObj[Z_LoopField],itemMode,TREE_NO)
			}
			MenuBar:=""
		} catch e {
			MsgBox,16,构建菜单出错,% "菜单名：" menuRootFn[menuLevel] "`n菜单项：" A_LoopField
				. "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
		}
	}
	For key, value in MenuObjParam
	{
		MenuObj[key]:=value
	}
	if(!HideMenuTray){
		Menu,% menuRootFn[1],add,%RUNANY_SELF_MENU_ITEM2%,:Tray,%MenuBar%
		Menu,% menuRootFn[1],Icon,%RUNANY_SELF_MENU_ITEM2%,% AnyIconS[1],% AnyIconS[2],%MenuIconSize%
	}
	Menu,% menuRootFn[1],add,
}
;[统一集合菜单中软件运行项]
MenuExeArrayPush(menuName,menuItem,itemFile,itemAny,TREE_NO){
	MenuObjEXE:=Object()	;~软件对象
	MenuObjEXE["menuName"]:=menuName
	MenuObjEXE["menuItem"]:=menuItem
	MenuObjEXE["itemFile"]:=itemFile
	;~ MenuObjEXE["itemAny"]:=itemAny
	if(RegExMatch(menuName,"S)[^\s]+$")){
		MenuExeArray.Push(MenuObjEXE)
	}else{
		MenuExeIconArray.Push(MenuObjEXE)
		if(!InStr(itemAny,"%getZz%"))
			MenuExeList%TREE_NO%[menuName].=menuItem "`n"
	}
}
;[读取热字串用作提示文字]
Menu_HotStr_Hint_Read(hotstr,hotStrName,itemParam){
	menuHotStrShow:=RegExReplace(hotstr,"^:[^:]*?X[^:]*?:")
	menuHotStrLen:=StrLen(menuHotStrShow)
	HotStrHintLenVal:=HotStrHintLen>1 ? HotStrHintLen : 1
	if(menuHotStrLen=0)
		return
	if(menuHotStrLen=1){
		menuHotStrHint:=menuHotStrShow
	}else if(menuHotStrLen<=HotStrHintLenVal){ ;总长度小于4在减1长度时提示
		menuHotStrHint:=SubStr(menuHotStrShow, 1, menuHotStrLen-1)
	}else{
		loop, % menuHotStrLen - HotStrHintLenVal
		{
			MenuObjHotStr:=Object()	;热字符对象
			menuHotStrHint:=SubStr(menuHotStrShow, 1, A_Index + HotStrHintLenVal-1)
			MenuObjHotStr["hotStrAny"]:=itemParam
			MenuObjHotStr["hotStrHint"]:=menuHotStrHint
			MenuObjHotStr["hotStrShow"]:=menuHotStrShow
			MenuObjHotStr["hotStrName"]:=hotStrName
			MenuHotStrList.Push(MenuObjHotStr)
			Hotstring(":*Xb0:" . menuHotStrHint,"Menu_HotStr_Hint_Run","On")
		}
		return
	}
	MenuObjHotStr:=Object()	;热字符对象
	MenuObjHotStr["hotStrAny"]:=itemParam
	MenuObjHotStr["hotStrHint"]:=menuHotStrHint
	MenuObjHotStr["hotStrShow"]:=menuHotStrShow
	MenuObjHotStr["hotStrName"]:=hotStrName
	MenuHotStrList.Push(MenuObjHotStr)
	Hotstring(":*Xb0:" . menuHotStrHint,"Menu_HotStr_Hint_Run","On")
}
Menu_HotStr_Hint_Run:
	runHotStrHint:=RegExReplace(A_ThisHotkey,"^:[^:]*?Xb0:")
	HintTip:=["","","",""]
	for k , v in MenuHotStrList
	{
		if(v["hotStrHint"]=runHotStrHint){
			hotStrName:=v["hotStrName"]!=""?v["hotStrName"]:""
			;将获取到的热字符串中的变量进行转化，比如显示实时时间
			hotStrFixed:=RegExReplace(v["hotStrAny"],"S);+$")
			hotStrFlexible:=Get_Transform_Val(hotStrFixed)
			if(HotStrShowLen<=0){
				hotStrAny:=""
			}else if(StrLen(v["hotStrAny"])>HotStrShowLen){
				hotStrAny:=SubStr(hotStrFlexible, 1, HotStrShowLen) . "..."
			}else{
				hotStrAny:=hotStrFlexible
			}
			HintTip[1] .= runHotStrHint "`n",HintTip[2] .= v["hotStrShow"] "  `n",HintTip[3] .= hotStrName "  `n",HintTip[4] .= hotStrAny "  `n"
		}
	}
	HintTip[2]:=RTrim(HintTip[2],"`n"),HintTip[3]:=RTrim(HintTip[3],"`n"),HintTip[4]:=RTrim(HintTip[4],"`n")
	CreateHotStrGui(HintTip,HotStrGuiW,HotStrGuiH)
	GetCaret(CaretX, CaretY, CaretW, CaretH, Flag)
	If(Flag=0)
		CaretX := CaretX+HotStrShowX, CaretY := CaretY+HotStrShowY-HotStrGuiH
	Else
		CaretX := CaretX+HotStrShowX+CaretW, CaretY := CaretY+HotStrShowY-HotStrGuiH
	CaretX := CaretX+HotStrGuiW>A_ScreenWidth?A_ScreenWidth-5-HotStrGuiW:CaretX,CaretY := CaretY<5?5:CaretY
	try Gui, HotStrGui:Show, x%CaretX% y%CaretY% NoActivate
	SetTimer, Hide_HotStrGui, %HotStrShowTime%
Return

Hide_HotStrGui:  ;隐藏GUI
	SetTimer, Hide_HotStrGui, Off
	Gui, HotStrGui:Hide
Return
return
;══════════════════════════════════════════════════════════════════
;~;【生成菜单项(判断后缀创建图标)】
;══════════════════════════════════════════════════════════════════
Menu_Add(menuName,menuItem,itemContent,itemMode,TREE_NO){
	if(!menuName || !itemContent)
		return
	try {
		SplitPath, itemContent,,, FileExt  ; 获取文件扩展名.
		Menu,%menuName%,add,%menuItem%,Menu_Run,%MenuBar%
		MenuBar:=""
		MenuObjList%TREE_NO%[menuName].=menuItem "`n"
		if(itemMode=2 || itemMode=3){  ; {短语}
			Menu_Item_Icon(menuName,menuItem,"SHELL32.dll",itemMode=3 ? "2" : "71")
			MenuSendStrList%TREE_NO%[menuName].=menuItem "`n"
			return
		}
		if(itemMode=4 || itemMode=5){	; {发送热键}
			Menu_Item_Icon(menuName,menuItem,"SHELL32.dll",itemMode=5 ? "101" : "100")
			return
		}
		if(itemMode=6){  ; {网址}
			website:=RegExReplace(itemContent,"iS)[\w-]+://?((\w+\.)+\w+).*","$1")
			webIcon:=RunIconDir "\" website ".ico"
			webIconNum:=0
			if(!FileExist(webIcon)){
				webIcon:=UrlIconS[1]
				webIconNum:=UrlIconS[2]
			}
			Menu_Item_Icon(menuName,menuItem,webIcon,webIconNum)
			if(InStr(itemContent,"%s") || InStr(itemContent,"%getZz%"))
				MenuWebList%TREE_NO%[menuName].=menuItem "`n"
			return
		}
		if(itemMode=8){  ; {脚本插件函数}
			appPlugins:=RegExReplace(itemContent,"iS)(.+?)\[.+?\]%?\(.*?\)$","$1")	;取插件名
			if(PluginsIconList[appPlugins ".ahk"]){
				PluginsIconS:=StrSplit(Get_Transform_Val(PluginsIconList[appPlugins ".ahk"]),",")
				Menu_Item_Icon(menuName,menuItem,PluginsIconS[1],PluginsIconS[2])
			}else{
				Menu_Item_Icon(menuName,menuItem,FuncIconS[1],FuncIconS[2])
			}
			if(InStr(itemContent,"%getZz%")){
				MenuGetZzList%TREE_NO%[menuName].=menuItem "`n"	; 添加到GetZz搜索
			}
			return
		}
		if(itemMode=7 || itemMode=71){  ; {目录}
			Menu,%menuName%,Icon,%menuItem%,% FolderIconS[1],% FolderIconS[2],%MenuIconSize%
		}else if(FileExt="lnk"){  ; {快捷方式}
			try{
				FileGetShortcut, %itemContent%, OutItem, , , , OutIcon, OutIconNum
				if(!OutIcon){
					OutIcon:=OutItem
					OutIconNum:=0
				}
				Menu_Item_Icon(menuName,menuItem,OutIcon,OutIconNum)
			} catch e {
				if(!HideFail){
					Menu_Item_Icon(menuName,menuItem,LNKIconS[1],LNKIconS[2])
				}else{
					Menu,%menuName%,Delete,%menuItem%
					MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuName,menuItem)
				}
			}
		}else{  ; {处理未知的项目图标}
			If(FileExt && FileExist(itemContent)){
				try{
					RegRead, regFileExt, HKEY_CLASSES_ROOT, .%FileExt%
					RegRead, regFileIcon, HKEY_CLASSES_ROOT, %regFileExt%\DefaultIcon
					regFileIconS:=StrSplit(regFileIcon,",")
					Menu_Item_Icon(menuName,menuItem,regFileIconS[1],regFileIconS[2])
				}catch{}
			}else if(!HideFail){
				Menu_Item_Icon(menuName,menuItem,"SHELL32.dll","124")
			}else{
				Menu,%menuName%,Delete,%menuItem%
				MenuObjTree_Delete_NoFind(MenuObjTree%TREE_NO%,menuName,menuItem)
			}
		}
	} catch e {
		MsgBox,16,判断后缀创建菜单项出错,% "菜单名：" menuName "`n菜单项：" menuItem
			. "`n路径：" itemContent "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
}
MenuObjTree_Delete_NoFind(MenuObjTreeNum,menuName,menuItem){
	for i,v in MenuObjTreeNum[menuName]
	{
		if(menuItem=Get_Obj_Transform_Name(v)){
			MenuObjTreeNum[menuName].RemoveAt(i)
		}
	}
}
;[统一设置菜单项图标]
Menu_Item_Icon(menuName,menuItem,iconPath,iconNo=0,treeLevel=""){
	try{
		menuItemSet:=treeLevel ? treeLevel : menuItem
		menuItemSet:=RTrim(menuItemSet)
		menuItemSet:=menuItemIconFileName(menuItemSet)
		if(IconFolderList[menuItemSet]){
			Menu,%menuName%,Icon,%menuItem%,% IconFolderList[menuItemSet],0,%MenuIconSize%
			MenuObjIconList[menuItem]:=IconFolderList[menuItemSet]
			MenuObjIconNoList[menuItem]:=0
		}else{
			Menu,%menuName%,Icon,%menuItem%,%iconPath%,%iconNo%,%MenuIconSize%
			MenuObjIconList[menuItem]:=iconPath
			MenuObjIconNoList[menuItem]:=iconNo
		}
		MenuObjName[menuItemSet]:=1
	}catch{}
}
menuItemIconFileName(menuItem){
	if(InStr(menuItem,"`t")){
		menuKeyStr:=RegExReplace(menuItem, "S)\t+", A_Tab)
		menuKeys:=StrSplit(menuKeyStr,"`t")
		menuItem:=menuKeys[1]
	}
	if(RegExMatch(menuItem,"S).*_:\d{1,2}$"))
		menuItem:=RegExReplace(menuItem,"S)(.*)_:\d{1,2}$","$1")
	if(RegExMatch(menuItem,"S):[*?a-zA-Z0-9]+?:[^:]*")){
		menuItemTemp:=RegExReplace(menuItem,"S)^([^:]*?):[*?a-zA-Z0-9]+?:[^:]*","$1")
		if(menuItemTemp)
			menuItem:=menuItemTemp
	}
	return menuItem
}
