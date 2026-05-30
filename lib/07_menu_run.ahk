;~;【——🚀菜单运行——】
;══════════════════════════════════════════════════════════════════
Menu_Run:
	Z_ThisMenuItem:=A_ThisMenuItem
	Z_ThisMenu:=A_ThisMenu
	Z_ThisMenuItemiconpath:= MenuObjIconList[Z_ThisMenuItem]
	Z_ThisMenuItemiconNo:= MenuObjIconNoList[Z_ThisMenuItem]
	any:=MenuObj[(Z_ThisMenuItem)]
	if(OutsideMenuItem!=""){
		any:=MenuObj[(OutsideMenuItem)]
		if(any=""){
			TrayTip,%OutsideMenuItem% 没有找到,请检查是否存在(在Everything能搜索到)，并重启RunAny重试,5,2
		}
		if(RunCtrlRunFlag || RemoteMenuRunFlag)
			Z_ThisMenuItem:=OutsideMenuItem
		RunCtrlRunFlag:=RemoteMenuRunFlag:=OutsideMenuItem:=""
	}
	MenuRunDebugModeShow()
	if(any="")
		return
	fullPath:=Get_Obj_Path(any)
	SplitPath, fullPath, name, dir, ext, name_no_ext
	if(dir && FileExist(dir))
		SetWorkingDir,%dir%
	try {
		global TVEditItem
		;[判断运行软件时按住的键]
		menuholdkey:=MenuRunHoldKey()
		;[获取菜单项启动模式]
		itemMode:=Get_Menu_Item_Mode(any)
		;[从最近运行项中记录的右键多功能项]
		M_ThisMenuItem:=""
		R_ThisMenuItem:=RegExReplace(Z_ThisMenuItem,"^&\d+ ","")
		menuRunNameStr:="运行(&R) " Z_ThisMenuItem "," MENU_RUN_NAME_STR
		menuRunNameNoFileStr:="运行(&R) " Z_ThisMenuItem "," MENU_RUN_NAME_NOFILE_STR
		if R_ThisMenuItem in %menuRunNameStr%
		{
			M_ThisMenuItem:=R_ThisMenuItem
		}
		;[显示功能菜单]
		if(menuholdkey=HoldKeyRun5){
			Gosub,MenuRunMultifunctionMenu
			if(M_ThisMenuItem="")
				return
		}
		;[编辑菜单项]
		if(menuholdkey=HoldKeyRun3 || M_ThisMenuItem="编辑(&E)"){
			TVEditItem:=Z_ThisMenuItem
			TVEditItem:=RegExReplace(TVEditItem,"重名$")
			Gosub,Menu_Edit%MENU_NO%
			return
		}
		;[复制或输出菜单项内容]
		if(menuholdkey=HoldKeyRun31 || M_ThisMenuItem="复制运行路径(&C)"){
			Send_Or_Show(fullPath,false,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun37 || M_ThisMenuItem="独立置顶显示(&T)"){
			Z_ThisMenuItem1 := StrReplace(Z_ThisMenuItem, """","\""")
			if FileExist(A_ScriptDir "\RunPlugins\xiaoyao_command.ahk")
				run,"%A_ScriptDir%\RunAny.exe" "%A_ScriptDir%\RunPlugins\xiaoyao_command.ahk" -PMI "%Z_ThisMenuItem1%" "%Z_ThisMenuItemiconpath%" "%Z_ThisMenuItemiconNo%"
			Else
				MsgBox, 出错了!`n请先下载xiaoyao_command.ahk插件到RunPlugins目录
			return
		}else if(menuholdkey=HoldKeyRun38 || M_ThisMenuItem="置顶所在的菜单(&Y)"){
			Z_ThisMenu :=Trim(StrReplace(Z_ThisMenu, """","\"""))

			if FileExist(A_ScriptDir "\RunPlugins\xiaoyao_command.ahk"){
				IniRead, 按钮宽度2, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,按钮宽度
				IniRead, 按钮是否单行显示2, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,按钮是否单行显示
				;MsgBox, %按钮宽度2% %按钮是否单行显示2%
				if (按钮是否单行显示2="" or 按钮是否单行显示2="ERROR")
					IniWrite,0,%A_ScriptDir%\RunAnyConfig.ini,菜单gui化,按钮是否单行显示
				if (按钮宽度2="" or 按钮宽度2="ERROR"){	;初次使用，将默认配置写入RunAnyConfig.ini
					;MsgBox, %按钮宽度1%
					run,"%A_ScriptDir%\RunAny.exe" "%A_ScriptDir%\RunPlugins\xiaoyao_command.ahk" -menutopguiIniWrite
					;写法：-menutopgui "菜单分类名" "按钮宽度" "按钮高度" "按钮字体大小" "透明度" "图标大小" "初始显示位置X坐标" "初始显示位置Y坐标" "按钮字体名称" "背景颜色"
					run,"%A_ScriptDir%\RunAny.exe" "%A_ScriptDir%\RunPlugins\xiaoyao_command.ahk" -menutopgui "%Z_ThisMenu%"
				}Else{
					IniRead, 按钮宽度1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,按钮宽度
					IniRead, 按钮高度1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,按钮高度
					IniRead, 按钮字体大小1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,按钮字体大小
					IniRead, 透明度1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,透明度
					IniRead, 图标大小1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,图标大小
					IniRead, 初始显示位置X坐标1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,初始显示位置X坐标
					IniRead, 初始显示位置Y坐标1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,初始显示位置Y坐标
					IniRead, 按钮字体名称1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,按钮字体名称
					IniRead, 背景颜色1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,背景颜色
					IniRead, 按钮是否单行显示1, %A_ScriptDir%\RunAnyConfig.ini,菜单gui化,按钮是否单行显示
					;MsgBox, %按钮宽度1% %按钮是否单行显示1%
					run,"%A_ScriptDir%\RunAny.exe" "%A_ScriptDir%\RunPlugins\xiaoyao_command.ahk" -menutopgui "%Z_ThisMenu%" "%按钮宽度1%" "%按钮高度1%" "%按钮字体大小1%" "%透明度1%" "%图标大小1%" "%初始显示位置X坐标1%" "%初始显示位置Y坐标1%" "%按钮字体名称1%" "%背景颜色1%" "%按钮是否单行显示1%"
				}
			}Else
				MsgBox, 出错了!`n请先下载xiaoyao_command.ahk插件到RunPlugins目录
			return
		}else if(menuholdkey=HoldKeyRun39 || M_ThisMenuItem="复制菜单项名称(&Q)"){
			Clipboard:=Z_ThisMenuItem
			return
		}else if(menuholdkey=HoldKeyRun32 || M_ThisMenuItem="输出运行路径(&V)"){
			Send_Or_Show(fullPath,true,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun33 || M_ThisMenuItem="复制软件名(&N)"){
			Send_Or_Show(name_no_ext,false,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun34 || M_ThisMenuItem="输出软件名(&M)"){
			Send_Or_Show(name_no_ext,true,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun35 || M_ThisMenuItem="复制软件名+后缀(&F)"){
			Send_Or_Show(name,false,HoldKeyShowTime)
			return
		}else if(menuholdkey=HoldKeyRun36 || M_ThisMenuItem="输出软件名+后缀(&G)"){
			Send_Or_Show(name,true,HoldKeyShowTime)
			return
		}
		;[结束软件进程]
		if((menuholdkey=HoldKeyRun4 || M_ThisMenuItem="结束软件进程(&X)" || RunCtrlRunWayVal=6) && (itemMode=1 || itemMode=60)){
			Run,% ComSpec " /C taskkill /f /im """ name """", , Hide
			RunCtrlRunWayVal=
			return
		}
		if(RecentMax>0 && !NoRecentFlag && !RegExMatch(Z_ThisMenuItem,"S)^&\d+")){
			Gosub,Menu_Recent
		}
		NoRecentFlag:=false
		;[根据菜单项模式运行]
		returnFlag:=false
		Gosub,Menu_Run_Mode_Label
		if(returnFlag)
			return
		;[解析选中变量%getZz%]
		getZzFlag:=InStr(any,"%getZz%") ? true : false
		if(getZzFlag && InStr(getZz,A_Space) && !InStr(any,"""%getZz%""")){
			;如果选中变量中有空格，自动包上双引号
			any:=StrReplace(any,"%getZz%","""%getZz%""")
		}
		any:=Get_Transform_Val_GetZz(any)
		any:=RTrim(any," `t`r`n")
		anyRun:=""
		if(getZz="" && !Candy_isFile){
			;[打开应用所在目录，只有目录则直接打开]
			if(menuholdkey=HoldKeyRun2 || M_ThisMenuItem="软件目录(&D)" || InStr(FileExist(any), "D")){
				WinGetClass,pclass,A
				if(pclass="#32770"){  ;打开/另存为窗口 变为跳转目录
					$FolderPath:=any
					if(RegExMatch(any,"iS).*?\.exe$")){
						SplitPath, any,, dir
						$FolderPath:=dir
					}
					Gosub,FeedExplorerOpenSave
					return
				}
				if(OpenFolderPathRun){
					anyRun=%anyRun%%OpenFolderPathRun%%A_Space%"%any%"
				}else if(InStr(FileExist(any), "D")){
					anyRun=%anyRun%%any%
				}else{
					anyRun.="explorer.exe /select," any
				}
				Run_Any(anyRun)
				return
			}
		}
		;判断软件运行方式
		Gosub,MenuRunWay
		;[带选中内容运行]
		if(getZz!="" && (getZzFlag || AutoGetZz)){
			firstFile:=RegExReplace(getZz,"S)(.*)(\n|\r).*","$1")  ;取第一行
			if(Candy_isFile=1 || FileExist(getZz) || FileExist(firstFile)){
				getZzStr:=""
				Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
				{
					if(!A_LoopField)
						continue
					getZzStr.="""" . A_LoopField . """" . A_Space
				}
				StringTrimRight, getZzStr, getZzStr, 1
				if(GetKeyState("Ctrl")){
					Gosub,Menu_Add_File_Item
					return
				}
				if(getZzFlag || InStr(FileExist(any), "D")){
					Run_Any(any,, way)
				}else{
					Run_Any(any . A_Space . getZzStr,, way)
				}
				if(topFlag || menuTransNum<100){
					Run_Wait(any, topFlag, menuTransNum)
				}
				return
			}
			if(getZzFlag){
				anyRun=%anyRun%%any%
			}else{
				anyRun=%anyRun%%any%%A_Space%%getZz%
			}
			Run_Any(anyRun,, way)
			if(topFlag || menuTransNum<100){
				Run_Wait(any, topFlag, menuTransNum)
			}
			return
		}
		Gosub, MenuRunAny
	} catch e {
		MsgBox,20,%Z_ThisMenuItem%运行出错,% "运行路径：" any "`n出错命令：" e.What
			. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message "`n`n是否在命令行中运行测试？"
		IfMsgBox Yes, {
			Run,%ComSpec% /k "echo 【运行命令:】start "" %any% & echo. & start "" %any%"
		}
	}finally{
		SetWorkingDir,%A_ScriptDir%
	}
return
;[软件运行方式]
MenuRunWay:
	menuKeys:=StrSplit(Z_ThisMenuItem,"`t")
	thisMenuName:=menuKeys[1]
	;[管理员身份运行]
	if((!RunCtrlRunFlag && (menuholdkey=HoldKeyRun11 || M_ThisMenuItem="管理员权限运行(&A)"))
		|| RunCtrlAdminRunVal || RegExMatch(thisMenuName,"S)^.*?\[#\](:[*?a-zA-Z0-9]+?:[^:]*)?(_:\d{1,2})?$")){
		anyRun.="*RunAs "
	}
	;[最小化、最大化、隐藏运行方式]
	if((!RunCtrlRunFlag && (menuholdkey=HoldKeyRun12 || M_ThisMenuItem="最小化运行(&I)")) || RunCtrlRunWayVal=3){
		way:="Min"
	}else if((!RunCtrlRunFlag && (menuholdkey=HoldKeyRun13 || M_ThisMenuItem="最大化运行(&P)")) || RunCtrlRunWayVal=4){
		way:="Max"
	}else if((!RunCtrlRunFlag && (menuholdkey=HoldKeyRun14 || M_ThisMenuItem="隐藏运行(&H)")) || RunCtrlRunWayVal=5){
		way:="Hide"
	}else{
		way:=""
	}
	;[透明运行方式]
	menuTransNum:=100
	if(thisMenuName && RegExMatch(thisMenuName,"S).*?_:(\d{1,2})$")){
		menuTransNum:=RegExReplace(thisMenuName,"S).*?_:(\d{1,2})$","$1")
	}else if(RegExMatch(M_ThisMenuItem,"S)^透明运行:&\d{1,2}%")){
		menuTransNum:=RegExReplace(M_ThisMenuItem,"S)^透明运行:&(\d{1,2})%$","$1")
	}
	;[置顶运行方式]
	topFlag:=false
	if((!RunCtrlRunFlag && M_ThisMenuItem="置顶运行(&T)") || RunCtrlRunWayVal=2){
		topFlag:=true
	}
	RunCtrlAdminRunVal:=false
	RunCtrlRunWayVal:=1
return
MenuRunAny:
	if(ext && openExtRunList[ext]){
		Run_Any(openExtRunList[ext] . A_Space . """" any """",, way)
	}else{
		Run_Any(anyRun . any,, way)
	}
	;运行后进行置顶或透明操作
	if(topFlag || menuTransNum<100){
		Run_Wait(any, topFlag, menuTransNum)
	}
return
;判断运行软件时按住的键
MenuRunHoldKey(){
	holdKey:=0
	if(GetKeyState("Ctrl"))
		holdKey:=2
	if(GetKeyState("Shift")){
		holdKey:=holdKey=2 ? 3 : 5
	}
	if(GetKeyState("LWin") || GetKeyState("RWin")){
		if(holdKey=2){
			holdKey:=4
		}else if(holdKey=5){
			holdKey:=6
		}else if(holdKey=3){
			holdKey:=7
		}
	}
	return holdKey
}
;右键菜单项显示多功能菜单
MenuRunMultifunctionMenu:
	menuRunSameSubFlag:=false
	Menu,menuRun,Add,运行(&R) %Z_ThisMenuItem%,MultifunctionMenu
	Menu,menuRun,Add,编辑(&E),MultifunctionMenu
	if itemMode not in 2,3,4,5,6,7,8
	{
		menuRunMultifunctionMenuStr:=menuRunNameStr
		for k, v in MenuObjSame
		{
			SplitPath, v, v_name
			vName:=RegExReplace(v_name,"iS)\.exe$")
			if(vName=Z_ThisMenuItem && v!=fullPath){
				MenuObj[v]:=v
				Menu,menuRunSameSub,Add, %k%, Menu_Run
				Menu_Item_Icon("menuRunSameSub",k,v)
				menuRunSameSubFlag:=true
			}
		}
		if(menuRunSameSubFlag)
			Menu,menuRun,Add,同名软件(&S), :menuRunSameSub
		Menu,menuRun,Add,软件目录(&D),MultifunctionMenu
		Menu,menuRun,Add
		Loop, 9
		{
			menuRunTransSubItem:="透明运行:&" A_Index*10 "%"
			Menu,menuRunTransSub,Add,%menuRunTransSubItem%, MultifunctionMenu
			Menu_Item_Icon("menuRunTransSub",menuRunTransSubItem,MenuObjIconList[Z_ThisMenuItem],MenuObjIconNoList[Z_ThisMenuItem])
		}
		Menu,menuRun,Add,透明运行(&Q), :menuRunTransSub
		Menu,menuRun,Add,置顶运行(&T),MultifunctionMenu
		;~ Menu,menuRun,Add,改变大小运行(&W), :menuRunWinSizeSub
		Menu,menuRun,Add,管理员权限运行(&A),MultifunctionMenu
		Menu,menuRun,Add,最小化运行(&I),MultifunctionMenu
		Menu,menuRun,Add,最大化运行(&P),MultifunctionMenu
		Menu,menuRun,Add,隐藏运行(&H),MultifunctionMenu
		Menu,menuRun,Add,结束软件进程(&X),MultifunctionMenu
	}else{
		menuRunMultifunctionMenuStr:=menuRunNameNoFileStr
	}
	Menu,menuRun,Add
	Menu,menuRun,Add,独立置顶显示(&T),MultifunctionMenu
	Menu,menuRun,Add,置顶所在的菜单(&Y),MultifunctionMenu
	Menu,menuRun,Add,复制菜单项名称(&Q),MultifunctionMenu
	Menu,menuRun,Add,复制运行路径(&C),MultifunctionMenu
	Menu,menuRun,Add,输出运行路径(&V),MultifunctionMenu
	Menu,menuRun,Add,复制软件名(&N),MultifunctionMenu
	Menu,menuRun,Add,输出软件名(&M),MultifunctionMenu
	Menu,menuRun,Add,复制软件名+后缀(&F),MultifunctionMenu
	Menu,menuRun,Add,输出软件名+后缀(&G),MultifunctionMenu
	Loop, Parse, menuRunMultifunctionMenuStr, `,
	{
		if(A_LoopField="同名软件(&S)" && !menuRunSameSubFlag)
			continue
		Menu_Item_Icon("menuRun",A_LoopField,MenuObjIconList[Z_ThisMenuItem],MenuObjIconNoList[Z_ThisMenuItem])
	}
	Menu,menuRun,Show
	Menu,menuRun,DeleteAll
return
MultifunctionMenu:
	M_ThisMenuItem:=A_ThisMenuItem
return
;══════════════════════════════════════════════════════════════════
;~;【菜单运行-热键】
;══════════════════════════════════════════════════════════════════
Menu_Key_Run:
	getZz:=Get_Zz()
	Gosub,Menu_Key_Run_Run
return
Menu_Key_NoGet_Run:
	getZz:=""
	Gosub,Menu_Key_Run_Run
return
Menu_Key_Run_Run:
	Gosub,Hide_HotStrGui
	any:=menuObjkey[(A_ThisHotkey)]
	thisMenuName:=MenuObjKeyName[(A_ThisHotkey)]
	SplitPath, any, , dir, ext
	if(dir && FileExist(dir))
		SetWorkingDir,%dir%
	try {
		itemMode:=Get_Menu_Item_Mode(any)

		MenuRunDebugModeShow(1)
		;[根据菜单项模式运行]
		returnFlag:=false
		Gosub,Menu_Run_Mode_Label
		if(returnFlag)
			return

		;[解析选中变量%getZz%]
		getZzFlag:=InStr(any,"%getZz%") ? true : false
		if(getZzFlag && InStr(getZz,A_Space) && !InStr(any,"""%getZz%""")){
			;如果选中变量中有空格，自动包上双引号
			any:=StrReplace(any,"%getZz%","""%getZz%""")
		}
		any:=Get_Transform_Val_GetZz(any)
		any:=RTrim(any," `t`r`n")
		;[打开文件夹]
		if(itemMode=7 && InStr(FileExist(any), "D")){
			WinGetClass,pclass,A
			if(pclass="#32770"){  ;打开/另存为窗口 变为跳转目录
				$FolderPath:=any
				Gosub,FeedExplorerOpenSave
			}else{
				Open_Folder_Path(any)
			}
			return
		}
		;[管理员身份运行]
		if(RegExMatch(thisMenuName,"S)^.*?\[#\](:[*?a-zA-Z0-9]+?:[^:]*)?(_:\d{1,2})?$")){
			any:="*RunAs " any
		}
		;[透明运行模式]
		menuTransNum:=100
		if(thisMenuName && RegExMatch(thisMenuName,"S).*?_:(\d{1,2})$")){
			menuTransNum:=RegExReplace(thisMenuName,"S).*?_:(\d{1,2})$","$1")
		}
		if(getZz!="" && (getZzFlag || AutoGetZz)){
			firstFile:=RegExReplace(getZz,"S)(.*)(\n|\r).*","$1")  ;取第一行
			if(getZzFlag){
				Run_Any(any)
			}else if(Candy_isFile=1 || FileExist(getZz) || FileExist(firstFile)){
				getZzStr:=""
				Loop, parse, getZz, `n, `r, %A_Space%%A_Tab%
				{
					if(!A_LoopField)
						continue
					getZzStr.="""" . A_LoopField . """" . A_Space
				}
				StringTrimRight, getZzStr, getZzStr, 1
				Run_Any(any . A_Space . getZzStr)
			}else{
				Run_Zz(any)
			}
		}else{
			if(ext && openExtRunList[ext]){
				Run_Any(openExtRunList[ext] . A_Space . """" any """")
			}else if(RegExMatch(any,"iS).*?\.[a-zA-Z0-9]+$")){
				Run_Zz(any)
			}else{
				Run_Any(any)
			}
		}
		if(menuTransNum<100){
			Run_Wait(any, false, menuTransNum)
		}
	} catch e {
		MsgBox,16,%thisMenuName%热键运行出错,% "运行路径：" any "`n出错命令：" e.What
			. "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}finally{
		SetWorkingDir,%A_ScriptDir%
	}
return
Menu_Run_Mode_Label:
	anyLen:=StrLen(any)
	if(itemMode=2){
		StringLeft, any, any, anyLen-1
		if(RegExMatch(any,"S).*\$$"))
			any:=SendStrDecrypt(any)
		Send_Str_Zz(any,true)  ;[粘贴输出短语]
		returnFlag:=true
	}else if(itemMode=3){
		StringLeft, any, any, anyLen-2
		if(RegExMatch(any,"S).*\$$"))
			any:=SendStrDecrypt(any)
		Send_Str_Input_Zz(any,true)  ;[键盘输出短语]
		returnFlag:=true
	}else if(itemMode=4){
		Gosub,Menu_Run_Send_Zz  ;[输出热键]
		returnFlag:=true
	}else if(itemMode=5){
		Gosub,Menu_Run_Send_Ahk_Zz  ;[输出AHK热键]
		returnFlag:=true
	}else if(itemMode=8){
		Gosub,Menu_Run_Plugins_ObjReg  ;{脚本插件函数}
		returnFlag:=true
	}else if(itemMode=60){
		Gosub,Menu_Run_Exe_Url  ;指定浏览器打开网页
		returnFlag:=true
	}else if(itemMode=6){
		Run_Search(any,getZz)  ;网页
		returnFlag:=true
	}
return
Menu_Run_Send_Zz:
	StringLeft, any, any, anyLen-2
	Send_Key_Zz(any)
return
Menu_Run_Send_Ahk_Zz:
	StringLeft, any, any, anyLen-3
	Send_Key_Zz(any,1)
return
Menu_Run_Exe_Url:
	BrowserPath:=RegExReplace(any,"iS)(.*?\.exe) .*","$1")	;只去参数
	anyUrl:=RegExReplace(any,"iS).*?\.exe (.*)","$1")	;去掉应用名，取参数
	Run_Search(anyUrl,getZz,BrowserPath)
return
;菜单运行时显示的调试信息
MenuRunDebugModeShow(key:=0){
	if(DebugMode){
		if(getZz!=""){
			Menu_Debug_Mode("===选中内容===`n")
			Menu_Debug_Mode(getZz "`n")
		}
		if(Candy_isFile)
			Menu_Debug_Mode("选中内容类型：文件" "`n")
		if(key){
			Menu_Debug_Mode("全局热键：" A_ThisHotkey "`n")
		}else if(GetKeyState("Ctrl") || GetKeyState("Shift") || GetKeyState("Alt")
			|| GetKeyState("LWin") || GetKeyState("RWin")){
			Menu_Debug_Mode("按下按键：")
			if(GetKeyState("Ctrl"))
				Menu_Debug_Mode(" Ctrl键")
			if(GetKeyState("Shift"))
				Menu_Debug_Mode(" Shift键")
			if(GetKeyState("Alt"))
				Menu_Debug_Mode(" Alt键")
			if(GetKeyState("LWin"))
				Menu_Debug_Mode(" 左Win键")
			if(GetKeyState("RWin"))
				Menu_Debug_Mode(" 右Win键")
			Menu_Debug_Mode("`n")
		}
	}
}
Run_Any(any,dir:="",way:=""){
	Menu_Debug_Mode("[运行路径]`n" any "`n")
	if(MenuIconFlag){
		Menu_Run_Tray_Tip(any "`n")
	}
	if(dir!="" || way!=""){
		Run,%any%,%dir%,%way%
	}else{
		Run,%any%
	}
}
Run_Zz(program){
	fullPath:=Get_Obj_Path(program)
	exePath:=fullPath ? fullPath : program
	SplitPath, exePath, exeName
	exeName:=exeName ? exeName : exePath
	DetectHiddenWindows, Off
	If(!WinExist("ahk_exe" . exeName)){
		Run_Any(program)
		return true
	}else{
		WinGet,l,List,ahk_exe %exeName%
		if(l=1)
			If WinActive("ahk_exe" . exeName)
				WinMinimize
			else
				WinActivate
		else
			WinActivateBottom,ahk_exe %exeName%
		return false
	}
}
Run_Wait(program,topFlag:=false,transRatio=100,winSizeRatio=100,winSize=0){
	fullPath:=Get_Obj_Path(program)
	exePath:=fullPath ? fullPath : program
	transRatio:=transRatio<0 ? 0 : transRatio
	DetectHiddenWindows, Off
	if(fExt="lnk"){
		FileGetShortcut,%exePath%,lnkexePath
		SplitPath, lnkexePath, fName,, fExt
		if(fExt="exe")
			exePath:=lnkexePath
	}
	SplitPath, exePath, fName,, fExt  ; 获取应用名
	WinWait,ahk_exe %fName%,,3
	if ErrorLevel
		return
	if(topFlag){
		if(WinActive("ahk_class CabinetWClass")){
			WinSet,AlwaysOnTop,On,ahk_class CabinetWClass
		}else{
			WinSet,AlwaysOnTop,On,ahk_exe %fName%
		}
	}
	if(transRatio<100){
		try WinSet,Transparent,% transRatio/100*255,ahk_exe %fName%
	}
}
;~;【🧩脚本插件函数运行】
Menu_Run_Plugins_ObjReg:
	appPlugins:=RegExReplace(any,"iS)(.+?)\[.+?\]%?\(.*?\)$","$1")	;取插件名
	appFunc:=RegExReplace(any,"iS).+?\[(.+?)\]%?\(.*?\)$","$1")	;取函数名
	appParmStr:=RegExReplace(any,"iS).+?\[.+?\]%?\((.*?)\)$","$1")	;取函数参数
	appParmErrorStr:=(appParmStr="") ? "空" : appParmStr
	if(!PluginsObjRegGUID[appPlugins] && appPlugins!="runany"){
		ToolTip,❎`n脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr%`n插件%appPlugins%没有找到！`n【请检查修改后重启RunAny重试】
		SetTimer,RemoveToolTip,8000
		return
	}
	if(RegExMatch(any,"iS).+?\[.+?\]%\(.*?\)")){  ;动态函数执行
		DynaExpr_ObjRegisterActive(PluginsObjRegGUID[appPlugins],appFunc,appParmStr,getZz)
	}else{
		if(appPlugins!="runany"){
			try {
				PluginsObjRegActive[appPlugins]:=ComObjActive(PluginsObjRegGUID[appPlugins])
			} catch e{
				TrayTip,%appPlugins% 外接脚本失败,请检查是否已经启动(在插件管理中设为自动启动)，并重启RunAny重试,5,2
			}
		}else if(!IsFunc(appFunc)){
			TrayTip,,没有在%appPlugins%.ahk中找到%appFunc%函数,5,2
		}
		appParmStr:=StrReplace(appParmStr,"``,",Chr(3))
		appParms:=StrSplit(appParmStr,",")
		Loop,% appParms.MaxIndex()
		{
			appParms[A_Index]:=StrReplace(appParms[A_Index],Chr(3),",")
			if(RegExMatch(appParms[A_Index],"iS)%""(.+?)""%")){	;无路径应用变量
				appNoPath:=RegExReplace(appParms[A_Index],"iS)%""(.+?)""%","$1")
				appNoPathName:=RegExReplace(appNoPath,"iS)\.exe($| .*)")	;去掉后缀或参数，取应用名
				appNoPathGetTfVal:=Get_Transform_Val("%" appNoPath "%")
				if(appNoPathGetTfVal="%" appNoPath "%"){	;识别为系统自带软件
					appParms[A_Index]:=RegExReplace(appParms[A_Index],"iS)%"".+?""%",appNoPath)
				}else{
					appParms[A_Index]:=appNoPathGetTfVal	;识别为自定义变量软件路径
				}
				if(MenuObj[appNoPathName]){
					SplitPath,% MenuObj[appNoPathName],,, FileExt  ; 获取文件扩展名.
					appNoPathParm:=RegExReplace(appNoPath,"iS).*?\." FileExt "($| .*)","$1")	;去掉应用名，取参数
					appParms[A_Index]:=MenuObj[appNoPathName] . appNoPathParm
				}
			}
			appParms[A_Index]:=Get_Transform_Val(appParms[A_Index])
		}
		if(appPlugins="runany"){
			if(appParmStr=""){
				Send_Or_Show(Func(appFunc).Call(),false)
			}else if(appParms.MaxIndex()>=1 && appParms.MaxIndex()<=10){
				Send_Or_Show(Func(appFunc).Call(appParms*),false)
			}else if(appParms.MaxIndex()>10){
				ToolTip,❎`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr% 参数数量最多为10个，请修改后重试！
				SetTimer,RemoveToolTip,8000
			}
			return
		}
		PluginsObjRegRun(appPlugins, appFunc, appParms)
	}
	if(!InStr(PluginsContentList[(appPlugins ".ahk")],appFunc "(")){
		ToolTip,❎`n脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr%`n
		(
函数%appFunc%没有找到！`n【请检查插件脚本是否已更新版本，或修改错误后重启RunAny重试】
		)
		SetTimer,RemoveToolTip,1000
	}
return
PluginsObjRegRun(appPlugins, appFunc, appParms){
	if(appParms.Length()=0){	;没有传参，直接执行函数
		effectResult:=PluginsObjRegActive[appPlugins][appFunc]()
	}else if(appParms.MaxIndex()>=1 && appParms.MaxIndex()<=10){
		effectResult:=PluginsObjRegActive[appPlugins][appFunc](appParms*)
	}else if(appParms.MaxIndex()>10){
		ToolTip,❎`n脚本插件：%appPlugins%`n脚本函数：%appFunc%`n函数参数：%appParmErrorStr% 参数数量最多为10个，请修改后重试！
		SetTimer,RemoveToolTip,8000
	}
	return effectResult
}
;~;【🕒菜单最近运行】
Menu_Recent:
	recentAny:=any
	regMenuItem:=A_ThisMenuItem
	;正则转义特殊字符
	regMenuItem:=StrListEscapeReplace(regMenuItem, RegexEscapeList, "\")
	Loop,% MenuCommonList.MaxIndex()
	{
		if(RegExMatch(MenuCommonList[A_Index],"S)^&\d+\s" regMenuItem)){
			return
		}
	}
	Loop,% MenuCommonList.MaxIndex()
	{
		C_Index:=A_Index
		try{
			Loop,%MenuCount%
			{
				Menu,% menuDefaultRoot%A_Index%[1],Delete,% MenuCommonList[C_Index]
				Menu,% menuWebRoot%A_Index%[1],Delete,% MenuCommonList[C_Index]
				Menu,% menuFileRoot%A_Index%[1],Delete,% MenuCommonList[C_Index]
			}
		}catch{}
	}
regMenuItem:=RegExReplace(A_ThisMenuItem,"iS)^运行\(&R\) ")
if(regMenuItem="")
return
;插入到最近运行第一条
MenuCommonList.InsertAt(1,"&1" A_Space regMenuItem)
MenuCommonNewList:=[]
MenuCommonNewList.InsertAt(1,"&1" A_Space regMenuItem)

Loop,% MenuCommonList.MaxIndex()
{
	try{
		if(A_Index<=RecentMax){
			if(A_Index>1){
				recentAny:=MenuObj[MenuCommonList[A_Index]]  ;获取原顺序下运行路径
				MenuCommonNewList[A_Index]:=RegExReplace(MenuCommonList[A_Index],"^&\d+","&" A_Index)  ;修改序号
			}
			menuItem:=MenuCommonNewList[A_Index]
			MenuObj[menuItem]:=recentAny
			fullPath:=Get_Obj_Path(recentAny)
			SplitPath,fullpath, , , recentExt
			Loop,%MenuCount%
			{
				Menu,% menuDefaultRoot%A_Index%[1],Add,%menuItem%,Menu_Run
				Menu,% menuWebRoot%A_Index%[1],Add,%menuItem%,Menu_Run
				Menu,% menuFileRoot%A_Index%[1],Add,%menuItem%,Menu_Run
				;更改图标
				if(recentExt="exe"){
					Menu_Item_Icon(menuDefaultRoot%A_Index%[1],menuItem,fullpath)
					Menu_Item_Icon(menuWebRoot%A_Index%[1],menuItem,fullpath)
					Menu_Item_Icon(menuFileRoot%A_Index%[1],menuItem,fullpath)
				}else{
					recentItemMode:=Get_Menu_Item_Mode(recentAny)
					Menu_Add(menuDefaultRoot%A_Index%[1],menuItem,recentAny,recentItemMode,"")
					Menu_Add(menuWebRoot%A_Index%[1],menuItem,recentAny,recentItemMode,"")
					Menu_Add(menuFileRoot%A_Index%[1],menuItem,recentAny,recentItemMode,"")
				}
			}
		}
	}catch{}
}
;保存菜单最近运行项至注册表，重启后加载
commonStr:=""
MenuCommonList:=MenuCommonNewList.Clone()
For k, v in MenuCommonList
{
	commonStr:=commonStr ? commonStr "|" v : v
}
RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, MenuCommonList, %commonStr%
return
