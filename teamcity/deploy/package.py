
import sys
import os
from subprocess import call

if not len(sys.argv) == 8:
    print "Number of arguments must 7!"
    print "    arg #1: component path"
    print "    arg #2: script type (package|distro)"
    print "    arg #3: platform"
    print "    arg #4: build config"
    print "    arg #5: build dir"
    print "    arg #6: qt ver"
    print "    arg #7: toolchain"
    os._exit(1)

component_path = sys.argv[1]
script_type = sys.argv[2]
platform = sys.argv[3]
build_config = sys.argv[4]
build_dir = sys.argv[5]
qt_ver = sys.argv[6]
toolchain = sys.argv[7]

if platform == "macos":
    cmd = "/bin/bash"
    script = component_path + "/deploy/macos-"+script_type+".sh"
    script_arguments = [ "--build-config="+build_config, "--build-dir="+build_dir, "--qt-ver="+qt_ver]
    if script_type == "distro":
        script_arguments = [ "--lazy-embed" ] + script_arguments
        if build_config == "release":
            script_arguments = [ "--with-sign" ] + script_arguments
    process_arguments = [cmd, script] + script_arguments
elif platform == "win_x86" or platform == "win_x64":
    cmd = "makensis"
    script = component_path + "\deploy\win-"+script_type+".nsi"
    script_arguments = [ "/D_Config_BuildDir="+build_dir, "/D_Config_Toolchain="+toolchain, "/D_Config_QtVer="+qt_ver ]
    if build_config == "debug":
        script_arguments = [ "/D_Config_Debug" ] + script_arguments
    if platform == "win_x86":
        script_arguments = [ "/D_Config_x86" ] + script_arguments
    if script_type == "distro":
        script_arguments = [ "/D_Config_LazyEmbed" ] + script_arguments
    process_arguments = [cmd] + script_arguments + [script]

print "Script interpreter : " + cmd
print "Script             : " + script
print "Script arguments   : "
for a in script_arguments: print "    " + a

print "Invoking script..."
if not (call(process_arguments) == 0):
    os._exit(1)

