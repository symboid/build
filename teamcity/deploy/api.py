
import sys
import os
from subprocess import call

if not len(sys.argv) == 4:
    print("Number of arguments must 3!")
    print("    arg #1: build dir")
    print("    arg #2: package dir")
    print("    arg #3: toolchain")
    os._exit(1)

build_dir = sys.argv[1]
package_dir = sys.argv[2]
toolchain = sys.argv[3]

# Build host is Windows: NSIS packaging
if toolchain[:4] == "msvc":
    cmd = "makensis"
    script = "api.nsi"
    script_arguments = [ "/D_Config_BuildDir="+build_dir, "/D_Config_PackageDir="+package_dir, "/D_Config_Toolchain="+toolchain[:8] ]
    if not toolchain[-3:] == "_64":
        script_arguments.append("/D_Config_x86")
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
