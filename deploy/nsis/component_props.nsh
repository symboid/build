
!ifndef __SYMBOID_BUILD_DEPLOY_COMPONENT_PROPS_NSH__
!define __SYMBOID_BUILD_DEPLOY_COMPONENT_PROPS_NSH__

!include config.nsh

!macro SetupComponentProps _ComponentID

	!define ConvertScriptPath "${RootDir}\sdk\build\component\component_nsh.vbs"
	!define ComponentNsh "${RootDir}\${_ComponentID}\component.nsh"
	!system 'cscript ${ConvertScriptPath} ${_ComponentID}'
	!include /CHARSET=UTF8 ${ComponentNsh}
	
!macroend

!macro DeployComponentJson
	!insertmacro DeployComponentJsonTo "$INSTDIR"
!macroend

!macro SetupComponentVersion

VIFileVersion ${COMPONENT_VER_STRING}
VIProductVersion ${COMPONENT_VER_STRING}

VIAddVersionKey /LANG=${LANG_HUNGARIAN} "CompanyName" "Symboid"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "ProductName" "${COMPONENT_TITLE}"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "FileVersion" "${COMPONENT_VER_STRING}"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "ProductVersion" "${COMPONENT_VER_STRING}"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "LegalCopyright" "Copyright TR"
;VIAddVersionKey /LANG=${LANG_HUNGARIAN} "FileDescription" "$(TextDeploymentPackage)"
VIAddVersionKey /LANG=${LANG_HUNGARIAN} "FileDescription" "Symboid Deployment Package"

!undef ComponentNsh

!macroend

!endif ; __SYMBOID_BUILD_DEPLOY_COMPONENT_PROPS_NSH__
