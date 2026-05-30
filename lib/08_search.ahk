;══════════════════════════════════════════════════════════════════
;~;【🔍一键搜索】
One_Show:
	getZz:=Get_Zz()
	Gosub,One_Search
return
One_Search:
	Loop,parse,OneKeyUrl,`n
	{
		if(A_LoopField){
			if(Candy_isFile){
				SplitPath, getZz,FileName
				Run_Search(A_LoopField,FileName,BrowserPathRun)
			}else{
				Run_Search(A_LoopField,getZz,BrowserPathRun)
			}
		}
	}
return
Run_Search(anyUrl, getZz="", browser=""){
	any:=Get_Transform_Val(anyUrl)
	if(browser){
		browserRun:=browser A_Space
	}else if(RegExMatch(any,"iS)(www[.]).*") && openExtRunList["www"]){
		browserRun:=openExtRunList["www"] A_Space
	}else{
		HyperList:=["http","https","ftp"]
		For i, v in HyperList
		{
			if(RegExMatch(any,"iS)(" v "://?).*") && openExtRunList[v]){
				browserRun:=openExtRunList[v] A_Space
				break
			}
		}
	}
	if(InStr(any,"%getZz%")){
		Run,% browserRun """" StrReplace(any,"%getZz%",getZz) """"
	}else if(InStr(any,"%Clipboard%")){
		Run,% browserRun """" StrReplace(any,"%Clipboard%",Clipboard) """"
	}else if(InStr(any,"%s",true)){
		Run,% browserRun """" StrReplace(any,"%s",getZz) """"
	}else if(InStr(any,"%S",true)){
		Run,% browserRun """" StrReplace(any,"%S",SkSub_UrlEncode(getZz)) """"
	}else if(AutoGetZz && any=anyUrl){  ;网址中没有变量则在末尾添加选中文字
		Run,%browserRun%"%any%%getZz%"
	}else{
		Run,%browserRun%"%any%"
	}
}
Web_Run:
	webName:=RegExReplace(A_ThisMenuItem,"iS)^" RUNANY_SELF_MENU_ITEM1)
	if(webName){
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(webName)] : menuWebList1[(webName)]
	}else{
		webList:=(A_ThisHotkey=MenuHotKey2) ? menuWebList2[(menuRoot2[1])] : menuWebList1[(menuRoot1[1])]
	}
	if(JumpSearch){
		Gosub,Web_Search
	}else{
		MsgBox,33,开始批量搜索%webName%,确定用【%getZz%】批量搜索以下网站：`n%webList%
		IfMsgBox Ok
		{
			Gosub,Web_Search
		}
	}
return
Web_Search:
	Loop,parse,webList,`n
	{
		if(A_LoopField){
			any:=MenuObj[(A_LoopField)]
			Run_Search(any,getZz,BrowserPathRun)
		}
	}
return
;~;[🔎一键Everything][搜索选中文字][激活][隐藏]
Ev_Show:
	getZz:=Get_Zz()
	EverythingIsRun()
	evSearch:=EvShowFolderSpace:=""
	if(Trim(getZz," `t`r`n")!=""){
		getZzLength:=StrSplit(getZz,"`n").Length()
		Loop, parse, getZz, `n, `r
		{
			S_LoopField=%A_LoopField%
			if(EvShowFolder && (InStr(FileExist(S_LoopField), "D") || RegExMatch(S_LoopField,"S).*\\$"))){
				EvShowFolderSpace:=A_Space
			}else if(RegExMatch(S_LoopField,"S)^(\\\\|.:\\).*?$")){
				SplitPath,S_LoopField,fileName,,,name_no_ext
				S_LoopField:=EvShowExt ? fileName : name_no_ext
			}
			if(InStr(S_LoopField,A_Space) && (getZzLength>1 || InStr(FileExist(S_LoopField), "D"))){
				S_LoopField="""%S_LoopField%"""
			}
			evSearch.=S_LoopField "|"
		}
		evSearch:=SubStr(evSearch, 1, -StrLen("|"))
	}
	DetectHiddenWindows,On
	IfWinExist ahk_class EVERYTHING
		if evSearch
			Run % EvPathRun " -search """ evSearch EvShowFolderSpace """"
		else
			IfWinNotActive
				WinActivate
else
	WinMinimize
else
	Run % EvPathRun (evSearch ? " -search """ evSearch EvShowFolderSpace """" : "")
	DetectHiddenWindows,Off
return
