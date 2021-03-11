
SYS_HOME = $$shell_path($$absolute_path(../.., $$PWD))
BUILD_HOME = $$shell_path($$absolute_path($$BUILD_ROOT, $$OUT_PWD))

SDK_HOME = $$SYS_HOME/sdk

defineReplace(sdkBuildDep) {
    mod_name = $$1
    mod_dep = $$SDK_HOME/$${mod_name}/mod
    return ($$mod_dep )
}

defineReplace(buildPath) {
    out_dir = $$1
    build_path =

    win32:CONFIG(release, debug|release): build_path = $${out_dir}/release
    else:win32:CONFIG(debug, debug|release): build_path = $${out_dir}/debug
    else:unix: build_path = $${out_dir}

    return ($$build_path)
}

defineReplace(libPath) {
    return ($$buildPath($$1))
}

defineReplace(staticLibDep) {
    lib_dir = $$1
    lib_name = $$2
    lib_dep =

    win32-g++: lib_base = lib$${lib_name}.a
    else: win32: !win32-g++: lib_base = $${lib_name}.lib
    else: unix: lib_base = lib$${lib_name}.a

    lib_dep = $$libPath($${lib_dir})/$${lib_base}

    return($$lib_dep)
}

defineReplace(componentLibDep) {
    lib_name = $$1
    lib_dep =

    win32-g++: lib_base = lib$${lib_name}.a
    else: win32: !win32-g++: lib_base = $${lib_name}.lib
    else: unix: lib_base = lib$${lib_name}.a

    return($$lib_dep)
}

# compiler settings:
CONFIG += c++17
clang|gcc {
    QMAKE_CXXFLAGS += -Wno-inconsistent-missing-override
}

clang {
    QMAKE_CXXFLAGS += -stdlib=libc++
    android {
        # fix of NDKr20
        lessThan(QT_MINOR_VERSION,14) {
                QMAKE_LFLAGS += -nostdlib++
        }
    }
    else {
        QMAKE_LFLAGS += -stdlib=libc++
        QMAKE_MACOSX_DEPLOYMENT_TARGET=10.13
        QMAKE_OBJECTIVE_CFLAGS += -fobjc-arc
    }
}

# first SDK home need to be added in order to avoid using _install/include inside module/component
#INCLUDEPATH += $${SDK_HOME}

# setting up context
macx{
    CTX_OS=mac
}
else:ios{
    CTX_OS=ios
}
else:win32{
    CTX_OS=win
}
else:android{
    CTX_OS=android
}
else:linux{
    CTX_OS=linux
}
else{
    CTX_OS=___
}
CONFIG(debug, debug|release){
    CTX_RUN=dev
}
else{
    CTX_RUN=prod
}
CONTEXT=$$CTX_OS-$$CTX_RUN

INCLUDEPATH += $$SYS_HOME
