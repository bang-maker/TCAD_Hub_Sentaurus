# 1D NPN Vertical Bipolar Transistor
# ----------------------------------

# Declare Initial grid
# --------------------

line x location= 4.0<um>   tag= SubTop      spacing= 20.0<nm>
line x location= 4.5<um>                    spacing= 40.0<nm>
line x location= 6.0<um>   tag= SubBottom   spacing= 0.2<um>

region Silicon xlo= SubTop xhi= SubBottom
init concentration= 1e+15<cm-3> field= Boron 

AdvancedCalibration

# Global Mesh settings for automatic meshing in newly generated layers
# --------------------------------------------------------------------

grid set.normal.growth.ratio.2d= 1.1 set.min.normal.size= 20<nm>  

# Buried layer (deposit screen ox, implant)
# -----------------------------------------
 
deposit Oxide type= isotropic thickness= 25.0<nm>
implant Antimony dose= 1.5e15<cm-2> energy= 100.0<keV> tilt= 0 rotation= 0 

SetPlxList {BTotal Antimony_Implant}
WritePlx n@node@_Sbasimp.plx

# Partial drive-in
# ----------------

diffuse temperature= 1100<C> time= 1<hr> 
strip Oxide

SetPlxList {BTotal SbTotal}
WritePlx n@node@_Sbdrive.plx

# Create Epi layer
# ----------------

deposit material= Silicon type= isotropic rate= 1.0<um/min> time= 4.0<min> species= Arsenic concentration= 1e15<cm-3>
diffuse temperature= 1100<C> time= 1<hr> 

SetPlxList {BTotal SbTotal AsTotal}
WritePlx n@node@_Epi.plx

# Base screen oxide, implant and drive-in
# ---------------------------------------

deposit Oxide type= isotropic thickness= 25.0<nm>
implant Boron dose= 1e14<cm-2> energy= 50<keV> tilt= 7<degree> rotation= 0 
diffuse temperature= 1000<C> time= 50<min> 

# Emitter screen oxide, implant and activation
# --------------------------------------------

implant Arsenic dose= 2e15<cm-2> energy= 55<keV> tilt= 7<degree> rotation= 0 
diffuse temperature= 1000<C> time= 35<min> 

# Show the final profiles
# -----------------------

SetPlxList {BActive SbActive AsActive}
WritePlx n@node@_Final.plx

exit




