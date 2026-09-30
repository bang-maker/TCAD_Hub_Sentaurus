
##start - lines
line x location= 0.0<um>  spacing= @res@<um>   tag= top
line x location= @l@<um>  spacing= @res@<um>   tag= bottom
line y location= -2.0<um> spacing= @res@<um>   tag= left
line y location= 0.0<um>  spacing= @res@<um>
line y location= 2.0<um>  spacing= @res@<um>   tag= right
line z location= -2.0<um> spacing= @res@<um>   tag= back
line z location= 0.0<um>  spacing= @res@<um>
line z location= 2.0<um>  spacing= @res@<um>   tag= front
##end - lines

##start - materials
pdbSet Silicon Mechanics BulkModulus [Enu2K 1e10 0.2]
pdbSet Silicon Mechanics ShearModulus [Enu2G 1e10 0.2]
##end - materials

##start - regions
region silicon substrate xlo= top xhi= bottom ylo= left yhi= right zlo= back zhi= front
##end - regions

##start - init
init !DelayFullD
##end - init

##start - struct init
struct tdr=n@node@_init
##end - struct init

##start - BCs
stressdata bc.location=Bottom bc.value= {dx=0 dy=0 dz=0}
stressdata bc.location=Left bc.value= {sx=0 sy=0 sz=0}
stressdata bc.location=Right bc.value= {sx=0 sy=0 sz=0}
stressdata bc.location=Back bc.value= {sx=0 sy=0 sz=0}
stressdata bc.location=Front bc.value= {sx=0 sy=0 sz=0}
stressdata bc.location=pointend point.coord= {0 0 0} bc.value= {pfx=0 pfy=0 pfz=@p@<dyn>}
##end - BCs

##start - solution
mode mechanics
solve 
##end - solution

##start - struct final
struct tdr=n@node@
struct tdr=n@node@_def deform deform.scale= 5.0
##end - struct final

##start - postprocessing
select z="Displacement_z"
plot.1d y=0 z=0
##end - postprocessing


