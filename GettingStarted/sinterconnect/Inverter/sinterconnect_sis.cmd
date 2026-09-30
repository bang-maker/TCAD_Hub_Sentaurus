# --- inverter.sis: Simplified Inverter ---

# --- Define a new material and
# set the permittivity for electrostatic analysis ---
mater add name= DIEL new.like= Oxide
pdbSet DIEL Potential Permittivity 3.0

# --- Initial 3D grid ---
line x location= 0.0
line x location= 0.1
line y location= 0.0
line y location= 1.5
line z location= 0.0
line z location= 1.0

# --- Initial simulation domain ---
region Silicon

# --- Initialize the simulation ---
init

# --- Settings for automatic meshing in newly generated layers ---
pdbSet Grid SnMesh min.normal.size 0.050
# --- Interface refinement ---
refinebox min.normal.size= 0.05 interface.materials= { Copper DIEL }

# --- Define polygons ---
polygon name= p1 \
  segments= {0.55 0.50 1.6 0.50 1.6 0.65 1.4 0.65 1.4 0.55 0.55 0.55}
polygon name= p2 min= {0.4 0.3}   max= {0.7 0.7}  rectangle
polygon name= p3 min= {1.25 0.35} max= {1.75 0.5} rectangle
polygon name= p4 min= {1.4 0.55}  max= {1.6 0.65} rectangle

# --- Define masks ---
mask clear
mask name= m1 polygons= {p1} negative
mask name= m2 left= 1.47 right= 1.53 front= 0.55 back= 0.60 negative
mask name= m3 polygons= {p2 p3 p4}

# --- Set pdb parameters to omit stress relaxation during etching/deposition ---
pdbSet Mechanics EtchDepoRelax 0
pdbSet Mechanics StressHistory 0

# --- Structure generation ---
deposit DIEL thickness= 0.1 isotropic
deposit Copper thickness= 0.03 anisotropic mask= m1

deposit DIEL coord= -0.35 fill
etch    DIEL thickness= 0.3 anisotropic mask= m2
deposit Copper coord= -0.35 fill

deposit Copper coord= -0.4 fill
etch    Copper thickness= 0.1 anisotropic mask= m3
deposit DIEL coord= -0.9 fill

transform reflect right

#split @Electrostatic@

# --- Define contacts ---
contact name= c0 x=  0.05 y= 1.5 z= 0.5 point Silicon !replace
contact name= c1 x= -0.38 y= 1.5 z= 0.6 point Copper !replace
contact name= c2 x= -0.38 y= 1.5 z= 0.4 point Copper !replace
contact name= c3 x= -0.38 y= 0.6 z= 0.5 point Copper !replace
contact name= c4 x= -0.38 y= 2.4 z= 0.5 point Copper !replace

# --- Define supplies ---
supply contact.name= c0 voltage= 0.0
supply contact.name= c1 voltage= 0.0
supply contact.name= c2 voltage= 1.0
supply contact.name= c3 voltage= 0.0

# --- Define solve mode ---
mode electrostatic

# --- Electrostatic simulation ---
solve info= 2

struct tdr= n@node@


