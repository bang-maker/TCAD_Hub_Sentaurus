#setdep @previous@

File {
  Grid            = "@tdr@"
  Parameter       = "@parameter@"
  #if [string match -nocase "*@StrainFrom@*" "File_Stress"]
  Piezo           = "@tdr@"
  #endif
  PMIUserFields   = "@tdr@"
  Current         = "@plot@"
  Plot            = "@tdrdat@"
  Output          = "@log@"
}

Plot { 
  ElectricField/Vector 
  eCurrent/Vector hCurrent/Vector
  DopingConcentration DonorConcentration AcceptorConcentration
  TotalTrapConcentration eTrappedCharge hTrappedCharge
  eDensity hDensity SpaceCharge
  Potential ConductionBandEnergy ValenceBandEnergy
  PE_Polarization/Vector PE_Charge PiezoCharge
  xMoleFraction
  nSiliconPlusConcentration pSiliconMinusConcentration
  MagnesiumActiveConcentration MagnesiumMinusConcentration
  eBarrierTunneling hBarrierTunneling
  PMIUserField0 PMIUserField1
  StressXX StressXY StressXZ StressYY StressYZ StressZZ
}

Electrode {
  { name= "source" voltage=0.0 Workfunction= 4.3 Schottky}
  { name= "drain"  voltage=0.0 Workfunction= 4.3 Schottky}
  { name= "gate"   voltage=0.0 Workfunction= 5.8 Schottky}
}

Physics { 
  DefaultParametersFromFile 
  AreaFactor=1.0 
  Temperature= @Tl@ 
  Fermi 
  Thermionic
  
  Mobility (
    DopingDependence
    HighFieldSaturation(GradQuasiFermi)
  )
  
  #if [string match -nocase @complete@ yes]
  IncompleteIonization
  #endif
  
  Recombination (
    SRH 
    Radiative
  )
  #if [string match -nocase @aniso@ yes]
  Aniso (
    Poisson
    direction(SimulationSystem)= xAxis
  )
  #endif
  EffectiveIntrinsicDensity ( NoBandGapNarrowing )
  #if [string match -nocase @StrainFrom@ Model]
  Piezoelectric_Polarization(strain)
  #elif [string match -nocase @StrainFrom@ File]
  Piezo( Strain= LoadFromFile )
  Piezoelectric_Polarization(strain)
  #elif [string match -nocase @StrainFrom@ Stress]
  Piezoelectric_Polarization(stress)
  #endif
  eBarrierTunneling "sourceNLM"
  eBarrierTunneling "drainNLM"
  hBarrierTunneling "gateNLM"
}

Physics (RegionInterface= "pgate/passivation_left") {
  Piezoelectric_Polarization(Activation=1.0)
  Traps (( Donor Level fromCondBand EnergyMid= 0.4 
    Conc= 3e13 eXsection=1e-14  hXsection=1e-14 )
  )
}

Physics (RegionInterface= "pgate/passivation_right") {
  Piezoelectric_Polarization(Activation=1.0)
  Traps (( Donor Level fromCondBand EnergyMid= 0.4 
    Conc= 3e13 eXsection=1e-14 hXsection=1e-14 )
  )
}

Physics (RegionInterface= "alganbarrier/passivation_left") {
  Traps (( Donor Level fromCondBand EnergyMid= 0.4 
    Conc= 3e13 eXsection=1e-14 hXsection=1e-14)
  )
}

Physics (RegionInterface= "alganbarrier/passivation_right") {
  Traps (( Donor Level fromCondBand EnergyMid= 0.4 
    Conc= 3e13 eXsection=1e-14 hXsection=1e-14)
  )
}

Physics (RegionInterface= "buffer/channel") {
  Traps (( Donor Level fromMidBandGap EnergyMid= 0 
    Conc= 2e11 eXsection=1e-14 hXsection=1e-14)
  )
}

Physics (RegionInterface= "relax2/buffer") {
  Traps (( Donor Level fromMidBandGap EnergyMid= 0 
    Conc= 2e13 eXsection=1e-14 hXsection=1e-14)
  )
}

Physics (RegionInterface= "relax1/relax2") {
  Traps (( Donor Level fromMidBandGap EnergyMid= 0 
    Conc= 3e13 eXsection=1e-14 hXsection=1e-14 )
  )
}

Physics (RegionInterface= "nucleation/relax1") {
  Piezoelectric_Polarization(Activation=0.2)
}

Physics (RegionInterface= "nucleation/wafer") {
  Traps (( Region= "wafer" Acceptor Level fromMidBandGap EnergyMid= 0 
    Conc= 5e13  eXsection=1e-14 hXsection=1e-14)
  )
  Piezoelectric_Polarization(Activation=0.2)
}

Physics (Region= "buffer") {
  Traps (( Acceptor SFactor= "PMIUserField0" Level fromValBand  EnergyMid= 0.3 
    Conc= 0 eXsection=1e-14  hXsection=1e-14 )
    ( Donor    SFactor= "PMIUserField1" Level fromCondBand EnergyMid= 0.2 
    Conc= 0 eXsection=1e-14  hXsection=1e-14 ) 
  )
}

Physics (Region= "relax2") {
  Traps (( Acceptor SFactor= "PMIUserField0" Level fromValBand  EnergyMid= 0.3 
    Conc= 0 eXsection=1e-14  hXsection=1e-14 )
    ( Donor    SFactor= "PMIUserField1" Level fromCondBand EnergyMid= 0.2 
    Conc= 0 eXsection=1e-14  hXsection=1e-14 ) 
  )
}

Physics (Region= "relax1") {
  Traps (( Acceptor SFactor= "PMIUserField0" Level fromValBand  EnergyMid= 0.3 
    Conc= 0 eXsection=1e-14  hXsection=1e-14 )
    ( Donor    SFactor= "PMIUserField1" Level fromCondBand EnergyMid= 0.2 
    Conc= 0 eXsection=1e-14  hXsection=1e-14 )
  )
}

Physics (Region= "nucleation") {
  Traps (( Acceptor SFactor= "PMIUserField0" Level fromValBand  EnergyMid= 0.3 
    Conc= 0 eXsection=1e-14  hXsection=1e-14 )
    ( Donor    SFactor= "PMIUserField1" Level fromCondBand EnergyMid= 0.2 
    Conc= 0 eXsection=1e-14  hXsection=1e-14 )
  )
}

Physics (Region= "wafer") {
  Recombination (-Radiative)
}

Math {
  ExtendedPrecision
  #if [string match -nocase @aniso@ yes]
  TensorGridAniso(Aniso)
  #endif
  Method= Blocked
  SubMethod = ILS(set=27)
  ILSrc="
  set(26){
    iterative(gmres(100), tolrel=1e-16, tolunprec=1e-8, tolabs=0, maxit=200);
    preconditioning(ilut(1.0e-15,-1),left);
    ordering ( symmetric=nd, nonsymmetric=mpsilst );
    options( compact=yes, linscale=0, refineresidual=60, verbose=0); 
  };
  set(27){  
    iterative(gmres(100), tolrel=1e-10, tolunprec=1e-4, tolabs=0, maxit=200);
    preconditioning(ilut(1.0e-9,-1), right);
    ordering(symmetric=nd, nonsymmetric=mpsilst);
    options(compact=yes, linscale=0, refineresidual=10, verbose=0);
  };
  "
  Number_of_Threads= 4
  Digits=5
  Iterations=20
  Notdamped=30
  Transient= BE
  Traps(Damping=0)
  DirectCurrent
  ErrRef(electron) = 1e8
  ErrRef(hole)   = 1e8
  CDensityMin= 0
  RefDens_eGradQuasiFermi_ElectricField= 1e8
  RefDens_hGradQuasiFermi_ElectricField= 1e8
  NonLocal "gateNLM" (
    electrode="gate"   Length= 20e-7  Digits= 4 EnergyResolution= 1e-3 
  )
  NonLocal "sourceNLM"(
    electrode="source" Length= 30e-7  Digits= 4 EnergyResolution= 1e-3 
    Direction=(0 1 0) MaxAngle=1 -EndPoint(Material="AlGaN")
  )
  NonLocal "drainNLM" (
    electrode="drain"  Length= 30e-7  Digits= 4 EnergyResolution= 1e-3 
    Direction=(0 1 0) MaxAngle=1 -EndPoint(Material="AlGaN")
  )
}

Solve {
  #----- solution at initial conditions
  Coupled(Iterations=100 LineSearchDamping=1e-4){ Poisson }
  Coupled(Iterations=100) { Poisson Electron Hole }
  Plot(FilePrefix="n@node@_zero")
  #----- drain ramp
  Transient (
    InitialStep=0.01 MinStep=1.0e-4 maxstep=0.1
    goal { name= drain voltage=@Vds@ }
  ) { coupled { Poisson Electron Hole } }
  #----- gate ramp
  NewCurrentPrefix= "n@node@_IdVg_"
  Transient (   
    InitialStep=0.01 MinStep=1.0e-5 maxstep=0.05
    goal { name= gate voltage=@Vgs@ }
  ) { coupled { Poisson Electron Hole } 
  	  CurrentPlot( time= ( range = (1.0 2.0) intervals = 20 ))
    }
}
