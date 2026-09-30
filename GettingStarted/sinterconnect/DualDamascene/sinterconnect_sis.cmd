# --- 3D Damascene process ---

# --- Initial 3D grid ---
line x location= 0.0      spacing= 0.05<um> tag= subTop
line x location= 0.1<um>  spacing= 0.05<um> tag= subBottom
line y location=-0.1<um>  spacing= 0.05<um>
line y location= 0.05<um> spacing= 0.05<um>
line z location= 0.0<um>  spacing= 0.1<um>
line z location= 0.7<um>  spacing= 0.1<um>

# --- Initial simulation domain ---
region Silicon
# --- Initialize the simulation ---
init wafer.orient= { 0 0 1 } notch.direction= { 1 1 0 }

# --- Settings for automatic meshing in newly generated layers ---
pdbSet Grid SnMesh min.normal.size  0.020 ;# 20nm
pdbSet Grid SnMesh max.lateral.size 0.100 ;# 100nm
pdbSet Grid SnMesh normal.growth.ratio.3d 2.0
# --- Remove all default refinement ---
refinebox clear
# --- Refinement by coordinates ---
refinebox name= active min= { -0.65 -0.1 0.0 } max= { -0.1 0.05 0.7 } \
	xrefine= 100<nm> yrefine= 100<nm> zrefine= 100<nm>
# --- Refinement by materials ---
refinebox name= metal materials= Copper \
	xrefine= 50<nm> yrefine= 50<nm> zrefine= 50<nm>
# --- Interface refinement ---
refinebox interface.materials= { Copper Nitride Oxide }

# --- Set pdb parameters for stress relaxation during etching/deposition ---
pdbSet Mechanics EtchDepoRelax 1
pdbSet Mechanics StressHistory 1

# --- Define Masks ---
mask clear
mask name= metal_1 left= 0.0 right= 0.1 front= 0.0 back= 0.45
mask name= via_12 left= 0.025 right= 0.1 front= 0.3 back= 0.4
mask name= metal_2 left= 0.0 right= 0.1 front= 0.25 back= 0.7

# --- Fabrication steps (Process simulation) ---
deposit Oxide temperature= 250<C> thickness= 0.1 type= isotropic
deposit Oxide temperature= 250<C> thickness= 0.2 type= isotropic
deposit Photoresist thickness= 0.1 type= isotropic mask= metal_1
etch Oxide temperature= 25<C> thickness= 0.2 type= anisotropic
deposit Copper temperature= 250<C> coord= -0.3 type= fill
strip Photoresist

deposit Nitride temperature= 250<C> coord= -0.35 type= fill
deposit Oxide temperature= 250<C> thickness= 0.1 type= isotropic
deposit Photoresist thickness= 0.1 type= isotropic mask= via_12
etch Oxide temperature= 25<C> thickness= 0.11 type= anisotropic
etch Nitride temperature= 25<C> thickness= 0.1 type= anisotropic
deposit Copper temperature= 250<C> coord= -0.46 type= fill
strip Photoresist

deposit Oxide temperature= 250<C> coord= -0.65 type= fill
deposit Photoresist thickness= 0.1 type= isotropic mask= metal_2
etch Oxide temperature= 0<C> thickness= 0.2 type= anisotropic
deposit Copper temperature= 250<C> coord= -0.65 type= fill
strip Photoresist

deposit Nitride temperature= 250<C> coord= -0.7 type= fill

#split @Mechanical@
# --- Define solve mode ---
mode mechanics
# --- Stress simulation ---
solve temperature= 25

# --- Save 1D stress profiles ---
SetPlxList { StressEL_xx StressEL_yy StressEL_zz }
WritePlx n@node@_via.plx y= 0.04 z= 0.35 Copper

#split @ElectroThermal@

# --- Contacts ---
# --- Copper's upper and lower sidewalls ---
contact Copper name= upper box sidewall \
	xlo= -0.65 xhi= -0.45 ylo= 0.0 yhi= 0.05 zlo= 0.7 zhi= 0.7
contact Copper name= lower box sidewall \
	xlo= -0.30 xhi= -0.10 ylo= 0.0 yhi= 0.05 zlo= 0.0 zhi= 0.0
# --- Structure's bottom and top ---
contact Silicon name= tm0 box  \
	xlo= 0.0 xhi= 0.0 ylo= -0.1 yhi= 0.05 zlo= 0.0 zhi= 0.7
contact Nitride name= tm1 box  \
	xlo= -0.7 xhi= -0.7 ylo= -0.1 yhi= 0.05 zlo= 0.0 zhi= 0.7

# --- Supplies ---
# --- Electrical supplies ---
supply contact.name= upper voltage= 0.1<V>
supply contact.name= lower voltage= 0.0<V>
# --- Thermal supplies ---
supply contact.name= tm0 temperature= 100<C>
supply contact.name= tm1 temperature= 25<C>

# --- Define new solve mode ---
mode mechanics current thermal
# --- Mechanical, thermal, and electrical analyses simulation ---
solve time= 1<s>
# --- Save structure ---
struct tdr= n@node@


