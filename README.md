# node-ito-transcoder
The transcoder is a shell application with node bindings for file transcoding.

## STATUS ##

This is currently unstable. The version beginning at 2 is due to the porting of previous work. This is a total rewrite with breaking changes to the API.

## GET STARTED ##

You'll want to first `git clone` the repository, change into the `bin/` directory and execute `sudo ./build.sh`

This will download, configure and install all of the third-party components (On Ubuntu.) 

However, we are working on making a transcoder VM that you can download and try out the system. Indeed, it is probably better to run the transcoder in a VM because some processes can be resource greedy, and that way you can guarantee some system stability.



### LICENSE ###

This package is licensed for use under the GPL-3, however some components are sub-licensed under LGPL-3, PD or Apache MIT. In those cases the licenses of the respective components are marked in their headers. What this means for you: If you use the ITO-SUITE with the transcoding module, then you are bound by the GPL.

Furthermore, the installation builds and installs dozens of third party pieces of software using many different license schemes. Please consult the wiki page "Licenses" for further guidance.