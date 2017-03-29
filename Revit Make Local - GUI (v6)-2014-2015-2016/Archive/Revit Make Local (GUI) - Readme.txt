Program/Script by David Baldacchino (04/16/2010)

HOW DO I USE THIS?
------------------

a) Place the contents of all 3 files somewhere on the local or network drive. Launch "Revit Make Local.exe".

b) Click on "Go to Central File Folder" and navigate to the Central File Folder. Click Ok.

c) The list box will show any number of files in the chosen folder named according to the convention below:

   XXXXX-#VV-central.rvt, where:

   XXXXX can be anything of any length
   # is the discipline (A, S or MEP, where the 3 letters in MEP can be expressed in any order)
   VV is the Revit version number
   The dashes can be any character.

d) Right click on one of the central files and pick from the following: Create Local & Open; Create Local & Specify Worksets to open; Open a Detached Local copy.
   Notice the bolded entry; that is the default option which can be invoked by simply double clicking a central file (the default can be changed in settings.ini).

e) By default, a unique shortcut is created on your desktop with a suffix showing what that shortcut will do next time it is invoked (OPEN, WORKSETS, DETACH). A tool tip is also
   available when you hover over the shortcut. If you don't want a shortcut created (not recommended), you can uncheck "Add Desktop Shortcut" before selecting a launching option.

f) The program will now check if the required local file is already running and if so, an error dialog will be launched and the running instance is maximized.
   If everything is found as expected, a copy of the central file is made under sub-folder "XXXXX #VV" in C:\Revit Local Files (this can be changed in settings.ini),
   named "XXXX #VV_username.rvt", where username is the windows log-on username.

g) If Revit is not open, a new Revit session will be launched and the local file is opened. The Revit "flavor" is determined from the file naming (discipline designator per
   above). If the correct flavor is not installed, you will be asked if you want to use another Revit flavor to open the file. An informative and animated splash screen will
   be displayed until the Revit Splash Screen appears (Revit splashscreen used to take ages to show up in older versions and this was done to give the user some feedback).

h) If the required Revit flavor is already running, the local file will open in the same session.

i) The Revit Build is checked (if the Detach option is used, build checking is skipped) and this information, machine name and project information is written to projects.ini.
   If any machine belonging to a team member is on an older build, a customized warning is issued. Once the machine is upgraded, the warning goes away automatically.

j) Next time the user needs to launch a local for the same project, the desktop shortcut is used instead. Some of the above checks are still performed. If the central file is
   not found, the shortcut is deleted, a warning is issued and the GUI pops up on the screen. The user now goes through the above steps once again.


ADVANCED FEATURES
-----------------

You can edit settings.ini to change paths and defaults as needed.

***********************************************************************

		   K N O W N   I S S U E S

***********************************************************************

The following scenario is the only known issue: You have one local file open (ex: mylocal A11_username.rvt), which you then closed. Revit is still open with or without
the Recent Files page and you launch the shortcut to create a new local (or run the GUI to select the central for the same project). The program will issue a warning stating
that mylocal A11_username.rvt is already open and the running instance will be activated. Currently there is no fix for this. You need to either close Revit completely or start
a new project and then launch the shortcut or program once again. Note that if you try to create a local file for a project other than last one opened, this issue will not occur.


***********************************************************************

		V E R S I O N   H I S T O R Y

***********************************************************************


#### Version 1 - 08/10/2007

#### Version 2 - 03/01/2008

a) Program now creates project folders named XXXXX #VV (see 1 for explanation) in C:\Revit Local Files\
b) Implemented "Command Line Parameters" (similar to switches) in shortcuts to instruct the script to either just open the local file, or open a detached copy, or specify
   the worksets to open.
c) Custom icon added.

#### Version 3 - 03/30/2008

a) Check for Revit build between users for the same project. Warn users that are using a build# other than what was used to create the first local file using this
   program.
b) Revit will now always open maximized.
c) Check if Revit is already open with a local version of the same project, belonging to the user that is running the script. If so, Revit issues a warning and stops running.
d) Program will now launch any Revit version and flavor from 2008 onwards (until Autodesk changes the naming again!).
e) Added animated splash screen which appears while a Revit session is opened. This goes away once the Revit splash screen appears.

#### Version 4 - 05/08/2009

a) Compatible with 2010 (32 & 64 bit) and works all the way to 2009 (32 & 64 bit) and 2008.
b) Adjusted some of the logic so now when creating a Detached copy, the central is not copied to the C drive. You can also create a detached copy of a project while a local
   file for the same project is still running. This wasn't possible before.
c) The script ends properly and the splashscreen should not persist after it finishes.

#### Version 5 - 04/16/2010

a) Application can now be centralized on a local or network drive.
b) Introduced GUI that automatically handles shortcut creation on user's desktop.
c) Pulled out paths and defaults into settings.ini, making it customizable by other users (including branding).
d) Overhauled build checking routine. Projects.ini can be written to a centralized location and holds project info., team's latest build and machine name's status (OK or UPGRADE).
e) Tested on Vista Enterprise 64 bit with Revit 2009, 2010 and 2011, but should (in theory) work also with Revit 2008 and future releases (add/edit install paths in settings.ini)

------------------------------------------------------------------------------------------