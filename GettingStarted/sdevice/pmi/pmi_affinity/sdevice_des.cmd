File {
  grid          = "@pwd@/diode.tdr"
  parameter     = "@parameter@"
  PMIPath       = "@pwd@"
  current       = "@plot@"
  plot          = "@tdrdat@"
  output        = "@log@"
}

Electrode {
  { Name="cathode"  voltage=0 }
  { Name="anode"    voltage=0 }
}

Thermode {
  { Name="cathode"  Temperature=300 }
  { Name="anode"    Temperature=300 }
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
  BandGap BandGapNarrowing EffectiveIntrinsicDensity
  ElectronAffinity ConductionBandEnergy ValenceBandEnergy
  Avalanche eAvalanche hAvalanche
  eMobility hMobility
}

CurrentPlot {
  Affinity ( (0.05 0.001) )
}

Physics {
  Temperature= 300
  Recombination (
    SRH(DopingDep) Auger Avalanche
  )
  RecGenHeat
  #if "@Affinity@" == "pmi"
  Affinity (pmi_affinity)
  #else      
  Affinity (Default)
  #endif
  Mobility (DopingDep Enormal HighFieldSaturation)
  Thermodynamic
}

Math {
  Extrapolate
  AvalDerivatives
  Digits=5
  ErrRef(electron)=1e8
  ErrRef(hole)    =1e8
  Iterations=10
  
  ParameterInheritance = None
}

Solve {
  NewCurrentPrefix = "ignore_"
  coupled { poisson electron hole }
  
  NewCurrentPrefix = ""
  QuasiStationary (
    DoZero
    InitialStep=0.04 MaxStep=0.04 MinStep=0.001
    Goal { Name="cathode" Temperature= 600 }
  ) {
    coupled { poisson electron hole temperature }
  }
}
