# Asset catalog builder
# reads a directory of images and bundles things into an asset catelog readable by XCode. 

import sys
import os
import argparse
import pip 
import json 

from glob import glob
from utils import checkForPackage


# read arguments
parser = argparse.ArgumentParser()
parser.add_argument('--image_dir',type=str)
parser.add_argument('--output_dir',type=str)

args = parser.parse_args()

############## CHECK FOR REQUIREMENTS ############ 



################ SETUP VARIABLES ################## 
image_dir = "" 
if(args.image_dir == None):
    image_dir = "/"
else:
    image_dir = args.image_dir

output_dir = ""
if(args.output_dir == None):
    output_dir = "/"
else:
    output_dir = args.image_dir

################ LOOK TO SEE IF THIS PROCESS IS WORTHWHILE ################## 
# this is really meant for someone that has a fairly large number of assets to use, if
# your app only has a few images, this probably isn't worth using and it might be easier to 
# just use xcode to add your asset catelog. 
images = glob(image_dir)

if(len(images) < 50):
    print("This script probably is not worth running since you appear to not have many images.")
    print("Are you sure you want to continue using this? It will wipe out any additions already made")
    answer = input("Press y to continue or n to quit... \n")

    if(answer == "n"):
        sys.exit()    
    

        


################ CHECK IF ASSETS CATALOG EXISTS ################## 

# Note that - if it does exist, this script will overwrite any work you might have already done. 

# first check of Image.xcassets folder exists
base_path = "Image.xcassets"
if(os.path.exists(base_path) == False):
    print("Asset catalog doesn't appear to exist - building the full tree...")
    os.makedirs(base_path)

# next check for all the neceessary folders and create if need be
paths = [
    "AppIcon.appiconset",
    "Image.imageset",
    "LaunchImage.launchimage"
]
    
for path in paths:
    fullpath = base_path + "/" + path
    if(os.path.exists(fullpath) == False):
        os.makedirs(fullpath)

# also may need a contents.json file 
default_contents_json= "{\"info\" : {\"version\" : 1,\"author\" : \"xcode\"}}"
if(os.path.exists(base_path + "/" + "Contents.json") == False):
    file_obj = open(base_path + "/" + "Contents.json", "w")
    file_obj.write(default_contents_json)
    file_obj.close()
