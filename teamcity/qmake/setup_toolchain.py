
import sys
import os

if not len(sys.argv) == 2:
    print("Number of arguments must be 1!")
    print("    arg #1: toolchain")
    os._exit(1)

toolchain = sys.argv[1]

#qtdir = r'' + os.environ['QTHOME'] + r''
#if not os.path.exists(qtdir):
#    print "QTDIR '" + qtdir + "' does not exist! Aborting..."
#    os._exit(1)

is_msvc_toolchain = (toolchain[:4] == "msvc")

# make path
if is_msvc_toolchain:
    make_path = r'"' + os.environ['QTHOME'] + r'\\Tools\\QtCreator\\bin\\jom.exe"'
else:
    make_path = 'make'
print("Path of make binary : "+make_path)

# toolchain setup script:
if toolchain == "msvc2017":
    invoke_setup = r'"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\VsDevCmd.bat"'
elif  toolchain == "msvc2017_64":
    invoke_setup = r'"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\VsDevCmd.bat"'
else:
    toolchain_script = ""

# setting teamcity parameters:
print("##teamcity[setParameter name='build.make_path' value='" + make_path + "']")
print("##teamcity[setParameter name='build.call_setup' value='" + invoke_setup + "']")

'''

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
print "##teamcity[setParameter name='build.make_path' value='" + make_cmd + "']"
print "##teamcity[setParameter name='qmake_setup_env' value='" + invoke_env_script + "']"
print "##teamcity[setParameter name='qmake_set_path' value='" + invoke_set_path + "']"
'''
