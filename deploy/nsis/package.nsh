
!ifndef __SYMBOID_SDK_BUILD_DEPLOY_PACKAGE_NSH__
!define __SYMBOID_SDK_BUILD_DEPLOY_PACKAGE_NSH__

!addincludedir ${__FILEDIR__}

!include config.nsh
!include arch.nsh
!include component_props.nsh
!include MUI2.nsh
!include links.nsh
!include echo.nsh
!include qt.nsh
!include crt.nsh
!include FileFunc.nsh
!include module.nsh

BrandingText "www.symboid.com"

!macro PackageCommonPages

!ifdef COMPONENT_EULA_VERSION
Function RegEulaVersion
	WriteRegDWORD HKCU "Software\Symboid\Components\${COMPONENT_NAME}" "eula_version" "${COMPONENT_EULA_VERSION}"
FunctionEnd
	!define MUI_PAGE_CUSTOMFUNCTION_LEAVE RegEulaVersion
	!insertmacro MUI_PAGE_LICENSE "${RootDir}\${COMPONENT_NAME}\deploy\eula.rtf"
!endif
!ifdef _Config_Components
	!insertmacro MUI_PAGE_COMPONENTS
!endif
Function PurgeIfExists
!ifdef PurgingExistingInstance
	; purging existing instance of component if specified
	IfFileExists "$INSTDIR\${PackageUninstallerExe}" 0 skip_purge_existing
	!insertmacro ExecUninstaller "$INSTDIR\${PackageUninstallerExe}"
	skip_purge_existing:
!endif
FunctionEnd
	!define MUI_PAGE_CUSTOMFUNCTION_PRE PurgeIfExists
	!insertmacro MUI_PAGE_INSTFILES

!macroend

!macro PackageTexts

	!insertmacro MUI_LANGUAGE "Hungarian"
	!insertmacro MUI_LANGUAGE "English"

	!include texts.nsh
	
!macroend

!macro ExecUninstaller _UninstallerPath
	ExecWait '${_UninstallerPath} /S --keep-reg:1' $0
	; waiting for quit of uninst process
	; or else unist process can block $INSTDIR for a little while
	Sleep 1000
	DetailPrint "${_UninstallerPath} returns: $0"
!macroend
	
!macro PackageBasics _PackageName _InstFolder

	${EchoHeader} "PACKING"
	!define PackageId ${_PackageName}

	; name of installer
	!searchreplace PackageRawName "${_PackageName}" " " "-"
	!ifndef PackageInstallerExe
	!define PackageInstallerExe "${PackageDir}\${PackageRawName}-win_${BuildArch}.exe"
	!endif
	!define PackageUninstallerExe "uninst-${PackageRawName}.exe"

	${EchoItem} "Package name         : ${_PackageName}"
	${EchoItem} "Installer exe        : ${PackageInstallerExe}"
	${EchoItem} "Installation folder  : ${_InstFolder}"

	Name "${COMPONENT_TITLE}"
	OutFile "${PackageInstallerExe}"
	InstallDir "${_InstFolder}"
	RequestExecutionLevel user

	Function .OnInit
		
		; checking for architecture compatibility
		!insertmacro Arch64Check
		
	FunctionEnd
	
!macroend

!macro PackageIcon _IconPath

	${EchoItem} "Package icon         : ${_IconPath}"

	Icon "${RootDir}\${_IconPath}"
	
!macroend

!macro RegAppPath _ExeBaseName _Path

	!define _AppPathsKey 'HKCU "Software\Microsoft\Windows\CurrentVersion\App Paths\${_ExeBaseName}"'
	
	Section "Reg AppPath ${_ExeBaseName}"
		
		WriteRegExpandStr ${_AppPathsKey} "Path" "${_Path}"
	SectionEnd
	
	Section "Un.Reg AppPath ${_ExeBaseName}"
		DeleteRegKey ${_AppPathsKey}
	SectionEnd
	
	!undef _AppPathsKey
	
!macroend

!macro PackageRegComponent _ComponentId _ComponentInstDir

	Section "Component Reg"
;		WriteRegExpandStr HKLM "Software\Symboid\Components\${_ComponentId}" "install_dir" "${_ComponentInstDir}"
	SectionEnd
	
	Section "Un.Component Reg"
;		${GetOptions} $CMDLINE "--keep-reg:" $0
;		StrCmp $0 "1" end_reg_delete
;		DeleteRegKey HKLM "Software\Symboid\Components\${_ComponentId}"
;		DeleteRegKey /ifempty HKLM "Software\Symboid\Components"
;		DeleteRegKey /ifempty HKLM "Software\Symboid"
;		end_reg_delete:
	SectionEnd
	
!macroend

!macro DeployUninstaller

	Section "Write Uninst"
		SetOutPath "$INSTDIR"
		WriteUninstaller "${PackageUninstallerExe}"
	SectionEnd

	Section "Un.Write Uninst"
		Delete "$INSTDIR\${PackageUninstallerExe}"
		RMDir "$INSTDIR"
	SectionEnd

!macroend

!macro UninstallRemovesUserData _FolderId

	!define _AppDataFolder "$LOCALAPPDATA\Symboid\${_FolderId}"
	!define _DocumentsFolder "$DOCUMENTS\${_FolderId}"

	UninstPage Custom Un.QuestionUserData Un.RemoveUserData
	
	Var RemoveAppDataCheckBox
	Var RemoveDocumentsCheckBox
	
	Var RemoveAppData
	Var RemoveDocuments
	
	Function Un.QuestionUserData
		nsDialogs::Create  /NOUNLOAD 1018
		
		; information text
		${NSD_CreateLabel} 0 10 100% 40 "$(TextCleanupOnUninstall)"
		
		; check box for AppData folder
		${NSD_CreateCheckBox} 30 60 100% 20 "$(TextRemoveAppData)"
		Pop $RemoveAppDataCheckBox
		${NSD_Check} $RemoveAppDataCheckBox
		${NSD_CreateLabel} 45 80 100% 20 "$(TextFolder): ${_AppDataFolder}\log"
		${NSD_CreateLabel} 45 100 100% 20 "$(TextFolder): ${_AppDataFolder}\cache"
		
		; check box for Documents folder
		${NSD_CreateCheckBox} 30 130 100% 20 "$(TextRemoveDocuments)"
		Pop $RemoveDocumentsCheckBox
		${NSD_UnCheck} $RemoveDocumentsCheckBox
		${NSD_CreateLabel} 45 150 100% 20 "$(TextFolder): ${_DocumentsFolder}"
		
		nsDialogs::Show
	FunctionEnd
	
	Function Un.RemoveUserData
		; removing AppData folder
		${NSD_GetState} $RemoveAppDataCheckBox $0
		${If} $0 == ${BST_CHECKED}
			StrCpy $RemoveAppData "1"
		${Endif}
		
		; removing Documents folder
		${NSD_GetState} $RemoveDocumentsCheckBox $1
		${If} $1 == ${BST_CHECKED}
			StrCpy $RemoveDocuments "1"
		${Endif}
	FunctionEnd
	
	Section "Un.CleanupUserData"
		${If} $RemoveAppData == "1"
			RMDir /r "${_AppDataFolder}\log"
			RMDir /r "${_AppDataFolder}\cache"
		${Endif}
		${If} $RemoveDocuments == "1"
			RMDir /r "${_DocumentsFolder}"
		${Endif}
	SectionEnd
	
	!undef _AppDataFolder
	!undef _DocumentsFolder
	
!macroend

!macro PackageBegin _RelFolder

	!define PurgingExistingInstance
	
	!insertmacro PackageBasics "${COMPONENT_NAME}" "$LOCALAPPDATA\Symboid\${_RelFolder}"
	!insertmacro PackageRegComponent "${COMPONENT_NAME}" "$LOCALAPPDATA\Symboid\${_RelFolder}"
	!insertmacro PackageCommonPages

	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro UninstallRemovesUserData "${_RelFolder}"
	!insertmacro MUI_UNPAGE_INSTFILES

!macroend

!macro PackageEnd
	
	!insertmacro PackageTexts
	!insertmacro DeployUninstaller

!macroend

!macro Package _RelFolder
	
	!insertmacro PackageBegin ${_RelFolder}
	!insertmacro PackageEnd

!macroend

!macro PackageWithRun _RelFolder _RunFunction

	!insertmacro PackageBegin ${_RelFolder}
	
	!define MUI_FINISHPAGE_RUN
	!define MUI_FINISHPAGE_RUN_FUNCTION ${_RunFunction}
	!define MUI_PAGE_CUSTOMFUNCTION_PRE RunAndExit
	!insertmacro MUI_PAGE_FINISH

	Function RunAndExit
		${GetOptions} $CMDLINE "--autorun:" $0
		${If} $0 == "1"
			Call ${_RunFunction}
			Quit
		${Endif}
	FunctionEnd

	!insertmacro PackageEnd

!macroend

!macro SubPackage _PackageName _AbsFolder

	!insertmacro PackageBasics "${_PackageName}" "${_AbsFolder}"
	!insertmacro PackageCommonPages

	!insertmacro PackageEnd

!macroend

!endif ; __SYMBOID_SDK_BUILD_DEPLOY_PACKAGE_NSH__
