
import sys
import os

if not len(sys.argv) == 2:
    print("Number of arguments must be 1!")
    print("    arg #1: toolchain")
    os._exit(1)

toolchain = sys.argv[1]
is_msvc_toolchain = (toolchain[:4] == "msvc")

# make path
if is_msvc_toolchain:
    make_path = r'"' + os.environ['QTHOME'] + r'\\Tools\\QtCreator\\bin\\jom.exe"'
    export_var = r'SET'
else:
    make_path = 'make'
    export_var = r'export'
print("Path of make binary : "+make_path)

# toolchain setup script:
if toolchain == "msvc2017":
    invoke_setup = r'CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat"'
elif  toolchain == "msvc2017_64":
    invoke_setup = r'CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"'
else:
    invoke_setup = "echo"

# setting teamcity parameters:
print("##teamcity[setParameter name='qt.make' value='" + make_path + "']")
#print("##teamcity[setParameter name='build.call_setup' value='" + invoke_setup + "']")
#print("##teamcity[setParameter name='build.call_export_var' value='" + export_var + "']")
