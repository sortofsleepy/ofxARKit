
import pip 
import os
import json 
import struct 

# check if we have the required packages
installed_packages = pip.get_installed_distributions()
installed_packages = [package.project_name for package in installed_packages]

# checks to see if the required package is available and installs it if it isn't. 
# note - this may not be needed now since we can find the image dimensions with the below function
# Also note - currently unused but may use in the future
def checkForPackage(name=None):
    if name not in installed_packages:
        pip.main(['install',name])

    
# writes a json file to disk using a python dictionary while also preserving newlines.
def write_json(base_path=None,filename=None,jsonobj=None):
    if filename == None or base_path == None or jsonobj == None:
        print("write_json() - a required parameter is missing")
        return
    
    if(os.path.exists(base_path + "/" + filename) == False):
        file_obj = open(base_path + "/" + filename, "w")
        json.dump(jsonobj,file_obj,indent=4)
        file_obj.close()


# converts pixel to inches
def pixels_to_inches(value):
    # TODO 96 ppi might not work totally well, needs testing
    return value / 96


# returns the image dimensions
# code based on code from @scardiine 
# https://github.com/scardine/image_size
# the checking function is a little unreliable though so that's been taken out in 
# favor of just using filenames  
# supports only jpgs and pngs since those are the most common

def get_image_size(filepath):
    with open(filepath,"rb") as input:
        height = -1
        width = -1
        data = input.read(26)
        size = os.path.getsize(filepath)
     
        filename, extension = os.path.splitext(filepath)

        if(extension == ".png"):
            # unpack png
            w,h = struct.unpack(">LL",data[16:24])
            width = int(w)
            height = int(h)
       
        if(extension == ".jpg"):
            input.seek(0)
            input.read(2)
            b = input.read(1)
            try:
                while (b and ord(b) != 0xDA):
                    while (ord(b) != 0xFF):
                        b = input.read(1)
                    while (ord(b) == 0xFF):
                        b = input.read(1)
                    if (ord(b) >= 0xC0 and ord(b) <= 0xC3):
                        input.read(3)
                        h, w = struct.unpack(">HH", input.read(4))
                        break
                    else:
                        input.read(
                            int(struct.unpack(">H", input.read(2))[0]) - 2)
                    b = input.read(1)
                width = int(w)
                height = int(h)
            
            except struct.error:
                raise UnknownImageFormat("StructError" + msg)
            except ValueError:
                raise UnknownImageFormat("ValueError" + msg)
            except Exception as e:
                raise UnknownImageFormat(e.__class__.__name__ + msg)

          
    return {
        "width":width,
        "height":height
    }


        


