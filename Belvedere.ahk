;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Windows
; Author:         Adam Pash <adam.pash@gmail.com>
;
; Script Function:
;	Automated file manager
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
StringCaseSense, On
SetFormat, float, 0.2
GoSub, SetVars
GoSub, TRAYMENU
GoSub, MENUBAR
Gosub, BuildINI
IniRead, Folders, rules.ini, Folders, Folders
IniRead, FolderNames, rules.ini, Folders, FolderNames
IniRead, AllRuleNames, rules.ini, Rules, AllRuleNames
if (AllRuleNames = "ERROR")
{
	AllRuleNames=
}

;main execution loop
Loop
{
	;msgbox, running
	;Loops through all the rule names for execution
	Loop, Parse, AllRuleNames, |
	{
		thisRule = %A_LoopField%
		;msgbox, %thisrule%
		NumOfRules := 1
		;Loops to determine number of subjects within a rule
		Loop
		{
			IniRead, MultiRule, rules.ini, %thisRule%, Subject%A_Index%
			if (MultiRule != "ERROR")
			{
				NumOfRules++ 
			}
			else
			{
				break
			}
		}
		if (thisRule = "ERROR") or (thisRule = "")
		{
			continue
		}
		;msgbox, %thisRule% has %Numofrules% rules
		IniRead, Folder, rules.ini, %thisRule%, Folder
		IniRead, Enabled, rules.ini, %thisRule%, Enabled
		IniRead, Action, rules.ini, %thisRule%, Action
		IniRead, Destination, rules.ini, %thisRule%, Destination, 0
		IniRead, Matches, rules.ini, %thisRule%, Matches
		
		;If rule is not enabled, just skip over it
		if (Enabled = 0)
		{
			continue
		}
		;MsgBox, %thisRule% is currently running
		;Loop to read the subjects, verbs and objects for the list defined
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
			IniRead, Subject%RuleNum%, rules.ini, %thisRule%, Subject%RuleNum%
			IniRead, Verb%RuleNum%, rules.ini, %thisRule%, Verb%RuleNum%
			IniRead, Object%RuleNum%, rules.ini, %thisRule%, Object%RuleNum%
		}
		;msgbox, %subject%, %subject1%, %subject2%
		if (Destination != "0")
		{
			IniRead, Overwrite, rules.ini, %thisRule%, Overwrite
		}
		IniRead, ConfirmAction, rules.ini, %thisRule%, ConfirmAction, 0
		;Msgbox, %Subject% %Verb% %Object% %Action% %ConfirmAction%

		Loop %Folder%
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
				;Subject1 = Fart
				;msgbox, % subject%rulenum%
				; Below determines the subject of the comparison
				if (Subject%RuleNum% = "Name")
				{
					thisSubject := getName(file)
					;msgbox, %thisSubject%
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
					;msgbox, % result%rulenum% . "is rule" . rulenum
					;if result%RuleNum%
					{
						;msgbox, true for %thissubject% and %object%
					}
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
					result%RuleNum% := !isInTheLast(thisSubject, Object%RuleNum%)
					;msgbox, % result%RuleNum%
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
			;Msgbox, result is %result%
			if result
			{
				if (ConfirmAction = 1)
				{
					MsgBox, 4, Action Confirmation, Are you sure you want to %Action% %fileName% because of rule %thisRule%?
					IfMsgBox No
						break
				}
				if (Action = "Move file") or (Action = "Rename file")
				{
					move(file, Destination, Overwrite)
					if errorCheck
					{
						errorCheck := 0
						break
					}
				}
				else if (Action = "Send file to Recycle Bin")
				{
					recycle(file)
				}
				else if (Action = "Delete file")
				{
					;msgbox, delete it!
					delete(file)
				}
				else if (Action = "Copy file")
				{
					copy(file, Destination, Overwrite)
					if errorCheck
					{
						errorCheck := 0
						break
					}
				}
				else if (Action = "Open file")
				{
					Run, %file%
				}
				else
				{
					Msgbox, You've detemerined no action to take.
				}
			}
			else
			{
				;msgbox, no match
			}	
			StringCaseSense, On
		}
	}
	;msgbox, run
	Sleep, %SleepTime%
}


SetVars:
APPNAME = Belvedere
Version = 0.3
AllSubjects = Name||Extension|Size|Date last modified|Date last opened|Date created|
NoDefaultSubject = Name|Extension|Size|Date last modified|Date last opened|Date created|
NameVerbs = is||is not|matches one of|does not match one of|contains|does not contain|
NoDefaultNameVerbs = is|is not|matches one of|does not match one of|contains|does not contain|
NumVerbs =	is||is not|is greater than|is less than|
NoDefaultNumVerbs = is|is not|is greater than|is less than|
DateVerbs = is in the last||is not in the last| ; removed is||is not| for now... needs more work implementing
NoDefaultDateVerbs = is in the last|is not in the last|
AllActions = Move file||Rename file|Send file to Recycle Bin|Delete file|Copy file|Open file|
AllActionsNoDefault = Move file|Rename file|Send file to Recycle Bin|Delete file|Copy file|Open file|
SizeUnits = MB||KB
NoDefaultSizeUnits = MB|KB|
DateUnits = minutes||hours|days|weeks
NoDefaultDateUnits = minutes|hours|days|weeks|
MatchList = ALL|ANY|
SleepTime := 300000
IfNotExist,resources
{
	FileCreateDir,resources
}
FileInstall, resources\belvedere.ico, resources\belvedere.ico
FileInstall, resources\belvederename.png, resources\belvederename.png
FileInstall, resources\both.png, resources\both.png
Menu, TRAY, Icon, resources\belvedere.ico
BelvederePNG = resources\both.png
return

BuildINI:
	IfNotExist, rules.ini
	{
		IniWrite,%A_Space%,rules.ini, Folders, Folders
		IniWrite,%A_Space%,rules.ini, Rules, AllRuleNames
	}
return

TRAYMENU:
Menu,TRAY,NoStandard 
Menu,TRAY,DeleteAll 
Menu, TRAY, Add, &Manage, MANAGE
Menu, TRAY, Default, &Manage
;Menu,TRAY,Add,&Preferences,PREFS
;Menu,TRAY,Add,&Help,HELP
Menu,TRAY,Add
Menu,TRAY,Add,&About...,ABOUT
Menu,TRAY,Add,E&xit,EXIT
Menu,Tray,Tip,%APPNAME% %Version%
;Menu,TRAY,Icon,resources\tk.ico
Return

MENUBAR:
Menu, FileMenu, Add,E&xit,EXIT
Menu, HelpMenu, Add,&About Belvedere,ABOUT
Menu, MenuBar, Add, &File, :FileMenu
Menu, MenuBar, Add, &Help, :HelpMenu
Return

PREFS:
msgbox, tk
return

HELP:
msgbox, tk
return

HOMEPAGE:
Run, http://lifehacker.com/341950/
return

WCHOMEPAGE:
Run, http://what-cheer.com/
return

ABOUT:
Gui,4: Destroy
Gui,4: +owner
Gui,4: Add,Picture,x45 y0,%BelvederePNG%
Gui,4: font, s8, Courier New
Gui,4: Add, Text,x275 y235,%Version%
Gui,4: font, s9, Arial 
Gui,4: Add,Text,x10 y250 Center,Belvedere is an automated file managment application`nthat performs actions on files based on user-defined criteria.`nFor example, if a file in your downloads folder`nhasn't been opened in 4 weeks and it's larger than 10MB,`nyou can tell Belvedere to automatically send it to the Recycle Bin.`n`nBelvedere is written by Adam Pash and distributed`nby Lifehacker under the GNU Public License.`nFor details on how to use Belvedere, check out the
Gui,4:Font,underline bold
Gui,4:Add,Text,cBlue gHomepage Center x115 y385,Belvedere homepage
Gui,4:Add,Text,cBlue gWCHomepage Center x105 y400,Icon design by What Cheer
Gui,4: Color,F8FAF0
;Gui 2:+Disabled
Gui,4: Show,auto,About Belvedere
Return

#Include includes\verbs.ahk
#Include includes\subjects.ahk
#Include includes\actions.ahk
#Include includes\Main_GUI.ahk

EXIT:
ExitApp