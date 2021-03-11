
!ifndef __SYMBOID_SDK_BUILD_DEPLOY_CRT_NSH__
!define __SYMBOID_SDK_BUILD_DEPLOY_CRT_NSH__

!include config.nsh

!macro IncludeVcRedist

!if `${BuildConfig}` == `release`
	!define CrtDir "${RootDir}\build\deploy\crt\${Toolchain}"
	${EchoItem} "Copy CRT from        : ${CrtDir}"
	
	Section "Deploy CRT"
		SetOutPath "$INSTDIR"
		File "${CrtDir}\vcruntime140.dll"
		File /nonfatal "${CrtDir}\vcruntime140_1.dll"
		File "${CrtDir}\msvcp140.dll"
		File "${CrtDir}\msvcp140_1.dll"
		File "${CrtDir}\msvcp140_2.dll"
		File "${CrtDir}\concrt140.dll"
		File "${CrtDir}\vccorlib140.dll"
		File /nonfatal "${CrtDir}\msvcp140_codecvt_ids.dll"
	SectionEnd
	
	Section "Un.Deploy CRT"
		Delete "$INSTDIR\vcruntime140.dll"
		Delete "$INSTDIR\vcruntime140_1.dll"
		Delete "$INSTDIR\msvcp140.dll"
		Delete "$INSTDIR\msvcp140_1.dll"
		Delete "$INSTDIR\msvcp140_2.dll"
		Delete "$INSTDIR\concrt140.dll"
		Delete "$INSTDIR\vccorlib140.dll"
		Delete "$INSTDIR\msvcp140_codecvt_ids.dll"
	SectionEnd

!endif

!macroend

!endif ; __SYMBOID_SDK_BUILD_DEPLOY_CRT_NSH__
