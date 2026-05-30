;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【——🔛配置初始化——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Config_Set:
	;#判断配置文件
	if(!FileExist(RunAnyConfig)){
		IniWrite,%IniConfig%,%RunAnyConfig%,Config,IniConfig
	}
	;[RunAny设置参数]
	global Z_ScriptName:=FileExist(RunAnyZz ".exe") ? RunAnyZz ".exe" : A_ScriptName
	RegRead, AutoRun, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, RunAny
	AutoRun:=AutoRun=A_ScriptDir "\" Z_ScriptName ? 1 : 0
	global AdminRun:=Var_Read("AdminRun",0)
	;#判断管理员权限#
	if(AdminRun && !A_IsAdmin){
		adminahkpath:=""
		if(!A_IsCompiled)
			adminahkpath:=A_AhkPath A_Space
		Run *RunAs %adminahkpath%"%A_ScriptFullPath%"
		ExitApp
	}
	global getZz:=""
	global OutsideMenuItem:=""
	global MENU_NO:=1
	global RegexEscapeStr:="\\|\.|\*|\?|\+|\[|\{|\||\(|\)|\^|\$"
	global RegexEscapeNoPointStr:="\\|\*|\?|\+|\[|\{|\||\(|\)|\^|\$"
	global RegexEscapeList:=StrSplit("\.*?+[{|()^$")
	global RegexEscapeNoPointList:=StrSplit("\*?+[{|()^$")
	global HideMenuTrayIcon:=Var_Read("HideMenuTrayIcon",0)
	if(HideMenuTrayIcon)
		Menu, Tray, NoIcon
	global AdminMode:=A_IsAdmin ? "【管理员】" : ""
	global MenuTrayTipText:=RunAnyZz . AdminMode "`n"
	global AutoReloadMTime:=Var_Read("AutoReloadMTime",2500)
	global ConfigDate:=Var_Read("ConfigDate")
	global RunABackupDir:=Var_Read("RunABackupDir","`%A_ScriptDir`%\RunBackup")
	global RunABackupRule:=Var_Read("RunABackupRule",1)
	global RunABackupMax:=Var_Read("RunABackupMax",15)
	global RunABackupFormat:=Var_Read("RunABackupFormat",".`%A_Now`%.bak")
	global HideFail:=Var_Read("HideFail",1)
	global HideWeb:=Var_Read("HideWeb",0)
	global HideGetZz:=Var_Read("HideGetZz",0)
	global HideSend:=Var_Read("HideSend",0)
	global HideAddItem:=Var_Read("HideAddItem",0)
	global HideMenuTray:=Var_Read("HideMenuTray",0)
	global HideSelectZz:=Var_Read("HideSelectZz",0)
	global RecentMax:=Var_Read("RecentMax",3)
	DisableApp:=Var_Read("DisableApp","vmware-vmx.exe,TeamViewer.exe,SunloginClient.exe,War3.exe,dota2.exe,League of Legends.exe")
	Loop,parse,DisableApp,`,
	{
		GroupAdd,DisableGUI,ahk_exe %A_LoopField%
	}
	;[热键配置]
	global MenuDoubleCtrlKey:=Var_Read("MenuDoubleCtrlKey",0)
	global MenuDoubleAltKey:=Var_Read("MenuDoubleAltKey",0)
	global MenuDoubleLWinKey:=Var_Read("MenuDoubleLWinKey",0)
	global MenuDoubleRWinKey:=Var_Read("MenuDoubleRWinKey",0)
	global MenuMButtonKey:=Var_Read("MenuMButtonKey",0)
	global MenuCtrlRightKey:=Var_Read("MenuCtrlRightKey",0)
	global MenuShiftRightKey:=Var_Read("MenuShiftRightKey",0)
	global MenuXButton1Key:=Var_Read("MenuXButton1Key",0)
	global MenuXButton2Key:=Var_Read("MenuXButton2Key",0)
	global MenuMButtonKey:=Var_Read("MenuMButtonKey",0)
	;[一键直达]
	global BrowserPath:=Var_Read("BrowserPath")
	global OneKeyRun:={"一键公式计算":""
		,"一键打开文件":"runany[Run_Any](%getZz%)"
		,"一键打开目录":"runany[Open_Folder_Path](%getZz%)"
		,"一键打开网址":"runany[Run_Search](%getZz%)"
		,"一键磁力链接":"runany[Run_Any](%getZz%)"}
	if(BrowserPath!=""){
		OneKeyRun["一键打开网址"]:=BrowserPath " ""%getZz%"""
	}
	global OneKeyRegex:={"一键公式计算":"S)^[\(\)\.\s\d]*\d+\s*[+*/-]+[\(\)\.+*/-\d\s]+($|=$)"
		,"一键打开文件":"S)^(\\\\|.:\\).*?\..+"
		,"一键打开目录":"S)^(\\\\|.:\\)"
		,"一键打开网址":"iS)^([\w-]+:\/\/?|www[.]).*"
		,"一键磁力链接":"iS)^magnet:\?xt=urn:btih:.*"}
	global OneKeyRegexList:={}
	global OneKeyRegexMultilineList:={}
	global OneKeyRunList:={}
	global OneKeyDisableList:={}
	global OneKeyDisableStr:=Var_Read("OneKeyDisableList")
	Loop, parse, OneKeyDisableStr, |
	{
		OneKeyDisableList[A_LoopField]:=true
	}
	IniRead,OneKeyVar,%RunAnyConfig%,OneKey
	if(!OneKeyVar){
		OneKeyRunList:=OneKeyRun
		OneKeyRegexList:=OneKeyRegex
	}
	Loop, parse, OneKeyVar, `n, `r
	{
		R_LoopField=%A_LoopField%
		if(R_LoopField="")
			continue
		varList:=StrSplit(R_LoopField,"=",,2)
		if(varList[1]="")
			continue
		if(RegExMatch(varList[1],".+_Run$")){
			OneKeyRunList[RegExReplace(varList[1],"(.+)_Run$","$1")]:=varList[2]
		}else if(RegExMatch(varList[1],".+_Regex$")){
			name:=RegExReplace(varList[1],"(.+)_Regex$","$1")
			OneKeyRegexList[name]:=varList[2]
			if(RegExMatch(varList[2],"m)^[^(]*?m.*?\).*")){
				OneKeyRegexMultilineList[name]:=varList[2]
			}
		}
	}
	global OneKeyMenu:=Var_Read("OneKeyMenu",0)
	global OneKeyUrl:=Var_Read("OneKeyUrl","https://www.baidu.com/s?wd=%s")
	OneKeyUrl:=StrReplace(OneKeyUrl, "|", "`n")
	;[搜索Everything]
	global EvPath:=Var_Read("EvPath")
	global EvShowExt:=Var_Read("EvShowExt",1)
	global EvShowFolder:=Var_Read("EvShowFolder",1)
	global EvAutoClose:=Var_Read("EvAutoClose",0)
	global EvExeVerNew:=Var_Read("EvExeVerNew",1)
	global EvExeMTimeNew:=Var_Read("EvExeMTimeNew",1)
	global EvDemandSearch:=Var_Read("EvDemandSearch",1)
	EvCommandDefault:="!" A_WinDir "* !?:\$RECYCLE.BIN* !?:\Users\*\AppData\Local\Temp\* !?:\Users\*\AppData\Roaming\*.exe"
	try EnvGet, scoopPath, scoop
	if(scoopPath)
		EvCommandDefault.=" !" RegExReplace(scoopPath,".(:\\.*)","?$1") "\shims\*"
	global EvCommand:=Var_Read("EvCommand",EvDemandSearch ? EvCommandDefault : EvCommandDefault " file:*.exe|*.lnk|*.ahk|*.bat|*.cmd")
	EvCommandVar:=RegExReplace(EvCommand,"i).*file:(\*\.[^\s]*).*","$1")
	global EvCommandExtList:=StrSplit(EvCommandVar,"|")
	;[热字符串]
	global HideHotStr:=Var_Read("HideHotStr",0)
	global HotStrHintLen:=Var_Read("HotStrHintLen",3)
	global HotStrShowLen:=Var_Read("HotStrShowLen",30)
	global HotStrShowTime:=Var_Read("HotStrShowTime",3000)
	global HotStrShowTransparent:=Var_Read("HotStrShowTransparent",80)
	global HotStrShowX:=Var_Read("HotStrShowX",0)
	global HotStrShowY:=Var_Read("HotStrShowY",0)
	global SendStrEcKey:=Var_Read("SendStrEcKey")
	global SendStrDcKey:=Var_Read("SendStrDcKey")
	;[高级配置]开始
	global ShowGetZzLen:=Var_Read("ShowGetZzLen",30)
	global DebugMode:=Var_Read("DebugMode",0)
	global DebugModeShowTime:=Var_Read("DebugModeShowTime",8000)
	global DebugModeShowTrans:=Var_Read("DebugModeShowTrans",70)
	global DebugModeShowText:=""
	global DebugModeShowTextLen:=0
	global EvNo:=Var_Read("EvNo",0)
	global JumpSearch:=Var_Read("JumpSearch",0)
	global AutoGetZz:=Var_Read("AutoGetZz",1)
	global GetZzCopyKey:=Var_Read("GetZzCopyKey","^{Insert}")
	global GetZzCopyKeyApp:=Var_Read("GetZzCopyKeyApp","cmd.exe,powershell.exe")
	Loop,parse,GetZzCopyKeyApp,`,
	{
		GroupAdd,GetZzCopyKeyAppGUI,ahk_exe %A_LoopField%
	}
	global GetZzTransformVal:=Var_Read("GetZzTransformVal",0)
	global DisableExeIcon:=Var_Read("DisableExeIcon",0)
	global RunAEncoding:=Var_Read("RunAEncoding",A_Language!=0804 ? "UTF-8" : "")
	global ClipWaitTime:=Var_Read("ClipWaitTime",0.5)
	global ClipWaitApp:=Var_Read("ClipWaitApp","totalcmd64.exe,TotalCMD64.exe,dopus.exe,explorer.exe")
	global HoldKeyShowTime:=Var_Read("HoldKeyShowTime",1000)
	global RUNANY_SELF_MENU_ITEM1:=Var_Read("RUNANY_SELF_MENU_ITEM1","&1批量搜索")
	global RUNANY_SELF_MENU_ITEM2:=Var_Read("RUNANY_SELF_MENU_ITEM2","RunAny设置")
	global RUNANY_SELF_MENU_ITEM3:=Var_Read("RUNANY_SELF_MENU_ITEM3","0【添加到此菜单】")
	global RUNANY_SELF_MENU_ITEM4:=Var_Read("RUNANY_SELF_MENU_ITEM4","-【显示全部菜单】")
	global RunAnyMenuTransparent:=Var_Read("RunAnyMenuTransparent",225)
	global RunAnyMenuSpaceRun:=Var_Read("RunAnyMenuSpaceRun",2)
	global RunAnyMenuRButtonRun:=Var_Read("RunAnyMenuRButtonRun",3)
	global RunAnyMenuMButtonRun:=Var_Read("RunAnyMenuMButtonRun",0)
	global RunAnyMenuXButton1Run:=Var_Read("RunAnyMenuXButton1Run",0)
	global RunAnyMenuXButton2Run:=Var_Read("RunAnyMenuXButton2Run",0)
	global HoldKeyList:={"HoldCtrlRun":2,"HoldCtrlShiftRun":3,"HoldCtrlWinRun":4,"HoldShiftRun":5,"HoldShiftWinRun":6,"HoldCtrlShiftWinRun":7}
	global HoldKeyValList:={"HoldCtrlRun":2,"HoldCtrlShiftRun":3,"HoldCtrlWinRun":11,"HoldShiftRun":5,"HoldShiftWinRun":31,"HoldCtrlShiftWinRun":4}
	for k, v in HoldKeyList
	{
		%k%:=Var_Read(k,HoldKeyValList[k])
		j:=%k%
		if(j){
			HoldKeyRun%j%:=v
		}
	}
	;[高级配置]结束
	global MENU_RUN_NAME_STR:="编辑(&E),同名软件(&S),软件目录(&D),透明运行(&Q),置顶运行(&T),改变大小运行(&W),管理员权限运行(&A)"
		. ",最小化运行(&I),最大化运行(&P),隐藏运行(&H),结束软件进程(&X)"
	global MENU_RUN_NAME_NOFILE_STR:="复制运行路径(&C),输出运行路径(&V),复制软件名(&N),输出软件名(&M),复制软件名+后缀(&F),输出软件名+后缀(&G),复制菜单项名称(&Q),置顶所在的菜单(&Y),独立置顶显示(&T)"
	MENU_RUN_NAME_STR.="," MENU_RUN_NAME_NOFILE_STR
	MENU_RUN_NAME_NOFILE_STR:="编辑(&E)," MENU_RUN_NAME_NOFILE_STR
	Loop, 9
	{
		MENU_RUN_NAME_STR.=",透明运行:&" A_Index*10 "%"
	}
	;~[最近运行项]
	if(RecentMax>0){
		global MenuCommonList:={}
		RegRead, MenuCommonListReg, HKEY_CURRENT_USER\Software\RunAny, MenuCommonList
		if(MenuCommonListReg){
			Loop, parse, MenuCommonListReg, |
			{
				R_ThisMenuItem:=RegExReplace(A_LoopField,"^&\d+ ","")
				if R_ThisMenuItem not in %MENU_RUN_NAME_STR%
				{
					MenuCommonList.Push(A_LoopField)
				}
			}
		}
	}
	OnExit("ExitFunc")
	OnMessage(0x004A, "Receive_WM_COPYDATA")
	OnMessage(0x11, "WM_QUERYENDSESSION")
	;~[定期自动检查更新]
	global giteeUrl:="https://gitee.com"
	global githubUrl:="https://raw.githubusercontent.com"
	global RunAnyGiteePages:="https://hui-zz.gitee.io"
	global RunAnyGithubPages:="https://hui-zz.github.io"
	global RunAnyGiteeDir:="/hui-Zz/RunAny/raw/master"
	global RunAnyGithubDir:="/hui-Zz/RunAny/master"
	global RunAnyDownDir:=giteeUrl . RunAnyGiteeDir ; 初始使用gitee地址
	/*	;20250317逍遥注释避免自动更新
		if(A_DD=01 || A_DD=15){
			;当天已经检查过就不再更新
			if(FileExist(A_Temp "\temp_RunAny.ahk")){
				FileGetTime,tempMTime, %A_Temp%\temp_RunAny.ahk, M  ; 获取修改时间.
				t1 := A_Now
				t1 -= %tempMTime%, Days
				FormatTime,tempTimeDD,%tempMTime%,dd
				if(t1=0 && (tempTimeDD=01 || tempTimeDD=15))
					return
				Gosub,Old_Config_Clear
			}
			Gosub,Auto_Update
		}
	*/
return
Old_Config_Clear:
	EvCommandDefaultOld1:="!" A_WinDir "* !?:\$RECYCLE.BIN* !?:\Users\*\AppData\Local\Temp\* !?:\Users\*\AppData\Roaming\*"
	try EnvGet, scoopPath, scoop
	if(scoopPath)
		EvCommandDefaultOld1.=" !" RegExReplace(scoopPath,".(:\\.*)","?$1") "\shims\*"
	EvCommand_Old1:=EvDemandSearch ? EvCommandDefaultOld1 : EvCommandDefaultOld1 " file:*.exe|*.lnk|*.ahk|*.bat|*.cmd"
	IniRead,readVar,%RunAnyConfig%,Config,EvCommand,A_Space
	if(readVar!=""){
		if(readVar=EvCommand_Old1){
			IniDelete,%RunAnyConfig%,Config,EvCommand
		}
	}
return
;~;【菜单自定义变量】
Menu_Var_Set:
	global MenuVarIniList:={}
	global MenuVarTypeList:={}
	IniRead,menuVarVar,%RunAnyConfig%,MenuVar
	SplitPath, A_ScriptDir,,,,,A_ScriptDrive
	if(!menuVarVar){
		menuVarVar:="A_Desktop`nA_MyDocuments`nA_ScriptDir`nA_ScriptDrive`n"
		menuVarVar.="AppData`nComputerName`nComSpec`nLocalAppData`nOneDrive`nProgramFiles`n"
		if(A_Is64bitOS)
			menuVarVar.="ProgramW6432`n"
		menuVarVar.="UserName`nUserProfile`nWinDir"
	}
	Loop, parse, menuVarVar, `n, `r
	{
		if(A_LoopField="")
			continue
		itemList:=StrSplit(A_LoopField,"=",,2)
		menuVarName:=itemList[1]
		menuVarVal:=itemList[2]
		if(%menuVarName%){
			MenuVarIniList[itemList[1]]:=%menuVarName%
			MenuVarTypeList[menuVarName]:=1
		}else{
			try EnvGet, %menuVarName%, %menuVarName%
			if(%menuVarName%){
				MenuVarIniList[itemList[1]]:=%menuVarName%
				MenuVarTypeList[menuVarName]:=2
			}else{
				%menuVarName%:=menuVarVal
				MenuVarTypeList[menuVarName]:=3
				MenuVarIniList[itemList[1]]:=itemList[2]
			}
		}
	}
return
;~;【内部关联后缀打开方式】
Open_Ext_Set:
	;支持一键直达浏览器无路径识别
	global BrowserPathRun:=Get_Obj_Path_Transform(BrowserPath)
	global openExtIniList:={}
	global openExtRunList:={}
	ClipWaitAppStr:=""
	IniRead,openExtVar,%RunAnyConfig%,OpenExt
	Loop, parse, openExtVar, `n, `r
	{
		itemList:=StrSplit(A_LoopField,"=",,2)
		openExtIniList[itemList[1]]:=itemList[2]
		Loop, parse,% itemList[2], %A_Space%
		{
			extLoopField:=RegExReplace(A_LoopField,"^\.","")
			openExtRunList[extLoopField]:=Get_Obj_Path_Transform(itemList[1])
		}
		if(InStr(itemList[1],"dopus.exe") || MenuObjEv["dopus"])
			ClipWaitAppStr:=StrJoin(",",ClipWaitAppStr,"dopus.exe")
		if(InStr(itemList[1],"xyplorer.exe") || MenuObjEv["xyplorer"])
			ClipWaitAppStr:=StrJoin(",",ClipWaitAppStr,"xyplorer.exe")
		if(InStr(itemList[1],"totalcmd.exe") || MenuObjEv["totalcmd"])
			ClipWaitAppStr:=StrJoin(",",ClipWaitAppStr,"totalcmd.exe")
		if(InStr(itemList[1],"TotalCMD64.exe") || MenuObjEv["TotalCMD64"])
			ClipWaitAppStr:=StrJoin(",",ClipWaitAppStr,"totalcmd64.exe")
	}
	; 解决指定软件界面剪贴板等待时间过短获取不到选中内容
	Sort, ClipWaitAppStr ,U D,
	if(ClipWaitAppStr!=""){
		ClipWaitTime:=Var_Read("ClipWaitTime", 1.2)
		ClipWaitApp:=Var_Read("ClipWaitApp", ClipWaitAppStr)
	}
	Loop,parse,ClipWaitApp,`,
	{
		GroupAdd,ClipWaitGUI,ahk_exe %A_LoopField%
	}
	if(!openExtRunList["folder"]){
		TcPath:=Var_Read("TcPath")
		if(TcPath){
			openExtName:="folder"
			if(openExtIniList[TcPath]){ ; 如果已存在旧打开方式，则加在末尾
				openExtName:=openExtIniList[TcPath] A_Space "folder"
			}
			IniWrite,%openExtName%,%RunAnyConfig%,OpenExt,%TcPath%
			openExtRunList["folder"]:=Get_Obj_Path_Transform(TcPath)
			openExtIniList[TcPath]:=openExtName
			IniDelete,%RunAnyConfig%,Config,TcPath
		}
	}
	global OpenFolderPathRun:=openExtRunList["folder"]
return
;~;【调用环境判断】
Run_Exist:
	;#判断菜单配置文件初始化#
	global iniFile:=iniPath
	global iniVar1:=""
	global both:=1
	global RunABackupDirPath:=Get_Transform_Val(RunABackupDir)
	global RunAEvFullPathIniDir:=Var_Read("RunAEvFullPathIniDir","`%AppData`%\" RunAnyZz)
	global RunAEvFullPathIniDirPath:=Get_Transform_Val(RunAEvFullPathIniDir)
	global RunAnyEvFullPathIni:=RunAEvFullPathIniDirPath "\RunAnyEvFullPath.ini"
	CreateDir(A_ScriptDir "\" PluginsDir "\" Lib)
	CreateDir(A_AppData "\" RunAnyZz)
	CreateDir(RunABackupDirPath "\" RunAnyConfig)
	CreateDir(RunAEvFullPathIniDirPath)
	CreateDir(A_Temp "\" RunAnyZz)
	FileRead, evFullPathIniVar, %RunAnyEvFullPathIni%
	evFullPathIniVar:=StrReplace(evFullPathIniVar, "[FullPath]`r`n", "")
	if(RunAEncoding){
		try{
			FileEncoding,%RunAEncoding%
		}catch e {
			MsgBox,16,文件编码出错,% "请设置正确的编码读取RunAny.ini!`n参考：https://wyagd001.github.io/zh-cn/docs/commands/FileEncoding.htm"
				. "`n`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
		}
	}
	FileGetSize,iniFileSize,%iniFile%
	If(!FileExist(iniFile) || iniFileSize=0){
		TrayTip,,RunAny初始化中...,2,17
		SetTimer, HideTrayTip, -2000
		Gosub,First_Run
	}
	FileRead, iniVar1, %iniPath%
	;#判断第2菜单ini#
	global MENU2FLAG:=false
	IfExist,%iniPath2%
	{
		global iniVar2:=""
		MENU2FLAG:=true
		FileRead, iniVar2, %iniPath2%
		CreateDir(RunABackupDirPath "\" RunAnyZz "2.ini")
	}
	global iniFileVar:=iniVar1
	global EvPathRun:=Get_Transform_Val(EvPath)
	;#判断Everything拓展DLL文件#
	if(!EvNo){
		Gosub,Ev_Exist
		;~Everything搜索检查准备
		global RunAnyTickCount:=0
		RegRead,RunAnyTickCount,HKEY_CURRENT_USER\SOFTWARE\RunAny,RunAnyTickCount
		if(!RunAnyTickCount || A_TickCount<RunAnyTickCount){
			RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults,0
		}
	}
return
Ev_Exist:
	global everyDLL:="Everything.dll"
	if(FileExist(A_ScriptDir "\Everything.dll")){
		everyDLL:=DllCall("LoadLibrary", str, "Everything.dll") ? "Everything.dll" : "Everything64.dll"
	}else if(FileExist(A_ScriptDir "\Everything64.dll")){
		everyDLL:=DllCall("LoadLibrary", str, "Everything64.dll") ? "Everything64.dll" : "Everything.dll"
	}
	if(!FileExist(A_ScriptDir "\" everyDLL)){
		MsgBox,17,,没有找到%everyDLL%，将不能识别菜单中程序的路径`n需要将%everyDLL%放到【%A_ScriptDir%】目录下`n是否需要从网上下载%everyDLL%？
		IfMsgBox Ok
		{
			URLDownloadToFile(RunAnyDownDir "/" everyDLL,A_ScriptDir "\" everyDLL)
			Gosub,Menu_Reload
		}else{
			MsgBox,17,【慎改】,是否需要开启不使用Everything模式？所有无路径应用可以通过手动新增修改同步来识别运行路径。`n`n（也可在高级配置中修改）
			IfMsgBox Ok
			{
				Var_Set(1,EvNo,"EvNo")
				EvNo:=1
			}
		}
	}
return
