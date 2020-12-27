
!ifndef __SYMBOID_PLATFORM_DEPLOY_LINKS_NSH__
!define __SYMBOID_PLATFORM_DEPLOY_LINKS_NSH__

!include config.nsh

!macro StartMenuFolder _RelFolder
!define /redef StartMenuFolderPath "$SMPROGRAMS\${_RelFolder}"
!macroend

!macro StartMenuLink _LinkName _ExePath _ExeParams _IconFile

!ifndef StartMenuFolderPath
	!error "Macro constant 'StartMenuFolderPath' is undefined! Macro 'StartMenuFolder' shall be called."
!endif

Section "SM Link ${_LinkName}"
	SetOutPath "$INSTDIR"
	CreateDirectory "${StartMenuFolderPath}"
	CreateShortCut "${StartMenuFolderPath}\${_LinkName}.lnk" "${_ExePath}" "${_ExeParams}" "${_IconFile}"
SectionEnd

Section "Un.SM Link ${_LinkName}"
	Delete "${StartMenuFolderPath}\${_LinkName}.lnk"
	RMDir "${StartMenuFolderPath}"
SectionEnd

!macroend

!macro DesktopLink _LinkName _ExePath _ExeParams _IconFile

Section "Desktop Link ${_LinkName}"
	SetOutPath "$INSTDIR"
	CreateShortCut "$DESKTOP\${_LinkName}.lnk" "${_ExePath}" "${_ExeParams}" "${_IconFile}"
SectionEnd

Section "Un.Desktop Link ${_LinkName}"
	Delete "$DESKTOP\${_LinkName}.lnk"
SectionEnd

!macroend

!macro StartMenuBootLink _LinkName _AppComponentId _IconFile

	!insertmacro StartMenuLink ${_LinkName} "$\"$INSTDIR\launcher.exe$\"" "--tool:boot --app:${_AppComponentId}" "${_IconFile}"
	
!macroend

!macro DesktopBootLink _LinkName _AppComponentId _IconFile

	!insertmacro DesktopLink ${_LinkName} "$\"$INSTDIR\launcher.exe$\"" "--tool:boot --app:${_AppComponentId}" "${_IconFile}"
	
!macroend

!endif ; __SYMBOID_PLATFORM_DEPLOY_LINKS_NSH__
