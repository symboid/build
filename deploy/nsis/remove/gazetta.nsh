
!ifndef __SYMBOID_PLATFORM_DEPLOY_GAZETTA_NSH__
!define __SYMBOID_PLATFORM_DEPLOY_GAZETTA_NSH__

!include config.nsh
!include echo.nsh

!macro DeployGazetta _GazettaInstDir

	${EchoItem} "Gazetta              :"
	
	!define _GazettaDir "${InstallDir}\data"

	Section "Gazetta DB"
		SetOutPath "${_GazettaInstDir}"
		File "${_GazettaDir}\country.csv"
		File "${_GazettaDir}\timezone.csv"
		File "${_GazettaDir}\zone.csv"
		File "${_GazettaDir}\HU_lesser_ppl.gaz.csv"
		File "${_GazettaDir}\World_most_ppl.gaz.csv"
	SectionEnd

	Section "Un.Gazetta DB"
		Delete "${_GazettaInstDir}\country.csv"
		Delete "${_GazettaInstDir}\timezone.csv"
		Delete "${_GazettaInstDir}\zone.csv"
		Delete "${_GazettaInstDir}\HU_lesser_ppl.gaz.csv"
		Delete "${_GazettaInstDir}\World_most_ppl.gaz.csv"
		RMDir "${_GazettaInstDir}"
		RMDir "$INSTDIR"
	SectionEnd

!macroend

!endif
