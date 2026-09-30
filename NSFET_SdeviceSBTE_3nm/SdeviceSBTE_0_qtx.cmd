###-----------------------------###
###--- subband-BTE Nano-slab ---###
###-----------------------------###

#define _DebugTDR_ 0

sBandSet nThreads=@Threads@

# Set sign of applied biases
#if [string match @Type@ nMOS]
 set sign 1
 set valleys [list Delta1 Delta2 Delta3]
#else
 set sign -1
 set valleys [list Gamma]
#endif

###--- Material definition in TDR ---###
Material  name=Silicon           type=semiconductor
##Material  name=SiliconGermanium  type=semiconductor
Material  name=Oxide             type=insulator
Material  name=HfO2              type=insulator
Material  name=LowK              type=insulator
Material  name=TiNitride         type=semiconductor
###----------------------------------###

# Load TDR
LoadDevice tdrFile=n@node|genStackedNanoslab@_fps.tdr ignoreDopants=1

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

#elif [string compare @Scattering@ "PH"]==0
 # PH+SR scattering models
source physics_scatt_phonon.tcl

#elif [string compare @Scattering@ "PH+SR"]==0
 # PH+SR scattering models
source physics_scatt.tcl

#elif [string compare @Scattering@ "PH+SR+CO"]==0
 # PH+SR+CO scattering models
source physics_scatt.tcl

puts "Using CO scattering"
Physics material=Silicon ScatteringModel=Coulomb name=ElectronCO \
        transitionType=Intravalley valleys=[list Delta1 Delta2 Delta3] \
        screening=Lindhard whenToCompute=FirstIteration

puts "Using CO scattering"
Physics material=Silicon ScatteringModel=Coulomb name=HoleCO \
        transitionType=Intravalley valleys=[list Gamma] \
        screening=Lindhard whenToCompute=FirstIteration

#endif

# Use Neumann BC on source and drain
Physics contact=source type=Neumann
Physics contact=drain  type=Neumann

Physics print

# Create Sliced channel over th channel active region
##set slicedChannelRegions [list ChFin_0]

set L        @L@              ;# Channel length
set Lsbte     @<2*Lnl_sde+L>@                ;# SBTE simulation Length
set dz        @zSpacing@
set nSlices   [expr (1+int($Lsbte/$dz))]
set Zc        0.0
set Zmin      [expr ($Zc - 0.5*$Lsbte)]
set Zmax      [expr ($Zc + 0.5*$Lsbte)]

puts " number of slices from discretization $nSlices"

set sliceCoordList {}
for {set i 0} {$i<$nSlices} {incr i} {
     set zSlice [format "%.4f" [expr ($Zmin + $dz*$i)]]
     lappend sliceCoordList $zSlice
}
puts "sliceCoordList $sliceCoordList"

# Create Sliced channel over th channel active region
Math slicedChannel name=$slicedChannelName regions=$slicedChannelRegions sliceCoords=$sliceCoordList \
     minZ=$Zmin maxZ=$Zmax

# Set number of subbands
set Nsubbands  @Nsubbands@
set ScattRange @ScattRange@

# BTE math setup
##source math.tcl
if { $sign == 1 } {
# n-type 

#- set valleys [list Delta1 Delta2 Delta3] 
 # Setup Parabolic Schro on the sliced channel
 Physics slicedChannel=$slicedChannelName eSchrodinger=Parabolic valleys=$valleys \
         Nsubbands=$Nsubbands Nk=16 Kmax=0.6 a0=5.43e-8 correction=3
         
 # Select BTE solver and set some energy grid paramters; tau=1.0e-10
 Physics slicedChannel=$slicedChannelName eBTESolver=Numeric deltaE=4.0e-3 resolveTOBEnergy=1 \
         minDeltaE=1.0e-4 tau=1.0e-10 subbandScatteringRange=$ScattRange \
         whenToComputeScreening=FirstIteration tdfDegenTol=1.0e-4  
} else {
# p-type 

#- set valleys [list Gamma]
 # Setup 6kp Schro
 set kGrid [list 0.00E+00 8.35E-03 1.67E-02 2.50E-02 3.33E-02 5.00E-02 \
                 6.67E-02 8.33E-02 0.1 0.116666667 0.133333333 0.15 0.2 \
                 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8]
 Physics slicedChannel=$slicedChannelName hSchrodinger=6kp valleys=$valleys \
         Nsubbands=$Nsubbands kGrid=$kGrid a0=5.43e-8 useKdependentWF=1 \
         degenSubbandEnergySplit=1.0e-6

 # Select BTE solver and set some energy grid paramters; default tau=1.0e-10
 Physics slicedChannel=$slicedChannelName hBTESolver=Numeric deltaE=4.0e-3 resolveTOBEnergy=1 \
         minDeltaE=1.0e-4 tau=1.0e-10 subbandScatteringRange=$ScattRange \
         whenToComputeScreening=FirstIteration tdfDegenTol=1.0e-4 
}

source save_output.tcl


