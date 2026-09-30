#setdep @node|GenerateStructure@

# Ramp gate bias and compute mobility
#   - VgStart is start value for ramp
#   - VgEnd is the end value for ramp
#   - NumSteps is the number of equally space bias points that will be used during ramp

# Set the number of threads
#seth Threads 8
sBandSet nThreads=@Threads@;

# Boltzmann constant in eV/K
set kb 8.617343e-5;

# set useful variables
set gateType @gateType@
set deviceType @deviceType@
if { [string compare $gateType single]==0 } {
  set isSG 1
  set gateFactor 1.0
} elseif { [string compare $gateType double]==0 } {
  set isSG 0
  set gateFactor 0.5
} else {
  puts "Invalid gateType"
  exit -1
}

# Load Device Structure
LoadDevice tdrFile=@[relpath n@node|GenerateStructure@_fps.tdr]@

# Set temperature
set T 300.0;
Physics temperature=$T

# Set dynamic subband energy cutoff
set energyCutoff [expr 10.0*$kb*$T];

# Set Gate workfunction
#if [string compare @CarrierType@ nmos]==0
set workfu 4.1
set startVg @VgStart@
set sign 1;
#else
set workfu 5.1
set startVg -@VgStart@
set sign -1;
#endif

if {$isSG==0} {
  Physics contact=top    workfunction=$workfu
  Physics contact=bottom workfunction=$workfu
} else {
  Physics contact=top    workfunction=$workfu
}

# Initial solve - Poisson only
if { $isSG==1 } {
  Solve V(top)=$startVg initial logFile=n@node@_epm.plt
} else {
  Solve V(top)=$startVg V(bottom)=$startVg initial logFile=n@node@_epm.plt
}


# Create nonlocal line for Schrodinger
Math nonlocal name=NL1 minZ=0.0 maxZ=@Qbox@

#if [string compare @CarrierType@ nmos]==0

  # Specify Schrodinger solver on NL
  set Nsubbands 32
  Physics nonlocal=NL1 eSchrodinger=Parabolic \
          valleys=[list Delta1 Delta2 Delta3] \
          Nphi=16 Nk=32 Kmax=0.3 Nsubbands=$Nsubbands \
          useDynamicSubbands=1 dynamicSubbandEnergyCutoff=$energyCutoff \
          a0=5.43e-8 correction=3;

  # Create mobility calculator
  Physics nonlocal=NL1 eMobilityCalculator=KGFromK Nphi=32 Nk=128

#else
  # Specify Schrodinger solver on NL
  # Specify kgrid for Schro solve
  set kGrid [list 0.00E+00 8.35E-03 1.67E-02 2.50E-02 \
                  3.33E-02 5.00E-02 6.67E-02 8.33E-02 0.1 \
                  0.116666667 0.133333333 0.15 0.2 0.25 0.3];
  puts "kGrid = $kGrid";

  set Nsubbands 32
  Physics nonlocal=NL1 hSchrodinger=6kp \
          valleys=[list Gamma] \
          Nphi=48 kGrid=$kGrid Nsubbands=$Nsubbands \
          iwSymmetry=AUTO useKdependentWF=1 \
          useDynamicSubbands=1 dynamicSubbandEnergyCutoff=$energyCutoff \
          a0=5.43e-8;

  # Create mobility calculator
  Physics nonlocal=NL1 hMobilityCalculator=KGFromK Nphi=48 Nk=64

#endif

# Print physics
Physics print
ListMaterialMap
PrintParameters deviceRegion=si1 filename=n@node@_region_si1_mat.txt
PrintParameters dbMaterial=Silicon filename=n@node@_dbmat_Silicon_mat.txt

# Re-solve with Schrodinger
Solve

# Generate list of bias values
set step [expr (@VgEnd@ - @VgStart@)/(@NumSteps@ - 1.)]
set rampList [list]
for {set i 0} {$i < @NumSteps@} {incr i} {
  set x [expr $sign*(@VgStart@ + $i*$step)]
  lappend rampList $x
}
puts [format "Vg Ramp List: %s" $rampList];

# Loop over bias values
foreach rampValue $rampList {

  puts ""
  puts "*** rampValue = $rampValue ***"
  puts ""

  # Solve at target gate bias
  if { $isSG==1 } {
    Solve V(top)=$rampValue
  } else {
    Solve V(top)=$rampValue V(bottom)=$rampValue
  }

  # Output subband numbers
  set totalNsubbands 0
  set ladderList [Physics getSubbandNumbers];
  foreach ladder $ladderList {
    set ladderName [lindex $ladder 0];
    set Nsubbands [lindex $ladder 1];
    puts [format "Ladder %s Nsubbands= %d" $ladderName $Nsubbands];
  };

  # Compute Eeff and add to log file
  #if [string compare @CarrierType@ nmos]==0
    set Eeff [Extract model=eEeffIntegrand region=si1 integral];
  #else
    set Eeff [Extract model=hEeffIntegrand region=si1 integral]
  #endif
  puts "Eeff=$Eeff"
  AddToLogFile name=Eeff value=$Eeff

  # Resolve and compute mobility
  set mobXX [ComputeMobility xx]

}; # end loop over bias ramp

# Models to save
set saveModels [concat DopingConcentration VacuumPotential \
                       ConductionBandEnergy ValenceBandEnergy \
                       eDensity hDensity];

# Add spatial mobility profile
#if [string compare @CarrierType@ nmos]==0
  lappend saveModels eMobility;
#else
  lappend saveModels hMobility;
#endif

# Subband models to save
set subbandModels [list]
foreach ladder [Physics getSubbandNumbers] {
  set ladderName [lindex $ladder 0];
  set Nsubbands [lindex $ladder 1];
  for {set i 0} {$i < $Nsubbands} {incr i} {
    lappend saveModels ${ladderName}_${i}_SubbandEnergy
    lappend saveModels ${ladderName}_${i}_SubbandDensity
    lappend saveModels ${ladderName}_${i}_Wavefunction
  };
};

# Save z-space structure as TDR
Save tdrFile=n@node@_epmZ.tdr models=$saveModels

# Subband k-space models to save
set saveKModels [list]
foreach ladder [Physics getSubbandNumbers] {
  set ladderName [lindex $ladder 0];
  set Nsubbands [lindex $ladder 1];
  for {set i 0} {$i < $Nsubbands} {incr i} {
    lappend saveKModels ${ladderName}_${i}_Dispersion
    lappend saveKModels ${ladderName}_${i}_IMRT
    lappend saveKModels ${ladderName}_${i}_ScatteringRate
  };
};

# Save k-space TDR
SaveK tdrFile=n@node@_epmK.tdr models=$saveKModels Kmax=0.3 Nk=101






