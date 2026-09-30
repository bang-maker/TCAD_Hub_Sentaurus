##------------------------------------------------------------------------------
##  The example demonstrates the 2D GaN diode simulation under the forward
##  bias conditions. 
##  All relevant to III-N material physics is counted, including the
##  piezoelectric polarization, material anisotropy, thermionic emission at 
##  heterointerfaces,  interface charge trapping, incomplete dopant ionization,
##  and radiative recombination.
##  The simulation is performed in slow transient. 
##------------------------------------------------------------------------------

File {
  Grid      = "@tdr@"
  Parameters= "@parameter@"
  
  Plot      = "@tdrdat@"
  Current   = "@plot@"
  Output    = "@log@"
}

Electrode {
  { Name= "anode"   Voltage= 0. }
  { Name= "cathode" Voltage= 0. }
}

Physics {
  Temperature=  300.00
  Fermi
  Piezoelectric_Polarization(strain)
  DefaultParametersFromFile
  EffectiveIntrinsicDensity(NoBandgapNarrowing)
  Recombination (
    SRH (
    )
    Auger()
    Radiative
  )
  Mobility (
    DopingDependence(Masetti)
    HighFieldSaturation(
      CaugheyThomas
    )
    Enormal(
      Lombardi
    )
  )
  IncompleteIonization
  Aniso (
    Poisson
    direction(SimulationSystem)= (1 0 0)
  )
}

Physics (MaterialInterface= "GaN/Nitride") {
  Traps (
    (
      Donor 
      Conc=3e13 
      Level 
      FromMidBandGap 
      EnergyMid=0.36 
      eXsection=1e-30 
      hXsection=1e-14 
    )
  )
}

Plot {
  Potential eQuasiFermi hQuasiFermi
  eDensity hDensity SpaceCharge
  Current eCurrent hCurrent CurrentPotential
  ElectricField SemiconductorElectricField InsulatorElectricField
  eMobility hMobility
  eVelocity hVelocity
  Doping DonorConcentration AcceptorConcentration
  PE_Polarization/vector
  PE_Charge PiezoCharge
  ConductionBandEnergy ValenceBandEnergy
  ElectronAffinity
  BandGap EffectiveBandGap BandGapNarrowing
  QCEffectiveBandGap
  xMolefraction yMolefraction
}

Math {
  NumberOfThreads= 4
  ParallelLicense (Wait)
  Wallclock
  Digits= 5
  ErrRef(electron)= 1.000e+04
  ErrRef(hole)= 1.000e+04
  RHSMin= 1e-3
  CheckRhsAfterUpdate
  Transient= BE
  ExtendedPrecision(80)
  TensorGridAniso(aniso)
  Cylindrical(yAxis= 0)
  ComputeDopingConcentration
  Method= Blocked
  SubMethod= ILS(set=22 )
  ILSrc= "set(22) {
    iterative (gmres(100), tolrel=1e-10, tolunprec=1e-4, maxit=200);
    preconditioning (ilut(1e-08,-1),left);
    ordering (symmetric=nd, nonsymmetric=mpsilst); 
    options(verbose=0, refineresidual=10);
  };"
}

Solve {
  Coupled (Iterations= 500 LineSearchDamping= 1e-2) { Poisson }
  Coupled (Iterations= 100) { Poisson Electron Hole }
  
  Transient (
    InitialStep= 1e-4 MinStep= 1e-9 MaxStep= 1e-2
    Increment= 1.4
    Goal{ Name= "anode" Voltage= 10 }
  ) { Coupled { Poisson Electron Hole } }
}
