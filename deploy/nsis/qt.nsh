
!ifndef __SYMBOID_SDK_BUILD_DEPLOY_QT_NSH__
!define __SYMBOID_SDK_BUILD_DEPLOY_QT_NSH__

!include config.nsh

; currently installed and used version on Qt API
!ifdef _Config_QtVer
	!define QtVer "${_Config_QtVer}"
!else
	!define QtVer 5.14.2
!endif

; directory of currently installed and used Qt Toolchain:
!if `${BuildArch}` == `x86`
	!define QtDir "${QtHome}\${QtVer}\${Toolchain}"
!else
	!define QtDir "${QtHome}\${QtVer}\${Toolchain}_64"
!endif

; version variants of Qt
!searchparse ">${QtVer}." ">" QtVerMajor "." QtVerMinor "."
!define QtVerNum "${QtVerMajor}${QtVerMinor}"
!if `${BuildConfig}` == `debug`
	!define QtVerMain "${QtVer}d"
!else
	!define QtVerMain "${QtVer}"
!endif

; installation directory of QT runtime
!define QtInstallDir "$INSTDIR\Qt${QtVerMain}"

; 
!define QtDepsDir "${BuildDir}\qt_${QtVer}_deps"

; full path and parameters of Qt dependency generator tool 'windeployqt':
!define QtDepGen "${QtDir}\bin\windeployqt.exe"
!define QtDepGenParams "--${BuildConfig} --no-compiler-runtime --verbose 0 --plugindir ${QtDepsDir}\plugins --dir ${QtDepsDir}\qml --libdir ${QtDepsDir}\bin"

!macro ClearQtDeps

	!system 'IF EXIST "${QtDepsDir}" RMDIR /Q /S "${QtDepsDir}"'
	!system 'MKDIR "${QtDepsDir}"'

!macroend

!ifdef _Config_QtKeepDeps
	; Qt deps directory won't be purged, bundle aggregation assumed
	!system 'IF NOT EXIST "${QtDepsDir}" MKDIR "${QtDepsDir}"'
!else
	; Qt deps directory will be purged
	!insertmacro ClearQtDeps
!endif


!macro GenQtDeps _ModuleRelPath _ModuleBaseName

	!define qml_dir "${RootDir}\${_ModuleRelPath}"
	!define binary_path "${BuildDir}\${_ModuleRelPath}\${BuildConfig}\${_ModuleBaseName}"
	
	!system '${QtDepGen} ${QtDepGenParams} --qmldir ${qml_dir} ${binary_path}'
	
	!undef binary_path
	!undef qml_dir
	
!macroend

; common basic binaries included Qt runtime at least
!define QtBasicLibNames "[Qt5Core][Qt5Gui][Qt5Widgets][Qt5Qml][Qt5Quick][libGLESV2][libEGL]"
!if `${BuildConfig}` == `debug`
	!searchreplace QtBasicLibNames "${QtBasicLibNames}" "]" "d]"
!endif
!define QtBasicDlls "${QtBasicLibNames}[D3Dcompiler_47][opengl32sw]"
!searchreplace QtBasicBinaries "${QtBasicDlls}" "]" ".dll"

; deploying basic Qt resources
!macro DeployQtBasics

	${EchoItem} "Qt Basics            : ${QtVerMain}"

	!searchreplace _BinaryList "${QtBasicBinaries}" "[" " ${QtDir}\bin\"
		
	Section "Qt ${QtVerMain}"
		SetOutPath "${QtInstallDir}\bin"
		File ${_BinaryList}
	SectionEnd

	Section "Un.Qt ${QtVerMain}"
		RMDir /r "${QtInstallDir}"
	SectionEnd

	!undef _BinaryList
	
!macroend

; deploying component-specific (dependent) Qt resources
!macro DeployQtDeps

	${EchoItem} "Qt Deps              : ${QtVerMain}"
	
	!searchreplace _ExcludeBinaries "${QtBasicBinaries}" "[" " /x "
	
	Section "Qt ${QtVerMain} Deps"
		SetOutPath "${QtInstallDir}"
		File /nonfatal /r ${_ExcludeBinaries} /x "qt_*.qm" "${QtDepsDir}\*.*"
		SetOutPath "${QtInstallDir}\translations"
		File "${QtDepsDir}\qml\translations\qt_hu.qm"
		File "${QtDepsDir}\qml\translations\qt_en.qm"
	SectionEnd

	!undef _ExcludeBinaries
	
!macroend

!endif ; __SYMBOID_SDK_BUILD_DEPLOY_QT_NSH__
