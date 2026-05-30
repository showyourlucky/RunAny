;~;【🔎Everything搜索所有exe程序】
;══════════════════════════════════════════════════════════════════
EverythingIsRun(){
	global EvPathRun
	evExist:=true
	evAdminRun:=A_IsAdmin ? "-admin" : ""
	DetectHiddenWindows,On
	;获取everything路径
	if(WinExist("ahk_exe " Everything_exe)){
		WinGet, EvPathRun, ProcessPath, ahk_exe %Everything_exe%
		ev := new everything
		;RunAny管理员权限运行后发现Everything非管理员权限则重新以管理员权限运行
		if(!ev.GetIsAdmin() && A_IsAdmin && EvPathRun){
			SplitPath, EvPathRun, name, dir
			SetWorkingDir,%dir%
			Run,%EvPathRun% -exit
			Run,%EvPathRun% -startup %evAdminRun%
			Sleep,500
			ShowTrayTip("","RunAny与Everything权限不一致自动调整后启动",10,17)
			Gosub,Menu_Reload
		}
	}else{
		EvPathRun:=Get_Transform_Val(EvPath)
		if(EvPathRun && FileExist(EvPathRun) && !InStr(FileExist(EvPathRun), "D")){
			SplitPath, EvPathRun, name, dir
			SetWorkingDir,%dir%
			Run,%EvPathRun% -startup %evAdminRun%
			Sleep,500
		}else if(FileExist(A_ScriptDir "\Everything\Everything.exe")){
			SetWorkingDir,%A_ScriptDir%\Everything
			Run,%A_ScriptDir%\Everything\Everything.exe -startup %evAdminRun%
			EvPath=%A_ScriptDir%\Everything\Everything.exe
			EvPathRun:=EvPath
			Sleep,500
		}else if(FileExist(A_ScriptDir "\Everything\Everything64.exe")){
			SetWorkingDir,%A_ScriptDir%\Everything
			Run,%A_ScriptDir%\Everything\Everything64.exe -startup %evAdminRun%
			EvPath=%A_ScriptDir%\Everything\Everything64.exe
			EvPathRun:=EvPath
			Sleep,500
		}else{
			TrayTip,,RunAny需要Everything快速识别无路径应用`n
			(
* 运行Everything后再重启RunAny
* 或在RunAny设置中配置Everything正确安装路径`n* 或www.voidtools.com下载安装
			),10,2
			evExist:=false
		}
		SetWorkingDir,%A_ScriptDir%
	}
	DetectHiddenWindows,Off
	return evExist
}
;[校验Everything是否可正常返回搜索结果]
EverythingCheck:
	DeleteFile(A_Temp "\" RunAnyZz "\RunAnyEv.ahk")
	FileAppend,
(
#NoTrayIcon
global everyDLL:="%A_ScriptDir%\%everyDLL%"
ev:=new everything
ev.SetMatchWholeWord(true)
ev.SetSearch("RunAny")
ev.Query()
while,`% !ev.GetTotResults()
{
	if(A_Index>1000){
		MsgBox,16,RunAny无法与Everything通信,Everything启动缓慢或异常导致无法搜索到磁盘文件``n``n
		`(
【原因1：Everything正在创建索引】
请手动打开Everything等待可以搜索到文件了请再重启RunAny``n
【原因2：Everything数据库在不同磁盘导致读写缓慢】
查看Everything.exe和文件Everything.db是否不在同一硬盘``n
在Everything窗口最上面菜单的“工具”——“选项”——找到选中左边的“索引”——
修改右边的数据库路径到Everything.exe同一硬盘，加快读写速度``n
【原因3：Everything搜索异常】
请打开Everything菜单-工具-选项设置 安装Everything服务(S)，再重启Everything待可以搜索文件再重启RunAny
		`)
		break
	}
	Sleep, 100
	ev.Query()
}
val:=ev.GetTotResults(0)
RegWrite,REG_SZ,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults,`%val`%
return
class everything
{
	__New(){
		this.hModule := DllCall("LoadLibrary",str,everyDLL)
	}
	SetSearch(aValue)
	{
		this.eSearch := aValue
		dllcall(everyDLL "\Everything_SetSearch",str,aValue)
		return
	}
	SetMatchWholeWord(aValue)
	{
		this.eMatchWholeWord := aValue
		dllcall(everyDLL "\Everything_SetMatchWholeWord",int,aValue)
		return
	}
	Query(aValue=1)
	{
		dllcall(everyDLL "\Everything_Query",int,aValue)
		return
	}
	GetTotResults()
	{
		return dllcall(everyDLL "\Everything_GetTotResults")
	}
}
),%A_Temp%\%RunAnyZz%\RunAnyEv.ahk
	Sleep, 200
	Run,%A_AhkPath%%A_Space%"%A_Temp%\%RunAnyZz%\RunAnyEv.ahk"
return
EverythingCheckResults:
	RegRead,EvTotResults,HKEY_CURRENT_USER\SOFTWARE\RunAny,EvTotResults
	if(EvTotResults>0){
		SetTimer,EverythingCheckResults,Off
		Gosub,RunAny_SearchBar
		ShowTrayTip("","Everything索引更新完成",5,17)
		Gosub,Menu_Reload
	}
return
EverythingQuery(EvCommandStr){
	ev := new everything
	evSearchStr:=EvCommandStr ? EvCommand " " EvCommandStr : EvCommand
	;查询字串设为everything
	ev.SetSearch("file: " evSearchStr)
	;执行搜索
	ev.Query()
	Loop,% ev.GetNumFileResults()
	{
		chooseNewFlag:=false
		Z_Index:=A_Index-1
		objFullPathName:=ev.GetResultFullPathName(Z_Index)
		if(!FileExist(objFullPathName))
			continue
		objFileName:=ev.GetResultFileName(Z_Index)
		objFileNameNoExeExt:=RegExReplace(objFileName,"iS)\.exe$","")
		if(MenuObjEv[objFileNameNoExeExt]){
			MenuObjSame[(MenuObjEv[objFileNameNoExeExt])]:=MenuObjEv[objFileNameNoExeExt]
			MenuObjSame[objFullPathName]:=objFullPathName
			if(EvExeMTimeNew){
				;优先选择最新修改时间的同名文件全路径
				FileGetTime,objFullPathNameUpdateTimeOld,% MenuObjEv[objFileNameNoExeExt], M
				FileGetTime,objFullPathNameUpdateTimeNew,% objFullPathName, M
				if(objFullPathNameUpdateTimeOld<objFullPathNameUpdateTimeNew){
					chooseNewFlag:=true
				}
			}
			if(EvExeVerNew && RegExMatch(objFileName,"iS).*?\.exe$")){
				;优先选择最新版本的同名exe全路径
				FileGetVersion,objFullPathNameVersionOld,% MenuObjEv[objFileNameNoExeExt]
				FileGetVersion,objFullPathNameVersionNew,% objFullPathName
				if(objFullPathNameVersionOld<objFullPathNameVersionNew){
					MenuObjEv[objFileNameNoExeExt]:=objFullPathName
					if(MenuObj.HasKey(objFileNameNoExeExt)){
						MenuObj[objFileNameNoExeExt]:=objFullPathName
						MenuObjSearch[objFileName]:=objFullPathName
					}
				}else if(chooseNewFlag && objFullPathNameVersionOld=objFullPathNameVersionNew){
					MenuObjEv[objFileNameNoExeExt]:=objFullPathName
					if(MenuObj.HasKey(objFileNameNoExeExt)){
						MenuObj[objFileNameNoExeExt]:=objFullPathName
						MenuObjSearch[objFileName]:=objFullPathName
					}
				}
				continue
			}
			;版本相同则取最新修改时间，时间相同或小于则不改变
			if(EvExeMTimeNew && !chooseNewFlag){
				continue
			}
		}
		MenuObjEv[objFileNameNoExeExt]:=objFullPathName
		if(MenuObj.HasKey(objFileNameNoExeExt)){
			MenuObj[objFileNameNoExeExt]:=objFullPathName
			MenuObjSearch[objFileName]:=objFullPathName
		}
	}
	return ev.GetNumFileResults()
}
EverythingNoPathSearchStr(){
	Loop,%MenuCount%
	{
		Loop, parse, iniVar%A_Index%, `n, `r, %A_Space%%A_Tab%
		{
			if(A_LoopField="" || InStr(A_LoopField,";")=1 || InStr(A_LoopField,"-")=1){
				continue
			}
			itemVars:=StrSplit(A_LoopField,"|",,2)
			itemVar:=itemVars[2] ? itemVars[2] : itemVars[1]
			itemMode:=Get_Menu_Item_Mode(itemVar)
			outVar:=RegExReplace(itemVar,"iS)^([^|]+?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数
			;[过滤掉所有不是无路径的菜单项]
			if(InStr(EvCommandStr,"|^" outVar "$|")){
				MenuObjEvPathEmptyReason[itemVar]:="重复的无路径应用"
				continue
			}else if(itemMode!=1 && itemMode!=8){
				MenuObjEvPathEmptyReason[itemVar]:="启动模式不是程序"
				continue
			}else if(outVar="iexplore.exe" && FileExist(A_ProgramFiles "\Internet Explorer\iexplore.exe")){
				MenuObj["iexplore"]:=A_ProgramFiles "\Internet Explorer\iexplore.exe"
				continue
			}else if(itemMode=1 && (InStr(outVar,"..\") || RegExMatch(outVar,"S)\\|\/|\:|\*|\?|\""|\<|\>|\|") || RegExMatch(outVar,"S)^%.*?%$") )){
				MenuObjEvPathEmptyReason[outVar]:="启动软件名带有特殊字符"
				continue
			}else if(itemMode=1 && (FileExist(A_WinDir "\" outVar) || FileExist(A_WinDir "\system32\" outVar))){
				MenuObjEvPathEmptyReason[outVar]:="属于Windows和System32系统路径软件"
				continue
			}else if(itemMode=8){
				MenuObjEvPathEmptyReason[outVar]:="插件脚本函数格式"
				if(RegExMatch(itemVar,"iS).+?\[.+?\]%?\(.*?%"".+?""%.*?\)")){
					outVar:=RegExReplace(itemVar,"iS).+?\[.+?\]%?\(.*?%""(.+?)""%.*?\)","$1")
					if(InStr(outVar,"..\")
						|| RegExMatch(outVar,"S)\\|\/|\:|\*|\?|\""|\<|\>|\|")
						|| RegExMatch(outVar,"S)^%.*?%$")
						|| FileExist(A_WinDir "\" outVar) || FileExist(A_WinDir "\system32\" outVar)){
						continue
					}
				}else{
					continue
				}
			}
			outVarStr:=outVar
			;正则转义特殊字符
			if(RegExMatch(outVarStr, RegexEscapeNoPointStr)){
				outVarStr:=StrListEscapeReplace(outVarStr, RegexEscapeNoPointList, "\")
			}
			outVarStr:=StrReplace(outVarStr,".","\.")
			EvCommandStr.="^" outVarStr "$|"
			outVarNoExeExt:=RegExReplace(outVar,"iS)\.exe$","")
			MenuObj[outVarNoExeExt]:=""
			MenuObjSearch[outVar]:=""
		}
	}
	if(EvCommandStr!=""){
		EvCommandStr:=SubStr(EvCommandStr, 1, -StrLen("|"))
		EvCommandStr:="regex:""" EvCommandStr """"
	}
	return EvCommandStr
}
;[使用everything搜索单个exe程序]
exeQuery(exeName,noSystemExe:=" !C:\Windows*"){
	ev := new everything
	str := exeName . noSystemExe
	;查询字串设为全字匹配
	ev.SetMatchWholeWord(true)
	ev.SetSearch(str)
	;执行搜索
	ev.Query()
	return ev.GetResultFullPathName(0)
}
;[IPC方式和everything进行通讯，修改于AHK论坛]
class everything
{
	__New(){
		this.hModule := DllCall("LoadLibrary", str, everyDLL)
	}
	__Get(aName){
	}
	__Set(aName, aValue){
	}
	__Delete(){
		DllCall("FreeLibrary", "UInt", this.hModule)
		return
	}
	SetSearch(aValue)
	{
		this.eSearch := aValue
		dllcall(everyDLL "\Everything_SetSearch",str,aValue)
		return
	}
	;设置全字匹配
	SetMatchWholeWord(aValue)
	{
		this.eMatchWholeWord := aValue
		dllcall(everyDLL "\Everything_SetMatchWholeWord",int,aValue)
		return
	}
	;设置正则表达式搜索
	SetRegex(aValue)
	{
		this.eMatchWholeWord := aValue
		dllcall(everyDLL "\Everything_SetRegex",int,aValue)
		return
	}
	;执行搜索动作
	Query(aValue=1)
	{
		dllcall(everyDLL "\Everything_Query",int,aValue)
		return
	}
	;返回管理员权限状态
	GetIsAdmin()
	{
		return dllcall(everyDLL "\Everything_IsAdmin")
	}
	;返回匹配总数
	GetTotResults()
	{
		return dllcall(everyDLL "\Everything_GetTotResults")
	}
	;返回可见文件结果的数量
	GetNumFileResults()
	{
		return dllcall(everyDLL "\Everything_GetNumFileResults")
	}
	;返回文件名
	GetResultFileName(aValue)
	{
		return strget(dllcall(everyDLL "\Everything_GetResultFileName",int,aValue))
	}
	;返回文件全路径
	GetResultFullPathName(aValue,cValue=128)
	{
		VarSetCapacity(bValue,cValue*2)
		dllcall(everyDLL "\Everything_GetResultFullPathName",int,aValue,str,bValue,int,cValue)
		return bValue
	}
}
;══════════════════════════════════════════════════════════════════
