File {
  grid          = "@pwd@/slab.tdr"
  parameter     = "@parameter@"
  PMIPath       = "@pwd@"
  current       = "@plot@"
  plot          = "@tdrdat@"
  output        = "@log@"
}

Electrode {
  { name = "left"   voltage=0.0 }
  { name = "right"  voltage=0.1 }
}

Thermode {
  { name = "left"   temperature=300 }
  { name = "right"  temperature=300 }
}

Plot {
  eCurrent/Vector hCurrent/Vector
  eDensity hDensity
  ElectricField
  eQuasiFermi hQuasiFermi
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel
  SpaceCharge
  SRH
  Auger
  BandGap
  eMobility hMobility
  Temperature eTemperature hTemperature LatticeTemperature
  TotalHeat eJouleHeat hJouleHeat RecombinationHeat ThomsonHeat
  ThermalConductivity
}

Physics {
  Recombination(
    SRH(DopingDep) Auger
  )
  Mobility(DopingDep CarrierCarrier)
  Thermodynamic
  ThermalConductivity(
    #if [string match "pmi*" "@TCmodel@"]
    @TCmodel@
    #else
    TempDep Resistivity
    #endif
  )
}

Math {
  -ExtendedPrecision
  Extrapolate
  Derivatives
  AvalDerivatives
  RelErrControl  # is default now
  Digits=5
  ErrRef(electron)=1e8
  ErrRef(hole)    =1e8
  Iterations=10
  # DebugDerivPrint
}

Solve {
  QuasiStationary (
    InitialStep=0.05 MaxStep=0.1 MinStep=0.001
    Goal {name = "right"  voltage=200}
  ) {
    coupled { poisson electron hole temperature }
  }
}
