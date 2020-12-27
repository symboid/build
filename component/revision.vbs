
dim Shell, Fs
set Shell = WScript.CreateObject("WScript.Shell")
set Fs = WScript.CreateObject("Scripting.FileSystemObject")
const ForReading = 1

function RepoRevId(RepoHome)
        set GitShell = WScript.CreateObject("WScript.Shell")
        GitShell.CurrentDirectory = RepoHome
        RepoRevId = GitShell.Exec("git rev-list --max-count=1 HEAD").StdOut.ReadLine()
end function

ScriptDir = Fs.GetParentFolderName(WScript.ScriptFullName)

if WScript.Arguments.Count < 1 then
	WScript.Echo "!!! Component name must be specified! Exiting..."
	WScript.Quit 1
end if

ComponentName = WScript.Arguments(0)
ComponentHome = Fs.GetAbsolutePathName(ScriptDir & "\..\..\..\" & ComponentName)
ComponentRevId = RepoRevId(ComponentHome)

RevisionStamp = ComponentHome & "\.revision.stamp"
if Fs.FileExists(RevisionStamp) then
	set TsFile = Fs.GetFile(RevisionStamp)
	TsRevId = Fs.OpenTextFile(RevisionStamp,ForReading).ReadLine()
	if TsRevId = ComponentRevId then
                WScript.Echo "No changes in component revision."
		WScript.Quit 0
	end if
end if

dim ComponentTs
set ComponentTs = Fs.CreateTextFile(RevisionStamp, true)
ComponentTs.WriteLine ComponentRevId
ComponentTs.Close
set ComponentTs = nothing
WScript.Echo "Component revision stamp '" & RevisionStamp & "' updated."
