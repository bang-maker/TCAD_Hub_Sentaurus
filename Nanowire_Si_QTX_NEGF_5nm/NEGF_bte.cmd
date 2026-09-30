#setdep @node|TensorMesh@

#define _DebugTDR_ 0

## Set device specific variables
set Type @Type@
if {[string compare $Type nMOS]==0} {
    puts "nMOS Structure"
    set sign 1
    set valleys [list Delta1 Delta2 Delta3]
} else {
    puts "pMOS Structure"
    set sign -1
    set valleys [list Gamma]
}

###--- Material definition in TDR ---###
Material  name=LowK     type=insulator
###----------------------------------###

## Load TDR
LoadDevice tdrFile=n@node|TensorMesh@_msh.tdr

## Set device temperature
Physics temperature=300.0

## Set coordinate system
set cDir @cDir@
if {[string compare $cDir 100]==0} {
    puts "Channel orientation: 100"
    set xDirection [list 0 0 1]
    set yDirection [list 0 1 0]
    set channelDir [list 1 0 0]
} elseif {[string compare $cDir 110]==0} {
    puts "Channel orientation: 110"
    set xDirection [list 0 0 1]
    set yDirection [list -1 1 0]    
    set channelDir [list 1 1 0]
}
Physics xDirection=$xDirection yDirection=$yDirection

## Set band & electrical models
source physics_band.tcl

## Define stress tensor in device coordinate system
set stressTensorDevCoord [list [list @Sxx@ 0 0] [list 0 @Syy@ 0] [list 0 0 @Szz@] ]

## Calculate strain tensor in crystal coordinate system
set xAxis [unitVec $xDirection]
set yAxis [unitVec $yDirection]
set zAxis [crossProduct $xAxis $yAxis]
set zAxis [unitVec $zAxis]
set A [list $xAxis $yAxis $zAxis]
set stressTensorCryCoord  [matrixProduct [transposeMatrix $A] [matrixProduct $stressTensorDevCoord $A] ]
set strainTensorCryCoord  [E strainFromStress stress=$stressTensorCryCoord]
puts "Stress Tensor in device coordinates:"
puts "$stressTensorDevCoord \n"
puts "Strain Tensor in crystal coordinates = $strainTensorCryCoord"

## Apply the strain
Physics region=Channel CrystalStrain strain=$strainTensorCryCoord

## Define scattering models
#if [string compare @Scattering@ Ballistic]==0
 puts "Scattering: Ballistic simulation"
 ## Remove all default scattering models
 Physics material=all ScatteringModel removeAll
 set Scattering @Scattering@
 set scatteringEvent @Scattering@
#else
 ## Remove all default scattering models
 Physics material=all ScatteringModel removeAll 
 ###-------------------------------------------
 # Possible scattering options are:
 # PH: phonon scattering
 # SR: surface roughness scattering
 # CO: Coulomb scattering
 # Combinations are also possible as, e.g., CO+PH+SR
 set scatteringModels [split @Scattering@ +]
 foreach scatteringEvent $scatteringModels {
    source physics_scatt.tcl
    set Scattering $scatteringEvent	
 }
 ###-------------------------------------------
#endif

## Use Neumann BC at source and drain
Physics contact=source type=Neumann resist=@Rc@
Physics contact=drain  type=Neumann resist=@Rc@

## Set workfunction
Physics contact=gate workfunction=@WF@

set Vgate @VGATE@
set Vdrain @VDRAIN@

## Classical Solve in equilibrium
Solve V(gate)=0.0 logFile=n@node@_negf.plt
set tdrModels [list VacuumPotential eDensity hDensity DopingConcentration \
		   ConductionBandEnergy ValenceBandEnergy]
#if _DebugTDR_
 Save tdrFile=n@node@_epm0.tdr models=$tdrModels
#endif

## Define regions where quantum transport equations are solved
set schrodingerRegions [list Channel] ; #Include GateOxide, SPd and SPs to the list for wave-function penetration

## Create a nonlocal over the device regions of interest.
Math nonlocal name=channel1 regions=$schrodingerRegions

## Set number of modes for NEGF
set Nmodes @Nmodes@

## Set number of Newton iterations
if {[string compare @DiscreteDopant@ 1]==0} {
    set iterations 50
} else {
    set iterations 30
}

## NEGF math setup
source mathNEGF.tcl

## Enable self-heating
set selfHeating @SelfHeating@
Math selfHeating=$selfHeating
if {[string compare $selfHeating 1]==0} {
    Physics material=semiconductor ThermalConductivity=ConstantThermalConductivity kappa=0.05
    Physics material=insulator ThermalConductivity=ConstantThermalConductivity kappa=0.005

    Physics thermalContact=source contactTemperature=@CT@
    Physics thermalContact=drain  contactTemperature=@CT@
    Physics thermalContact=gate   type=Neumann
}

## Set gate voltage list
set VgList [list ]
for {set absVg 0.0} {$absVg<[expr @<abs(VGATE)>@+0.01]} {set absVg [expr $absVg + 0.1]} {
    if { @VGATE@ >= 0 } {
	lappend VgList [format %.2f $absVg]
    } else {
	lappend VgList [format %.2f [expr -1*$absVg]]
    }
}
if { [expr abs([lindex $VgList end])] < @<abs(VGATE)>@ } {
    lappend VgList @VGATE@
}
puts "Gate Bias List - $VgList"

## Ramp gate and perform IdVg curve simulation
foreach Vg $VgList {
    Solve V(gate)=$Vg V(drain)=$Vdrain V(source)=0.0 logFile=n@node@_IdVg.plt
    
    set tunnelingCurrent [ComputeTunnelingCurrent]
    AddToLogFile name=TunnelingCurrent value=$tunnelingCurrent
    
    #if _DebugTDR_
    	## Save results
    	set pid "n@node@_Vg=${Vg}"
    	set PlotNsubbands [expr $Nmodes-2]
    	source saveTDR_3D.tcl
    	source saveTDR_NEGF.tcl
    #endif
}

## Save results
set pid "n@node@"
set PlotNsubbands [expr $Nmodes-2]
source saveTDR_3D.tcl
source saveTDR_NEGF.tcl


