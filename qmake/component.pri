
include(rules.pri)

# updating repo revision
REVISION_STAMP = $$shell_path($$SYS_HOME/$$COMPONENT_NAME/.revision.stamp)
revision.target = $$REVISION_STAMP
revision.depends = FORCE
win32 {
REVISION_SCRIPT = $$SYS_HOME\sdk\build\component\revision.vbs
revision.commands = cscript $$REVISION_SCRIPT $$COMPONENT_NAME
}
else:unix {
REVISION_SCRIPT = $$SYS_HOME/build/component/revision.sh
revision.commands = $$REVISION_SCRIPT $$COMPONENT_NAME
}
QMAKE_EXTRA_TARGETS += revision
OTHER_FILES += $$REVISION_SCRIPT

# target for component.h and component.json generation
#COMPONENT_PROPS=$$shell_path("$$SYS_HOME/$$COMPONENT_NAME/component.json")
COMPONENT_H=$$shell_path("$$SYS_HOME/$$COMPONENT_NAME/component.h")
component_h.target = $$COMPONENT_H
component_h.depends = $$shell_path($$SYS_HOME/$$COMPONENT_NAME/component.ini) $$REVISION_STAMP
win32 {
    component_h.commands = cscript $$SYS_HOME\sdk\build\component\generate.vbs $$COMPONENT_NAME $${QT_MAJOR_VERSION}.$${QT_MINOR_VERSION}
}
else:unix {
    component_h.commands = chmod +x $$SYS_HOME/build/component/generate.sh; $$SYS_HOME/build/component/generate.sh $$COMPONENT_NAME $${QT_MAJOR_VERSION}.$${QT_MINOR_VERSION}
}
QMAKE_EXTRA_TARGETS += component_h

component_h_alias.target = $$shell_path($$relative_path("$$SYS_HOME/$$COMPONENT_NAME/component.h", $$OUT_PWD))
component_h_alias.depends = $$shell_path($$COMPONENT_H)
QMAKE_EXTRA_TARGETS += component_h_alias

defineReplace(object_dep_on_component_header) {
    object_name = $$1
    object_path

    win32:CONFIG(release, debug|release): object_path = release\\$${object_name}.obj
    else:win32:CONFIG(debug, debug|release): object_path = debug\\$${object_name}.obj
    else:unix: object_path = $${object_name}.o

    eval($${object_name}_obj.target += $${object_path})
    eval($${object_name}_obj.depends += $$COMPONENT_H)
    eval(export($${object_name}_obj.target))
    eval(export($${object_name}_obj.depends))

    return ($${object_name}_obj)
}

OTHER_FILES += \
    $$SYS_HOME/build/component/generate.vbs \
    $$SYS_HOME/build/component/generate.sh \
    $$SYS_HOME/$$COMPONENT_NAME/component.h \
#    $$SYS_HOME/$$COMPONENT_NAME/component.json \
    $$SYS_HOME/$$COMPONENT_NAME/component.ini

# target for component files clean
component_files_clean.commands = -$(DEL_FILE) $$REVISION_STAMP $$COMPONENT_H
QMAKE_EXTRA_TARGETS += component_files_clean
CLEAN_DEPS += component_files_clean

