AdvancedCalibration


line x location= 0.0     spacing= 0.05<um> tag= bottom
line x location= 0.4<um> spacing= 0.05<um> tag= top

line y location= 0.0     spacing= 0.05<um> tag= left
line y location= 1.5<um> spacing= 0.05<um> tag= right

line z location= 0.0     spacing= 0.05<um> tag= front 
line z location= 1.0<um> spacing= 0.05<um> tag= back


region Silicon xlo= bottom xhi= top ylo= left yhi= right zlo= front zhi= back 
init   concentration= 1.4e+15<cm-3> field= Boron 

grid set.min.normal.size= 0.1
grid set.normal.growth.ratio.3d= 2.0

struct tdr= n@node@_0

deposit PolySilicon anisotropic thickness= 0.2
mask name= poly1 left= 0.3 right= 0.5 front= 0.25 back= 0.75 
mask name= poly1 left= 0.625 right= 0.875 front= 0.375 back= 0.625
mask name= poly1 left= 1.0 right= 1.2 front= 0.25 back= 0.75 
etch PolySilicon anisotropic thickness= 0.25 mask= poly1


deposit Nitride anisotropic thickness= 0.2
mask name= nit1 left= 0.5 right= 1.0 front= 0.25 back= 0.75 
etch Nitride anisotropic thickness= 0.25 mask= nit1
etch cmp coord= -0.2

struct tdr= n@node@_1


beam name= src1 direction= {1 0 0} factor= 1
mgoals dx= 0.01 dy= 0.01 dz= 0.01
etch sources= {src1} type= fourier !remesh time= 0.1 \
  mat.coeffs= {Silicon= {-1 2} Nitride= {-0.7 1.2} Oxide= { 0.01 } \
  PolySilicon= {-0.05 0.2}}

struct tdr= n@node@_2

exit
