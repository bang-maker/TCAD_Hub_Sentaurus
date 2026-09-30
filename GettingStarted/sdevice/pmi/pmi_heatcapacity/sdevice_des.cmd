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
  { Name="right"  voltage=0 }
}

Thermode {
  { name = "left"   temperature=300 }
  { name = "right"  temperature=300 }
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
  Temperature eTemperature hTemperature LatticeTemperature
  TotalHeat eJouleHeat hJouleHeat RecombinationHeat ThomsonHeat
  LatticeHeatCapacity
}

Physics {
  Recombination (
    SRH(DopingDep) Auger
  )
  Mobility (DopingDep CarrierCarrierScattering)
  Thermodynamic
  HeatCapacity(
    @HCmodel@
  )
}

Math {
  Extrapolate
  Digits=5
  Iterations=10
  
  Transient=BE
}

Solve {
  Poisson
  Coupled { Poisson Electron Hole Temperature }
  Transient (
    InitialTime = 0  FinalTime = 1e-3
    InitialStep = 1e-4  MaxStep = 1e-4
    Goal { Name="right"  voltage=2 }    
  ) {  Coupled { Poisson Electron Hole Temperature } }
}
