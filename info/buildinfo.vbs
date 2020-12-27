
dim Shell, Fs
set Shell = WScript.CreateObject("WScript.Shell")
set Fs = WScript.CreateObject("Scripting.FileSystemObject")
const ForReading = 1

' application directory = where the script has been called from:
AppHome = Shell.CurrentDirectory

' Getting SDK home directory: parent-parent of script directory
function GetSdkHome()
	ScriptDir = Fs.GetParentFolderName(WScript.ScriptFullName)
	GetSdkHome = Fs.GetParentFolderName(Fs.GetParentFolderName(ScriptDir))
end function

' Querying vcs revision of SDK:
function GetRepoRev(RepoHome)
	dim VcsProcess
	CWD = Shell.CurrentDirectory
	Shell.CurrentDirectory = RepoHome
	set VcsProcess = Shell.Exec("hg id -n -r .")
	if VcsProcess.Status = 0 then
		GetRepoRev = VcsProcess.StdOut.ReadLine()
	end if
	Shell.CurrentDirectory = CWD
	set VcsProcess = nothing
end function

sub TransformInfoIni(InfoIniPath, MacroPrefix, OutputH)
	' open appinfo.ini
	if Fs.FileExists(InfoIniPath) then
		dim InfoIni
		set InfoIni = Fs.OpenTextFile(InfoIniPath, ForReading)
		' reading each line
		do while InfoIni.AtEndOfStream <> true
			InputLine = InfoIni.ReadLine
			' transform comment signs:
			InputLine = Replace(InputLine, ";", "//")
			' trimming leading white spaces:
			InputLine = LTrim(InputLine)
			' transforming declaration line:
			if InStr(InputLine, "//") = 1 then
				OutputLine = InputLine
			else
				SepPos = InStr(InputLine, "=")
				if SepPos <> 0 then
					OutputLine = "#define " & MacroPrefix & UCase(Left(InputLine, SepPos - 1)) & " " & Right(InputLine, Len(InputLine) - SepPos)
				else
					OutputLine = InputLine
				end if
			end if
			OutputH.WriteLine OutputLine
		loop
		set InfoIni = nothing
	else
		WScript.StdErr.WriteLine("Error: Info ini file '" & InfoIniPath & "' cannot be found!")
	end if
end sub

sub CreateHeader(RawHeaderPath)
	if Fs.FileExists(RawHeaderPath) then
		ContentChanged = false
		
		HeaderPath = RawHeaderPath & ".h"
		if Fs.FileExists(HeaderPath) then
			' reading raw file content:
			dim RawHeaderFile
			set RawHeaderFile = Fs.OpenTextFile(RawHeaderPath, ForReading)
			RawHeaderText = RawHeaderFile.ReadAll
			' reading target file content:
			dim HeaderFile
			set HeaderFile = Fs.OpenTextFile(HeaderPath, ForReading)
			HeaderText = HeaderFile.ReadAll
			' comparing content:
			if RawHeaderText <> HeaderText then
				ContentChanged = true
			end if
                        set HeaderFile = nothing
                        set RawHeaderFile = nothing
		else
			ContentChanged = true
		end if
		
		if ContentChanged then
			Fs.CopyFile RawHeaderPath, HeaderPath
			WScript.Echo "Header file '" & HeaderPath & "' generated."
		end if
	else
		WScript.Echo "Raw header file " & RawHeaderPath & " not found!"
	end if
end sub

SdkHome = GetSdkHome

' Outputting SDK revision:
SdkRev = 1000 'GetRepoRev(SdkHome)
WScript.Echo "SDK Home : " & SdkHome
WScript.Echo "SDK Rev  : " & SdkRev

' Outputting App revision:
AppRev = GetRepoRev(AppHome)
WScript.Echo "App Home : " & AppHome
WScript.Echo "App Rev  : " & AppRev

dim CodeRevIni
set CodeRevIni = Fs.CreateTextFile(AppHome & "\coderev.ini", true)
CodeRevIni.WriteLine("")
CodeRevIni.WriteLine("; code revision info:")
CodeRevIni.WriteLine("sdk_repo_rev=" &SdkRev)
CodeRevIni.WriteLine("app_repo_rev=" &AppRev)
CodeRevIni.WriteLine("app_serial_num=" &(CLng(SdkRev)+CLng(AppRev)))
CodeRevIni.WriteLine("")
CodeRevIni.Close
set CodeRevIni = nothing
WScript.Echo "Info file 'coderev.ini' generated."

' Writing app info header:
dim AppInfoH
set AppInfoH = Fs.CreateTextFile(AppHome & "\appinfo", true)
AppInfoH.WriteLine("")
AppInfoH.WriteLine("#ifndef __APPINFO_H__")
AppInfoH.WriteLine("#define __APPINFO_H__")
AppInfoH.WriteLine("")
TransformInfoIni AppHome & "\appinfo.ini", "APP_", AppInfoH
TransformInfoIni AppHome & "\coderev.ini", "", AppInfoH
AppInfoH.WriteLine("#endif // __APPINFO_H__")
AppInfoH.Close
set AppInfoH = nothing
CreateHeader AppHome & "\appinfo"

' Writing build info header:
dim BuildInfoH
set BuildInfoH = Fs.CreateTextFile(AppHome & "\buildinfo", true)
BuildInfoH.WriteLine("")
BuildInfoH.WriteLine("#ifndef __BUILDINFO_H__")
BuildInfoH.WriteLine("#define __BUILDINFO_H__")
BuildInfoH.WriteLine("")
BuildInfoH.WriteLine("#include ""appinfo.h"" ")
BuildInfoH.WriteLine("#include ""hosting/mod/sysabout.h"" ")
BuildInfoH.WriteLine("")
BuildInfoH.WriteLine("class AppBuildInfo : public Sh::BuildInfo")
BuildInfoH.WriteLine("{")
BuildInfoH.WriteLine("public:")
BuildInfoH.WriteLine("    virtual int serialNumber() const override")
BuildInfoH.WriteLine("    {")
BuildInfoH.WriteLine("        return APP_SERIAL_NUM;")
BuildInfoH.WriteLine("    }")
BuildInfoH.WriteLine("    virtual SyLiteral appShortId() const override")
BuildInfoH.WriteLine("    {")
BuildInfoH.WriteLine("        return SyLiteral(APP_SHORT_ID);")
BuildInfoH.WriteLine("    }")
BuildInfoH.WriteLine("    virtual SyLiteral appPublisher() const override")
BuildInfoH.WriteLine("    {")
BuildInfoH.WriteLine("        return SyLiteral(APP_PUBLISHER);")
BuildInfoH.WriteLine("    }")
BuildInfoH.WriteLine("    virtual SyLiteral appShortTitle() const override")
BuildInfoH.WriteLine("    {")
BuildInfoH.WriteLine("        return SyLiteral(APP_SHORT_TITLE);")
BuildInfoH.WriteLine("    }")
BuildInfoH.WriteLine("    virtual SyLiteral appLongTitle() const override")
BuildInfoH.WriteLine("    {")
BuildInfoH.WriteLine("        return SyLiteral(APP_LONG_TITLE);")
BuildInfoH.WriteLine("    }")
BuildInfoH.WriteLine("    virtual int appMajorVer() const override")
BuildInfoH.WriteLine("    {")
BuildInfoH.WriteLine("        return APP_MAJOR_VER;")
BuildInfoH.WriteLine("    }")
BuildInfoH.WriteLine("    virtual int appMinorVer() const override")
BuildInfoH.WriteLine("    {")
BuildInfoH.WriteLine("        return APP_MINOR_VER;")
BuildInfoH.WriteLine("    }")
BuildInfoH.WriteLine("    virtual int appPatchVer() const override")
BuildInfoH.WriteLine("    {")
BuildInfoH.WriteLine("        return APP_PATCH_VER;")
BuildInfoH.WriteLine("    }")
BuildInfoH.WriteLine("};")
BuildInfoH.WriteLine("")
BuildInfoH.WriteLine("#endif // __BUILDINFO_H__")
BuildInfoH.Close
set BuildInfoH = nothing
CreateHeader AppHome & "\buildinfo"
