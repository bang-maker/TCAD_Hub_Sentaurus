#setdep @node|NMOS@
## ------------------------------------------------------------------------------
## Meshing for Device Simulation
## ------------------------------------------------------------------------------
## Clear all the lines and refineboxes defined earlier for the process simulation
## ------------------------------------------------------------------------------
init tdr= @[relpath n@node|NMOS@_before_mesh]@
refinebox clear
line clear

grid Adaptive set.Delaunay.type= boxmethod set.min.normal.size= @<dmesh * 0.01>@ set.normal.growth.ratio.2d= 2.0
pdbSet Grid AdaptiveField Refine.Abs.Error     1e37
pdbSet Grid AdaptiveField Refine.Rel.Error     1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0

refinebox name= Global \
	  refine.max.edge= "1.0 0.3" refine.min.edge= "@<dmesh * 0.03>@ @<dmesh * 0.03>@" \
	  refine.fields= { NetActive } def.max.asinhdiff= 0.28 \
	  adaptive Silicon add 

## Refinement in the MOS channel region 
refinebox name= Ref_channel min.normal.size= @<dmesh * 0.002>@ normal.growth.ratio= 2.0 \
 	  interface.materials= { Silicon } min= { $p_nplus $trench_l } max= "[expr $trench_d + 0.5] [expr $trench_l+ 0.5]"

## Offset mesh for Si-Si02 interface
refinebox offsetting min.normal.size= 0.002 normal.growth.ratio= 2.8 \
          interface.mat.pairs= { Silicon Oxide Oxide PolySilicon} 

## Source contact meshing (only for SBD-TG-NMOS device)
#if @<[string compare SBD "YES"] == 0>@
refinebox name= "Ref_source" min.normal.size= 0.01 normal.growth.ratio= 1.5 \
	  interface.materials= {Silicon Gas} min= "0.0 2.4" max= "1.0 3.0"
#endif

grid remesh

## Save TDR for device simulation
struct tdr= n@node@_final interfaces

## End of re-meshing for Sentaurus Device Simulation  
