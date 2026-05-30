;~;【——🔗启动控制Gui——】
;══════════════════════════════════════════════════════════════════
RunCtrl_Manage_Gui:
	Gosub,RunCtrl_Read
	RunCtrlListBoxChoose:=1
	if(RunCtrlListBox!=""){
		RunCtrlListBoxChoose:=GetKeyByVal(RunCtrlListBoxList, RunCtrlListBox)
	}
	Gui,RunCtrlManage:Destroy
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:+Resize
	Gui,RunCtrlManage:Font, s10, Microsoft YaHei
	Gui,RunCtrlManage:Add, ListBox, x16 w130 vRunCtrlListBox gRunCtrlListClick Choose%RunCtrlListBoxChoose%, %RunCtrlListBoxVar%
	Gui,RunCtrlManage:Add, Listview,x+15 w570 r15 grid AltSubmit vRunCtrlLV gRunCtrlListView, 启动项|类型|重复运行|管理员运行|运行方式|最后运行时间
	LVImageListID := IL_Create(11)
	Icon_Image_Set(LVImageListID)
	LV_SetImageList(LVImageListID)
	Gosub,RunCtrlListClick
	RunCtrlLVMenu("RunCtrlLVMenu")
	RunCtrlLVMenu("RunCtrlManageMenu")
	Gui,RunCtrlManage: Menu, RunCtrlManageMenu
	Gui,RunCtrlManage:Show, w755 , RunCtrl 启动管理 %RunAny_update_version% %RunAny_update_time%%AdminMode%(双击修改，右键操作)
	Sleep,200
	if(RuleNameStr="" || RunCtrlListBoxVar=""){
		MsgBox,64,,首次使用请阅读：`n1. 先点击“规则管理”按钮后再点击“添加默认规则”`n
		(
2. 然后返回界面点击“添加规则组”`n3. 最后再点击“添加启动应用”`n`n这样就可以自动根据不同规则判断来运行不同的程序了
		)
	}
return

RunCtrlListClick:
	if (A_GuiEvent = "Normal" || A_GuiEvent = "")
	{
		Gui,RunCtrlManage:Default
		Gui,RunCtrlManage:Submit, NoHide
		LV_delete()
		GuiControl,RunCtrlManage:-Redraw, RunCtrlLV
		For runn, runv in RunCtrlList[RunCtrlListBox].runList
		{
			LV_Add(Set_Icon(LVImageListID,runv.noPath ? Get_Obj_Path(runv.path) : runv.path,false,false,runv.path)
				, runv.path, runv.noPath ? "菜单项" : "全路径", runv.repeatRun ? "重复" : "", runv.adminRun ? "管理员" : ""
				, StrReplace(RunCtrlRunWayList[runv.runWay],"启动"), time_format(runv.lastRunTime))
		}
		GuiControl,RunCtrlManage:+Redraw, RunCtrlLV
		LV_ModifyCol()
		LV_ModifyCol(1,245)
		LV_ModifyCol(6,150)
	}else if A_GuiEvent = DoubleClick
	{
		Gosub,RunCtrlLVEdit
	}
return
RunCtrlListView:
	if A_GuiEvent = DoubleClick
	{
		Gosub,LVCtrlRunEdit
	}
return
;创建头部及右键功能菜单
RunCtrlLVMenu(addMenu){
	flag:=addMenu="RunCtrlManageMenu" ? true : false
	Menu, %addMenu%, Add,% flag ? "启动" : "启动`tF1", RunCtrlLVRun
	Menu, %addMenu%, Icon,% flag ? "启动" : "启动`tF1",% RunCtrlManageIconS[1],% RunCtrlManageIconS[2]
	Menu, %addMenu%, Add,% flag ? "添加规则组" : "添加规则组`tF3", RunCtrlLVAdd
	Menu, %addMenu%, Icon,% flag ? "添加规则组" : "添加规则组`tF3", SHELL32.dll,22
	Menu, %addMenu%, Add,% flag ? "添加启动应用" : "添加启动应用`tF4", LVCtrlRunAdd
	Menu, %addMenu%, Icon,% flag ? "添加启动应用" : "添加启动应用`tF4",% EXEIconS[1],% EXEIconS[2]
	Menu, %addMenu%, Add,% flag ? "编辑" : "编辑`tF2", RunCtrlLVEdit
	Menu, %addMenu%, Icon,% flag ? "编辑" : "编辑`tF2", SHELL32.dll,134
	Menu, %addMenu%, Add,% flag ? "移除" : "移除`tDel", RunCtrlLVDel
	Menu, %addMenu%, Icon,% flag ? "移除" : "移除`tDel", SHELL32.dll,132
	Menu, %addMenu%, Add,% flag ? "规则管理" : "规则管理`tF7", Rule_Manage_Gui
	Menu, %addMenu%, Icon,% flag ? "规则管理" : "规则管理`tF7", imageres.dll,112
	Menu, %addMenu%, Add,% flag ? "导入" : "导入`tF8", RunCtrlLVImport
	Menu, %addMenu%, Icon,% flag ? "导入" : "导入`tF8", SHELL32.dll,55
	Menu, %addMenu%, Add,% flag ? "下移" : "下移`t(F5/PgDn)", RunCtrlLVDown
	try Menu, %addMenu%, Icon,% flag ? "下移" : "下移`t(F5/PgDn)",% DownIconS[1],% DownIconS[2]
	Menu, %addMenu%, Add,% flag ? "上移" : "上移`t(F6/PgUp)", RunCtrlLVUp
	try Menu, %addMenu%, Icon,% flag ? "上移" : "上移`t(F6/PgUp)",% UpIconS[1],% UpIconS[2]
	Menu, %addMenu%, Add,% flag ? "全选" : "全选`tCtrl+A", RunCtrlLVSelect
}
RunCtrlLVDel:
	Gui,RunCtrlManage:Default
	if(RunCtrlListBox="")
		return
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		MsgBox,35,确认移除规则组 %RunCtrlListBox%？(Esc取消),确定移除规则组：%RunCtrlListBox% ？`n【注意!】：同时会移除 %RunCtrlListBox% 下的所有启动项和规则条件！
		IfMsgBox Yes
		{
			IniDelete,%RunAnyConfig%,RunCtrlList,%RunCtrlListBox%
			IniDelete,%RunAnyConfig%,%RunCtrlListBox%_Run
			IniDelete,%RunAnyConfig%,%RunCtrlListBox%_Rule
			Gosub,RunCtrl_Manage_Gui
		}
	}
	if(focusGuiName!="SysListView321"){
		return
	}
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row){
		MsgBox,35,确认移除？(Esc取消),确定移除当前选中的启动项？
		DelRowList:=""
	}
	DelRunValList:=Object()
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(RunCtrlRunValue, RowNumber, 1)
		LV_GetText(RunCtrlNoPath, RowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RowNumber, 3)
		LV_GetText(RunCtrlAdminRun, RowNumber, 4)
		LV_GetText(RunCtrlRunWay, RowNumber, 5)
		IfMsgBox Yes
		{
			DelRowList := RowNumber . ":" . DelRowList
			oldStr:=RunCtrlRunIniKeyJoin(RunCtrlNoPath="菜单项", RunCtrlRepeatRun="重复", RunCtrlAdminRun="管理员"
				, GetKeyByVal(RunCtrlRunWayList, RunCtrlRunWay "启动")) "=" RunCtrlRunValue
			DelRunValList[oldStr]:=true
			IniDelete, %RunCtrlLastTimeIni%, last_run_time, %RunCtrlRunValue%
		}
	}
	IfMsgBox Yes
	{
		DelRowList:=SubStr(DelRowList, 1, -StrLen(":"))
		loop, parse, DelRowList, :
			LV_Delete(A_loopfield)

		IniRead,ctrlAppsVar,%RunAnyConfig%,%RunCtrlListBox%_Run
		runContent:=""
		Loop, parse, ctrlAppsVar, `n, `r
		{
			runContent.=DelRunValList[A_LoopField] ? "" : A_LoopField "`n"
		}
		IniWrite,%runContent%,%RunAnyConfig%,%RunCtrlListBox%_Run
		Gosub,RunCtrl_Read
	}
return
#If WinActive("RunCtrl 启动管理 " RunAny_update_version A_Space RunAny_update_time)
	F1::Gosub,RunCtrlLVRun
	F2::Gosub,RunCtrlLVEdit
	F3::Gosub,RunCtrlLVAdd
	F4::Gosub,LVCtrlRunAdd
	Del::Gosub,RunCtrlLVDel
	F7::Gosub,Rule_Manage_Gui
	^a::Gosub,RunCtrlLVSelect
#If
RunCtrlLVUp:
RunCtrlLVDown:
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:Submit, NoHide
	if(RunCtrlListBox=""){
		return
	}
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		;上下移动规则组
		RunCtrlListContent:=""
		for i,v in RunCtrlListBoxList
		{
			if(A_ThisLabel="RunCtrlLVDown"){
				if(RunCtrlListBox=v){
					if((i + 1) > RunCtrlListBoxList.MaxIndex()){
						return
					}
					RunCtrlListContent.=RunCtrlListBoxList[i + 1] "=" RunCtrlListContentList[RunCtrlListBoxList[i + 1]] "`n"
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}else if(RunCtrlListBox!=RunCtrlListBoxList[i - 1]){
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}
			}else if(A_ThisLabel="RunCtrlLVUp"){
				if(RunCtrlListBox=v){
					if((i - 1) <= 0){
						return
					}
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
					RunCtrlListContent.=RunCtrlListBoxList[i - 1] "=" RunCtrlListContentList[RunCtrlListBoxList[i - 1]] "`n"
				}else if(RunCtrlListBox!=RunCtrlListBoxList[i + 1]){
					RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
				}
			}
		}
		RunCtrlListContent:=SubStr(RunCtrlListContent, 1, -StrLen("`n"))
		IniWrite,%RunCtrlListContent%,%RunAnyConfig%,RunCtrlList
		Gosub,RunCtrl_Manage_Gui
		return
	}
	RunRowNumber1 := LV_GetNext(0, "F")
	if not RunRowNumber1
		return
	if(A_ThisLabel="RunCtrlLVDown"){
		RunRowNumber2 := RunRowNumber1 + 1
		RunRowCount := LV_GetCount()
		if(RunRowNumber2 > RunRowCount)
			return
	}else if(A_ThisLabel="RunCtrlLVUp"){
		RunRowNumber2 := RunRowNumber1 - 1
		if(RunRowNumber2 <= 0)
			return
	}
	LV_GetText(RunCtrlRunValue1, RunRowNumber1, 1)
	LV_GetText(RunCtrlNoPath1, RunRowNumber1, 2)
	LV_GetText(RunCtrlRepeatRun1, RunRowNumber1, 3)
	LV_GetText(RunCtrlAdminRun1, RunRowNumber1, 4)
	LV_GetText(RunCtrlRunWay1, RunRowNumber1, 5)
	LV_GetText(RunCtrlLastRunTime1, RunRowNumber1, 6)

	LV_GetText(RunCtrlRunValue2, RunRowNumber2, 1)
	LV_GetText(RunCtrlNoPath2, RunRowNumber2, 2)
	LV_GetText(RunCtrlRepeatRun2, RunRowNumber2, 3)
	LV_GetText(RunCtrlAdminRun2, RunRowNumber2, 4)
	LV_GetText(RunCtrlRunWay2, RunRowNumber2, 5)
	LV_GetText(RunCtrlLastRunTime2, RunRowNumber2, 6)

	LV_Modify(RunRowNumber1,Set_Icon(LVImageListID,RunCtrlNoPath2 ? Get_Obj_Path(RunCtrlRunValue2) : RunCtrlRunValue2,false,false,RunCtrlRunValue2)
		,RunCtrlRunValue2,RunCtrlNoPath2,RunCtrlRepeatRun2,RunCtrlAdminRun2,RunCtrlRunWay2,RunCtrlLastRunTime2)
	LV_Modify(RunRowNumber2,Set_Icon(LVImageListID,RunCtrlNoPath1 ? Get_Obj_Path(RunCtrlRunValue1) : RunCtrlRunValue1,false,false,RunCtrlRunValue1)
		,RunCtrlRunValue1,RunCtrlNoPath1,RunCtrlRepeatRun1,RunCtrlAdminRun1,RunCtrlRunWay1,RunCtrlLastRunTime1)
	;顺序改变后写入配置文件
	runContent=
	Gui, ListView, RunCtrlLV
	Loop % LV_GetCount()
	{
		LV_GetText(RunCtrlRunValue, A_Index, 1)
		LV_GetText(RunCtrlNoPath, A_Index, 2)
		LV_GetText(RunCtrlRepeatRun, A_Index, 3)
		LV_GetText(RunCtrlAdminRun, A_Index, 4)
		LV_GetText(RunCtrlRunWay, A_Index, 5)
		runContent.=RunCtrlRunIniKeyJoin(RunCtrlNoPath="菜单项", RunCtrlRepeatRun="重复", RunCtrlAdminRun="管理员"
			, GetKeyByVal(RunCtrlRunWayList, RunCtrlRunWay "启动")) "=" RunCtrlRunValue "`n"
	}
	runContent:=SubStr(runContent, 1, -StrLen("`n"))
	IniWrite, %runContent%, %RunAnyConfig%, %RunCtrlListBox%_Run
	LV_Modify(0, "-Select")
	LV_Modify(RunRowNumber2, "Select Focus")
return
RunCtrlLVSelect:
	Gui,RunCtrlManage:Default
	LV_Modify(0, "Select Focus")   ; 选择所有.
return
RunCtrlLVRun:
	Gui,RunCtrlManage:Default
	Gui,RunCtrlManage:Submit, NoHide
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		effectResult:=RunCtrl_RunRules(RunCtrlList[RunCtrlListBox],true)
	}else if(focusGuiName="SysListView321"){
		Gosub,LVCtrlRunRun
	}
return
RunCtrlLVAdd:
	RuleGroupName:=RuleGroupLogic2:=RuleMostRun:=RuleIntervalTime:=RuleGroupKey:=RunCtrlListBox:=""
	RuleEnable:=RuleGroupLogic1:=true
	RuleGroupWinKey:=false
	menuItem:="新建"
	Gosub,RunCtrlConfig
return
RunCtrlLVEdit:
	RuleGroupName:=RunCtrlListBox
	menuItem:="编辑"
	Gui,RunCtrlManage:Default
	GuiControlGet, focusGuiName, Focus
	if(focusGuiName="ListBox1"){
		RuleEnable:=RunCtrlList[RunCtrlListBox].enable
		RuleEnableText:=RuleEnable ? "Green" : ""
		RuleGroupLogic1:=RunCtrlList[RunCtrlListBox].ruleLogic
		RuleGroupLogic2:=RuleGroupLogic1 ? 0 : 1
		RuleMostRun:=RunCtrlList[RunCtrlListBox].ruleMostRun
		RuleMostRun:=RuleMostRun<0 ? "" : RuleMostRun
		RuleIntervalTime:=RunCtrlList[RunCtrlListBox].ruleIntervalTime
		RuleIntervalTime:=RuleIntervalTime=0 ? "" : RuleIntervalTime
		RuleGroupKey:=RunCtrlList[RunCtrlListBox].key
		RuleGroupWinKey:=0
		if(InStr(RuleGroupKey,"#")){
			RuleGroupWinKey:=1
			RuleGroupKey:=StrReplace(RuleGroupKey, "#")
		}
		Gosub,RunCtrlConfig
	}else if(focusGuiName="SysListView321"){
		Gosub,LVCtrlRunEdit
	}
return
;~;【启动控制-规则组配置Gui】
RunCtrlConfig:
	Gui,RunCtrlConfig:Destroy
	Gui,RunCtrlConfig:Default
	Gui,RunCtrlConfig:+Resize
	Gui,RunCtrlConfig:+OwnerRunCtrlManage
	Gui,RunCtrlConfig:Font,,Microsoft YaHei
	Gui,RunCtrlConfig:Margin,20,20
	Gui,RunCtrlConfig:Add, CheckBox, xm+5 y+15 Checked%RuleEnable% vvRuleEnable c%RuleEnableText%, 启用规则组
	Gui,RunCtrlConfig:Add, Text, x+30 yp w60, 全局热键：
	Gui,RunCtrlConfig:Add, Hotkey,x+5 yp-2 w130 h22 vvRuleGroupKey,%RuleGroupKey%
	Gui,RunCtrlConfig:Add, Checkbox, x+10 yp+3 w55 Checked%RuleGroupWinKey% vvRuleGroupWinKey,Win
	Gui,RunCtrlConfig:Add, Text, xm+5 yp+30 w60, 规则组名：
	Gui,RunCtrlConfig:Add, Edit, x+5 yp-3 w300 vvRuleGroupName, %RuleGroupName%
	Gui,RunCtrlConfig:Add, GroupBox,xm y+10 w500 h385 vFuncGroup,规则组设置
	Gui,RunCtrlConfig:Add, Radio, xm+10 yp+25 Checked%RuleGroupLogic1% vvRuleGroupLogic1, 与（全部规则都验证成立）(&A)
	Gui,RunCtrlConfig:Add, Radio, x+10 yp Checked%RuleGroupLogic2% vvRuleGroupLogic2, 或（一个规则即验证成立）(&O)
	Gui,RunCtrlConfig:Add, Text, xm+10 y+15 w100, 规则循环最大次数:
	Gui,RunCtrlConfig:Add, Edit, x+2 yp-3 Number w70 h20 vvRuleMostRun, %RuleMostRun%
	Gui,RunCtrlConfig:Add, Text, x+20 yp+3 w110, 循环间隔时间(秒):
	Gui,RunCtrlConfig:Add, Edit, x+2 yp-3 w100 h20 vvRuleIntervalTime, %RuleIntervalTime%
	Gui,RunCtrlConfig:Add, Button, xm+10 y+15 w85 GLVFuncAdd, + 增加规则(&A)
	Gui,RunCtrlConfig:Add, Button, x+10 yp w85 GLVFuncEdit, · 修改规则(&E)
	Gui,RunCtrlConfig:Add, Button, x+10 yp w85 GLVFuncRemove, - 减少规则(&D)
	Gui,RunCtrlConfig:Font, s10, Microsoft YaHei
	Gui,RunCtrlConfig:Add, Listview, xm+10 y+10 w480 r10 grid AltSubmit C808000 vFuncLV glistfunc, 规则名|中断|条件|条件值
	;[读取启动项设置的规则内容写入列表]
	GuiControl, RunCtrlConfig:-Redraw, FuncLV
	For k, v in RunCtrlList[RunCtrlListBox].ruleList
	{
		funcBoolean:=v.logic="1" ? "相等" : v.logic="0" ? "不相等" : RunCtrlLogicEnum[v.logic]
		if(!rulestatusList[v.name]){
			funcBoolean:="规则函数未找到"
		}else if(!ruletypelist[v.name] && v.file!="RunAny" && !rule_check_is_run(PluginsPathList[v.file ".ahk"])){
			funcBoolean:="规则插件未启动"
		}
		LV_Add("", v.name, v.ruleBreak, funcBoolean, v.value)
	}
	LV_ModifyCol(1)
	LV_ModifyCol(2)
	LV_ModifyCol(3)
	GuiControl, RunCtrlConfig:+Redraw, FuncLV
	Gui,RunCtrlConfig:Add,Button,Default xm+150 y+15 w75 vvFuncSave GRunCtrlLVSave,保存(&Y)
	Gui,RunCtrlConfig:Add,Button,x+20 w75 vvFuncCancel GSetCancel,取消(&C)
	Gui,RunCtrlConfig:Show, , RunCtrl 规则组 - %menuItem% %RunAny_update_version% %RunAny_update_time%%AdminMode%
return

RunCtrlLVSave:
	Gui,RunCtrlConfig:Submit, NoHide
	fnx:=250
	fny:=100
	if(!vRuleGroupName){
		ToolTip, 请填入规则组名,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(RuleGroupName!=vRuleGroupName && RunCtrlList[vRuleGroupName]){
		ToolTip, 已存在相同的规则组名，请修改,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(Instr(vRuleGroupName, A_SPACE)){
		StringReplace, vRuleGroupName, vRuleGroupName, %A_SPACE%, _, All
		GuiControl, RunCtrlConfig:, vRuleGroupName, %vRuleGroupName%
		ToolTip, 规则组名不能带有空格，请用_代替,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(Instr(vRuleGroupName, A_Tab)){
		StringReplace, vRuleGroupName, vRuleGroupName, %A_Tab%, _, All
		GuiControl, RunCtrlConfig:, vRuleGroupName, %vRuleGroupName%
		ToolTip, 规则组名不能带有制表符，请用_代替,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	;中文、数字、字母、下划线正则校验，根据Unicode字符属性Han来判断中文，RunAnyCtrl.ahk编码不能为ANSI
	if(!RegExMatch(vRuleGroupName,"^[\p{Han}A-Za-z0-9_]+$")){
		ToolTip, 规则组名只能为中文、数字、字母、下划线,%fnx%,%fny%
		SetTimer,RemoveToolTip,3500
		return
	}
	runContent:=ruleContent:=""
	Loop % LV_GetCount()
	{
		LV_GetText(RuleName, A_Index, 1)
		LV_GetText(FuncBreak, A_Index, 2)
		LV_GetText(FuncBoolean, A_Index, 3)
		LV_GetText(FuncValue, A_Index, 4)
		FuncBoolean:=GetKeyByVal(RunCtrlLogicEnum, FuncBoolean)
		FuncBoolean:=FuncBoolean="eq" ? 1 : FuncBoolean="ne" ? 0 : FuncBoolean
		FuncBreak:=FuncBreak ? "|" FuncBreak : ""
		ruleContent.=RuleName . "|" . FuncBoolean . FuncBreak . "=" . FuncValue . "`n"
	}
	;[写入配置文件]
	Gui,RunCtrlManage:Default
	ruleLogicVal:=vRuleGroupLogic1=1 ? 1 : 0
	ruleRunListVal=%vRuleEnable%|%ruleLogicVal%
	if(vRuleMostRun!=""){
		ruleRunListVal.="|" vRuleMostRun "|" vRuleIntervalTime
	}
	if(vRuleGroupKey!=""){
		if(vRuleMostRun=""){
			ruleRunListVal.="||"
		}
		vRuleGroupKey:=vRuleGroupWinKey ? "#" . vRuleGroupKey : vRuleGroupKey
		ruleRunListVal.="|" vRuleGroupKey
	}

	if(menuItem="编辑"){
		runCtrlListNo:=GetKeyByVal(RunCtrlListBoxList, RuleGroupName)
		;如果是修改规则组，先删除老规则组
		if(!(RuleGroupName==vRuleGroupName)){
			IniDelete, %RunAnyConfig%, RunCtrlList, %RuleGroupName%
			IniDelete, %RunAnyConfig%, %RuleGroupName%_Rule
			IniDelete, %RunAnyConfig%, %RuleGroupName%_Run
		}
		RunCtrlListContent:=""
		for i,v in RunCtrlListBoxList
		{
			if(i=runCtrlListNo){
				RunCtrlListContent.=vRuleGroupName "=" ruleRunListVal "`n"
			}else{
				RunCtrlListContent.=v "=" RunCtrlListContentList[v] "`n"
			}
		}
		RunCtrlListContent:=SubStr(RunCtrlListContent, 1, -StrLen("`n"))
		IniWrite, %RunCtrlListContent%, %RunAnyConfig%, RunCtrlList
	}else{
		IniWrite, %ruleRunListVal%, %RunAnyConfig%, RunCtrlList, %vRuleGroupName%
	}

	if(RunCtrlList[RuleGroupName]){
		For runn, runv in RunCtrlList[RuleGroupName].runList
		{
			runContent.=RunCtrlRunIniKeyJoin(runv.noPath,runv.repeatRun,runv.adminRun,runv.runWay) "=" runv.path "`n"
		}
		runContent:=SubStr(runContent, 1, -StrLen("`n"))
	}
	IniWrite, %runContent%, %RunAnyConfig%, %vRuleGroupName%_Run
	ruleContent:=SubStr(ruleContent, 1, -StrLen("`n"))
	IniWrite, %ruleContent%, %RunAnyConfig%, %vRuleGroupName%_Rule
	Gui,RunCtrlConfig:Destroy
	Gosub,RunCtrl_Manage_Gui
return
RunCtrlLVImport:
	Gui,RunCtrlConfig:Submit, NoHide
	runContent:=""
	IniRead,ctrlAppsVar,%RunAnyConfig%,%RunCtrlListBox%_Run
	FileSelectFile, selectName, M35, , 选择多个你要导入的启动项, (*.*)
	Loop,parse,selectName,`n
	{
		if(A_Index=1){
			dir:=A_LoopField
		}else{
			fullPath:=dir "\" A_LoopField
			SplitPath, fullPath, , , ext, name_no_ext
			runContent.="path=" fullPath "`n"
		}
	}
	runContent:=SubStr(runContent, 1, -StrLen("`n"))
	runContent:=ctrlAppsVar!="" ? ctrlAppsVar "`n" runContent : runContent
	IniWrite,%runContent%,%RunAnyConfig%,%RunCtrlListBox%_Run
	Gosub,RunCtrl_Manage_Gui
return
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;[规则函数配置]
LVFuncAdd:
	menuFuncItem:="新建规则函数"
	RuleName:=FuncBoolean:=FuncValue:=""
	FuncBooleanNE:=FuncBooleanGE:=FuncBooleanLE:=FuncBooleanGT:=FuncBooleanLT:=FuncBooleanRegEx:=FuncBreak:=false
	FuncBooleanEQ:=true
	RuleNameChoose:=1
	Gosub,LVFuncConfig
return
LVFuncEdit:
	menuFuncItem:="修改规则函数"
	RowNumber:=LV_GetNext(0, "F")
	if not RowNumber
		return
	LV_GetText(RuleName, RowNumber, 1)
	LV_GetText(FuncBreak, RowNumber, 2)
	LV_GetText(FuncBoolean, RowNumber, 3)
	LV_GetText(FuncValue, RowNumber, 4)
	FuncBreak:=FuncBreak ? 1 : 0
	for k,v in RunCtrlLogicEnum
	{
		FuncBoolean%k%:=false
		if(v=FuncBoolean){
			FuncBoolean%k%:=true
		}
	}
	RuleNameChoose:=1
	loop, parse, rulenameStr, |
	{
		if(RuleName=A_LoopField){
			RuleNameChoose:=A_Index
			break
		}
	}
	FuncValue:=StrReplace(FuncValue,"``t","`t")
	FuncValue:=StrReplace(FuncValue,"``n","`n")
	Gosub,LVFuncConfig
return
;~;【启动控制-运行规则Gui】
LVFuncConfig:
	Gui,RunCtrlFunc:Destroy
	Gui,RunCtrlFunc:+Resize
	Gui,RunCtrlFunc:+OwnerRunCtrlConfig
	Gui,RunCtrlFunc:Font,,Microsoft YaHei
	Gui,RunCtrlFunc:Margin,20,10
	Gui,RunCtrlFunc:Add, Text, xm y+10 w60, 规则名：
	Gui,RunCtrlFunc:Add, DropDownList, xm+60 yp-3 Choose%RuleNameChoose% GDropDownRuleChoose vvRuleName, %RuleNameStr%
	Gui,RunCtrlFunc:Add, Text, x+10 yp+3 cblue w150 GClipboardRuleResultText vvRuleResultText,
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanEQ% vvFuncBooleanEQ, 相等 ( 真 &True 1 )
	Gui,RunCtrlFunc:Add, Radio, x+4 yp Checked%FuncBooleanNE% vvFuncBooleanNE, 不相等 ( 假 &False 0 )
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanGE% vvFuncBooleanGE, 大于等于
	Gui,RunCtrlFunc:Add, Radio, x+6 yp Checked%FuncBooleanLE% vvFuncBooleanLE, 小于等于
	Gui,RunCtrlFunc:Add, Radio, xm y+10 Checked%FuncBooleanGT% vvFuncBooleanGT, 大于
	Gui,RunCtrlFunc:Add, Radio, x+6 yp Checked%FuncBooleanLT% vvFuncBooleanLT, 小于
	Gui,RunCtrlFunc:Add, Radio, x+6 yp Checked%FuncBooleanRegEx% vvFuncBooleanRegEx, 正则表达式
	Gui,RunCtrlFunc:Add, CheckBox, xm y+10 Checked%FuncBreak% vvFuncBreak, 不满足此条件就中断整个规则循环（建议排在其他规则前面）
	Gui,RunCtrlFunc:Add, Text, xm y+10 w350 vvRuleText, 条件值：（只判断规则真假，可不填写）
	Gui,RunCtrlFunc:Add, Text, xm yp w350 cblue vvRuleParamText, 条件值：（条件值变为参数传递到规则函数，只判断结果真假）
	; `n多个参数每行为一个参数，最多支持10个，保存会用|分隔
	Gui,RunCtrlFunc:Add, Edit, xm y+10 w350 r6 vvFuncValue GFuncValueChange, %FuncValue%
	Gui,RunCtrlFunc:Add, Button,Default xm+80 y+15 w75 vvFuncSave GLVFuncSave,保存(&Y)
	Gui,RunCtrlFunc:Add, Button,x+10 w75 vvFuncCancel GSetCancel,取消(&C)
	Gui,RunCtrlFunc:Show, , RunCtrl 修改规则函数 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	Gosub,DropDownRuleChoose
return
LVFuncRemove:
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
LVFuncSave:
	Gui,RunCtrlFunc:Submit, NoHide
	fnx:=40
	fny:=230
	if(!vRuleName){
		ToolTip, 请选择使用的规则,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	if(vFuncValue="" && !(vFuncBooleanEQ || vFuncBooleanNE)){
		ToolTip, 如果是大于或小于请填写条件值,%fnx%,%fny%
		SetTimer,RemoveToolTip,3000
		return
	}
	vFuncValue:=RTrim(vFuncValue,"`n")
	vFuncValue:=StrReplace(vFuncValue,"`t","``t")
	vFuncValue:=StrReplace(vFuncValue,"`n","``n")
	;[写入配置文件]
	Gui,RunCtrlFunc:Destroy
	Gui,RunCtrlConfig:Default
	for k,v in RunCtrlLogicEnum
	{
		if(vFuncBoolean%k%){
			funcBoolean:=k
		}
	}
	ruleLogic:=RunCtrlLogicEnum[funcBoolean]
	if(menuFuncItem="修改规则函数"){
		LV_Modify(RowNumber,"",vRuleName,vFuncBreak ? "*" : "",ruleLogic,vFuncValue)
	}else{
		LV_Add("",vRuleName,vFuncBreak ? "*" : "",ruleLogic,vFuncValue)
	}
	LV_ModifyCol(1)
	LV_ModifyCol(2)
	LV_ModifyCol(3)
	GuiControl, RunCtrlConfig:+Redraw, FuncLV
return
listfunc:
	if A_GuiEvent = DoubleClick
	{
		Gosub,LVFuncEdit
	}
return
DropDownRuleChoose:
	Gui,RunCtrlFunc:Submit, NoHide
	if(ruleparamList[vRuleName]){
		GuiControl, RunCtrlFunc:show, vRuleParamText
		GuiControl, RunCtrlFunc:hide, vRuleText
		if(FuncBooleanEQ){
			GuiControl, RunCtrlFunc:,vFuncBooleanEQ,1
		}else{
			GuiControl, RunCtrlFunc:,vFuncBooleanNE,1
		}
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanGE
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanLE
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanGT
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanLT
		GuiControl, RunCtrlFunc:Disable, vFuncBooleanRegEx
	}else{
		GuiControl, RunCtrlFunc:show, vRuleText
		GuiControl, RunCtrlFunc:hide, vRuleParamText
		GuiControl, RunCtrlFunc:enable, vFuncBooleanGE
		GuiControl, RunCtrlFunc:enable, vFuncBooleanLE
		GuiControl, RunCtrlFunc:enable, vFuncBooleanGT
		GuiControl, RunCtrlFunc:enable, vFuncBooleanLT
		GuiControl, RunCtrlFunc:enable, vFuncBooleanRegEx
	}
	GuiControl, RunCtrlFunc:,vRuleResultText,% RunCtrl_RuleResult(vRuleName, ruleitemList[vRuleName], vFuncValue)
return
ClipboardRuleResultText:
	Gui,RunCtrlFunc:Submit, NoHide
	GuiControlGet, OutputVar, ,vRuleResultText
	Clipboard:=OutputVar
	ToolTip, 已复制到剪贴板
	SetTimer,RemoveToolTip,2000
return
FuncValueChange:
	Gui,RunCtrlFunc:Submit, NoHide
	if(!InStr(rulefileList[vRuleName],"RunCtrl_Network.ahk")){
		Gosub,DropDownRuleChoose
	}
return
SetFilePath:
	FileSelectFile, filePath, 3, , 请选择导入的启动项, (*.ahk;*.exe)
	GuiControl, RunCtrlConfig:, vFilePath, %filePath%
return
;~;【启动控制-启动项Gui】
LVCtrlRunAdd:
	menuItem:="新建"
	RunCtrlRepeatRun:=RunCtrlAdminRun:=RunCtrlRunWay:=RunCtrlRunValue:=""
	RunCtrlNoPath:="菜单项"
	Gosub,LVCtrlRunConfig
return
LVCtrlRunEdit:
	menuItem:="编辑"
	Gosub,LVCtrlRunConfig
return
LVCtrlRunRun:
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		LV_GetText(RunCtrlRunValue, RowNumber, 1)
		LV_GetText(RunCtrlNoPath, RowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RowNumber, 3)
		LV_GetText(RunCtrlAdminRun, RowNumber, 4)
		LV_GetText(RunCtrlRunWay, RowNumber, 5)
		RunCtrl_RunApps(RunCtrlRunValue, RunCtrlNoPath="菜单项" ? 1 : 0, 1
			, RunCtrlAdminRun="管理员" ? 1 : 0, GetKeyByVal(RunCtrlRunWayList, RunCtrlRunWay "启动"))
	}
return
LVCtrlRunConfig:
	Gui, ListView, RunCtrlLV
	if(menuItem="编辑"){
		RunRowNumber := LV_GetNext(0, "F")
		if not RunRowNumber
			return
		LV_GetText(RunCtrlRunValue, RunRowNumber, 1)
		LV_GetText(RunCtrlNoPath, RunRowNumber, 2)
		LV_GetText(RunCtrlRepeatRun, RunRowNumber, 3)
		LV_GetText(RunCtrlAdminRun, RunRowNumber, 4)
		LV_GetText(RunCtrlRunWay, RunRowNumber, 5)
	}
	RunCtrlNoPath1:=RunCtrlNoPath="菜单项" ? 1 : 0
	RunCtrlNoPath2:=RunCtrlNoPath1 ? 0 : 1
	RunCtrlRepeatRun:=RunCtrlRepeatRun="重复" ? 1 : 0
	RunCtrlAdminRun:=RunCtrlAdminRun="管理员" ? 1 : 0
	RunCtrlRunWay:=GetKeyByVal(RunCtrlRunWayList, RunCtrlRunWay "启动")
	Gui,CtrlRun:Destroy
	Gui,CtrlRun:Default
	Gui,CtrlRun:+OwnerRunCtrlManage
	Gui,CtrlRun:Margin,20,20
	Gui,CtrlRun:Font,,Microsoft YaHei
	Gui,CtrlRun:Add, Radio, xm+10 yp+20 Checked%RunCtrlNoPath1% vvRunCtrlNoPath1, 菜单项(&Z)
	Gui,CtrlRun:Add, Radio, x+42 yp Checked%RunCtrlNoPath2% vvRunCtrlNoPath2, 全路径(&A)
	Gui,CtrlRun:Add, GroupBox, xm y+5 w410 h50
	Gui,CtrlRun:Add, CheckBox, xm+10 yp+20 Checked%RunCtrlRepeatRun% vvRunCtrlRepeatRun, 重复启动(&R)
	Gui,CtrlRun:Add, CheckBox, x+30 yp Checked%RunCtrlAdminRun% vvRunCtrlAdminRun, 管理员启动(&G)
	Gui,CtrlRun:Add, DropDownList, x+30 yp-3 Choose%RunCtrlRunWay% AltSubmit GDropDownRunWayChoose vvRunCtrlRunWay, % StrListJoin("|",RunCtrlRunWayList)
	Gui,CtrlRun:Add, Button, xm y+20 w100 h60 GSetRunCtrlRunValue,运行软件路径`n或%RunAnyZz%菜单项
	Gui,CtrlRun:Add, Edit, x+12 yp+1 w300 r3 -WantReturn vvRunCtrlRunValue, %RunCtrlRunValue%
	Gui,CtrlRun:Font
	Gui,CtrlRun:Add,Button,Default xm+100 y+25 w75 GSaveRunCtrlRunValue,保存(&Y)
	Gui,CtrlRun:Add,Button,x+20 w75 GSetCancel,取消(&C)
	Gui,CtrlRun:Show,,RunCtrl - %openExtItem%启动项 %RunAny_update_version% %RunAny_update_time%
return
SetRunCtrlRunValue:
	Gui,CtrlRun:Submit, NoHide
	if(vRunCtrlNoPath1){
		global RunCtrlMenuItemFlag:=true
		Gosub,Menu_Edit1
	}else if(vRunCtrlNoPath2){
		FileSelectFile, runPath, , , 启动程序路径
		if(runPath){
			GuiControlSet("CtrlRun","vRunCtrlRunValue",runPath)
		}
	}
return
DropDownRunWayChoose:
	Gui,CtrlRun:Submit, NoHide
	if(!A_IsAdmin && vRunCtrlRunWay=2 && vRunCtrlAdminRun)
		MsgBox,48,权限不允许！, %RunAnyZz% 没有管理员权限！无法置顶操作 勾选了“管理员启动”的软件`n%vRunCtrlRunValue%
return
SaveRunCtrlRunValue:
	Gui,CtrlRun:Submit, NoHide
	if(RunCtrlListBox=""){
		Gui,CtrlRun:Destroy
		return
	}
	oldStr:=RunCtrlRunIniKeyJoin(RunCtrlNoPath1,RunCtrlRepeatRun,RunCtrlAdminRun,RunCtrlRunWay) "=" RunCtrlRunValue
	newStr:=RunCtrlRunIniKeyJoin(vRunCtrlNoPath1,vRunCtrlRepeatRun,vRunCtrlAdminRun,vRunCtrlRunWay) "=" vRunCtrlRunValue
	if(oldStr=newStr){
		Gui,CtrlRun:Destroy
		return
	}
	if(vRunCtrlNoPath2 && !InStr(vRunCtrlRunValue,".")){
		ToolTip, 全路径是直接运行，不是运行RunAny菜单项，请填写正确的启动项,30,25
		SetTimer,RemoveToolTip,5000
		return
	}
	IniRead,ctrlAppsVar,%RunAnyConfig%,%RunCtrlListBox%_Run
	runContent:=""
	if(menuItem="编辑"){
		Loop, parse, ctrlAppsVar, `n, `r
		{
			runContent.=A_LoopField=oldStr ? newStr "`n" : A_LoopField "`n"
		}
		runContent:=SubStr(runContent, 1, -StrLen("`n"))
		if(RunCtrlRunValue!=vRunCtrlRunValue){
			IniDelete, %RunCtrlLastTimeIni%, last_run_time, %RunCtrlRunValue%
		}
	}else if(menuItem="新建"){
		runContent:=ctrlAppsVar!="" ? ctrlAppsVar "`n" newStr : newStr
	}
	IniWrite,%runContent%,%RunAnyConfig%,%RunCtrlListBox%_Run
	Gosub,RunCtrl_Manage_Gui
return
RunCtrlRunIniKeyJoin(runNoPath,runRepeat,runAdminRun,runRunWay){
	newNoPath:=runNoPath ? "menu" : "path"
	newRunRepeat:=runRepeat ? "|1" : "|"
	newAdminRun:=runAdminRun ? "|1" : "|"
	newRunWay:=(runRunWay!="" && runRunWay!="1") ? "|" runRunWay : ""
	newRunStr:=(newRunRepeat="|" && newAdminRun="|" && newRunWay="") ? "" : newRunRepeat newAdminRun newRunWay
	return newNoPath newRunStr
}
;══════════════════════════════════════════════════════════════════════════════════════════════════════
;~;【——🧬规则Gui——】
;══════════════════════════════════════════════════════════════════════════════════════════════════════
Rule_Manage_Gui:
	Gosub,RunCtrl_Read
	Gui,RuleManage:Destroy
	Gui,RuleManage:Default
	Gui,RuleManage:+Resize
	Gui,RuleManage:Font, s10, Microsoft YaHei
	Gui,RuleManage:Add, Listview, xm w685 r18 grid AltSubmit BackgroundF6F6E8 vRuleLV hwndRLV glistrule, 规则名|规则函数|状态|类型|参数|示例|规则插件名
	;[读取规则内容写入列表]
	GuiControl, -Redraw, RuleLV
	NRLV := New ListView(RLV)
	For kName, kVal in rulefileList
	{
		ruleStatus:=rulestatusList[kName] ? "正常" : "未找到"
		if(!ruletypelist[kName] && kVal!="RunAny.ahk" && !rule_check_is_run(PluginsPathList[kVal])){
			ruleStatus:="未启动"
		}
		ruleResult:=""
		if(ruleStatus="正常"){
			ruleResult:=InStr(kVal,"RunCtrl_Network.ahk") ? "http://ip-api.com/json" : RunCtrl_RuleResult(kName, ruleitemList[kName], "")
		}
		LV_Add("", kName, rulefuncList[kName], ruleStatus ,ruletypelist[kName] ? "变量" : "插件",ruleparamList[kName] ? "传参" : ""	,ruleResult , kVal)
		if(ruleStatus!="正常")
			NRLV.Color(A_Index,0x999999)
	}
	GuiControl, +Redraw, RuleLV
	Menu, ruleGuiMenu, Add, 新增, LVRulePlus
	Menu, ruleGuiMenu, Icon, 新增, SHELL32.dll,1
	Menu, ruleGuiMenu, Add, 修改, LVRuleEdit
	Menu, ruleGuiMenu, Icon, 修改, SHELL32.dll,134
	Menu, ruleGuiMenu, Add, 减少, LVRuleMinus
	Menu, ruleGuiMenu, Icon, 减少, SHELL32.dll,132
	Menu, ruleGuiMenu, Add, 添加最新默认规则, LVRuleDefault
	Menu, ruleGuiMenu, Icon, 添加最新默认规则, SHELL32.dll,194
	Menu, ruleGuiMenu, Add, 全选, LVRuleSelect
	Gui,RuleManage:Menu, ruleGuiMenu
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	LV_ModifyCol(2,"Sort")
	Gui,RuleManage:Show, , RunCtrl 规则管理 %RunAny_update_version% %RunAny_update_time%%AdminMode%
return
LVRulePlus:
	menuRuleItem:="规则新建"
	RuleName:=RuleFunction:=RulePath:=""
	Gosub,RuleConfig_Gui
return
LVRuleEdit:
	RowNumber:=LV_GetNext(0, "F")
	if not RowNumber
		return
	LV_GetText(RuleName, RowNumber, 1)
	LV_GetText(RuleFunction, RowNumber, 2)
	LV_GetText(RuleType, RowNumber, 4)
	LV_GetText(RulePath, RowNumber, 7)
	menuRuleItem:="规则编辑"
	RuleTypeVar:=RuleType="变量" ? 1 : 0
	RuleTypeFunc:=RuleTypeVar=1 ? 0 : 1
	Gosub,RuleConfig_Gui
return
LVRuleSelect:
	LV_Modify(0, "Select Focus")   ; 选择所有.
return
LVRuleDefault:
	MsgBox,33,添加默认规则,需要添加最新版本的默认规则吗？`n（不影响原有规则，重复的规则不会添加）
	IfMsgBox Ok
	{
		ruleWriteStr:=ruleDefaultStr:=""
		RunCtrlRuleObj:={"电脑名":"A_ComputerName","用户名":"A_UserName","系统版本":"A_OSVersion","系统64位":"A_Is64bitOS"
			,"主屏幕宽度":"A_ScreenWidth","主屏幕高度":"A_ScreenHeight"
			,"本地时间":"A_Now","年":"A_YYYY","月":"A_MM","星期":"A_WDay","日":"A_DD","时":"A_Hour","分":"A_Min","秒":"A_Sec","剪贴板文字":"Clipboard"}
		For rName, rFunc in RunCtrlRuleObj
		{
			if(rulefileList[rName]!="0"){
				ruleWriteStr.=rName "|" rFunc "`n"
			}
		}
		ruleWriteStr:=SubStr(ruleWriteStr, 1, -StrLen("`n"))
		Sort, ruleWriteStr, CL
		Loop, Parse, ruleWriteStr, `n
		{
			IniWrite, 0, %RunAnyConfig%, RunCtrlRule, %A_LoopField%
		}
		RunCtrlRuleObj:={"开机时长(秒)":"rule_boot_time","电脑机型":"rule_chassis_types","运行状态":"rule_check_is_run","联网状态":"rule_check_network"}
		For rName, rFunc in RunCtrlRuleObj
		{
			if(!rulefileList[rName]){
				IniWrite, RunAny.ahk, %RunAnyConfig%, RunCtrlRule, %rName%|%rFunc%
			}
		}
		if(PluginsPathList["RunCtrl_Common.ahk"]){
			RunCtrlCommonRuleObj:={"内网IP":"rule_ip_internal","WiFi名":"rule_wifi_silence","验证注册表的值":"rule_check_regedit","验证ini配置的值":"rule_check_ini"
				,"运行过(今天)":"rule_run_today","最近打开文件(今天)":"rule_run_today_file"}
			For rName, rFunc in RunCtrlCommonRuleObj
			{
				if(!rulefileList[rName]){
					IniWrite, RunCtrl_Common.ahk, %RunAnyConfig%, RunCtrlRule, %rName%|%rFunc%
				}
			}
			ruleDefaultStr.="`nRunCtrl_Common.ahk"
		}
		if(PluginsPathList["RunCtrl_Network.ahk"]){
			RunCtrlNetworkRuleObj:={"城市":"rule_ip_city","国家":"rule_ip_country","国家代码":"rule_ip_countryCode","省":"rule_ip_region","省缩写":"rule_ip_regionName"
				,"纬度":"rule_ip_lat","经度":"rule_ip_lon","时区":"rule_ip_timezone","运营商":"rule_ip_isp","外网IP":"rule_ip_external"}

			For rName, rFunc in RunCtrlNetworkRuleObj
			{
				if(!rulefileList[rName]){
					IniWrite, RunCtrl_Network.ahk, %RunAnyConfig%, RunCtrlRule, %rName%|%rFunc%
				}
			}
			ruleDefaultStr.="`nRunCtrl_Network.ahk"
		}
		if(ruleDefaultStr!=""){
			Msgbox,64,,请在“插件管理”窗口里设置 %ruleDefaultStr% `n插件为自动启动，`n只有插件运行时规则才会生效`n
		}
		Gosub,Rule_Manage_Gui
	}
return
;~;【规则-编辑Gui】
RuleConfig_Gui:
	Gui,RuleConfig:Destroy
	Gui,RuleConfig:+OwnerRuleManage
	Gui,RuleConfig:Font,,Microsoft YaHei
	Gui,RuleConfig:Margin,20,10
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则名：
	Gui,RuleConfig:Add, Edit, xm+60 yp-3 w450 vvRuleName, %RuleName%
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则类型：
	Gui,RuleConfig:Add, Radio, x+4 yp Checked%RuleTypeVar% GRuleTypeChange vvRuleTypeVar, 菜单变量
	Gui,RuleConfig:Add, Radio, x+4 yp Checked%RuleTypeFunc% GRuleTypeChange vvRuleTypeFunc, 插件函数
	Gui,RuleConfig:Add, Link, x+15 yp vvVarDocs,<a href="https://hui-zz.gitee.io/runany/#/article/built-in-variables">变量参考</a>
	Gui,RuleConfig:Add, Text, xm y+10 w60, 规则函数：
	Gui,RuleConfig:Add, Edit, xm+60 yp-3 w225 vvRuleFunction, %RuleFunction%
	Gui,RuleConfig:Add, DropDownList, x+5 yp+2 w220 vvRuleDLL GDropDownRuleList
	Gui,RuleConfig:Add, Button, xm-5 yp+30 w60 h60 vvSetRulePath GSetRulePath,规则路径 可自动识别函数名
	Gui,RuleConfig:Add, Edit, xm+60 yp w450 r3 vvRulePath GRulePathChange, %RulePath%
	Gui,RuleConfig:Add, Button,Default xm+180 y+10 w75 GLVRuleSave,保存(&Y)
	Gui,RuleConfig:Add, Button,x+10 w75 GSetCancel,取消(&C)
	Gui,RuleConfig:Show, , RunCtrl 规则编辑 %RunAny_update_version% %RunAny_update_time%%AdminMode%
	funcnameStr:=KnowAhkFuncZz(RulePath)
	GuiControl, RuleConfig:, vRuleDLL, |
	GuiControl, RuleConfig:, vRuleDLL, %funcnameStr%
	funcNameChoose:=1
	loop, parse, funcnameStr, |
	{
		if(RuleFunction=A_LoopField){
			funcNameChoose:=A_Index
			break
		}
	}
	GuiControl, RuleConfig:Choose, vRuleDLL, %funcNameChoose%
	Gosub,RuleTypeChange
return
LVRuleMinus:
	DelRowList:=""
	Row:=LV_GetNext(0, "F")
	RowNumber:=0
	if(Row)
		MsgBox,51,确认删除？(Esc取消),确定删除选中的规则项？`n【注意！】此操作会连带删除所有规则组中用到的这个规则
	Loop
	{
		RowNumber := LV_GetNext(RowNumber)  ; 在前一次找到的位置后继续搜索.
		if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
			break
		IfMsgBox Yes
		{
			LV_GetText(RuleName, RowNumber, 1)
			LV_GetText(RuleFunction, RowNumber, 2)
			LV_GetText(RulePath, RowNumber, 7)
			DelRowList:=RowNumber . ":" . DelRowList
			IniDelete, %RunAnyConfig%, RunCtrlRule, %RuleName%|%RuleFunction%
			;删除所有正在使用此规则的关联配置
			Change_Rule_Name(RuleName,"")
			Gosub,RunCtrl_Read
		}
	}
	IfMsgBox Yes
	{
		stringtrimright, DelRowList, DelRowList, 1
		loop, parse, DelRowList, :
			LV_Delete(A_loopfield)
	}
return
LVRuleSave:
	Gui,RuleConfig:Submit, NoHide
	if(vRuleTypeVar){
		vRulePath:=0
	}
	if(!vRuleName || !vRuleFunction || vRulePath=""){
		MsgBox, 48, ,请填入规则名、规则函数和规则路径
		return
	}
	if(InStr(vRuleName,"|")){
		MsgBox, 48, ,规则名不能包含有“|”分割符
		return
	}
	if(RuleName!=vRuleName && rulefileList[vRuleName]){
		MsgBox, 48, ,已存在相同的规则名，请修改
		return
	}
	if(vRuleTypeFunc){
		checkRulePath:=Get_Transform_Val(vRulePath)
		if(!FileExist(checkRulePath) && !FileExist(PluginsPathList[checkRulePath])){
			MsgBox, 48, ,规则路径AHK脚本不存在，请重新添加
			return
		}
	}
	;[写入配置文件]
	Gui,RuleManage:Default
	ruleVar:=vRuleTypeVar ? Get_Transform_Val("%" vRuleFunction "%") : "重启生效"
	ruleStatus:=!vRuleTypeVar ? "重启生效" : ruleVar!="" ? "正常" : "错误变量"
	if(menuRuleItem="规则编辑"){
		if(RuleName!=vRuleName || RuleFunction!=vRuleFunction){
			IniDelete, %RunAnyConfig%, RunCtrlRule, %RuleName%|%RuleFunction%
			;~ 变更所有正在使用此规则的启动项中关联规则名称
			if(RuleName!=vRuleName)
				Change_Rule_Name(RuleName,vRuleName)
		}
		LV_Modify(RowNumber,"",vRuleName,vRuleFunction,ruleStatus,vRuleTypeVar ? "变量" : "插件",ruleparamList[vRuleName] ? "传参" : "",ruleVar,vRulePath)
	}else{
		LV_Add("",vRuleName,vRuleFunction,ruleStatus,vRuleTypeVar ? "变量" : "插件",ruleparamList[vRuleName] ? "传参" : "",ruleVar,vRulePath)
	}
	IniWrite, %vRulePath%, %RunAnyConfig%, RunCtrlRule, %vRuleName%|%vRuleFunction%
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	GuiControl, RuleManage:+Redraw, RuleLV
	Gosub,RunCtrl_Read
	Gui,RuleConfig:Destroy
return
listrule:
	if A_GuiEvent = DoubleClick
	{
		Gosub,LVRuleEdit
	}
return
SetRulePath:
	FileSelectFile, rulePath, 3, , 请选择要使用的的AutoHotkey规则脚本, (*.ahk)
	if(rulePath){
		Gui,RuleConfig:Submit, NoHide
		Get_Rule_Func_Name(rulePath,vRuleFunction)
		rulePath:=StrReplace(rulePath,A_ScriptDir "\" PluginsDir "\")
		rulePath:=StrReplace(rulePath,A_ScriptDir "\")
		GuiControl, RuleConfig:, vRulePath, %rulePath%
	}
return
RuleTypeChange:
	Gui,RuleConfig:Submit, NoHide
	if(vRuleTypeVar){
		GuiControlShow("RuleConfig","vVarDocs")
		GuiControlHide("RuleConfig","vRuleDLL","vSetRulePath","vRulePath")
	}else{
		GuiControlShow("RuleConfig","vRuleDLL","vSetRulePath","vRulePath")
		GuiControlHide("RuleConfig","vVarDocs")
		if(vRulePath="0"){
			GuiControl, RuleConfig:, vRulePath, RunCtrl_Common.ahk
			Gosub,RulePathChange
		}
	}
return
RulePathChange:
	Gui,RuleConfig:Submit, NoHide
	Get_Rule_Func_Name(vRulePath,vRuleFunction)
return
DropDownRuleList:
	Gui,RuleConfig:Submit, NoHide
	GuiControl, RuleConfig:, vRuleFunction, %vRuleDLL%
return
;[自动根据规则脚本的路径来变更函数下拉选择框和空规则函数]
Get_Rule_Func_Name(rulePath,vRuleFunction){
	if(rulePath){
		funcnameStr:=KnowAhkFuncZz(rulePath)
		GuiControl, RuleConfig:, vRuleDLL, |
		GuiControl, RuleConfig:, vRuleDLL, %funcnameStr%
		GuiControl, RuleConfig:Choose, vRuleDLL, 1
		if(!vRuleFunction && funcnameStr){
			Gosub,DropDownRuleList
		}
	}
}
;[变更所有正在使用此规则的启动项中关联规则名称]
Change_Rule_Name(rname,rnew){
	if(rname=rnew)
		Return
	for n,obj in RunCtrlList
	{
		runCtrlName:=obj.name
		for i,r in obj.ruleList
		{
			if(r.name=rname && runCtrlName!=""){
				IniDelete,%RunAnyConfig%,%runCtrlName%_Rule,% r.name "|" r.logic
				IniWrite,% r.value, %RunAnyConfig%, %runCtrlName%_Rule,% rnew "|" r.logic
			}
		}
	}
}
/*
【自动识别AHK脚本中的函数 by hui-Zz】
ahkPath AHK脚本路径
return AHK脚本所有函数用|分隔的字符串,没有返回""
*/
KnowAhkFuncZz(ahkPath){
	ahkPath:=Get_Transform_Val(ahkPath)
	if(FileExist(PluginsPathList[ahkPath])){
		ahkPath:=PluginsPathList[ahkPath]
	}
	funcName:=funcnameStr:=""
	StringReplace, checkPath, ahkPath,`%A_ScriptDir`%, %A_ScriptDir%
	if(FileExist(checkPath)){
		funcIndex:=0
		getFuncNameReg:="iS)^\t*\s*(?!if)([^\s\.,:=\(]*)\(.*?\)\t*\s*"
		getFuncNameReg1:=getFuncNameReg . "\{"
		getFuncNameReg2:=getFuncNameReg . "$"
		Loop, read, %checkPath%
		{
			if(RegExMatch(A_LoopReadLine,getFuncNameReg1)){
				funcnameStr.=RegExReplace(A_LoopReadLine,getFuncNameReg1,"$1") . "|"
			}
			if(funcName && A_Index=funcIndex && RegExMatch(A_LoopReadLine,"^\t*\s*\{\t*\s*$")){
				funcnameStr.=funcName . "|"
			}
			if(RegExMatch(A_LoopReadLine,getFuncNameReg2)){
				funcName:=RegExReplace(A_LoopReadLine,getFuncNameReg2,"$1")
				funcIndex:=A_Index+1
			}
		}
		stringtrimright, funcnameStr, funcnameStr, 1
	}
	return funcnameStr
}
;■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
