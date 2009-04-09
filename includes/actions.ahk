delete(file)
{
	FileDelete, %file%
}

move(file, destination, overwrite)
{
	global thisRule
	global errorCheck
	IfExist, %destination%
	{
		FileMove, %file%, %destination%, %overwrite%
	}
	else
	{
		Msgbox,,&APPNAME%: Missing Folder,A folder you're attempting to move or copy files to with &APPNAME% does not exist. Check your "%thisRule%" rule in &APPNAME% and verify that %destination% exists.
		errorCheck := 1
	}
}

copy(file, destination, overwrite)
{
	global thisRule
	global errorCheck
	IfExist, %destination%
	{
		FileCopy, %file%, %destination%, %overwrite%
	}
		else
	{
		Msgbox,,&APPNAME%: Missing Folder,A folder you're attempting to move or copy files to with &APPNAME% does not exist. Check your "%thisRule%" rule in &APPNAME% and verify that %destination% exists.
		errorCheck := 1
	}
}

recycle(file)
{
	FileRecycle, %file%
}
