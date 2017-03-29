outputcombined  = 
Loop Files, C:\ProgramData\Autodesk\CLM\LGS\LGS.data, R  ; Recurse into subfolders.
{
	FileRead, output, %A_LoopFileFullPath%
	outputcombined = %outputcombined%%output%
}
ifInString, outputcombined, _NETWORK 
{
MsgBox, %outputcombined% : Network license found
}
ifNotInString, outputcombined, _NETWORK 
{
MsgBox, %outputcombined% : No network license found
}
Exit