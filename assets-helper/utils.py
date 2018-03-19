
import pip 

# check if we have the required packages
installed_packages = pip.get_installed_distributions()
installed_packages = [package.project_name for package in installed_packages]

# checks to see if the required package is available and installs it if it isn't. 
def checkForPackage(name=None):
    if name not in installed_packages:
        pip.main(['install',name])

    
