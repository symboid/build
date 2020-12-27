
TEMPLATE = subdirs

SYS_HOME = $$shell_path($$absolute_path(../.., $$PWD))

defineReplace(module_dep) {
    component_name = $$1
    module_name = $$2

    dep = $${component_name}-$${module_name}
    eval($${dep}.file = $$SYS_HOME/$$component_name/$$module_name/$${component_name}-$${module_name}.pro)
    eval(export($${dep}.file))

    return ($$dep)
}

CONFIG += ordered
