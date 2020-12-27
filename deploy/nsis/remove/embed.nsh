
!ifndef __SYMBOID_PLATFORM_DEPLOY_EMBED_NSH__
!define __SYMBOID_PLATFORM_DEPLOY_EMBED_NSH__

!include config.nsh

!ifdef _Config_Debug
	!define EmbedBuildSwitch /D_Config_Debug
!else
	!define EmbedBuildSwitch
!endif

!define EmbedIndent "/D_Config_EchoIndent=${EchoIndent}......."
!define EmbedHideSummary "/D_Config_HideSummary"
!define EmbedToolchain "/D_Config_Toolchain=${Toolchain} /D_Config_QtVer=${QtVer}"
!define EmbedBuildDir " /D_Config_BuildDir=${BuildDir}"
!define EmbedSwitches "${EmbedBuildSwitch} ${EmbedIndent} ${EmbedHideSummary} ${EmbedToolchain} ${EmbedBuildDir}"

!macro EmbedMake _InstallerExe _InstallerNsi _InstallerSwitches

	!define _MakeSwitches "${EmbedSwitches} ${_InstallerSwitches}"
	!makensis '/V2 /D_Config_InstExe=${_InstallerExe} ${_MakeSwitches} ${_InstallerNsi}' = 0
	!undef _MakeSwitches
	
!macroend

!macro EmbedExe _Exe _OutPath

	Section "Embed ${_Exe}"
		SetOutPath "${_OutPath}"
		File "${PackageDir}\${_Exe}"
	SectionEnd
	
!ifndef _Config_LazyEmbed
	!delfile "${PackageDir}\${_Exe}"
!endif

!macroend

!macro UnEmbedExe _Exe _OutPath

	Section "Un.Embed ${_Exe}"
		Delete "${_OutPath}\${_Exe}"
		RMDir "${_OutPath}"
		RMDir "$INSTDIR"
	SectionEnd

!macroend

!macro EmbedInstaller _InstallerExe _BuildArch _InstallerNsi _InstallerSwitches

	${EchoLine}

!ifndef _Config_LazyEmbed
	!define _BuildEmbedded 1
!else if /FileExists "${RootDir}\packages\${_InstallerExe}"
	!define _BuildEmbedded 0
!else
	!define _BuildEmbedded 1
!endif

!if ${_BuildEmbedded}
	!insertmacro EmbedMake "${_InstallerExe}" "${_InstallerNsi}" "${_InstallerSwitches} /D_Config_${_BuildArch}"
!else
	${EchoItem} "Embedding package    : ${_InstallerExe}"
!endif
	!undef _BuildEmbedded

	${EchoLine}

	!define _PackagesDir "$INSTDIR\packages"

	!insertmacro EmbedExe "${_InstallerExe}" "${_PackagesDir}"
	
	Section "Exec ${_InstallerExe}"
!if `${BuildArch}` == `All`
		${If} ${RunningX64}
			StrCmp "x64" "${_BuildArch}" execInstaller purgeInstaller
		${Else}
			StrCmp "x86" "${_BuildArch}" execInstaller purgeInstaller
		${EndIf}
	execInstaller:
!endif
	
		SetOutPath "$INSTDIR"
		ExecWait '"${_PackagesDir}\${_InstallerExe}" /S' $0
		; error handling
		IntCmp $0 0 purgeInstaller
		DetailPrint "Embedded installer exit code: $0"
		MessageBox MB_OK|MB_ICONSTOP "$(MUI_TEXT_ABORT_SUBTITLE)"
		Quit
		Abort "$(MUI_TEXT_ABORT_SUBTITLE)"
		
	purgeInstaller:
		Delete "${_PackagesDir}\${_InstallerExe}"
		RMDir "${_PackagesDir}"
	SectionEnd
	
	!undef _PackagesDir
	
!macroend

!endif ; __SYMBOID_PLATFORM_DEPLOY_EMBED_NSH__
