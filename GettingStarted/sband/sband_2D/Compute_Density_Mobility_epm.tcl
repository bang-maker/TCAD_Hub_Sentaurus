#setdep @node|Slice@

#seth deltaVg 0.1
#seth Stress 0
#seth cDir 110
#seth xDir 110
#seth yDir 100

#if "@Type@" == "nmos"
proc getNinv {} {
    return [Extract model=eDensity nonlocal=NL1 integral]
}
#else
proc getNinv {} {
    return [Extract model=hDensity nonlocal=NL1 integral]
}
#endif

sBandSet nThreads=8
# Set the Boltzmann constant
set Temperature 300.0;
set kb 8.617e-5; # Boltzmann constant in eV/K
set kBT [expr $kb*$Temperature]; # [eV]

# Define the dynamic subband energy cutoff
set subbandEnergyCutoff [expr 10.0*$kBT];

set plotlist [list DopingConcentration eDensity hDensity \
    ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy \
    ConductionBandPotential eQuasiFermiPotential eDensityTimesEField]

set workfu0 @WF@
set lastnsbnd 3

#if "@Type@" == "nmos"
set valleylist [list Delta1 Delta2 Delta3]
set carsign 1
#else 
set valleylist [list Gamma]
set carsign -1
#endif

# Create list of models to save
set modelsToSave $plotlist                       
# Subband models to save
foreach valley $valleylist {
    for {set i 0} {$i < $lastnsbnd} {incr i} {
        
        # Real Space models
        lappend modelsToSave ${valley}_${i}_SubbandEnergy
        lappend modelsToSave ${valley}_${i}_Wavefunction
        lappend modelsToSave ${valley}_${i}_SubbandDensity
        
        # k-space models
        lappend kModelsToSave ${valley}_${i}_IMRT ${valley}_${i}_Dispersion
    }
}

Material name=HfO2 type=insulator

# Load TDR
LoadDevice tdrFile=@[relpath n@node|Slice@_slice_msh.tdr]@

#- Define material parameters
#----------------------------------------------------------------------#
#Define High-K
Physics material=HfO2 Permittivity epsilon=22

# Use default parameters for Si
#if "@Type@" == "nmos"
Physics material=Silicon hBulkDensity=ConstantModel value=0.0
#else
Physics material=Silicon eBulkDensity=ConstantModel value=0.0
#endif

# Set workfunction
Physics contact=gate workfunction=$workfu0

#- Set stress parameters
#----------------------------------------------------------------------#

# Channel direction
#if  "@cDir@" == "100" && "@xDir@" == "100" && "@yDir@" == "100"
Physics xDirection=[list 1 0 0] yDirection=[list 0 1 0]
set channelDir [list 0 0 1]
#elif "@cDir@" == "100" && "@xDir@" == "110" && "@yDir@" == "110"
Physics xDirection=[list 1 1 0] yDirection=[list 1 -1 0]
set channelDir [list 0 0 1]
#elif "@cDir@" == "110" && "@xDir@" == "100" && "@yDir@" == "110"
Physics xDirection=[list 0 0 1] yDirection=[list 1 -1 0]
set channelDir [list 1 1 0]
#elif "@cDir@" == "110" && "@xDir@" == "110" && "@yDir@" == "100"
Physics xDirection=[list 1 1 0] yDirection=[list 0 0 1]
set channelDir [list 1 -1 0]
#else
puts "Orientation is beyond the scope.. Check it out..."
exit
#endif
       
SiliconCrystal name=Silicon
Silicon apply uniaxialStrain dir=$channelDir stress=@Stress@
Physics material=Silicon CrystalStrain strain=[Silicon get strain]

#- Simulation and Save Output
#----------------------------------------------------------------------#
# Output Parameters
Physics print
ListMaterialMap

# Initial, classical solve
Solve V(gate)=0.0 initial logFile=n@node@_initial_epm.plt

Math nonlocal name=NL1 regions=[list Channel]

#if "@Type@" == "nmos"
# Setup Parabolic Schro on the sliced channel
Physics nonlocal=NL1 eSchrodinger=Parabolic valleys=$valleylist \
    useDynamicSubbands=1 Nk=32 Kmax=0.6 a0=5.43e-8 correction=3
   
# Mobility Calculator
Physics nonlocal=NL1 eMobilityCalculator=LinearBTE Nk=1024
#else
set kGrid [list 0.00E+00 8.35E-03 1.67E-02 2.50E-02 3.33E-02 5.00E-02 6.67E-02 8.33E-02 0.1 \
    0.1167 0.1333 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6]
  
Physics nonlocal=NL1 hSchrodinger=6kp valleys=$valleylist \
    useDynamicSubbands=1 dynamicSubbandEnergyCutoff=$subbandEnergyCutoff \
    kGrid=$kGrid a0=5.43e-8 useKdependentWF=1 \
    degenSubbandEnergySplit=1.0e-6  
    
# Mobility Calculator
Physics nonlocal=NL1 hMobilityCalculator=LinearBTE Nk=1024    
#endif

# Set some convergence params. We will continue to next bias if not-converged
Math potentialUpdateTolerance=3.0e-3 doOnFailure=0

Physics print
ListMaterialMap
# Re-solve with Schrodinger
Solve

#if "@Type@" == "nmos"
Physics material=all ScatteringModel=SRFor2D name=ElectronSR \
    transitionType=Intravalley valleys=$valleylist \
    delta=[list {100 0.3e-7} {110 0.3e-7}] lambda=1.5e-7 powerSpectrum=Exponential beta=1.5
Physics material=all ScatteringModel=Coulomb name="eCoulomb" scaleFactor=1.0 \
    transitionType=Intravalley valleys=$valleylist screening=Lindhard \
    whenToCompute=FirstIteration
#else
Physics material=all ScatteringModel=SRFor2D name=HoleSR \
    transitionType=Intravalley valleys=$valleylist \
    delta=[list {100 0.25e-7} {110 0.25e-7}] lambda=4.0e-7 powerSpectrum=Exponential beta=1.5
Physics material=all ScatteringModel=Coulomb name="hCoulomb" scaleFactor=1.0 \
    transitionType=Intravalley valleys=$valleylist screening=Lindhard \
    whenToCompute=FirstIteration
#endif



# Ramp gate
for {set Vg @VgStart@} {$Vg<=[expr @VgEnd@+0.001]} {set Vg [expr $Vg + 0.1]} {
    # Vg for filename
    set Vg_print [format %.2f $Vg]

    Solve V(gate)=[expr $carsign*$Vg]  logFile=n@node@_epm.plt	 
    
    set Ninv_cm [getNinv]    
    puts "Ninv as is = [format "%.3e" $Ninv_cm] cm-1"
    # Compute inversion density per cm2
    set Ninv_cm3 [expr $Ninv_cm/(@W@*1e-4)/(@H@*1e-4)]
    puts "Ninv/vol = [format "%.3e" $Ninv_cm3] cm-3"
    AddToLogFile name=Ninv value=$Ninv_cm3
    AddToLogFile name=MobilityXX value=[ComputeMobility xx]

     set ladderList [Physics getSubbandNumbers];
     foreach ladder $ladderList {
       set name [lindex $ladder 0];
       set num [lindex $ladder 1];
       puts "Ladder $name, Nsubbands=$num"
     }

    foreach valley $ladderList {
	set name [lindex $ladder 0];
	set num [lindex $ladder 1]

        for {set i 0} {$i < $num} {incr i} {
        
        # k-space models
	puts "valley_i = ${name}_${i}" 
        set mass_xx [ComputeMass xx subbands=${name}_${i}]
        set mass_xy [ComputeMass xy subbands=${name}_${i}]
        set mass_yy [ComputeMass yy subbands=${name}_${i}]
	AddToLogFile name=${name}_${i}_mass_x value=$mass_xx
        puts "${valley} : xx = $mass_xx, xy = $mass_xy, yy = $mass_yy"

	}
    }

    # Save TDR file with structure and models
    Save tdrFile=n@node@_Vg_${Vg_print}_epm.tdr models=$modelsToSave
    # Save TDR file with dispersion in 1D k-space
    SaveK tdrFile=n@node@_Vg_${Vg_print}_epmK.tdr models=$kModelsToSave
    
}
