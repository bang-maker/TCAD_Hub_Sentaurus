##------------------------------------------------------------------------------
##  The example demonstrates the 2D GaN diode simulation under the reverse
##  bias conditions up to breakdown. 
##  All relevant to III-N material physics is counted, including the
##  piezoelectric polarization, material anisotropy, thermionic emission at 
##  heterointerfaces,  interface charge trapping, incomplete dopant ionization,
##  and radiative recombination.
##  The simulation is performed in slow transient. 
##------------------------------------------------------------------------------

File {
  * input files
  Grid      = "@tdr@"
  Parameters= "@parameter@"
  
  * output files
  Plot      = "@tdrdat@"
  Current   = "@plot@"
  Output    = "@log@"
}

Electrode {
  { Name= "anode"   Voltage= 0 Resist=1e7 }
  { Name= "cathode" Voltage= 0}
}

Physics {
  
  Temperature=  300.00
  Fermi
  Piezoelectric_Polarization(strain) * strain-based piezo model
  DefaultParametersFromFile
  EffectiveIntrinsicDensity(NoBandgapNarrowing)
  
  * bulk generation/recombination
  Recombination (
    SRH 
    Auger
    Radiative
    * Avalanche generation model activation with driving force specification
    Avalanche(vanOverstraeten)
  )
  
  * Carrier mobility
  Mobility (
    DopingDependence(Masetti)
    HighFieldSaturation(CaugheyThomas)
    * Transverse field mobility degradation
    Enormal(Lombardi) * Lombardi interface degradation mobility model
  )
  
  IncompleteIonization
  Aniso (
    Poisson * Global aniso permittivity model activation
    direction(SimulationSystem)= (1 0 0)
  )
}


Physics (MaterialInterface= "GaN/Nitride") {
  * Interface trap specification
  Traps (
    (Donor           * trap type
      Conc=3e13       * trap density, 1/cm^2
      Level           * trap energetic distribution
      FromMidBandGap  * reference energy position
      EnergyMid=0.36  * central energy position of energetic distribution
      eXsection=1e-30 * trap cross-section for electrons, cm^2
      hXsection=1e-14 * trap cross-section for holes, cm^2
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
  ImpactIonization eImpactIonization hImpactIonization
  eAlphaAvalanche hAlphaAvalanche
  eIonIntegral hIonIntegral MeanIonIntegral
}

Math {
  #==== Multi-threading controls ====
  NumberOfThreads= 4    * number of threads to be used in parallel
  ParallelLicense(Wait) * parallel license scenario
  Wallclock             * report wallclock times in log
  
  #==== Non-linear solver controls ====
  Digits= 5                   * number of digits used in relative error control
  ErrRef(electron)= 1.000e+04 * reference electron denisty used for relative error control
  ErrRef(hole)= 1.000e+04     * reference hole denisty used for relative error control
  RHSMin= 1.000e-5            * RHS norm convergence criterion
  CheckRhsAfterUpdate
  
  #==== General controls ====
  Transient= BE              * Transient solution method
  Iterations=15              * set max allowed Newton iterations, default is 50.
  ExtendedPrecision(80)      * ExtendedPrecision arithmetics
  TensorGridAniso(aniso)     * Aniso approximation for anisotropic materials and stress-related problematics
  Cylindrical(yAxis= 0)      * Consider 3D rotational symmetry for 2D device geometry
  ComputeDopingConcentration * force net doping recomputation from individual dopants
  
  #==== Linear solver controls ====
  Method= Blocked         * Outer linear solver for Coupled linear system
  SubMethod= ILS(set=22 ) * Inner linear solver for Coupled linear system
  * ILS customizable set
  ILSrc= "set(22) {
    iterative (gmres(100), tolrel=1e-10, tolunprec=1e-4, maxit=200);
    preconditioning (ilut(1e-08,-1),left);
    ordering (symmetric=nd, nonsymmetric=mpsilst); 
    options(verbose=0, refineresidual=10);
  };"
}

Solve {
  Coupled (Iterations=500) { Poisson }
  Coupled (Iterations=100) { Poisson Hole }
  Coupled (Iterations=100) { Poisson Electron Hole }
  
  Transient (
    InitialStep= 1e-10 MinStep= 1e-15 MaxStep= 1e-2
    Increment= 1.4
    Goal{ Name= "anode" Voltage= -1e4 }
    BreakCriteria { Current (Contact = "cathode" absval = 1e-5) }
  ) { Coupled { Poisson Electron Hole } }
}

