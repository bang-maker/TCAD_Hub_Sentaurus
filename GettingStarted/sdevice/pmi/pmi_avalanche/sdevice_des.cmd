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
  { name = "right"  voltage=0.0 Resist= 1e3 }
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
  Avalanche eAvalanche hAvalanche
  eMobility hMobility
}

Physics {
  DefaultParametersFromFile
  Temperature= 300
  Recombination (
    SRH(DopingDep) 
    Auger
    Avalanche (
      # both Okuto and pmi_Okuto should produce the same results
      #if [string match -nocase pmi @Okuto@]
      pmi_Okuto
      #elif [string match -nocase pmi_std @Okuto@]
      pmi_Okuto_std
      #else
      Okuto
      #endif
      GradQuasiFermi 
    )
  )
  Mobility (DopingDep CarrierCarrierScattering)
}

Math {
  Extrapolate
  AvalDerivatives
  Digits=5
  ErrRef(electron)=1e8
  ErrRef(hole)    =1e8
  Iterations=10       
  BreakCriteria {
    Current (Contact = "right" maxval = 0.01)
  }
}

Solve {
  QuasiStationary (
    DoZero
    InitialStep=0.01 MaxStep=0.1 MinStep=1e-9
    Goal {name = "right"  voltage=100}
  )  {
    coupled { poisson electron hole }
    CurrentPlot (Time= (range=(0.001 1)))
  }
}
