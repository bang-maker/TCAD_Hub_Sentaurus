#setdep @previous@

#if "@bias@" == "reverse"
#define _vdd_ -1000
#define _res_ 1e7
#define _temp_ 400
#define _Ava_ Avalanche
#else
#define _temp_ 300
#define _vdd_ 10
#define _res_ 1
#define _Ava_ 
#endif

File {
  Grid=      "@tdr@"
  Current=   "@plot@"
  Plot=      "@tdrdat@"
  Output=    "@log@"
}

Electrode {
  { Name = "top"  Voltage = 0 Resist = _res_ }
  { Name = "bottom"  Voltage = 0 }
}

Physics {
  Temperature = _temp_
  Mobility(
    PhuMob 
    HighFieldSaturation(GradQuasiFermi)
  )
  Recombination (SRH _Ava_)
  EffectiveIntrinsicDensity (
    BandGapNarrowing (oldSlotboom)
  )
  Fermi
}

Plot {
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  ElectricField/Vector Potential SpaceCharge
  ImpactIonization eImpactIonization hImpactIonization
}

Math {
  
  Transient = BE
  eMobilityAveraging = ElementEdge
  hMobilityAveraging = ElementEdge
  
  ElementVolumeAvalanche
  AvalFlatElementExclusion = 1.
  
  ParallelToInterfaceInBoundaryLayer(FullLayer -ExternalBoundary)
  ComputeGradQuasiFermiAtContacts= UseQuasiFermi
  
  WeightedVoronoiBox
  
  AutoCNPMinStepFactor = 0
  AutoNPMinStepFactor = 0
  -PlotLoadable
  SimStats   
  
  ExitOnFailure
  
  Digits = 5
  ErrRef(electron) = 1e8
  ErrRef(hole) = 1e8
  
  Iterations = 10
  NotDamped = 100
  RHSMin = 1e-8
  EquilibriumSolution(Iterations=100)
  
  Extrapolate
  
  RefDens_eGradQuasiFermi_ElectricField_HFS = 1e8
  RefDens_hGradQuasiFermi_ElectricField_HFS = 1e8
  *    RefDens_eGradQuasiFermi_EparallelToInterface_HFS= 1e8
  *    RefDens_hGradQuasiFermi_EparallelToInterface_HFS= 1e8
  
  Method = ParDiSo
  
  NumberOfThreads = 4
  ParallelLicense (Wait)
  Wallclock
}

Solve {
  Coupled (Iterations = 100 LineSearchDamping = 1e-4){ Poisson } 
  Coupled (Iterations = 100){ Poisson Electron Hole } 
  
  Quasistationary ( 
    InitialStep = 1e-3 Increment = 1.41
    MinStep = 1e-7     MaxStep = 0.1
    Goal { Name = "top" Voltage = _vdd_ }
  ) { 
  	Coupled { Poisson Electron Hole } 
  }
}
