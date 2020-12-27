
!ifndef __SYMBOID_SDK_BUILD_DEPLOY_MODULE_NSH__
!define __SYMBOID_SDK_BUILD_DEPLOY_MODULE_NSH__

!include config.nsh
!include qt.nsh

!macro DeployBinaryFile _BinaryRelFolder _BinaryFileName

	${EchoItem} "Binary               : ${BuildDir}\${_BinaryRelFolder}\${_BinaryFileName}"

	Section "Binary ${_BinaryFileName}"
		SetOutPath "$INSTDIR"
		File "${BuildDir}\${_BinaryRelFolder}\${_BinaryFileName}"
	SectionEnd

	Section "Un.Binary ${_BinaryFileName}"
		Delete "$INSTDIR\${_BinaryFileName}"
		RMDir "$INSTDIR"
	SectionEnd
	
!macroend

!macro DeployModule _ModuleLogicalPath

	!searchparse "${_ModuleLogicalPath}" "" _ComponentName "\" _ModuleFolder "\" _ModuleName "." _ModuleFileExt
	!define _BinaryRelPath "${_ComponentName}\${_ModuleFolder}\${BuildConfig}"

	!insertmacro DeployBinaryFile "${_BinaryRelPath}" "${_ModuleName}.${_ModuleFileExt}"
	!if `${BuildConfig}` == `debug`
		!insertmacro DeployBinaryFile "${_BinaryRelPath}" "${_ModuleName}.pdb"
	!endif
	!insertmacro GenQtDeps "${_ComponentName}\${_ModuleFolder}" "${_ModuleName}.${_ModuleFileExt}"

	!undef _BinaryRelPath
	
!macroend

!macro DeployFile _SourceFolder _TargetFolder _BaseName

	!define _SourcePath "${RootDir}\${_SourceFolder}\${_BaseName}"
	${EchoItem} "File                 : ${_SourcePath}"
	
	Section "${_BaseName}"
		SetOutPath "${_TargetFolder}"
		File "${_SourcePath}"
	SectionEnd

	Section "Un.${_BaseName}"
		Delete "${_TargetFolder}\${_BaseName}"
		RMDir "${_TargetFolder}"
		RMDir "$INSTDIR"
	SectionEnd
	!undef _SourcePath

!macroend


!endif ; __SYMBOID_SDK_BUILD_DEPLOY_MODULE_NSH__
