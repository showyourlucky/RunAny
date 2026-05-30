;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;~;【══🧰通用函数方法══】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;[创建文件夹]
CreateDir(dir){
	if(!InStr(FileExist(dir), "D"))
		FileCreateDir, %dir%
}
;[删除已有文件]
DeleteFile(filePath){
	if(FileExist(filePath))
		FileDelete, %filePath%
}
;[检查后缀名]
Ext_Check(name,len,ext){
	len_ext:=StrLen(ext)
	site:=InStr(name,ext,,0,1)
	return site!=0 && site=len-len_ext+1
}
;[输出结果还是仅显示保存到剪贴板]
Send_Or_Show(textResult,isSend:=false,sTime:=1000){
	textResult:=RegExReplace(textResult,"`r`n$")
	if(textResult="")
		return
	if(isSend){
		Send_Str_Zz(textResult)
		return
	}
	Clipboard:=textResult
	ToolTip,%textResult%
	SetTimer,RemoveToolTip,%sTime%
}
;[粘贴输出短语]
Send_Str_Zz(strZz,tf=false){
	Candy_Saved:=ClipboardAll
	;切换Win10输入法为英文
	try DllCall("SendMessage",UInt,DllCall("imm32\ImmGetDefaultIMEWnd",Uint,WinExist("A")),UInt,0x0283,Int,0x002,Int,0x00)
	if(tf){
		strZz:=Get_Transform_Val_GetZz(strZz)
	}
	Clipboard:=strZz
	SendInput,^v
	Sleep,80
	Clipboard:=Candy_Saved
}
;[键盘输出短语]
Send_Str_Input_Zz(strZz,tf=false){
	if(tf){
		strZz:=Get_Transform_Val_GetZz(strZz)
	}
	SendInput,{Text}%strZz%
}
;[输出热键]
Send_Key_Zz(keyZz,keyLevel=0){
	if(keyLevel=1)
		SendLevel,1
	SendInput,%keyZz%
	if(keyLevel=1)
		SendLevel,0
}
;[获取选中]
Get_Zz(copyKey:="^c"){
	global Candy_isFile
	global Candy_Select
	Candy_isFile:=0
	try Candy_Saved:=ClipboardAll
	Clipboard:=""
	if(GetZzCopyKey!="" && GetZzCopyKeyApp!="" && WinActive("ahk_group GetZzCopyKeyAppGUI"))
		copyKey:=GetZzCopyKey
	SendInput,%copyKey%
	if(ClipWaitTime != 0.1) && WinActive("ahk_group ClipWaitGUI"){
		ClipWait,%ClipWaitTime%
	}else{
		ClipWait,0.1
	}
	If(ErrorLevel){
		Clipboard:=Candy_Saved
		return ""
	}
	Candy_isFile:=DllCall("IsClipboardFormatAvailable","UInt",15)
	CandySel:=Clipboard
	Candy_Select:=ClipboardAll
	Clipboard:=Candy_Saved
	return CandySel
}
;[文本转换为URL编码]
SkSub_UrlEncode(str, enc="UTF-8")
{
	enc:=trim(enc)
	If enc=
		Return str
	hex := "00", func := "msvcrt\" . (A_IsUnicode ? "swprintf" : "sprintf")
	VarSetCapacity(buff, size:=StrPut(str, enc)), StrPut(str, &buff, enc)
	While (code := NumGet(buff, A_Index - 1, "UChar")) && DllCall(func, "Str", hex, "Str", "%%%02X", "UChar", code, "Cdecl")
		encoded .= hex
	Return encoded
}
;[拼接字符Zz]
StrJoin(sep, params*) {
	str:=""
	for index,param in params
	{
		if(param!="")
			str.= param . sep
	}
	return SubStr(str, 1, -StrLen(sep))
}
;[数组拼接字符Zz]
StrListJoin(sep, paramList, join:=":"){
	str:=""
	for index,param in paramList
	{
		if(paramList.HasKey(1)){
			str.= param . sep
		}else{
			str.= index join param . sep
		}
	}
	return SubStr(str, 1, -StrLen(sep))
}
;[批量替换字符]
StrListBatchReplace(paramList, regExStr, replaceStr:=""){
	strObj:=Object()
	for index,searchStr in paramList
	{
		strObj.Push(RegExReplace(searchStr, regExStr, replaceStr))
	}
	return strObj
}
;[批量替换数组字符]
StrListEscapeReplace(str, paramList, replaceStr:="\"){
	For k, v in paramList
	{
		str:=StrReplace(str, v, replaceStr v)
	}
	return str
}
;[反向获取val对应的key]
GetKeyByVal(obj, val){
	for k,v in obj
	{
		if(val=v)
			return k
	}
}
;[获取变量展开转换后的值]
Get_Transform_Val(string){
	try{
		For mVarName, mVarVal in MenuVarIniList
		{
			if(InStr(string,"%" mVarName "%"))
				string:=StrReplace(string, "%" mVarName "%", mVarVal)
		}
		spo := 1
		out := ""
		while (fpo:=RegexMatch(string, "(%(.*?)%)|``(.)", m, spo))
		{
			out .= SubStr(string, spo, fpo-spo)
			spo := fpo + StrLen(m)
			if (m1)
				out .= %m2%
			else switch (m3)
			{
			;此处报错请升级Autohotkey到v1.1.31以上版本
			case "a": out .= "`a"
			case "b": out .= "`b"
			case "f": out .= "`f"
			case "n": out .= "`n"
			case "r": out .= "`r"
			case "t": out .= "`t"
			case "v": out .= "`v"
			default: out .= m3
			}
		}
		return out SubStr(string, spo)
	}catch{
		return string
	}
}
Get_Transform_Val_GetZz(string){
	if(InStr(string,"%getZz%")){
		string:=StrReplace(string, "%getZz%", getZz)
	}
	if(InStr(string,"%A_ThisMenuItem%")){
		string:=StrReplace(string, "%A_ThisMenuItem%", A_ThisMenuItem)
	}
	if(InStr(string,"%Clipboard%") || InStr(string,"%ClipboardAll%")){
		string:=StrReplace(string, "%Clipboard%", Clipboard)
		string:=StrReplace(string, "%ClipboardAll%", ClipboardAll)
	}
	return Get_Transform_Val(string)
}
;变量布尔值反转
Variable_Boolean_Reverse(vars*){
	global
	for i,v in vars
	{
		%v%:=!%v%
	}
}
;时间格式转换
time_format(t, f:="yyyy-MM-dd HH:mm:ss"){
	FormatTime, timeVar, %t%, %f%
	return t!="" ? timeVar : ""
}
;获取运行进程的路径
get_process_path(process){
	DetectHiddenWindows,On
	WinGet, processPath, ProcessPath,ahk_exe %process%
	DetectHiddenWindows,Off
	return processPath
}
;~;[电脑开机后的运行时长(秒)-规则]
rule_boot_time(){
	return A_TickCount/1000
}
/*
【获取当前电脑机型-规则】
返回值参考：https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-systemenclosure
*/
rule_chassis_types(){
	chassisTypes:=cmdClipReturn("wmic PATH Win32_SystemEnclosure get ChassisTypes /value | findstr ""ChassisTypes=""")
	chassisTypes:=RegExReplace(chassisTypes,"i)ChassisTypes=\{(\d+)\}.*","$1")
	return Format("{:d}",chassisTypes)
}
;~;[检查网络状态-规则]
rule_check_network(lpszUrl=""){
	if(lpszUrl="")
		lpszUrl:="http://www.baidu.com"
	return DllCall("Wininet.dll\InternetCheckConnection", "Ptr", &lpszUrl, "UInt", 0x1, "UInt", 0x0, "Int")
}
/*
【判断启动项当前是否已经运行】
runNamePath 进程名或者启动项路径
*/
rule_check_is_run(runNamePath){
	DetectHiddenWindows,On
	result:=false
	runValue:=RegExReplace(runNamePath,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
	SplitPath, runValue, name,, ext  ; 获取扩展名
	if(ext="ahk"){
		if(InStr(runNamePath,"..\")=1){
			runNamePath:=IsFunc("funcPath2AbsoluteZz") ? Func("funcPath2AbsoluteZz").Call(runNamePath,A_ScriptFullPath) : runNamePath
		}
		if WinExist(runNamePath " ahk_class AutoHotkey")
		{
			result:=true
		}
	}else if(name){
		Process,Exist,%name%
		if ErrorLevel
			result:=true
	}
	DetectHiddenWindows,Off
	return result
}
/*
【相对路径转换为绝对路径 by hui-Zz】
aPath 被转换的相对路径，可带文件名
ahkPath 相对参照的执行脚本完整全路径，带文件名
return -1 路径参数有误
*/
funcPath2AbsoluteZz(aPath,ahkPath){
	SplitPath, aPath, fname, fdir, fext, , fdrive
	SplitPath, ahkPath, name, dir, ext, , drive
	if(!aPath || !ahkPath)
		return -1
	;下级目录直接加上参照目录路径
	if(!fdrive && !InStr(aPath,"..")){
		return dir . "\" . aPath
	}
	pathList:=StrSplit(dir,"\")
	;上级目录根据层级递进添加多级路径
	if(InStr(aPath,"..\")=1){
		aPathStr:=RegExReplace(aPath, "\.\.\\", , PointCount)
		pathStr:=""
		;每次向上递进，找到添加与启动项相匹配路径段
		Loop,% pathList.MaxIndex()-PointCount
		{
			pathStr.=pathList[A_Index] . "\"
		}
		filePath:=pathStr . aPathStr
		return filePath
	}
	return false
}
/*
【绝对路径转换为相对路径 by hui-Zz】
fPath 被转换的全路径，可带文件名
ahkPath 相对参照的执行脚本完整全路径，带文件名
return -1 路径参数有误
return -2 被转换路径和参照路径不在同一磁盘，不能转换
*/
funcPath2RelativeZz(fPath,ahkPath){
	SplitPath, fPath, fname, fdir, fext, , fdrive
	SplitPath, ahkPath, name, dir, ext, , drive
	if(!fPath || !ahkPath || !dir || !fdir || !fdrive)
		return -1
	if(fdrive!=drive){
		return -2
	}
	;下级目录直接去掉参照目录路径
	if(InStr(fPath,dir)){
		filePath:=StrReplace(fPath,dir)
		StringTrimLeft, filePath, filePath, 1
		return filePath
	}
	;上级目录根据层级递进添加多级前缀..\
	pathList:=StrSplit(dir,"\")
	Loop,% pathList.MaxIndex()
	{
		pathStr:=""
		upperStr:=""
		;每次向上递进，找到与启动项相匹配路径段替换成..\
		Loop,% pathList.MaxIndex()-A_Index
		{
			pathStr.=pathList[A_Index] . "\"
		}
		StringTrimRight, pathStr, pathStr, 1
		if(InStr(fdir,pathStr)){
			Loop,% A_Index
			{
				upperStr.="..\"
			}
			StringTrimRight, upperStr, upperStr, 1
			filePath:=StrReplace(fPath,pathStr,upperStr)
			return filePath
		}
	}
	return false
}
;[利用HTML中JS的eval函数来计算]
js_eval(exp)
{
	HtmlObj:=ComObjCreate("HTMLfile")
	exp:=escapeString(exp)
	if(InStr(exp,"-") && InStr(exp,".")){
		;解决eval减法精度失真问题，根据最长的小数位数四舍五入
		subMaxNum:=0
		expResult:=exp
		while RegExMatch(expResult,"S)(\.\d+)")
		{
			sub:=RegExReplace(expResult,".*(\.\d+).*","$1")
			if(StrLen(sub)>subMaxNum)
				subMaxNum:=StrLen(sub)
			expResult:=RegExReplace(expResult,sub)
		}
		expNum:="1"
		Loop,%subMaxNum%
		{
			expNum.="0"
		}
	}else{
		expNum:="100000000000000"
	}
	HtmlObj.write("<body><script>var t=document.body;t.innerText='';t.innerText=Math.round(eval('" . exp . "')*" expNum ")/" expNum ";</script></body>")
	return InStr(cabbage:=HtmlObj.body.innerText, "body") ? "?" : cabbage
}
escapeString(string){
	string:=RegExReplace(string, "('|""|&|\\|\\n|\\r|\\t|\\b|\\f)", "\$1")
	string:=RegExReplace(string, "\R", "\n")
	return string
}
/*
【隐藏运行cmd命令并将结果存入剪贴板后取回 @hui-Zz】
*/
cmdClipReturn(command){
	cmdInfo:=""
	try{
		Clip_Saved:=ClipboardAll
		Clipboard=
		Run,% ComSpec " /C " command " | CLIP", , Hide
		ClipWait,2
		cmdInfo:=Clipboard
		Clipboard:=Clip_Saved
	}catch{}
		return cmdInfo
}
;~;[接收其他脚本的消息]
Receive_WM_COPYDATA(wParam, lParam)
{
	StringAddress := NumGet(lParam + 2*A_PtrSize)  ; 获取 CopyDataStruct 的 lpData 成员.
	CopyOfData := StrGet(StringAddress)  ; 从结构中复制字符串.
	Remote_Dyna_Run(CopyOfData, "", true)
	return true  ; 返回 1(true) 是回复此消息的传统方式.
}
;[系统关机或重启前操作]
WM_QUERYENDSESSION(wParam, lParam)
{
	ENDSESSION_LOGOFF = 0x80000000
	RegWrite,REG_SZ,HKEY_CURRENT_USER\SOFTWARE\RunAny,RunAnyTickCount,%A_TickCount%
	if (lParam & ENDSESSION_LOGOFF)  ; 用户正在注销.
		EventType = Logoff
	else  ; 系统正在关机或重启.
		EventType = Shutdown
}
;[脚本退出或重启前操作]
ExitFunc(ExitReason, ExitCode)
{
	RegWrite,REG_SZ,HKEY_CURRENT_USER\SOFTWARE\RunAny,RunAnyTickCount,%A_TickCount%
	Gosub,AutoClose_Plugins
	; 不要调用 ExitApp -- 那会阻止其他 OnExit 函数被调用.
}
;[动态执行脚本注册对象]
DynaExpr_ObjRegisterActive(GUID,appFunc,appParms:="",getZz:="")
{
	sScript:="
	(
		#NoTrayIcon
		getZz = " getZz "
		try appPlugins := ComObjActive(""" GUID """)
		appPlugins[""" appFunc """](" appParms ")
	)"
	PID:=DynaRun(sScript)
}
;[动态获得AHK代码结果值]
DynaExpr_EvalToVar(sExpr,getZz:="")
{
	sTmpFile := A_Temp "\temp.ahk"
	sScript:="
	(
		#NoTrayIcon
		FileDelete " sTmpFile "
		getZz = " getZz "
		val := " sExpr "
		FileAppend %val%, " sTmpFile "
	)"
	PID:=DynaRun(sScript)
	Process,WaitClose,%PID%
	FileRead sResult, %sTmpFile%
	return sResult
}
;[动态执行AHK代码]
DynaRun(TempScript, pipename="", params="")
{
	static _:="uint",@:="Ptr"
	If pipename =
		name := "AHK" A_TickCount
	Else
		name := pipename
	__PIPE_GA_ := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,2,_,0,_,255,_,0,_,0,@,0,@,0)
	__PIPE_    := DllCall("CreateNamedPipe","str","\\.\pipe\" name,_,2,_,0,_,255,_,0,_,0,@,0,@,0)
	if (__PIPE_=-1 or __PIPE_GA_=-1)
		Return 0
	If A_IsCompiled || (A_IsDll && DllCall(A_AhkPath "\ahkgetvar","Str","A_IsCompiled")) ; allow compiled executable to execute dynamic scripts. Requires AHK_H
		Run, % """" A_AhkPath """" (params?" ":"") params " /E ""\\.\pipe\" name """",,UseErrorLevel HIDE, PID
	else
		Run, % """" A_AhkPath """" (params?" ":"") params " ""\\.\pipe\" name """",,UseErrorLevel HIDE, PID
	If ErrorLevel
		MsgBox, 262144, ERROR,% "Could not open file:`n" __AHK_EXE_ """\\.\pipe\" name """"
	DllCall("ConnectNamedPipe",@,__PIPE_GA_,@,0)
	DllCall("CloseHandle",@,__PIPE_GA_)
	DllCall("ConnectNamedPipe",@,__PIPE_,@,0)
	script := (A_IsUnicode ? chr(0xfeff) : (chr(239) . chr(187) . chr(191))) TempScript
	if !DllCall("WriteFile",@,__PIPE_,"str",script,_,(StrLen(script)+1)*(A_IsUnicode ? 2 : 1),_ "*",0,@,0)
		Return A_LastError,DllCall("CloseHandle",@,__PIPE_)
	DllCall("CloseHandle",@,__PIPE_)
	Return PID
}
;[改进版URLDownloadToFile，来源于：http://ahkcn.net/thread-5658.html]
URLDownloadToFile(URL, FilePath, Options:="", RequestHeaders:="")
{
	Options:=this.解析信息到对象(Options)
	RequestHeaders:=this.解析信息到对象(RequestHeaders)

	ComObjError(0)	;禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")

	if (Options["EnableRedirects"]<>"")	;设置是否获取跳转后的页面信息
		WebRequest.Option(6):=Options["EnableRedirects"]
	;proxy_setting没值时，根据Proxy值的情况智能设定是否要进行代理访问。
	;这样的好处是多数情况下需要代理时依然只用给出代理服务器地址即可。而在已经给出代理服务器地址后，又可以很方便的对是否启用代理进行开关。
	if (Options["proxy_setting"]="" and Options["Proxy"]<>"")
		Options["proxy_setting"]:=2	;0表示 Proxycfg.exe 运行了且遵循 Proxycfg.exe 的设置（没运行则效果同设置为1）。1表示忽略代理直连。2表示使用代理
	if (Options["proxy_setting"]="" and Options["Proxy"]="")
		Options["proxy_setting"]:=1
	;设置代理服务器。微软的代码 SetProxy() 是放在 Open() 之前的，所以我也放前面设置，以免无效
	WebRequest.SetProxy(Options["proxy_setting"],Options["Proxy"],Options["ProxyBypassList"])
	if (Options["Timeout"]="")		;Options["Timeout"]如果被设置为-1，并不代表无限超时，而是依然遵循SetTimeouts第4个参数设置的最大超时时间
		WebRequest.SetTimeouts(0,60000,30000,0)		;0或-1都表示超时无限等待，正整数则表示最大超时（单位毫秒）
	else if (Options["Timeout"]>30)				;如果超时设置大于30秒，则需要将默认的最大超时时间修改为大于30秒
		WebRequest.SetTimeouts(0,60000,30000,Options["Timeout"]*1000)
	else
		WebRequest.SetTimeouts(0,60000,30000,30000)	;此为SetTimeouts的默认设置。这句可以不加，因为默认就是这样，加在这里是为了表述清晰。

	WebRequest.Open("GET", URL, true)   			;true为异步获取。默认是false，龟速的根源！！！卡顿的根源！！！

	;SetRequestHeader() 必须 Open() 之后才有效
	for k, v in RequestHeaders
	{
		if (k="Cookie")
		{
			WebRequest.SetRequestHeader("Cookie","tuzi")    ;先设置一个cookie，防止出错，msdn推荐这么做
			WebRequest.SetRequestHeader("Cookie",v)
		}
		WebRequest.SetRequestHeader(k,v)
	}

	Loop
	{
		WebRequest.Send()
		WebRequest.WaitForResponse(-1)		;WaitForResponse方法确保获取的是完整的响应。-1表示总是使用SetTimeouts设置的超时

		;获取状态码，一般status为200说明请求成功
		this.Status:=WebRequest.Status()
		this.StatusText:=WebRequest.StatusText()

		if (Options["expected_status"]="" or Options["expected_status"]=this.Status)
			break
		;尝试指定次数后页面返回的状态码依旧与预期状态码不一致，则抛出错误及详细错误信息（可使用我另一个错误处理函数专门记录处理它们）
		;即使number_of_retries为空，表达式依然成立，所以不用为number_of_retries设置初始值。
		else if (A_Index>=Options["number_of_retries"])
		{
			this.extra.URL:=URL
			this.extra.Expected_Status:=Options["expected_status"]
			this.extra.Status:=this.Status
			this.extra.StatusText:=this.StatusText
			throw, Exception("经过" Options.number_of_retries "次尝试后，服务器返回状态码依旧与期望值不一致", -1, Object(this.extra))
		}
	}

	ADO:=ComObjCreate("adodb.stream")   		;使用 adodb.stream 编码返回值。参考 http://bbs.howtoadmin.com/ThRead-814-1-1.html
	ADO.Type:=1									;以二进制方式操作
	ADO.Mode:=3 								;可同时进行读写
	ADO.Open()  								;开启物件
	ADO.Write(WebRequest.ResponseBody())    	;写入物件。注意没法将 WebRequest.ResponseBody() 存入一个变量，所以必须用这种方式写文件
	ADO.SaveToFile(FilePath,2)   				;文件存在则覆盖
	ADO.Close()
	this.ResponseHeaders:=this.解析信息到对象(WebRequest.GetAllResponseHeaders())
	return, 1
}
donothing:
return
;══════════════════════════════════════════════════════════════════
;~;【══🔩内部函数方法══】
;══════════════════════════════════════════════════════════════════
;[写入配置]
Var_Set(vGui, var, sz){
	StringCaseSense, On
	if(vGui!=var){
		if(vGui=""){
			IniDelete,%RunAnyConfig%,Config,%sz%
		}else{
			IniWrite,%vGui%,%RunAnyConfig%,Config,%sz%
		}
	}
	StringCaseSense, Off
}
;[读取配置]
Var_Read(rValue,defVar=""){
	IniRead, regVar,%RunAnyConfig%, Config, %rValue%,% defVar ? defVar : A_Space
	if(regVar!=""){
		if(defVar!="" && regVar=defVar){
			IniDelete, %RunAnyConfig%, Config, %rValue%
		}
		if(InStr(regVar,"ZzIcon.dll") && !FileExist(A_ScriptDir "\ZzIcon.dll"))
			return defVar
		else
			return regVar
	}else{
		IniDelete, %RunAnyConfig%, Config, %rValue%
		return defVar
	}
}
;[控制提示信息的显示时长]
RemoveToolTip:
	if(A_TimeIdle<2500){
		SetTimer,RemoveToolTip,Off
		ToolTip
	}
return
RemoveDebugModeToolTip:
	SetTimer,RemoveDebugModeToolTip,Off
	DebugModeShowText:=""
	DebugModeShowTextLen:=0
	ToolTip
return
HideTrayTip(){
	TrayTip
}
;[临时脚本显示提示信息，不受主脚本重启影响]
ShowTrayTip(title,text,seconds,options){
	DeleteFile(A_Temp "\" RunAnyZz "\RunAnyTrayTip.ahk")
	FileAppend,
	(
#NoEnv
Menu,Tray,Icon,SHELL32.dll,50
TrayTip, %title%, %text%, %seconds%, %options%
Sleep,10000
ExitApp
	),%A_Temp%\%RunAnyZz%\RunAnyTrayTip.ahk
	Run,%A_AhkPath%%A_Space%"%A_Temp%\%RunAnyZz%\RunAnyTrayTip.ahk"
}
;~[鼠标悬停在托盘图标上时显示初始化信息]
Menu_Tray_Tip(tText,tmpText:=""){
	MenuTrayTipText.=tText
	Menu,Tray,Tip,% MenuTrayTipText tmpText
	return MenuTrayTipText
}
;~[鼠标悬停在托盘图标上时显示运行路径信息]
Menu_Run_Tray_Tip(tText,tmpText:=""){
	if(Menu_Tray_Tip(tText,tmpText)!=A_IconTip){
		MenuTrayTipText:="运行路径`n" tText tmpText
		Menu,Tray,Tip,%MenuTrayTipText%
	}
}
;~[菜单调试模式下的调试信息]
Menu_Debug_Mode(tText,tmpText:=""){
	if(DebugMode){
		DebugModeShowText.=tText
		if(StrLen(tText)>DebugModeShowTextLen)
			DebugModeShowTextLen:=StrLen(tText)
		CoordMode, ToolTip
		ToolTip,%DebugModeShowText%`n%tmpText%,A_ScreenWidth-DebugModeShowTextLen,0,1
		SetTimer,RemoveDebugModeToolTip,%DebugModeShowTime%
		WinSet, Transparent, % DebugModeShowTrans/100*255, ahk_class tooltips_class32
	}
}
;~;{获取菜单项启动模式}
;~;1-启动路径|2-短语模式|3-模拟打字短语|4-热键映射|5-AHK热键映射|6-网址|60-程序参数中带网址
;~;7-文件夹|8-插件脚本函数
;~;10-菜单分类|11-分割符|12-注释说明
Get_Menu_Item_Mode(item,fullItemFlag:=false){
	if(fullItemFlag){
		if(InStr(item,";")=1)
			return 12
		if(RegExMatch(item,"S)^-+[^-]+.*"))
			return 10
		if(RegExMatch(item,"S)^-+$") || RegExMatch(item,"S)^\|+$"))
			return 11
		menuItems:=StrSplit(item,"|",,2)
		item:=(menuItems[2]) ? menuItems[2] : menuItems[1]
	}
	len:=StrLen(item)
	if(len=0)
		return 1
	if(InStr(item,";",,0,1)=len)
		return InStr(item,";;",,0,1)=len-1 ? 3 : 2
	if(InStr(item,"::",,0,1)=len-1)
		return InStr(item,":::",,0,1)=len-2 ? 5 : 4
	if(RegExMatch(item,"iS)^.*?\.(exe|lnk|bat|cmd|vbs|ps1|ahk) .*?([\w-]+://?|www[.]).*"))
		return 60
	if(RegExMatch(item,"iS)^([\w-]+://?|www[.]).*"))
		return 6
	if(RegExMatch(item,"S).+?\[.+?\]%?\(.*?\)"))
		return 8
	if((RegExMatch(item,"S)^.:\\.*") && InStr(FileExist(item), "D")))
		return 7
	if(RegExMatch(item,"S)^\\.*"))
		return 71
	return 1
}
;[获取分类名称]
Get_Tree_Name(z_item,show_key=true){
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|",,2)
		z_item:=menuDiy[1]
		if(show_key && InStr(menuDiy[1],"`t")){
			menuKeyStr:=RegExReplace(menuDiy[1], "S)\t+", A_Tab)
			menuKeys:=StrSplit(menuKeyStr,"`t")
			z_item:=menuKeys[1]
		}
	}
	return RegExReplace(z_item,"S)^-+")
}
;[获取应用名称]
Get_Obj_Transform_Name(z_item){
	return Get_Obj_Name(Get_Transform_Val(z_item))
}
Get_Obj_Name(z_item){
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|",,2)
		return menuDiy[1]
	}else if(RegExMatch(z_item,"iS)^(\\\\|.:\\).*?\.exe$")){
		SplitPath,z_item,fileName,,,menuItem
		return menuItem
	}else{
		return RegExReplace(z_item,"iS)\.exe$")
	}
}
;[获取应用路径]
Get_Obj_Path(z_item){
	obj_path:=""
	if(InStr(z_item,"|")){
		menuDiy:=StrSplit(z_item,"|",,2)
		obj_path:=MenuObj[menuDiy[1]]
	}else{
		z_item:=RegExReplace(z_item,"iS)(.*?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数，取路径
		if(RegExMatch(z_item,"iS)^(\\\\|.:\\).*?\.exe$")){
			obj_path:=z_item
		}else{
			appName:=RegExReplace(z_item,"iS)\.exe$")
			obj_path:=MenuObj[appName]="" ? z_item : MenuObj[appName]
		}
	}
	if(RegExMatch(obj_path,"iS).*?\.[a-zA-Z0-9-_]+($| .*)")){
		obj_path:=RegExReplace(obj_path,"iS)(\.[a-zA-Z0-9-_]+)($| .*)","$1")
	}
	if(obj_path!="" && !InStr(obj_path,"\")){
		if(FileExist(A_WinDir "\" obj_path))
			obj_path=%A_WinDir%\%obj_path%
		if(FileExist(A_WinDir "\system32\" obj_path))
			obj_path=%A_WinDir%\system32\%obj_path%
		return obj_path
	}else if(!InStr(obj_path,"..\")){
		return obj_path
	}else{
		val:=RegExReplace(obj_path,"\.\.\\.*?$")
		aPath:=StrReplace(obj_path,val)
		absolute:=funcPath2AbsoluteZz(aPath,val)
		return absolute ? absolute : obj_path
	}
}
;[获取变量转换后的应用路径]
Get_Obj_Path_Transform(z_item){
	if(z_item="")
		return z_item
	itemPath:=Get_Transform_Val(z_item) ; 变量转换
	objPathItem:=Get_Obj_Path(itemPath) ; 自动添加完整路径
	if(objPathItem && itemPath!=objPathItem){
		appParm:=RegExReplace(itemPath,"iS).*?\.exe($| .*)","$1")	;去掉应用名，取参数
		itemPath:=objPathItem
		if(appParm!=""){
			itemPath:=objPathItem . appParm
		}
	}
	return itemPath
}
;[判断后返回该菜单项最佳的启动路径]
Get_Item_Run_Path(z_item_path){
	SplitPath,z_item_path,fileName,,,itemName
	if(InStr(FileExist(z_item_path), "D"))
		return z_item_path
	if(!Check_Obj_Ext(z_item_path))
		return z_item_path
	any:=MenuObj[fileName] ? MenuObj[fileName] : MenuObj[itemName]
	if(any && any!=z_item_path){
		return z_item_path
	}
	return fileName
}
;[打开文件夹(支持使用第三方文件管理器)]
Open_Folder_Path(path){
	If(OpenFolderPathRun){
		Run,%OpenFolderPathRun%%A_Space%"%path%"
	}else{
		Run,%path%
	}
}
;[检查文件后缀是否支持无路径查找]
Check_Obj_Ext(filePath){
	EvExtFlag:=false
	fileValue:=RegExReplace(filePath,"iS)(.*?\.[a-zA-Z0-9-_]+)($| .*)","$1")	;去掉参数
	SplitPath, fileValue, fName,, fExt  ; 获取扩展名
	Loop,% EvCommandExtList.MaxIndex()
	{
		EvCommandExtStr:=StrReplace(EvCommandExtList[A_Index],"*.")
		if(fExt=EvCommandExtStr){
			EvExtFlag:=true
			break
		}
	}
	if(!EvExtFlag && fExt)
		return false
	else
		return true
}
;[自动调整列表宽度]
LVModifyCol(width, colList*){
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	for index,col in colList
	{
		LV_ModifyCol(col, width)
		LV_ModifyCol(col, "center")
	}
}
;~;[外部动态运行函数和插件]
Remote_Dyna_Run(remoteRun, remoteGetZz, remoteFlag:=false){
	getZz:=remoteGetZz
	if(IsLabel(remoteRun)){
		Gosub,%remoteRun%
		return
	}
	if(remoteFlag){
		if(RegExMatch(remoteRun,"S).+?\[.+?\]%?\(.*?\)")){
			global any:=remoteRun
			SetTimer,Menu_Run_Plugins_ObjReg,-1
		}else{
			Remote_Menu_Run(remoteRun, remoteGetZz)
		}
		return
	}
	global any:=remoteRun
	if(RegExMatch(remoteRun,"S).+?\[.+?\]%?\(.*?\)")){
		Gosub,Menu_Run_Plugins_ObjReg
	}else{
		;[获取菜单项启动模式]
		global itemMode:=Get_Menu_Item_Mode(any)
		;[根据菜单项模式运行]
		global returnFlag:=false
		Gosub,Menu_Run_Mode_Label
		if(returnFlag)
			return
		Run_Any(Get_Obj_Path_Transform(any))
	}
}
;[外部调用运行菜单项]
Remote_Menu_Run(remoteRun, remoteGetZz:=""){
	global RemoteMenuRunFlag:=true
	;	getZz:=remoteGetZz 这个参数外部调用，如果参数内容有特殊符号就报错
	getZz:=Get_Zz()
	OutsideMenuItem:=remoteRun
	OutsideMenuItem:= StrReplace(OutsideMenuItem, "生僻窥察1","%")
	Gosub, Menu_Run
}
;[外部调用显示后缀菜单]
Remote_Menu_Ext_Show(fileExt){
	getZz:=Get_Zz()
	extMenuName:=MenuObjExt[FileExt]
	If (extMenuName="" || FileExt="public")
		extMenuName := "public"
	Menu_Show_Show(extMenuName, getZz)
}
;[外部调用显示悬浮菜单有图标]
Remote_PMI_run(caidanxiang){
	caidanxiangiconpath:= MenuObjIconList[caidanxiang]
	caidanxiangiconNo:= MenuObjIconNoList[caidanxiang]
	caidanxiang1 := StrReplace(caidanxiang, """","\""")
	if FileExist(A_ScriptDir "\RunPlugins\xiaoyao_command.ahk")
		run,"%A_ScriptDir%\RunAny.exe" "%A_ScriptDir%\RunPlugins\xiaoyao_command.ahk" -PMI "%caidanxiang1%" "%caidanxiangiconpath%" "%caidanxiangiconNo%"
	Else
		MsgBox, 出错了!`n请先下载xiaoyao_command.ahk插件到RunPlugins目录
	return
}
;[外部调用显示指定分类名称的菜单]
Remote_Menuname_Show(Menu_name){
	getZz:=Get_Zz()
	Menu_Show_Show(Menu_name,getZz)
}
;══════════════════════════════════════════════════════════════════
;~;【══🧩插件函数方法══】
;══════════════════════════════════════════════════════════════════
;调用huiZz_Text插件函数
SendStrDecrypt(any,key:=""){
	try{
		if(encryptFlag){
			key:=(key="") ? SendStrDcKey : key
			PluginsObjRegActive["huiZz_Text"]:=ComObjActive(PluginsObjRegGUID["huiZz_Text"])
			anyval:=PluginsObjRegActive["huiZz_Text"]["runany_decrypt"](any,key)
			return anyval
		}
	} catch {}
		return any
}
SendStrEncrypt(any,key:=""){
	try{
		if(encryptFlag){
			key:=(key="") ? SendStrDcKey : key
			PluginsObjRegActive["huiZz_Text"]:=ComObjActive(PluginsObjRegGUID["huiZz_Text"])
			anyval:=PluginsObjRegActive["huiZz_Text"]["runany_encrypt"](any,key)
			return anyval
		}
	} catch {}
		return any
}
;RunAny搜索框插件
RunAny_SearchBar:
	if(rule_check_is_run(PluginsPathList["RunAny_SearchBar.ahk"])){
		DeleteFile(RunAEvFullPathIniDirPath "\RunAnyMenuObj.ini")
		DeleteFile(RunAEvFullPathIniDirPath "\RunAnyMenuObjExt.ini")
		DeleteFile(RunAEvFullPathIniDirPath "\RunAnyMenuObjIcon.ini")
		for k,v in MenuObj
		{
			if(v="" || MenuObjKeyList[k])
				continue
			IniWrite, % v, %RunAEvFullPathIniDirPath%\RunAnyMenuObj.ini, MenuObj, %k%
		}
		for k,v in MenuObjExt
		{
			IniWrite, % v, %RunAEvFullPathIniDirPath%\RunAnyMenuObjExt.ini, MenuObjExt, %k%
		}
		for k,v in MenuObjIconList
		{
			if(v="")
				continue
			if(MenuObjKeyList[k]){
				klist:=StrSplit(k,"`t",,2)
				k:=klist[1]
			}
			IniWrite, % v "," MenuObjIconNoList[k], %RunAEvFullPathIniDirPath%\RunAnyMenuObjIcon.ini, MenuObjIcon, %k%
		}
	}
return
Plugins_Down_Check(name, path){
	FileRead, content, %path%
	if(!content || InStr(content,"404: Not Found") || InStr(content,"404 Not Found")){
		MsgBox,48,,%name% 下载失败，请重新勾选下载！
	}
}
;[插件检查版本更新]
PluginsDownVersion:
	if(!rule_check_network(giteeUrl)){
		RunAnyDownDir:=githubUrl . RunAnyGithubDir
		if(!rule_check_network(githubUrl)){
			TrayTip,网络异常,无法连接网络读取最新版本文件，请手动下载,5,2
			pluginsDownList:=PluginsObjList
			checkGithub:=false
			return
		}
	}
	CreateDir(A_Temp "\" RunAnyZz "\" PluginsDir)
	ObjRegIniPath=%A_Temp%\%RunAnyZz%\%PluginsDir%\%RunAny_ObjReg%
	URLDownloadToFile(RunAnyDownDir "/" PluginsDir "/" RunAny_ObjReg, ObjRegIniPath)
	IfExist,%ObjRegIniPath%
	{
		FileGetSize, ObjRegIniSize, %ObjRegIniPath%
		if(ObjRegIniSize>500){
			IniRead,objRegIniVar,%ObjRegIniPath%,version
			Loop, parse, objRegIniVar, `n, `r
			{
				varList:=StrSplit(A_LoopField,"=",,2)
				pluginsDownList[(varList[1])]:=varList[2]
			}
			IniRead,objRegIniVar,%ObjRegIniPath%,name
			Loop, parse, objRegIniVar, `n, `r
			{
				varList:=StrSplit(A_LoopField,"=",,2)
				pluginsNameList[(varList[1])]:=varList[2]
			}
			checkGithub:=true
			return
		}
	}
	pluginsDownList:=PluginsObjList
	checkGithub:=false
return
