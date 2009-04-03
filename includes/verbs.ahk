contains(Subject, Object)
{
	IfInString, Subject, %Object%
	{
		result := true
	}
	else
	{
		result := false
	}
	;Msgbox, %subject% contains %object%? %result%
	return result
}

isEqual(Subject, Object)
{
	;Msgbox, %subject% is equal to %object%?
	if (Subject = Object)
	{
		result := true
	}
	else
	{
		result := false
	}
	; Msgbox, Result is %result%
	return result
}

isOneOf(Subject, Object)
{
	if Subject in %Object%
	{
		;msgbox, %subject% is in %object%
		result := true
	}
	else
	{
		;msgbox, %subject% is not in %object%
		result := false
	}
	return result
}

isGreaterThan(Subject, Object)
{
	if (Subject > Object)
	{
		result := true
	}
	else
	{
		result := false
	}
	return result
}

isLessThan(Subject, Object)
{
	if (Subject < Object)
	{
		result := true
	}
	else
	{
		result := false
	}
	;msgbox, %subject% < %object%? %result%
	return result
}

isInTheLast(Subject, Object)
{
	global thisRule
	IniRead, Units, rules.ini, %thisRule%, Units
	if (Units = "ERROR")
	{
		global testUnits
		Units = %testUnits%
	}
	EnvSub, Time, %Subject%, s
	;MsgBox, %A_Now% - %Subject% = %Time%
	if (Units = "minutes")
	{
		if ((Time/60) < Object)
		{
			result := true
		}
		else
		{
			result := false
		}
	}
	else if (Units = "hours")
	{
		if ((Time/3600) < Object)
		{
			result := true
		}
		else
		{
			result := false
		}
	}
	else if (Units = "days")
	{
		if ((Time/86400) < Object)
		{
			result := true
		}
		else
		{
			result := false
		}
	}
	else if (Units = "weeks")
	{
		if ((Time/604800) < Object)
		{
			result := true
		}
		else
		{
			result := false
		}
	}

	return result
}

getObjectTime(Object)
{
	global thisRule
	IniRead, Units, rules.ini, %thisRule%, Units
	if (Units = "minutes")
	{
		
	}
}