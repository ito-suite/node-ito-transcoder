#!/bin/bash

echo 'We should try to do something with these, now that we know their mime-types.'

# Explicitly cite in your work that you have used MeshLab, a tool developed with the support of the 3D-CoForm project,

#  STL,OBJ
#    convert obj -> stl
#    make thumb of stl -> stl2pov
#      stl2pdf infile [outfile] [x degrees | y degrees | z degrees ...]
#      convert outfile >jpg
#   ps-stl-3.1.zip
#   http://rsmith.home.xs4all.nl/software/py-stl-stl2pov.html
#   create a U3D (for pdf embedding) with meshlab.

# other tools for this
# meshconv <model filespec> [-c <output filetype>] [-o <output filename>] [<options>]
# > dxf obj off ply stl wrl
# eg: meshconv /home/models/train.off -c ply -tri -o /home/ply/train

# stl2ps.py

# Xvfb & disown
# DISPLAY=:0 meshlabserver