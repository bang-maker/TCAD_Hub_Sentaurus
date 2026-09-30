#rem # PARALLEL 
math numThreads= 8

# New Solver Enhancement ( Parallelization)
pdbSet Math diffuse 3D ILS.hpc.mode 2
pdbSet ImplantData ResistSkip 1

#-- Reflected boundary condition ---#
pdbSet ImplantData LeftBoundary  Reflect
pdbSet ImplantData RightBoundary Reflect
pdbSet ImplantData FrontBoundary Reflect
pdbSet ImplantData BackBoundary  Reflect

pdbSet Silicon SiliconGermanium.ConversionConc 2e23

## Design Rule
fset PolyPitch 0.130
fset GateThick 0.025
fset IsoPitch  0.14
fset FinPitch  0.05

fset fp 1.0

fset HFin 0.04        
fset STI_depth 0.15  
fset Tsub 0.5
 
## Fin Width
fset Wfin  0.017       ;# Z-axis in Layout (Dfin)
fset Tpoly 0.04
fset Lg    0.025       ;# Y-axis in Layout
fset gox   0.001
fset THK   0.002
fset MetalG   0.004
fset CapOx 0.005

fset PolyReox 0.002    
fset Lsp  0.0025      
fset Lspepi 0.0125

#rem #---------------------------------------------------------------------#
#rem #   LAYOUT
#rem #---------------------------------------------------------------------#

icwb filename= "FinSRAM_lyt.mac" scale= 1e-3
#rem # Loading of the "TCAD Layout" file.

#rem # Selecting the simulation domain.
icwb domain= @Domain@ 


set DIM [icwb dimension]
#rem # Query utility: Returns the dimension of the selected simulation domain.
LogFile "icwb: dimension -> $DIM"

#rem # Query utility: Returns the bounding box of the simulation
set Ymin [icwb bbox left ]
set Ymax [icwb bbox right]
set Zmin [icwb bbox back ]
set Zmax [icwb bbox front]





# -------------------------------------------------------
# initial grid and structure initialization
# -------------------------------------------------------

puts "YZ domain: $Ymin $Zmin $Ymax $Zmax"

fset Y [expr ($Ymax-$Ymin)/2.0]
fset Z [expr ($Zmax-$Zmin)/2.0]
# keep user-defined lines
pdbSetBoolean Grid MGoals UseLines 1

line x location= 0.0 tag= top
line x location= 0.1 
line x location= $Tsub tag= bottom

line y location= $Ymin spa= 0.02 tag= left
line y location= $Y
line y location= $Ymax tag= right

line z location= $Zmin tag= back
line z location= $Z
line z location= $Zmax tag= front

region silicon substrate xlo= top xhi= bottom ylo= left yhi= right zlo= back zhi= front

init field= Boron concentration= 1.5e15 wafer.orient= 100

# -------------------------------------------------------
# pdb settings
# -------------------------------------------------------



# Continuum
AdvancedCalibration

# KMC
SetAtomistic
AdvancedCalibration
UnsetAtomistic


SiGe_and_Stress_Effect 1 1 1 0


pdbSet InfoDefault 0


# turn off stress relaxation after depo/etch
pdbSet Mechanics EtchDepoRelax 0
pdbSet Grid SnMesh MaxPoints 8000000

# meshing strategy
pdbSet Grid SnMesh min.normal.size 0.005/$fp
pdbSet Grid SnMesh normal.growth.ratio.2d 2 
pdbSet Grid SnMesh normal.growth.ratio.3d 2 



icwb.create.mask layer.name= "FIN"   name= FIN   info= 1 polarity= negative
icwb.create.mask layer.name= "NWELL" name= NWELL info= 1 polarity= positive
icwb.create.mask layer.name= "NWELL" name= PWELL info= 1 polarity= negative

icwb.create.mask layer.name= "FIN"   name= FINref   info= 1 polarity= positive
icwb.create.mask layer.name= "NWELL" name= NWELLref info= 1 polarity= negative
icwb.create.mask layer.name= "NWELL" name= PWELLref info= 1 polarity= positive

refinebox interface.materials= {Silicon}




refinebox name= Total mask= "FINref" extend= 0.75 extrusion.min= 0.0 extrusion.max= $Tsub \
xrefine= " 0.5/$fp "  yrefine= " $Y/(2.0*$fp) " zrefine= " $Z/(2.0*$fp) " all add

refinebox name= FinSurf mask= "FINref" extend= 0.75 extrusion.min= -0.01 extrusion.max= $STI_depth \
min.normal.size= 0.001 normal.growth.ratio= 2.0 interface.mat.pairs= {Silicon Oxide} all add

# -------------------------------------------------------
# process flow begins
# ------------------------------------------------------- 

# Hard mask nitride
deposit material= {Oxide}   type= anisotropic  rate= {1.0} time= 0.01
deposit material= {Nitride} type= anisotropic  rate= {1.0} time= 0.1

# Fin mask
photo mask= FIN thickness= 0.02
etch material= {Nitride} type= anisotropic rate= {0.1} time= 1.1


strip Photoresist
etch material= {Oxide} type= anisotropic rate= {0.01} time= 1.1
etch material= {Silicon} type= trapezoidal rate= $STI_depth time= 1.0 angle= 88.0
strip Nitride
strip Oxide


etch    material= {Silicon} type= isotropic rate= {0.002} time= 1.0
deposit material= {Silicon} type= isotropic rate= {0.002} time= 1.0 selective.materials= {Silicon}


deposit oxide fill coord= $HFin


# Cap oxide and fill
deposit material= {Oxide} type= isotropic rate= $CapOx time= 1.0



stressdata Oxide sxxi= -5e8<Pa> syyi= -5e8<Pa> szzi= -5e8<Pa>
diffuse stress.relax time= 1e-10 temp= 600


# --------------------------------------------------------------
# WELL/Vt implant
# --------------------------------------------------------------

refinebox name= Vt mask= "FINref" extend= 0.004 extrusion.min= 0.0 extrusion.max= [expr 2*$HFin ] \
xrefine= " 0.005/$fp"  yrefine= " $PolyPitch/(6.0*$fp) " zrefine= " $FinPitch/(8.0*$fp) " all add

refinebox remesh



photo mask= PWELL thickness= 1.0


implant Boron dose= 1e13 energy= 150 tilt= 0.0
implant Boron dose= 1e13 energy= 60  tilt= 0.0
implant Boron dose= 1e13 energy= 15  tilt= 0.0

strip Photoresist


photo mask= NWELL thickness= 1.0


implant Phosphorus dose= 4.0e12 energy= 100 tilt= 0.0
implant Phosphorus dose= 5.0e12 energy= 65  tilt= 0.0
implant Arsenic    dose= 5.0e12 energy= 20  tilt= 0.0

strip Photoresist

# Well RTA

temp_ramp name= well temperature= 600<C>  time= 0.067      t.final= 900
temp_ramp name= well temperature= 900<C>  time= 0.033<min> t.final= 1050
temp_ramp name= well temperature= 1050<C> time= 0.2<min>   t.final= 750
temp_ramp name= well temperature= 750<C>  time= 0.1<min>   t.final= 600


diffuse stress.relax temp.ramp= well


etch material= {Oxide} type= cmp coord= $HFin  


#split Poly

icwb filename= "FinSRAM_lyt.mac" scale= 1e-3
icwb domain= @Domain@ 
icwb.create.mask layer.name= "GATE" name= POLY info= 1  polarity= negative

# gate stack
deposit material= {Oxide} type= isotropic rate= {1.0} time= $gox
deposit material= {HfO2} type= isotropic  rate= $THK time= 1.0


# MetalGate
mater add name= TiN new.like= Nitride
pdbSetDouble TiN Mechanics BulkModulus  [ Enu2K 600e10 0.25 ]
pdbSetDouble TiN Mechanics ShearModulus [ Enu2G 600e10 0.25 ]
pdbSetDouble TiN Mechanics ThExpCoeff   9.4e-6
deposit material= {TiN}  type= isotropic  rate= $MetalG  time= 1.0

# Poly etching (gate mask)

deposit    material= {PolySilicon} type= fill coord= -$Tpoly-$gox
deposit material= {Nitride} type= isotropic  rate= $HFin+0.05 time=1.0



photo mask= POLY thickness= 0.02


set Hmask [expr $HFin+$Tpoly]
etch material= {Nitride PolySilicon} type= anisotropic rate= {$Hmask $Hmask} time= 2.5
strip Photoresist


set Gstack [expr $gox+$HFin]
etch material= {TiN HfO2 Oxide} type= anisotropic rate= {$Gstack $Gstack $Gstack} time= 2.0
deposit oxide fill coord= $HFin



# Offset spacer
deposit material= {Oxide} type= isotropic  rate= {1.0} time= $PolyReox


deposit material= {Nitride} type= isotropic  rate= {$Lsp} time= 1.0


etch nitride type= anisotropic rate= $HFin time= 1.0



refinebox name= HALO mask= "FINref" extend= 0.005 extrusion.min= -$gox-$THK extrusion.max= 1.5*$HFin \
 xrefine= " 0.002/$fp 0.005/$fp "  yrefine= " $PolyPitch/(20.0*$fp) " zrefine= " $FinPitch/(10.0*$fp) " all add

refinebox name= YEXT mask= "POLY" \
 extend= 0.005 extrusion.min= 0.0 extrusion.max= $HFin \
 xrefine= " 0.001/$fp "  yrefine= " $PolyPitch/(40.0*$fp) " zrefine= " $FinPitch/(20.0*$fp) " Silicon add

refinebox name= EXT_IF mask= "FINref" \
 extend= 0.001 extrusion.min= -$gox extrusion.max= $HFin min.normal.size= 0.0005/$fp normal.growth.ratio= 2.0 \
 interface.mat.pairs= {Silicon Oxide} Silicon add


#split Ext

#-- SiC Material prop to activate Molefraction Dependent stress ---#
pdbSetDoubleArray Silicon Carbon Conc.Strain {0 0 1 -0.432}
pdbSetDouble Silicon Mechanics TopRelaxedNodeCoord 0.05e-4

# ------------ Halo Implantation
photo mask= PWELL thickness= 0.1




implant Boron dose= 3.2e+14 energy= 5.0 tilt= 15 rotation=  30  info=1
implant Boron dose= 3.2e+14 energy= 5.0 tilt= 15 rotation= 150  info=1
implant Boron dose= 3.2e+14 energy= 5.0 tilt= 15 rotation= 210  info=1
implant Boron dose= 3.2e+14 energy= 5.0 tilt= 15 rotation= 330  info=1 

## ---------- S/D Extension implantation nFinFET ----------------------
implant Carbon  dose= 1.0e15 energy= 2.5 tilt= 10.0 rotation= 0.0  info=1 
implant Carbon  dose= 1.0e15 energy= 2.5 tilt= 10.0 rotation= 180.0  info=1
implant Arsenic dose= 2.0e15 energy= 4.0 tilt= 10.0 rotation= 0.0  info=1
implant Arsenic dose= 2.0e15 energy= 4.0 tilt= 10.0 rotation= 180.0  info=1
 


struct tdr=n@node@_Extn

strip Photoresist
photo mask= NWELL thickness= 0.1




implant Arsenic dose= 8.5e12 energy= 25 tilt= 20 rotation= 0 info=1    
implant Arsenic dose= 8.5e12 energy= 25 tilt= 20 rotation= 90 info=1
implant Arsenic dose= 8.5e12 energy= 25 tilt= 20 rotation= 180 info=1
implant Arsenic dose= 8.5e12 energy= 25 tilt= 20 rotation= 270 info=1

implant Phosphorus dose= 8.5e12 energy= 40 tilt= 20 rotation= 0  info=1
implant Phosphorus dose= 8.5e12 energy= 40 tilt= 20 rotation= 90  info=1
implant Phosphorus dose= 8.5e12 energy= 40 tilt= 20 rotation= 180  info=1
implant Phosphorus dose= 8.5e12 energy= 40 tilt= 20 rotation= 270  info=1


## ---------- S/D Extension implantation pFinFET -----------------------
implant BF2  dose= 6.5e15 energy= 2.0 tilt= 10 rotation= 0.0  info=1
implant BF2  dose= 6.5e15 energy= 2.0 tilt= 10 rotation= 180.0 info=1


struct tdr=n@node@_Extp

strip Photoresist


diffuse temperature= 750<C> time= 1<min>


#split SDEpi


# Spacer for epi

deposit material= {Nitride} type= isotropic rate= {$Lspepi} time= 1.0
etch material= {Nitride Oxide} type= anisotropic rate= {$HFin $HFin} time= 2.0


deposit oxide fill coord= $HFin

## LKMC
pdbSet KMC  Movie ""
pdbSet KMC  Epitaxy true
pdbSet KMC  Simplify.Geometry @simgeo@
pdbSet LKMC Epitaxy.Cleanup 0

pdbSet KMC YMaxCell 0.8E-3
pdbSet KMC ZMaxCell 0.8E-3

pdbSet KMC YMinCell 0.4E-3
pdbSet KMC ZMinCell 0.4E-3

SetAtomistic
pdbSet LKMC Epitaxy.Model Coordinations.Planes

set arsenic   4.5e20
set carbon    1.5e21
set germanium 1.5e22
set boron     1.5e20



#if @[ string match "TN" @Domain@ ]@

    diffuse time=5<min> temperature=700  epi.thickness=0.02 epi.doping.final= { Arsenic=$arsenic Carbon=$carbon } Epi epi.layers=1  

#elif @[ string match "TP*" @Domain@ ]@

# Following steps are specific for 3D P-FET
    etch   material= {Silicon} type= anisotropic rate= {0.010} time= 1.0
    etch   material= {Silicon} type= isotropic rate= {0.001} time= 1.0
    deposit material= {Oxide} type= fill coord= $HFin
    diffuse time=5<min> temperature=700 Epi epi.thickness=0.03 epi.doping.final= { Germanium=$germanium Boron=$boron } Epi epi.layers=1 

#endif

struct tdr=n@node@_epi

pdbSet KMC Epitaxy false

deposit material= {Oxide} type= isotropic rate= {1.0} time= 0.0015 fill.buried

#split SD


# ----------------------------------------------------------------
#   SD Implantation
#----------------------------------------------------------------

deposit Photoresist mask= PWELL type= anisotropic thickness= 1.0
etch Photoresist type=cmp coord= [expr (-0.1-$Tpoly)]



struct tdr= n@node@_sdn
strip Photoresist

deposit Photoresist mask= NWELL type= anisotropic thickness= 1.0
etch Photoresist type=cmp coord= [expr (-0.1-$Tpoly)]



struct tdr= n@node@_sdp
strip Photoresist

# ---- laser annealing ----
temp_ramp name= laser  time= 1e-03<s> ramprate= 5e+05<C/s>  temperature= 600.0
temp_ramp name= laser  time= 1e-03<s> ramprate= -5e+04<C/s> temperature= 1100.0


#split Silicide
# ---------- Contact silicidation -----------------------

# avoid diffusion at low temperature
SetFastMode no.diffusion
diffuse stress.relax time= 1<min> temp= 20 ramprate= [ expr 450.0 - 25.0 ]<K/min> 

etch material= {oxide}  type= isotropic rate= {0.002} time= 1.0


deposit material= {NickelSilicide} type= isotropic rate= 0.003 time= 1.0 selective.materials= {Silicon}


diffuse stress.relax time= 1<min>  temperature= 450  ramprate= [ expr 20.0 - 450.0 ]<K/min> 

#split DeviceMesh


icwb filename= "FinSRAM_lyt.mac" scale= 1e-3
#rem # Loading of the "TCAD Layout" file.

#rem # Selecting the simulation domain.
icwb domain= @Domain@ 

fset fd 1.0
fset HFin 0.04

#Polishing
etch material= {Nitride} type= cmp coord= -3*$gox-$THK-$MetalG
etch material= {Oxide} type= cmp coord= -3*$gox-$THK-$MetalG


#Remove Poly and metal gate
strip PolySilicon
strip TiNitride


##---------------Remeshing for device simulation--------##
# clear the process simulation mesh
refinebox clear
refinebox !keep.lines
line clear

# reset default settings for adaptive meshing
pdbSet Grid AdaptiveField Refine.Abs.Error 1e37
pdbSet Grid AdaptiveField Refine.Rel.Error 1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0

# Set high quality delaunay meshes
pdbSet Grid Adaptive 1
pdbSet Grid SnMesh DelaunayType boxmethod
pdbSet Grid SnMesh CoplanarityAngle 179
pdbSet Grid SnMesh MaxPoints 10000000
pdbSet Grid SnMesh MaxNeighborRatio 1e6

# meshing strategy
pdbSet Grid SnMesh min.normal.size 0.01
pdbSet Grid SnMesh normal.growth.ratio.3d 8 
pdbSet Grid SnMesh max.box.angle.3d 179.0 

# Which interfaces are to have interface meshes
refinebox interface.materials= {Silicon}



refinebox name= Device_FINS mask= "FINref" extend= 0.01 extrusion.min= -0.1  extrusion.max= $HFin+0.01 \
 refine.fields= { NetActive} def.max.asinhdiff= 1.0 \
 refine.max.edge= " 0.01  0.01  0.01 " \
 refine.min.edge= " 0.002/$fd  0.002/$fd  0.002/$fd " adaptive Silicon add


refinebox name= Device_GATES mask= POLY extend= 0.005 extrusion.min= -0.1  extrusion.max= $HFin+0.01 \
 xrefine= " 0.01/$fd "  yrefine= " $PolyPitch/(20.0*$fd) " zrefine= " $FinPitch/(5.0*$fd) " Silicon add


refinebox name= Device_IF mask= POLY extend= 0.005 extrusion.min= -0.1  extrusion.max= $HFin+0.01 \
min.normal.size= 0.0004/$fd normal.growth.ratio= 2.0 \
interface.materials= {Silicon Oxide} Silicon add

refinebox remesh 



transform reflect right


struct tdr= n@node@_fin

exit


