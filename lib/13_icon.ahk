;~;【——⭕️图标初始化——】
Icon_Set:
	Menu,exeTestMenu,add,donothing	;只用于测试应用图标正常添加
	global RunIconDir:=A_ScriptDir "\RunIcon"
	global WebIconDir:=RunIconDir "\WebIcon"
	global ExeIconDir:=RunIconDir "\ExeIcon"
	global MenuIconDir:=RunIconDir "\MenuIcon"
	IconDirs:="ExeIcon,WebIcon,MenuIcon"
	Loop, Parse, IconDirs, `,
	{
		CreateDir(RunIconDir "\" A_LoopField)
	}
	global IconFileSuffix:="*.ico;*.bmp;*.png;*.gif;*.jpg;*.jpeg;*.jpe;*.jfif;*.dib;*.tif;*.tiff;*.heic"
		. ";*.cur;*.ani;*.cpl;*.scr;"
	global ResourcesExtractExist:=false
	global ResourcesExtractDir:=A_ScriptDir "\ResourcesExtract"
	global ResourcesExtractFile:=A_ScriptDir "\ResourcesExtract\ResourcesExtract.exe"
	if(!FileExist(ResourcesExtractFile)){
		ResourcesExtractFile:=RunIconDir "\ResourcesExtract\ResourcesExtract.exe"
		if(FileExist(ResourcesExtractFile)){
			ResourcesExtractExist:=true
			ResourcesExtractDir:=RunIconDir "\ResourcesExtract"
		}
	}else{
		ResourcesExtractExist:=true
	}
	iconAny:="shell32.dll,190"
	iconMenu:="shell32.dll,195"
	iconTree:="shell32.dll,53"
	if(A_OSVersion="WIN_XP"){
		MoveIcon:="shell32.dll,53"
		UpIcon:="shell32.dll,53"
		DownIcon:="shell32.dll,53"
	}else{
		MoveIcon:="shell32.dll,246"
		UpIcon:="shell32.dll,247"
		DownIcon:="shell32.dll,248"
	}
	if(A_IsCompiled=1){
		iconAny:=A_ScriptName ",1"
		iconMenu:=A_ScriptName ",2"
	}
	if(FileExist(A_ScriptDir "\ZzIcon.dll")){
		iconAny:="ZzIcon.dll,1"
		iconMenu:="ZzIcon.dll,2"
		iconTree:="ZzIcon.dll,3"
		MoveIcon:="ZzIcon.dll,4"
		UpIcon:="ZzIcon.dll,5"
		DownIcon:="ZzIcon.dll,6"
		try{
			Menu,exeTestMenu,Icon,donothing,ZzIcon.dll,7
			ZzIconPath:="ZzIcon.dll,7"
		} catch {
			ZzIconPath:="ZzIcon.dll,1"
		}
	}else{
		ZzIconPath:="shell32.dll,194"
	}
	MonitorHeight:=true
	SysGet, MonitorCount, MonitorCount
	Loop, %MonitorCount%
	{
		SysGet, Monitor, Monitor, %A_Index%
		if(MonitorBottom<1080){
			MonitorHeight:=false
		}
	}
	;如果所有显示器分辨率都大于等于1080高度则菜单图标默认24像素大小
	global MenuIconSize:=Var_Read("MenuIconSize",MonitorHeight ? 24 : "")
	global MenuTrayIconSize:=Var_Read("MenuTrayIconSize")
	global AnyIcon:=Var_Read("AnyIcon",iconAny)
	global AnyIconS:=StrSplit(Get_Transform_Val(AnyIcon),",")
	global MenuIcon:=Var_Read("MenuIcon",iconMenu)
	global MenuIconS:=StrSplit(Get_Transform_Val(MenuIcon),",")
	global TreeIcon:=Var_Read("TreeIcon",iconTree)
	global TreeIconS:=StrSplit(Get_Transform_Val(TreeIcon),",")
	global MoveIconS:=StrSplit(MoveIcon,",")
	global UpIconS:=StrSplit(UpIcon,",")
	global DownIconS:=StrSplit(DownIcon,",")
	global EditFileIcon:=Var_Read("EditFileIcon","shell32.dll,134")
	global EditFileIconS:=StrSplit(EditFileIcon,",")
	global PluginsManageIcon:=Var_Read("PluginsManageIcon","shell32.dll,166")
	global PluginsManageIconS:=StrSplit(PluginsManageIcon,",")
	global RunCtrlManageIcon:=Var_Read("RunCtrlManageIcon","shell32.dll,25")
	global RunCtrlManageIconS:=StrSplit(RunCtrlManageIcon,",")
	global CheckUpdateIcon:=Var_Read("CheckUpdateIcon","shell32.dll,14")
	global CheckUpdateIconS:=StrSplit(CheckUpdateIcon,",")
	global ZzIconS:=StrSplit(ZzIconPath,",")
return
;~;[后缀图标初始化]
Icon_FileExt_Set:
	global FolderIcon:=Var_Read("FolderIcon","shell32.dll,4")
	global FolderIconS:=StrSplit(Get_Transform_Val(FolderIcon),",")
	global UrlIcon:=Var_Read("UrlIcon","shell32.dll,44")
	global UrlIconS:=StrSplit(Get_Transform_Val(UrlIcon),",")
	global EXEIcon:=Var_Read("EXEIcon","shell32.dll,3")
	global EXEIconS:=StrSplit(Get_Transform_Val(EXEIcon),",")
	global LNKIcon:="shell32.dll,264"
	if(A_OSVersion="WIN_XP"){
		LNKIcon:="shell32.dll,30"
	}
	global LNKIconS:=StrSplit(LNKIcon,",")
	FuncIcon:=Var_Read("FuncIcon","shell32.dll,131")
	global FuncIconS:=StrSplit(Get_Transform_Val(FuncIcon),",")
	;~;[引入菜单项图标识别库]
	global IconFolderPath:=Var_Read("IconFolderPath","%A_ScriptDir%\RunIcon\ExeIcon|%A_ScriptDir%\RunIcon\WebIcon|%A_ScriptDir%\RunIcon\MenuIcon")
	global IconFolderList:={}
	Loop, parse, IconFolderPath, |
	{
		IconFolder:=Get_Transform_Val(A_LoopField)
		IfExist,%IconFolder%
		{
			Loop,%IconFolder%\*.*,0,1
			{
				SplitPath,% A_LoopFileFullPath, ,, ext, name_no_ext
				IconFolderList[(name_no_ext)]:=A_LoopFileFullPath
			}
		}
	}
	IconFolderPath:=StrReplace(IconFolderPath, "|", "`n")
return
;══════════════════════════════════════════════════════════════════
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■

;~;[图标集初始图标]
Icon_Image_Set(ImageListID){
	IL_Add(ImageListID, "shell32.dll", 1)
	IL_Add(ImageListID, "shell32.dll", 2)
	IL_Add(ImageListID, EXEIconS[1], EXEIconS[2])
	IL_Add(ImageListID, FolderIconS[1], FolderIconS[2])
	IL_Add(ImageListID, LNKIconS[1], LNKIconS[2])
	IL_Add(ImageListID, TreeIconS[1], TreeIconS[2])
	IL_Add(ImageListID, UrlIconS[1], UrlIconS[2])
	IL_Add(ImageListID, "shell32.dll", 50)
	IL_Add(ImageListID, "shell32.dll", 100)
	IL_Add(ImageListID, "shell32.dll", 101)
	IL_Add(ImageListID, FuncIconS[1], FuncIconS[2])
}
;#菜单加载完后，预读完成"修改菜单"的GUI图标
Icon_Tree_Image_Set(ImageListID){
	Loop,%MenuCount%
	{
		Loop, parse, iniVar%A_Index%, `n, `r, %A_Space%%A_Tab%
		{
			if(InStr(A_LoopField,";")=1 || A_LoopField="")
				continue
			Set_Icon(ImageListID,A_LoopField,false)
		}
	}
}
;~;[提取菜单中所有EXE程序图标，过程较慢]
Menu_Exe_Icon_Create:
	cfgFile=%ResourcesExtractDir%\ResourcesExtract.cfg
	DestFold=%A_Temp%\%RunAnyZz%\RunAnyExeIconTemp
	if(!ResourcesExtractExist){
		MsgBox,64,,请将ResourcesExtract.exe放入%ResourcesExtractDir%
		return
	}
	MsgBox,35,生成所有EXE图标，请稍等片刻,
(
使用生成的EXE图标可以加快开机第一次RunAny的加载速度`n`n是：覆盖老图标重新生成%RunAnyZz%菜单中的所有EXE图标`n否：只生成没有的EXE图标`n取消：取消生成
)
	IfMsgBox Yes
	{
		exeIconCreateFlag:=false
		Gosub,Menu_Exe_Icon_Extract
	}
	IfMsgBox No
	{
		exeIconCreateFlag:=true
		Gosub,Menu_Exe_Icon_Extract
	}
return
Menu_Exe_Icon_Extract:
	if(!FileExist(cfgFile)){
		MsgBox,64,,请将ResourcesExtract.cfg放入%ResourcesExtractDir%
		return
	}else{
		IniWrite,%DestFold%,%cfgFile%,General,DestFolder
		IniWrite,1,%cfgFile%,General,ExtractIcons
		IniWrite,0,%cfgFile%,General,ExtractCursors
		IniWrite,0,%cfgFile%,General,ExtractBitmaps
		IniWrite,0,%cfgFile%,General,ExtractHTML
		IniWrite,0,%cfgFile%,General,ExtractAnimatedIcons
		IniWrite,0,%cfgFile%,General,ExtractAnimatedCursors
		IniWrite,0,%cfgFile%,General,ExtractAVI
		IniWrite,0,%cfgFile%,General,OpenDestFolder
		IniWrite,2,%cfgFile%,General,MultiFilesMode
	}
	ToolTip,RunAny开始用ResourcesExtract生成EXE图标，请稍等……
	For k, v in MenuExeArray
	{
		exePath:=v["itemFile"]
		if(FileExist(exePath)){
			menuItem:=menuItemIconFileName(v["menuItem"])
			if(!exeIconCreateFlag || !FileExist(ExeIconDir "\" menuItem ".ico")){
				Run,%ResourcesExtractFile% /LoadConfig "%cfgFile%" /Source "%exePath%" /DestFold "%DestFold%"
			}
		}
	}
	Process,WaitClose,ResourcesExtract.exe,10
	ToolTip
	Menu_Exe_Icon_Set()
	MsgBox,64,,成功生成%RunAnyZz%内所有EXE图标到 %ExeIconDir%
	Gui,66:Submit, NoHide
	if(vIconFolderPath){
		if(!InStr(vIconFolderPath,"ExeIcon"))
			GuiControl,, vIconFolderPath, %vIconFolderPath%`n`%A_ScriptDir`%\RunIcon\ExeIcon
	}else{
		GuiControl,, vIconFolderPath, `%A_ScriptDir`%\RunIcon\ExeIcon
	}
return
;[循环提取菜单中EXE程序的正确图标]
Menu_Exe_Icon_Set(){
	For k, v in MenuExeArray
	{
		exePath:=v["itemFile"]
		SplitPath, exePath, exeName, exeDir, ext, name_no_ext
		iconNameFlag:=false
		maxFileName=
		maxFileSize=
		maxFilePath=
		IfExist,%A_Temp%\%RunAnyZz%\RunAnyExeIconTemp\%exeName%
		{
			loop,%A_Temp%\%RunAnyZz%\RunAnyExeIconTemp\%exeName%\*.ico
			{
				if(RegExMatch(A_LoopFileName,"iS).*_MAINICON.ico")){
					maxFilePath:=A_LoopFileFullPath
					break
				}
				if(!iconNameFlag && RegExMatch(A_LoopFileName,"iS).*_\d+\.ico")){
					iconNum:=RegExReplace(A_LoopFileName,"iS).*_(\d+)\.ico","$1")
					if(A_Index=1 || maxFileName>iconNum){
						maxFileName:=iconNum
						maxFilePath:=A_LoopFileFullPath
					}
					continue
				}
				if(maxFileSize<A_LoopFileSize){
					iconNameFlag:=true
					maxFileSize:=A_LoopFileSize
					maxFilePath:=A_LoopFileFullPath
				}
			}
			menuItem:=menuItemIconFileName(v["menuItem"])
			FileCopy, %maxFilePath%, %ExeIconDir%\%menuItem%.ico, 1
			maxFilePath=
		}
	}
}
;══════════════════════════════════════════════════════════════════
