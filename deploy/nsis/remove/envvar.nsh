
!ifndef __SYMBOID_SDK_BUILD_DEPLOY_ENVVAR_NSH__
!define __SYMBOID_SDK_BUILD_DEPLOY_ENVVAR_NSH__

!include config.nsh
!include winmessages.nsh
;!include EnvVarUpdate.nsh

!define EnvHKLM 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
!define EnvHKCU 'HKCU "Environment"'

!macro UserVar _Name _Value

	Section "Var ${_Name}"
		WriteRegStr ${EnvHKCU} ${_Name} "${_Value}"
		SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
	SectionEnd
	
	Section "Un.Var ${_Name}"
		DeleteRegValue ${EnvHKCU} ${_Name}
		SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
	SectionEnd
	
!macroend

!macro AppendUserPATH _PathValue

	Section "PATH"
		${EnvVarUpdate} $0 "PATH" "A" "HKCU" "${_PathValue}"
	SectionEnd
	
	Section "Un.PATH"
		${un.EnvVarUpdate} $0 "PATH" "R" "HKCU" "${_PathValue}"
	SectionEnd
	
!macroend

!macro SetEnv _VarName _VarValue
	System::Call 'Kernel32::SetEnvironmentVariable(t, t)i ("${_VarName}", "${_VarValue}").r0'
!macroend

!endif ; __SYMBOID_SDK_BUILD_DEPLOY_ENVVAR_NSH__
