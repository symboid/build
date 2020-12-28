
import sys
import os
from subprocess import call

if not len(sys.argv) == 4:
    print("Number of arguments must 3!")
    print("    arg #1: component path")
    print("    arg #2: build dir")
    print("    arg #3: toolchain")
    os._exit(1)

component_path = sys.argv[1]
build_dir = sys.argv[2]
toolchain = sys.argv[3]

if toolchain[:4] == "msvc":
    cmd = "makensis"
    script = component_path + "\\deploy\\api.nsi"
    script_arguments = [ "/D_Config_BuildDir="+build_dir ]
    process_arguments = [cmd] + script_arguments + [script]

print("Script interpreter : " + cmd)
print("Script             : " + script)
print("Script arguments   : ")
for a in script_arguments: print("    " + a)

print("Invoking script...")
if not (call(process_arguments) == 0):
    os._exit(1)
