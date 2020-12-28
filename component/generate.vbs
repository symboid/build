
dim Shell, Fs
set Shell = WScript.CreateObject("WScript.Shell")
set Fs = WScript.CreateObject("Scripting.FileSystemObject")
const ForReading = 1

function RepoRevList(RepoHome,RevListParams)
	set GitShell = WScript.CreateObject("WScript.Shell")
        GitShell.CurrentDirectory = RepoHome
        RepoRevList = GitShell.Exec("git rev-list " & RevListParams).StdOut.ReadLine()
end function

function RepoRevId(RepoHome)
        RepoRevId = RepoRevList(RepoHome, "--max-count=1 HEAD")
end function

function RepoRevNum(RepoHome)
        RepoRevNum = RepoRevList(RepoHome, "--count HEAD")
end function

ScriptDir = Fs.GetParentFolderName(WScript.ScriptFullName)

if WScript.Arguments.Count < 1 then
	WScript.Echo "!!! Component name must be specified! Exiting..."
	WScript.Quit 1
end if

QtVerString=""
if WScript.Arguments.Count >= 2 then
	QtVerString = WScript.Arguments(1)
end if

ComponentName = WScript.Arguments(0)
ComponentHome = Fs.GetAbsolutePathName(ScriptDir & "\..\..\" & ComponentName)
ComponentRevNum = RepoRevNum(ComponentHome)
ComponentRevId  = RepoRevId(ComponentHome)

WScript.Echo "Component Name    : " & ComponentName
WScript.Echo "Component Home    : " & ComponentHome
WScript.Echo "Component Rev Num : " & ComponentRevNum
WScript.Echo "Component Rev Id  : " & ComponentRevId

SdkHome = Fs.GetAbsolutePathName(ScriptDir & "\..\..\..\sdk")
SdkRevId  = RepoRevId(SdkHome)
WScript.Echo "SDK Rev Id        : " & SdkRevId

'''QdkHome = Fs.GetAbsolutePathName(ScriptDir & "\..\..\..\qdk")
'''QdkRevId  = RepoRevId(QdkHome)
'''WScript.Echo "QDK Rev Id        : " & QdkRevId

ComponentRevNum = Replace(ComponentRevNum, "+", ".")

' build time properties
Function LPad (str, pad, length)
    LPad = String(length - Len(str), pad) & str
End Function
ComponentBuildTimestamp = DateDiff("s", "01/01/1970 00:00:00", Now)
ComponentNow = DateAdd("s", ComponentBuildTimestamp, "01/01/1970 00:00:00")
ComponentBuildDate = Year(ComponentNow) & "." & LPad(Month(ComponentNow), "0", 2) & "." & LPad(Day(ComponentNow), "0", 2)

WScript.Echo "Build timestamp   : " & ComponentBuildTimestamp & " (" & ComponentBuildDate & ")"

ComponentIni = ComponentHome & "\component.ini"
if Fs.FileExists(ComponentIni) then
	dim IniFile
	set IniFile = Fs.OpenTextFile(ComponentIni,ForReading)
	do while IniFile.AtEndOfStream <> true
		VarAssign = IniFile.ReadLine
		if InStr(VarAssign, "#") <> 1 then
			ExecuteGlobal VarAssign
		end if
	loop
	set InfoIni = nothing
else
	WScript.Echo "!!! Component config file '" & ComponentIni & "' cannot be found!"
	WScript.Quit 1
end if

COMPONENT_DEPS = Replace(COMPONENT_DEPS, ",", """, """)
' setting exact component id of qtre (with version)
COMPONENT_DEPS = Replace(COMPONENT_DEPS, "qtre", "qtre" & QtVerString)
if COMPONENT_DEPS <> "" then
    COMPONENT_DEPS = """" & COMPONENT_DEPS & """"
end if

' component serial number is the vcs revision number
ComponentVerSerial = ComponentRevNum
ComponentVerString = COMPONENT_VER_MAJOR & "." & COMPONENT_VER_MINOR & "." & COMPONENT_VER_PATCH & "." & ComponentVerSerial

ComponentJsonPath = ComponentHome & "\component.json"
dim ComponentJson
set ComponentJson = Fs.CreateTextFile(ComponentJsonPath, true)
ComponentJson.WriteLine "{"
ComponentJson.WriteLine vbTab & """component"": {"
ComponentJson.WriteLine vbTab & vbTab & """id"": """ & COMPONENT_ID & ""","
ComponentJson.WriteLine vbTab & vbTab & """title"": """ & COMPONENT_TITLE & ""","
ComponentJson.WriteLine vbTab & vbTab & """swid"": " & COMPONENT_SWID & ","
ComponentJson.WriteLine vbTab & vbTab & """revision"": {"
ComponentJson.WriteLine vbTab & vbTab & vbTab & """num"": " & ComponentRevNum & ","
ComponentJson.WriteLine vbTab & vbTab & vbTab & """id"": """ & ComponentRevId & ""","
if InStr(COMPONENT_DEPS, "qdk") then
ComponentJson.WriteLine vbTab & vbTab & vbTab & """qdk"": """ & QdkRevId & ""","
end if
ComponentJson.WriteLine vbTab & vbTab & vbTab & """sdk"": """ & SdkRevId & """"
ComponentJson.WriteLine vbTab & vbTab & "},"
ComponentJson.WriteLine vbTab & vbTab & """version"": {"
ComponentJson.WriteLine vbTab & vbTab & vbTab & """major"": " & COMPONENT_VER_MAJOR & ","
ComponentJson.WriteLine vbTab & vbTab & vbTab & """minor"": " & COMPONENT_VER_MINOR & ","
ComponentJson.WriteLine vbTab & vbTab & vbTab & """patch"": " & COMPONENT_VER_PATCH & ","
ComponentJson.WriteLine vbTab & vbTab & vbTab & """serial"": " & ComponentVerSerial & ","
if QtVerString <> "" then
ComponentJson.WriteLine vbTab & vbTab & vbTab & """qt"": """ & QtVerString & ""","
end if
ComponentJson.WriteLine vbTab & vbTab & vbTab & """string"": """ & ComponentVerString & """"
ComponentJson.WriteLine vbTab & vbTab & "},"
if COMPONENT_LAUNCH_MODULE <> "" then
ComponentJson.WriteLine vbTab & vbTab & """launch_module"": """ & COMPONENT_LAUNCH_MODULE & ""","
end if
if COMPONENT_EULA_VERSION <> "" then
ComponentJson.WriteLine vbTab & vbTab & """eula_version"": " & COMPONENT_EULA_VERSION & ","
end if
ComponentJson.WriteLine vbTab & vbTab & """deps"": [ " & COMPONENT_DEPS & " ],"
ComponentJson.WriteLine vbTab & vbTab & """build"": {"
ComponentJson.WriteLine vbTab & vbTab & vbTab & """timestamp"": " & ComponentBuildTimestamp & ","
ComponentJson.WriteLine vbTab & vbTab & vbTab & """date"": """ & ComponentBuildDate & """"
ComponentJson.WriteLine vbTab & vbTab & "}"
ComponentJson.WriteLine vbTab & "}"
ComponentJson.WriteLine "}"
ComponentJson.Close
set ComponentJson = nothing
WScript.Echo "Property file '" & ComponentJsonPath & "' generated."

ComponentHeaderPath = ComponentHome & "\component.h"
dim ComponentHeader
set ComponentHeader = Fs.CreateTextFile(ComponentHeaderPath, true)
ComponentHeaderGuard = "__SYMBOID_" & UCase(COMPONENT_ID) & "_COMPONENT_H__"
ComponentHeader.WriteLine "#ifndef " & ComponentHeaderGuard
ComponentHeader.WriteLine "#define " & ComponentHeaderGuard
ComponentHeader.WriteLine ""
ComponentHeader.WriteLine "#define COMPONENT_NAME """ & COMPONENT_ID & """"
ComponentHeader.WriteLine "#define COMPONENT_SWID " & COMPONENT_SWID
ComponentHeader.WriteLine "#define COMPONENT_TITLE """ & COMPONENT_TITLE & """"
ComponentHeader.WriteLine ""
ComponentHeader.WriteLine "#define COMPONENT_REV_NUM " & ComponentRevNum
ComponentHeader.WriteLine "#define COMPONENT_REV_ID """ & ComponentRevId & """"
if InStr(COMPONENT_DEPS, "qdk") then
ComponentHeader.WriteLine "#define COMPONENT_REV_QDK """ & QdkRevId & """"
end if
ComponentHeader.WriteLine "#define COMPONENT_REV_SDK """ & SdkRevId & """"
ComponentHeader.WriteLine ""
ComponentHeader.WriteLine "#define COMPONENT_VER_MAJOR " & COMPONENT_VER_MAJOR
ComponentHeader.WriteLine "#define COMPONENT_VER_MINOR " & COMPONENT_VER_MINOR
ComponentHeader.WriteLine "#define COMPONENT_VER_PATCH " & COMPONENT_VER_PATCH
ComponentHeader.WriteLine "#define COMPONENT_VER_SERIAL " & Replace(ComponentVerSerial, ".", "")
if QtVerString <> "" then
ComponentHeader.WriteLine "#define COMPONENT_VER_QT """ & QtVerString & """"
end if
ComponentHeader.WriteLine "#define COMPONENT_VER_STRING """ & ComponentVerString & """"
ComponentHeader.WriteLine ""
if COMPONENT_LAUNCH_MODULE <> "" then
ComponentHeader.WriteLine "#define COMPONENT_LAUNCH_MODULE """ & COMPONENT_LAUNCH_MODULE & """"
ComponentHeader.WriteLine ""
end if
if COMPONENT_EULA_VERSION <> "" then
ComponentHeader.WriteLine "#define COMPONENT_EULA_VERSION " & COMPONENT_EULA_VERSION
ComponentHeader.WriteLine ""
end if
ComponentHeader.WriteLine "#define COMPONENT_DEPS { " & COMPONENT_DEPS & " }"
ComponentHeader.WriteLine ""
ComponentHeader.WriteLine "#define COMPONENT_BUILD_TIMESTAMP " & ComponentBuildTimestamp
ComponentHeader.WriteLine "#define COMPONENT_BUILD_DATE """ & ComponentBuildDate & """"
ComponentHeader.WriteLine ""
ComponentHeader.WriteLine "#endif // " & ComponentHeaderGuard
ComponentHeader.Close
set ComponentHeader = nothing
WScript.Echo "Header file '" & ComponentHeaderPath & "' generated."
