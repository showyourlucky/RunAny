;══════════════════════════════════════════════════════════════════
;~;【——🌏检查更新——】
;══════════════════════════════════════════════════════════════════
Check_Update:
	checkUpdateFlag:=true
	TrayTip,,RunAny检查更新中……,2,17
	SetTimer, HideTrayTip, -2000
	Gosub,Auto_Update
return
Auto_Update:
	DeleteFile(A_Temp "\" RunAnyZz "\RunAny_Update.bat")
	;[下载最新的更新脚本]
	if(!rule_check_network(giteeUrl)){
		RunAnyDownDir:=githubUrl . RunAnyGithubDir
		if(!rule_check_network(githubUrl)){
			TrayTip,网络异常,无法连接网络读取最新版本文件,5,2
			return
		}
	}
	URLDownloadToFile(RunAnyDownDir "/RunAny.ahk",A_Temp "\temp_RunAny.ahk")
	versionReg=iS)^\t*\s*global RunAny_update_version:="([\d\.]*)".*
	Loop, read, %A_Temp%\temp_RunAny.ahk
	{
		if(RegExMatch(A_LoopReadLine,versionReg)){
			versionStr:=RegExReplace(A_LoopReadLine,versionReg,"$1")
			break
		}
		if(A_LoopReadLine="404: Not Found"){
			TrayTip,,文件下载异常，更新失败！,5,2
			return
		}
	}
	if(versionStr){
		Gosub,Plugins_Read
		Gosub,PluginsDownVersion
		runAnyUpdateStr:=pluginUpdateStr:=""
		For pk, pv in pluginsDownList
		{
			if(PluginsVersionList[pk] < pv){
				pluginUpdateStr.=pk A_Tab PluginsVersionList[pk] "`t版本更新后=>`t" pv "`n"
			}
		}
		if(RunAny_update_version<versionStr || pluginUpdateStr!=""){
			runAnyUpdateStr:=RunAny_update_version<versionStr ? "检测到RunAny有新版本`n`n" RunAny_update_version "`t版本更新后=>`t" versionStr "`n" : ""
			pluginUpdateStr:=pluginUpdateStr!="" ? "`n检测到插件有新版本`n" pluginUpdateStr : ""
			MsgBox,33,RunAny检查更新,%runAnyUpdateStr%%pluginUpdateStr%`n
(
是否更新到最新版本？
将移动老版本文件到临时目录，如有修改过请注意备份！`n%A_Temp%\%RunAnyZz%`n
)
			IfMsgBox Ok
			{
				TrayTip,,RunAny开始下载最新版本并替换老版本...,3,17
				SetTimer, HideTrayTip, -3000
				;[下载插件脚本]
				if(pluginUpdateStr!=""){
					For pk, pv in pluginsDownList
					{
						if(PluginsVersionList[pk] < pv && FileExist(PluginsPathList[pk])){
							FileMove,% PluginsPathList[pk],%A_Temp%\%RunAnyZz%\%PluginsDir%\%pk%,1
							URLDownloadToFile(RunAnyDownDir "/" StrReplace(PluginsRelativePathList[pk],"\","/"), A_ScriptDir "\" PluginsRelativePathList[pk])
							Sleep,1000
							Plugins_Down_Check(pk, A_ScriptDir "\" PluginsRelativePathList[pk])
						}
					}
					TrayTip,,插件脚本已经更新到最新版本。,3,1
					SetTimer, HideTrayTip, -3000
				}
				;[下载新版本]
				if(RunAny_update_version<versionStr){
					URLDownloadToFile(RunAnyDownDir "/RunAny.exe",A_Temp "\temp_RunAny.exe")
					Gosub,RunAny_Update
					shell := ComObjCreate("WScript.Shell")
					shell.run(A_Temp "\" RunAnyZz "\RunAny_Update.bat",0)
					ExitApp
				}
			}
		}else if(checkUpdateFlag){
			FileDelete, %A_Temp%\temp_RunAny.ahk
			TrayTip,,RunAny已经是最新版本。,5,1
			checkUpdateFlag:=false
		}
	}
return
RunAny_Update:
	if(rule_check_network(RunAnyGiteePages)){
		Run,%RunAnyGiteePages%/runany/#/change-log?id=runany已更新最新版本！感谢一直以来的支持！
	}else{
		Run,%RunAnyGithubPages%/RunAny/#/change-log?id=runany已更新最新版本！感谢一直以来的支持！
	}
	TrayTip,,RunAny已经更新到最新版本。,5,1
	FileAppend,
(
@ECHO OFF & setlocal enabledelayedexpansion & TITLE RunAny更新版本
set /a x=1
:BEGIN
set /a x+=1
ping -n 2 127.1>nul
if exist "%A_Temp%\temp_RunAny.ahk" `(
  MOVE /y "%A_Temp%\temp_RunAny.ahk" "%A_ScriptDir%\RunAny.ahk"
`)
if exist "%A_Temp%\temp_RunAny.exe" `(
  MOVE /y "%A_Temp%\temp_RunAny.exe" "%A_ScriptDir%\RunAny.exe"
`)
goto INDEX
:INDEX
if !x! GTR 10 `(
  exit
`)
if exist "%A_Temp%\temp_RunAny.ahk" `(
  goto BEGIN
`)
if exist "%A_Temp%\temp_RunAny.exe" `(
  if !x! EQU 5 `(
    taskkill /f /im %A_ScriptName%
  `)
  goto BEGIN
`)
start "" "%A_ScriptDir%\RunAny.exe"
exit
),%A_Temp%\%RunAnyZz%\RunAny_Update.bat
return
;══════════════════════════════════════════════════════════════════
;~;【托盘菜单】
Menu_Tray_Add:
	Menu,Tray,NoStandard
	Menu,Tray,add,显示菜单(&Z)`t%MenuHotKey%,Menu_Tray_Show
	Menu,Tray,add,修改菜单(&E)`t%TreeHotKey1%,Menu_Edit1
	Menu,Tray,add,修改文件(&F)`t%TreeIniHotKey1%,Menu_Ini
	Menu,Tray,add
	If(MENU2FLAG){
		Menu,Tray,add,显示菜单2(&2)`t%MenuHotKey2%,Menu_Show2
		Menu,Tray,add,修改菜单2(&W)`t%TreeHotKey2%,Menu_Edit2
		Menu,Tray,add,修改文件2(&G)`t%TreeIniHotKey2%,Menu_Ini2
		Menu,Tray,add
	}
	Menu,Tray,add,插件管理(&C)`t%PluginsManageHotKey%,Plugins_Gui
	Menu,Tray,add,启动管理(&Q)`t%RunCtrlManageHotKey%,RunCtrl_Manage_Gui
	Menu,Tray,add,菜单列表(&T),RunA_MenuObj_Show
	Menu,Tray,add
	Menu,Tray,add,设置RunAny(&D)`t%RunASetHotKey%,Settings_Gui
	Menu,Tray,add,关于RunAny(&A)...,Menu_About
	Menu,Tray,add,检查更新(&U),Check_Update
	Menu,Tray,add
	Menu,Tray,add,重启(&R)`t%RunAReloadHotKey%,Menu_Reload
	Menu,Tray,add,停用(&S)`t%RunASuspendHotKey%,Menu_Suspend
	Menu,Tray,add,退出(&X)`t%RunAExitHotKey%,Menu_Exit
	Menu,Tray,Default,显示菜单(&Z)`t%MenuHotKey%
	Menu,Tray,Click,1
	;[RunAny菜单图标初始化]
	try {
		Menu,Tray,Icon,% MenuIconS[1],% MenuIconS[2]
		Menu,Tray,Icon,显示菜单(&Z)`t%MenuHotKey%,% ZzIconS[1],% ZzIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,修改菜单(&E)`t%TreeHotKey1%,% TreeIconS[1],% TreeIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,修改文件(&F)`t%TreeIniHotKey1%,% EditFileIconS[1],% EditFileIconS[2],%MenuTrayIconSize%
		If(MENU2FLAG){
			Menu,Tray,Icon,显示菜单2(&2)`t%MenuHotKey2%,% ZzIconS[1],% ZzIconS[2],%MenuTrayIconSize%
			Menu,Tray,Icon,修改菜单2(&W)`t%TreeHotKey2%,% TreeIconS[1],% TreeIconS[2],%MenuTrayIconSize%
			Menu,Tray,Icon,修改文件2(&G)`t%TreeIniHotKey2%,% EditFileIconS[1],% EditFileIconS[2],%MenuTrayIconSize%
		}
		Menu,Tray,Icon,菜单列表(&T),imageres.dll,112,%MenuTrayIconSize%
		Menu,Tray,Icon,插件管理(&C)`t%PluginsManageHotKey%,% PluginsManageIconS[1],% PluginsManageIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,启动管理(&Q)`t%RunCtrlManageHotKey%,% RunCtrlManageIconS[1],% RunCtrlManageIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,设置RunAny(&D)`t%RunASetHotKey%,% MenuIconS[1],% MenuIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,关于RunAny(&A)...,% AnyIconS[1],% AnyIconS[2],%MenuTrayIconSize%
		Menu,Tray,Icon,检查更新(&U),% CheckUpdateIconS[1],% CheckUpdateIconS[2],%MenuTrayIconSize%
	} catch e {
		TrayTip,,% "托盘菜单图标错误：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message,5,3
	}
return
Menu_Tray:
	Menu,Tray,Show
return
Menu_Ini:
	Ini_Run(iniPath)
return
Menu_Ini2:
	Ini_Run(iniPath2)
return
Menu_Config:
	Ini_Run(RunAnyConfig)
return
Menu_Reload:
	Critical
	Run,%A_AhkPath% /force /restart "%A_ScriptFullPath%"
ExitApp
return
Menu_Suspend:
	Menu,tray,ToggleCheck,停用(&S)`t%RunASuspendHotKey%
	Suspend
return
Menu_Exit:
ExitApp
return
Ini_Run(ini){
	try{
		if(!FileExist(ini)){
			MsgBox,16,%ini%,没有找到配置文件：%ini%
		}
		Run,"%ini%"
	}catch{
		Run,notepad.exe "%ini%"
	}
}
;══════════════════════════════════════════════════════════════════
;~;[导入桌面程序菜单]
Desktop_Import:
	MsgBox,33,导入桌面程序,确定导入桌面程序到菜单当中吗？
	IfMsgBox Ok
	{
		Gosub,Desktop_Append
		Gosub,Menu_Reload
	}
return
Desktop_Append:
	desktopItem:="`n-桌面(&Desktop)`n"
	desktopDir:=""
	Loop,%A_Desktop%\*.lnk,0,1
	{
		if(A_LoopFileDir!=A_Desktop && A_LoopFileDir!=desktopDir){
			desktopDir:=A_LoopFileDir
			StringReplace,dirItem,desktopDir,%A_Desktop%\
			desktopItem.="`t--" dirItem "`n"
		}
		desktopItem.="`t" A_LoopFileName "`n"
	}
	desktopItem.="`n"
	desktopDir:=""
	Loop,%A_Desktop%\*.exe,0
	{
		desktopItem.="`t" A_LoopFileName "`n"
	}
	FileAppend,%desktopItem%,%iniFile%
return
;~;【——初次运行——】
First_Run:
	FileAppend,
(
;以【;】开头代表注释
;以【-】开头+名称表示1级分类
-常用(&App)
	Chrome浏览器|chrome.exe
	;多个同名iexplore.exe用全路径指定运行32位IE
	;在【|】前加上IE(&E)的简称显示
	IE(&E)|`%ProgramFiles`%\Internet Explorer\iexplore.exe
	;2级分隔符【--】
	--
	StrokesPlus鼠标手势|StrokesPlus.exe
	Ditto剪贴板|Ditto.exe
-办公(&Work)|doc docx xls xlsx ppt pptx wps et dps
	word(&W)|winword.exe
	Excel(&E)|excel.exe
	PPT(&T)|powerpnt.exe
	;以【--】开头名称表示2级分类
	--WPS(&S)
		WPS(&W)|WPS.exe
		ET(&E)|et.exe
		WPP(&P)|wpp.exe
	--
-网址(U&RL)
	;在别名最末尾添加Tab制表符+热键(参考AHK写法:^代表Ctrl !代表Alt #代表Win +代表Shift)，如选中文字按Alt+z百度
	百度(&B)	!z|https://www.baidu.com/s?wd=
	谷歌(&G)	!g|https://www.google.com/search?q=`%s&gws_rd=ssl
	翻译(&F)	#z|https://translate.google.cn/#auto/zh-CN/
	异次元软件|http://www.iplaysoft.com/search/?s=548512288484505211&q=`%s
	淘宝(&T)|https://s.taobao.com/search?q=`%s
	京东(&D)|https://search.jd.com/Search?keyword=`%s&enc=utf-8
	知乎(&Z)|https://www.zhihu.com/search?type=content&q=
	B站|http://search.bilibili.com/all?keyword=`%s
	--
	RunAny地址|https://github.com/hui-Zz/RunAny
-图片(im&G)|bmp gif jpeg jpg png
	画图(&T)|mspaint.exe
	ACDSee.exe
	XnView.exe
	IrfanView.exe
-影音(&Video)|avi mkv mp4 rm rmvb flv wmv swf mp3
	QQPlayer.exe
	PotPlayer.exe
	XMP.exe
	--
	云音乐(&C)|cloudmusic.exe
	QQ音乐|QQMusic.exe
-编辑(&Edit)|txt ini cmd bat md ahk html
	;在别名后面添加_:数字形式来透明启动应用(默认不透明,1-100是全透明到不透明)
	记事本(&N)_:88|notepad.exe
-文件(&File)
	WinRAR.exe
	TC文件管理|Totalcmd.exe
	Everything文件秒搜|Everything.exe
-系统(&Sys)
	cmd.exe
	控制面板(&S)|Control.exe
	;在程序名后空格+带参数启动
	hosts文件|notepad.exe `%A_WinDir`%\System32\drivers\etc\hosts
-输入(inpu&T)
	;当前时间（变量语法参考AHK文档https://wyagd001.github.io/zh-cn/docs/Variables.htm）
	当前时间|`%A_YYYY`%-`%A_MM`%-`%A_DD`% `%A_Hour`%:`%A_Min`%:`%A_Sec`%;
;热键映射,快捷方便,左边Shift+空格=回车键;左手Shift+大小写键=删除键
;左手回车	<+Space|{Enter}::
;左手删除	LShift & CapsLock|{Delete}::
),%iniFile%
	Gosub,Desktop_Append
	FileAppend,
(
-
;1级分隔符【-】并且使下面项目都回归1级分类
QQ.exe
;使用【&】指定快捷键为C,忽略下面C盘的快捷键C
计算器(&C)|calc.exe
我的电脑(&Z)|explorer.exe
;以【\】结尾代表是文件夹路径
C盘|C:\
-
),%iniFile%
	global iniFlag:=true
return

;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
