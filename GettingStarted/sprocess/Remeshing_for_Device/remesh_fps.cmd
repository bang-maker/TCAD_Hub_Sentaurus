#setdep @previous@
init tdr= @[relpath n@previous@]@

refinebox clear

line clear
grid set.Delaunay.type= boxmethod

# refinebox name= Global xrefine= 0.25 yrefine= 0.15

#if @case@==1
refinebox min= {0 0.1} max= {0.2 0.4} xrefine= 0.010 yrefine= 0.020
#endif

#if @case@==2
refinebox PolySilicon xrefine= 0.010 yrefine= 0.020
#endif

#if @case@==3
refinebox regions= { Oxide_1.1 } xrefine= 0.010 yrefine= 0.020
#endif

#if @case@==4
refinebox interface.mat.pairs= {Silicon Oxide} \
 min.normal.size	= 0.005 normal.growth.ratio= 1.5
#endif

#if @case@==5
refinebox offsetting interface.materials= {Silicon} offsetting.maxlevel= 10 
refinebox offsetting interface.mat.pairs= {Silicon Oxide} \
	min.normal.size= 0.003 normal.growth.ratio= 1.3
#endif

#if @case@==6
grid set.min.normal.size= 0
refinebox offsetting interface.regions= {Silicon_1} offsetting.maxlevel= 10 
refinebox offsetting interface.region.pairs= {Silicon_1 Oxide_1.1} \
	min.normal.size= 0.003 normal.growth.ratio= 1.3
#endif

#if @case@==7
refinebox Silicon refine.fields= {NetActive} max.asinhdiff= {NetActive=1.0} \
	refine.min.edge= {0.004 0.004} refine.max.edge= {0.25 0.15}
#endif

#if @case@==8
refinebox interface.mat.pairs= {Silicon Oxide} \
        min= {0.4 0.3} max= {0.5 0.5} \
	min.normal.size= 0.002 normal.growth.ratio= 1.5
#endif

#if @case@==9
pdbSet Grid MGoals UseLines 1
line x location= 0.1
line x location= 0.2
line x location= 0.4

line y location= 0.1
line y location= 0.2
line y location= 0.3
line y location= 0.4
#endif

grid remesh

struct tdr= n@node@ !Gas !interfaces

