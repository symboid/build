
import sys
import os
import platform

platform_name = platform.system()
if platform_name == "Darwin":
    pkg_suffix = ".pkg"
    distro_suffix = "-distro.pkg"
elif platform_name == "Windows":
    pkg_suffix = "-pkg.exe"
    distro_suffix = "-distro.exe"
else:
    print "Platform '"+platform_name+"' not implemented!"
    os._exit(1)

packages_dir = sys.argv[1]
if os.path.exists(packages_dir):
    packages = os.listdir(packages_dir)
else:
    packages = []

for package in packages:
    package_path = os.path.normpath(os.path.join(packages_dir, package))
    if package_path[-len(pkg_suffix):] == pkg_suffix and package_path[-len(distro_suffix):] != distro_suffix:
        print "Purging: " + package_path
        os.remove(package_path)
