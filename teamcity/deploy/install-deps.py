
import sys
import os
from subprocess import call
import platform

if not len(sys.argv) == 2:
    print("Number of arguments must be 1!")
    print("    arg #1: packages folder")
    os._exit(1)

platform_name = platform.system()
packages_dir = sys.argv[1]

if os.path.exists(packages_dir):
    packages = os.listdir(packages_dir)
else:
    packages = []

for package in packages:
	package_path = os.path.normpath(os.path.join(packages_dir, package))
	if platform_name == "Linux" or platform_name == "Darwin":
		command_line = ["tar", "-xf", package_path, "-C", package_dir]
		file_ext = "tar.gz"
	elif platform_name == "Windows":
		command_line = [package_path, "/S", "/D="+package_dir]
		file_ext = "exe"
	else:
		print("Platform '"+platform_name+"' not implemented!")
		os._exit(1)
	if package_path[-(len(file_ext)+1):] == "."+file_ext:
		print("Invoking:")
		for arg in command_line:
			sys.stdout.write(" "+arg)
		print(" ")
		exit_code = call(command_line)
		if not (exit_code == 0):
			os._exit(exit_code)
	else:
		print("Not executed: '"+package_path+"'")
