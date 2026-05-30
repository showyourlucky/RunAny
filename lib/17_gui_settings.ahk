;~;【——🔧设置选项Gui——】
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
Settings_Gui:
	if(!MenuIconFlag){
		TrayTip,,RunAny正在初始化，请完成后再打开设置,5,1
		return
	}
	Critical  ;防止短时间内打开多次界面出现问题
	HotKeyFlag:=MenuVarFlag:=OpenExtFlag:=AdvancedConfigFlag:=false
	GUI_WIDTH_66=700
	TAB_WIDTH_66=680
	GROUP_WIDTH_66=660
	GROUP_LISTVIEW_WIDTH_66=650
	GROUP_CHOOSE_EDIT_WIDTH_66=580
	GROUP_ICON_EDIT_WIDTH_66=550
	MARGIN_TOP_66=15
	ev := new everything
	Gui,66:Destroy
	Gui,66:Default
	Gui,66:+Resize
	Gui,66:Margin,30,20
	Gui,66:Font,,Microsoft YaHei
	Gui,66:Add,Tab3,x10 y10 w%TAB_WIDTH_66% vConfigTab gConfigTabSelect +Theme -Background
		,RunAny设置|热键配置|菜单变量|无路径缓存|搜索Everything|一键直达|内部关联|热字符串|图标设置|高级配置
	Gui,66:Tab,RunAny设置,,Exact
	Gui,66:Add,Checkbox,Checked%AutoRun% xm y+%MARGIN_TOP_66% vvAutoRun,开机自动启动
	Gui,66:Add,Checkbox,Checked%AdminRun% x+25 vvAdminRun,管理员权限运行所有软件和插件
	Gui,66:Add,Button,x+20 w245 h20 gSetScheduledTasks,系统任务计划方式：开机管理员启动%RunAnyZz%
	Gui,66:Add,GroupBox,xm-10 y+15 w%GROUP_WIDTH_66% h105,RunAny应用菜单
	Gui,66:Add,Checkbox,Checked%HideFail% xm yp+20 vvHideFail,隐藏失效项
	Gui,66:Add,Checkbox,Checked%HideSend% x+180 vvHideSend,隐藏短语
	Gui,66:Add,Checkbox,Checked%HideWeb% xm yp+20 vvHideWeb,隐藏带`%s网址
	Gui,66:Add,Checkbox,Checked%HideGetZz% x+163 vvHideGetZz,隐藏带`%getZz`%插件脚本
	Gui,66:Add,Checkbox,Checked%HideSelectZz% xm yp+20 vvHideSelectZz gSetHideSelectZz,隐藏选中目标提示
	Gui,66:Add,Checkbox,Checked%HideAddItem% x+144 vvHideAddItem,隐藏【添加到此菜单】
	Gui,66:Add,Checkbox,Checked%HideMenuTray% xm yp+20 vvHideMenuTray,隐藏底部“RunAny设置”
	Gui,66:Add,Edit,x+101 w30 h20 vvRecentMax,%RecentMax%
	Gui,66:Add,Text,x+5 yp+2,最近运行项数量 (0为隐藏)
	Gui,66:Add,Button,x+5 w50 h20 gSetClearRecentMax,清理

	Gui,66:Add,GroupBox,xm-10 y+15 w225 h55,RunAny菜单热键 %MenuHotKey%
	Gui,66:Add,Hotkey,xm yp+20 w150 vvMenuKey,%MenuKey%
	Gui,66:Add,Checkbox,Checked%MenuWinKey% xm+155 yp+3 w55 vvMenuWinKey gSetMenuWinKey,Win
	If(MENU2FLAG){
		Gui,66:Add,GroupBox,x+60 yp-23 w225 h55,菜单2热键 %MenuHotKey2%
		Gui,66:Add,Hotkey,xp+10 yp+20 w150 vvMenuKey2,%MenuKey2%
		Gui,66:Add,Checkbox,Checked%MenuWinKey2% xp+155 yp+3 w55 vvMenuWinKey2 gSetMenuWinKey2,Win
	}else{
		Gui,66:Add,Button,x+60 yp-5 w150 GSetMenu2,开启第2个菜单
	}

	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% h110,RunAny.ini文件设置
	Gui,66:Add,Edit,xm yp+20 w50 h20 vvAutoReloadMTime,%AutoReloadMTime%
	Gui,66:Add,Text,x+5 yp+2,(毫秒)  RunAny.ini修改后自动重启，0为不自动重启
	Gui,66:Add,Checkbox,xm yp+25 Checked%RunABackupRule% vvRunABackupRule,自动备份
	Gui,66:Add,Text,x+5 yp,最多备份数量
	Gui,66:Add,Edit,x+5 yp-2 w70 h20 vvRunABackupMax,%RunABackupMax%
	Gui,66:Add,Text,x+5 yp+2,备份文件名格式
	Gui,66:Add,Edit,x+5 yp-2 w236 h20 vvRunABackupFormat,%RunABackupFormat%
	Gui,66:Add,Button,xm yp+25 GSetRunABackupDir,RunAny.ini自动备份目录
	Gui,66:Add,Edit,x+11 yp+2 w400 r1 vvRunABackupDir,%RunABackupDir%

	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% vvDisableAppGroup,屏蔽RunAny程序列表（英文逗号分隔）
	Gui,66:Font,,Consolas
	Gui,66:Add,Edit,xm yp+25 r4 -WantReturn vvDisableApp,%DisableApp%
	Gui,66:Font,,Microsoft YaHei

	Gui,66:Tab,热键配置,,Exact
	Gui,66:Add,GroupBox,xm-10 y+%MARGIN_TOP_66% w%GROUP_WIDTH_66% h125 vvMultiHotkey,RunAny多种方式启动菜单（与第三方软件热键冲突则取消勾选）
	Gui,66:Add,Checkbox,Checked%MenuDoubleCtrlKey% xm yp+20 vvMenuDoubleCtrlKey,双击Ctrl键
	Gui,66:Add,Checkbox,Checked%MenuDoubleAltKey% x+166 vvMenuDoubleAltKey,双击Alt键
	Gui,66:Add,Checkbox,Checked%MenuDoubleLWinKey% xm yp+20 vvMenuDoubleLWinKey,双击左Win键
	Gui,66:Add,Checkbox,Checked%MenuDoubleRWinKey% x+152 vvMenuDoubleRWinKey,双击右Win键
	Gui,66:Add,Checkbox,Checked%MenuCtrlRightKey% xm yp+20 w160 vvMenuCtrlRightKey,按住Ctrl再按鼠标右键
	Gui,66:Add,Checkbox,Checked%MenuShiftRightKey% x+86 vvMenuShiftRightKey,按住Shift再按鼠标右键
	Gui,66:Add,Checkbox,Checked%MenuXButton1Key% xm yp+20 vvMenuXButton1Key,鼠标X1键
	Gui,66:Add,Checkbox,Checked%MenuXButton2Key% x+171 vvMenuXButton2Key,鼠标X2键
	Gui,66:Add,Checkbox,Checked%MenuMButtonKey% xm yp+20 vvMenuMButtonKey,鼠标中键（需要关闭插件huiZz_MButton.ahk）

	Gui,66:Add,Link,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%
		,%RunAnyZz%热键配置列表（双击修改，按F2可手写AHK使用特殊热键，<a href="https://wyagd001.github.io/zh-cn/docs/KeyList.htm">如Space、CapsLock、Tab等</a>）
	Gui,66:Add,Listview,xm yp+20 w%GROUP_LISTVIEW_WIDTH_66% r16 AltSubmit -ReadOnly -Multi vRunAnyHotkeyLV glistviewHotkey, 热键AHK写法|热键说明|热键变量名
	kvLenMax:=0
	GuiControl, 66:-Redraw, RunAnyHotkeyLV
	For ki, kv in HotKeyList
	{
		StringReplace,keyV,kv,Hot
		StringReplace,winkeyV,kv,Hot,Win
		if(!MENU2FLAG){
			if ki in 2,7,9
			{
				continue
			}
		}
		%kv%:=%winkeyV% ? "#" . %keyV% : %keyV%
		LV_Add("", %kv%, HotKeyTextList[ki], kv)
		if(StrLen(%kv%)>kvLenMax)
			kvLenMax:=StrLen(%kv%)
	}
	LV_ModifyCol()
	if(kvLenMax<13)
		LV_ModifyCol(1,"AutoHdr")  ;列宽调整为标题对齐
	GuiControl, 66:+Redraw, RunAnyHotkeyLV

	Gui,66:Tab,菜单变量,,Exact
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%,自定义配置RunAny菜单中可以使用的变量
	Gui,66:Add,Button, xm yp+30 w50 GLVMenuVarAdd, + 增加
	Gui,66:Add,Button, x+10 yp w50 GLVMenuVarEdit, · 修改
	Gui,66:Add,Button, x+10 yp w50 GLVMenuVarRemove, - 减少
	Gui,66:Add,Link, x+15 yp-5,使用方法：变量两边加百分号如：<a href="https://hui-zz.gitee.io/runany/#/article/built-in-variables">`%变量名`%</a>`n
	(
编辑菜单项的启动路径中 或 RunAny.ini文件中使用
	)
	Gui,66:Add,Listview,xm yp+40 r16 grid AltSubmit vRunAnyMenuVarLV glistviewMenuVar, 菜单变量名|类型|菜单变量值（动态变量不同电脑会自动变化）
	RunAnyMenuVarImageListID:=IL_Create(2)
	IL_Add(RunAnyMenuVarImageListID,AnyIconS[1],AnyIconS[2])
	IL_Add(RunAnyMenuVarImageListID,"shell32.dll",71)
	IL_Add(RunAnyMenuVarImageListID,"shell32.dll",25)
	GuiControl, 66:-Redraw, RunAnyMenuVarLV
	LV_SetImageList(RunAnyMenuVarImageListID)
	For mVarName, mVarVal in MenuVarIniList
	{
		mtypeIcon:=(MenuVarTypeList[mVarName]=1) ? "Icon1" : (MenuVarTypeList[mVarName]=2) ? "Icon3" : "Icon2"
		mtypeStr:=(MenuVarTypeList[mVarName]=1) ? "RunAny变量(动态)" : (MenuVarTypeList[mVarName]=2) ? "系统环境变量(动态)" : "用户变量(固定值)"
		LV_Add(mtypeIcon, mVarName, mtypeStr, mVarVal)
	}
	LV_ModifyCol()
	GuiControl, 66:+Redraw, RunAnyMenuVarLV

	evCurrentRunPath:=get_process_path(Everything_exe)
	emptyReasonStr:="无路径说明"
	if(!evCurrentRunPath){
		emptyReasonStr:="Everything未启动"
	}else if(!EvNo && !RunAEvFullPathSyncFlag){
		emptyReasonStr:="自动更新中...可以重新打开设置查看或点击EV更新同步"
	}
	Gui,66:Tab,无路径缓存,,Exact
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66%,RunAny菜单中无路径的缓存全路径
	Gui,66:Add,Button,x+10 yp-5 GSetRunAEvFullPathIniDir,无路径缓存文件目录
	Gui,66:Add,Edit,x+11 yp+2 w300 r1 GSetRunAEvFullPathIniDirHint vvRunAEvFullPathIniDir,%RunAEvFullPathIniDir%
	Gui,66:Add,Button, xm yp+35 w50 GLVMenuObjPathAdd, + 增加
	Gui,66:Add,Button, x+10 yp w50 GLVMenuObjPathEdit, · 修改
	Gui,66:Add,Button, x+10 yp w50 GLVMenuObjPathRemove, - 减少
	Gui,66:Add,Button, x+10 yp w50 GLVMenuObjPathSelect, A 全选
	Gui,66:Add,Button, x+10 yp w75 GLVMenuObjPathSync, EV更新同步
	Gui,66:Add,Text, x+15 yp-5,无路径说明：每次新增或移动无路径应用文件后`n会使用Everything获得它最新的运行全路径
	Gui,66:Add,Listview,xm yp+40 r16 grid AltSubmit vRunAnyMenuObjPathLV hwndWLJLV glistviewMenuObjPath, 无路径应用名(不能有等号=)|当前电脑运行全路径（来自Everything）|%emptyReasonStr%
	RunAnyMenuObjPathImageListID := IL_Create(11)
	Icon_Image_Set(RunAnyMenuObjPathImageListID)
	GuiControl, 66:-Redraw, RunAnyMenuObjPathLV
	LV_SetImageList(RunAnyMenuObjPathImageListID)
	NWLJLV := New ListView(WLJLV)
	Loop, parse, evFullPathIniVar, `n, `r
	{
		if(A_LoopField="")
			continue
		varList:=StrSplit(A_LoopField,"=",,2)
		LV_Add(varList[2]="" ? "Icon3" : Set_Icon(RunAnyMenuObjPathImageListID,varList[2],false,false,varList[2])
			, varList[1], varList[2], MenuObjEvPathEmptyReason[(varList[1])])
		if(!varList[2])
			NWLJLV.Color(A_Index,0x999999)
	}
	if(emptyReasonStr="无路径说明"){
		LV_ModifyCol()
	}else{
		LV_ModifyCol("Auto")
	}
	LV_ModifyCol(1, 155)
	LV_ModifyCol(2, 350)
	LV_ModifyCol(1, "Sort")  ; 排序
	GuiControl, 66:+Redraw, RunAnyMenuObjPathLV

	Gui,66:Tab,搜索Everything,,Exact
	EvIsAdmin:=ev.GetIsAdmin()
	EvIsAdminStatus:=EvIsAdmin ? "管理员权限" : "非管理员"
	EvAllSearch:=EvDemandSearch ? 0 : 1
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66%,Everything当前权限：【%EvIsAdminStatus%】
	Gui,66:Add,Checkbox,Checked%EvAutoClose% x+20 yp vvEvAutoClose,Everything自动关闭(不常驻后台)
	if(EvPath!=""){
		Gui,66:Add,Button,x+10 w80 h20 gSetEvReindex,重建索引
	}
	Gui,66:Add,Text,xm yp+28,% "Everything当前运行路径：" evCurrentRunPath
	Gui,66:Add,GroupBox,xm-10 y+12 w%GROUP_WIDTH_66% h55,一键Everything [搜索选中文字，支持多选文件、再按为隐藏/激活] %EvHotKey%
	Gui,66:Add,Hotkey,xm+10 yp+20 w130 vvEvKey,%EvKey%
	Gui,66:Add,Checkbox,Checked%EvWinKey% xm+150 yp+3 vvEvWinKey,Win
	Gui,66:Add,Checkbox,Checked%EvShowExt% x+27 vvEvShowExt,搜索带文件后缀
	Gui,66:Add,Checkbox,Checked%EvShowFolder% x+5 vvEvShowFolder,搜索选中文件夹内部
	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% h60 vvEvSetupGroup,Everything安装路径（支持菜单变量和相对路径 \..\代表上一级目录）
	Gui,66:Add,Button,xm yp+20 w50 GSetEvPath,选择
	Gui,66:Add,Edit,xm+60 yp+2 w%GROUP_CHOOSE_EDIT_WIDTH_66% vvEvPath,%EvPath%
	Gui,66:Add,GroupBox,xm-10 y+20 w%GROUP_WIDTH_66% vvEvCommandGroup,RunAny调用Everything搜索参数（搜索结果可在RunAny无路径运行，Everything异常请尝试重建索引）
	Gui,66:Add,Radio,Checked%EvDemandSearch% xm yp+25 cBlack vvEvDemandSearch gSetEvDemandSearch
		,按需搜索模式（推荐，只搜索RunAny菜单的无路径文件进行匹配路径，速度快，支持生成更新无路径应用缓存）
	Gui,66:Add,Radio,Checked%EvAllSearch% xm yp+25 cBlack vvEvAllSearch gSetEvAllSearch
		,全磁盘搜索模式（搜索全磁盘指定后缀的文件，然后匹配RA菜单取得路径，开机首次加载缓慢，无路径缓存无效！）
	Gui,66:Add,Checkbox,Checked%EvExeVerNew% xm yp+25 vvEvExeVerNew,搜索结果优先最新版本的同名exe
	Gui,66:Add,Checkbox,Checked%EvExeMTimeNew% x+23 vvEvExeMTimeNew,搜索结果优先最新修改时间的同名文件
	Gui,66:Add,Button,xm y+20 w50 GSetEvCommand,修改
	Gui,66:Font,,Consolas
	Gui,66:Add,Text,xm+60 yp-10,% StrReplace(EvCommandDefault,"Temp\* ","Temp\* `n") "`n表示默认排除搜索系统目录、回收站、临时目录、软件数据目录等，注意中间空格间隔"
	; Gui,66:Add,Text,xm+60 yp+15,file:*.exe|*.lnk|后面类推增加想要的后缀
	Gui,66:Add,Edit,xm y+10 r5 -WantReturn ReadOnly vvEvCommand,%EvCommand%
	Gui,66:Font,,Microsoft YaHei
	Gosub,SetEvAllSearch

	Gui,66:Tab,一键直达,,Exact
	Gui,66:Add,Button, xm-10 y+%MARGIN_TOP_66% w50 GRunA_One_Key_Down, @ 在线
	Gui,66:Add,Button, x+5 yp w50 GLVRunAnyOneKeyAdd, + 增加
	Gui,66:Add,Button, x+5 yp w50 GLVRunAnyOneKeyEdit, · 修改
	Gui,66:Add,Button, x+5 yp w50 GLVRunAnyOneKeyRemove, - 减少
	Gui,66:Add,Link, x+20 yp-5,【正则一键直达】（仅菜单1热键触发，不想触发的菜单项放入菜单2中）`n
	(
<a href="https://wyagd001.github.io/zh-cn/docs/misc/RegEx-QuickRef.htm">AHK正则选项</a>：i) 不区分大小写匹配  m) 多行匹配模式  S) 研究模式来提高性能
	)
	Gui,66:Add,Listview,xm-10 yp+40 w%GROUP_WIDTH_66% r12 grid AltSubmit -ReadOnly Checked vRunAnyOneKeyLV hwndYJLV glistviewRunAnyOneKey
		, 选中内容逐行匹配正则（多行整体匹配使用正则选项 m）|一键直达说明|状态|一键直达运行（支持无路径、RunAny插件写法）
	GuiControl, 66:-Redraw, RunAnyOneKeyLV
	NYJLV := New ListView(YJLV)
	For onekeyName, onekeyVal in OneKeyRunList
	{
		LV_Add(OneKeyDisableList[onekeyName] ? "" : "Check", OneKeyRegexList[onekeyName], onekeyName
			,OneKeyDisableList[onekeyName] ? "禁用" : "启用" ,onekeyName="一键公式计算" ? "内置功能输出结果" : onekeyVal)
		if(OneKeyDisableList[onekeyName])
			NYJLV.Color(A_Index,0x999999)
	}
	LV_ModifyCol()
	LV_ModifyCol(1,240)
	LV_ModifyCol(2, "Sort Auto")  ; 排序
	GuiControl, 66:+Redraw, RunAnyOneKeyLV
	Gui,66:Add,GroupBox,xm-10 y+10 w%GROUP_WIDTH_66% h240 vvOneKeyUrlGroup,一键搜索选中文字 %OneHotKey%
	Gui,66:Add,Hotkey,xm yp+30 w150 vvOneKey,%OneKey%
	Gui,66:Add,Checkbox,Checked%OneWinKey% xm+155 yp+3 vvOneWinKey,Win
	Gui,66:Add,Checkbox,Checked%OneKeyMenu% x+38 vvOneKeyMenu,绑定菜单1热键为一键搜索
	Gui,66:Add,Text,xm y+15 w325,一键搜索网址(`%s为选中文字的替代参数，多行搜索多个网址)
	Gui,66:Add,Edit,xm yp+20 r3 vvOneKeyUrl,%OneKeyUrl%
	Gui,66:Add,Text,xm y+15 w600,一键搜索非默认浏览器打开网址（新版一键网址直达请在上面列表中设置一键打开网址：浏览器.exe "`%getZz`%"）
	Gui,66:Add,Button,xm yp+20 w50 GSetBrowserPath,选择
	Gui,66:Add,Edit,xm+60 yp r2 -WantReturn vvBrowserPath,%BrowserPath%

	Gui,66:Tab,内部关联,,Exact
	Gui,66:Add,Text,xm y+%MARGIN_TOP_66%,内部关联RunAny.ini菜单内不同后缀的文件，使用指定软件打开
	Gui,66:Add,Text,xm yp x+5 cRed, （对资源管理器选中的文件无效！）
	Gui,66:Add,Button, xm yp+30 w50 GLVOpenExtAdd, + 增加
	Gui,66:Add,Button, x+10 yp w50 GLVOpenExtEdit, · 修改
	Gui,66:Add,Button, x+10 yp w50 GLVOpenExtRemove, - 减少
	Gui,66:Add,Text, x+10 yp-5 w360,特殊类型：网址http https www ftp等`n文件夹folder（原来使用TC、DO第三方软件打开文件夹的功能）
	Gui,66:Add,Listview,xm yp+40 r16 grid AltSubmit -Multi vRunAnyOpenExtLV glistviewOpenExt, RunAny菜单内文件后缀(用空格分隔)|打开方式(支持无路径)
	kvLenMax:=0
	GuiControl, 66:-Redraw, RunAnyOpenExtLV
	For mOpenExtName, mOpenExtRun in openExtIniList
	{
		LV_Add("", mOpenExtRun, mOpenExtName)
		if(StrLen(mOpenExtRun)>kvLenMax)
			kvLenMax:=StrLen(mOpenExtRun)
	}
	LV_ModifyCol()
	if(kvLenMax<22)
		LV_ModifyCol(1,"AutoHdr")  ;列宽调整为标题对齐
	GuiControl, 66:+Redraw, RunAnyOpenExtLV

	Gui,66:Tab,热字符串,,Exact
	Gui,66:Add,GroupBox,xm-10 y+%MARGIN_TOP_66% w%GROUP_WIDTH_66% vvHotStrGroup,热字符串设置
	Gui,66:Add,Checkbox,Checked%HideHotStr% xm yp+40 vvHideHotStr,隐藏热字符串提示
	Gui,66:Add,Text,xm yp+40 w250,按几个字符出现提示 (默认3个字符)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrHintLen,%HotStrHintLen%
	Gui,66:Add,Text,xm yp+50 w250,提示启动路径最长字数 (0为隐藏)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowLen,%HotStrShowLen%
	Gui,66:Add,Text,xm yp+50 w250,提示显示时长 (毫秒)
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowTime,%HotStrShowTime%
	Gui,66:Add,Text,xm yp+50 w250,提示显示透明度百分比 (`%)
	Gui,66:Add,Slider,xm+200 yp ToolTip w200 r1 vvHotStrShowTransparent,%HotStrShowTransparent%
	Gui,66:Add,Text,xm yp+50 w250,提示相对于鼠标坐标 X (可为负数)：
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowX,%HotStrShowX%
	Gui,66:Add,Text,xm yp+50 w250,提示相对于鼠标坐标 Y (可为负数)：
	Gui,66:Add,Edit,xm+200 yp-3 w200 r1 vvHotStrShowY,%HotStrShowY%
	if(encryptFlag){
		Gui,66:Add,Text,xm yp+50 w250 GMenu_Config,短语key（huiZz_Text）：
		Gui,66:Add,Edit,xm+200 yp-3 Password w200 cWhite r1 vvSendStrEcKey,%SendStrEcKey%
	}
	Gui,66:Add,Text,xm yp+50 cBlue,提示文字自动消失后，而且后续输入字符不触发热字符串功能`n需要按Tab/回车/句点/空格等键之后才会再次进行提示

	Gui,66:Tab,图标设置,,Exact
	Gui,66:Add,Checkbox,Checked%HideMenuTrayIcon% xm-5 y+%MARGIN_TOP_66% vvHideMenuTrayIcon gSetHideMenuTrayIcon,隐藏任务栏托盘图标
	Gui,66:Add,Text,x+10 yp,RunAny菜单图标大小(像素)
	Gui,66:Add,Edit,x+3 yp w30 h20 vvMenuIconSize,%MenuIconSize%
	Gui,66:Add,Text,x+15 yp,任务栏托盘右键图标大小(像素)
	Gui,66:Add,Edit,x+3 yp w30 h20 vvMenuTrayIconSize,%MenuTrayIconSize%
	Gui,66:Add,GroupBox,xm-10 yp+30 w%GROUP_WIDTH_66% h275,图标自定义设置（图片或图标文件路径 , 序号不填默认1）
	Gui,66:Add,Button,xm yp+20 w80 GSetAnyIcon,RunAny图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvAnyIcon,%AnyIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetMenuIcon,准备图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvMenuIcon,%MenuIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetTreeIcon,分类图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvTreeIcon,%TreeIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetFolderIcon,文件夹图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvFolderIcon,%FolderIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetUrlIcon,网址图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvUrlIcon,%UrlIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetEXEIcon,EXE图标
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvEXEIcon,%EXEIcon%
	Gui,66:Add,Button,xm yp+35 w80 GSetFuncIcon,脚本插件函数
	Gui,66:Add,Edit,xm+85 yp+1 w%GROUP_ICON_EDIT_WIDTH_66% r1 vvFuncIcon,%FuncIcon%
	Gui,66:Add,GroupBox,xm-10 y+25 w%GROUP_WIDTH_66% h185,%RunAnyZz%图标识别库（支持多行, 要求图标名与菜单项名相同, 不包含热字符串和全局热键）
	Gui,66:Add,Text, xm yp+20 w380,如图标文件名可以为：-常用(&&App).ico、cmd.png、百度(&&B).ico
	if(ResourcesExtractExist)
		Gui,66:Add,Button,x+5 yp w110 GMenu_Exe_Icon_Create,生成所有EXE图标
	Gui,66:Add,Button,xm yp+30 w50 GSetIconFolderPath,选择
	Gui,66:Add,Edit,xm+60 yp w%GROUP_CHOOSE_EDIT_WIDTH_66% r6 vvIconFolderPath,%IconFolderPath%

	Gui,66:Tab,高级配置,,Exact
	Gui,66:Add,Link,xm y+%MARGIN_TOP_66% w%GROUP_WIDTH_66%,%RunAnyZz%高级配置列表，请理解说明后修改（双击或按F2进行修改）
	Gui,66:Add,Listview,xm yp+20 r18 grid AltSubmit -ReadOnly -Multi vAdvancedConfigLV glistviewAdvancedConfig, 1或有值=启用，0或空=停用|单位|配置说明|配置脚本|配置项名
	AdvancedConfigImageListID:=IL_Create(2)
	IL_Add(AdvancedConfigImageListID,(A_OSVersion="WIN_7") ? "imageres.dll" : "shell32.dll",(A_OSVersion="WIN_XP") ? 145 : (A_OSVersion="WIN_7") ? 102 : 297)
	IL_Add(AdvancedConfigImageListID,"shell32.dll",132)
	GuiControl, 66:-Redraw, AdvancedConfigLV
	LV_SetImageList(AdvancedConfigImageListID)
	LV_Add(JumpSearch ? "Icon1" : "Icon2", JumpSearch,, "跳过点击批量搜索时的确认弹窗","","JumpSearch")
	LV_Add(ShowGetZzLen ? "Icon1" : "Icon2", ShowGetZzLen,"字", "[选中] 菜单第一行显示选中文字最大截取字数","","ShowGetZzLen")
	LV_Add(ClipWaitApp ? "Icon1" : "Icon2", ClipWaitApp,"逗号分隔", "[选中] 指定软件解决剪贴板等待时间过短获取不到选中内容（多个用,分隔）","","ClipWaitApp")
	LV_Add(ClipWaitApp ? "Icon1" : "Icon2", ClipWaitTime,"秒", "[选中] 指定软件获取选中目标到剪贴板等待时间，全局其他软件默认0.1秒","","ClipWaitTime")
	LV_Add(GetZzCopyKey ? "Icon1" : "Icon2", GetZzCopyKey,"热键", "[选中] 自定义在一些软件界面获取选中内容的热键","","GetZzCopyKey")
	LV_Add(GetZzCopyKey ? "Icon1" : "Icon2", GetZzCopyKeyApp,"逗号分隔", "[选中] 自定义在哪些软件界面改变获取选中内容热键","","GetZzCopyKeyApp")
	LV_Add(GetZzTransformVal ? "Icon1" : "Icon2", GetZzTransformVal,"", "[选中] 对选中的双百分号内容%%自动转换成变量值","","GetZzTransformVal")
	LV_Add(HoldCtrlRun ? "Icon1" : "Icon2", HoldCtrlRun,"", "[按住Ctrl键] 回车或点击菜单项（选项数字可互用） 2:打开该软件所在目录","","HoldCtrlRun")
	LV_Add(HoldShiftRun ? "Icon1" : "Icon2", HoldShiftRun,"", "[按住Shift键] 回车或点击菜单项（选项数字可互用） 5:打开多功能菜单运行方式","","HoldShiftRun")
	LV_Add(HoldCtrlShiftRun ? "Icon1" : "Icon2", HoldCtrlShiftRun,"", "[按住Ctrl+Shift键] 回车或点击菜单项（选项数字可互用） 3:编辑该菜单项","","HoldCtrlShiftRun")
	LV_Add(HoldCtrlWinRun ? "Icon1" : "Icon2", HoldCtrlWinRun,""
		, "[按住Ctrl+Win键] 回车或点击菜单项（选项数字可互用） 11:以管理员权限运行 12:最小化运行 13:最大化运行 14:隐藏运行(部分有效)","","HoldCtrlWinRun")
	LV_Add(HoldShiftWinRun ? "Icon1" : "Icon2", HoldShiftWinRun,""
		, "[按住Shift+Win键] 回车或点击菜单项（选项数字可互用） 31:复制运行路径 32:输出运行路径 33:复制软件名 34:输出软件名 35:复制软件名+后缀 36:输出软件名+后缀","","HoldShiftWinRun")
	LV_Add(HoldCtrlShiftWinRun ? "Icon1" : "Icon2", HoldCtrlShiftWinRun,"", "[按住Ctrl+Shift+Win键] 回车或点击菜单项（选项数字可互用） 4:强制结束该软件名进程","","HoldCtrlShiftWinRun")
	if(RunAnyMenuSpaceFlag)
		LV_Add(RunAnyMenuSpaceRun ? "Icon1" : "Icon2", RunAnyMenuSpaceRun,"", "[按空格键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuSpaceRun")
	if(RunAnyMenuRButtonFlag)
		LV_Add(RunAnyMenuRButtonRun ? "Icon1" : "Icon2", RunAnyMenuRButtonRun,"", "[按右键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuRButtonRun")
	if(RunAnyMenuMButtonFlag)
		LV_Add(RunAnyMenuMButtonRun ? "Icon1" : "Icon2", RunAnyMenuMButtonRun,"", "[按中键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuMButtonRun")
	if(RunAnyMenuXButton1Flag)
		LV_Add(RunAnyMenuXButton1Run ? "Icon1" : "Icon2", RunAnyMenuXButton1Run,"", "[按XButton1键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuXButton1Run")
	if(RunAnyMenuXButton2Flag)
		LV_Add(RunAnyMenuXButton2Run ? "Icon1" : "Icon2", RunAnyMenuXButton2Run,"", "[按XButton2键] 运行菜单项（只能复制上面已设置的选项数字）","RunAny_Menu.ahk","RunAnyMenuXButton2Run")
	LV_Add(HoldKeyShowTime ? "Icon1" : "Icon2", HoldKeyShowTime,"毫秒", "按键运行菜单项复制运行路径、软件名等提示信息的显示时间","RunAny_Menu.ahk","HoldKeyShowTime")
	if(RunAnyMenuTransparentFlag)
		LV_Add(RunAnyMenuTransparent ? "Icon1" : "Icon2", RunAnyMenuTransparent,"", "RunAny菜单和右键菜单透明度数值（0全透明-255不透明）","RunAny_Menu.ahk","RunAnyMenuTransparent")
	LV_Add(RUNANY_SELF_MENU_ITEM1 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM1,, "RunAny自身功能的菜单项名称修改1：&1批量搜索","","RUNANY_SELF_MENU_ITEM1")
	LV_Add(RUNANY_SELF_MENU_ITEM2 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM2,, "RunAny自身功能的菜单项名称修改2：RunAny设置","","RUNANY_SELF_MENU_ITEM2")
	LV_Add(RUNANY_SELF_MENU_ITEM3 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM3,, "RunAny自身功能的菜单项名称修改3：0【添加到此菜单】","","RUNANY_SELF_MENU_ITEM3")
	LV_Add(RUNANY_SELF_MENU_ITEM4 ? "Icon1" : "Icon2", RUNANY_SELF_MENU_ITEM4,, "RunAny自身功能的菜单项名称修改4：-【显示菜单全部】","","RUNANY_SELF_MENU_ITEM4")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugMode,, "[调试模式] 实时显示菜单运行的信息","","DebugMode")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugModeShowTime,"毫秒", "[调试模式] 实时显示菜单运行信息的自动隐藏时间","","DebugModeShowTime")
	LV_Add(DebugMode ? "Icon1" : "Icon2", DebugModeShowTrans,"%", "[调试模式] 实时显示菜单运行信息的透明度","","DebugModeShowTrans")
	LV_Add(DisableExeIcon ? "Icon1" : "Icon2", DisableExeIcon,, "菜单中exe程序不加载本身图标","","DisableExeIcon")
	LV_Add(RunAEncoding ? "Icon1" : "Icon2", RunAEncoding,, "使用指定编码读取RunAny.ini（默认ANSI）","","RunAEncoding")
	LV_Add(AutoGetZz ? "Icon1" : "Icon2", AutoGetZz,, "【慎改】菜单程序运行自动带上当前选中文件，关闭后需要手动加%getZz%才可以获取到","","AutoGetZz")
	LV_Add(EvNo ? "Icon1" : "Icon2", EvNo,, "【慎改】不使用Everything模式，所有无路径应用缓存需要手动新增修改","","EvNo")
	LV_ModifyCol(2,"Auto Center")
	LV_ModifyCol(3,"Auto")
	LV_ModifyCol(4,"Auto")
	LV_ModifyCol(5,"Auto")
	GuiControl, 66:+Redraw, AdvancedConfigLV

	Gui,66:Tab
	Gui,66:Add,Button,Default w75 vvSetOK GSetOK,确定
	Gui,66:Add,Button,w75 vvSetCancel GSetCancel,取消
	Gui,66:Add,Button,w75 vvSetReSet GSetReSet,重置
	Gui,66:Add,Text,w75 vvMenu_Config GMenu_Config,RunAnyConfig.ini
	Gui,66:Show,w%GUI_WIDTH_66%,%RunAnyZz%设置 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	Critical,Off
	k:=v:=mVarName:=mVarVal:=mOpenExtName:=mOpenExtRun:=""
	SetValueList:=["AdminRun"]
	;[手写AHK热键情况下不根据Hotkey热键控件保存，避免清空手写热键值]
	Gui,66:Submit, NoHide
	For ki, kv in RunHotKeyList
	{
		keyV:=StrReplace(kv,"Hot")
		winkeyV:=StrReplace(kv,"Hot","Win")
		if(v%keyV%="" && %kv%!=""){
			GuiControl,Disable,v%keyV%
			GuiControl,Disable,v%winkeyV%
		}else{
			SetValueList.Push(keyV)
			SetValueList.Push(winkeyV)
		}
	}
return
ConfigTabSelect:
	Gui,66:Submit, NoHide
	if(ConfigTab="无路径缓存"){
		Gui,ListView,% WLJLV
	}else if(ConfigTab="一键直达"){
		Gui,ListView,% YJLV
	}
return
;~;【关于Gui】
Menu_About:
	aboutWebHeight:=( 96 / A_ScreenDPI ) * 120 + 380
	marginTop:=( 96 / A_ScreenDPI ) * 50
	Gui,99:Destroy
	Gui,99:Color,FFFFFF
	Gui,99:Add, ActiveX, x0 y0 w570 h%aboutWebHeight% voWB, shell explorer
	oWB.Navigate("about:blank")
	versionTime:=RegExReplace(RunAny_update_time, "[^\d\.]*([\d\.]+)[^\d\.]*", "$1")
	versionUrlEncode:=StrReplace(SkSub_UrlEncode("v" RunAny_update_version),"%","`%")
	vHtml =
(
<html>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>name</title>
<body style="font-family:Microsoft YaHei;margin:30px;background:url(https://hui-zz.gitee.io/runany/assets/images/RunAnyMp_120x120.png) no-repeat center top;">
<br><br>
<h2 align="center" style="margin-top:%marginTop%px;">
【%RunAnyZz%】一劳永逸的快速启动工具
<br>
<img alt="GitHub stars" src="https://raster.shields.io/github/stars/hui-Zz/RunAny.svg?style=social&logo=github"/>
<img alt="GitHub forks" src="https://raster.shields.io/github/forks/hui-Zz/RunAny?style=social"/>
<img alt="history" src="https://raster.shields.io/badge/2017--2022-white.svg?label=Time&style=social&logo=github"/>
</h2>
<b>当前版本：</b><img alt="当前版本" style="vertical-align:middle" src="https://raster.shields.io/badge/RunAny-%versionUrlEncode%-blue.svg?style=flat-square"/>
<br>
<b>最新版本：</b><img alt="GitHub release" style="vertical-align:middle" src="https://raster.shields.io/github/v/release/hui-Zz/RunAny.svg?label=RunAny&style=flat-square&color=red"/>
<img alt="Autohotkey" style="vertical-align:middle" src="https://raster.shields.io/badge/autohotkey-1.1.33.10-green.svg?style=flat-square&logo=autohotkey"/>
<br>
默认启动菜单热键为 <b><font color="red"><kbd>``</kbd></font></b>（Esc键下方的重音符键~`` ）
<br>
注意：想打字打出 <font color="red"><kbd>``</kbd></font> 的时候，按 <font color="red"><kbd>Win</kbd> + <kbd>``</kbd></font>
<br><br>
<li>按住<kbd>Shift</kbd>+回车键 或+鼠标左键打开 <b>多功能菜单运行方式</b></li>
<li>按住<kbd>Ctrl</kbd>+回车键 或+鼠标左键打开 软件所在的目录</li>
<li>按住<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+回车键 或+鼠标左键打开 快速跳转到编辑该菜单项</li>
<li>按住<kbd>Ctrl</kbd>+<kbd>Win</kbd>+鼠标左键打开 以管理员身份来运行</li>
<br>
【右键任务栏RA图标进行设置】
<br><br>
作者：hui-Zz 建议：hui0.0713@gmail.com
</body>
</html>
)
	oWB.document.write(vHtml)
	oWB.Refresh()
	Gui,99:Font,s11 Bold cRed,Microsoft YaHei
	Gui,99:Add,Link,xm+18 y+10,赞助支持作者：<a href="https://hui-zz.gitee.io/runany/#/ABOUT">https://hui-zz.gitee.io/runany/#/ABOUT</a>
	Gui,99:Font,s11 Bold cBlack,Microsoft YaHei
	Gui,99:Add,Link,xm+18 y+10,国内Gitee文档：<a href="https://hui-zz.gitee.io/RunAny">https://hui-zz.gitee.io/RunAny</a>
	Gui,99:Add,Link,xm+18 y+10,Github文档：<a href="https://hui-zz.github.io/RunAny">https://hui-zz.github.io/RunAny</a>
	Gui,99:Add,Link,xm+18 y+10,Github地址：<a href="https://github.com/hui-Zz/RunAny">https://github.com/hui-Zz/RunAny</a>
	Gui,99:Add,Text,y+10, 讨论QQ群：
	Gui,99:Add,Link,x+8 yp,<a href="https://jq.qq.com/?_wv=1027&k=445Ug7u">246308937【RunAny快速启动一劳永逸】</a>`n
	Gui,99:Font
	Gui,99:Show,AutoSize Center,关于%RunAnyZz% %RunAny_update_version% %RunAny_update_time%%AdminMode%
	hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
	OnMessage(0x200,"WM_MOUSEMOVE")
return
SetEvPath:
	FileSelectFile, evFilePath, 3, %Everything_exe%, Everything安装路径, (%Everything_exe%)
	if(evFilePath)
		GuiControl,, vEvPath, %evFilePath%
return
SetIconFolderPath:
	Gui,66:Submit, NoHide
	FileSelectFolder, iconFolderName, , 0
	if(iconFolderName){
		if(vIconFolderPath){
			GuiControl,, vIconFolderPath, %vIconFolderPath%`n%iconFolderName%
		}else{
			GuiControl,, vIconFolderPath, %iconFolderName%
		}
	}
return
SetRunABackupDir:
	Gui,66:Submit, NoHide
	FileSelectFolder, dir, , 0
	if(dir){
		GuiControl,, vRunABackupDir, %dir%
	}
return
SetRunAEvFullPathIniDir:
	Gui,66:Submit, NoHide
	FileSelectFolder, dir, , 0
	if(dir){
		GuiControl,, vRunAEvFullPathIniDir, %dir%
	}
return
SetRunAEvFullPathIniDirHint:
	ToolTip, ⚠ 无路径缓存文件 请不要设置在网盘同步文件夹里面！`n防止把其他电脑上的软件路径同步过来造成混乱, 370, 45
	SetTimer,RemoveToolTip,4000
return
SetBrowserPath:
	FileSelectFile, browserFilePath, 3, , 程序路径, (*.exe)
	if(browserFilePath)
		GuiControl,, vBrowserPath, %browserFilePath%
return
SetOpenExtRun:
	FileSelectFile, openExtPath, , , 启动文件路径
	if(openExtPath){
		GuiControl,, vopenExtRun, %openExtPath%
	}
return
SetAnyIcon:
SetMenuIcon:
SetTreeIcon:
SetFolderIcon:
SetUrlIcon:
SetEXEIcon:
SetFuncIcon:
	setEdit:=StrReplace(A_ThisLabel, "Set", "v")
	FileSelectFile, filePath, 3, , 图标图片路径
	if(filePath)
		GuiControl,, %setEdit%, %filePath%
return
SetEvCommand:
	MsgBox,64,Everything搜索参数语法,请打开Everything参照`nEverything-帮助(H)-搜索语法`n`n
		(
修改以下文本框参数后，请务必复制参数到Everthing搜索
检验是否有搜索到RunAny菜单中的程序，避免出现错误
		)
	GuiControl,-ReadOnly,vEvCommand
return
SetOK:
	Gui,66:Submit, NoHide
	if(!vEvDemandSearch && !InStr(vEvCommand,"file:*.exe")){
		MsgBox, 48, 提示：, 搜索Everything - 全磁盘搜索模式 - 请修改搜索参数编辑框
			, 指定搜索后缀`n`n空格间隔后写入 file:*.exe|*.lnk|*.ahk|*.bat|*.cmd`n`n否则开机加载会非常缓慢！
		return
	}
	Gui,66:Hide
	vConfigDate:=A_MM A_DD
	if(vAutoRun!=AutoRun){
		AutoRun:=vAutoRun
		if(AutoRun){
			RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, RunAny, %A_ScriptDir%\%Z_ScriptName%
		}else{
			RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, RunAny
		}
	}
	if(vSendStrEcKey!=SendStrEcKey){
		vSendStrEcKey:=SendStrEncrypt(vSendStrEcKey,RunAnyZz vConfigDate)
	}else{
		vSendStrEcKey:=SendStrEncrypt(SendStrDcKey,RunAnyZz vConfigDate)
	}
	SetValueList.Push("ConfigDate","AutoReloadMTime","RunABackupRule","RunABackupMax","RunABackupFormat","RunABackupDir","RunAEvFullPathIniDir","DisableApp"
		,"EvPath","EvCommand","EvAutoClose","EvShowExt","EvShowFolder","EvExeVerNew","EvExeMTimeNew","EvDemandSearch"
		,"HideFail","HideWeb","HideGetZz","HideSend","HideAddItem","HideMenuTray","HideSelectZz","RecentMax"
		,"OneKeyUrl","OneKeyMenu","BrowserPath","IconFolderPath"
		,"HideMenuTrayIcon","MenuIconSize","MenuTrayIconSize","MenuIcon","AnyIcon","TreeIcon","FolderIcon","UrlIcon","EXEIcon","FuncIcon"
		,"HideHotStr","HotStrHintLen","HotStrShowLen","HotStrShowTime","HotStrShowTransparent","HotStrShowX","HotStrShowY","SendStrEcKey"
		,"MenuDoubleCtrlKey", "MenuDoubleAltKey", "MenuDoubleLWinKey", "MenuDoubleRWinKey"
		,"MenuCtrlRightKey", "MenuShiftRightKey", "MenuXButton1Key", "MenuXButton2Key", "MenuMButtonKey")
	;[回车转换成竖杠保存到ini配置文件]
	OneKeyUrl:=RegExReplace(OneKeyUrl,"S)[\n]+","|")
	vOneKeyUrl:=RegExReplace(vOneKeyUrl,"S)[\n]+","|")
	IconFolderPath:=RegExReplace(IconFolderPath,"S)[\n]+","|")
	vIconFolderPath:=RegExReplace(vIconFolderPath,"S)[\n]+","|")
	For vi, vv in SetValueList
	{
		vValue:="v" . vv
		Var_Set(%vValue%,%vv%,vv)
	}
	;[保存热键配置列表]
	if(HotKeyFlag){
		Gui, ListView, RunAnyHotkeyLV
		Loop % LV_GetCount()
		{
			LV_GetText(RunAHotKey, A_Index, 1)
			LV_GetText(RunAHotKeyVal, A_Index, 3)
			keyV:=StrReplace(RunAHotKeyVal,"Hot")
			winkeyV:=StrReplace(RunAHotKeyVal,"Hot","Win")
			v_keyV:=StrReplace(RunAHotKey,"#")
			v_winkeyV:=InStr(RunAHotKey,"#")
			IniWrite,%v_keyV%,%RunAnyConfig%,Config,%keyV%
			IniWrite,%v_winkeyV%,%RunAnyConfig%,Config,%winkeyV%
		}
	}
	;[保存自定义菜单变量]
	if(MenuVarFlag){
		Gui, ListView, RunAnyMenuVarLV
		IniWrite, delete=1, %RunAnyConfig%, MenuVar
		IniDelete, %RunAnyConfig%, MenuVar, delete
		Loop % LV_GetCount()
		{
			LV_GetText(menuVarName, A_Index, 1)
			LV_GetText(menuVarVal, A_Index, 3)
			IniWrite,%menuVarVal%,%RunAnyConfig%,MenuVar,%menuVarName%
		}
	}
	;[保存无路径应用缓存]
	if(MenuObjPathFlag){
		Gui, ListView, RunAnyMenuObjPathLV
		FileDelete, %RunAnyEvFullPathIni%
		IniWrite, delete=1, %RunAnyEvFullPathIni%, FullPath
		IniDelete, %RunAnyEvFullPathIni%, FullPath, delete
		Loop % LV_GetCount()
		{
			LV_GetText(menuObjPathName, A_Index, 1)
			LV_GetText(menuObjPathVal, A_Index, 2)
			IniWrite,%menuObjPathVal%,%RunAnyEvFullPathIni%,FullPath,%menuObjPathName%
		}
	}
	;[保存一键直达]
	if(RunAnyOneKeyFlag){
		Gui, ListView, RunAnyOneKeyLV
		IniWrite, delete=1, %RunAnyConfig%, OneKey
		IniDelete, %RunAnyConfig%, OneKey, delete
		OneKeyDisableSaveList:=[]
		Loop % LV_GetCount()
		{
			LV_GetText(oneKeyRegex, A_Index, 1)
			LV_GetText(oneKeyName, A_Index, 2)
			LV_GetText(oneKeyStatus, A_Index, 3)
			LV_GetText(oneKeyRegexRun, A_Index, 4)
			if(oneKeyName="一键公式计算")
				oneKeyRegexRun=
			IniWrite,%oneKeyRegex%,%RunAnyConfig%,OneKey,%oneKeyName%_Regex
			IniWrite,%oneKeyRegexRun%,%RunAnyConfig%,OneKey,%oneKeyName%_Run
			if(oneKeyStatus="禁用")
				OneKeyDisableSaveList.Push(oneKeyName)
		}
		Var_Set(StrListJoin("|",OneKeyDisableSaveList),OneKeyDisableStr,"OneKeyDisableList")
	}
	;[保存内部关联打开后缀列表]
	if(OpenExtFlag){
		Gui, ListView, RunAnyOpenExtLV
		IniWrite, delete=1, %RunAnyConfig%, OpenExt
		IniDelete, %RunAnyConfig%, OpenExt, delete
		Loop % LV_GetCount()
		{
			LV_GetText(openExtName, A_Index, 1)
			LV_GetText(openExtRun, A_Index, 2)
			IniWrite,%openExtName%,%RunAnyConfig%,OpenExt,%openExtRun%
		}
	}
	;[保存高级配置]
	if(AdvancedConfigFlag){
		Gui, ListView, AdvancedConfigLV
		Loop % LV_GetCount()
		{
			LV_GetText(AdvancedConfigVal, A_Index, 1)
			LV_GetText(AdvancedConfigName, A_Index, 5)
			Var_Set(AdvancedConfigVal,%AdvancedConfigName%,AdvancedConfigName)
		}
	}
	Gosub,Menu_Reload
return
SetHideSelectZz:
	GuiControlGet, outPutVar, , vHideSelectZz
	GuiControl,, vHideSelectZz2, %outPutVar%
return
SetScheduledTasks:
	cmdClipReturn("""schtasks /create /tn """ RunAnyZz "启动"" /tr " A_AhkPath " /sc onlogon /rl HIGHEST""")
	Run,taskschd.msc
	if(rule_chassis_types()>=8){
		Sleep,1000
		MsgBox, 64, 任务计划%RunAnyZz%创建完成, 在每次系统登录时会以管理员权限启动%RunAnyZz%`n`n
		(
【注意】`n当前电脑是笔记本，如果需要笔记本使用电池开机也会自动启动%RunAnyZz%
`n请找到任务计划程序库-%RunAnyZz%启动-右键属性-“条件”里面-
取消勾选“只有在计算机使用交流电源时才启动此任务”
		)
	}
	GuiControl,,vAutoRun,0
return
SetClearRecentMax:
	RegDelete, HKEY_CURRENT_USER\SOFTWARE\RunAny, MenuCommonList
return
SetEvReindex:
	Gui,66:Submit, NoHide
	Run,% Get_Transform_Val(vEvPath) " -reindex"
return
SetReSet:
	MsgBox,49,重置RunAny配置,此操作会删除RunAny所有注册表配置`n以及删除本地配置文件%RunAnyConfig%！`n还有所有的规则启动配置！`n确认删除重置吗？
	IfMsgBox Ok
	{
		RegDelete, HKEY_CURRENT_USER\SOFTWARE\RunAny
		RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, RunAny
		FileDelete, %RunAnyConfig%
		Gosub,Menu_Reload
	}
return
SetEvAllSearch:
	Gui,66:Submit, NoHide
	if(vEvDemandSearch){
		Gui,66:Font, cBlack, Microsoft YaHei
		GuiControl,66:Font, vEvAllSearch
	}else{
		Gui,66:Font, cRed, Microsoft YaHei
		GuiControl,66:Font, vEvAllSearch
		GuiControl,66:Font, RunAnyMenuObjPathLV
		Gui,66:Font, cBlack, Microsoft YaHei
	}
return
SetEvDemandSearch:
	Gui,66:Submit, NoHide
	Gosub,SetEvAllSearch
	if(vEvDemandSearch){
		MsgBox,64,Everything按需搜索模式, 只搜索%RunAnyZz%菜单的无路径文件，`n
		(
（不再搜索电脑上所有exe、lnk等后缀文件全路径）加快加载速度`n
想在%RunAnyZz%菜单中的任意后缀文件，都可以无路径运行`n
按需模式可以去掉下面的搜索参数：file:*.exe|*.lnk|*.ahk|*.bat|*.cmd`n
【注意】此设置会影响RunAny所有设置和插件脚本的无路径识别，
不在RunAny.ini菜单内的程序无法自动识别全路径
		)
	}
return
SetMenu2:
	MsgBox,33,开启第2个菜单,确定开启第2个菜单吗？`n会在目录生成RunAny2.ini`n【注意！】`n还原可以删除或重命名RunAny2.ini
	IfMsgBox Ok
	{
		text2=;这里添加第2菜单内容`n-菜单2分类
		FileAppend,%text2%,%iniPath2%
		Gosub,Menu_Edit2
	}
return
SetMenuWinKey:
	GuiControlGet, outPutVar, , vMenuWinKey
	If(outPutVar)
		MsgBox, 48, 提示：, 使用Win+字母热键可能无法取得QQ聊天窗口中文字，`n因为QQ聊天窗口是绘制的特殊窗体
return
SetMenuWinKey2:
	GuiControlGet, outPutVar, , vMenuWinKey2
	If(outPutVar)
		MsgBox, 48, 提示：, 使用Win+字母热键可能无法取得QQ聊天窗口中文字，`n因为QQ聊天窗口是绘制的特殊窗体
return
SetHideMenuTrayIcon:
	Gui,66:Submit, NoHide
	If(vHideMenuTray && vHideMenuTrayIcon){
		MsgBox, 48, 警告！, 已经隐藏菜单中的“RunAny设置”，如果再隐藏任务栏托盘图标后`n
		(
只能通过快捷键来再次打开RunAny设置界面，如果忘记热键的话`n`n需要手动修改 RunAnyConfig.ini 文件取消隐藏图标： HideMenuTrayIcon=0
		)
	}
return
;~;[编辑设置Gui]
;-------------------------------------RunAny热键配置界面-------------------------------------
RunA_Hotkey_Edit:
	Gui, ListView, RunAnyHotkeyLV
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_GetText(RunAHotKey, RunRowNumber, 1)
	LV_GetText(RunAHotKeyText, RunRowNumber, 2)
	LV_GetText(RunAHotKeyVal, RunRowNumber, 3)
	keyV:=StrReplace(RunAHotKeyVal,"Hot")
	winkeyV:=StrReplace(RunAHotKeyVal,"Hot","Win")
	v_keyV:=StrReplace(RunAHotKey,"#")
	v_winkeyV:=InStr(RunAHotKey,"#")
	Gui,key:Destroy
	Gui,key:Default
	Gui,key:+Owner66
	Gui,key:Margin,20,20
	Gui,key:Font,,Microsoft YaHei
	Gui,key:Add,GroupBox,xm-10 y+20 w255 h55,%RunAHotKeyText%：%RunAHotKey%
	Gui,key:Add,Hotkey,xm yp+20 w180 vvkeyV,%v_keyV%
	Gui,key:Add,Checkbox,Checked%v_winkeyV% xm+185 yp+3 vvwinkeyV,Win
	Gui,key:Font
	Gui,key:Add,Button,Default xm+35 y+25 w75 GSaveRunAHotkey,保存
	Gui,key:Add,Button,x+20 w75 GSetCancel,取消
	Gui,key:Show,,配置热键 %RunAny_update_version% %RunAny_update_time%
return
listviewHotkey:
	if A_GuiEvent = DoubleClick
	{
		Gosub,RunA_Hotkey_Edit
	}else if A_GuiEvent = e
	{
		HotKeyFlag:=true
	}else if  A_GuiEvent = R
	{
		Run,https://wyagd001.github.io/zh-cn/docs/KeyList.htm
	}
return
SaveRunAHotkey:
	HotKeyFlag:=true
	Gui,key:Submit, NoHide
	vKeyWinKeyV:=vwinkeyV ? "#" . vkeyV : vkeyV
	Gui,66:Default
	LV_Modify(RunRowNumber,"",vKeyWinKeyV)
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,key:Destroy
return
;-------------------------------------内部关联打开后缀界面-------------------------------------
Open_Ext_Edit:
	Gui, ListView, RunAnyOpenExtLV
	if(openExtItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(openExtName, RunRowNumber, 1)
		LV_GetText(openExtRun, RunRowNumber, 2)
	}
	Gui,SaveExt:Destroy
	Gui,SaveExt:Default
	Gui,SaveExt:+Owner66
	Gui,SaveExt:Margin,20,20
	Gui,SaveExt:Font,,Microsoft YaHei
	Gui,SaveExt:Add, GroupBox,xm y+10 w450 h145,%openExtItem%内部关联后缀打开方式
	Gui,SaveExt:Add, Text, xm+10 y+35 y35 w62, 文件后缀    (空格分隔)
	Gui,SaveExt:Add, Edit, x+5 yp+5 w350 vvopenExtName, %openExtName%
	Gui,SaveExt:Add, Button, xm+5 y+15 w60 GSetOpenExtRun,打开方式软件路径
	Gui,SaveExt:Add, Edit, x+12 yp w350 r3 -WantReturn vvopenExtRun, %openExtRun%
	Gui,SaveExt:Font
	Gui,SaveExt:Add,Button,Default xm+140 y+25 w75 GSaveOpenExt,保存(&Y)
	Gui,SaveExt:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SaveExt:Show,,%RunAnyZz% - %openExtItem%内部关联后缀打开方式 %RunAny_update_version% %RunAny_update_time%
return
listviewOpenExt:
	if A_GuiEvent = DoubleClick
	{
		openExtItem:="编辑"
		Gosub,Open_Ext_Edit
	}
return
LVOpenExtAdd:
	openExtItem:="新建"
	openExtName:=openExtRun:=""
	Gosub,Open_Ext_Edit
return
LVOpenExtEdit:
	openExtItem:="编辑"
	Gosub,Open_Ext_Edit
return
LVOpenExtRemove:
	Gui, ListView, RunAnyOpenExtLV
	OpenExtFlag:=true
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_Delete(RunRowNumber)
return
SaveOpenExt:
	OpenExtFlag:=true
	Gui,SaveExt:Submit, NoHide
	if(!vopenExtName || !vopenExtRun){
		ToolTip, 请填入文件后缀名和打开方式软件路径,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(openExtItem="新建"){
		if(openExtIniList[vopenExtRun]){
			Loop % LV_GetCount()
			{
				LV_GetText(openExtNameGet, A_Index, 1)
				LV_GetText(openExtRunGet, A_Index, 2)
				if(vopenExtRun=openExtRunGet){
					LV_Modify(A_Index,"",openExtNameGet . A_Space . vopenExtName,vopenExtRun)
					ToolTip, 已自动合并后缀到相同打开方式中,195,-20
					SetTimer,RemoveToolTip,3000
					break
				}
			}
		}else{
			LV_Add("",vopenExtName,vopenExtRun)
		}
	}else{
		LV_Modify(RunRowNumber,"",vopenExtName,vopenExtRun)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,SaveExt:Destroy
return
;--------------------------------------菜单变量设置界面--------------------------------------
Menu_Var_Edit:
	Gui, ListView, RunAnyMenuVarLV
	if(menuVarItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(menuVarName, RunRowNumber, 1)
		LV_GetText(menuVarType, RunRowNumber, 2)
		LV_GetText(menuVarVal, RunRowNumber, 3)
	}
	Gui,SaveVar:Destroy
	Gui,SaveVar:Default
	Gui,SaveVar:+Owner66
	Gui,SaveVar:Margin,20,20
	Gui,SaveVar:Font,,Microsoft YaHei
	Gui,SaveVar:Add, GroupBox,xm y+10 w450 h135 vvmenuVarType,%menuVarType%
	Gui,SaveVar:Add, Text, xm+5 y+35 y35 w60,菜单变量名
	Gui,SaveVar:Add, Edit, x+5 yp w350 vvmenuVarName gSetMenuVarVal, %menuVarName%
	Gui,SaveVar:Add, Text, xm+5 y+15 w60,菜单变量值
	Gui,SaveVar:Add, Edit, x+5 yp w350 r3 -WantReturn vvmenuVarVal, %menuVarVal%
	Gui,SaveVar:Font
	Gui,SaveVar:Add,Button,Default xm+140 y+25 w75 GSaveMenuVar,保存(&S)
	Gui,SaveVar:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SaveVar:Show,,%RunAnyZz% - %menuVarItem%菜单变量和变量值 %RunAny_update_version% %RunAny_update_time%
	if(menuVarType!="用户变量(固定值)")
		Gosub,SetMenuVarVal
return
listviewMenuVar:
	if A_GuiEvent = DoubleClick
	{
		menuVarItem:="编辑"
		Gosub,Menu_Var_Edit
	}
return
LVMenuVarAdd:
	menuVarItem:="新建"
	menuVarName:=menuVarVal:=""
	Gosub,Menu_Var_Edit
return
LVMenuVarEdit:
	menuVarItem:="编辑"
	Gosub,Menu_Var_Edit
return
LVMenuVarRemove:
	Gui, ListView, RunAnyMenuVarLV
	MenuVarFlag:=true
	RunRowNumber := LV_GetNext(0, "F")
	if not RunRowNumber
		return
	LV_Delete(RunRowNumber)
return
SetMenuVarVal:
	Gui,SaveVar:Submit, NoHide
	if(vmenuVarName="")
		return
	if(!RegExMatch(vmenuVarName,"S)^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 变量名只能为中文、数字、字母、下划线,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	try EnvGet, sysMenuVarName, %vmenuVarName%
	if(sysMenuVarName){
		menuVarType:="系统环境变量(动态)"
		GuiControl,, vmenuVarVal, %sysMenuVarName%
		GuiControl,, vmenuVarType, %menuVarType%
		GuiControl,+ReadOnly, vmenuVarVal
	}else{
		if(%vmenuVarName%){
			menuVarType:="RunAny变量(动态)"
			GuiControl,, vmenuVarVal, % %vmenuVarName%
			GuiControl,, vmenuVarType, %menuVarType%
			GuiControl,+ReadOnly, vmenuVarVal
		}else{
			menuVarType:="用户变量(固定值)"
			GuiControl,, vmenuVarType, %menuVarType%
			GuiControl,-ReadOnly, vmenuVarVal
		}
	}
return
SaveMenuVar:
	MenuVarFlag:=true
	Gui,SaveVar:Submit, NoHide
	if(vmenuVarName=""){
		ToolTip, 请填入菜单变量名,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	if(!RegExMatch(vmenuVarName,"S)^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 变量名只能为中文、数字、字母、下划线,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(menuVarItem="新建"){
		if(MenuVarIniList[vmenuVarName]){
			ToolTip, 已有相同菜单变量名！,195,35
			SetTimer,RemoveToolTip,3000
			return
		}
		LV_Add("",vmenuVarName,menuVarType,vmenuVarVal)
	}else{
		LV_Modify(RunRowNumber,"",vmenuVarName,menuVarType,vmenuVarVal)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	Gui,SaveVar:Destroy
return
;-----------------------------------无路径应用缓存设置界面-----------------------------------
Menu_Obj_Path_Edit:
	Gui, ListView, RunAnyMenuObjPathLV
	if(menuObjPathItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(menuObjPathName, RunRowNumber, 1)
		LV_GetText(menuObjPathVal, RunRowNumber, 2)
	}
	Gui,SavePath:Destroy
	Gui,SavePath:Default
	Gui,SavePath:+Owner66
	Gui,SavePath:Margin,20,20
	Gui,SavePath:Font,,Microsoft YaHei
	Gui,SavePath:Add, GroupBox,xm y+10 w450 h135, 无路径应用缓存
	Gui,SavePath:Add, Text, xm+5 y+35 y35 w60,无路径名
	Gui,SavePath:Add, Edit, x+5 yp w350 vvmenuObjPathName, %menuObjPathName%
	Gui,SavePath:Add, Text, xm+5 y+15 w60,运行全路径
	Gui,SavePath:Add, Edit, x+5 yp w350 r3 -WantReturn vvmenuObjPathVal, %menuObjPathVal%
	Gui,SavePath:Font
	Gui,SavePath:Add,Button,Default xm+140 y+25 w75 GSaveMenuObjPath,保存(&S)
	Gui,SavePath:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,SavePath:Show,,%RunAnyZz% - %menuObjPathItem%菜单无路径应用缓存 %RunAny_update_version% %RunAny_update_time%
return
listviewMenuObjPath:
	if A_GuiEvent = DoubleClick
	{
		menuObjPathItem:="编辑"
		Gosub,Menu_Obj_Path_Edit
	}
return
LVMenuObjPathAdd:
	menuObjPathItem:="新建"
	menuObjPathName:=menuObjPathVal:=""
	Gosub,Menu_Obj_Path_Edit
return
LVMenuObjPathEdit:
	menuObjPathItem:="编辑"
	Gosub,Menu_Obj_Path_Edit
return
LVMenuObjPathRemove:
	Gui, ListView, RunAnyMenuObjPathLV
	MenuObjPathFlag:=true
	DelRowList:=""
	RowNumber:=0
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		DelRowList:=RowNumber . ":" . DelRowList
	}
	stringtrimright, DelRowList, DelRowList, 1
	loop, parse, DelRowList, :
		LV_Delete(A_loopfield)
return
LVMenuObjPathSelect:
	Gui, ListView, RunAnyMenuObjPathLV
	LV_Modify(0, "Select Focus")   ; 选择所有.
return
LVMenuObjPathSync:
	Gosub,Ev_Exist
	if(EverythingIsRun()){
		RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RunAny, ReloadGosub, Settings_Gui
		EvCommandStr:=EverythingNoPathSearchStr()
		Gosub,RunAEvFullPathSync
		ShowTrayTip("","无路径应用缓存已经最新",3,17)
		Gosub,Menu_Reload
	}
return
SaveMenuObjPath:
	MenuObjPathFlag:=true
	Gui,SavePath:Submit, NoHide
	if(vmenuObjPathName=""){
		ToolTip, 请填入无路径应用缓存名,195,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(menuObjPathItem="新建"){
		if(MenuObjEv[vmenuObjPathName]){
			ToolTip, 已有相同无路径应用缓存名！,195,35
			SetTimer,RemoveToolTip,3000
			return
		}
		LV_Add("",vmenuObjPathName,vmenuObjPathVal)
	}else{
		LV_Modify(RunRowNumber,"",vmenuObjPathName,vmenuObjPathVal)
	}
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	LV_ModifyCol(1, "Sort")  ; 排序
	Gui,SavePath:Destroy
return
;-----------------------------------正则一键直达设置界面-----------------------------------
RunA_One_Key_Edit:
	Gui, ListView, RunAnyOneKeyLV
	if(runAnyOneKeyItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(oneKeyRegex, RunRowNumber, 1)
		LV_GetText(oneKeyName, RunRowNumber, 2)
		LV_GetText(oneKeyStatus, RunRowNumber, 3)
		LV_GetText(oneKeyRegexRun, RunRowNumber, 4)
		oneKeyStatusText:=oneKeyStatus="启用" ? "Green" : ""
		oneKeyStatus:=oneKeyStatus="启用" ? 1 : 0
	}
	Gui,OneKey:Destroy
	Gui,OneKey:Default
	Gui,OneKey:+Owner66
	Gui,OneKey:Margin,20,20
	Gui,OneKey:Font,,Microsoft YaHei
	Gui,OneKey:Add, GroupBox, xm y+10 w450 h230, 选中内容匹配正则表达式后运行
	Gui,OneKey:Add, Text, xm+5 yp+35 y35,直达说明
	Gui,OneKey:Add, Edit, x+10 yp-3 w250 vvoneKeyName, %oneKeyName%
	Gui,OneKey:Add, CheckBox, x+15 yp+3 Checked%oneKeyStatus% vvoneKeyStatus c%oneKeyStatusText%, 启用
	Gui,OneKey:Add, Text, xm+5 y+15,匹配正则
	Gui,OneKey:Add, Edit, x+10 yp w380 r6 -WantReturn vvoneKeyRegex, %oneKeyRegex%
	Gui,OneKey:Add, Button, xm yp+27 w60 GGraphicRegex,图解正则
	Gui,OneKey:Add, Text, xm+5 y+65,直达运行
	Gui,OneKey:Add, Edit, x+10 yp w380 r2 -WantReturn vvoneKeyRegexRun, %oneKeyRegexRun%
	Gui,OneKey:Font
	Gui,OneKey:Add,Button,Default xm+140 y+25 w75 GSaveRunAnyOneKey,保存(&S)
	Gui,OneKey:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,OneKey:Show,,%RunAnyZz% - %runAnyOneKeyItem%正则一键直达 %RunAny_update_version% %RunAny_update_time%
return
listviewRunAnyOneKey:
	if A_GuiEvent = DoubleClick
	{
		runAnyOneKeyItem:="编辑"
		Gosub,RunA_One_Key_Edit
	}
	if (A_GuiEvent = "I"){
		Gui, ListView, RunAnyOneKeyLV
		LV_GetText(oneKeyStatus, A_EventInfo, 3)
		if(errorlevel == "c" && oneKeyStatus!="禁用"){
			RunAnyOneKeyFlag:=true
			LV_Modify(A_EventInfo,"",,,"禁用")
			NYJLV.Color(A_EventInfo,0x999999)
		}else if(errorlevel == "C" && oneKeyStatus!="启用"){
			RunAnyOneKeyFlag:=true
			LV_Modify(A_EventInfo,"",,,"启用")
			NYJLV.Color(A_EventInfo,0x000000)
		}
	}
return
LVRunAnyOneKeyAdd:
	runAnyOneKeyItem:="新建"
	oneKeyRegex:=oneKeyName:=oneKeyStatus:=oneKeyRegexRun:=""
	Gosub,RunA_One_Key_Edit
return
LVRunAnyOneKeyEdit:
	runAnyOneKeyItem:="编辑"
	Gosub,RunA_One_Key_Edit
return
LVRunAnyOneKeyRemove:
	Gui, ListView, RunAnyOneKeyLV
	RunAnyOneKeyFlag:=true
	DelRowList:=""
	RowNumber:=0
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		DelRowList:=RowNumber . ":" . DelRowList
		LV_GetText(oneKeyName, RowNumber, 2)
		OneKeyRegexList.Delete(oneKeyName)
	}
	stringtrimright, DelRowList, DelRowList, 1
	loop, parse, DelRowList, :
		LV_Delete(A_loopfield)
return
GraphicRegex:
	Gui,OneKey:Submit, NoHide
	regexper:=RegExReplace(voneKeyRegex,"i)^[imS]+\)")
	Run,% "https://regexper.com/#" SkSub_UrlEncode(regexper)
return
SaveRunAnyOneKey:
	RunAnyOneKeyFlag:=true
	Gui,OneKey:Submit, NoHide
	if(voneKeyName=""){
		ToolTip, 请填入功能说明,300,35
		SetTimer,RemoveToolTip,3000
		return
	}
	if(InStr(voneKeyName,"=")){
		MsgBox, 48, ,一键直达名称不能包含有“=”分割符
		return
	}
	if(runAnyOneKeyItem="新建" && OneKeyRegexList[voneKeyName]){
		ToolTip, 已存在相同的一键直达名称，请修改,300,35
		SetTimer,RemoveToolTip,3000
		return
	}
	Gui,66:Default
	if(runAnyOneKeyItem="新建"){
		LV_Add("Check",voneKeyRegex,voneKeyName,voneKeyStatus ? "启用" : "禁用",voneKeyRegexRun)
	}else{
		LV_Modify(RunRowNumber,voneKeyStatus ? "Check" : "-Check",voneKeyRegex,voneKeyName,voneKeyStatus ? "启用" : "禁用",voneKeyRegexRun)
		LV_ModifyCol(2, "Sort")  ; 排序
	}
	Gui,OneKey:Destroy
return
;~;[在线正则一键直达]
RunA_One_Key_Down:
	Gosub,RunAnyOneKeyOnline
	Gui,OneKeyDown:Destroy
	Gui,OneKeyDown:Default
	Gui,OneKeyDown:+Owner66
	Gui,OneKeyDown:+Resize
	Gui,OneKeyDown:Font, s10, Microsoft YaHei
	Gui,OneKeyDown:Add, Listview, xm w620 r15 grid AltSubmit Checked BackgroundF6F6E8 vRunAnyOneKeyDownLV, 状态|选中内容逐行匹配正则|直达说明|直达运行
	GuiControl,OneKeyDown: -Redraw, RunAnyOneKeyDownLV
	For onekeyName, onekeyVal in OneKeyDownRunList
	{
		runStatus:=runCheck:=""
		if(!OneKeyRegexList[onekeyName] && !GetKeyByVal(OneKeyRegexList,OneKeyDownRegexList[onekeyName])){  ;本地列表未使用在线正则库正则
			runStatus:="未使用"
			runCheck:="Select Check"
		}else if(OneKeyRegexList[onekeyName]!=OneKeyDownRegexList[onekeyName] || OneKeyRunList[onekeyName]!=onekeyVal ){
			runStatus:="可更新"
			runCheck:="Select Check"
		}
		LV_Add(runCheck, runStatus, OneKeyDownRegexList[onekeyName], onekeyName,onekeyName="一键公式计算" ? "内置功能输出结果" : onekeyVal)
	}
	GuiControl,OneKeyDown: +Redraw, RunAnyOneKeyDownLV
	Menu, OneKeyDownMenu, Add,全部勾选, LVRunAnyOneKeyCheck
	Menu, OneKeyDownMenu, Icon,全部勾选, SHELL32.dll,145
	Menu, OneKeyDownMenu, Add,添加勾选的正则一键直达, LVRunAnyOneKeyDown
	Menu, OneKeyDownMenu, Icon,添加勾选的正则一键直达, SHELL32.dll,123
	Gui,OneKeyDown: Menu, OneKeyDownMenu
	LV_ModifyCol()
	LV_ModifyCol(2,170)
	Gui,OneKeyDown:Show, , %RunAnyZz% 在线正则一键直达 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
LVRunAnyOneKeyCheck:
	Gui, ListView, RunAnyOneKeyDownLV
	LV_Modify(0, "Check Focus")   ; 勾选所有.
return
LVRunAnyOneKeyDown:
	RunAnyOneKeyFlag:=true
	OneKeySameArray:=[]
	Loop
	{
		Gui, OneKeyDown:Default
		RowNumber := LV_GetNext(RowNumber, "Checked")  ; 再找勾选的行
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(oneKeyStatus, RowNumber, 1)
		LV_GetText(oneKeyRegex, RowNumber, 2)
		LV_GetText(oneKeyName, RowNumber, 3)
		LV_GetText(oneKeyRegexRun, RowNumber, 4)
		if(OneKeyRegexList[onekeyName]=oneKeyRegex && OneKeyRunList[onekeyName]=oneKeyRegexRun){
			OneKeySameArray.Push(oneKeyName)
			continue
		}
		Gui, 66:Default
		Gui, ListView, RunAnyOneKeyLV
		if(oneKeyStatus="可更新"){
			Loop % LV_GetCount()
			{
				LV_GetText(RowRegText, A_Index, 1)
				LV_GetText(RowText, A_Index, 2)
				if(oneKeyName=RowText || oneKeyRegex=RowRegText)
					LV_Modify(A_Index,"Select",oneKeyRegex,oneKeyName,"启用",oneKeyRegexRun)
			}
		}else{
			LV_Add("Select",oneKeyRegex,oneKeyName,"启用",oneKeyRegexRun)
		}
	}
	if(OneKeySameArray.Length()>0){
		TrayTip,无法添加重名的正则一键直达：,% StrListJoin("、",OneKeySameArray),5,2
	}
	Gui,OneKeyDown:Destroy
return
RunAnyOneKeyOnline:
	global OneKeyDownRunList:={}
	global OneKeyDownRegexList:={}
	RunAnyDownDir:=RunAnyGiteePages . "/RunAny"
	if(!rule_check_network(RunAnyGiteePages)){
		RunAnyDownDir:=RunAnyGithubPages . "/RunAny"
		if(!rule_check_network(RunAnyGithubPages)){
			MsgBox,48,,网络异常，无法连接网络读取最新一键直达，请联网后重试或手动输入
			return
		}
	}
	OneKeyIniPath=%A_Temp%\%RunAnyZz%\RunAny_OneKey.ini
	URLDownloadToFile(RunAnyDownDir "/assets/RunAny_OneKey.ini",OneKeyIniPath)
	IfExist,%OneKeyIniPath%
	{
		FileGetSize, OneKeyIniSize, %OneKeyIniPath%
		if(OneKeyIniSize>500){
			IniRead,OneKeyIniVar,%OneKeyIniPath%,OneKey
			Loop, parse, OneKeyIniVar, `n, `r
			{
				varList:=StrSplit(A_LoopField,"=",,2)
				if(RegExMatch(varList[1],".+_Run$")){
					OneKeyDownRunList[RegExReplace(varList[1],"(.+)_Run$","$1")]:=varList[2]
				}
				if(RegExMatch(varList[1],".+_Regex$")){
					OneKeyDownRegexList[RegExReplace(varList[1],"(.+)_Regex$","$1")]:=varList[2]
				}
			}
			return
		}
	}
return
;[RunAny所有菜单运行项]
RunA_MenuObj_Show:
	Gui,MenuObjShow:Destroy
	Gui,MenuObjShow:Default
	Gui,MenuObjShow:+Resize
	Gui,MenuObjShow:Font, s10, Microsoft YaHei
	Gui,MenuObjShow:Add, Listview, xm w1000 r30 grid AltSubmit vRunAnyMenuObjShowLV, 菜单项名|全局热键|热字符串|管理员|透明度|菜单运行路径
	RunAnyMenuObjShowImageListID := IL_Create(11)
	Icon_Image_Set(RunAnyMenuObjShowImageListID)
	GuiControl,MenuObjShow: -Redraw, RunAnyMenuObjShowLV
	LV_SetImageList(RunAnyMenuObjShowImageListID)
	for k,v in MenuObj
	{
		if(v="")
			continue
		hotstr:=hotStrShow:=itemAdminRun:=menuTransNum:=""
		kname:=k
		if(MenuObjKeyList[k]){
			klist:=StrSplit(k,"`t",,2)
			kname:=klist[1]
		}
		if(RegExMatch(kname,"S).*_:\d{1,2}$")){
			menuTransNum:=RegExReplace(kname,"S).*?_:(\d{1,2})$","$1")
			kname:=RegExReplace(kname,"S)(.*)_:\d{1,2}$","$1")
		}
		if(RegExMatch(kname,"S):[*?a-zA-Z0-9]+?:[^:]*")){
			hotstr:=RegExReplace(kname,"S)^[^:]*?(:[*?a-zA-Z0-9]+?:[^:]*)","$1")
			hotStrShow:=RegExReplace(hotstr,"S)^:[^:]*?X[^:]*?:")
			menuItemTemp:=RegExReplace(kname,"S)^([^:]*?):[*?a-zA-Z0-9]+?:[^:]*","$1")
			if(menuItemTemp)
				kname:=menuItemTemp
		}
		if(RegExMatch(kname,"S)\[#\]$")){
			itemAdminRun:="是"
			kname:=RegExReplace(kname,"S)^(.*?)\[#\]$","$1")
		}
		LV_Add(Set_Icon(RunAnyMenuObjShowImageListID,v,false,false,v), kname, MenuObjKeyList[k], hotStrShow, itemAdminRun, menuTransNum, v)
	}
	GuiControl,MenuObjShow: +Redraw, RunAnyMenuObjShowLV
	LV_ModifyCol()
	LV_ModifyCol(1, 200)
	LV_ModifyCol(1, "Sort")  ; 排序
	Gui,MenuObjShow:Show, , %RunAnyZz% 所有菜单运行项 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
;--------------------------------------------------------------------------------------------
