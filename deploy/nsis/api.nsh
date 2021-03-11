
!ifndef __SYMBOID_SDK_BUILD_DEPLOY_API_NSH__
!define __SYMBOID_SDK_BUILD_DEPLOY_API_NSH__

!addincludedir ${__FILEDIR__}

!include config.nsh
!include arch.nsh
!include echo.nsh
!include component_props.nsh
!include MUI2.nsh

!macro ComponentApiBegin _ComponentName

	!insertmacro SetupComponentProps ${_ComponentName}
	
	!define _ApiInstallerExe "${PackageDir}\${COMPONENT_NAME}-api-win_${BuildArch}.exe"
	!define _ApiUninstallerExe "${COMPONENT_NAME}-api-uninst.exe"
	
	Name "${COMPONENT_TITLE}"
	OutFile "${_ApiInstallerExe}"
;	InstallDir "${_InstFolder}"
	RequestExecutionLevel user
	
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_LANGUAGE "English"
	
	Section "Write Uninst"
		SetOutPath "$INSTDIR"
		WriteUninstaller "${_ApiUninstallerExe}"
	SectionEnd

	Section "Un.Write Uninst"
		Delete "$INSTDIR\${_ApiUninstallerExe}"
		RMDir "$INSTDIR"
	SectionEnd
	
	!undef _ApiInstallerExe
	
!macroend

!macro FileApi _RelFolderPath _FileName

	Section "Deploy ${_RelFolderPath}\${_FileName} API"
		SetOutPath "$INSTDIR\${COMPONENT_NAME}\${_RelFolderPath}"
		File  "${RootDir}\${COMPONENT_NAME}\${_RelFolderPath}\${_FileName}"
	SectionEnd
	
	Section "Un.Deploy ${_RelFolderPath}\${_FileName} API"
		RMDir /r "$INSTDIR\${COMPONENT_NAME}\${_RelFolderPath}"
		RMDir  "$INSTDIR\${COMPONENT_NAME}"
		RMDir  "$INSTDIR"
	SectionEnd

!macroend

!macro FolderApi _FolderName _FileFilter

	Section "Deploy ${_FolderName} API"
		SetOutPath "$INSTDIR\${COMPONENT_NAME}\${_FolderName}"
		File /r  "${RootDir}\${COMPONENT_NAME}\${_FolderName}\${_FileFilter}"
	SectionEnd
	
	Section "Un.Deploy ${_FolderName} API"
		RMDir /r "$INSTDIR\${COMPONENT_NAME}\${_FolderName}"
		RMDir    "$INSTDIR\${COMPONENT_NAME}"
		RMDir    "$INSTDIR"
	SectionEnd
	
!macroend

!macro ModuleApi _ModuleName
	
	!insertmacro FolderApi ${_ModuleName} *.h
	
	!define _ModuleBasename "${COMPONENT_NAME}-${_ModuleName}"
	
	Section "Deploy ${_ModuleName} Binary"
		SetOutPath "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}"
		File "${BuildDir}\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.dll"
		File "${BuildDir}\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.lib"
!if `${BuildConfig}` == `debug`
		File "${BuildDir}\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.pdb"
!endif
	SectionEnd
	
	Section "Un.Deploy ${_ModuleName} Binary"
		Delete "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.dll"
		Delete "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.lib"
!if `${BuildConfig}` == `debug`
		Delete "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.pdb"
!endif
		RMDir  "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}"
		RMDir  "$INSTDIR\${COMPONENT_NAME}"
		RMDir  "$INSTDIR"
	SectionEnd
	
	!undef _ModuleBasename
	
!macroend


!macro ExeFolder _ModuleName
	
	!define _ModuleBasename "${COMPONENT_NAME}-${_ModuleName}"
	
	Section "Deploy ${_ModuleName} Binary"
		SetOutPath "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}"
		File "${BuildDir}\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.exe"
!if `${BuildConfig}` == `debug`
		File "${BuildDir}\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.pdb"
!endif
	SectionEnd
	
	Section "Un.Deploy ${_ModuleName} Binary"
		Delete "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.exe"
!if `${BuildConfig}` == `debug`
		Delete "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}\${_ModuleBasename}.pdb"
!endif
		RMDir  "$INSTDIR\${COMPONENT_NAME}\${_ModuleName}"
		RMDir  "$INSTDIR\${COMPONENT_NAME}"
		RMDir  "$INSTDIR"
	SectionEnd
	
	!undef _ModuleBasename
	
!macroend

!endif ; __SYMBOID_SDK_BUILD_DEPLOY_API_NSH__
