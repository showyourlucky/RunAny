;══════════════════════════════════════════════════════════════════
;~;【——🔗规则启动——】
;══════════════════════════════════════════════════════════════════
;~;[规则启动项Read]
RunCtrl_Read:
	;规则名-脚本路径；规则名-脚本插件名；规则名-函数名；规则名-状态；规则名-类型；规则名-是否传参
	global rulefileList:=Object(),ruleitemList:=Object(),rulefuncList:=Object(),rulestatusList:=Object(),ruletypelist:=Object(),ruleparamList:=Object()
	global RuleNameStr:=""
	global RunCtrlLastTimeIni:=A_AppData "\" RunAnyZz "\RunCtrlLastTime.ini"
	ruleitemVar:=rulefuncVar:=""
	IniRead,ruleitemVar,%RunAnyConfig%,RunCtrlRule
	Loop, parse, ruleitemVar, `n, `r
	{
		varList:=StrSplit(A_LoopField,"=",,2)
		itemList:=StrSplit(varList[1],"|",,2)
		if(varList[1]="" || varList[2]="" || itemList[1]="" || itemList[2]="")
			continue
		RuleNameStr.=itemList[1] "|"
		rulefuncList[(rulefuncList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=itemList[2]
		rulefileList[(rulefileList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=varList[2]
		SplitPath,% varList[2],fileName,,,nameNotExt
		ruleitemList[itemList[1]]:=nameNotExt
		;判断规则状态
		if(varList[2]=RunAnyZz ".ahk"){
			rulestatusList[(rulestatusList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=IsFunc(itemList[2])
		}else if(varList[2]="0"){
			ruletypelist[(ruletypelist[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=true
			if(Get_Transform_Val("%" itemList[2] "%")!=itemList[2]){
				rulestatusList[(rulestatusList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=true
			}
		}else{
			rulestatusList[(rulestatusList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=InStr(PluginsContentList[(varList[2])],itemList[2] "(") ? 1 : 0
		}
		;判断规则是否需要传参
		if(varList[2]=RunAnyZz ".ahk"){
			ruleparamList[(ruleparamList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=IsFunc(itemList[2]) > 1
		}else if(varList[2]!="0" && !InStr(PluginsContentList[(varList[2])],itemList[2] "()")){
			ruleparamList[(ruleparamList[itemList[1]]!="" ? itemList[1] "(重名)" : itemList[1])]:=true
		}
	}
	RuleNameStr:=SubStr(RuleNameStr, 1, -StrLen("|"))
	if(ruleparamList.HasKey("联网状态")){
		ruleparamList["联网状态"]:=1
	}
	;---规则启动项---
	global RunCtrlList:=Object(),RunCtrlListBoxList:=Object(),RunCtrlListContentList:=Object()
	global RunCtrlLogicEnum:={"eq":"相等","ne":"不相等","ge":"大于等于","le":"小于等于","gt":"大于","lt":"小于","regex":"正则表达式"}
	global RunCtrlRunWayList:=["启动","置顶启动","最小化启动","最大化启动","隐藏启动","结束软件进程_启动"]
	global RunCtrlListBoxVar:=""
	IniRead,runCtrlListVar,%RunAnyConfig%,RunCtrlList
	Loop, parse, runCtrlListVar, `n, `r
	{
		R_LoopField=%A_LoopField%
		if(R_LoopField="")
			continue
		varList:=StrSplit(R_LoopField,"=",,2)
		if(varList[1]="")
			continue
		runCtrlName:=varList[1]
		RunCtrlListBoxVar.=runCtrlName "|"
		RunCtrlListBoxList.Push(runCtrlName)
		RunCtrlListContentList[runCtrlName]:=varList[2]
		itemList:=StrSplit(varList[2],"|",,6)
		RunCtrlObj:=new RunCtrl(runCtrlName,itemList[1],itemList[2],itemList[3],itemList[4],itemList[5],itemList[6])
		RunCtrlList[runCtrlName]:=RunCtrlObj
		try{
			if(itemList[1] && itemList[5]!=""){
				funcEffect:=Func("RunCtrl_RunRules").Bind(RunCtrlObj,true)
				Hotkey,% itemList[5],% funcEffect,On
			}
		} catch {
			MsgBox,16,规则组%runCtrlName%：热键配置不正确,% "热键错误：`n" itemList[5] "`n请设置正确热键后重启RunAny"
		}
	}
	RunCtrlListBoxVar:=SubStr(RunCtrlListBoxVar, 1, -StrLen("|"))
return

class RunCtrl
{
	name:=""                ;运行组名
	enable:=false           ;运行组启用状态
	noPath:=true            ;无全路径应用
	noMenu:=true            ;无菜单项应用
	key:=""                 ;规则组全局热键
	ruleLogic:=true         ;规则组逻辑：与、或
	ruleMostRun:=""         ;规则循环最大次数(0=无限)
	ruleIntervalTime:=0     ;循环间隔时间(秒)
	ruleStopOnSuccess:=false ;条件成立后停止循环
	runNums:=""             ;运行次数
	runList:=Object()       ;应用运行队列
	ruleFile:=Object()      ;规则文件
	ruleList:=Object()      ;规则队列
	__New(name,enable,ruleLogic,ruleMostRun,ruleIntervalTime,key,ruleStopOnSuccess){
		this.name:=name
		this.enable:=enable
		this.ruleLogic:=ruleLogic
		this.ruleMostRun:=ruleMostRun
		this.ruleIntervalTime:=ruleIntervalTime
		this.key:=key
		this.ruleStopOnSuccess:=ruleStopOnSuccess
		IniRead,ctrlAppsVar,%RunAnyConfig%,%name%_Run
		Loop, parse, ctrlAppsVar, `n, `r
		{
			varList:=StrSplit(A_LoopField,"=",,2)
			if(varList[1]="")
				continue
			runObj:=new RunCtrlRun
			runObj.path:=varList[2]

			itemList:=StrSplit(varList[1],"|",,4)
			noPathStr:=itemList[1]
			runObj.repeatRun:=itemList[2]!="" ? itemList[2] : 0
			runObj.adminRun:=itemList[3]!="" ? itemList[3] : 0
			runObj.runWay:=itemList[4]!="" ? itemList[4] : 1
			if(noPathStr="path"){
				this.noPath:=false
				runObj.noPath:=false
			}else if(noPathStr="menu"){
				this.noMenu:=false
			}
			IniRead, lastRunTime, %RunCtrlLastTimeIni%, last_run_time,% runObj.path, %A_Space%
			runObj.lastRunTime:=lastRunTime
			this.runList.push(runObj)
		}
		IniRead,ruleAppsVar,%RunAnyConfig%,%name%_Rule
		Loop, parse, ruleAppsVar, `n, `r
		{
			varList:=StrSplit(A_LoopField,"=",,2)
			itemList:=StrSplit(varList[1],"|",,3)
			if(varList[1]="" || itemList[1]="")
				continue
			runRuleObj:=new RunCtrlRunRule
			runRuleObj.value:=varList[2]
			runRuleObj.name:=itemList[1]
			runRuleObj.logic:=itemList[2]
			runRuleObj.ruleBreak:=itemList[3]
			runRuleObj.file:=ruleitemList[itemList[1]]
			this.ruleList.push(runRuleObj)
			if(rulestatusList[runRuleObj.name]){
				this.ruleFile[ruleitemList[runRuleObj.name]]:=true
			}
		}
	}
}
class RunCtrlRun
{
	num:=0
	path:=""
	noPath:=true        ;无路径标记
	repeatRun:=false    ;重复运行
	adminRun:=false     ;管理员运行
	runWay:=1           ;运行方式
	lastRunTime:=""     ;最后运行时间
}
class RunCtrlRunRule
{
	file:="",name:="",value:="",ruleBreak:=""
	logic:=1
}

;~;[规则生效]
Rule_Effect:
	global runIndex:=Object(), RuleRunFailList:=Object(), RuleRunNoPathList:=Object()
	try{
		for n,obj in RunCtrlList
		{
			runCtrlObj:=RunCtrlList[n]
			if(!runCtrlObj.enable){
				continue
			}
			rcName:=runCtrlObj.name
		;规则循环
		if(runCtrlObj.ruleMostRun!=""){
			runIndex[rcName]:=0	;规则定时器初始计数为0
			funcEffect%rcName%:=Func("RunCtrl_RunRules").Bind(runCtrlObj)	;规则定时器
			ruleTime:=runCtrlObj.ruleIntervalTime>0 ? runCtrlObj.ruleIntervalTime * 1000 : 1000		;规则定时器间隔时间(秒)
			SetTimer,% funcEffect%rcName%, %ruleTime%
		}else{
			RunCtrl_RunRules(runCtrlObj)
		}
		}
		if(RuleRunFailList.Count() > 0){
			RuleRunFailStr:=StrListJoin("`n",RuleRunFailList)
			TrayTip,规则插件脚本没有启动：,%RuleRunFailStr%,5,2
		}
		RunCtrlRunFlag:=false
	} catch e {
		MsgBox,16,规则判断出错,% "规则名：" rcName
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	}
return
;~;[规则启动]
RunCtrl_RunRules(runCtrlObj,show:=0){
	try {
		rcName:=runCtrlObj.name
		effectResult:=RunCtrl_RuleEffect(runCtrlObj)
		if(effectResult){
			for i,runv in runCtrlObj.runList
			{
				if(!runCtrlObj.noPath || !runCtrlObj.noMenu){
					RunCtrl_RunApps(runv.path, runv.noPath, runv.repeatRun, runv.adminRun, runv.runWay)
				}
			}
			;条件成立后停止循环
			if(runCtrlObj.ruleStopOnSuccess){
				try SetTimer,% funcEffect%rcName%, Off
			}
		}else if(show){
			ToolTip, ❎ 规则验证失败
			SetTimer,RemoveToolTip,3000
			if(RuleRunFailList.Count() > 0){
				RuleRunFailStr:=StrListJoin("`n",RuleRunFailList)
				TrayTip,规则插件脚本没有启动：,%RuleRunFailStr%,5,2
			}
		}
		return effectResult
	} catch e {
		MsgBox,16,启动规则出错,% "启动规则名：" rcName "`n启动规则脚本：" StrListJoin(",",runCtrlObj.ruleFile)
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	} finally {
		runIndex[rcName]++	;规则定时器运行计数+1
		;规则运行计数达到最大循环次数(0=无限不按次数停) => 结束定时器
		if(runCtrlObj.ruleMostRun>0 && runIndex[rcName] >= runCtrlObj.ruleMostRun){
			try SetTimer,% funcEffect%rcName%, Off
		}
	}
}
;~;[规则应用启动]
RunCtrl_RunApps(path,noPath,repeatRun:=0,adminRun:=0,runWay:=1){
	try {
		global RunCtrlRunFlag:=true
		global RunCtrlAdminRunVal:=adminRun
		global RunCtrlRunWayVal:=runWay
		if(noPath){
			tfPath:=Get_Obj_Transform_Name(Trim(path," `t`r`n"))
			if(!repeatRun && runWay!=6 && rule_check_is_run(MenuObj[tfPath])){
				return
			}
			if(NoPathFlag || EvNo){
				OutsideMenuItem:=tfPath
				global NoRecentFlag:=true
				Gosub, Menu_Run
				RunCtrl_LastRunTime(path)
			}else{
				RuleRunNoPathList[tfPath]:=true
				RuleRunAdminRunList[tfPath]:=adminRun
				RuleRunRunWayList[tfPath]:=runWay
				;定时等待无路径程序可运行后再运行
				SetTimer,RunCtrl_RunMenu,100
			}
		}else{
			global any:=Get_Transform_Val(path)
			SplitPath,% any, name, dir
			if(!repeatRun && runWay!=6 && rule_check_is_run(any)){
				return
			}else if(runWay=6){
				Run,% ComSpec " /C taskkill /f /im """ name """", , Hide
				return
			}
			if(dir && FileExist(dir))
				SetWorkingDir,%dir%
			global anyRun:=""
			global way:=""
			Gosub, MenuRunWay
			Gosub, MenuRunAny
			RunCtrlRunFlag:=false
			RunCtrl_LastRunTime(path)
		}
	} catch e {
		MsgBox,16,规则启动应用出错,% "启动应用：" path
			. "`n出错脚本：" e.File "`n出错命令：" e.What "`n错误代码行：" e.Line "`n错误信息：" e.extra "`n" e.message
	} finally {
		SetWorkingDir,%A_ScriptDir%
	}
}
RunCtrl_RunMenu:
	if(NoPathFlag || EvNo){
		SetTimer,RunCtrl_RunMenu,Off
		For path, isRun in RuleRunNoPathList
		{
			if(isRun){
				RuleRunNoPathList[path]:=false
				global RunCtrlRunFlag:=true
				global RunCtrlAdminRunVal:=RuleRunAdminRunList[path]
				global RunCtrlRunWayVal:=RuleRunRunWayList[path]
				global NoRecentFlag:=true
				OutsideMenuItem:=path
				Gosub,Menu_Run
				RunCtrl_LastRunTime(path)
			}
		}
	}
return
RunCtrl_LastRunTime(path){
	IniWrite, %A_Now%, %RunCtrlLastTimeIni%, last_run_time, %path%
}
;~;[规则判断是否成立]
RunCtrl_RuleEffect(runCtrlObj){
	effectFlag:=false
	ruleRunCount:=0
	rcName:=runCtrlObj.name
	for ruleFile,ruleStatus in runCtrlObj.ruleFile
	{
		if(ruleStatus && ruleFile!="0" && ruleFile!="RunAny"){
			if(rule_check_is_run(PluginsPathList[ruleFile ".ahk"])){
				PluginsObjRegActive[ruleFile]:=ComObjActive(PluginsObjRegGUID[ruleFile])
			}else{
				RuleRunFailList[ruleFile]:=""
			}
		}
	}
	for i,rulev in runCtrlObj.ruleList
	{
		ruleRunCount++
		if(!rulefuncList[rulev.name])
			continue
		;获取变量规则、插件规则函数的执行结果
		effectResult:=RunCtrl_RuleResult(rulev.name, rulev.file, rulev.value)
		;根据运算符计算规则最终是否成立
		if(ruleparamList[rulev.name]){
			;如果规则设定条件为（假、不相等），而脚本执行结果是真，则判定为假；执行结果是假，则判定为真
			if(rulev.logic=0 || rulev.logic="ne"){
				effectFlag:=!effectResult
			}else{
				effectFlag:=effectResult
			}
		}else{
			;根据不同的运算符判断结果为真或假
			if(rulev.value=""){
				if(rulev.logic=0 || rulev.logic="ne"){
					effectFlag:=!effectResult
				}else{
					effectFlag:=effectResult
				}
			}else if(rulev.logic=1 || rulev.logic="eq"){
				effectFlag:=effectResult = rulev.value
			}else if(rulev.logic=0 || rulev.logic="ne"){
				effectFlag:=effectResult != rulev.value
			}else if(rulev.logic="gt"){
				effectFlag:=effectResult > rulev.value
			}else if(rulev.logic="ge"){
				effectFlag:=effectResult >= rulev.value
			}else if(rulev.logic="lt"){
				effectFlag:=effectResult < rulev.value
			}else if(rulev.logic="le"){
				effectFlag:=effectResult <= rulev.value
			}else if(rulev.logic="regex"){
				effectFlag:=RegExMatch(effectResult, rulev.value)
			}else{
				effectFlag:=effectResult
			}
		}
		;有中断标记的规则不满足时，则直接中断后续判断并停止规则循环
		if(rulev.ruleBreak){
			if(!effectFlag){
				try SetTimer,% funcEffect%rcName%, Off
				break
			}else{
				continue
			}
		}
		;该启动项所有规则必须全部为真时，如有一假就退出循环
		;该启动项只需要有一项规则为真时，如有一真就退出循环
		if(runCtrlObj.ruleLogic){
			if(!effectFlag)
				break
		}else if(effectFlag){
			break
		}
	}
	return ruleRunCount>0 ? effectFlag : true
}
;~;[规则结果返回]
RunCtrl_RuleResult(ruleName,ruleFile,ruleValue:=""){
	effectResult=
	if(ruleparamList[ruleName]){
		;传参模式仅判断真假，不做运算符计算
		if(ruleFile=RunAnyZz && IsFunc(rulefuncList[ruleName])){
			effectResult:=Func(rulefuncList[ruleName]).Call(ruleValue)
		}else{
			appParms:=StrSplit(ruleValue,"``n")
			effectResult:=PluginsObjRegRun(ruleFile, rulefuncList[ruleName], appParms)
		}
	}else{
		if(ruletypelist[ruleName]){
			effectResult:=Get_Transform_Val("%" rulefuncList[ruleName] "%")
		}else if(ruleFile=RunAnyZz && IsFunc(rulefuncList[ruleName])){
			effectResult:=Func(rulefuncList[ruleName]).Call()
		}else{
			effectResult:=PluginsObjRegActive[(ruleitemList[ruleName])][(rulefuncList[ruleName])]()
		}
	}
	return effectResult
}
