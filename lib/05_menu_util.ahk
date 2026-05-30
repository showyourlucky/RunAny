;~;[菜单项过滤不同内容类型]
Menu_Item_List_Filter(M_Index,MenuTypeList,HideFlag,MenuType:=1){
	if(!HideFlag)
		return
	if(MenuType=1){
		rootName:=menuDefaultRoot%M_Index%[1]
		rootReg:="S)[^\s]+\s$"
	}else if(MenuType=2){
		rootName:=menuWebRoot%M_Index%[1]
		rootReg:="S)[^\s]+\s{2}$"
	}else if(MenuType=3){
		rootName:=menuFileRoot%M_Index%[1]
		rootReg:="S)[^\s]+\s{3}$"
	}
	For mn,items in %MenuTypeList%%M_Index%
	{
		if(mn=rootName || RegExMatch(mn,rootReg)){
			Loop, Parse, items, `n
			{
				if(A_LoopField="")
					continue
				try Menu,%mn%,Delete,%A_LoopField%
			}
			if(InStr(mn,RunAnyZz))
				continue
			if(%MenuTypeList%%M_Index%[mn]=MenuObjList%M_Index%[mn]){
				try Menu,%mn%,Delete
			}
		}
	}
}
;~[菜单节点分类过滤]
Menu_Tree_List_Filter(M_Index,MenuTypeList,MenuType){
	if(MenuType=2){
		TREE_TYPE:="  "
		rootReg:="S)[^\s]+\s{2}$"
	}else if(MenuType=3){
		TREE_TYPE:="   "
		rootReg:="S)[^\s]+\s{3}$"
	}
	For mn,items in MenuObjTree%M_Index%
	{
		if(!RegExMatch(mn,rootReg))
			continue
		delFlag:=true
		For k,v in %MenuTypeList%%M_Index%
		{
			if(mn=v TREE_TYPE || mn=M%M_Index% TREE_TYPE){
				delFlag:=false
				break
			}
		}
		if(delFlag){
			try Menu,%mn%,Delete
		}
	}
}
;[修改RunAny.ini文件自动重启]
AutoReloadMTime:
	RegRead, MTimeIniPathReg, HKEY_CURRENT_USER\Software\RunAny, %iniPath%
	FileGetTime,MTimeIniPath, %iniPath%, M  ; 获取修改时间.
	if(MTimeIniPathReg!=MTimeIniPath){
		Gosub,Menu_Reload
	}
	if(MENU2FLAG){
		RegRead, MTimeIniPath2Reg, HKEY_CURRENT_USER\Software\RunAny, %iniPath2%
		FileGetTime,MTimeIniPath2, %iniPath2%, M  ; 获取修改时间.
		if(MTimeIniPath2!=MTimeIniPath2Reg){
			Gosub,Menu_Reload
		}
	}
return
;[RunAny自动备份配置文件]
RunABackup(RunABackupDir,RunABackupFile,RunABackupFileContent,RunABackupFileCopy,RunABackupFileTarget){
	ConfigBackupNum:=0
	ConfigBackupFlag:=true
	Loop,%RunABackupDir%%RunABackupFile%
	{
		FileRead, iniVarBak, %A_LoopFileFullPath%
		if(RunABackupFileContent=iniVarBak){
			ConfigBackupFlag:=false
		}
		ConfigBackupNum++
	}
	if(ConfigBackupFlag){
		FileCopy, %RunABackupFileCopy%, %RunABackupDir%%RunABackupFileTarget%, 1
	}
	if(ConfigBackupNum>RunABackupMax){
		RunABackupClear(RunABackupDir,RunABackupFile)
	}
}
RunABackupClear(RunABackupDir,RunABackupFile){
	if(RunABackupMax>0){
		oldFile:=A_Now
		Loop,%RunABackupDir%%RunABackupFile%
		{
			if(oldFile>A_LoopFileTimeCreated){
				oldFile:=A_LoopFileTimeCreated
				oldPath:=A_LoopFileLongPath
			}
		}
		if(RegExMatch(oldPath, "iS).*?\.bak$")){
			FileDelete, %oldPath%
		}
	}
}
;~;[无路径应用缓存同步更新]
RunAEvFullPathSync:
	MenuObjUpdateList:=Object(),MenuObjEv:=Object(),MenuObjSearch:=Object()
	if(EverythingQuery(EvCommandStr)){
		for k,v in MenuObjCache
		{
			if(MenuObjSearch[k] && v!=MenuObjSearch[k]){
				IniWrite, % MenuObjSearch[k], %RunAnyEvFullPathIni%, FullPath, %k%
				MenuObjUpdateList.Push(k)
			}else if(MenuObjCache[k]="" && !MenuObjEvPathEmptyReason[k]){
				MenuObjEvPathEmptyReason[k]:="在EV中没有搜索到"
				RunAEvFullPathSyncFlag:=true
			}
		}
		if(MenuObjUpdateList.Length()>0){
			Gosub,RunAny_SearchBar
			ShowTrayTip("以下无路径应用缓存更新：",StrListJoin("、",MenuObjUpdateList),10,17)
			Gosub,Menu_Reload
		}
	}
return
;══════════════════════════════════════════════════════════════════
;~;【多种启动菜单热键】
#If MenuDoubleCtrlKey=1
	Ctrl::Gosub,DoubleClickKey
#If
#If MenuDoubleAltKey=1
	Alt::Gosub,DoubleClickKey
#If
#If MenuDoubleLWinKey=1
	LWin::Gosub,DoubleClickKey
#If
#If MenuDoubleRWinKey=1
	RWin::Gosub,DoubleClickKey
#If
#If MenuCtrlRightKey=1
	~Ctrl & RButton::Gosub,Menu_Show1
#If
#If MenuShiftRightKey=1
	~Shift & RButton::Gosub,Menu_Show1
#If
#If MenuXButton1Key=1
	XButton1::Gosub,Menu_Show1
#If
#If MenuXButton2Key=1
	XButton2::Gosub,Menu_Show1
#If
#If MenuMButtonKey=1 && !WinActive("ahk_group DisableGUI")
	~MButton::Gosub,Menu_Show1
#If

DoubleClickKey:
	KeyWait,%A_ThisHotkey%
	KeyWait,%A_ThisHotkey%,d,t0.2
	if !Errorlevel
		Gosub,Menu_Show1
	else
		SendInput,{%A_ThisHotkey%}
return
return
;══════════════════════════════════════════════════════════════════
