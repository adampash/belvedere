MANAGE:
	Gui, 1: Destroy
	Gui, Add, Tab2, w700 h425 vTabs , Folders|Preferences
	Gui, 1: Menu, MenuBar
	
	;Items found of First Tab
	Gui, Tab, 1
	Gui, 1: Add, ListView, NoSortHdr x62 y52 w175 h310 vFolders gListRules,Folders|Path
	ListFolders := SubStr(Folders, 1, -1)
	if (ListFolders != "ERROR")
	{
		Loop, Parse, ListFolders, |
		{
			SplitPath, A_LoopField, FileName
			LV_Add(0, FileName, A_LoopField)
		}
		LV_ModifyCol(1, 171)
		LV_ModifyCol(2, 0)
	}

	Gui, 1: Add, ListView, NoSortHdr x252 y52 w410 h310 vRules gSetActive, Enabled|Rules
	Gui, 1: Add, Button, x62 y382 w30 h30 gAddFolder, +
	Gui, 1: Add, Button, x92 y382 w30 h30 gRemoveFolder, -
	Gui, 1: Add, Button, x252 y382 w30 h30 gAddRule, +
	Gui, 1: Add, Button, x282 y382 w30 h30 gRemoveRule, -
	Gui, 1: Add, Button, x312 y382 h30 vEditRule gEditRule, Edit Rule
	Gui, 1: Add, Button, x620 y382 h30 vEnableButton gEnableButton, Enable
	; Generated using SmartGUI Creator 4.0
	
	;Items found on Second Tab
	IniRead, Sleep, rules.ini, Preferences, Sleeptime
	Gui, Tab, 2
	Gui, 1: Add, Text, x62 y62 w60 h20 , Sleeptime:
	Gui, 1: Add, Edit, x120 y60 w100 h20 Number vSleep, %Sleep%
	Gui, 1: Add, Text, x225 y62, (Time in milliseconds)
	Gui, 1: Add, Button, x62 y382 h30 vSavePrefs gSavePrefs, Save Preferences
	
	Gui, 1: Show, h443 w724, %APPNAME% Rules
Return

GuiClose:
	Gui, 1: Destroy
	Gui, 2: Destroy
return

ListRules:
	ActiveRule=
	Gui, 1:Default
	Gui, 1: ListView, Rules
	LV_Delete()
	if (A_EventInfo != 0)
	{
		;msgbox, %a_eventinfo%
		Gui, 1: ListView, Folders
		LV_GetText(ActiveFolder, A_EventInfo, 2)
		CurrentlySelected = %A_eventinfo%
	}
	;msgbox, % text
	;msgbox, %activefolder%
	IniRead, RuleNames, rules.ini, %ActiveFolder%, RuleNames
	;msgbox, %rulenames%
	if (RuleNames = "ERROR")
	{
		RuleNames =
	}

	Gui, 1: ListView, Rules
	LV_Delete()
	ListRules := SubStr(RuleNames, 1, -1)
	;msgbox, %listrules%
	Loop, Parse, ListRules, |
	{
		IniRead, Enabled, rules.ini, %A_LoopField%, Enabled

		if (Enabled = 1)
			LV_Add(0,"Yes", A_LoopField)
		else
			LV_Add(0,"No", A_LoopField)
	}
return

SetActive:
	Gui, ListView, Rules

	;Blank out ActiveRule if we get the column headings
	if (A_EventInfo = 0)
	{
		ActiveRule =
	}
	else 
	{
		LV_GetText(ActiveRule, A_EventInfo, 2)
	}
	
	;Change the button based on the selected rule's enable status
	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled
	If (Enabled = 1)
	{
		GuiControl, 1:, EnableButton, Disable
	}
	else
	{
		GuiControl, 1:, EnableButton, Enable
	}
return

EnableButton:
	; make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox, Please select a rule to enable/disable.
		return
	}

	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled
	If (Enabled = 1)
	{
		IniWrite, 0, rules.ini, %ActiveRule%, Enabled
	}
	else
	{
		IniWrite, 1, rules.ini, %ActiveRule%, Enabled
	}
	Gosub, ListRules
return

AddFolder:
	FileSelectFolder, NewFolder,
	if (NewFolder = "")
	{
		return
	}
	Folders = %Folders%%NewFolder%|
	IniWrite, %Folders%, rules.ini, Folders, Folders
	Gui, ListView, Folders
	LV_Delete()
	Loop, Parse, Folders, |
	{
		SplitPath, A_LoopField, FileName
		LV_Add(0, FileName, A_LoopField)
	}
	Gosub, RefreshVars
return

RemoveFolder:
	if (CurrentlySelected = "")
	{
		Msgbox, Select the folder you'd like to delete.
		return
	}
	MsgBox, 4, Delete Folder, Are you sure you would like to delete the folder "%ActiveFolder%" ?
	IfMsgBox No
		return
	Gui, 1: Default
	Gui, ListView, Folders
	LV_GetText(RemoveFolder, CurrentlySelected, 2)
	LV_GetText(RemoveFolderName, CurrentlySelected, 3)
	success := LV_Delete()
	StringReplace, Folders, Folders, %RemoveFolder%|,,
	IniWrite, %Folders%, rules.ini, Folders, Folders
	IniRead, RuleNames, rules.ini, %RemoveFolder%, RuleNames
	Loop, Parse, RuleNames, |
	{
		if (A_LoopField != "")
		{
			StringReplace, AllRuleNames, AllRuleNames, %A_LoopField%|,,
			IniDelete, rules.ini, %A_LoopField%
		}
	}
	IniWrite, %AllRuleNames%, rules.ini, Rules, AllRuleNames
	IniDelete, rules.ini, %RemoveFolder%
	Gosub, RefreshVars

	;msgbox, %success%
	Loop, Parse, Folders, |
	{
		SplitPath, A_LoopField, FileName
		LV_Add(0, FileName, A_LoopField)
	}
	Gosub, ListRules
return

AddRule:
	Skip=
	Edit := 0 ; this is a new rule, not a rule being edited
	LineNum=
	NumOfRules := 1
	if (CurrentlySelected = "")
	{
		MsgBox, You must select a folder to create a rule
		return
	}
	Gui, ListView, Folders
	LV_GetText(RemoveFolderName, CurrentlySelected, 3)
	LV_GetText(FolderName, CurrentlySelected, 3)
	Gui, 2: Destroy
	Gui, 2: +owner1
	Gui, 2: +toolwindow
	Gui, 2: Add, Text, x52 y32 h20 , Folder: %ActiveFolder%
	Gui, 2: Add, Text, x32 y62 w60 h20 , Description:
	Gui, 2: Add, Edit, x92 y62 w250 h20 vRuleName , 
	Gui, 2: Add, Checkbox, x448 y30 vEnabled, Enabled
	Gui, 2: Add, Checkbox, x448 y50 vConfirmAction, Confirm Action
	Gui, 2: Add, Checkbox, x448 y70 vRecursive, Recursive
	Gui, 2: Add, Groupbox, x443 y10 w110 h80, Rule Options
	Gui, 2: Add, Text, x32 y92 w520 h20 , __________________________________________________________________________________________
	Gui, 2: Add, Text, x32 y122 w10 h20 , If
	Gui, 2: Add, DropDownList, x45 y120 w46 h20 r2 vMatches , ALL||ANY
	Gui, 2: Add, Text, x96 y122 w240 h20 , of the following conditions are met:
	Gui, 2: Add, DropDownList, x32 y152 w160 h20 r6 vGUISubject gSetVerbList , %AllSubjects%
	Gui, 2: Add, DropDownList, x202 y152 w160 h21 r6 vGUIVerb , %NameVerbs%
	Gui, 2: Add, Edit, x372 y152 w140 h20 vGUIObject , 
	Gui, 2: Add, DropDownList, x445 y152 vGUIUnits w60 ,
	GuiControl, 2: Hide, GUIUnits
	Gui, 2: Add, Button, vGUINewLine x515 y152 w20 h20 gNewLine , +
	Gui, 2: Add, Text, x32 y212 w260 h20 vConsequence , Do the following:
	Gui, 2: Add, DropDownList, x32 y242 w160 h20 vGUIAction gSetDestination r6 , %AllActions%
	Gui, 2: Add, Text, x202 y242 h20 w45 vActionTo , to folder:
	Gui, 2: Add, Edit, x248 y242 w190 h20 vGUIDestination , 
	Gui, 2: Add, Button, x450 y242 gChooseFolder vGUIChooseFolder h20, ...
	Gui, 2: Add, Checkbox, x482 y242 vOverwrite, Overwrite?
	Gui, 2: Add, Button, x32 y302 w100 h30 vTestButton gTESTMatches, Test
	Gui, 2: Add, Button, x372 y302 w100 h30 vOKButton gSaveRule, OK
	Gui, 2: Add, Button, x482 y302 w100 h30 vCancelButton gGui2Close, Cancel
	; Generated using SmartGUI Creator 4.0
	Gui, 2: Show, h348 w598, Create a rule...
	Gosub, RefreshVars
	Gosub, ListRules
Return

EditRule:
	Skip = 
	Edit := 1
	
	;make sure a rule is selected
	if (ActiveRule = "")
	{
		MsgBox, Please select a rule to edit.
		return
	}
	OldName = %ActiveRule%
	
	;find out how many conditions a rule has
	NumOfRules := 1
	Loop 
	{
		IniRead, MultiRule, rules.ini, %ActiveRule%, Subject%A_Index%
		if (MultiRule != "ERROR")
		{
			NumOfRules++ 
		}
		else
		{
			break
		}
	}
	;msgbox, %numofrules%
	
	;TK Start HERE to complete the editing rule features	
	;msgbox, %thisRule% has %Numofrules% rules
	IniRead, Folder, rules.ini, %ActiveRule%, Folder
	IniRead, Action, rules.ini, %ActiveRule%, Action
	IniRead, Destination, rules.ini, %ActiveRule%, Destination, 0
	IniRead, Overwrite, rules.ini, %ActiveRule%, Overwrite
	IniRead, Matches, rules.ini, %ActiveRule%, Matches
	IniRead, Enabled, rules.ini, %ActiveRule%, Enabled
	IniRead, ConfirmAction, rules.ini, %ActiveRule%, ConfirmAction
	IniRead, Recursive, rules.ini, %ActiveRule%, Recursive
	Gui, 2: Destroy
	Gui, 2: +owner1
	Gui, 2: +toolwindow
	Gui, 2: Add, Text, x52 y32 h20 , Folder: %ActiveFolder%
	Gui, 2: Add, Text, x32 y62 w60 h20 , Description:
	Gui, 2: Add, Edit, x92 y62 w250 h20 vRuleName , %ActiveRule%
	Gui, 2: Add, Checkbox, x448 y30 Checked%Enabled% vEnabled, Enabled
	Gui, 2: Add, Checkbox, x448 y50 Checked%ConfirmAction% vConfirmAction, Confirm Action
	Gui, 2: Add, Checkbox, x448 y70 Checked%Recursive% vRecursive, Recursive
	Gui, 2: Add, Groupbox, x443 y10 w110 h80, Rule Options
	Gui, 2: Add, Text, x32 y92 w520 h20 , __________________________________________________________________________________________
	Gui, 2: Add, Text, x32 y122 w10 h20 , If
	StringReplace, thisMatchList, MatchList, %Matches%, %Matches%|
	Gui, 2: Add, DropDownList, x45 y120 w46 h20 r2 vMatches , %thisMatchList%
	Gui, 2: Add, Text, x96 y122 w240 h20 , of the following conditions are met:
	
	; this loop creates the controls for all of the conditions in the rule
	height =
	LineNum =
	Loop
	{
		if ((A_Index-1) = NumOfRules)
		{
			break
		}
		if (A_Index = 1)
		{
			RuleNum =
		}
		else
		{
			RuleNum := A_Index - 1
		}
		IniRead, Subject%RuleNum%, rules.ini, %ActiveRule%, Subject%RuleNum%
		IniRead, Verb%RuleNum%, rules.ini, %ActiveRule%, Verb%RuleNum%
		IniRead, Object%RuleNum%, rules.ini, %ActiveRule%, Object%RuleNum%
		IniRead, Units%RuleNum%, rules.ini, %ActiveRule%, Units%RuleNum%
		if (LineNum = "")
		{
			LineNum := 0
			height := 152
		}
		else
		{
			height := (RuleNum * 30) + 152
		}
		; Set each control with the value of each rule
		defaultSubject = % Subject%RuleNum% "|"
		defaultVerb = % Verb%RuleNum% "|"
		;defaultObject = % Object%RuleNum% "|"
		defaultUnit = % Units%RuleNum% "|"
		StringReplace, RuleSubject, NoDefaultSubject, %defaultSubject%, %defaultSubject%|
		
		; verbs need to be set by subject b/c verbs change by subject
		;msgbox, %defaultSubject%
		if (defaultSubject = "Name|") or (defaultSubject = "Extension|")
		{
			NoDefaultVerbs = %NoDefaultNameVerbs%
		}
		else if (defaultSubject = "Size|")
		{
			NoDefaultVerbs = %NoDefaultNumVerbs%
		}
		else if (defaultSubject = "Date last modified|") or (defaultSubject = "Date last opened|") or (defaultSubject = "Date created|")
		{
			NoDefaultVerbs = %NoDefaultDateVerbs%
		}
		StringReplace, RuleVerb, NoDefaultVerbs, %defaultVerb%, %defaultVerb%|

		;msgbox, % subject%rulenum% " translates to " rulesubject
		Gui, 2: Add, DropDownList, x32 y%height% w160 h20 r6 vGUISubject%RuleNum% gSetVerbList , %RuleSubject%
		Gui, 2: Add, DropDownList, x202 y%height% w160 h21 r6 vGUIVerb%RuleNum% , %RuleVerb%
		Gui, 2: Add, Edit, x372 y%height% w140 h20 vGUIObject%RuleNum% , % Object%RuleNum%
		if (defaultSubject = "Size|")
		{
			NoDefaultUnits = %NoDefaultSizeUnits%
			GuiControl, 2: Move , GUIObject%RuleNum% , w70
		}
		else if (defaultSubject = "Date last modified|") or (defaultSubject = "Date last opened|") or (defaultSubject = "Date created|")
		{
			NoDefaultUnits = %NoDefaultDateUnits%
			GuiControl, 2: Move , GUIObject%RuleNum% , w70
		}
		;msgbox, %defaultunit%
		StringReplace, RuleUnits, NoDefaultUnits, %defaultUnit%, %defaultUnit%|
		;msgbox, %ruleunits%
		Gui, 2: Add, DropDownList, x445 y%height% vGUIUnits%RuleNum% w60 , %RuleUnits%
		if (defaultSubject = "Name|") or (defaultSubject = "Extension|")
		{
			GuiControl, 2: Hide, GUIUnits%RuleNum%
		}
		Gui, 2: Add, Button, vGUINewLine%RuleNum% x515 y%height% w20 h20 gNewLine , +
		if (RuleNum != "")
		{
			Gui, 2: Add, Button, vGUIRemLine%RuleNum% x535 y%height% w20 h20 gRemLine , -
		}
		LineNum++
	}	
	ActionHeight :=
	Gui, 2: Add, Text, x32 y212 w260 h20 vConsequence , Do the following:
	StringReplace, RuleAction, AllActionsNoDefault, %Action%, %Action%|
	;msgbox, %RuleAction%
	Gui, 2: Add, DropDownList, x32 y242 w160 h20 vGUIAction gSetDestination r6 , %RuleAction%
	Gui, 2: Add, Text, x202 y242 h20 w45 vActionTo , to folder:
	Gui, 2: Add, Edit, x248 y242 w190 h20 vGUIDestination , %Destination%
	Gui, 2: Add, Button, x450 y242 gChooseFolder vGUIChooseFolder h20, ...
	Gui, 2: Add, Checkbox, x482 y242 vOverwrite Checked%Overwrite%, Overwrite?
	FirstEdit := 1
	GUIAction = %Action%
	Gosub, SetDestination
	Gui, 2: Add, Button, x32 y302 w100 h30 vTestButton gTESTMatches, Test
	Gui, 2: Add, Button, x372 y302 w100 h30 vOKButton gSaveRule, OK
	Gui, 2: Add, Button, x482 y302 w100 h30 vCancelButton gGui2Close, Cancel
	; Generated using SmartGUI Creator 4.0
	GuiControl, 2: Move, Consequence , % "y" (NumOfRules-1) * 30 + 212
	GuiControl, 2: Move, GUIAction, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, ActionTo, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, GUIDestination, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, GUIChooseFolder,% "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, Overwrite, % "y" (NumOfRules-1) * 30 + 242
	GuiControl, 2: Move, TestButton, % "y" (NumOfRules-1) * 30 + 302
	GuiControl, 2: Move, OKButton, % "y" (NumOfRules-1) * 30 + 302
	GuiControl, 2: Move, CancelButton, % "y" (NumOfRules-1) * 30 + 302
	Gui, 2: Show, h348 w598, Create a rule...
	Gui, 2: Show, % "h" (NumOfRules-1) * 30 + 348
	Gosub, RefreshVars
	Gosub, ListRules
return

Gui2Close:
	Gui, 2: Destroy
return

SetVerbList:
	LaunchedBy = %A_GuiControl%
	StringRight, GUILineNum, LaunchedBy, 1
	if (GUILineNum = "t")
	{
		GUILineNum =
	}
	;Msgbox, %GUILineNum%
	GuiControlGet, GUISubject%GUILineNum%, , GUISubject%GUILineNum%
	if (GUISubject%GUILineNum% = "Name") or (GUISubject%GUILineNum% = "Extension")
	{
		GuiControl, 2: ,GUIVerb%GUILineNum%,|%NameVerbs%
		GuiControl, 2: Hide, GUIUnits%GUILineNum%
		GuiControl, 2: Move , GUIObject%GUILineNum% , w140
	}
	else if (GUISubject%GUILineNum% = "Size")
	{
		GuiControl, 2: ,GUIVerb%GUILineNum%,|%NumVerbs%
		GuiControl, 2: Move , GUIObject%GUILineNum% , w70
		;ControlMove, GUIObject,,,70,,
		GuiControl, 2: ,GUIUnits%GUILineNum%,|%SizeUnits%
		GuiControl, 2: Show, GUIUnits%GUILineNum%
	}
	else if (GUISubject%GUILineNum% = "Date last modified") or (GUISubject%GUILineNum% = "Date last opened") or (GUISubject%GUILineNum% = "Date created")
	{
		GuiControl,,GUIVerb%GUILineNum%,|%DateVerbs%
		GuiControl, 2: Move , GUIObject%GUILineNum% , w70
		GuiControl, 2: ,GUIUnits%GUILineNum%,|%DateUnits%
		;GuiControl, 2: +r4, GUIUnits
		GuiControl, 2: Show, GUIUnits%GUILineNum%
	}
return

NewLine:
	;msgbox add a new line?!
	if (LineNum = "")
	{
		LineNum := 1
	}
	height := (LineNum * 30) + 152
	Gui, 2: Add, DropDownList, x32 y%height% w160 h20 r6 vGUISubject%LineNum% gSetVerbList , %AllSubjects%
	Gui, 2: Add, DropDownList, x202 y%height% w160 h21 r6 vGUIVerb%LineNum% , %NameVerbs%
	Gui, 2: Add, Edit, x372 y%height% w140 h20 vGUIObject%LineNum% , 
	Gui, 2: Add, DropDownList, x445 y%height% vGUIUnits%LineNum% w60 ,
	GuiControl, 2: Hide, GUIUnits%LineNum%
	Gui, 2: Add, Button, vGUINewLine%LineNum% x515 y%height% w20 h20 gNewLine , + 
	Gui, 2: Add, Button, vGUIRemLine%LineNum% x535 y%height% w20 h20 gRemLine , - 

	; now extend the size of the window
	GuiControl, 2: Move, Consequence , % "y" LineNum * 30 + 212
	GuiControl, 2: Move, GUIAction, % "y" LineNum * 30 + 242
	GuiControl, 2: Move, ActionTo, % "y" LineNum * 30 + 242
	GuiControl, 2: Move, GUIDestination, % "y" LineNum * 30 + 242
	GuiControl, 2: Move, GUIChooseFolder,% "y" LineNum * 30 + 242
	GuiControl, 2: Move, Overwrite, % "y" LineNum * 30 + 242
	GuiControl, 2: Move, TestButton, % "y" LineNum * 30 + 302
	GuiControl, 2: Move, OKButton, % "y" LineNum * 30 + 302
	GuiControl, 2: Move, CancelButton, % "y" LineNum * 30 + 302
	Gui, 2: Show, % "h" LineNum * 30 + 348

	LineNum++
	NumOfRules++
return

RemLine:
	NumOfRules--
	LaunchedBy = %A_GuiControl%
	StringRight, GUILineNum, LaunchedBy, 1
	if (GUILineNum = "e")
	{
		GUILineNum =
	}
	Skip = %Skip%,%GUILineNum%
	;msgbox, %guilinenum% 
	GuiControl, 2: Hide, GUISubject%GUILineNum%
	GuiControl, 2: Hide, GUIVerb%GUILineNum%
	GuiControl, 2: Hide, GUIObject%GUILineNum%
	GuiControl, 2: Hide, GUIUnits%GUILineNum%
	GuiControl, 2: Hide, GUINewLine%GUILineNum%
	GuiControl, 2: Hide, GUIRemLine%GUILineNum%
	;GuiControl, 2: Hide, GUIUnits%GUILineNum%
	GuiControl, 2:, GUISubject%GUILineNum%, |
return

SetDestination:
	if !FirstEdit
	{
		GuiControlGet, GUIAction, , GUIAction
	}
	FirstEdit := 0
	if (GUIAction = "Move file") or (GUIAction = "Copy file")
	{
		GuiControl, 2: Show, GUIDestination
		GuiControl, 2: Show, GUIChooseFolder
		GuiControl, 2: , ActionTo, to folder:
		GuiControl, 2: Show, ActionTo
		GuiControl, 2: Show, Overwrite
	}
	else if (GUIAction = "Rename file")
	{
		GuiControl, 2: , ActionTo, to:
		GuiControl, 2: Show, ActionTo
		GuiControl, 2: Show, GUIDestination
		GuiControl, 2: Hide, GUIChooseFolder
		GuiControl, 2: Hide, Overwrite
	}
	else if (GUIAction = "Open file") or (GUIAction = "Delete file") or (GUIAction = "Send file to Recycle Bin")
	{
		GuiControl, 2: Hide, ActionTo
		GuiControl, 2: Hide, GUIChooseFolder
		GuiControl, 2: Hide, GUIDestination
		GuiControl, 2: Hide, Overwrite
	}
return

RemoveRule:
	;msgbox, %ActiveRule%
	if (ActiveRule = "")
	{
		MsgBox, Please select a rule to delete.
		return
	}
	MsgBox, 4, Delete Rule, Are you sure you would like to delete the rule "%ActiveRule%" ?
	IfMsgBox No
		return
	StringReplace, RuleNames, RuleNames, %ActiveRule%|,,
	Iniwrite, %RuleNames%, rules.ini, %ActiveFolder%, RuleNames
	StringReplace, AllRuleNames, AllRuleNames, %ActiveRule%|,,
	Iniwrite, %AllRuleNames%, rules.ini, Rules, AllRulenames
	Inidelete, rules.ini, %ActiveRule%
	Gosub, RefreshVars
	Gosub, ListRules
return

SaveRule:
	Gui, 2: Submit, NoHide
	;MsgBox, LineNum: %LineNum%
	if (RuleName = "")
	{
		Msgbox, You need to write a description for your rule.
		return
	}
	else if RuleName contains |
	{
		Msgbox, Your description cannot contain the | (pipe) character
		return
	}
	StringReplace, RuleMatchList, AllRuleNames, |,`,,ALL
	;msgbox, Edit: %Edit%
	if RuleName in %RuleMatchList%
	{
		if !Edit
		{
			Msgbox, A rule with this name already exists. Please rename your rule.
 			return
		}
	}
	if Edit
	{
		IniDelete, rules.ini, %OldName%
		StringReplace, AllRuleNames, AllRuleNames, %OldName%|,,
		StringReplace, RuleNames, RuleNames, %OldName%|,,
		;msgbox, allrulenames: %allrulenames% - rulenames: %rulenames%
	}
	if (LineNum = "")
	{
		LineNum := 1
	}
	Loop
	{
		if (A_Index > LineNum)
		{
			;msgbox, bigger
			break
		}
		else
		{
			CheckLine := A_Index - 1
		}
		if (CheckLine = 0)
		{
			CheckLine=
		}
		if (GUIObject%CheckLine% = "")
		{
			if Checkline in %Skip%
			{
				;msgbox, you want to skip this one because %checkline% is in %skip%
			}
			else
			{
				Msgbox, % "You're missing data in one of your " GUISubject%CheckLine% " rules."
				return
			}
		}
		if (GUIDestination = "")
		{
			if (GUIAction = "Move file") or (GUIAction = "Rename file") or (GUIAction = "Copy file")
			{
				Msgbox, % "You need to enter a destination folder for the " GUIAction " action."
				return
				; %
			}
		}
		else
		{
			IfNotExist, %GUIDestination%
			{
				Msgbox, %GUIDestination% is not a real folder.
				return
			}
		}
	}
	Gui, 2: Destroy
	;MsgBox, %LineNum%
	IniWrite, %RuleNames%%RuleName%|, rules.ini, %ActiveFolder%, RuleNames
	IniWrite, %AllRuleNames%%RuleName%|, rules.ini, Rules, AllRuleNames
	IniWrite, %ActiveFolder%\*, rules.ini, %RuleName%, Folder
	IniWrite, %Enabled%, rules.ini, %RuleName%, Enabled
	IniWrite, %ConfirmAction%, rules.ini, %RuleName%, ConfirmAction
	IniWrite, %Recursive%, rules.ini, %RuleName%, Recursive
	IniWrite, %Matches%, rules.ini, %RuleName%, Matches
	IniWrite, %GUIAction%, rules.ini, %RuleName%, Action
	IniWrite, %GUIDestination%, rules.ini, %RuleName%, Destination
	IniWrite, %Overwrite%, rules.ini, %RuleName%, Overwrite
	Loop
	{
		if (A_Index = 1)
		{
			thisLine =
		}
		else
		{
			thisLine := A_Index - 1
		}
		;msgbox, %thisline%
		if (A_Index > LineNum)
		{
			;msgbox, break
			break
		}
		;msgbox, % guisubject%thisline%
		if (GUISubject%thisLine% != "")
		{
			if (thisLine = "")
			{
				RuleNum =
				;msgbox, RuleNum = %rulenum%
			}
			else if (RuleNum = "")
			{
				RuleNum := 1
				;msgbox, RuleNum = %rulenum%
			}
			else
			{
				RuleNum++
				;msgbox, RuleNum = %rulenum%
			}
			IniWrite, % GUISubject%thisLine%, rules.ini, %RuleName%, Subject%RuleNum%
			IniWrite, % GUIVerb%thisLine%, rules.ini, %RuleName%, Verb%RuleNum%
			IniWrite, % GUIObject%thisLine%, rules.ini, %RuleName%, Object%RuleNum%
			IniWrite, % GUIUnits%thisLine%, rules.ini, %RuleName%, Units%RuleNum%
		}
	}
	Gosub, RefreshVars
	Gosub, ListRules
return

TESTMatches:
	matchFiles =
	Gui, 2: Submit, NoHide
	if (RuleName = "")
	{
		Msgbox, You need to write a description for your rule.
		return
	}
	else if RuleName contains |
	{
		Msgbox, Your description cannot contain the | (pipe) character
		return
	}
	if (LineNum = "")
	{
		LineNum := 1
	}
	
	; set variables to the active folder and match type (ALL OR ANY) 
	; for testing below
	Folder = %ActiveFolder%\*
	Matches = %Matches%
	
	Loop
	{
		if (A_Index > LineNum)
		{
			;msgbox, bigger
			break
		}
		else
		{
			CheckLine := A_Index - 1
		}
		if (CheckLine = 0)
		{
			CheckLine=
		}
		if (GUIObject%CheckLine% = "")
		{
			if Checkline in %Skip%
			{
				;msgbox, you want to skip this one because %checkline% is in %skip%
			}
			else
			{
				Msgbox, % "You're missing data in one of your " GUISubject%CheckLine% " rules."
				return
			}
		}
		if (GUIDestination = "")
		{
			if (GUIAction = "Move file") or (GUIAction = "Rename file") or (GUIAction = "Copy file")
			{
				Msgbox, % "You need to enter a destination folder for the " GUIAction " action."
				return
				; %
			}
		}
		else
		{
			IfNotExist, %GUIDestination%
			{
				Msgbox, %GUIDestination% is not a real folder.
				return
			}
		}
	}
	
	Loop
	{
		if (A_Index = 1)
		{
			thisLine =
		}
		else
		{
			thisLine := A_Index - 1
		}
		;msgbox, %thisline%
		if (A_Index > LineNum)
		{
			;msgbox, break
			break
		}
		;msgbox, % guisubject%thisline%
		if (GUISubject%thisLine% != "")
		{
			if (thisLine = "")
			{
				RuleNum =
				;msgbox, RuleNum = %rulenum%
			}
			else if (RuleNum = "")
			{
				RuleNum := 1
				;msgbox, RuleNum = %rulenum%
			}
			else
			{
				RuleNum++
				;msgbox, RuleNum = %rulenum%
			}
			
			; set the test variables for rules
			Subject%thisLine% = % GUISubject%RuleNum%
			Verb%thisLine% = % GUIVerb%RuleNum%
			Object%thisLine% = % GUIObject%RuleNum%
			Units%thisLine% = % GUIUnits%RuleNum%
			
			;msgbox, % subject%thisLine%
			;msgbox, %folder%
			;msgbox, %matches%
			;msgbox % object%thisLine%
		}
	}
	
	; Now loop through the folder to test for matches
	Loop %Folder%, 0, %Recursive%
	{
		Loop
		{
			if ((A_Index - 1) = NumOfRules)
			{
				break
			}
			if (A_Index = 1)
			{
				RuleNum =
			}
			else
			{
				RuleNum := A_Index - 1
			}
			;msgbox, % subject subject1 subject2
			file = %A_LoopFileLongPath%
			;MsgBox, %file%
			fileName = %A_LoopFileName%
			;msgbox, % subject%rulenum%
			; Below determines the subject of the comparison
			if (Subject%RuleNum% = "Name")
			{
				thisSubject := getName(file)
				;msgbox, name %file%
			}
			else if (Subject%RuleNum% = "Extension")
			{
				thisSubject := getExtension(file)
				;Msgbox, extension: %thissubject%
			}
			else if (Subject%RuleNum% = "Size")
			{
				thisSubject := getSize(file)
				;msgbox, size %thissubject%
			}
			else if (Subject%RuleNum% = "Date last modified")
			{
				thisSubject := getDateLastModified(file)
			}
			else if (Subject%RuleNum% = "Date last opened")
			{
				thisSubject := getDateLastOpened(file)
			}
			else if (Subject%RuleNum% = "Date created")
			{
				thisSubject := getDateCreated(file)
			}
			else
			{
				MsgBox, Subject does not have a match
				;msgbox, % subject %rulenum%
			}
			
			testUnits = % Units%RuleNum%
			; Below determines the comparison verb
			if (Verb%RuleNum% = "contains")
			{
				result%RuleNum% := contains(thisSubject, Object%RuleNum%)
			}
			else if (Verb%RuleNum% = "does not contain")
			{
				result%RuleNum% := !(contains(thisSubject, Object%RuleNum%))
			}
			else if (Verb%RuleNum% = "is")
			{
				result%RuleNum% := isEqual(thisSubject, Object%RuleNum%)
			}
			else if (Verb%RuleNum% = "matches one of")
			{
				result%RuleNum% := isOneOf(thisSubject, Object%RuleNum%)
				;msgbox, % result%rulenum% . "is rule" . rulenum
			}
			else if (Verb%RuleNum% = "does not match one of")
			{
				result%RuleNum% := !(isOneOf(thisSubject, Object%RuleNum%))
				;msgbox, % result%rulenum% . "is rule" . rulenum
			}
			else if (Verb%RuleNum% = "is less than")
			{
				result%RuleNum% := isLessThan(thisSubject, Object%RuleNum%)
				;msgbox, % result%rulenum%
			}
			else if (Verb%RuleNum% = "is greater than")
			{
				result%RuleNum% := isGreaterThan(thisSubject, Object%RuleNum%)
			}
			else if (Verb%RuleNum% = "is not")
			{
				result%RuleNum% := !(isEqual(thisSubject, Object%RuleNum%))
			}
			else if (Verb%RuleNum% = "is in the last")
			{
				result%RuleNum% := isInTheLast(thisSubject, Object%RuleNum%)
			}
			else if (Verb%RuleNum% = "is not in the last")
			{
				result%RuleNum% := !(isInTheLast(thisSubject, Object%RuleNum%))
			}
		}
		; Below evaluates result and takes action
		Loop
		{
			;msgbox, %a_index%
			if (NumOfRules < A_Index)
			{
				;msgbox, over
				break
			}
			if (A_Index = 1)
			{
				RuleNum=
			}
			else
			{
				RuleNum := A_Index - 1
			}
			;msgbox, % result%rulenum% . "is rule " . rulenum
			if (Matches = "ALL")
			{
				if (result%RuleNum% = 0)
				{
					result := 0
					break
				}
				else
				{
					result := 1
					continue
				}
			}
			else if (Matches = "ANY")
			{
				if (result%RuleNum% = 1)
				{
					result := 1
					;msgbox, 1
					break
				}
				else
				{
					result := 0
					continue
				}
			}
		}
		;msgbox, %result%
		;Msgbox, result is %result%
		if result
		{
			;Msgbox, match %fileName%
			matchFiles = %fileName%, %matchFiles%
		}
	}
	
	if (matchFiles != "")
	{
		Msgbox,,%APPNAME% Test Matches, This rule matches the following file(s): `n %matchFiles%
	}
	else
	{
		Msgbox,,%APPNAME% Test Matches, No matches were found
	}
return

ChooseFolder:
	FileSelectFolder, GUIDestination
	GuiControl, 2:, GUIDestination, %GUIDestination%
return

SavePrefs:
	Gui, 1: Submit, NoHide
	SleepTime := Sleep
	IniWrite, %Sleep%, rules.ini, Preferences, Sleeptime
	MsgBox,,Saved Settings, Your settings have been saved.
return

#IfWinActive, Belvedere Rules
~LButton::
	MouseGetPos,,,,ClickedControl
	;msgbox, %ClickedControl%
	if (ClickedControl = "SysListView321") or (ClickedControl = "SysListView322")
	{
		;msgbox, this one
		Sleep, 10
		Click 2
	}
	else
	{
		;Click
	}
return

RefreshVars:
	IniRead, Folders, rules.ini, Folders, Folders
	IniRead, FolderNames, rules.ini, Folders, FolderNames
	IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames
return
