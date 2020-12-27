
!define _Config_QtKeepDeps

!include config.nsh
!include qt.nsh
!include FileFunc.nsh
!include envvar.nsh

!ifdef _Config_ExeName
	!define ExeName ${_Config_ExeName}
!else
	!define ExeName launcher.exe
!endif

!ifdef _Config_ExeLevel
	!define ExeLevel ${_Config_ExeLevel}
!else
	!define ExeLevel user 
!endif

OutFile "${PackageDir}\${ExeName}"
RequestExecutionLevel ${ExeLevel}
Icon "${RootDir}\platform\deploy\platform.ico"
SilentInstall silent

Var PATH
Var AppComponentId
Var PlatformTool

!define ToolExePath "$SYMBOID_PLATFORM\$PlatformTool.exe"
!define CurrentQtDir "${QtInstallDir}"

Section
	; querying environment variable 'PATH'
	ReadRegStr $PATH ${EnvHKCU} "PATH"

	; settung up proper runtime environment:
	!insertmacro SetEnv "PATH" "$PATH;${CurrentQtDir}\bin"
	!insertmacro SetEnv "QML2_IMPORT_PATH" "${CurrentQtDir}\qml"
	!insertmacro SetEnv "QT_PLUGIN_PATH" "${CurrentQtDir}\plugins"
	!insertmacro SetEnv "QMLSCENE_DEVICE" "softwarecontext"
	!insertmacro SetEnv "QML_DISABLE_DISK_CACHE" "true"
	
	; parsing command line argument:
	${GetOptions} $CMDLINE "--" $R0
	${If} $R0 == "env"
	
		; displaying runtime settings
		MessageBox MB_OK "PATH=$PATH;${CurrentQtDir}\bin$\n$\nQML2_IMPORT_PATH=${CurrentQtDir}\qml$\n$\nQT_PLUGIN_PATH=${CurrentQtDir}\plugins$\n$\ntool-exe=${ToolExePath}"
		
	${Else}
	
		; fetching tool parameter
		StrCpy $PlatformTool "boot" ; default tool is boot
		${GetOptions} $CMDLINE "--tool:" $PlatformTool

		${GetOptions} $CMDLINE "--trial-stamp:" $AppComponentId
		${If} $AppComponentId != ""
			; launching trial stamp operation
			ExecShell "open" "$SYMBOID_PLATFORM\boot.exe" "--trial-stamp:$AppComponentId"
			
		${Else}
			; parsing app parameter
			${GetOptions} $CMDLINE "--app:" $AppComponentId
			; launching platform tool
			ExecShell "open" "${ToolExePath}" "--app:$AppComponentId"
		${Endif}

	${Endif}

SectionEnd
