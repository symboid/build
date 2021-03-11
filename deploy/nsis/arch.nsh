
!ifndef __SYMBOID_PLATFORM_DEPLOY_ARCH_NSH__
!define __SYMBOID_PLATFORM_DEPLOY_ARCH_NSH__

!include X64.nsh

;-------------------------------------------------------------------------------
; Toolchain selected:
;
!ifdef _Config_Toolchain
	!define Toolchain "${_Config_Toolchain}"
!else
	!define Toolchain "msvc2019_64"
!endif

;-------------------------------------------------------------------------------
; Type of binary architecture excpected:
;
!searchparse ">${Toolchain}_32_" ">" __t "_" __arch "_"
#!ifdef _Config_AllArch
#	!define BuildArch All
#!else ifdef _Config_x86
!if `${__arch}` = `32`
	!define BuildArch x86
!else
	!define BuildArch x64
!endif

;-------------------------------------------------------------------------------
; Directory of Program Files:
;
!if `${BuildArch}` == `x86`
	!define ProgramFilesDir $PROGRAMFILES32
!else
	!define ProgramFilesDir $PROGRAMFILES64
!endif

;-------------------------------------------------------------------------------
; Validation of running architecture
;
!macro Arch64Check
	; when package is 64 bit and OS is 32 bit
	; installation cannot be executed
	!if `${BuildArch}` == `x64`
		${If} ${RunningX64}
		${Else}
			MessageBox MB_OK|MB_ICONSTOP "$(TextCannotExecute64BitInstaller)"
			Abort
		${EndIf}
	!endif

	; when package is 32 bit and OS is 64 bit
	; the 64 bit compilation will be recommended
	!if `${BuildArch}` == `x86`
		${If} ${RunningX64}
			IfSilent continue
			MessageBox MB_YESNO|MB_ICONQUESTION  "$(TextRecommend64BitInstaller)" IDYES continue
			Abort
			continue:
		${EndIf}
	!endif
!macroend

!endif ; __SYMBOID_PLATFORM_DEPLOY_ARCH_NSH__
