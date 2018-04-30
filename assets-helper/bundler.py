# Asset catalog builder
# reads a directory of images and bundles things into an asset catelog readable by XCode.
# Note that this assumes you've added an Assets.xcassets folder to your project.

import sys
import os
import argparse
import pip

from shutil import copyfile
from os import path
from utils import write_json,get_res,get_image_size


# read arguments
parser = argparse.ArgumentParser()
parser.add_argument('--image_dir',nargs='?',default='./', type=str)
parser.add_argument('--output_dir',nargs='?', default='./',type=str)

args = parser.parse_args()

################ SETUP VARIABLES ##################
image_dir = args.image_dir 
output_dir = args.output_dir


################ LOOK TO SEE IF THIS PROCESS IS WORTHWHILE ##################
# this is really meant for someone that has a fairly large number of assets to use, if
# your app only has a few images, this probably isn't worth using and it might be easier to
# just use xcode to add your asset catelog.
images = [f for f in os.listdir(image_dir)]


if(len(images) < 50):
    print("This script probably is not worth running since you appear to have only a few images.")
    print("Are you sure you want to continue using this? It may wipe out any additions already made")
    answer = input("Press any key to continue or n to quit... \n")

    if(answer == "n"):
        sys.exit()

# if there are no images, we also quit.
if len(images) < 0:
    print("no images were found! Quitting")
    sys.exit()

################ CHECK IF ASSETS CATALOG EXISTS ##################

# first check of Image.xcassets folder exists
base_path = output_dir + "/Image.xcassets"
if(os.path.exists(base_path) == False):
    print("Asset catalog doesn't appear to exist - building the full tree...")
    os.makedirs(base_path)

# next check for all the neceessary folders and create if need be
# TODO maybe add option to generate all folders?
paths = [
    #"AppIcon.appiconset",
    "Image.imageset",
    #"LaunchImage.launchimage"
]

for path in paths:
    fullpath = base_path + "/" + path
    if(os.path.exists(fullpath) == False):
        os.makedirs(fullpath)

# also may need a contents.json file
default_contents_json = {
    "info":{
        "version":1,
        "author":"xcode"
    }

}

# write contents.json file if it doesn't exist.
if(os.path.exists(output_dir + "/" + "Contents.json") == False):
    write_json(output_dir,"Contents.json",default_contents_json)

################ START BUILDING DICTIONARY ###############

'''
 We're operating on the assumption that all the image recognition examples focus on items in the
 Image.xcassets directory.

 To seperate retina from non-retina your images should be defined in the following manner

 <name>_<type - either 1x,2x or 3x>.<file extension>

'''

# prepared data that we're gonna output.
images_struct = {
    "images":[],
    "info" : {
        "version" : 1,
        "author" : "xcode"
    }
}

for image in images:
 
    # check the res (normal, retina, etc)
    ext = get_res(image)
    
    # get dimensions of the photo
    dims = get_image_size(image_dir + "/" + image)

    # setup dictionary
    data = {
        "idiom":"universal",
        "filename":image
    }


    if ext == "1x":
        data["scale"] = "1x"
    elif ext == "2x":
        data["scale"] = "2x"
    else:
        data["scale"] = "3x"

    # append info to our directory
    images_struct["images"].append(data)

    # now copy the image into the Image.imageset folder
    copyfile(image_dir + "/" + image, output_dir + "/Image.xcassets/Image.imageset/" + image)

# finally, write out the dictionary into the folder 
write_json(base_path + "/Image.imageset/","Contents.json",images_struct)



    
