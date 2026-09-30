# 1D Grid definition
# ------------------

line x location= 0.0      spacing=  1<nm> tag= SiTop       
line x location= 10<nm>   spacing=  2<nm>                 
line x location= 50<nm>   spacing= 10<nm>                  
line x location= 300<nm>  spacing= 20<nm>                  
line x location= 0.5<um>  spacing= 50<nm>                  
line x location= 2.0<um>  spacing= 0.2<um> tag= SiBottom    


# Initial simulation domain
# -------------------------

region Silicon xlo= SiTop xhi= SiBottom 


# Initialize the simulation
# -------------------------

init concentration= 1.0e15<cm-3> field= Boron 
AdvancedCalibration

# Global Mesh settings for automatic meshing in newly generated layers
# --------------------------------------------------------------------

grid set.min.normal.size= 3<nm> set.normal.growth.ratio.2d= 1.4


set SCREEN Grow

if { $SCREEN == "Grow" } {

# Growing screening oxide
# -----------------------

gas_flow name= O2_1_N2_1 pressure= 1<atm> flowO2= 1.2<l/min> flowN2= 1.0<l/min>
diffuse temperature= 900<C>  time= 40<min> gas.flow= O2_1_N2_1

# Measuring the oxide thickness
# -----------------------------

select z=1
layers

} else {

# Depositing screening oxide
# --------------------------

deposit material= {Oxide} type= isotropic time= 1.0 rate= {0.01}
diffuse temperature= 900<C>  time= 40<min> 

}

# Implanting Arsenic
# ------------------

implant Arsenic energy= 30<keV> dose= 1e14<cm-2> tilt= 7<degree>  rotation= 0<degree> 

# Plotting out the "as implanted" profile
# ---------------------------------------

SetPlxList { BTotal Arsenic_Implant }
WritePlx n@node@_1DasImpl.plx

# Thermal annealing
# -----------------

diffuse  temperature= 1000<C> time= 30<min>
strip Oxide

SetPlxList { BTotal BActive AsTotal AsActive }
WritePlx   n@node@_1Danneal.plx

exit

