#header
set CNode @node@

#rem #   LAYOUT
icwb filename= "DRAMCell_lyt.mac" scale= 1e-3
icwb domain= DCell

#endheader

## Geometry and Simulation Control
fset debug       1
fset fp          1.0
fset ReoxT       0.006
fset STI_Depth   0.3
fset STI_Tilt    88

fset GoxT   0.0035  ;# Gate Oxide Thickness
fset BWH    0.155   ;# Wordline depth from the top Si surface 
fset SFE    0.085   ;# Wordline metal contact height from SF
fset FH     0.05    ;# SaddleFin Height
fset NiSiT  0.015   ;# NiSi thickness (Deposit after isotropic etch)
fset PWL    0.088   ;# Word Line Pitch

fproc WriteBND {} {
     global count
     global CNode
        
     struct tdr.bnd= n${CNode}_${count} !Gas
     incr count 
}
fset count 1

# Domain initialization
fset sim_top    0.0
fset sim_bottom 0.8
fset sim_left   [icwb bbox left ]
fset sim_right  [icwb bbox right]
fset sim_back   [icwb bbox back ]
fset sim_front  [icwb bbox front]
fset spac_y     [expr ($sim_right-$sim_left)/4.0]
fset spac_z     [expr ($sim_front-$sim_back)/4.0] 
fset WW   [expr $sim_right - $sim_left]     ;# Cell Width, um
fset WL   [expr $sim_front - $sim_back]     ;# Cell Length,um

line x loc= $sim_top                tag= top
line x loc= $sim_bottom             tag= bot

line y loc= $sim_left   tag= left   spac= $spac_y
line y loc= $sim_right  tag= right  spac= $spac_y

line z loc= $sim_back   tag= back   spac= $spac_y
line z loc= $sim_front  tag= front  spac= $spac_y

region Silicon xlo= top xhi= bot ylo= left yhi= right zlo= back zhi= front substrate
init concentration= 1e15 field= Boron wafer.orient= {0 0 1} notch.direction= {1 1 0} !DelayFullD

source MaterialParams_sp.tcl
# General control
AdvancedCalibration
math numThreads= 4
math coord.ucs

# pdb settings ---------------------------------------------------------
pdbSet InfoDefault 1
pdbSet Mechanics StressHistory 0
pdbSet Mechanics EtchDepoRelax 0
pdbSet ImplantData ResistSkip 1
pdbSet ImplantData LeftBoundary Reflect
pdbSet ImplantData RightBoundary Reflect
pdbSet ImplantData BackBoundary Reflect
pdbSet ImplantData FrontBoundary Reflect


# meshing strategy ----------------------------------------------------------------------
mgoals resolution= 1.0/3.0 accuracy= 1e-4 repair.angle= 2.0
grid set.min.normal.size= 0.005 \
     set.normal.growth.ratio.3d= 4.0 \
     set.min.edge= 1e-7 \
     set.max.points= 10000000 \
     set.max.neighbor.ratio= 1e6
pdbSet Grid SnMesh max.box.angle.3d 175
 
refinebox name= GlobalInt \
   min= " $sim_top-0.01 $sim_left $sim_back " max= " $sim_bottom $sim_right $sim_front " \
   min.normal.size= 0.005 normal.growth.ratio= 2.0 interface.materials= {Silicon Oxide}

refinebox name= Global1 \
   min= " -0.01 $sim_left $sim_back-0.001 " max= " $sim_bottom $sim_right $sim_front " \
   xrefine= "0.05/$fp"  yrefine= "0.04/$fp" zrefine= "0.05/$fp"

## ---- Pad Oxide ----- 
deposit material= {Oxide} type= isotropic rate= 1.0 time= 0.04
if { $debug } { WriteBND }

## ---- Nitride Deposition -----
deposit material= {Nitride} type= isotropic rate= 1.0 time= 0.10 

temp_ramp name= liner time= 5  temp= 600.0 ramprate= 0.6667
temp_ramp name= liner time= 10 temp= 800.0 hold
temp_ramp name= liner time= 5  temp= 800.0 ramprate= -0.6667

diffuse temp_ramp= liner info= 1

#split @STI@

icwb.create.mask layer.name= "Active" name= ACTIVEn polarity= negative
photo mask= ACTIVEn thickness= 0.2
if { $debug } { WriteBND }
etch material= {Photoresist} type= isotropic rate= {0.005}  time= 1.1
if { $debug } { WriteBND }

## ---- STI Etching -----
etch material= {Nitride} type= anisotropic rate= {0.1}  time= 1.1
etch material= {Oxide}   type= anisotropic rate= {0.04} time= 1.1
if { $debug } { WriteBND }

strip Photoresist
strip nitride
etch    material= {Oxide} type= isotropic rate= {0.007} time= 1.0
deposit material= {Oxide} type= isotropic rate= {0.007} time= 1.0 selective.materials= Oxide
if { $debug } { WriteBND }

etch material= {Silicon} type= trapezoidal time= 1.0 rate= $STI_Depth angle= $STI_Tilt roundness= 3.0
if { $debug } { WriteBND }
deposit material= {Oxide2} type= isotropic rate= {0.0005} time= 1.0 
etch material= {Oxide2} type= anisotropic rate= 0.001  time= 1.0
etch material= {Silicon} type= trapezoidal time= 1.0 rate= {0.22} angle= 78 
if { $debug } { WriteBND }
strip Oxide2
strip Oxide
if { $debug } { WriteBND }

etch    material= {Silicon} type= isotropic rate= 0.0025 time= 1.0
deposit material= {Silicon} type= isotropic rate= 0.0025 time= 1.0 selective.materials= Silicon
if { $debug } { WriteBND }

deposit material= {Oxide} type= isotropic rate=$ReoxT  time= 1.0
deposit material= {Nitride2} type= fill coord= -0.004
etch    material= {Nitride2 Oxide} type= cmp coord= -0.003
deposit material= {Oxide}  type= anisotropic rate= {0.0045} time= 1.0
if { $debug } { WriteBND }

#split @SFin@

## -- Saddle FIN ----
icwb.create.mask layer.name= "WL" name= BWL polarity= positive
photo mask= BWL thickness= 0.05

deposit material= Photoresist type= isotropic time= 1.0 rate= 0.002 selective.materials= {Photoresist}
if { $debug } { WriteBND }

etch material= {Silicon Oxide Nitride2} type= trapezoidal rate= {$BWH} time= 1.0 angle= 87.0
if { $debug } { WriteBND }

deposit material= {Oxide2} type= isotropic   time= 1.0 rate= 0.0002
etch   material= {Oxide2} type= anisotropic time= 1.0 rate= 0.001
if { $debug } { WriteBND }

etch material= {Nitride2 Oxide} type= trapezoidal  rate= {$FH} time= 1.2 angle= 86.0
strip Oxide2
if { $debug } { WriteBND }

etch material= {Nitride2 Oxide} type= isotropic rate= {0.007 0.007} time= 1.0
if { $debug } { WriteBND }


## ---- Control the rounding of the Saddle Fin -----
etch    material= {Silicon} type= isotropic rate= 0.012 time= 1.0
if { $debug } { WriteBND }

deposit material= {Silicon} type= isotropic rate= 0.008 time= 1.0 selective.materials= {Silicon}
if { $debug } { WriteBND }

strip Photoresist
deposit material= {Oxide} type= isotropic rate= $GoxT time= 1.0
if { $debug } { WriteBND }

#split @SD@

refinebox name= SFin1 \
 min= " 0.001 $sim_left $sim_back-0.001 " max= " 0.225 $sim_right $sim_front " \
 xrefine= " 0.0075/$fp "  yrefine= " 0.005/$fp " zrefine= " 0.005/$fp " Silicon

# Halo Implant

implant Boron energy= 56 dose= 4.1e13 tilt= 30 rotation= 0.0
implant Boron energy= 56 dose= 4.1e13 tilt= 30 rotation= 90.0
implant Boron energy= 56 dose= 4.1e13 tilt= 30 rotation= 180.0
implant Boron energy= 56 dose= 4.1e13 tilt= 30 rotation= -90.0

# SD Implant
icwb.create.mask layer.name= "WL" name= SD polarity= negative
photo mask= SD thickness= 0.25 

implant Arsenic energy= 10 dose= 1.0e15 tilt= 0 rotation= 0
implant Arsenic energy= 30 dose= 1.0e15 tilt= 0 rotation= 0
implant Arsenic energy= 45 dose= 1.0e15 tilt= 0 rotation= 0
struct tdr= n@node@_asImp
strip Photoresist

temp_ramp name= rta temp= 600  time= 2.0<s> ramprate= (900-600)/2.0
temp_ramp name= rta temp= 900  time= 1.0<s> ramprate= (1050-900)/1.0
temp_ramp name= rta temp= 1050 time= 0.5<s> ramprate=  0.0
temp_ramp name= rta temp= 1050 time= 5.0<s> ramprate= (800-1050)/5.0
temp_ramp name= rta temp= 800  time= 2.0<s> ramprate= (800-600)/2.0

diffuse delT= 50.0 temp_ramp= rta

# -------------------------------------------------------------------- #
SetPlxList { BTotal AsTotal }
WritePlx n@node@_anneal.plx y= [expr $WW/2.0] z= [expr $WL/2.0]
# -------------------------------------------------------------------- #

#split @WL@

refinebox name= SFin2 \
   min= " 0.025 $sim_left $sim_back-0.001 " max= " 0.15 $sim_right $sim_front " \
   refine.fields= { NetActive } def.max.asinhdiff= 1.0 \
   refine.max.edge= " 0.05/$fp  0.05/$fp  0.05/$fp" \
   refine.min.edge= " 0.003/$fp 0.003/$fp 0.003/$fp" adaptive Silicon

deposit material= {TiN} type= isotropic rate= 0.0025 time= 1.0
deposit material= { Tungsten } type= fill coord= $BWH-$SFE-0.002
if { $debug } { WriteBND }
etch material= {TiNitride TiN} type= cmp coord= $BWH-$SFE-0.002
if { $debug } { WriteBND }

deposit material= {NitridePECVD} type= isotropic rate= 0.002 time= 1.0 
deposit material= {OxideCVD} type= fill coord= -0.009
deposit material= {NitridePECVD} type= fill coord= -0.02
deposit material= {OxideTEOS} type= anisotropic rate= 0.03 time= 1.0 
if { $debug } { WriteBND }

#split @BL@

refinebox name= Cap \
 min= " -0.2 $sim_left $sim_back-0.001 " max= " 0.05 $sim_right $sim_front " \
 xrefine= " 0.05/$fp "  yrefine= " 0.02/$fp " zrefine= " 0.02/$fp " 

##Circular mask
fset tiso 0.02
fset st   -0.05
fset nt   0.075
icwb.create.mask layer.name= "BLC" name= BLC polarity= positive

    deposit NitrideARC fill coord=[expr $st-$nt]       
    WriteBND 

    # patterning
    deposit C1 fill coord=[expr $st-$nt-0.03] info=2
    deposit C2 fill coord=[expr $st-$nt-0.06] info=2
    photo   thickness=0.05 mask= BLC	
    set	isoangle [expr 90.0-atan($tiso/0.05)*180.0/3.14159]
    etch C2 trapezoidal thickness=0.1 angle=$isoangle info=2
    WriteBND 

    strip resist
    
    etch C1 trapezoidal thickness=0.10 angle=90.0 
    etch C1 isotropic   thickness=$tiso           
    strip C2
    etch material= {NitrideARC OxideTEOS} trapezoidal thickness=[expr $nt+0.04] angle=87.0 info=2
    strip C1
    WriteBND     

etch material= {NitridePECVD Oxide Nitride2} type= trapezoidal time= 1.0 rate= {0.05} angle= 87.0
strip NitrideARC
if { $debug } { WriteBND }

etch material= {OxideTEOS NitridePECVD} type= isotropic rate= {0.0015} time= 1.0
if { $debug } { WriteBND }

etch material= {Silicon} type= isotropic rate= {0.022} time= 1.0
etch material= {Oxide} type= isotropic rate= {0.0025} time= 1.0
if { $debug } { WriteBND }

deposit material= {PolySilicon} type= isotropic rate= 0.04 time= 1.0 selective.materials= {Silicon}
deposit material= {TiNitride}   type= isotropic rate= 0.002 time= 1.0
deposit material= {Tungsten}    type= fill coord= -0.075
if { $debug } { WriteBND }

etch type= cmp coord= -0.048
deposit material= {Aluminium} type= isotropic rate= 0.05 time= 1.0 
if { $debug } { WriteBND }

icwb.create.mask layer.name= "BL" name= BLM polarity= negative
photo mask= BLM thickness= 0.05
if { $debug } { WriteBND }

etch material= {Aluminium} type= anisotropic rate= 0.06 time= 1.0
strip Photoresist
if { $debug } { WriteBND }
deposit material= {SiON} type= isotropic rate= 0.006 time= 1.0 selective.materials= {Aluminium}
deposit material= {SOH}    type= fill coord= -0.146
if { $debug } { WriteBND }

#split @SNC@

fset tiso 0.02
fset nt   0.05
fset st   -0.146
icwb.create.mask layer.name= "SNC" name= SN polarity= positive

deposit NitrideARC fill coord=[expr $st-$nt]        

    # patterning
    deposit C1 fill coord=[expr $st-$nt-0.03] info=2
    deposit C2 fill coord=[expr $st-$nt-0.06] info=2
    photo   thickness=0.05 mask= SN	
    set	isoangle [expr 90.0-atan($tiso/0.05)*180.0/3.14159]
    etch C2 trapezoidal thickness=0.1 angle=$isoangle info=2
    WriteBND 

    strip resist 
    
    etch C1 trapezoidal thickness=0.10 angle=90.0 
    etch C1 isotropic   thickness=$tiso           
    strip C2
    etch material= {NitrideARC} trapezoidal thickness=[expr $nt+0.04] angle=87.0 info=2
    strip C1
    WriteBND

etch NitrideARC type=isotropic rate= 0.005 time=1.0
if { $debug } { WriteBND }

etch material= {SOH OxideTEOS NitridePECVD} type= trapezoidal time= 1.0 rate= {0.15} angle= 87
if { $debug } { WriteBND }

etch material= {Oxide Nitride2} type= trapezoidal time= 1.0 rate= {0.025} angle= 87.0
if { $debug } { WriteBND }

etch material= {OxideTEOS NitridePECVD Oxide Nitride2} type= isotropic rate= {0.003} time= 1.0
if { $debug } { WriteBND }

etch material= {Nitride2 Silicon} type= isotropic rate= {0.0025 0.0025} time= 1.0
strip NitrideARC
deposit material= {PolySilicon} type= fill coord= -0.115
if { $debug } { WriteBND }

etch type= cmp coord= -0.049
etch material= {PolySilicon} type= cmp coord= -0.048
deposit material= {TaN} type= fill coord= -0.049
if { $debug } { WriteBND }

#split @DeviceMesh@

refinebox clear
line clear
fset fd 1.0

# Set very high values for adaptive meshing parameters

pdbSet Grid AdaptiveField Refine.Abs.Error     1e37
pdbSet Grid AdaptiveField Refine.Rel.Error     1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0
pdbSet Grid SnMesh max.box.angle.3d 179
select PolySilicon z= 1.0e20 name= NetActive store

# Refinement strategy
grid Adaptive set.Delaunay.type= boxmethod \
     set.max.points= 10000000 set.max.neighbor.ratio= 1e6 \
     set.min.normal.size= 0.005/$fd set.normal.growth.ratio.3d= 4.0

refinebox name= Device \
  min= " -0.1 $sim_left $sim_back-0.001 " max= " $sim_bottom $sim_right $sim_front " \
   refine.fields= { NetActive } def.max.asinhdiff= 1.0 \
   refine.max.edge= " 0.2/$fd    0.2/$fd    0.2/$fd" \
   refine.min.edge= " 0.008/$fd  0.008/$fd  0.008/$fd" adaptive Silicon

refinebox name= DeviceSD \
   min= " 0.04 $sim_left $sim_back " max= " 0.25 $sim_right $sim_front " \
   refine.fields= { NetActive } def.max.asinhdiff= 1.0 \
   refine.max.edge= " 0.1/$fd   0.1/$fd   0.1/$fd" \
   refine.min.edge= " 0.003/$fd  0.003/$fd  0.003/$fd" adaptive Silicon
  
refinebox name= Device_IF \
   min= "-0.001 $sim_left $sim_back" max= "$BWH+$SFE+0.2 $sim_right $sim_front" \
   min.normal.size= 0.002 normal.growth.ratio= 2.0 \
   interface.materials= {Silicon Oxide} 


## Trap near SF-Gate Region
mater add name= SiTr new.like= Silicon alt.matername= Silicon
polygon name= TrapC min= { 0.012 0.018 } max= { 0.05 0.08 } rectangle
polyhedron name=SFTrap polygons= TrapC min=$SFE max=0.22

insert polyhedron= SFTrap replace.materials= {Silicon} new.material= SiTr new.region= SiTr_1

# Refinement for Trap Region 
refinebox name= "SiTr_IF" \
   min= " $SFE $sim_left $sim_back-0.001 " max= " 0.25 $sim_right $sim_front " \
   min.normal.size= 2.0e-3 normal.growth.ratio= 1.5 \
   interface.materials = {SiTr Oxide} 

grid remesh

# square contact size on interface; contact border must be within contact interface(s) to avoid crash.
set contact_size   0.012
set contact_offset 0.012

set MAT [ region name= Aluminum_1 material syntax.check.value= Copper]
contact add name= "BL" $MAT box xlo= -1*(0.049+$contact_offset) ylo= $WW/1.75-$contact_size/2 zlo= 0.018-$contact_size/2 \
	xhi= -1*(0.049-$contact_offset) yhi= $WW/1.75+$contact_size/2 zhi= 0.018+$contact_size/2 

set MAT [ region name= TaN_1 material syntax.check.value= Copper]
contact add name= "SC" $MAT box xlo= -1*(0.049+$contact_offset) ylo= $WW/4.0-$contact_size/2 zlo= 0.1-$contact_size/2 \
	xhi= -1*(0.049-$contact_offset) yhi= $WW/4.0+$contact_size/2 zhi= 0.1+$contact_size/2 

contact name= "WL" point x= [expr $BWH-$SFE/2.0] y= $WW/2.0 z= $PWL/2.0 Tungsten !replace 
contact name= "PG" point x= [expr $BWH-$SFE/2.0] y= $WW/1.5 z= [expr $sim_front-0.005] Tungsten !replace

contact  name= substrate Silicon bottom !replace

struct tdr= n@node@  

exit
