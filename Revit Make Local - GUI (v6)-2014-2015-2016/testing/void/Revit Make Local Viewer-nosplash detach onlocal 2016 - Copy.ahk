FileDelete C:\Revit Local Files\detachedopen.txt

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
	Jrn.Command "StartupPage" , "Open an existing project , ID_REVIT_FILE_OPEN"
	Jrn.Data "FileOpenSubDialog" , "OpenAsLocalCheckBox", "True"
	Jrn.Data "FileOpenSubDialog" , "DetachCheckBox", "True"
	Jrn.Data "FileOpenSubDialog" , "OpenAsLocalCheckBox", "False" 
	Jrn.Data "File Name" , "IDOK", "P:\W3334 Palisades Recreation Center\Drawings\Void\Wxxxx-S17-Central.rvt"
	Jrn.Data "WorksetConfig" , "Custom", 0
	Jrn.Data "TaskDialogResult" , "Detaching this model will create an independent model. You will be unable to synchronize your changes with the original central model." & vbLf & "What do you want to do?", "Detach and preserve worksets", "1001"
	), C:\Revit Local Files\detachedopen.txt

; Open Revit Discipline 20XX and open a detached copy
;    Run C:\Program Files\Autodesk\Revit 2017\Revit.exe "N:\Revit\Revit Development\Revit Create Local File Script\Revit Make Local - GUI (v6)-2014-2015-2016\testing\Working Detach Open Min.txt",,max
;    Goto, SPLASHSCREEN

; Open Revit Discipline 20XX and open a detached copy
;   Run C:\Program Files\Autodesk\Revit 2017\Revit.exe "C:\Revit Local Files\detachedopen.txt",,max
