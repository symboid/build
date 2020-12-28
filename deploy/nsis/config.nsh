
!ifndef __SYMBOID_PLATFORM_DEPLOY_CONFIG_NSH__
!define __SYMBOID_PLATFORM_DEPLOY_CONFIG_NSH__

!include echo.nsh
!include arch.nsh

;-------------------------------------------------------------------------------
; Configuration defaults:
;

; Type of binary compilation excpected:
!ifdef _Config_Debug
	!define BuildConfig debug
!else
	!define BuildConfig release
!endif

;-------------------------------------------------------------------------------
; Basic directory settings:
;

; directory of NSIS script files:
!define ScriptDir "${__FILEDIR__}"

; root directory of complete source code (including local repos):
!define RelScriptDir "build\deploy\nsis"
!define RootDirScript "${RelScriptDir}\__rootdir.nsh"
!cd "${ScriptDir}\..\..\.."
!system 'ECHO !define RootDir "%CD%" > ${RootDirScript}'
!include ${RootDirScript}
!delfile ${RootDirScript}
;!cd ${RelScriptDir}
!cd "${ScriptDir}"

; directory of builds:
!ifdef _Config_BuildDir
	!define RelBuildDir "${_Config_BuildDir}"
!else
	!define RelBuildDir "_build\${BuildConfig}-${Toolchain}-${BuildArch}"
!endif
!define BuildDir "${RootDir}\${RelBuildDir}"

; directory of packages:
!define PackageDir "${RootDir}\_packages"
!system "IF NOT EXIST ${PackageDir} MKDIR ${PackageDir}"

; root directory of Qt
!ifdef _Config_QtHome
	!define QtHome "${_Config_QtHome}"
!else
	!define QtHome "C:\Qt"
!endif

;-------------------------------------------------------------------------------
; Configuration summary:
;
${EchoHeader} "CONFIGURATION"
${EchoItem} "Architecture         : ${BuildArch}"
${EchoItem} "Toolchain            : ${Toolchain}"
!ifndef _Config_HideSummary
${EchoItem} "Build quality        : ${BuildConfig}"
${EchoItem} "Script location      : ${ScriptDir}"
${EchoItem} "Root directory       : ${RootDir}"
${EchoItem} "Package directory    : ${PackageDir}"
!endif
${EchoItem} "Build directory      : ${BuildDir}"

!endif ; __SYMBOID_PLATFORM_DEPLOY_CONFIG_NSH__
