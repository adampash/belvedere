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
		Msgbox,,Hazel: Missing Folder,A folder you're attempting to move or copy files to with Hazel does not exist. Check your "%thisRule%" rule in Hazel and verify that %destination% exists.
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
		Msgbox,,Hazel: Missing Folder,A folder you're attempting to move or copy files to with Hazel does not exist. Check your "%thisRule%" rule in Hazel and verify that %destination% exists.
		errorCheck := 1
	}
}

recycle(file)
{
	FileRecycle, %file%
}