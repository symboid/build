
!ifndef __SYMBOID_SDK_BUILD_DEPLOY_ECHO_NSH__
!define __SYMBOID_SDK_BUILD_DEPLOY_ECHO_NSH__

!ifdef _Config_EchoIndent
	!define EchoIndent ${_Config_EchoIndent}
!else
	!define EchoIndent ""
!endif

!macro CompileEcho _Indent _Prefix _Text

	!system 'ECHO ${_Indent}${_Prefix}${_Text}'
	
!macroend

!macro FillWs _text _ws_length

	!if `${_ws_length}` == `0`
		"${_text}"
	!else
		!define /redef /math _lesser_length ${_ws_length} - 1
		!insertmacro FillWs "${_text} " ${_lesser_length}
	!endif
	
!macroend

!macro CompileEchoItem _ItemText

	!insertmacro CompileEcho "${EchoIndent}" "  " "${_ItemText}"
	
!macroend

!define EchoItem '!insertmacro CompileEchoItem'
!define EchoHeader '!insertmacro CompileEcho "${EchoIndent}" ""'
!define EchoLine '!insertmacro CompileEcho "${EchoIndent}" "" "............................................................................................."'

!endif ; __SYMBOID_SDK_BUILD_DEPLOY_ECHO_NSH__
