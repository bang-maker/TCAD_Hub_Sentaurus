#header

#rem #---------------------------------------------------------------------#
#rem #   LAYOUT
#rem #---------------------------------------------------------------------#

set Domain @CUT@

#if "@Layout@" == "gds"

 #rem # Loading of "GDSII Layout" file.
 if { $Domain == "SIM2N" } {
	icwb gds.file= "SRAM.gds" cell= "Cell" scale= 1e-3 \
	layer.numbers=  {1:0 2:0 3:0 5:0 6:0 7:0 8:0 30:1 31:0 32:0 33:0 34:0 35:0 36:1 37:1 38:1 39:1 40:1 41:1 51:0 52:0 53:0 54:0 60:1} \
	layer.names= {Active pWELL POLY VIA1 METAL1 VIA2 METAL2 Gate_ACC1 Drain_ACC1 Drain_N1 Source_N1 Drain_P1 Source_P1 Gate_ACC2 Drain_ACC2 Drain_N2 Source_N2 Drain_P2 Source_P2 Gate_N1 Gate_N2 Gate_P2 Gate_P1 Mesh_EXT} \
	sim2d= "-240.0 112.5 -240.0 0.0" \
	stretches= {MOS_L= {-325.0 55.00 -170.0 55.00}}
 } elseif { $Domain == "SIM2P" } {
        icwb gds.file= "SRAM.gds" cell= "Cell" scale= 1e-3 \
	layer.numbers=  {1:0 2:0 3:0 5:0 6:0 7:0 8:0 30:1 31:0 32:0 33:0 34:0 35:0 36:1 37:1 38:1 39:1 40:1 41:1 51:0 52:0 53:0 54:0 60:1} \
	layer.names= {Active pWELL POLY VIA1 METAL1 VIA2 METAL2 Gate_ACC1 Drain_ACC1 Drain_N1 Source_N1 Drain_P1 Source_P1 Gate_ACC2 Drain_ACC2 Drain_N2 Source_N2 Drain_P2 Source_P2 Gate_N1 Gate_N2 Gate_P2 Gate_P1 Mesh_EXT} \
	sim2d= "-80.0 112.5 -80.0 0.0" \
	stretches= {MOS_L= {-140.0 55.00 -30.0 55.00}}
	#rem # Define stretch marks for parameterization
 }

icwb stretch name= "MOS_L" value=@<(lg-0.030)>@

#else

icwb filename= "SRAM_lyt.mac" scale=1e-3
#rem # Loading of the "TCAD Layout" file. # scaling all coordinates from nm to um.

set Domains [icwb list domains]
#rem # Query utility: Listing all simulation domain names found in the "TCAD Layout" file.
LogFile "icwb: LDomains -> $Domains"

set LNames  [icwb list layerNames]
#rem # Query utility: Listing all layer names found in the "TCAD Layout" file.
LogFile "icwb: LNames -> $LNames"

set LIDs     [icwb list layerIDs]
#rem # Query utility: Listing all layer IDs found in the "TCAD Layout" file.
LogFile "icwb: LIDs -> $LIDs"

icwb domain= $Domain

icwb stretch name= "${Domain}_L" value=@<(lg-0.030)>@

#endif

set DIM [icwb dimension]
#rem # Query utility: Returns the dimension of the selected simulation domain.
LogFile "icwb: dimension -> $DIM"

#rem # Query utility: Returns the boundaries of the 2D simulation domain
set Ymin [icwb bbox left]
set Ymax [icwb bbox right]
LogFile "icwb: Domain boundaries -> $Ymin $Ymax"

set Ymid [expr ($Ymax-$Ymin)/2.0]

set CNode @node@
#endheader

# unified Coordinate system
math coord.ucs
# uncomment following line, if you have 8 CPU or more.
math numThreads= 8

AdvancedCalibration
SiGe_and_Stress_Effect 1 1 1 0

pdbSet ImplantData ResistSkip 1
pdbSet ImplantData LeftBoundary Reflect
pdbSet ImplantData RightBoundary Reflect

# Enable stress history
pdbSet Mechanics StressHistory 1
pdbSet Mechanics StressRelaxFactor 1
pdbSet Silicon Mechanics Anisotropic 1

# Disable stress re-balancing after etch/depo step
pdbSet Mechanics EtchDepoRelax 0
pdbSet ImplantData Extrude 1
pdbSet InfoDefault 1
pdbSet Oxide_Silicon Boundary BoundaryCondition ThreePhaseSegregation

# Initial Boundary
fset Xbot 10
fset Xtop 0

#rem #---------------------------------------------------------------------#
#rem #   PARAMETERS
#rem #---------------------------------------------------------------------#
fset PolyPitch 0.1125
fset GateThick 0.035
fset PolyReox 0.0025
fset Tox 0.0006
fset THF 0.0020
fset NMOS_recess 0.01
fset PMOS_pocket 0.08
fset Lsp 0.014
fset FastMode 0
fset debug 0
fset Lg    @lg@
fset f     1.0
fset HaloDepth 0.08

#-------------------------------------#
#rem# Stress parameter
#-------------------------------------#
fset STRESS_TENSILE_NMOS_DSL_Pa 3e9
fset STRESS_COMP_PMOS_DSL_Pa -6e9

#-------------------------------------#
#rem# LASER Parameter (Fast Ramp)
#-------------------------------------#
fset LASER_AMBIENT_TEMP_degC 600
fset LASER_DURATION_ms 1.0

#--------------------------------------#
## Initialization for Epitaxial parameters
#--------------------------------------# 
fset epi_temp 740.0
fset epi_thick 0.05
fset count 1

fproc WriteBND {} {
        global count
        global CNode
        
        if { $count < 10} {
           struct tdr.bnd=n${CNode}_0${count} 
        } else {
           struct tdr.bnd=n${CNode}_${count} 
        }
        incr count
}

#--------------------------------------#
## Initial Boundary
#--------------------------------------#

line x location= $Xtop tag= top
line x location= $Xbot tag= bottom
line y location= $Ymin tag= left
line y location= $Ymid tag= right

region Silicon substrate xlo= top xhi= bottom ylo= left yhi= right 
init concentration= 1e15 field= Boron slice.angle=45

# -------------------------------------------------------------------- #
grid set.min.normal.size= 0.001/$f \
     set.normal.growth.ratio.2d= 2.0
# -------------------------------------------------------------------- #

refinebox interface.materials= {Silicon Oxide}
icwb.create.mask name= Active layer.name= "Active" polarity= positive
refinebox name= WellVt mask= Active \
    extend= 0.005 extrusion.min= 0.0 extrusion.max= 0.4 \
    xrefine= "0.005/$f"  yrefine= "$PolyPitch/(10.0*$f)" 
 
# --- well and channel implantation and annealing ---
deposit material= {Oxide} type= isotropic  rate= {1.0} time= 0.005

icwb.create.mask layer.name= "pWELL" name= PWELL info= 1 polarity= negative
photo mask= PWELL thickness= 1.0

implant Boron dose= 2e+13 energy= 300.0 tilt= 0.0  
implant Boron dose= 2e+13 energy= 200.0 tilt= 0.0  
implant Boron dose= 1e+13 energy=  70.0 tilt= 0.0  
implant Boron dose= 1e+13 energy=  25.0 tilt= 0.0 
strip Photoresist

icwb.create.mask layer.name= "pWELL" name= NWELL info= 1 polarity= positive
photo mask= NWELL thickness= 1.0

implant Phosphorus dose= 2.5e13 energy= 400 tilt= 0.0
implant Phosphorus dose= 1.0e13 energy= 180 tilt= 0.0
implant Phosphorus dose= 1.0e12 energy= 50  tilt= 0.0

implant Arsenic    dose= 1e13 energy= 130 tilt= 0.0
implant Arsenic    dose= 8.0e12 energy= 70 tilt= 0.0
implant Arsenic    dose= 1e12 energy=  50 tilt= 0.0

strip Photoresist

# -------------------------------------------------------------------- #
SetPlxList { Boron_Implant Arsenic_Implant Phosphorus_Implant }
WritePlx n@node@_well_imp.plx y= $Ymid
# -------------------------------------------------------------------- #
temp_ramp name= well time= 1.8<s>  temp= 600.0  ramprate= 250.0
temp_ramp name= well time= 20.0<s> temp= 1050.0 ramprate= 0.0
temp_ramp name= well time= 5.0<s>  temp= 1050.0 ramprate= -90.0

if { $FastMode != 1  } {
diffuse stress.relax temp_ramp= well
}
# -------------------------------------------------------------------- #
SetPlxList { BTotal AsTotal PTotal }
WritePlx n@node@_well.plx y= $Ymid
# -------------------------------------------------------------------- #
strip Oxide 

# ------------------------------------
#split @Poly@
# ------------------------------------

## ---------- gate oxidation --------------------------------------
deposit material= {Oxide} type= isotropic  rate= {1.0} time= $Tox

if { $debug } { WriteBND }
temp_ramp name= gateox time= 24 temp= 600.0 ramprate= 0.0972
temp_ramp name= gateox time= 20 temp= 740.0 ramprate= 0.0
temp_ramp name= gateox time= 5.6<s> temp= 740.0 ramprate= -25.0

if { $FastMode != 1  } {
diffuse stress.relax temp_ramp= gateox
}

##---------------High-k MetalGate -----------
deposit HfO2 thickness= $THF<um>

mater add name= TiNitride new.like= Nitride
mater add name= AlNitride new.like= Nitride
#if [string match @CUT@ "SIM2N"]
deposit TiNitride thickness= 0.005
#else
deposit AlNitride thickness= 0.005
#endif
if { $debug } { WriteBND }

# ---- poly silicon deposition and etching ----
icwb.create.mask layer.name= "POLY" name= POLY info= 1 polarity= negative
deposit material= {Poly} type= anisotropic  thickness= $GateThick+$Tox+0.005 mask= POLY
if { $debug } { WriteBND }

etch material= {Poly} type= cmp coord= -$GateThick-$Tox
if { $debug } { WriteBND }

etch TiNitride thickness= 0.05 type= anisotropic
etch AlNitride thickness= 0.05 type= anisotropic
etch HfO2 thickness= 0.02 type= anisotropic 
if { $debug } { WriteBND }

etch material= {Oxide} type= anisotropic rate= {$Tox} time= 2.0 
strip Photoresist
if { $debug } { WriteBND }

## ---------- Si recess etching --------------------------------
deposit material= Silicon type= fill coord= -0.0008
etch material= Silicon type= trapezoidal rate= $PolyReox-0.001+0.0008*(1-sqrt(2.0)/2.0) time= 1.0 angle= 45.0 undercut= 0.0
etch material= Silicon type= isotropic rate= 0.0008*sqrt(2.0)/2.0 time= 1.0
if { $debug } { WriteBND }

## ---------- reoxidation -----------------------------------------
deposit material= {Oxide} type= isotropic  rate= {1.2} time= $PolyReox
if { $debug } { WriteBND }

temp_ramp name= polyreox time= 4.0<s> temp= 600.0 ramprate= 50.0
temp_ramp name= polyreox time= 4.0<s> temp= 800.0 ramprate= 25.0
temp_ramp name= polyreox time= 5.0<s> temp= 900.0 ramprate=  0.0
temp_ramp name= polyreox time= 4.0<s> temp= 900.0 ramprate= -25.0
temp_ramp name= polyreox time= 4.0<s> temp= 800.0 ramprate= -50.0
if { $FastMode != 1  } {
diffuse stress.relax temp_ramp= polyreox
}

## ---------- PolyReox spacer etching --------------------------------
etch material= {Oxide} type= anisotropic rate= $PolyReox time= 1.5
deposit material= {Oxide} type= isotropic  rate= {0.8} time= $PolyReox selective.materials= {PolySilicon}
if { $debug } { WriteBND }

# ------------------------------------
#split @Halo@
# ------------------------------------
# --- refinebox for halo implants ----------------------- #
refinebox name= HALO mask= Active \
  extend= 0.0 extrusion.min= -0.001 extrusion.max= 0.065 \
  xrefine= " 0.001/$f 0.004/$f"  yrefine= " 0.004/$f "

##-------------- Epitaxial Si:C growth for nMOS -----------
photo mask= PWELL thickness= 1.0
etch material= Silicon type= anisotropic rate= 2.0*$NMOS_recess time= 1.0
if { $debug } { WriteBND }
etch material= Silicon type= isotropic   rate= 0.25*$NMOS_recess time= 1.0
if { $debug } { WriteBND }

#-- SiC Material: activate Mole-fraction dependent stress ---#
pdbSet Grid NativeLayerThickness 1.5e-7
pdbSetDoubleArray Silicon Carbon Conc.Strain {0 0 1 0.0}
pdbSet Silicon Mechanics UpdateStrain 0

temp_ramp name= epi_SiC temperature= 550<C> t.final= $epi_temp<C> time= 1.0<min> thick= 0.75*$epi_thick<um> \
 epi.doping= { Boron= 1.5e17 Carbon= 2.5e21 } Epi epi.doping.final= { Boron= 8.0e16 Carbon= 2.5e21 } epi.layers= 10 epi.model= 1
diffuse temp_ramp= epi_SiC info= 1
    
etch material= {Silicon} type= cmp coord= -0.0005
etch material= {Silicon} type= anisotropic  rate= {1.0} time= $PolyReox-0.0005
if { $debug } { WriteBND }

pdbSetDoubleArray Silicon Carbon Conc.Strain {0 0 1 -0.432}
pdbSetDouble Silicon Mechanics TopRelaxedNodeCoord 0.15e-4
pdbSet Silicon Mechanics UpdateStrain 1

diffuse stress.relax time= 1e-10 temp= 600
struct tdr= n@node@_sic

strip Photoresist

# --- natural through-oxide from cleaning step ---
etch material= {Oxide} type= isotropic  thickness= 0.001
deposit material= {Oxide} type= isotropic  thickness= 0.001
if { $debug } { WriteBND }

# --- halo implantation ---
# -------------------------------------------------------------------- #

photo mask= PWELL thickness= 0.16

implant BF2 dose= 1.25e13 energy= 15 tilt= 30 rotation=   0
implant BF2 dose= 1.25e13 energy= 15 tilt= 30 rotation=  90
implant BF2 dose= 1.25e13 energy= 15 tilt= 30 rotation= 180
implant BF2 dose= 1.25e13 energy= 15 tilt= 30 rotation= -90 
strip Photoresist

photo mask= NWELL thickness= 0.16
implant Arsenic dose= 1e12 energy= 25 tilt= 45 rotation= 30
implant Arsenic dose= 1e12 energy= 25 tilt= 45 rotation= 120
implant Arsenic dose= 1e12 energy= 25 tilt= 45 rotation= 210
implant Arsenic dose= 1e12 energy= 25 tilt= 45 rotation= 300


strip Photoresist

# -------------------------------------------------------------------- #
SetPlxList { Boron_Implant Arsenic_Implant }
WritePlx n@node@_haloimp.plx y= [expr $Ymid-($Lg/2.0-0.01)]
# -------------------------------------------------------------------- #

#split @Ext@
# -------------------------------------------------------------------- #

icwb.create.mask name= EXT layer.name= "Mesh_EXT" polarity= positive
refinebox name= ExtXY mask= EXT \
  extend= 0.001 extrusion.min= -0.001 extrusion.max= 0.01 \
  xrefine= " 0.001/$f "  yrefine= " 0.001/$f "
  
refinebox name= ExtIF mask= Active \
  extend= 0.0 extrusion.min= -$Tox extrusion.max= 0.01 \
  min.normal.size= 0.0004/$f normal.growth.ratio= 2.0 \
  interface.materials= {Silicon Oxide}
  
grid remesh

# --- source/drain extension implantation ---
photo mask= PWELL thickness= 0.16
implant Arsenic dose= @<2.5e+15*HDoseFactor>@ energy= @<1.0*HErgFactor>@ tilt= 0.0
strip Photoresist

photo mask= NWELL thickness= 0.16
implant Germanium dose= @<1.0e15*HDoseFactor>@ energy= @<25*HErgFactor>@    tilt= 0
implant Carbon    dose= @<6.5e14*HDoseFactor>@ energy= @<5.0*HErgFactor>@   tilt= 0
implant BF2       dose= @<2.0e15*HDoseFactor>@ energy= @<2.0*HErgFactor>@   tilt= 0
strip Photoresist
struct tdr=n@node@_extimp

# -------------------------------------------------------------------- #
SetPlxList { Boron_Implant Arsenic_Implant }
WritePlx n@node@_extimp.plx y= [expr $Ymid-($Lg/2.0-0.01)]
# -------------------------------------------------------------------- #

#split @SD@

## ---------- side wall spacer -----------------------------------
deposit material= {Nitride} type= isotropic rate= {1.0} time= $Lsp
etch material= {Nitride} type= anisotropic rate= 1.6*$Lsp time= 1.0
etch material= {Oxide}   type= anisotropic rate= 0.0015 time= 1.5 
if { $debug } { WriteBND }

photo mask= PWELL thickness= 0.1
if { $debug } { WriteBND }
## ---------- NMOS recess -----------------------
etch material= Silicon type= trapezoidal rate= $NMOS_recess-0.0015 time= 1.0 angle= 45.0 undercut= 0.0
if { $debug } { WriteBND }

etch material= Silicon type= isotropic rate= 0.001 time= 1.0 
if { $debug } { WriteBND }

strip Photoresist
photo mask= NWELL thickness= 0.1
if { $debug } { WriteBND }

## ---------- SiGe pocket for PMOS -----------------------
#etch material= Silicon type= trapezoidal rate=$PMOS_pocket time=0.1 angle= 123 undercut=0.015
etch material= Silicon type= trapezoidal rate=$PMOS_pocket time=0.1 angle= 123 undercut=0.01
if { $debug } { WriteBND }

etch material= Silicon type= directional rate= 0.5*$PMOS_pocket*tan(57.0*atan(1.0)/45.) time= 1.0 \
     direction= { sin(57.0*atan(1.0)/45.) -1.0*cos(57.0*atan(1.0)/45.0) 0 }
if { $debug } { WriteBND }

pdbSet Mechanics StrainedDeposition 1
pdbSet SiGe Ge Min.Conv.Conc 1e22

##REM # To set 30 % Ge-molefraction field on SiGePocket
set Nge [lindex [GetMoleFractionFields Si SiGe 0.3] 2] 
doping name=EpiGe field= Germanium values= {$Nge $Nge}      depths= {0.0 $PMOS_pocket}
doping name=EpiB  field= Boron     values= {2e19  1.0e20}   depths= {0.0 $PMOS_pocket}
##doping name=EpiB  field= Boron     values= {@SDDop@  1.0e20}   depths= {0.0 $PMOS_pocket}
doping name=EpiAs field= Arsenic   values= {2.0e18  2.0e18}   depths= {0.0 $PMOS_pocket}
doping name=EpiP field= Phosphorus   values= {2.0e17  1.0e16}   depths= {0.0 $PMOS_pocket}
doping name=EpiC  field= Carbon    values= {2.5e19  7.5e17}   depths= {0.0 $PMOS_pocket}

deposit material= {Silicon} type= isotropic time= 1.0 rate= $PMOS_pocket \
  selective.materials= {Silicon} doping= {EpiB EpiAs EpiGe EpiC} steps= 10 Strained.Lattice
if { $debug } { WriteBND }

etch material= Silicon type= cmp coord= -0.4*$PMOS_pocket
if { $debug } { WriteBND }

mask name=Pocket left=$Ymid-($Lg/2.0)-0.425*$PMOS_pocket/tan(57.0*atan(1.0)/45.) right=$Ymax
deposit material= {Metal} type= anisotropic time= 1.0 rate= 0.1 mask=Pocket
if { $debug } { WriteBND }

etch material= Silicon type= directional rate= 0.4*$PMOS_pocket time= 1.0 \
     direction= { sin(57.0*atan(1.0)/45.) cos(57.0*atan(1.0)/45.0) 0 }
strip Metal
if { $debug } { WriteBND }

strip Photoresist
# --- natural through-oxide from cleaning step ---
deposit material= {Oxide} type= isotropic  rate= {1.0} time= 0.002
if { $debug } { WriteBND } 

# --- source/drain(HDD)-implantation ---
photo mask= PWELL thickness= 0.16
 
implant Arsenic dose= @<2.5e+15*HDoseFactor>@ energy= @<6.0*HErgFactor>@ tilt= 0.0
strip Photoresist

photo mask= NWELL thickness= 0.16
implant Boron dose= @<1.5e+15*HDoseFactor>@ energy= @<1.5*HErgFactor>@ tilt= 0.0
strip Photoresist

# -------------------------------------------------------------------- #
SetPlxList { Boron_Implant Arsenic_Implant }
WritePlx n@node@_sd.plx y= [expr $Ymid-($Lg/2.0-0.01)]
# -------------------------------------------------------------------- #
struct tdr= n@node@_asImpSD
# -------------------------------------------------------------------- #

##---------------SMT for nMOS-------------------
#if @[ string match "SIM2N" @CUT@]@
    ##Initialization for the Plasticity Model
       pdbSet PolySilicon Mechanics ThExpCoeff  20e-6
       pdbSet PolySilicon Mechanics FirstYield  5.0E10
       pdbSet PolySilicon Mechanics Hardening.Modulus.Isotropic 1.0E10
       
    ## Turn on Plasticity Model
    pdbSet PolySilicon Mechanics IsPlastic 1
    
#endif

## -------Spike+laser annealing-----------------
temp_ramp name= spike time= 1.0<s> temp= 600 ramprate= 350.0
temp_ramp name= spike time= 0.2<s> temp= 950 ramprate= 0.0
temp_ramp name= spike time= 1.5<s> temp= 950 ramprate= -233.3

if { $FastMode != 1  } {
diffuse temp_ramp= spike info= 1 
struct tdr= n@node@_sd
}

#Initial condition
pdbSet Diffuse minT 500.0
pdbSet Heat WaferThickness 500

# ---- light source ----
pdbSet Heat Fluence 8.65
pdbSet Heat Pulse 0.11

# ---- update heat generation rate ----
pdbSet Heat UpdateHeatRate 1

diffuse laser temp= $LASER_AMBIENT_TEMP_degC time= $LASER_DURATION_ms<ms> info= 1 write.temp.file= n@node@_LATemp

## Turn off Plasticity Model
pdbSet PolySilicon Mechanics IsPlastic 0
 
# -------------------------------------------------------------------- #
SetPlxList { BTotal AsTotal }
WritePlx n@node@_anneal.plx y= [expr $Ymid-($Lg/2.0-0.01)]
# -------------------------------------------------------------------- #

#split @Backend@

## ---------- Contact Silicidation -----------------------
etch material= {Oxide} type= anisotropic rate= {0.008} time= 1.0
etch material= {Oxide} type= isotropic   rate= {0.002} time= 1.4
deposit material= {Oxide} type= isotropic   rate= {0.002} time= 1.0 selective.materials= { Polysilicon }
if { $debug } { WriteBND }

##database for NiSi formation
pdbSet NickelSilicide Silicon ORS 0
pdbSet Grid MinimumVelocity  1e-12
pdbSet NickelSilicide Grid perp.add.dist 2e-7

##To controll NiSi growth and Reaction kinetics with Silicon and polySilicon Only...
pdbSet NickelSilicide Silicon Dstar { {[Arr 0.02  1.6]} }

pdbSet NickelSilicide_Silicon Silicon Expansion.Ratio 1.0
pdbSet Nickel_NickelSilicide  Silicon Expansion.Ratio 1.0

pdbSet NickelSilicide_Silicon SilicidationTripleDistance 20e-7
pdbSet Nickel_NickelSilicide SilicidationTripleDistance 20e-7

etch material= {Silicon} type= isotropic rate= {0.0005} time= 1.0

pdbSet Silicon Mechanics UpdateStrain 0
deposit Nickel type= isotropic thickness= 0.01
if { $debug } { WriteBND }

diffuse time= 0.5<s> temp= 500<C> minT= 300<C> stress.relax
strip Nickel
etch material= {Oxide} type= isotropic   rate= {0.002} time=1.5
    
pdbSet Silicon Mechanics UpdateStrain 1
if { $debug } { WriteBND }

# -- DSL Material Deposition
#if @[ string match "SIM2N" @CUT@]@
doping name= Stress_TensDSL field= Pressure depths= {-0.3 0.01} \
	values= { -1*$STRESS_TENSILE_NMOS_DSL_Pa  -1*$STRESS_TENSILE_NMOS_DSL_Pa }
deposit material= {Oxynitride} doping= {Stress_TensDSL} type= isotropic rate= 1.0 time= 0.075 steps= 25
#else
doping name= Stress_CompDSL field= Pressure depths= {-0.3 0.01} \
	values= { -1*$STRESS_COMP_PMOS_DSL_Pa  -1*$STRESS_COMP_PMOS_DSL_Pa }
deposit material= {Oxynitride} doping= {Stress_CompDSL} type= isotropic rate= 1.0 time= 0.075 steps= 25
#endif
if { $debug } { WriteBND }

# -------------------------------------------------------------------- #
#set Lgeff 0.0
#set Xj    0.0
set Ygox [expr [lindex [ lsort -real [interface oxide /silicon y = 0.05 ]] 0 ] + 0.005]
sel z = { NetActive }
set Xgd [format %.3e [lindex [lsort -real [interpolate x= $Ygox  silicon val=2e16]] 0]]
set Xj  [format %.3e [lindex [lsort -real [interpolate y= 0.005 silicon val=2e16]] 0]]
puts "DOE: Lgeff [format %.4e [expr 2*($Ymid-$Xgd)]]"
puts "DOE: Xj $Xj"
# -------------------------------------------------------------------- #

#split @Mesh@
# -------------------------------------------------------------------- #
# Re-Meshing for Device Simulation
# -------------------------------------------------------------------- #

strip Oxynitride 
strip PolySilicon

# Truncate bottom
transform cut min= {-10 -10 -10} max= {0.5 1.0 1.0}

##---------------Remeshing for device simulation--------##
# clear the process simulation mesh
refinebox clear
refinebox !keep.lines
line clear
line x location= 0.0 tag= SiTop

# Mesh Multiplication factor for device
set fd 1.0

# reset default settings for adaptive meshing
pdbSet Grid AdaptiveField Refine.Abs.Error 1e37
pdbSet Grid AdaptiveField Refine.Rel.Error 1e10
pdbSet Grid AdaptiveField Refine.Target.Length 100.0

# Set high quality delaunay meshes
pdbSet Grid sMesh 1
pdbSet Grid SnMesh DelaunayType boxmethod
pdbSet Grid SnMesh CoplanarityAngle 179
pdbSet Grid SnMesh MaxPoints 500000
pdbSet Grid SnMesh MaxNeighborRatio 1e6

# Set the interface spacing
pdbSet Grid SnMesh max.box.angle.2d 179
grid adaptive set.min.normal.size= 0.01/$fd \
     set.normal.growth.ratio.3d= 4.0 \
     set.max.points= 500000 \
     set.max.neighbor.ratio= 1e6

# Refinement strategy

## Convert Si -> SiGe(x)
##pdbSet SiGe Ge Min.Conv.Conc 1e20
##diffuse time= 1e-10<s> temp= 500<C>

refinebox name= DA mask= Active \
  extend= 0.01 extrusion.min= -0.05 extrusion.max= 0.5 \
  refine.fields= { NetActive} def.max.asinhdiff= 0.5 \
  refine.max.edge= "0.02/$fd  $PolyPitch/(8*$fd)" \
  refine.min.edge= "0.002/$fd $PolyPitch/(32*$fd)" adaptive Silicon

refinebox name= DE mask= EXT \
  extend= 0.005 extrusion.min= -0.0 extrusion.max= 0.025 \
  xrefine= "0.002/$fd"  yrefine= "0.005/$fd" Silicon

icwb.create.mask name= Device_Channel layer.name= "POLY" polarity= positive

refinebox name= DC mask= Device_Channel \
  extend= 0.025 extrusion.min= -0.001 extrusion.max= 0.025 \
  refine.fields= { NetActive} def.max.asinhdiff= 1.0 \
  refine.max.edge= "0.005/$fd $PolyPitch/(32*$fd)" \
  refine.min.edge= "0.0025/$fd  $PolyPitch/(128*$fd)" adaptive Silicon
  
refinebox name= DeviceIF mask= Device_Channel \
  extend= 0.01 extrusion.min= -0.001 extrusion.max= 0.005 \
  min.normal.size= 0.0002/$fd normal.growth.ratio= 1.1  \
  interface.materials= {Silicon Oxide} Silicon

refinebox name= PDeviceIF mask= Device_Channel \
  extend= 0.025 extrusion.min= -0.035 extrusion.max= 0.0 \
  min.normal.size= 0.0002/$fd normal.growth.ratio= 1.2  \
  interface.materials= {Silicon Nitride} Silicon

icwb.create.mask name= SDN layer.name= "Source_N1" polarity= positive 
refinebox name= nsd mask= SDN \
   extend= 0.03 extrusion.min= -0.0 extrusion.max= 0.08 \
   xrefine= "0.005/$fd"  yrefine= "0.005/$fd" Silicon

icwb.create.mask name= SDP layer.name= "Source_P1" polarity= positive
refinebox name= psd mask= SDP \
   extend= 0.03 extrusion.min= -0.025 extrusion.max= 0.08 \
   xrefine= "0.005/$fd"  yrefine= "0.005/$fd" Silicon
   
grid remesh info= 1

transform reflect right

# Contacts

#if @[ string match "SIM2N" @CUT@]@
icwb.contact.mask layer.name= "Drain_N1"  name= drain  point NickelSilicide x= $NMOS_recess+0.0025 adjacent.material= Silicon
icwb.contact.mask layer.name= "Source_N1" name= source point NickelSilicide x= $NMOS_recess+0.0025 adjacent.material= Silicon
icwb.contact.mask layer.name= "Gate_N1"   name= gate   point TiNitride x= -$THF-$Tox-0.004 replace

#elif @[ string match "SIM2P" @CUT@]@
icwb.contact.mask layer.name= "Drain_P1"  name= drain  point NickelSilicide x= -0.03 adjacent.material= Silicon
icwb.contact.mask layer.name= "Source_P1" name= source point NickelSilicide x= -0.03 adjacent.material= Silicon
icwb.contact.mask layer.name= "Gate_P1"   name= gate   point AlNitride x= -$THF-$Tox-0.004 replace

#endif
contact bottom name= Substrate Silicon

#if 0
region name=HfO2_1 Polysilicon change.material !zero.data

#if @[ string match "SIM2N" @CUT@]@
select z= "1.0e20" name= NetActive PolySilicon store
#elif @[ string match "SIM2P" @CUT@]@
select z= "-4.0e19" name= NetActive PolySilicon store
#endif

#endif

struct tdr= n@node@ !gas

exit



