


## Grid
## ----

line x location= -0.15 spacing= 0.03 tag= GateTop    
line x location= -0.02 spacing= 0.03                 
line x location= -0.01 spacing= 0.03 tag= OxTop      
line x location=  0.0  spacing= 0.03 tag= SiTop      
line x location=  0.05 spacing= 0.05                  
line x location=  0.5  spacing= 0.10                  
line x location=  1.0  spacing= 0.20 tag= SiBottom   
                              
line y location= -0.4   spacing= 0.10 tag= Left       
line y location= -0.1   spacing= 0.10 tag= GateL      
line y location= 0.1   spacing= 0.10 tag= GateR      
line y location= 0.4   spacing= 0.10 tag= Right       

# Structure definition 
# --------------------

region Silicon xlo= SiTop   xhi= SiBottom ylo= Left  yhi= Right
region Oxide   xlo= OxTop   xhi= SiTop    ylo= Left  yhi= Right
region PolySilicon    xlo= GateTop xhi= OxTop    ylo= GateL yhi= GateR

## Start simulation
## ----------------

init concentration= 1.00e+15 field= Phosphorus
struct     tdr= n@node@_grid_rb0

## Remeshing
## ---------

grid set.min.normal.size= 0.005 set.normal.growth.ratio.2d= 2.0
grid remesh 
struct tdr= n@node@_grid_rb1

## refinebox 1
## -----------

refinebox  min= {-0.1  0.05 }  max= { 0.1  0.15 }  \
           xrefine= {0.015} yrefine= {0.015}   all add

 grid       remesh
struct     tdr= n@node@_grid_rb2

## refinebox 2
## -----------

refinebox  min= {-0.1  -0.2 }  max= { 0.1  -0.05 } \
           xrefine= {0.015}  yrefine= {0.005 0.015 0.0025} Silicon add
 grid       remesh
struct     tdr= n@node@_grid_rb3

exit

