;---### Scripted by David Baldacchino. Started on 01/13/2009 (V2009) and finished 04/16/2010 (v2011) - Introduced GUI & enhanced Build checking
;---### Other release dates: 08/10/2007 (V1), 03/01/2008 (V2), 04/02/2008 (V3), 05/08/2009  (V4). Thanks to everyone for their help on the Discussion Forum at AutoHotKey.com!!
;---### Thanks to David Kingham of The Neenan Company and James Vandezande of HOK (formerly of SOM New York) for contributing their code and for their input on the AUGI Forums!


; RESOURCES:
; http://www.autohotkey.com/docs/commands/ListView.htm 

#NoEnv  					; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  				; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force				; If the script is currently running this will kill it
#WinActivateForce
Hotkey #x, GuiClose				; Allows script to be terminated with Win + X

;---### VARIABLES - Initialize, Capitalize, get from settings.ini, etc.-----------------------------------------------

StringUpper,1 ,1				; "1" - first command line parameter in the Target field of the shortcut (SC)
StringUpper,3 ,3				; "3" - Third command line parameter in the Target field of the shortcut (DETACH, WORKSETS)
						; SC - Opens Local; SC GaRbAgE - Opens Local; SC WORKSETS - Specify Worksets; SC DETACH - Open Detached Copy

SettingsINI = %A_ScriptDir%\Settings.ini
IniRead, ProjectsINI, %SettingsINI%, PATHS, ProjectsINI		; Path for ProjectsINI
IniRead, FolderProjects, %SettingsINI%, PATHS, Projects		; Path for button "Navigate to Central File"
IniRead, FolderLocals, %SettingsINI%, PATHS, Locals		; Path for Local Files Folder
IniRead, URL, %SettingsINI%, PATHS, URL				; Path for URL launched when clicking on logo
IniRead, HelpURL, %SettingsINI%, PATHS, HelpURL			; Path for URL containing help documentation
IniRead, DialogTitle, %SettingsINI%, DEFAULTS, DialogTitle	; Dialog Application Title
IniRead, CreateSC, %SettingsINI%, DEFAULTS, CreateSC		; 1 to have Create Desktop Shortcut checked by default; 0 to be unchecked
IniRead, RCoption, %SettingsINI%, DEFAULTS, RCoption		; Right-click default option: 1 to open locls, 2 to specify worksets, 3 to detach
EnvGet, username, username					; Username Environment Variable
EnvGet, computername, computername				; Computername Environment Variable

CreateGui: ;---####-------------------Create GUI

Gui +Resize										; Allow the user to maximize or drag-resize the window:
Gui, Add, Text, y10 x10, This is the new ETABS launcher that will help us limit the use of high level licenses being checked out.
Gui, Add, Text, y25 x10, If you run into issues using it please contact Timon Hazell (C) Silman:
Gui, Add, Button, vButtonNavETABS1 gButtonETABS1 W120 H50 x10 y50 Default, Etabs Plus
Gui, Add, Button, vButtonNavETABS2 gButtonETABS2 W120 H50 x150 y50 Default, Etabs Non-Linear
Gui, Add, Button, vButtonNavETABS3 gButtonETABS3 W120 H50 x290 y50 Default, Cancel
Gui, font
gui, font, s10 Verdana bold
Gui, Show, W700, %DialogTitle%
gui, font

return

ButtonHelp: ;---####--------------------------Online Help

run %HelpURL%
Return

MyLogo: ;---####------------------------------URL will be opened when logo is clicked

run %URL%
return
ButtonETABS1:
; this option only works for .exe files and dragging onto the ahk doesn't seem to work the same way.

Loop %1%  ; For each parameter (or file dropped onto a script):
{
GivenPath := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
Loop %GivenPath%, 1
LongPath = %A_LoopFileLongPath%
SplitPath, LongPath , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
}


zFNvariable := """" . LongPath . """"

Run C:\Program Files\Computers and Structures\ETABS 2016\ETABS.exe %zFNvariable% /L PLUS


Goto, GuiEscape
return

ButtonETABS2:
; this option only works for .exe files and dragging onto the ahk doesn't seem to work the same way.

Loop %1%  ; For each parameter (or file dropped onto a script):
{
GivenPath := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
Loop %GivenPath%, 1
LongPath = %A_LoopFileLongPath%
SplitPath, LongPath , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
}

zFNvariable := """" . LongPath . """"

Run C:\Program Files\Computers and Structures\ETABS 2016\ETABS.exe %zFNvariable% /L NONLINEAR
Goto, GuiEscape
return

ButtonETABS3:
Goto, GuiEscape
return
;-----------------------------------------------------------------------------------------
GuiEscape:
GuiClose:
ExitApp