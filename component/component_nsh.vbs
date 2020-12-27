
dim Shell, Fs
set Shell = WScript.CreateObject("WScript.Shell")
set Fs = WScript.CreateObject("Scripting.FileSystemObject")
const ForReading = 1

ScriptDir = Fs.GetParentFolderName(WScript.ScriptFullName)

if WScript.Arguments.Count < 1 then
	WScript.Echo "!!! Component name must be specified! Exiting..."
	WScript.Quit 1
end if

ComponentName = WScript.Arguments(0)
ComponentHome = Fs.GetAbsolutePathName(ScriptDir & "\..\..\..\" & ComponentName)

ComponentHPath = ComponentHome & "\component.h"
ComponentNshPath = ComponentHome & "\component.nsh"

if Fs.FileExists(ComponentHPath) then
	dim ComponentH, ComponentNsh
	set ComponentH = Fs.OpenTextFile(ComponentHPath, ForReading)
	set ComponentNsh = Fs.CreateTextFile(ComponentNshPath, true)
	' reading each line
	do while ComponentH.AtEndOfStream <> true
		InputLine = ComponentH.ReadLine
		' skipping COMPONENT_DEPS declaration (due to { } )
		if InStr(InputLine, "COMPONENT_DEPS") = 0 then
			' transform preprocessor signs:
			OutputLine = Replace(InputLine, "#", "!")
			' transform comment sign
			OutputLine = Replace(OutputLine, "//", ";")
			ComponentNsh.WriteLine OutputLine
		end if
	loop
	set ComponentH = nothing
	set ComponentNsh = nothing
	
	WScript.Echo "NSI header '" & ComponentNshPath & "' created."
else
	WScript.StdErr.WriteLine("Error: Component header '" & ComponentHPath & "' cannot be found!")
end if
