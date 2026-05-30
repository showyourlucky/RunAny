;~;【AHK插件脚本Read】
Plugins_Read:
	global PluginsObjList:=Object(),PluginsPathList:=Object(),PluginsRelativePathList:=Object(),PluginsNameList:=Object(),pluginsDownList:=Object()
	global PluginsVersionList:=Object(),PluginsIconList:=Object(),PluginsContentList:=Object()
	global PluginsObjNum:=0
	global PluginsDirList:=[]
	global PluginsEditor:=Var_Read("PluginsEditor")
	global PluginsDirPath:=Var_Read("PluginsDirPath")
	global PluginsListViewSwap:=Var_Read("PluginsListViewSwap",0)
	global PluginsDirPathList:="%A_ScriptDir%\%PluginsDir%|" PluginsDirPath
	Loop, parse, PluginsDirPathList, |
	{
		PluginsFolder:=Get_Transform_Val(A_LoopField)
		PluginsFolder:=RegExReplace(PluginsFolder,"(.*)\\$","$1")
		if(!FileExist(PluginsFolder))
			continue
		PluginsDirList.Push(PluginsFolder)
		Loop,%PluginsFolder%\*.ahk,0	;Plugins目录下AHK脚本
		{
			PluginsObjList[(A_LoopFileName)]:=0
			PluginsPathList[(A_LoopFileName)]:=A_LoopFileFullPath
			PluginsRelativePathList[(A_LoopFileName)]:=StrReplace(A_LoopFileFullPath,A_ScriptDir "\")
			PluginsNameList[(A_LoopFileName)]:=Plugins_Read_Name(A_LoopFileFullPath)
			PluginsVersionList[(A_LoopFileName)]:=Plugins_Read_Version(A_LoopFileFullPath)
			PluginsIconList[(A_LoopFileName)]:=Plugins_Read_Icon(A_LoopFileFullPath)
			if(A_LoopField="%A_ScriptDir%\%PluginsDir%"){
				FileRead,pluginsContent,%A_LoopFileFullPath%
				PluginsContentList[(A_LoopFileName)]:=pluginsContent
			}
		}
		Loop,%PluginsFolder%\*.*,2	;Plugins目录下文件夹内同名AHK脚本
		{
			IfExist,%A_LoopFileFullPath%\%A_LoopFileName%.ahk
			{
				PluginsObjList[(A_LoopFileName . ".ahk")]:=0
				PluginsPathList[(A_LoopFileName . ".ahk")]:=A_LoopFileFullPath "\" A_LoopFileName ".ahk"
				PluginsRelativePathList[(A_LoopFileName . ".ahk")]:=StrReplace(A_LoopFileFullPath "\" A_LoopFileName ".ahk",A_ScriptDir "\")
				PluginsNameList[(A_LoopFileName . ".ahk")]:=Plugins_Read_Name(A_LoopFileFullPath "\" A_LoopFileName ".ahk")
				PluginsVersionList[(A_LoopFileName . ".ahk")]:=Plugins_Read_Version(A_LoopFileFullPath "\" A_LoopFileName ".ahk")
				PluginsIconList[(A_LoopFileName . ".ahk")]:=Plugins_Read_Icon(A_LoopFileFullPath "\" A_LoopFileName ".ahk")
				if(A_LoopField="%A_ScriptDir%\%PluginsDir%"){
					FileRead,pluginsContent,% A_LoopFileFullPath "\" A_LoopFileName ".ahk"
					PluginsContentList[(A_LoopFileName . ".ahk")]:=pluginsContent
				}
			}
		}
	}
	IniRead,pluginsVar,%RunAnyConfig%,Plugins
	Loop, parse, pluginsVar, `n, `r
	{
		varList:=StrSplit(A_LoopField,"=",,2)
		SplitPath,% varList[1], name,, ext, name_no_ext
		PluginsObjList[(varList[1])]:=varList[2]
		if(varList[2])
			PluginsObjNum++
		Loop,% PluginsDirList.MaxIndex()
		{
			if(FileExist(PluginsDirList[A_Index] "\" varList[1]))
				PluginsPathList[(varList[1])]:=PluginsDirList[A_Index] "\" varList[1]
			if(FileExist(PluginsDirList[A_Index] "\" name_no_ext "\" varList[1]))
				PluginsPathList[(varList[1])]:=PluginsDirList[A_Index] "\" name_no_ext "\" varList[1]
		}
	}
return
;~;【AHK脚本对象注册】
Plugins_Object_Register:
	global PluginsObjRegGUID:=Object()      ;~插件对象注册GUID列表
	global PluginsObjRegActive:=Object()    ;~插件对象注册Active列表
	global RunAny_ObjReg_Path
	RunAny_ObjReg_Path=%A_ScriptDir%\%PluginsDir%\%RunAny_ObjReg%
	IfExist,%RunAny_ObjReg_Path%
	{
		IniRead,objRegVar,%RunAny_ObjReg_Path%,objreg
		Loop, parse, objRegVar, `n, `r
		{
			varList:=StrSplit(A_LoopField,"=",,2)
			PluginsObjRegGUID[(varList[1])]:=varList[2]
		}
	}
	if(PluginsObjRegGUID["huiZz_Text"] && PluginsObjList["huiZz_Text.ahk"]){
		;#判断huiZz_Text插件是否可以文字加解密
		if(InStr(PluginsContentList["huiZz_Text.ahk"],"runany_encrypt(text,key){")
			&& InStr(PluginsContentList["huiZz_Text.ahk"],"runany_decrypt(text,key){")){
			global encryptFlag:=true
		}
	}
	;#判断RunAny_Menu插件是否启用
	if(PluginsObjList["RunAny_Menu.ahk"]){
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"SetTimer,Transparent_Show"))
			global RunAnyMenuTransparentFlag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~Space Up::"))
			global RunAnyMenuSpaceFlag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~RButton Up::"))
			global RunAnyMenuRButtonFlag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~MButton Up::"))
			global RunAnyMenuMButtonFlag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~XButton1 Up::"))
			global RunAnyMenuXButton1Flag:=true
		if(InStr(PluginsContentList["RunAny_Menu.ahk"],"~XButton2 Up::"))
			global RunAnyMenuXButton2Flag:=true
	}
return
Plugins_Read_Name(filePath){
	returnStr:=""
	strRegOld:="iS).*?【(.*?)】.*"
	strRegNew=iS)^\t*\s*global RunAny_Plugins_Name:="(.+?)"
	Loop, read, %filePath%
	{
		if(RegExMatch(A_LoopReadLine,strRegNew)){
			returnStr:=RegExReplace(A_LoopReadLine,strRegNew,"$1")
			break
		}else if(RegExMatch(A_LoopReadLine,strRegOld)){
			returnStr:=RegExReplace(A_LoopReadLine,strRegOld,"$1")
			break
		}
	}
	return returnStr
}
Plugins_Read_Version(filePath){
	returnStr:=""
	strReg=iS)^\t*\s*global RunAny_Plugins_Version:="([\d\.]*)"
	Loop, read, %filePath%
	{
		if(RegExMatch(A_LoopReadLine,strReg)){
			returnStr:=RegExReplace(A_LoopReadLine,strReg,"$1")
			break
		}
	}
	return returnStr
}
;[获取插件图标的路径]
Plugins_Read_Icon(filePath){
	returnStr:=""
	strReg=iS)^\t*\s*global RunAny_Plugins_Icon:="(.+?)"
	Loop, read, %filePath%
	{
		if(RegExMatch(A_LoopReadLine,strReg)){
			returnStr:=RegExReplace(A_LoopReadLine,strReg,"$1")
			break
		}
	}
	if(returnStr=""){
		PluginsFile:=RegExReplace(filePath,"iS)\.ahk$")
		Loop, Parse,% IconFileSuffix "*.exe;", `;
		{
			suffix:=StrReplace(A_LoopField, "*")
			if(FileExist(PluginsFile suffix)){
				return PluginsFile suffix ",1"
			}
		}
	}
	return returnStr
}
;~;【自动启动插件】
AutoRun_Plugins:
	if(!A_AhkPath)
		return
	try {
		For runn, runv in PluginsPathList	;循环启动项
		{
			;需要自动启动的项
			if(PluginsObjList[runn]){
				runValue:=RegExReplace(runv,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
				SplitPath, runValue, name, dir, ext  ; 获取扩展名
				if(dir && FileExist(dir)){
					SetWorkingDir,%dir%
				}
				if(ext="ahk"){
					Run,%A_AhkPath%%A_Space%"%runv%"
				}else{
					Run,%runv%
				}
			}
		}
	} catch e {
		MsgBox,16,自动启动插件出错,% "启动插件名：" runn "`n启动插件路径：" runv
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	} finally {
		SetWorkingDir,%A_ScriptDir%
	}
return
;[随RunAny自动关闭插件]
AutoClose_Plugins:
	DetectHiddenWindows,On
	For runn, runv in PluginsPathList
	{
		if(PluginsObjList[runn]){
			runValue:=RegExReplace(runv,"iS)(.*?\.exe)($| .*)","$1")	;去掉参数
			SplitPath, runValue, name,, ext  ; 获取扩展名
			if(ext="ahk"){
				PostMessage, 0x111, 65405,,, %runv% ahk_class AutoHotkey
			}else if(name){
				Process,Close,%name%
			}
		}
	}
	DetectHiddenWindows,Off
return
