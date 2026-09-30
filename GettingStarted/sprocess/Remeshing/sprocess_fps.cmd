

## Grid 
## ----

line x location= -0.15 spacing= 0.01  tag= GateTop    
line x location= -0.02 spacing= 0.005                 
line x location= -0.01 spacing= 0.005 tag= OxTop      
line x location=  0.0  spacing= 0.005 tag= SiTop      
line x location=  0.05 spacing= 0.01                  
line x location=  0.5  spacing= 0.05                 
line x location=  1.0  spacing= 0.2   tag= SiBottom   
                              
line y location= 0.0   spacing= 0.05  tag= Mid        
line y location= 0.1   spacing= 0.05  tag= Gate       
line y location= 0.4   spacing= 0.05  tag= Right      

## Structure definition
## --------------------

region Silicon xlo= SiTop   xhi= SiBottom ylo= Mid yhi= Right
region Oxide   xlo= OxTop   xhi= SiTop    ylo= Mid yhi= Right
region PolySilicon    xlo= GateTop xhi=OxTop    ylo= Mid yhi= Gate

## Start simulation
## ----------------

init concentration= 1.00e+15 field= Phosphorus
struct tdr= n@node@_grid_mg0

## Remeshing
## ---------

grid set.min.normal.size= 0.01  set.normal.growth.ratio.2d= 2.0
grid remesh
struct tdr= n@node@_grid_mg1

grid set.min.normal.size= 0.002 set.normal.growth.ratio.2d=2.0
grid remesh
struct tdr= n@node@_grid_mg2

grid set.min.normal.size= 0.002 set.normal.growth.ratio.2d= 1.2
grid remesh
struct tdr= n@node@_grid_mg3

exit

