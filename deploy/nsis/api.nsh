
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

!macro FileApi _RelFilePath

	Section "Deploy ${_RelFilePath} API"
		SetOutPath "$INSTDIR\${COMPONENT_NAME}"
		File  "${RootDir}\${COMPONENT_NAME}\${_RelFilePath}"
	SectionEnd
	
	Section "Un.Deploy ${_RelFilePath} API"
		Delete "$INSTDIR\${COMPONENT_NAME}\${_RelFilePath}"
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
		SetOutPath "$INSTDIR\${RelBuildDir}\${COMPONENT_NAME}\${_ModuleName}\${BuildConfig}"
		File "${BuildDir}\${COMPONENT_NAME}\${_ModuleName}\${BuildConfig}\${_ModuleBasename}.dll"
		File "${BuildDir}\${COMPONENT_NAME}\${_ModuleName}\${BuildConfig}\${_ModuleBasename}.lib"
!if `${BuildConfig}` == `debug`
		File "${BuildDir}\${COMPONENT_NAME}\${_ModuleName}\${BuildConfig}\${_ModuleBasename}.pdb"
!endif
	SectionEnd
	
	Section "Un.Deploy ${_ModuleName} Binary"
		Delete "$INSTDIR\${RelBuildDir}\${COMPONENT_NAME}\${_ModuleName}\${BuildConfig}\${_ModuleBasename}.dll"
		Delete "$INSTDIR\${RelBuildDir}\${COMPONENT_NAME}\${_ModuleName}\${BuildConfig}\${_ModuleBasename}.lib"
!if `${BuildConfig}` == `debug`
		Delete "$INSTDIR\${RelBuildDir}\${COMPONENT_NAME}\${_ModuleName}\${BuildConfig}\${_ModuleBasename}.pdb"
!endif
		RMDir  "$INSTDIR\${RelBuildDir}\${COMPONENT_NAME}\${_ModuleName}\${BuildConfig}"
		RMDir  "$INSTDIR\${RelBuildDir}\${COMPONENT_NAME}\${_ModuleName}"
		RMDir  "$INSTDIR\${RelBuildDir}\${COMPONENT_NAME}"
		RMDir  "$INSTDIR\${RelBuildDir}"
		RMDir  "$INSTDIR"
	SectionEnd
	
	!undef _ModuleBasename
	
!macroend

/*
!macro DeployApi _BinaryName _IncludePath

	${EchoItem} "Module API           : ${_BinaryName}"

	!define _RuntimeBinary "${InstallDir}\bin\${_BinaryName}.dll"
	!define _StaticBinary "${InstallDir}\lib\${_BinaryName}.lib"
	
!if /FileExists "${_RuntimeBinary}"
	!define _IsRuntimeModule 1
!else if /FileExists "${_StaticBinary}"
	!define _IsRuntimeModule 0
!else
	!error "Module '${_BinaryName}' not found!"
!endif
	
	Section "${_BinaryName}-API"
		; module binary
!if ${_IsRuntimeModule}
		SetOutPath "$INSTDIR\bin"
		File "${_RuntimeBinary}"
		
		; module library archive
		SetOutPath "$INSTDIR\lib"
		File "${InstallDir}\bin\${_BinaryName}.lib"
!else
		SetOutPath "$INSTDIR\lib"
		File "${InstallDir}\lib\${_BinaryName}.lib"
!endif		
		; module interface
		SetOutPath "$INSTDIR\include\${_IncludePath}"
		File /r "${InstallDir}\include\${_IncludePath}\*.h"
	SectionEnd
	
	Section "Un.${_BinaryName}-API"
		; module binary
!if ${_IsRuntimeModule}
		Delete "$INSTDIR\bin\${_BinaryName}.dll"
		RMDir "$INSTDIR\bin"
!endif		
		; module library archive
		Delete "$INSTDIR\lib\${_BinaryName}.lib"
		RMDir "$INSTDIR\lib"
		
		; module interface
		RMDir /r "$INSTDIR\include\${_IncludePath}"
		RMDir "$INSTDIR\include"
		
		RMDir "$INSTDIR"
	SectionEnd
	
	!undef _RuntimeBinary
	!undef _StaticBinary
	!undef _IsRuntimeModule
	
!macroend

!macro DeploySdkApi _SdkModuleName
	!insertmacro DeployApi "${_SdkModuleName}" "${_SdkModuleName}"
!macroend

!macro DeployModuleApi _ModuleName
	!insertmacro DeployApi "${COMPONENT_NAME}${_ModuleName}" "${COMPONENT_NAME}\${_ModuleName}"
	Section "Un.SDK-interface"
		RMDir "$INSTDIR\include\sdk"
		RMDir "$INSTDIR\include"
		RMDir "$INSTDIR"
	SectionEnd
!macroend
*/

!endif ; __SYMBOID_SDK_BUILD_DEPLOY_API_NSH__
