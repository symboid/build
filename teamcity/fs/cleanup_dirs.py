
import sys
import os
import shutil

dirs = sys.argv[1:]

for dir in dirs:
    if os.path.exists(dir):
        shutil.rmtree(dir)
        print "Directory '" + dir + "' cleaned up."
    os.makedirs(dir)
