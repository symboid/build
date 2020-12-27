
include(rules.pri)

TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle

INCLUDEPATH += $${SDK_HOME}

# Qt resolves dl-path based upon variable LIBS:
#LIBS += -L$$libPath($$OUT_PWD/../mod)
#DEPENDPATH += $$PWD/../mod

# test dependency:
#LIBS += -L$$libPath($${SDK_BUILD}/test) -ltest
#DEPENDPATH += $${SDK_HOME}/test
#PRE_TARGETDEPS += $$staticLibDep($${SDK_BUILD}/test, test)

LIBS += -ldl
