;Dim output
Loop Files, C:\ProgramData\Autodesk\CLM\LGS\LGS.data, R  ; Recurse into subfolders.
{
;    MsgBox, 4, , Filename = %A_LoopFileFullPath%`n`nContinue?
	FileRead, output, %A_LoopFileFullPath%
    FileAppend,
	(
	%A_LoopFileFullPath%		%output%	%A_UserName% 

	), \\dcfs\projects\W3334 Palisades Recreation Center\Drawings\Void\lgsdatacollect.txt

}
MsgBox, Thanks! - Tell Timon it's done.
Exit