
import sys
import os
from subprocess import call

if not len(sys.argv) == 5:
    print("Number of arguments must 4!")
    print("    arg #1: script path")
    print("    arg #2: build dir")
    print("    arg #3: package dir")
    print("    arg #4: toolchain")
    os._exit(1)

script_path = sys.argv[1]
build_dir = sys.argv[2]
package_dir = sys.argv[3]
toolchain = sys.argv[4]

# Build host is Windows: NSIS packaging
if toolchain[:4] == "msvc":
    cmd = "makensis"
    script = script_path + ".nsi"
    script_arguments = [ "/D_Config_BuildDir="+build_dir, "/D_Config_PackageDir="+package_dir, "/D_Config_Toolchain="+toolchain ]
    process_arguments = [cmd] + script_arguments + [script]
# Build host is other (Linux,MacOS): tar+gzip
else:
    cmd = "/bin/bash"
    script = ""
    os.chdir(build_dir)
    script_arguments = [ "-c", "tar -czf "+package_dir+"/api.tar.gz *" ]
    process_arguments = [cmd] + script_arguments

print("Script interpreter : " + cmd)
print("Script             : " + script)
print("Script arguments   : ")
for a in script_arguments: print("    " + a)

print("Invoking script...")
if not (call(process_arguments) == 0):
    os._exit(1)
