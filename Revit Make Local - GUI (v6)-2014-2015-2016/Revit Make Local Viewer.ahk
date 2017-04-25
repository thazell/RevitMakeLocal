;---### Scripted by David Baldacchino. Started on 01/13/2009 (V2009) and finished 04/16/2010 (v2011) - Introduced GUI & enhanced Build checking
;---### Other release dates: 08/10/2007 (V1), 03/01/2008 (V2), 04/02/2008 (V3), 05/08/2009  (V4). Thanks to everyone for their help on the Discussion Forum at AutoHotKey.com!!
;---### Thanks to David Kingham of The Neenan Company and James Vandezande of HOK (formerly of SOM New York) for contributing their code and for their input on the AUGI Forums!


; RESOURCES:
; http://www.autohotkey.com/docs/commands/ListView.htm 

appdata := A_appdata

;#NoEnv  					; Recommended for performance and compatibility with future AutoHotkey releases.
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
IniRead, FolderCentral, %SettingsINI%, PATHS, Projects		; Path for button "Navigate to Central File"
IniRead, FolderLinks, %SettingsINI%, PATHS, Links		; Path for LinkFiles
IniRead, FolderLocals, %SettingsINI%, PATHS, Locals		; Path for Local Files Folder
IniRead, URL, %SettingsINI%, PATHS, URL				; Path for URL launched when clicking on logo
IniRead, HelpURL, %SettingsINI%, PATHS, HelpURL			; Path for URL containing help documentation
IniRead, DialogTitle, %SettingsINI%, DEFAULTS, DialogTitle	; Dialog Application Title
IniRead, CreateSC, %SettingsINI%, DEFAULTS, CreateSC		; 1 to have Create Desktop Shortcut checked by default; 0 to be unchecked
IniRead, RCoption, %SettingsINI%, DEFAULTS, RCoption		; Right-click default option: 1 to open locls, 2 to specify worksets, 3 to detach
EnvGet, username, username					; Username Environment Variable
EnvGet, computername, computername				; Computername Environment Variable
SCpath := getLNKorEXE()						; Full path of link calling the application or the application path

;---####--------------------------------------------------------------------------------------------------------------

getLNKorEXE(){ ; SKAN 14-Apr-2010 @ www.autohotkey.com/forum/viewtopic.php?p=347602#347602 
 VarSetCapacity(suInfo,68,0), DllCall("GetStartupInfoA", UInt,&suInfo) 
Return DllCall( "MulDiv", UInt,NumGet(SuInfo,12), Int,1, Int,1, Str ) 
}

If 1 <> SC
{
Goto, CreateGui
}
Else
{
	CENTRALFILE = %2%					; Populate variable CENTRAFILE (if GUI is used, it will be populated by what the user double/right-clicks on)
	FolderCentral = %A_WorkingDir%				; This sets the central folder to the shortcut's "Start in" field
	Goto, LocalOperations	
}

ExitApp

CreateGui: ;---####-------------------Create GUI

Gui +Resize										; Allow the user to maximize or drag-resize the window:
Gui, Add, Text, y10 x10, Central file naming convention:
Gui, font, bold

Gui, Add, Text, cBlue y10 W100, XXXXX
Gui, Add, Text, y10 xp+43, -
Gui, Add, Text, cBlue y10 xp+8 w20, #
Gui, Add, Text, cBlue y10 xp+8 w20, VV
Gui, Add, Text, y10 xp+20, -
Gui, font
Gui, Add, Text, cBlue y10 xp+8, CENTRAL . rvt
Gui, font, bold
Gui, Add, Text, cBlue y+10 x40 w100, XXXXX
Gui, font
Gui, Add, Text, cBlack yp x100, Project # && description (any length)
Gui, font, bold
Gui, Add, Text, cBlue yp+15 x40 w20, #
Gui, font
Gui, Add, Text, cBlack yp x100, Discipline designator (A, S, M, E or P)
Gui, font, bold
Gui, Add, Text, cBlue yp+15 x40 w20, VV
Gui, font
Gui, Add, Text, cBlack yp x100, Version designator (last 2 digits - ex: 11)
Gui, Add, Text, cBlack y+10 x10, EX:
Gui, Add, Text, cBlue yp x38, 1234 DreamHouse A11_Central.rvt
Gui, Add, Text, cBlack yp x+5, (dashes can be any character)
Gui, font, s10
Gui, Add, Text, vInstructions cRed x10 yp+20, Right-Click a project and pick an option (or Double-Click to run the default option)
Gui, font

Gui, Add, Checkbox, vCreateShortcut checked%CreateSC% y+27 , Add Desktop Shortcut


;---#### Create the ListView and its columns:

Gui, Add, ListView, Grid  LV0x40 -Multi altsubmit xm y130 r10 w500 vMyListView gMyListView, Name|Date modified|Size	; You can also add |Type to list the file type but we'll filter for rvt "Central" only
LV_ModifyCol(3, "Integer")  												; For sorting, we need to indicate that the Size column is an integer. Otherwise it will be sorted (incorrectly) as text

ImageListID1 := IL_Create(10)												; Create an ImageList so that the ListView can display some icons:
ImageListID2 := IL_Create(10, 10, true)  ; A list of large icons to go with the small ones.

; Attach the ImageLists to the ListView so that it can later display the icons:
LV_SetImageList(ImageListID1)
LV_SetImageList(ImageListID2)

; Display the window and return. The OS will notify the script
; whenever the user performs an eligible action:
GuiControl, Disable, MyListView
GuiControl, Hide, Instructions
GuiControl, Disable, CreateShortcut
LV_ModifyCol() 										; Auto-size each column to fit its contents.
							
Gui, Add, Button, Y130 W120 vButtonHelp gButtonHelp, Help Me!
Gui, Add, Picture, w120 h120 vMyLogo gMyLogo, %A_ScriptDir%\Logo.jpg
gui, font, s10 Verdana bold
Gui, Show, W700, %DialogTitle%
gui, font



goto Previewloopfiles
return

ButtonHelp: ;---####--------------------------Online Help

run %HelpURL%
Return

MyLogo: ;---####------------------------------URL will be opened when logo is clicked

run %URL%
return


; Ensure the variable has enough capacity to hold the longest file path. This is done
; because ExtractAssociatedIconA() needs to be able to store a new filename in it.
VarSetCapacity(Filename, 260)
sfi_size = 352
VarSetCapacity(sfi, sfi_size)



; set discipline and version defaults.   These should be moved to INI file later.
DSCPLNDFLT = 
VRSNDFLT = 
VERSIONDFLT = 

PREVIEWLOOPFILES:
GuiControl, -Redraw, MyListView  ; Improve performance by disabling redrawing during load.
Loop %FolderCentral%\*CENTRAL.rvt
{
    FileName := A_LoopFileFullPath  ; Must save it to a writable variable for use below.
    ; Check if the discipline designator is acceptable and if so, add to the list view

    DSCPLN := SubStr(A_LoopFileName,-14,1)    						; Pick the 14th character to determine the discipline
    StringUpper, DSCPLN, DSCPLN								; Capitalize discipline designator
    If (DSCPLN = "A" OR DSCPLN = "S" OR DSCPLN = "M" OR DSCPLN = "E" OR DSCPLN = "P")	; If the Discipline Designator is correct, we add the file to the list view
    {
    DSCPLNDFLT := SubStr(A_LoopFileName,-14,1)
    VRSNDFLT := SubStr(A_LoopFileName,-13,2)
    VERSIONDFLT := 2000 + SubStr(A_LoopFileName,-13,2)
    ; Create the new row in the ListView and assign it the icon number determined above:
    FormatTime, DateCreated, %A_LoopFileTimeModified%, MM/dd/yyyy  hh:mm tt
    LV_Add("Icon" . IconNumber, A_LoopFileName, DateCreated, A_LoopFileSizeKB " KB") ; FileExt
    }
}

;check Links Folder folder
Loop %FolderLinks%\*.rvt
{
    FileName := A_LoopFileFullPath  ; Must save it to a writable variable for use below.

    ; Build a unique extension ID to avoid characters that are illegal in variable names,
    ; such as dashes.  This unique ID method also performs better because finding an item
    ; in the array does not require search-loop.    ; Check if the discipline designator is acceptable and if so, add to the list view
;commented out dscpln check

 ;   DSCPLN := SubStr(A_LoopFileName,-14,1)    						; Pick the 14th character to determine the discipline
 ;   StringUpper, DSCPLN, DSCPLN								; Capitalize discipline designator
 ;   If (DSCPLN = "A" OR DSCPLN = "S" OR DSCPLN = "M" OR DSCPLN = "E" OR DSCPLN = "P")	; If the Discipline Designator is correct, we add the file to the list view
 ;   {
    ; Create the new row in the ListView and assign it the icon number determined above:
    FormatTime, DateCreated, %A_LoopFileTimeModified%, MM/dd/yyyy  hh:mm tt
    LV_Add("Icon" . IconNumber, "Link - "A_LoopFileName, DateCreated, A_LoopFileSizeKB " KB") ; FileExt
 ;   }
}
GuiControl, +Redraw, MyListView  							; Re-enable redrawing (it was disabled above).

LV_ModifyCol()  									; Auto-size each column to fit its contents.

if % LV_GetCount() > 0									; If Listview contains rows of data, we enable the control; otherwise disable it
{
GuiControl, Enable, MyListView
GuiControl, Show, Instructions
GuiControl, Enable, CreateShortcut
LV_ModifyCol(3, 60) 									; Make the Size column at little wider to reveal its header.
}
else
{
LV_Add("Icon" . 0, "No Central files were found! Navigate to another folder and try again", "")
GuiControl, Disable, MyListView
GuiControl, Hide, Instructions
GuiControl, Disable, CreateShortcut
LV_ModifyCol()  									; Auto-size each column to fit its contents.
}

return


ClearListView:
LV_Delete()  										; Clear the ListView, but keep icon cache intact for simplicity.
return

MyListView:
if A_GuiEvent = DoubleClick								; Default option is invoked (set in Settings.ini)
{
GoSub, DefaultOpen
}

return

ReadGuiData: ;---####-------------------------Retrieve GUI data and return it to the calling subroutine

Gui, Submit, NoHide
RowNumber := LV_GetNext()
LV_GetText(CENTRALFILE, RowNumber, 1)
return


GuiContextMenu: ;---####----------------------Do Nothing on Right Click
return
DefaultOpen: ;---####-----------------------The user selected "Create Local & Open" in the context menu

3 = OPEN
If % LV_GetCount("Selected")>0
{
	GoSub, ReadGuiData
	If CreateShortcut=1
	{
		;msgbox, Shortcut will be created for %CENTRALFILE% and local will be opened
		scToolTip = Create & Open Local for %CENTRALFILE%
		Goto, CreateShorty
	}
	Else
	{
		;msgbox, Local for %CENTRALFILE% will be opened (NO SHORTY!)
		Goto, LocalOperations
	}
}
return

DetachedOpen: ;---####------------------------The user selected "Open a Detached Local copy" in the context menu

3 = DETACH
If % LV_GetCount("Selected")>0
{
	GoSub, ReadGuiData
	If CreateShortcut=1
	{
		;msgbox, Shortcut will be created for %CENTRALFILE% and local will be opened as Detached from Central
		scToolTip = Open a Detached Copy of %CENTRALFILE%
		Goto, CreateShorty
	}
	Else
	{
		;msgbox, Local for %CENTRALFILE% will be opened as Detached copy (NO SHORTY!), 3=%3%
		Goto, LocalOperations
	}
}
return


CreateShorty: ;---####-----------------------------Create a Desktop Shortcut

IfInString, CENTRALFILE, CENTRAL
{
 StringTrimRight, PARTFILE, CENTRALFILE, 12                                     ; Remove "_central.rvt" from filename string (12 characters)...
}
else
{
 StringTrimRight, PARTFILE, CENTRALFILE, 4                                     ; Remove "_central.rvt" from filename string (12 characters)...
}
MsgBox, %PARTFILE%
MsgBox, %CENTRALFILE%
1 = SC
if 3 <>
{
scNamePart = -%3%
}
;---####----------------------- backup of my documents folder option ---> scDesktop = %A_MyDocuments%\Revit Links\%PARTFILE%%scNamePart%.lnk
scDesktop = %A_Desktop%\%PARTFILE%%scNamePart%.lnk

scParams =  %1% "%CENTRALFILE%" %3%

FileCreateShortcut, %A_ScriptFullPath%, %scDesktop%, %FolderCentral%, %scParams%, %scToolTip%,,,,3

Goto, LocalOperations

GuiSize: ;---####----------------------------------Resize and move the controls

Gui +Resize +MinSize500x290

if A_EventInfo = 1  									; The window has been minimized.  No action needed.
    return
;---### The following is performed when the window has been resized or maximized ----------------------------------------------------

GuiControl, Move, MyListView, % "W" . (A_GuiWidth - 150) . " H" . (A_GuiHeight - 140)
GuiControl, Move, ButtonHelp, % "x" . (A_GuiWidth - 130) 				; We want the button to move sideways but stay aligned at the top
GuiControl, Move, ButtonNav2Central, % "x" . (A_GuiWidth - 130) 			; We want the button to move sideways but stay aligned at the top
GuiControl, Move, CreateShortcut, % "x" . (A_GuiWidth - 130) 				; We want the button to move sideways but stay aligned at the top 
GuiControl, Move, MyLogo, % "x" . (A_GuiWidth - 130) . " y" . (A_GuiHeight - 130)	
return


;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

LocalOperations: ;---####------------------Finally, we run a modified version of the "old" script to:
;					   a) create local and open; b) specify worksets; c) create a detached copy

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

Gui, Destroy

;---#### Check that the Central File stored in switch 2 (parameter) exists!

IfNotExist, %FolderCentral%\%CENTRALFILE%
{
FolderCentral = %FolderLinks%
 StringTrimLeft, CENTRALFILE, CENTRALFILE, 7

DSCPLN = S
DISCIPLINE = Structure
IfNotExist, %FolderCentral%\%CENTRALFILE%
{FileDelete, %SCpath%									; Delete the shortcut since it refers to a central file and path that don't exist anymore
MsgBox, 16, Central File not found!, The Central File [%FolderCentral%\%CENTRALFILE%] was not found. `n`nPlease select a new Central File and create a new shortcut. `nFor your convenience, the old shortcut was deleted.
Goto, CreateGui
}


DSCPLN := SubStr(CENTRALFILE,-14,1)
VRSN := SubStr(CENTRALFILE,-13,2)
VERSION := 2000 + SubStr(CENTRALFILE,-13,2)


;---#### Check if the local file that we're trying to create is already running. If so, a warning will be issued and execution will stop


IfInString, CENTRALFILE, CENTRAL
{
 StringTrimRight, PARTFILE, CENTRALFILE, 12                                     ; Remove "_central.rvt" from filename string (12 characters)...
}
else
{
 StringTrimRight, PARTFILE, CENTRALFILE, 4                                     ; Remove ".rvt" from filename string (4 characters)...
 ; Remove "Link - " from filename string (7 characters)...
}
}
DESTINATION = %FOLDERLOCALS%%PARTFILE%\						; Full path for this project's local file

LOCALFILE = %PARTFILE%_%username%.rvt                                         	; and replace with "username.rvt"

IniRead, RevitApp, %SettingsINI%, REVIT, %DSCPLN%%VRSN%
MsgBox Revit App = %RevitApp%
MsgBox Default Values: %DSCPLNDFLT%%VRSNDFLT%
MsgBox Default Values: %DSCPLN%%VRSN%
If RevitApp = ERROR						
	{
	IniRead, RevitApp, %SettingsINI%, REVIT, %DSCPLNDFLT%%VRSNDFLT%
	}

mSGBOX, DISPLAY REVITAPP VARIABLE: %REVITAPP%
AppPath = %RevitApp%
JournPath = %RevitApp%Journals\

SetTitleMatchMode 2

IfWinExist, Revit, %PARTFILE%_%username%					; Revit 2009 32 bit does not report filename with ".rvt" but 64 bit does!! I hate inconsistencies
{
    If 3 = DETACH								
    {
        Goto, CHECKFLAVOR						      	; Do some checks and open detached copy without creating a local
    }
    Else
    {
       MsgBox, 16, Local file already open!, The local file for project [%PARTFILE%] belonging to user [%username%] is already running.`n`nThe current instance will now be activated.
       WinMaximize
       ExitApp
    }
}

If 3 = DETACH								
{
    Goto, CHECKFLAVOR						      		; We skip build checking and creating local
}


;<><><><><><>-----------BUILD CHECK------------Does not run if the correct Revit flavor (per discipline designator) is not found or when opening a detached copy----------

IfExist, %AppPath%Revit.exe							; This is true if Revit.exe is found in the retrieved path (I'm checking for the executable as the folders remain after uninstalling!)
{
	If ProjectsINI=								; If blank, we need to look for Projects.ini (or write to it) to the Central File folder
	{
	ProjectsINI = %FolderCentral%\Projects.ini
	}
	Else
		{
		ProjectsINI = %ProjectsINI%\Projects.ini			; If not blank, use the path for from Settings.ini to look for Projects.ini (or write to it)
		}

	FileGetVersion, RevitBuild, %AppPath%Revit.exe				; Get Machine's Revit Build #
	
	IniRead, ProjectBuild, %ProjectsINI%, %PARTFILE%, BUILD			; Latest detected Revit build for this project

	If ProjectBuild = ERROR						
	{
	IniWrite, %RevitBuild%, %ProjectsINI%, %PARTFILE%, BUILD		; Project not found; Write a new Section and Key with BUILD
	IniWrite, OK, %ProjectsINI%, %PARTFILE%, %computername%			; After writing build, we set Computername to OK			
	}
	Else
		{
		StringReplace, RBuild, RevitBuild,., , All
		StringReplace, PBuild, ProjectBuild,., , All
		subtract := RBuild - PBuild					; Subtract BUILD from RevitBuild			
	

		;---#### If %subtract% is Negative, Revit needs to be upgraded on %computername%

		If subtract < 0
		{
		IniWrite, UPGRADE, %ProjectsINI%, %PARTFILE%, %computername%
		msgbox,48, Multiple Revit Builds working on [%PARTFILE%], The Project Team is on Revit Build# %ProjectBuild%, but this `ncomputer (%computername%) is on Revit Build# %RevitBuild%. `n`nTo avoid any potential problems, please contact your local workstation administrator to upgrade as soon as possible.
		}



		;---#### If %subtract% is Zero, Revit is up to date on %computername%

		If subtract = 0
		{
		IniWrite, OK, %ProjectsINI%, %PARTFILE%, %computername%
		}


		;---#### If %subtract% is Positive, Revit on %computername% is more current and BUILD (%ProjectBuild%) needs to be updated


		If subtract > 0
		{
		IniWrite, %RevitBuild%, %ProjectsINI%, %PARTFILE%, BUILD
		IniWrite, OK, %ProjectsINI%, %PARTFILE%, %computername%
		}


		} ; end of Else statement
}

;<><><><><><>--------------------------------END OF BUILD CHECK-----------------------------------------------------------------------------------------------------------


;----------------####-------Now start the correct flavor of Revit, but first check if it is installed. Use current session (for OPEN only) if it is already running.
;----------------####-------Remove the user's username from Revit.ini so Revit uses the Username System Variable. Then open the new local file.
CHECKFLAVOR: ;---####-------Check to see if correct Revit flavor exists and if not offer options to use a different one of the same version.

If DSCPLN = A
{
DISCIPLINE = Architecture
}

If DSCPLN = S
{
DISCIPLINE = Structure
}

If DSCPLN = M
{
DISCIPLINE = MEP
}

If DSCPLN = E
{
DISCIPLINE = MEP
}

If DSCPLN = P
{
DISCIPLINE = MEP
}

If InStr(CENTRAFILE, "\")
{
MsgBox Found backslash
DSCPLN = S
DISCIPLINE = Structure
PARTFILE = %CENTRALFILE%
}
IfNotExist, %AppPath%Revit.exe							; This is true if Revit.exe is found in retrieved path (also if it was blank or "ERROR"). I'm checking for the executable as the folders remain after uninstalling!
{
   if (RevitApp = "ERROR" or RevitApp = "")					; This is true if version doesn't exist in settings.ini or path is blank
   {
   MsgBox, HELP! %AppPath%Revit.exe
   MsgBox, 20, Error 187902 Revit %DISCIPLINE% %VERSION% not found!, The path for Revit %DISCIPLINE% %VERSION% was not found in Settings.ini. `n`nDo you want to use another discipline's Revit %VERSION% application to open [%LOCALFILE%]?
   IfMsgBox No
	{
	RUN %A_ScriptDir%
	ExitApp
	}
   }
   Else
   {
   MsgBox, 20, Revit %DISCIPLINE% %VERSION% not found!, Revit %DISCIPLINE% %VERSION% is not installed at the path specified in Settings.ini. `n`nDo you want to use another discipline's Revit %VERSION% application to open [%LOCALFILE%]?
   IfMsgBox No
	{
	RUN %A_ScriptDir%
	ExitApp
	}
   }

;---####-------------------------------------------------------We now force and cycle through all the discipline designators to see what version of Revit we can find installed

      		DSCPLN = A
      		IniRead, RevitApp, %SettingsINI%, REVIT, %DSCPLN%%VRSN%
		AppPath = %RevitApp%
		JournPath = %RevitApp%Journals\
      		IfNotExist, %AppPath%Revit.exe
     		{	
       	  	DSCPLN = S
      		}
      		IniRead, RevitApp, %SettingsINI%, REVIT, %DSCPLN%%VRSN%
		AppPath = %RevitApp%
		JournPath = %RevitApp%Journals\
		IfNotExist, %AppPath%Revit.exe
     		{	
       	  	DSCPLN = M
      		}
      		IniRead, RevitApp, %SettingsINI%, REVIT, %DSCPLN%%VRSN%
		AppPath = %RevitApp%
		JournPath = %RevitApp%Journals\
		IfNotExist, %AppPath%Revit.exe
     		{	
       	  	DSCPLN = E
      		}
      		IniRead, RevitApp, %SettingsINI%, REVIT, %DSCPLN%%VRSN%
		AppPath = %RevitApp%
		JournPath = %RevitApp%Journals\
		IfNotExist, %AppPath%Revit.exe
     		{	
       	  	DSCPLN = P
      		}
      		IniRead, RevitApp, %SettingsINI%, REVIT, %DSCPLN%%VRSN%
		AppPath = %RevitApp%
		JournPath = %RevitApp%Journals\
		IfNotExist, %AppPath%Revit.exe
      		{
         	MsgBox, 16, No Revit %VERSION% was found!!, No flavor of Autodesk Revit %VERSION% is installed on this computer, or Settings.ini contains incorrect or missing Revit install paths. `n`nPlease contact your local workstation administrator for assistance!
         	ExitApp
		}
}


IniDelete, %AppPath%\Revit.ini, Partitions, Username 				; Let's delete the username from the Revit.ini first


;---#### Create local file folder in case it doesn't exist. Delete the backup copy of the local file. Rename the existing local file so it becomes the new backup.
;---#### Then copy the central file to this folder and rename it to reflect the user's username, thus becoming the new local file. 


If 3 = DETACH								
{
    Goto, OPENLOCAL						      		; We skip making a local and just open a detached copy
}

FileCreateDir %DESTINATION%				      		       	; Project destination within new sub-folder

FileRecycle, %DESTINATION%%PARTFILE%_%username%_BAK.rvt                        	; If "_BAK" file exists, delete it and keep in recycle bin

FileMove, %DESTINATION%%LOCALFILE%, %DESTINATION%%PARTFILE%_%username%_BAK.rvt 	; Rename the local (if exists) by appending "_BAK" to the filename

FileCopy, %FolderCentral%\%CENTRALFILE%, %DESTINATION%, 0                       ; Do not overwrite existing files	(0). Copy central to destination...

FileMove, %DESTINATION%%CENTRALFILE%, %DESTINATION%%LOCALFILE%                 	; and rename copied central to appropriate local filename.

;msgbox, Central File=%CENTRALFILE% `nDiscipline=%DSCPLN% `nVersion=%VRSN% `nDestination=%Destination% `nPartfile=%partfile% `nCentral Folder=%FolderCentral% `n`nRevitApp=%RevitApp% `nAppPath=%AppPath%

OPENLOCAL:

If DSCPLN = A
{
DISCIPLINE = Architecture
}

If DSCPLN = S
{
DISCIPLINE = Structure
}

If DSCPLN = M
{
DISCIPLINE = MEP
}

If DSCPLN = E
{
DISCIPLINE = MEP
}

If DSCPLN = P
{
DISCIPLINE = MEP
}


If InStr(CENTRAFILE, "\")
{
MsgBox Found backslash
DSCPLN = S
DISCIPLINE = Structure
PARTFILE = %CENTRALFILE%
}
;---#### If the shortcut has the "DETACH" switch, we run this portion   ;, "IDOK", "..\..\..\Revit Local Files\%LOCALFILE%"
OPENDETACHED:
If 3 = DETACH         
{

;FileDelete C:\Revit Local Files\detachedopen.txt

FileDelete C:\ProgramData\Autodesk\Revit\Addins\20%VRSN%\detachedopen.txt
FileDelete C:\ProgramData\Autodesk\Revit\Addins\20%VRSN%\journal.*.*

; Now we create the journal so Revit will create a detached copy, no questions asked. We have 2 versions as things have changed in 2010 journals.


	FileAppend,
	(
	'
	' 0:< Initial VM: Avail 134217399 MB, Used 18 MB, Peak 18; RAM: Avail 23736 MB, Used 56 MB, Peak 18 
	' 0:< GUI Resource Usage GDI: Avail 9995, Used 5, User: Used 3 
	'C 06-Mar-2017 10:42:24.188;   0:< started recording journal file 
	' Build: 20170118_1100(x64)
	' Branch: RELEASE_2017_R2
	Dim Jrn
	Set Jrn = CrsJournalScript
	Jrn.Directive "DebugMode", "PerformAutomaticActionInErrorDialog", 1
	Jrn.Directive "DebugMode", "PermissiveJournal", 1
	Jrn.Command "StartupPage" , "Open an existing project , ID_REVIT_FILE_OPEN"
	Jrn.Data "FileOpenSubDialog" , "OpenAsLocalCheckBox", "True"
	Jrn.Data "FileOpenSubDialog" , "DetachCheckBox", "True"
	Jrn.Data "FileOpenSubDialog" , "OpenAsLocalCheckBox", "False" 
	Jrn.Data "File Name" , "IDOK", "%FolderCentral%\%CENTRALFILE%"
	Jrn.Data "WorksetConfig" , "Custom", 0
	Jrn.Data "TaskDialogResult" , "Detaching this model will create an independent model. You will be unable to synchronize your changes with the original central model." & vbLf & "What do you want to do?", "Detach and preserve worksets", "1001"
	Jrn.Directive "DebugMode", "PerformAutomaticActionInErrorDialog", 0
	), C:\ProgramData\Autodesk\Revit\Addins\20%VRSN%\detachedopen.txt

; Open Revit Discipline 20XX and open a detached copy
;    Run %AppPath%Revit.exe "N:\Revit\Revit Development\Revit Create Local File Script\Revit Make Local - GUI (v6)-2014-2015-2016\testing\Working Detach Open Min.txt",,max
;    Goto, SPLASHSCREEN

; Open Revit Discipline 20XX and open a detached copy
   Run %AppPath%Revit.exe /viewer "C:\ProgramData\Autodesk\Revit\Addins\20%VRSN%\detachedopen.txt",,max
   Goto, SPLASHSCREEN
}

;FileAppend, 
;(
;'
;Dim Jrn
;Set Jrn = CrsJournalScript
;Jrn.Command "Menu" , "Open an existing project , 57601 , ID_REVIT_FILE_OPEN"
;Jrn.Data "File Name"  _
;, "IDOK", "%DESTINATION%%LOCALFILE%"
;Jrn.Data "WorksetConfig"  _
;, "Editable", 0
;  Jrn.Data "MessageBox"  _;
;		  , "IDOK", "This Central File has been copied or moved from ""%FolderCentral%\%CENTRALFILE%"" to ""%DESTINATION%%LOCALFILE%""." & vbCrLf & "" & vbCrLf & "If you wish this file to remain a Central File then you must re-save the file as a Central File. To do this select ""Save As"" from the ""File"" menu and check the ""Make this a Central File after save"" check box (under the options button) before you save." & vbCrLf & "" & vbCrLf & "If you do not save the file as a Central File then it will be considered a local user copy of the file belonging to user ""%Username%""."
;Jrn.Command "Menu" , "Workset control , 33460 , ID_SETTINGS_PARTITIONS"
;), %JournPath%select_ws.txt
;
; Open Revit Discipline 20XX and open the file; worksets dialog pops up at the end
;    Run %AppPath%Revit.exe "%JournPath%select_ws.txt",,max
;    Goto, SPLASHSCREEN
;}
;---#### If the shortcut has an invalid or no switch, we open local as usual.  I removed the Worksets option from the code


combinedstringoflicensetypes  = 
Loop Files, C:\ProgramData\Autodesk\CLM\LGS\LGS.data, R  ; Recurse into subfolders.
{
	FileRead, output, %A_LoopFileFullPath%
	combinedstringoflicensetypes = %combinedstringoflicensetypes%%output%
}
SetTitleMatchMode 2

IfWinExist Revit %DISCIPLINE% %VERSION%
{
; Activate Revit Discipline 20XX and open the file
    WinMaximize
    Run %DESTINATION%%LOCALFILE%,,max
    Goto, FINISHUP
}
else
{
; Open Revit Discipline 20XX and open the file

    ifInString, combinedstringoflicensetypes, _NETWORK 
	{
		MsgBox, 0,Temp Message Box for Testing, %combinedstringoflicensetypes% : Network license found will ask about viewer mode. 
		MsgBox, 4,, Would you like to open in Viewer Mode only?
		IfMsgBox, No
		{
		IfExist, %appdata%\Autodesk\Revit\SettingsBackupforJournalFile\Autodesk Revit 20%VRSN%\Revit.ini ;We need to test if the contents of the folder exists
			{
			;MsgBox, The target file does exist we will use it. 
			;if yes then use it
			FileMove, %appdata%\Autodesk\Revit\SettingsBackupforJournalFile\Autodesk Revit 20%VRSN%\Revit.ini, %appdata%\Autodesk\Revit\Autodesk Revit 20%VRSN%\Revit.ini, 1
			FileMove, %appdata%\Autodesk\Revit\SettingsBackupforJournalFile\Autodesk Revit 20%VRSN%\KeyboardShortcuts.xml, %appdata%\Autodesk\Revit\Autodesk Revit 20%VRSN%\KeyboardShortcuts.xml, 1
			}
		else
			{
			;if no fill use them (copy down)
			;MsgBox, the target file does not exist.  We arent going to do anything.
			
			}
			
		Run %AppPath%Revit.exe "%DESTINATION%%LOCALFILE%",,max
		}
		
		
	IfMsgBox, Yes ; use revit viewer
		{
		IfExist, %appdata%\Autodesk\Revit\SettingsBackupforJournalFile\Autodesk Revit 20%VRSN%\Revit.ini ;Using viewer if contents of the folder exist, do nothing
			{
			;MsgBox, The target file does exist and so we wont make another copy 
			;if skip
			}
		else
			{
			;if yes skip
			;MsgBox, The target file does not exist so we will copy it into the folder. 
			FileCreateDir, %appdata%\Autodesk\Revit\SettingsBackupforJournalFile\Autodesk Revit 20%VRSN%
			FileCopy, %appdata%\Autodesk\Revit\Autodesk Revit 20%VRSN%\Revit.ini, %appdata%\Autodesk\Revit\SettingsBackupforJournalFile\Autodesk Revit 20%VRSN%\, 0
			FileCopy, %appdata%\Autodesk\Revit\Autodesk Revit 20%VRSN%\KeyboardShortcuts.xml, %appdata%\Autodesk\Revit\SettingsBackupforJournalFile\Autodesk Revit 20%VRSN%\, 0
			}
			;We need to test if the contents of the folder are empty
			3 = DETACH
			Goto, OPENDETACHED
		}
    }
}


;---#### The following is the animated Splash Screen that shows up when opening a Revit session.
;---#### It will disappear once the Revit splash screen appears.

SPLASHSCREEN:

SplashCheck:
	If WinExist("ahk_class Afx:66A30000:40") or WinExist("ahk_class Afx:00400000:40") or WinExist("ahk_class Afx:0000000140000000:40")   ; 2008 or 2009/2010 32 bit bit or 2009/2010 64 bit Revit
	{
   	Progress, Off ;msgbox, splashscreen detected!
   	SetTimer, SplashCheck, Off ;kill splashscreen here
	L := -100
	If 3 = OPEN							; We only want to run the loop to check for the "central has been copied" warning when we OPEN local only.
	{
		Goto, Finishup
	}
	ExitApp
	}

Goto, Finishup
Return

FINISHUP_old:

#Persistent
SetTimer, MsgBoxCheck, 1000

MsgBoxCheck:

If VRSN < 10
{
;Goto, Dismiss2009
If WinExist("Revit", "This Central File has been copied or moved from", "ahk_class #32770")
	{
   	WinClose
   	ExitApp
	}
}
Else
{
	IfWinExist, Copied Central File
	{
   	WinClose
   	ExitApp
	}
}

Return

;-----------------------------------------------------------------------------------------
Finishup:
GuiEscape:
GuiClose:
ExitApp