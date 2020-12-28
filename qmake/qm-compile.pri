
include(rules.pri)

QM_MOD = $$TARGET

##TRANSLATIONS += \
##    $${QM_MOD}_hu.ts

MODULE_TS = $$_PRO_FILE_PWD_/$${QM_MOD}_hu.ts
MODULE_QM = $$_PRO_FILE_PWD_/$${QM_MOD}_hu.qm
MODULE_TS_DEP += $$files($$_PRO_FILE_PWD_/*.cc, true)
MODULE_TS_DEP += $$files($$_PRO_FILE_PWD_/*.qml, true)

lingv_update.target = $$MODULE_TS
lingv_compile.target = $$MODULE_QM

message("QTDIR="$$(QTDIR))

LUPDATE = $$absolute_path(bin/lupdate, $$(QTDIR))
LRELEASE = $$absolute_path(bin/lrelease, $$(QTDIR))

lingv_update.commands = $$LUPDATE -no-obsolete $$_PRO_FILE_ -ts $$MODULE_TS
lingv_compile.commands = $$LRELEASE $$MODULE_TS -qm $$MODULE_QM

lingv_update.depends = $$MODULE_TS_DEP
lingv_compile.depends = $$MODULE_TS

QMAKE_EXTRA_TARGETS += lingv_update lingv_compile

win32:CONFIG(release, debug|release): qrc_mod_cpp.target = release\qrc_$${QM_MOD}.cpp
else:win32:CONFIG(debug, debug|release): qrc_mod_cpp.target = debug\qrc_$${QM_MOD}.cpp
else: qrc_mod_cpp.target = qrc_$${QM_MOD}.cpp
qrc_mod_cpp.depends += $$MODULE_QM
QMAKE_EXTRA_TARGETS += qrc_mod_cpp

module_qm_alias.target = $$shell_path($$relative_path($$MODULE_QM, $$OUT_PWD))
module_qm_alias.depends = $$shell_path($$MODULE_QM)
QMAKE_EXTRA_TARGETS += module_qm_alias

# target for translation files clean
translation_clean.commands = -$(DEL_FILE) $$MODULE_QM
QMAKE_EXTRA_TARGETS += translation_clean
CLEAN_DEPS += translation_clean
