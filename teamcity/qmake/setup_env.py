
import sys
import os

if not len(sys.argv) == 4:
    print "Number of arguments must be 3!"
    print "    arg #1: platform"
    print "    arg #2: toolchain"
    print "    arg #2: qtdir"
    os._exit(1)

platform = sys.argv[1]
toolchain = sys.argv[2]
qtdir = sys.argv[3]

if not os.path.exists(qtdir):
    print "QTDIR '" + qtdir + "' does not exist! Aborting..."
    os._exit(1)

# toolchain setup script:
if toolchain == "msvc2013":
    toolchain_script = r'"' + os.environ['VS120COMNTOOLS'] + r'\..\..\VC\vcvarsall.bat"'
elif  toolchain == "msvc2015":
    toolchain_script = r'"' + os.environ['VS140COMNTOOLS'] + r'\..\..\VC\vcvarsall.bat"'
else:
    toolchain_script = ""

# qmake setup shell script call:
if platform == "win_x86":
    invoke_env_script = "CALL " + toolchain_script + " x86"
elif platform == "win_x64":
    invoke_env_script = "CALL " + toolchain_script + " x64"
else:
    invoke_env_script = "echo"

# PATH setting shell script call:
if platform == "win_x86" or platform == "win_x64":
    invoke_set_path = r'set "PATH=' + qtdir + r'\\bin;' + os.environ['PATH'] + r'"'
    make_cmd = r'"' + os.environ['QT_HOME'] + r'\\Tools\\QtCreator\\bin\\jom.exe"'
else:
    invoke_set_path = r'export PATH="' + qtdir + r'/bin:' + os.environ['PATH'] + r'"'
    make_cmd = 'make'

# setting teamcity parameters:
print "##teamcity[setParameter name='make_cmd' value='" + make_cmd + "']"
print "##teamcity[setParameter name='qmake_setup_env' value='" + invoke_env_script + "']"
print "##teamcity[setParameter name='qmake_set_path' value='" + invoke_set_path + "']"
