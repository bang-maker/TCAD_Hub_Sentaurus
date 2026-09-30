proc Perform_Anneal { } {
   line clear
   init tdr=n@node@_Implant
   diffuse temperature= 1100<C> time= 2<hr>
}

pdbSet Silicon Dopant DiffModel Constant
line x location= 0.0<um>   tag= SubTop      spacing= 20.0<nm>
line x location= 2.0<um>   tag= SubBottom   spacing= 20.0<nm>
region Silicon xlo= SubTop xhi= SubBottom
init concentration= 1e+10<cm-3> field= Boron

implant species= Boron Silicon gaussian
implant Boron dose= 1e14<cm-2> energy= 400.0<keV> 
struct tdr= n@node@_Implant

SetPlxList {Boron_Implant}
WritePlx n@node@_Implant.plx
SetPlxList {BTotal}

# Step 1: Do nothing.  Accept defaults before anneal.
Perform_Anneal
WritePlx n@node@_No_xfer.plx

# Step 2: Make the surface a Boron sink.
pdbSet Gas_Silicon Boundary BoundaryCondition Dirichlet
pdbSetDouble Silicon Boron Cstar 1e10
Perform_Anneal
WritePlx n@node@_Dirichlet_sink.plx

# Step 3: Make the surface a Boron source.
pdbSet Gas_Silicon Boundary BoundaryCondition Dirichlet
pdbSetDouble Silicon Boron Cstar 1e19
Perform_Anneal
WritePlx n@node@_Dirichlet_source.plx

# Step 4: Change the surface back to reflecting and increase clustering.
pdbSet Gas_Silicon Boundary BoundaryCondition HomNeumann
pdbSet Silicon Boron AcInit 1e17
pdbSet Silicon Boron CluRate {[Arrhenius 5e6 5.6]} ;# 1.65e13 5.6
Perform_Anneal 
WritePlx n@node@_Clustered.plx

exit

