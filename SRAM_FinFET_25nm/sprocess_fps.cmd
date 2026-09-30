#header
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


#endheader

fproc FindInterfaceRegions {args} {
## ---------------------------------------------------------------------- ##
## FindInterfaceRegions - procedure to find the interface regions
## for regions that contain certain stem in the name
##
## It take one argument:
## 1) NameStem - name stem;
## Returns a list of interface regions
## ---------------------------------------------------------------------- ##

   global ExecuteOn    
   if { ! $ExecuteOn } {
      if {[llength $args] < 1 || [llength $args] > 2} {
         error "FindInterfaceRegions: wrong number of arguments"
         exit -1
      }
   }
   set NameStem   [lindex $args 0]
   set IFRegions [ list ]
   set Regions [region list.interface]
   foreach LocalRegion $Regions {
      if { [string match $NameStem*+Silicon* $LocalRegion] } {
         lappend IFRegions $LocalRegion 
      }
   }

   return $IFRegions;
}

fproc ChangeMaterialMatchRegions {args} {
 # ChangeMaterialMatchRegions - procedure to chage the material
 # for regions that contain certain stem in the name
 # It take the following three arguments:
 # NameStem - name stem;
 # NewMat   - new material;
 # ZeroData - Reset Doping Data
     global ExecuteOn    
    if { ! $ExecuteOn } {
       if {[llength $args] < 2} {
          error "ChangeMaterialMatchRegions: wrong number of arguments"
          exit -1
       }
    }
    set NameStem   [lindex $args 0]
    set NewMat     [lindex $args 1]
    set ZeroData   [lindex $args 2]
    
    set Regions [region list.bulk]
    foreach LocalRegion $Regions {
        if { [string match $NameStem* $LocalRegion] && [string match $ZeroData Nozerodata] } {
           region name=$LocalRegion $NewMat change.material !zero.data
           }
        if { [string match $NameStem* $LocalRegion] && [string match $ZeroData zerodata] } {
           region name=$LocalRegion $NewMat change.material zero.data
        }
    }

  return;

}

fproc HexaPrism {args} {
#rem # HexaPrism - procedure to create prism from hexagon along SProcess Y 
#rem # It take the following arguments:
#rem # 0. Name - name of the prism
#rem # 1. Height - height of the prism
#rem # 2. DeltaX - Prism center translation along SProcess X (optional, default=0)
#rem # 3. DeltaY - Prism center translation along SProcess Y (optional, default=0)
#rem # 4. DeltaZ - Prism center translation along SProcess Z (optional, default=0)
#rem # 5. alpha  - Prism hexagon angle measured from YZ plane(optional, default=60)
#rem # 6. YY     - Prism Length              along SProcess Y(optional, default=height)
#rem # 7. ZZ     - Prism hexagon diagonal length in YZ plane  along SProcess Z (optional)


       if {[llength $args] < 2 || [llength $args] > 8} {
          error "HexaPrism: wrong number of arguments"
          exit -1
       }
    set name      [lindex $args 0]
    set h         [lindex $args 1]
    set dx 0
    set dy 0
    set dz 0
    if {[llength $args] > 2 } {
      set dx  [lindex $args 2]
    }
    if {[llength $args] > 3 } {
      set dy  [lindex $args 3]
    }
    if {[llength $args] > 4 } {
      set dz  [lindex $args 4]
    }
    if {[llength $args] > 5 } {
      set alpha  [expr [lindex $args 5]*atan(1.0)/45.0]
    } else {
      set alpha [ expr 60.0*atan(1.0)/45.0]
    }
    if {[llength $args] > 6 } {
      set yy  [lindex $args 6]
    } else {
      set yy $h
    }
    if {[llength $args] == 8 } {
      set zz  [lindex $args 7]
    } else {
      set zz  [expr  $h*(1.0+1.0/tan($alpha))/2.0 ]
    }
   
    set x1 [expr  $h/2.0 + $dx]
    set x2 $dx 
    set x3 [expr -$h/2.0 + $dx]
    
    set y1 [expr -$yy/2.0 + $dy]
    set y2 [expr  $yy/2.0 + $dy]
    
    set z1 [expr  $zz/2.0+$dz]
    set z2 [expr -$zz/2.0+$dz]
    set z3 [expr  $zz/2.0-$h/(tan($alpha)*2.0)+$dz]
    set z4 [expr -$zz/2.0+$h/(tan($alpha)*2.0)+$dz]
    if {$z3 < $z4} {
         error "ERROR: inconsistent input: check height, width and angle!"
         exit 1
    }

    # Points
    point name= p1_$name coord= { $x1 $y1 $z4}
    point name= p2_$name coord= { $x1 $y1 $z3}
    point name= p3_$name coord= { $x2 $y1 $z1}
    point name= p4_$name coord= { $x3 $y1 $z3}
    point name= p5_$name coord= { $x3 $y1 $z4}
    point name= p6_$name coord= { $x2 $y1 $z2}
    point name= p7_$name coord= { $x1 $y2 $z4}
    point name= p8_$name coord= { $x1 $y2 $z3}
    point name= p9_$name coord= { $x2 $y2 $z1}
    point name= p10_$name coord= { $x3 $y2 $z3}
    point name= p11_$name coord= { $x3 $y2 $z4}
    point name= p12_$name coord= { $x2 $y2 $z2}
    
    # Polygons
    polygon name= hex1_$name   points= " p1_$name p2_$name p3_$name p4_$name p5_$name p6_$name "
    polygon name= hex2_$name   points= " p7_$name p8_$name p9_$name p10_$name p11_$name p12_$name "
    polygon name= rec1_$name   points= " p1_$name p2_$name p8_$name p7_$name "
    polygon name= rec2_$name   points= " p2_$name p8_$name p9_$name p3_$name "
    polygon name= rec3_$name   points= " p3_$name p9_$name p10_$name p4_$name "
    polygon name= rec4_$name   points= " p4_$name p10_$name p11_$name p5_$name "
    polygon name= rec5_$name   points= " p5_$name p11_$name p12_$name p6_$name "
    polygon name= rec6_$name   points= " p6_$name p12_$name p7_$name p1_$name "
    
    polyhedron name= $name polygons= " hex1_$name hex2_$name rec1_$name rec2_$name rec3_$name rec4_$name rec5_$name rec6_$name" info= 2
}

#rem # PARALLEL EXECUTION - uncomment if you have 8 CPUs or more
math numThreads= 8
math coord.ucs

## Design Rule
fset PolyPitch 0.130
fset GateThick 0.025
fset FinPitch  0.05

fset debug 0
fset FastMode 0
fset fp 1.0

fset HFin 0.04        
fset STI_depth 0.15  
fset Tsub 0.5

fset Wfin  0.017       ;# Z-axis in Layout 
fset Tpoly 0.04
fset Lg    0.025       ;# Y-axis in Layout
fset gox   0.001
fset THK   0.002
fset MetalG   0.004
fset CapOx 0.005

fset PolyReox 0.002    
fset Lsp  0.0025      
fset Lspepi 0.0125

fset Y [expr ($Ymax-$Ymin)/2.0]
fset Z [expr ($Zmax-$Zmin)/2.0]

# -------------------------------------------------------
# initial grid and structure 
# -------------------------------------------------------

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

init field= Boron concentration= 1.0e15 wafer.orient= {0 0 1}

AdvancedCalibration

# -------------------------------------------------------
# pdb settings
# -------------------------------------------------------

#-- Reflected boundary condition ---#
pdbSet ImplantData LeftBoundary  Reflect
pdbSet ImplantData RightBoundary Reflect
pdbSet ImplantData FrontBoundary Reflect
pdbSet ImplantData BackBoundary  Reflect
pdbSet ImplantData ResistSkip 1
pdbSet Mechanics StressHistory 1
pdbSet InfoDefault 1

# turn off stress relaxation after depo/etch
pdbSet Mechanics EtchDepoRelax 0

# meshing strategy
mgoals resolution= 1.0/3.0 accuracy= 1e-4
 pdbSet Grid SnMesh max.box.angle.3d 179
 pdbSet Grid SnMesh CoplanarityAngle 175
 pdbSet Grid SnMesh EdgeProximity 0.3
 pdbSet Grid SnMesh FaceProximity 0.3

grid set.min.normal.size= 0.005/$fp \
 set.normal.growth.ratio.3d= 2.0 \
 set.min.edge= 1e-7 set.max.points= 10000000 \
 set.max.neighbor.ratio= 1e6

refinebox name= fin min= " -0.001 $Ymin $Zmin" max= "$Tsub $Ymax $Zmax" \
        xrefine= "0.5/$fp"  yrefine= "$Y/(2.0*$fp)" zrefine= "$Z/(2.0*$fp)" 

refinebox name= FinIF min= " -0.001 $Ymin $Zmin" max= "$Tsub $Ymax $Zmax" \
        min.normal.size= 0.001/$fp normal.growth.ratio= 2.0 interface.materials= {Silicon Oxide}
 
# -------------------------------------------------------
# process flow 
# ------------------------------------------------------- 

# Hard mask nitride
deposit material= {Oxide}   type= anisotropic  rate= {0.01} time= 1.0
deposit material= {Nitride} type= anisotropic  rate= {0.1}  time= 1.0

# Fin mask
polygon clear
icwb.create.mask layer.name= "FIN" name= FIN info= 1 polarity= negative
photo mask= FIN thickness= 0.02
etch material= {Nitride} type= anisotropic rate= {0.1} time= 1.1
if { $debug } { struct tdr.bnd= n@node@_01 }

strip Photoresist
etch material= {Oxide} type= anisotropic rate= {0.01} time= 1.1
etch material= {Silicon} type= trapezoidal rate= $STI_depth time= 1.0 angle= 88.0
strip Nitride
strip Oxide
if { $debug } { struct tdr.bnd= n@node@_02 }

etch    material= {Silicon} type= isotropic rate= {0.002} time= 1.0 
deposit material= {Silicon} type= isotropic rate= {0.002} time= 1.0 selective.materials= {Silicon}
if { $debug } { struct tdr.bnd= n@node@_03 }

deposit oxide fill coord= $HFin
if { $debug } { struct tdr.bnd= n@node@_04 }

# Cap oxide and fill
deposit material= {Oxide} type= isotropic rate= $CapOx time= 1.0
if { $debug } { struct tdr.bnd= n@node@_05 }

icwb.create.mask layer.name= "FIN" name= FinMask polarity= positive
refinebox name= Vth mask= FinMask \
          extend= 0.004 extrusion.min= -0.01 extrusion.max= [expr 2*$HFin] \
          xrefine= "0.005/$fp"  yrefine= "$PolyPitch/(6.0*$fp)" zrefine= "$FinPitch/(8.0*$fp)"

if { $FastMode == 0 } {
stressdata Oxide sxxi= -5e8<Pa> syyi= -5e8<Pa> szzi= -5e8<Pa>
diffuse stress.relax time= 1e-10 temp= 600
}

# --------------------------------------------------------------
# WELL/Vt implant
# --------------------------------------------------------------

icwb.create.mask layer.name= "NWELL" name= NWELL info= 1 polarity= positive
deposit material= {Oxynitride} type= fill coord= -$Tpoly-$gox-$HFin-0.15
etch    material= {Oxynitride} type= anisotropic rate= {$Tpoly+$gox+$HFin+0.15} time= 1.5 mask= NWELL

if { $FastMode == 0 } {
implant Boron dose= 1.0e13 energy= 180 tilt= 0.0
implant Boron dose= 1.0e13 energy= 60  tilt= 0.0
implant Boron dose= 1.0e13 energy= 12  tilt= 0.0
}
if { $debug } { struct tdr.bnd= n@node@_06 }
strip Oxynitride

polygon clear
icwb.create.mask layer.name= "NWELL" name= PWELL info= 1 polarity= negative
deposit material= {Oxynitride} type= fill coord= -$Tpoly-$gox-$HFin-0.15
etch    material= {Oxynitride} type= anisotropic rate= {$Tpoly+$gox+$HFin+0.15} time= 1.5 mask= PWELL

if { $FastMode == 0 } {
implant Phosphorus dose= 1.0e13 energy= 120 tilt= 0.0
implant Phosphorus dose= 5.0e12 energy= 65  tilt= 0.0
implant Arsenic    dose= 5.5e12 energy= 25  tilt= 0.0

}
if { $debug } { struct tdr.bnd= n@node@_07 }
strip Oxynitride

# Well RTA
temp_ramp name= well temperature= 600<C>  time= 0.067      t.final= 900
temp_ramp name= well temperature= 900<C>  time= 0.033<min> t.final= 1050
temp_ramp name= well temperature= 1050<C> time= 0.2<min>   t.final= 750
temp_ramp name= well temperature= 750<C>  time= 0.1<min>   t.final= 600

if { $FastMode == 0 } {
diffuse stress.relax temp.ramp= well
}

etch material= {Oxide} type= cmp coord= $HFin  
if { $debug } { struct tdr.bnd= n@node@_08 }

#split @Poly@

# gate stack
deposit material= {Oxide} type= isotropic rate= {1.0} time= $gox
deposit material= {HfO2}  type= isotropic rate= $THK  time= 1.0
if { $debug } { struct tdr.bnd= n@node@_09 }

# MetalGate
deposit material= {TiNitride}  type= isotropic  rate= $MetalG  time= 1.0

# Poly etching
icwb.create.mask layer.name= "GATE" name= POLY info= 1  polarity= negative
deposit material= {PolySilicon} type= fill  coord= -$Tpoly-$gox
deposit material= {Nitride} type= isotropic  rate= $HFin+$Tpoly+0.01 time=1.0
if { $debug } { struct tdr.bnd= n@node@_10 }

photo mask= POLY thickness= 0.02
if { $debug } { struct tdr.bnd= n@node@_11 }

set Hmask [expr $HFin+$Tpoly]
etch material= {PolySilicon Nitride} type= anisotropic rate= {$Hmask} time= 2.5
strip Photoresist
if { $debug } { struct tdr.bnd= n@node@_12 }

set Gstack [expr $gox+$HFin]
etch material= {TiNitride HfO2 Oxide} type= anisotropic rate= {$Gstack $Gstack $Gstack} time= 2.0
deposit oxide fill coord= $HFin
if { $debug } { struct tdr.bnd= n@node@_13 }

# Offset spacer
deposit material= {Oxide} type= isotropic  rate= {1.0} time= $PolyReox
if { $debug } { struct tdr.bnd= n@node@_14 }

deposit material= {Nitride} type= isotropic  rate= {$Lsp} time= 1.0
if { $debug } { struct tdr.bnd= n@node@_15 }

etch nitride type= anisotropic rate= $HFin time= 1.0
if { $debug } { struct tdr.bnd= n@node@_16 }

if { $FastMode == 0 } {
refinebox name= Halo mask= FinMask \
          extend= 0.005 extrusion.min= -$gox-$THK extrusion.max= 1.5*$HFin \
          xrefine= "0.005/$fp"  yrefine= "$PolyPitch/(20.0*$fp)" zrefine= "$FinPitch/(10.0*$fp)" Silicon

icwb.create.mask layer.name= "GATE" name= Gate polarity= positive
refinebox name= YExt mask= Gate \
          extend= 0.002 extrusion.min= 0.0 extrusion.max= $HFin \
          xrefine= "0.002/$fp"  yrefine= "$PolyPitch/(40.0*$fp)" zrefine= "$FinPitch/(20.0*$fp)" Silicon 

refinebox name= ChannelIF mask= FinMask \
          extend= 0.001 extrusion.min= -$gox extrusion.max= $HFin \
          min.normal.size= 0.001/$fp normal.growth.ratio= 2.0 interface.materials= {Silicon Oxide} Silicon

}

#split @Ext@

#-- To activate Molefraction Dependent stress ---#
pdbSetDoubleArray Silicon Carbon Conc.Strain {0 0 1 -0.432}
pdbSetDouble Silicon Mechanics TopRelaxedNodeCoord 0.05e-4

# ------------ Halo Implantation ----------------------------------
deposit material= {Oxynitride} type= fill coord= -$Tpoly-$gox-$HFin-0.15
etch    material= {Oxynitride} type= anisotropic rate= {$Tpoly+$gox+$HFin+0.15} time= 1.5 mask= NWELL
if { $debug } { struct tdr.bnd= n@node@_17 }

if { $FastMode == 0 } {
implant Boron dose= 1.1e+14 energy= 5.5 tilt= 15 rotation= 30  
implant Boron dose= 1.1e+14 energy= 5.5 tilt= 15 rotation= 150 
implant Boron dose= 1.1e+14 energy= 5.5 tilt= 15 rotation= 210 
implant Boron dose= 1.1e+14 energy= 5.5 tilt= 15 rotation= 330  

## ---------- S/D Extension implantation for nFinFET -----------------------
implant Carbon  dose= 2.0e15 energy= 2.0  tilt= 10 rotation= 0.0 !pai
implant Carbon  dose= 2.0e15 energy= 2.0  tilt= 10 rotation= 180.0 !pai

implant Arsenic dose= 1.0e15 energy= 4.0  tilt= 10 rotation= 0.0
implant Arsenic dose= 1.0e15 energy= 4.0  tilt= 10 rotation= 180.0
} 

struct tdr= n@node@_Extn
strip Oxynitride

deposit material= {Oxynitride} type= fill coord= -$Tpoly-$gox-$HFin-0.15
etch    material= {Oxynitride} type= anisotropic rate= {$Tpoly+$gox+$HFin+0.15} time= 1.5 mask= PWELL
if { $debug } { struct tdr.bnd= n@node@_18 }

# ------------ Halo Implantation ----------------------------------
if { $FastMode == 0 } {
implant Arsenic dose= 4.55e13 energy= 25 tilt= 20 rotation= 30    
implant Arsenic dose= 4.55e13 energy= 25 tilt= 20 rotation= 150   
implant Arsenic dose= 4.55e13 energy= 25 tilt= 20 rotation= 210   
implant Arsenic dose= 4.55e13 energy= 25 tilt= 20 rotation= 330   

implant Phosphorus dose= 1.5e13 energy= 40 tilt= 20 rotation= 30
implant Phosphorus dose= 1.5e13 energy= 40 tilt= 20 rotation= 150
implant Phosphorus dose= 1.5e13 energy= 40 tilt= 20 rotation= 210
implant Phosphorus dose= 1.5e13 energy= 40 tilt= 20 rotation= 330

## ---------- S/D Extension implantation for pFinFET -----------------------
implant BF2  dose= 1.0e15 energy= 2.5 tilt= 10 rotation= 0.0
implant BF2  dose= 1.0e15 energy= 2.5 tilt= 10 rotation= 180.0
}

struct tdr=n@node@_Extp
strip Oxynitride

if { $FastMode == 0 } {
diffuse temperature= 750<C> time= 1<min> info= 1
}

#split @SD@

# Spacer
deposit material= {Nitride} type= isotropic rate= {$Lspepi} time= 1.0
etch material= {Nitride Oxide} type= anisotropic rate= {$HFin $HFin} time= 1.8
if { $debug } { struct tdr.bnd= n@node@_19 }

deposit oxide fill coord= $HFin
if { $debug } { struct tdr.bnd= n@node@_20 }

# Diamond shaped Si/SiGe Pocket

SiGe_and_Stress_Effect 1 1 1 0
pdbSet SiGe Ge Min.Conv.Conc 1e22
  
mater add name= SiGePocket new.like= Silicon alt.matername= SiliconGermanium 
mater add name= SMTPocket new.like= Silicon alt.matername= Silicon 

# Height and Dimension of the pocket
set height  [expr 1.3*$HFin]
set width   [expr 1.25*$FinPitch]
set xcenter [expr $HFin/2.2]
set length  [expr $PolyPitch-$Lg-1.8*($PolyReox+$Lsp)]

#if @[ string match @Domain@ "SRAM10T" ]@

## First separate PFET and NFET
   photo mask= NWELL thickness= 0.2  
   etch   material= {Silicon} type= anisotropic rate= {0.002} time= 1.0
   etch   material= {Silicon} type= isotropic rate= {0.001} time= 1.0
   deposit oxide fill coord= $HFin 
   if { $debug } { struct tdr.bnd= n@node@_21 }
 
   deposit material= { Aluminum } rate= 0.005 time= 1.0 type= isotropic selective.materials= {Silicon}
   strip Photoresist
   
   deposit Nickel fill coord= 0.03
   deposit material= {Oxynitride} rate= 0.005 time= 1.0 type= isotropic selective.materials= {Silicon}
   strip Nickel
   if { $debug } { struct tdr.bnd= n@node@_SepNP }
   
grid remesh
   
## Extract the interface regions for NFET and PFET 
   set NMOS_IF [FindInterfaceRegions Oxynitride]
   set PMOS_IF [FindInterfaceRegions Aluminum]   
   
   puts "nIF : $NMOS_IF "
   puts "pIF : $PMOS_IF "


## Loop through the regions and create the SiGe pockets for PFET
   set i 0
   foreach Region $PMOS_IF {
      set RBBox [ region name= $Region bbox ]
      set YRmin [expr 1e4 * [lindex [lindex $RBBox 0] 1]]
      set ZRmin [expr 1e4 * [lindex [lindex $RBBox 0] 2]]
      set YRmax [expr 1e4 * [lindex [lindex $RBBox 1] 1]]
      set ZRmax [expr 1e4 * [lindex [lindex $RBBox 1] 2]]
         
      set YR [expr ($YRmax+$YRmin)/2.0 ]
      set ZR [expr ($ZRmax+$ZRmin)/2.0 ]

   	HexaPrism SiGe_${i} $height $xcenter $YR $ZR 40.0 $length $width
	polyhedron list
	insert polyhedron= SiGe_${i} replace.materials= { Gas Aluminum } new.material= SiGePocket new.region= SiGePocket_${i}
	if { $debug } { struct tdr.bnd= n@node@_SiGe_${i} }
      set i [expr $i+1]
   
   }

## Loop through the regions and create the SMT pockets for NFET
   set i 0
   foreach Region $NMOS_IF {
      set RBBox [ region name= $Region bbox ]
      set YRmin [expr 1e4 * [lindex [lindex $RBBox 0] 1]]
      set ZRmin [expr 1e4 * [lindex [lindex $RBBox 0] 2]]
      set YRmax [expr 1e4 * [lindex [lindex $RBBox 1] 1]]
      set ZRmax [expr 1e4 * [lindex [lindex $RBBox 1] 2]]
      
      set YR [expr ($YRmax+$YRmin)/2.0 ]
      set ZR [expr ($ZRmax+$ZRmin)/2.0 ]


	HexaPrism SMT_${i} $height $xcenter $YR $ZR 40.0 $length $width
	polyhedron list
	insert polyhedron= SMT_${i} replace.materials= { Gas Oxynitride } new.material= SMTPocket new.region= SMTPocket_${i}
	if { $debug } { struct tdr.bnd= n@node@_SMT_${i} }
      set i [expr $i+1]
   
   }
   strip Aluminum
   strip Oxynitride

set Nge [lindex [GetMoleFractionFields Si SiGe 0.3] 2]
sel z= $Nge name= Germanium SiGePocket store
sel z= 1.5e20 name= Boron     SiGePocket store
sel z= 2.5e20 name= Arsenic   SMTPocket  store
sel z= 1.5e21 name= Carbon    SMTPocket  store
ChangeMaterialMatchRegions SMTPocket Silicon Nozerodata
ChangeMaterialMatchRegions SiGePocket Silicon Nozerodata
      
#elif @[ string match "TN" @Domain@ ]@

HexaPrism SMT_n $height $xcenter $Ymin $Zmax 40.0 $length $width
polyhedron list
insert polyhedron= SMT_n replace.materials= { Gas } new.material= SMTPocket new.region= SMTPocket_1
if { $debug } { struct tdr.bnd= n@node@_21 }

grid remesh
sel z= 1.5e20 name= Arsenic   SMTPocket  store
sel z= 1.5e21 name= Carbon    SMTPocket  store
ChangeMaterialMatchRegions SMTPocket Silicon Nozerodata

#elif @[ string match "TP*" @Domain@ ]@

etch    material= {Silicon} type= anisotropic rate= {0.003} time= 1.0
etch    material= {Silicon} type= isotropic rate= {0.001} time= 1.0
deposit material= {Oxide}   type= fill coord= $HFin

HexaPrism SiGe_p $height $xcenter $Ymin $Zmax 40.0 $length $width
polyhedron list
insert polyhedron= SiGe_p replace.materials= { Gas } new.material= SiGePocket new.region= SiGePocket_1
if { $debug } { struct tdr.bnd= n@node@_21 }

grid remesh
sel z= 1.5e22 name= Germanium SiGePocket store
sel z= 1.5e20 name= Boron     SiGePocket store
ChangeMaterialMatchRegions SiGePocket Silicon Nozerodata

#endif

if { $FastMode == 0 } {
diffuse time= 1e-8<s> temp= 600 init= 1e-8<s>
}

struct tdr= n@node@_Poly
if { $debug } { struct tdr.bnd= n@node@_Pocket }

# ---------------------------------------------------------------
#   SD Implantation
#----------------------------------------------------------------
deposit material= {Oxynitride} type= fill coord= -$Tpoly-$gox-0.1
etch    material= {Oxynitride} type= anisotropic rate= {$Tpoly+$gox+0.1} time= 1.5 mask= NWELL

if { $FastMode == 0 } {
implant Arsenic dose= 5.0e+15 energy= 15.0 tilt= 0 rotation= 0
}

if { $debug } { struct tdr.bnd= n@node@_22 }

strip Oxynitride

deposit material= {Oxynitride} type= fill coord= -$Tpoly-$gox-0.1
etch    material= {Oxynitride} type= anisotropic rate= {$Tpoly+$gox+0.1} time= 1.5 mask= PWELL

if { $FastMode == 0 } {
implant BF2 dose= 1.5e15 energy= 10.0 tilt= 0 rotation= 0
}

if { $debug } { struct tdr.bnd= n@node@_23 }

strip Oxynitride


if { $FastMode == 0 } {
# ---- spike RTA ----
temp_ramp name= spike1000 time= 2<s>     ramprate= 200<C/s>   temperature= 600.0
temp_ramp name= spike1000 time= 0.1<s>   ramprate=   0<C/s>   temperature= 1000.0
temp_ramp name= spike1000 time= 4<s>     ramprate= -75<C/s>   temperature= 1000.0

diffuse temp.ramp= spike1000 stress.relax

# ---- laser annealing ----
temp_ramp name= laser time= 1e-03<s> ramprate= 6e+05<C/s>    temperature= 600.0
temp_ramp name= laser time= 1e-06<s> ramprate= 0<C/s>        temperature= 1200.0
temp_ramp name= laser time= 1e-03<s> ramprate= -5e+04<C/s>   temperature= 1200.0

diffuse temp.ramp= laser stress.relax
}

#split @Silicide@

pdbSet Diffuse minT 500

diffuse stress.relax time= 1<min> temp= 20 ramprate= [expr 450.0 - 20.0]<C/min>

deposit material= {NickelSilicide} temperature= 450 type= isotropic rate= 0.003 time= 1.0 selective.materials= {Silicon SiliconGermanium SiGePocket}
if { $debug } { struct tdr.bnd= n@node@_24 }

diffuse stress.relax time= 1<min>  temperature= 450 ramprate= [expr 20.0 - 450.0]<C/min>

#split @DeviceMesh@
#-------------------------------------
#set YMax 1
#set ZMax 1
#set HFin 0.04
puts "DOE: YMax [format %.3f $Ymax]"
puts "DOE: ZMax [format %.3f $Zmax]"
puts "DOE: HFin [format %.3f $HFin]"
#-------------------------------------
fset fd 1.0

#Polishing
etch material= {Nitride} type= cmp coord= -3*$gox-$THK-$MetalG
etch material= {Oxide} type= cmp coord= -3*$gox-$THK-$MetalG
if { $debug } { struct tdr.bnd= n@node@_25 }

#Remove Poly and metal gate
strip PolySilicon
strip TiNitride
if { $debug } { struct tdr.bnd= n@node@_26 }

#Remeshing for device simulation - clear the process simulation mesh-------## 
refinebox clear
line clear

# Set very high values for adaptive meshing parameters
pdbSet Grid AdaptiveField Refine.Abs.Error 1e37
pdbSet Grid AdaptiveField Refine.Rel.Error 1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0

# Set high quality delaunay meshes
pdbSet Grid Adaptive 1
pdbSet Grid SnMesh DelaunayType boxmethod
pdbSet Grid SnMesh CoplanarityAngle 179
pdbSet Grid SnMesh max.box.angle.3d 179

grid set.min.normal.size= 0.1/$fd \
 set.normal.growth.ratio.3d= 8.0 \
 set.max.points= 20000000 \
 set.max.neighbor.ratio= 1e6

# Refinement strategy 
refinebox name= DF min= " -0.01 $Ymin $Zmin" max= "$Tsub $Ymax $Zmax" \
	  refine.fields= {NetActive} def.max.asinhdiff= 1.0 \
          refine.max.edge= "0.2/$fd  0.2/$fd  0.2/$fd" \
          refine.min.edge= "0.01/$fd  0.01/$fd  0.01/$fd" adaptive materials= {Silicon SiliconGermanium}
		  
refinebox name= DG mask= Gate \
          extend= 0.0025 extrusion.min= -0.01 extrusion.max= $HFin+0.01 \
          xrefine= "0.008/$fd"  yrefine= "$PolyPitch/(15.0*$fd)" zrefine= "$FinPitch/(5.0*$fd)" \
          materials= {Silicon SiliconGermanium}

refinebox name= DeviceIF mask= Gate \
          extend= 0.005 extrusion.min= -0.01 extrusion.max= $HFin+0.01 \
          min.normal.size= 0.001/$fd normal.growth.ratio= 1.5 \
          interface.materials= {Silicon Oxide SiliconGermanium Oxide}
		  
grid remesh

#if @[ string match "SRAM10T" @Domain@]@

#-Contacts
icwb.contact.mask layer.name= "Gate_ACC1" name= GateACC1 box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "Gate_ACC2" name= GateACC2 box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "Gate_A1"   name= GateA1   box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "Gate_A2"   name= GateA2   box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas


icwb.contact.mask layer.name= "Drain_ACC1" name= DrainACC1 x= 0.012 point NickelSilicide replace
icwb.contact.mask layer.name= "Drain_ACC2" name= DrainACC2 x= 0.012 point NickelSilicide replace


icwb.contact.mask layer.name= "Gate_N1" name= GateN1 box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "Gate_N2" name= GateN2 box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "PS1" name= SourceN1 x= 0.012 point NickelSilicide replace
icwb.contact.mask layer.name= "PS2" name= SourceN2 x= 0.012 point NickelSilicide replace
icwb.contact.mask layer.name= "PD1" name= DrainN1 x= 0.012 point NickelSilicide replace
icwb.contact.mask layer.name= "PD2" name= DrainN2 x= 0.012 point NickelSilicide replace

icwb.contact.mask layer.name= "Gate_P1"   name= GateP1 box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "Gate_P2"   name= GateP2 box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "Source_P1" name= SourceP1 x= -0.009 point NickelSilicide replace
icwb.contact.mask layer.name= "Source_P2" name= SourceP2 x= -0.009 point NickelSilicide replace
icwb.contact.mask layer.name= "Drain_P1"  name= DrainP1  x= -0.009 point NickelSilicide replace
icwb.contact.mask layer.name= "Drain_P2"  name= DrainP2  x= -0.009 point NickelSilicide replace

icwb.contact.mask layer.name= "Source_P1" name= SubnWell1  box Silicon xlo= $STI_depth*0.9  xhi=$STI_depth*1.1 sidewall !cut.mesh
icwb.contact.mask layer.name= "Source_P2" name= SubnWell2  box Silicon xlo= $STI_depth*0.9  xhi=$STI_depth*1.1 sidewall !cut.mesh
contact bottom name= substrate Silicon


struct tdr= n@node@ !gas

#else

icwb.contact.mask layer.name= "Gate_N1" name= Gate box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "PS1" name= Source x= 0.012 point NickelSilicide replace

icwb.contact.mask layer.name= "Gate_P1"   name= Gate box HfO2 xlo= -$gox-$THK-$MetalG xhi= $HFin+0.001 adjacent.material= Gas
icwb.contact.mask layer.name= "Source_P1" name= Source x= -0.009 point NickelSilicide replace

contact bottom name= substrate Silicon
struct tdr= n@node@_half !gas

if { [catch { exec tdx -mtt -Y -ren Source=Drain n@node@_half_fps.tdr n@node@_fps.tdr} Err] !=0 } { 
    LogFile $Err
} 
#endif

#Remove selected TDR files to reduce project size
if { [catch {fexec rm n2_fps.tdr n3_fps.tdr n4_fps.tdr n5_fps.tdr n6_fps.tdr} Err] !=0 } {
   LogFile $Err
}
exit

