
!ifndef __SYMBOID_PLATFORM_DEPLOY_LAUNCHER_NSH__
!define __SYMBOID_PLATFORM_DEPLOY_LAUNCHER_NSH__

!include embed.nsh

!macro GenerateLauncher _ExeName _ExeLevel

	!define _LauncherExe "${_ExeName}.exe"
	
	${EchoItem} "Launcher             : ${_LauncherExe}"
	!insertmacro EmbedMake "${_LauncherExe}" launcher.nsi "/D_Config_x86 /D_Config_ExeName=${_LauncherExe} /D_Config_ExeLevel=${_ExeLevel}"
	!insertmacro EmbedExe "${_LauncherExe}" "$INSTDIR"
	!insertmacro UnEmbedExe "${_LauncherExe}" "$INSTDIR"
	
	!undef _LauncherExe

!macroend

!endif ; __SYMBOID_PLATFORM_DEPLOY_LAUNCHER_NSH__
