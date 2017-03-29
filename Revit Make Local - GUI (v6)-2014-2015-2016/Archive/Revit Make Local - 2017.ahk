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
Gui, Add, Button, vButtonNav2Central gButtonNav2Central W120 H50 y10 Default, Go to Central`nFile Folder
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

; Create a Right-Click context menu:

If (RCoption = 1) {
   RCDefault = Create Local && Open
}
If (RCoption = 2) {
   RCDefault = Create Local && Specify Worksets to open
}
If (RCoption = 3) {
   RCDefault = Open a Detached Local copy
}

Menu, MyContextMenu, Add, Create Local && Open, RightClickOpen
Menu, MyContextMenu, Add, Create Local && Specify Worksets to open, RightClickSpecify
Menu, MyContextMenu, Add, Open a Detached Local copy, RightClickDetach
Menu, MyContextMenu, Default, %RCDefault%						; Make this option a bold font to indicate that double-clicking will launch this by default

; Display the window and return. The OS will notify the script
; whenever the user performs an eligible action:
GuiControl, Disable, MyListView
GuiControl, Hide, Instructions
GuiControl, Disable, CreateShortcut

LV_Add("Icon" . 0, "Navigate to the Central File folder", "")				; Listview is disabled until a folder is selected
LV_ModifyCol() 										; Auto-size each column to fit its contents.
							
Gui, Add, Button, Y130 W120 vButtonHelp gButtonHelp, Help Me!
Gui, Add, Picture, w120 h120 vMyLogo gMyLogo, %A_ScriptDir%\Logo.jpg
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

ButtonNav2Central: ;---####-------------------Navigate to Central file folder

Gui +OwnDialogs  									; Forces user to dismiss the following dialog before using main window.
FileSelectFolder, FolderCentral, %FolderProjects%, 0, Select the Central File folder containing the RVT project you want to work in
if not FolderCentral  									; The user canceled the dialog.
    return

GoSub, ClearListView									;We want the list view to only show us the contents of the selected folder, so we always start by clearing it

; Check if the last character of the folder name is a backslash, which happens for root
; directories such as C:\. If it is, remove it to prevent a double-backslash later on.
StringRight, LastChar, FolderCentral, 1
if LastChar = \
    StringTrimRight, FolderCentral, FolderCentral, 1  					; Remove the trailing backslash.

; Ensure the variable has enough capacity to hold the longest file path. This is done
; because ExtractAssociatedIconA() needs to be able to store a new filename in it.
VarSetCapacity(Filename, 260)
sfi_size = 352
VarSetCapacity(sfi, sfi_size)

; Loop through the files in the selected folder (central files only) and append them to the ListView:
GuiControl, -Redraw, MyListView  ; Improve performance by disabling redrawing during load.
Loop %FolderCentral%\*CENTRAL.rvt
{
    FileName := A_LoopFileFullPath  ; Must save it to a writable variable for use below.

    ; Build a unique extension ID to avoid characters that are illegal in variable names,
    ; such as dashes.  This unique ID method also performs better because finding an item
    ; in the array does not require search-loop.
    SplitPath, FileName,,, FileExt  ; Get the file's extension.
    if FileExt in EXE,ICO,ANI,CUR
    {
        ExtID := FileExt  ; Special ID as a placeholder.
        IconNumber = 0  ; Flag it as not found so that these types can each have a unique icon.
    }
    else  ; Some other extension/file-type, so calculate its unique ID.
    {
        ExtID = 0  ; Initialize to handle extensions that are shorter than others.
        Loop 7     ; Limit the extension to 7 characters so that it fits in a 64-bit value.
        {
            StringMid, ExtChar, FileExt, A_Index, 1
            if not ExtChar  ; No more characters.
                break
            ; Derive a Unique ID by assigning a different bit position to each character:
            ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
        }
        ; Check if this file extension already has an icon in the ImageLists. If it does,
        ; several calls can be avoided and loading performance is greatly improved,
        ; especially for a folder containing hundreds of files:
        IconNumber := IconArray%ExtID%
    }
    if not IconNumber  ; There is not yet any icon for this extension, so load it.
    {
        ; Get the high-quality small-icon associated with this file extension:
        if not DllCall("Shell32\SHGetFileInfoA", "str", FileName, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
            IconNumber = 9999999  ; Set it out of bounds to display a blank icon.
        else ; Icon successfully loaded.
        {
            ; Extract the hIcon member from the structure:
            hIcon = 0
            Loop 4
                hIcon += *(&sfi + A_Index-1) << 8*(A_Index-1)
            ; Add the HICON directly to the small-icon and large-icon lists.
            ; Below uses +1 to convert the returned index from zero-based to one-based:
            IconNumber := DllCall("ImageList_ReplaceIcon", "uint", ImageListID1, "int", -1, "uint", hIcon) + 1
            DllCall("ImageList_ReplaceIcon", "uint", ImageListID2, "int", -1, "uint", hIcon)
            ; Now that it's been copied into the ImageLists, the original should be destroyed:
            DllCall("DestroyIcon", "uint", hIcon)
            ; Cache the icon to save memory and improve loading performance:
            IconArray%ExtID% := IconNumber
        }
    }


    ; Check if the discipline designator is acceptable and if so, add to the list view

    DSCPLN := SubStr(A_LoopFileName,-14,1)    						; Pick the 14th character to determine the discipline
    StringUpper, DSCPLN, DSCPLN								; Capitalize discipline designator
    If (DSCPLN = "A" OR DSCPLN = "S" OR DSCPLN = "M" OR DSCPLN = "E" OR DSCPLN = "P")	; If the Discipline Designator is correct, we add the file to the list view
    {
    ; Create the new row in the ListView and assign it the icon number determined above:
    FormatTime, DateCreated, %A_LoopFileTimeModified%, MM/dd/yyyy  hh:mm tt
    LV_Add("Icon" . IconNumber, A_LoopFileName, DateCreated, A_LoopFileSizeKB " KB") ; FileExt
    }
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
IfEqual, RCoption, 1, GoSub, RightClickOpen
IfEqual, RCoption, 2, GoSub, RightClickSpecify
IfEqual, RCoption, 3, GoSub, RightClickDetach
}

return

ReadGuiData: ;---####-------------------------Retrieve GUI data and return it to the calling subroutine

Gui, Submit, NoHide
RowNumber := LV_GetNext()
LV_GetText(CENTRALFILE, RowNumber, 1)
return

GuiContextMenu: ;---####----------------------Launched in response to a right-click or press of the Apps key.

if A_GuiControl <> MyListView  								; Display the menu only for clicks inside the ListView.
    return
											
if % LV_GetCount("Selected")>0								; LV_GetCount ("Selected") returns the # of selected rows.
{											; If one row is selected, the context menu displays.								
Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY% 						; Show the menu at the provided coordinates, A_GuiX and A_GuiY.  These should be used
return											; because they provide correct coordinates even if the user pressed the Apps key
}


RightClickOpen: ;---####-----------------------The user selected "Create Local & Open" in the context menu

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


RightClickSpecify: ;---####-----------------------The user selected "Create Local & Specify Worksets to open" in the context menu

3 = WORKSETS
If % LV_GetCount("Selected")>0
{
	GoSub, ReadGuiData
	If CreateShortcut=1
	{
		;msgbox, Shortcut will be created for %CENTRALFILE% and local will be opened after specifiying worksets
		scToolTip = Create & Open Local (Specify Worksets) for %CENTRALFILE%
		Goto, CreateShorty
	}
	Else
	{
		;msgbox, Local for %CENTRALFILE% will be opened after specifying worksets (NO SHORTY!)
		Goto, LocalOperations
	}
}
return


RightClickDetach: ;---####------------------------The user selected "Open a Detached Local copy" in the context menu

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

StringTrimRight, PARTFILE, CENTRALFILE, 12                                     ; Remove "_central.rvt" from filename string (12 characters)...

1 = SC
if 3 <>
{
scNamePart = -%3%
}
scDesktop = %A_MyDocuments%\Revit Links\%PARTFILE%%scNamePart%.lnk
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
FileDelete, %SCpath%									; Delete the shortcut since it refers to a central file and path that don't exist anymore
MsgBox, 16, Central File not found!, The Central File [%FolderCentral%\%CENTRALFILE%] was not found. `n`nPlease select a new Central File and create a new shortcut. `nFor your convenience, the old shortcut was deleted.
Goto, CreateGui
}


DSCPLN := SubStr(CENTRALFILE,-14,1)
VRSN := SubStr(CENTRALFILE,-13,2)
VERSION := 2000 + SubStr(CENTRALFILE,-13,2)


;---#### Check if the local file that we're trying to create is already running. If so, a warning will be issued and execution will stop


StringTrimRight, PARTFILE, CENTRALFILE, 12                                    	; Remove "_central.rvt" from filename string (12 characters)...

DESTINATION = %FOLDERLOCALS%%PARTFILE%\						; Full path for this project's local file

LOCALFILE = %PARTFILE%_%username%.rvt                                         	; and replace with "username.rvt"

IniRead, RevitApp, %SettingsINI%, REVIT, %DSCPLN%%VRSN%

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

IfNotExist, %AppPath%Revit.exe							; This is true if Revit.exe is found in retrieved path (also if it was blank or "ERROR"). I'm checking for the executable as the folders remain after uninstalling!
{
   if (RevitApp = "ERROR" or RevitApp = "")					; This is true if version doesn't exist in settings.ini or path is blank
   {
   MsgBox, 20, Revit %DISCIPLINE% %VERSION% not found!, The path for Revit %DISCIPLINE% %VERSION% was not found in Settings.ini. `n`nDo you want to use another discipline's Revit %VERSION% application to open [%LOCALFILE%]?
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


;---#### If the shortcut has the "DETACH" switch, we run this portion   ;, "IDOK", "..\..\..\Revit Local Files\%LOCALFILE%"

If 3 = DETACH         
{
FileDelete, %JournPath%detach.txt

; Now we create the journal so Revit will create a detached copy, no questions asked. We have 2 versions as things have changed in 2010 journals.

If VRSN >= 10
	{
	FileAppend,
	(
	'
	Set Jrn = CrsJournalScript
	Jrn.Command "Internal" , "Open an existing project , ID_REVIT_FILE_OPEN"
	Jrn.Data "FileOpenSubDialog" , "DetachCheckBox", "True"
	Jrn.Data "TaskDialogResult"  , "Detaching this file will create an independent file and you will be unable to synchronize your changes with the original central file. Are you sure you want to detach this file?",  "Yes", 6
	Jrn.Data "File Name" , "IDOK", "%FolderCentral%\%CENTRALFILE%"    
	Jrn.Data "WorksetConfig" , "Custom", 0
	), %JournPath%detach.txt
	}
	Else
	{
	FileAppend,
	(
	'
	Set Jrn = CrsJournalScript
	Jrn.Command "Internal" , "Open an existing project , ID_REVIT_FILE_OPEN"
	Jrn.Data "FileOpenSubDialog" , "DetachCheckBox", "True"
	Jrn.Data "MessageBox" , "IDOK", "Detaching creates an independent file and prohibits saving any changes back to the original Central File."
	Jrn.Data "File Name" , "IDOK", "%FolderCentral%\%CENTRALFILE%"   
	Jrn.Data "WorksetConfig" , "Custom", 0
	), %JournPath%detach.txt
	}

; Open Revit Discipline 20XX and open a detached copy
    Run %AppPath%Revit.exe "%JournPath%detach.txt",,max
    Goto, SPLASHSCREEN
}

;---#### If the shortcut has the "WORKSETS" switch, we run this portion

If 3 = WORKSETS
{
FileDelete, %JournPath%select_ws.txt

; Now we create the journal so Revit will prompt us to open select worksets

	FileAppend,
	(
	'
	Set Jrn = CrsJournalScript
	Jrn.Command "Menu" , "Open an existing project , 57601 , ID_REVIT_FILE_OPEN"
	Jrn.Data "File Name"  _
	, "IDOK", "%DESTINATION%%LOCALFILE%"
	Jrn.Data "WorksetConfig"  _
	, "Editable", 0
	  Jrn.Data "MessageBox"  _
			  , "IDOK", "This Central File has been copied or moved from ""%FolderCentral%\%CENTRALFILE%"" to ""%DESTINATION%%LOCALFILE%""." & vbCrLf & "" & vbCrLf & "If you wish this file to remain a Central File then you must re-save the file as a Central File. To do this select ""Save As"" from the ""File"" menu and check the ""Make this a Central File after save"" check box (under the options button) before you save." & vbCrLf & "" & vbCrLf & "If you do not save the file as a Central File then it will be considered a local user copy of the file belonging to user ""%Username%""."
	Jrn.Command "Menu" , "Workset control , 33460 , ID_SETTINGS_PARTITIONS"
	), %JournPath%select_ws.txt

; Open Revit Discipline 20XX and open the file; worksets dialog pops up at the end
    Run %AppPath%Revit.exe "%JournPath%select_ws.txt",,max
    Goto, SPLASHSCREEN
}

;---#### If the shortcut has an invalid or no switch, we open local as usual

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
    Run %AppPath%Revit.exe "%DESTINATION%%LOCALFILE%",,max
    Goto, SPLASHSCREEN
}


;---#### The following is the animated Splash Screen that shows up when opening a Revit session.
;---#### It will disappear once the Revit splash screen appears.

SPLASHSCREEN:

If 3 = DETACH
	{
	MSG = Opening Detached Copy of [%LOCALFILE%]`nPlease Wait...
	}
	else if 3 = WORKSETS
	{
	MSG = Opening [%LOCALFILE%] with Specify Worksets option`nPlease wait...
	}
	else
	{					
	MSG = Opening [%LOCALFILE%]`nPlease wait...
	}


Progress,A b1 FM20 CT933993 CB933993 CW000000 ZX50 ZY30 W450 WM1000 WS600 r0-50, %MSG% , Launching`nRevit %Discipline% %VERSION%

L=0
X=1

	#Persistent
	SetTimer, SplashCheck, 1000

Loop
	{
   		L := L+X
   		Progress, %L%
   		Sleep, 1

		if (L = 50 or L = 0)
		{
        	X := X*(-1)
		}
		If L<0
		Break
	}

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

Return

FINISHUP:

;---#### Dismiss the dialog that comes up to warn you that this is a copy of the Central bla bla bla....

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
GuiEscape:
GuiClose:
ExitApp