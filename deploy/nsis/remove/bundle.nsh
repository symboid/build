
!ifndef __SYMBOID_PLATFORM_DEPLOY_BUNDLE_NSH__
!define __SYMBOID_PLATFORM_DEPLOY_BUNDLE_NSH__

!addincludedir ${__FILEDIR__}

!include config.nsh
!include qt.nsh
!include package.nsh
!include embed.nsh

!macro Bundle _BundlePackageName _BundleTitle _BackgroundImage

	!define DontCheckHome
	!define DontCheckQt
	!define PackageInstallerExe "${PackageDir}\${COMPONENT_NAME}-${COMPONENT_VER_STRING}-${BuildArch}-distro.exe"
	!insertmacro PackageBasics "${_BundlePackageName}" "$TEMP\${_BundlePackageName}"

	!define MUI_WELCOMEFINISHPAGE_BITMAP "${RootDir}\${_BackgroundImage}"
	
	!insertmacro MUI_PAGE_WELCOME
	!insertmacro PackageCommonPages

!macroend

!macro BundleFinish

	!insertmacro MUI_PAGE_FINISH
	!insertmacro PackageTexts

!macroend

!macro BundleFinishWithRun _StartFunction

	!define MUI_FINISHPAGE_RUN
	!define MUI_FINISHPAGE_RUN_FUNCTION ${_StartFunction}
	!insertmacro BundleFinish

!macroend

!macro BundleFinishWithLaunch _StartRef
	
	Function StartApp
		ExecShell "open" "${_StartRef}"
	FunctionEnd

	!insertmacro BundleFinishWithRun StartApp
	
!macroend

!macro IncludePackage _PackageName _PackageNsi
!if `${BuildArch}` != `x86`
	!insertmacro EmbedInstaller "${_PackageName}-pkg.exe" x64 "${RootDir}\${_PackageNsi}" "/D_Config_QtKeepDeps"
!endif
!if `${BuildArch}` != `x64`
	!insertmacro EmbedInstaller "${_PackageName}-pkg.exe" x86 "${RootDir}\${_PackageNsi}" "/D_Config_QtKeepDeps"
!endif
	
!macroend

!endif ; __SYMBOID_PLATFORM_DEPLOY_BUNDLE_NSH__
