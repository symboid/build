
include(component.pri)

# binary type is shared object
TEMPLATE = lib

# module build macro switch
DEFINES += BUILD_$$upper($$replace(TARGET,-,_))

# install phase rules
target.path = .
INSTALLS += target

MODULE_H     = $$absolute_path($$_PRO_FILE_PWD_/module.h)

defineReplace(dep_on) {
    rule_name = $$1
    target_ref = $$2
    dep_ref = $$3

    eval($${rule_name}.target += $${target_ref})
    eval($${rule_name}.depends += $${dep_ref})
    eval(export($${rule_name}.target))
    eval(export($${rule_name}.depends))

    return ($$rule_name)
}

defineReplace(dep_on_module_header) {
    rule_name = $$1
    target_ref = $$2

    return ($$dep_on($$rule_name, $$target_ref, $$MODULE_H))
}

defineReplace(res_dep_on) {
    res_name = $$1
    rule_name = res_$${res_name}
    dep_ref = $$2
    rule

    res_obj
    gcc: res_obj = $${res_name}_res.o
    else: res_obj = $${res_name}.res

    win32:CONFIG(release, debug|release): rule = $$dep_on($${rule_name}, release\\$${res_obj}, $$dep_ref)
    else:win32:CONFIG(debug, debug|release): rule = $$dep_on($${rule_name}, debug\\$${res_obj}, $$dep_ref)
    else: rule = ""

    return ($$rule)
}

# resource file compilation under windows
win32 {
    QMAKE_EXTRA_TARGETS += $$res_dep_on(details, $$MODULE_H $$COMPONENT_PROPS)

    DETAILS_RC = $$SYS_HOME/build/module/details.rc
    RC_INCLUDEPATH = $$_PRO_FILE_PWD_ $$_PRO_FILE_PWD_/..
    RC_FILE = $$DETAILS_RC

    OTHER_FILES += $$DETAILS_RC

    # RC_FILE declaration automatically turns filepath to relative
    # for path pattern matching target must be converted to relative
    module_details.target = $$relative_path($$DETAILS_RC, $$OUT_PWD)
    module_details.depends = $$MODULE_H
    QMAKE_EXTRA_TARGETS += module_details
}

# rules for module.h generation
module_header_rule.target = $$MODULE_H
win32 {
    module_header_rule.commands = cscript $$SYS_HOME/build/module/generate.vbs $$TARGET $$_PRO_FILE_PWD_
}
else:unix {
    module_header_rule.commands = chmod +x $$SYS_HOME/build/module/generate.sh; $$SYS_HOME/build/module/generate.sh $$TARGET $$_PRO_FILE_PWD_
}
QMAKE_EXTRA_TARGETS += module_header_rule

module_header_alias.target = $$shell_path($$relative_path($$_PRO_FILE_PWD_/module.h, $$OUT_PWD))
module_header_alias.depends = $$shell_path($$MODULE_H)
QMAKE_EXTRA_TARGETS += module_header_alias

# rule for module header clean
module_files_clean.commands = -$(DEL_FILE) $$MODULE_H
QMAKE_EXTRA_TARGETS += module_files_clean
CLEAN_DEPS += module_files_clean

defineReplace(object_dep_on_module_header) {
    object_name = $$1
    rule_name = obj_$${object_name}
    rule

    win32:CONFIG(release, debug|release): rule = $$dep_on_module_header($${rule_name}, release\\$${object_name}.obj)
    else:win32:CONFIG(debug, debug|release): rule = $$dep_on_module_header($${rule_name}, debug\\$${object_name}.obj)
    else: rule = $$dep_on_module_header($${rule_name}, $${object_name}.o)

    return ($$rule)
}

defineReplace(moduleName) {
    component_name = $$1
    module_name = $$2

android {
    lessThan(QT_MINOR_VERSION,14) {
        module_dir_name += $$component_name-$${module_name}
    }
    else {
        module_dir_name += $$component_name-$${module_name}_$$ANDROID_TARGET_ARCH
    }
}
else {
    module_dir_name += $$component_name-$$module_name
}
    return ($$module_dir_name)
}

defineReplace(moduleDirPath) {
    component_name = $$1
    module_name = $$2

    module_dir_name = $$libPath($$BUILD_HOME/$$component_name/$$module_name)

    return ($$module_dir_name)
}

defineReplace(moduleDep) {
    component_name = $$1
    module_name = $$2

    module_dep = -L$$moduleDirPath($$component_name,$$module_name)
    module_dep += -l$$moduleName($$component_name,$$module_name)

    return ($$module_dep)
}

defineReplace(androidModuleBuildPath) {
    component_name = $$1
    module_name = $$2

    module_build_path = $$moduleDirPath($$component_name,$$module_name)/lib$$moduleName($$component_name,$$module_name).so

    return ($$module_build_path)
}

# so name must be explicitly specified under MacOS
osx {
    QMAKE_LFLAGS_SONAME = -Wl,-install_name,$$OUT_PWD/
}

OTHER_FILES += \
    $$SYS_HOME/build/module/generate.vbs \
    $$SYS_HOME/build/module/generate.sh
