
!ifndef __SYMBOID_SDK_BUILD_DEPLOY_CRT_NSH__
!define __SYMBOID_SDK_BUILD_DEPLOY_CRT_NSH__

!include config.nsh

!macro IncludeVcRedist

!if `${BuildConfig}` == `release`
	!define VcRedistFileName "vcredist_${Toolchain}_${BuildArch}"
	!define VcRedistPath "${QtHome}\vcredist\${VcRedistFileName}.exe"
	!define VcRedistParams "/install /quiet /norestart"
	${EchoItem} "VC Redist installer  : ${VcRedistPath}"
	
	Section "Exec ${VcRedistFileName}"
		SetOutPath "$TEMP\_${VcRedistFileName}"
		File "${VcRedistPath}"
		ExecWait "${VcRedistFileName} ${VcRedistParams}"
	SectionEnd
	
	Section "Delete ${VcRedistFileName}"
		RMDir /r "$TEMP\_${VcRedistFileName}"
	SectionEnd
!endif

!macroend

!endif ; __SYMBOID_SDK_BUILD_DEPLOY_CRT_NSH__
