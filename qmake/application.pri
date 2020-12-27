
include(qt-module.pri)

TEMPLATE = app
CONFIG -= app_bundle

msvc {
    QMAKE_LFLAGS_WINDOWS = /SUBSYSTEM:WINDOWS,5.01
}

unix {
    QMAKE_STRIP=@echo "strip switched off for: "
}
