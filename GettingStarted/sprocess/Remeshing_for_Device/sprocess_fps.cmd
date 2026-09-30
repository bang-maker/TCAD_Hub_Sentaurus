

line x location= 0    spacing= 0.01 tag= top
line x location= 0.15 spacing= 0.02
line x location= 1.0  spacing= 0.2  tag= bottom

line y location= 0.0      spacing= 0.1*@Lg@  tag= left
line y location= 0.5*@Lg@ spacing= 0.05*@Lg@
line y location= 1.5*@Lg@ spacing= 0.2*@Lg@
line y location= 2*@Lg@   spacing= @Lg@      tag= right 

region Silicon xlo= top xhi= bottom ylo= left yhi= right 

# step Init
init concentration= 1e17 field= Boron slice.angle= 180 !DelayFullD

# step STI
deposit Oxide thickness= 0.010
deposit Nitride anisotropic thickness= 0.1
mask name= ACTIVE right= 1.5*@Lg@
etch Nitride type= anisotropic thickness= 0.12 mask= ACTIVE
etch Oxide  type= anisotropic thickness= 0.02
etch Silicon type= trapezoidal thickness= 0.4 angle= 80
diffuse time= 1 temperature= 950 H2O
deposit Oxide type= fill coord= -0.02
strip Nitride
etch Oxide type= isotropic thickness= 0.015

# step Gate Oxidation
pdbSet Oxide Grid perp.add.dist 0.01e-4 
diffuse time= 10 temperature= 950 O2

# step Deposit poly
deposit PolySilicon type= anisotropic thickness= 0.1 
# step Poly Mask
mask name= poly left=-@Lg@/2 right= @Lg@/2
# step Etch Poly
etch PolySilicon type= anisotropic thickness= 0.12 mask= poly
etch Oxide type= anisotropic thickness= 0.02

# step LDD implant
implant Arsenic dose= 1e14 energy= 20
# step Spacer formation
deposit Nitride type= isotropic thickness= 0.3*@Lg@
etch  Nitride type= anisotropic thickness= 0.35*@Lg@
# step SD Implant
implant Phosphorus dose= 1e15 energy= 15
# step SD Anneal
diffuse time=1<s> temperature= 1000

# step contactSD
deposit Aluminum type= anisotropic thickness= 0.05
mask name= contact left=@Lg@*0.9 right=@Lg@*1.2
etch Aluminum type= anisotropic thickness= 0.1 mask= contact 

# step save
struct tdr=n@node@ !Gas !interfaces bnd

