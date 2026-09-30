###---------------------------------------------###
###--- subband-BTE Nanowire Application Note ---###
###---------------------------------------------###

#setdep @node|AddContacts@

#define _DebugTDR_ 0

# Set sign of applied biases
#if [string match @Type@ nMOS]
 set sign 1
 set valleys [list Delta1 Delta2 Delta3]
#else
 set sign -1
 set valleys [list Gamma]
#endif

sBandSet nThreads=@Threads@

###--- Material definition in TDR ---###
Material  name=Silicon  type=semiconductor
Material  name=Oxide    type=insulator
Material  name=LowK     type=insulator
###----------------------------------###

# Load TDR
LoadDevice tdrFile=n@node|AddContacts@_fps.tdr

Physics temperature=300.0

# Channel direction
#if [string compare @cDir@ 100]==0
  Physics xDirection=[list 0 0 1] yDirection=[list 0 1 0]
  set channelDir [list 1 0 0]
#elif [string compare @cDir@ 110]==0
  Physics xDirection=[list 0 0 1] yDirection=[list -1 1 0]
  set channelDir [list 1 1 0]
#endif

# band & electrical models
source physics_band.tcl

#if [string compare @Scattering@ Ballistic]==0
 # Ballistic simulation
puts "Scattering: Doing Ballistic simulation"
Physics material=all ScatteringModel removeAll

#elif [string compare @Scattering@ "PH+SR"]==0
 # PH+SR scattering models
source physics_scatt.tcl
#endif

# Use Neumann BC on source and drain
Physics contact=source type=Neumann resist=@Rcont@
Physics contact=drain  type=Neumann resist=@Rcont@

# Set workfunction
Physics contact=gate workfunction=@WF@

# Classical Solve in equilibrium
Solve V(gate)=0.0 logFile=n@node@_bte.plt
set tdrModels [list VacuumPotential eDensity hDensity DopingConcentration \
                    ConductionBandEnergy ValenceBandEnergy]
Save tdrFile=n@node@_epm0.tdr models=$tdrModels

# include oxide region for wave-function penetration
# Create Sliced channel over all device. This also creates a nonlocal on each slices with name channel1.NL
set slicedChannelRegions [list Channel cDrain cSource GateOxide SPd SPs]
Math slicedChannel name=channel1 regions=$slicedChannelRegions

# Set number of subbands
set Nsubbands @Nsubbands@

# BTE math setup
source math.tcl

# Solve at equilibrium 
Solve V(gate)=0.0  V(drain)=0.0

#if _DebugTDR_
### Save zero bias results
set pid "n@node@_zero"
set PlotNsubbands @Nsubbands@
source saveTDR.tcl
set cutX 0.0
source saveTDRcut.tcl
#endif

# Solve at desired drain bias
Solve V(drain)=@VDRAIN@

#if _DebugTDR_
### Save desired drain bias results
set pid "n@node@_Vd"
set PlotNsubbands @Nsubbands@
source saveTDR.tcl
set cutX 0.0
source saveTDRcut.tcl
#endif

#----- Ramp gate voltage list -----#
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
#----------------------------------#

### Ramp gate and perform IdVg curve simulation
foreach Vg $VgList {
  Solve V(gate)=$Vg logFile=n@node@_IdVg.plt
  AddToLogFile name=Id value=[GetLast name=I(drain)]

#if _DebugTDR_
  ### Save results
  set pid "n@node@_Vg=${Vg}"
  set PlotNsubbands 2
  source saveTDR.tcl
  set cutX 0.0
  source saveTDRcut.tcl
#endif  
}


### Save results
set pid "n@node@"
set PlotNsubbands @Nsubbands@
source saveTDR.tcl
set cutX 0.0
source saveTDRcut.tcl



