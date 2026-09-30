
init tdr="@pwd@/start_fps.tdr"

#-----------------------------------#
## Prepare for Device Simulations
deposit Aluminum thickness= 0.2<um> anisotropic selective.materials= {Silicon}

## Contact Definition
contact name= "gate" point x=-0.2 y=0.5 z=0.5 PolySilicon replace

	
contact name= "emitter" point x=-0.1 y=2.0 z=0.5 Aluminum replace

contact name= "collector" box Silicon \
   xlo=@<PT-0.1>@ ylo=0.0 zlo=0.0 \
   xhi=@<PT+0.1>@ yhi=$Ymax zhi=$Zmax

## Meshing for Device Simulation
refinebox clear
line clear
pdbSet Grid AdaptiveField Refine.Abs.Error     1e37
pdbSet Grid AdaptiveField Refine.Rel.Error     1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0
pdbSet Grid Adaptive 1
# Set high quality delaunay meshes
pdbSet Grid SnMesh DelaunayType boxmethod
pdbSet Grid sMesh 1
pdbSet Grid SnMesh DelaunayTolerance 0.0
pdbSet Grid SnMesh MaxPoints 1e8
pdbSet Grid SnMesh MaxConnectivity 100
pdbSet Grid SnMesh SliverRemovalAlgorithm 2
pdbSet Grid SnMesh StoreDelaunayWeight 1
pdbSet Grid Contacts.In.Brep 1


## Refinement boxes
refinebox name= Ref_Global \
	  refine.max.edge= "10.0 0.3 0.3" refine.min.edge= "@<dmesh * 2.0>@ @<dmesh * 0.15>@ @<dmesh * 0.15>@" \
	  refine.fields= { NetActive } def.max.asinhdiff= 3.0 adaptive Silicon 
	  
refinebox name= topref1 \
	  refine.max.edge= "0.1 0.2 0.2" refine.min.edge= "@<dmesh * 0.06>@ @<dmesh * 0.03>@ @<dmesh * 0.03>@" \
	  refine.fields= { NetActive } def.max.asinhdiff= 1.8 adaptive Silicon \
	  min= "0.0 0.0 0.0" max= "0.6 $Ymax $Zmax" 
	  
refinebox name= topref2 \
	  refine.max.edge= "0.05 0.2 0.2" refine.min.edge= "@<dmesh * 0.02>@ @<dmesh * 0.02>@ @<dmesh * 0.02>@" \
	  refine.fields= { NetActive } def.max.asinhdiff= 1.8 adaptive Silicon \
	  min= "0.0 0.0 0.0" max= "0.2 $Ymax $Zmax" 	 
	  	  
refinebox name= botref1 \
	  refine.max.edge= "0.2 0.3 0.3" refine.min.edge= "@<dmesh * 0.06>@ @<dmesh * 0.03>@ @<dmesh * 0.03>@" \
	  refine.fields= { NetActive } def.max.asinhdiff= 1.5 adaptive Silicon \
	  min= "@<PT-1.5>@ 0.0 0.0" max= "@PT@ $Ymax $Zmax" 	  
	  
refinebox name= botref2 \
	  refine.max.edge= "0.5 0.3 0.3" refine.min.edge= "@<dmesh * 0.05>@ @<dmesh * 0.05>@ @<dmesh * 0.05>@" \
	  refine.fields= { NetActive } def.max.asinhdiff= 1.5 adaptive Silicon \
	  min= "@<PT-5.0>@ 0.0 0.0" max= "@PT@ $Ymax $Zmax" 	  
	
# refinements for poly-gate oxide
refinebox name= Channel \
  min= "-0.02  0.0 0.0" max= "0.03 1.1 1.1" \
  min.normal.size= 6.0e-3 normal.growth.ratio= 3.0 max.lateral.size= 2.0 \
  interface.mat.pairs= {Silicon Oxide}
	
## for more information on grid statistics; set info= 2
grid remesh info= 1

## Final TDR output file
struct tdr=n@node@
exit

