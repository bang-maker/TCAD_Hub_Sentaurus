File {
  grid          = "@pwd@/slab.tdr"
  current       = "@plot@"
  plot          = "@tdrdat@"
  output        = "@log@"
  parameter     = "@parameter@"
  PMIPath       = "@pwd@"
}

Electrode {
  { Name="left"   voltage=0 }
  { Name="right"  voltage=0.1 }
}


Plot {
  BandGap BandGapNarrowing EffectiveIntrinsicDensity
  eCurrent/Vector hCurrent/Vector
  Doping SpaceCharge eDensity hDensity
  ElectricField/Vector 
  eQuasiFermi hQuasiFermi
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  SRH Auger
  eMobility hMobility
  eTemperatureRelaxationTime hTemperatureRelaxationTime
  eTemperatureRelaxationTimePerTemperature hTemperatureRelaxationTimePerTemperature
}

Physics {
  Recombination (
    SRH (DopingDep) 
    Auger
    Avalanche (Okuto GradQuasiFermi)
  )
  Hydro
  Mobility (
    DopingDep
    HighFieldSaturation (CarrierTempDrive)
    Enormal
  )
  EnergyRelaxationTime (
    @ERTmodel@
  )
}

Math {
  Extrapolate
  Digits=5
  Iterations=10
  
  eMobilityAveraging = Element
  hMobilityAveraging = Element
}

Solve {
  Poisson
  Coupled { Poisson Electron Hole }
  Coupled { Poisson Electron Hole eTemperature hTemperature }
  
  QuasiStationary (
    InitialStep=0.04 MaxStep=0.04 MinStep=0.001
    Goal { Name="right"  voltage=10 }
  ) { Coupled { Poisson Electron Hole eTemperature hTemperature } }
}
