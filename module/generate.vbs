
dim Shell, Fs
set Shell = WScript.CreateObject("WScript.Shell")
set Fs = WScript.CreateObject("Scripting.FileSystemObject")
const ForReading = 1

ScriptDir = Fs.GetParentFolderName(WScript.ScriptFullName)

if WScript.Arguments.Count < 2 then
	WScript.Echo "!!! Module name and home must be specified! Exiting..."
	WScript.Quit 1
end if

ModuleName = WScript.Arguments(0)
ModuleHome = Fs.GetAbsolutePathName(WScript.Arguments(1))
ReturnCwd = Fs.GetAbsolutePathName(".")
Shell.CurrentDirectory = ModuleHome
ComponentHome = Shell.Exec("git rev-parse --show-toplevel").StdOut.ReadLine()
ComponentName = Fs.GetBaseName(ComponentHome)
Shell.CurrentDirectory = ReturnCwd

WScript.Echo "Module Name       : " & ModuleName
WScript.Echo "Module Home       : " & ModuleHome
WScript.Echo "Component Name    : " & ComponentName
WScript.Echo "Component Home    : " & ComponentHome

ModuleHeaderPath = ModuleHome & "\module.h"

if Fs.FileExists(ModuleHeaderPath) then
	WScript.Echo "Module header '" & ModuleHeaderPath & "' found."
	WScript.Quit 0
end if

dim ModuleHeader
set ModuleHeader = Fs.CreateTextFile(ModuleHeaderPath, true)
ModuleHeaderGuard = "__SYMBOID_" & UCase(ComponentName) & "_" & UCase(Replace(ModuleName,"-","_")) & "_MODULE_H__"
ModuleHeader.WriteLine "#ifndef " & ModuleHeaderGuard
ModuleHeader.WriteLine "#define " & ModuleHeaderGuard
ModuleHeader.WriteLine ""
ModuleHeader.WriteLine "#define MODULE_NAME """ & ModuleName & """"
ModuleHeader.WriteLine "#define MODULE_PARENT_COMPONENT """ & ComponentName & """"
ModuleHeader.WriteLine "#define MODULE_DESC """ & ComponentName & "-" & ModuleName & "-module"""
ModuleHeader.WriteLine ""
ModuleHeader.WriteLine "#endif // " & ModuleHeaderGuard
ModuleHeader.Close
set ModuleHeader = nothing
WScript.Echo "Header file '" & ModuleHeaderPath & "' generated."
