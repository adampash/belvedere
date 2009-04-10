
0.1 Release:
	x GUI
	x Actions:
	x Subject:
		x Date modified
		x Date created
		x Date last opened
	
0.2 Release:
	x Matches multiple rules (ALL or ANY)
	x Edit existing rules
	x Action Updates: Move file to Recycle Bin, permanently delete
	x fixed mouse bugs
	x Add new icon from John Muller
	x Set checks for proper data entry before submit	
	x Verify no duplicate rule descriptions	for a single folder
	x Add excellent new icon, about page

	
0.3 Release:
	x Test rule matches
		x Not absolutely perfect (there are some bugs when you've deleted conditions), but seems to work apart from that
	x Check for existing folders before attempting to move or copy
	x Set matchlist for OR stringing of Name and Extension conditions... e.g., Extension matches on of png,jpg,gif
	x Fix saving bug detailed here: http://lifehacker.com/341950/belvedere-automates-your-self+cleaning-pc#c4044294

Added Features not yet in release:
	- Enable/Disable rules with UI checkboxes
	- Recurse subdirectories
	- Option to overwrite or not when moving or copying files
	- Added tabbed interface for rules and preferences
	- Added configurable sleeptime
	- Added rule and folder deletion confirmation
	- fixed bug in rule description bug across folders
	- created application installer
	
Maybe features:
 	- Multiple Actions (e.g., copy twice, copy and move, etc.) (moved to 0.3)
	- Trash management tab a la Hazel (i.e., Keep Recycle Bin size under X GB)
	- Import media to iTunes
	- Multiple Actions/Results
	- Action, Action1, etc, break loop when IniRead reads ERROR
	- Update GUI to allow for multiple actions
	- change rule storage 
