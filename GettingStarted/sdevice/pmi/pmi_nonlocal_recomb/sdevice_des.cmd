File {
  grid    = "@pwd@/diode.tdr"
  PMIPath = "@pwd@"
  current = "@plot@"
  plot    = "@tdrdat@"
  output  = "@log@"
}

Electrode {
  { name = "left"   voltage = 0 }
  { name = "right"  voltage = 0 }
}

Plot {
  DonorConcentration AcceptorConcentration
  Potential Doping SpaceCharge
  eDensity hDensity
  eCurrent hCurrent
  ElectricField
  eQuasiFermi hQuasiFermi
  ConductionBandEnergy  ValenceBandEnergy
  PMIeNonLocalRecombination  PMIhNonLocalRecombination
}

Currentplot {
  PMIeNonLocalRecombination (Integrate (Material="Silicon"))
  PMIhNonLocalRecombination (Integrate (Material="Silicon"))
}

Physics {
  Mobility (DopingDependence)
  EffectiveIntrinsicDensity (NoBandGapNarrowing)
  Recombination (
    pmi_tunneling_recomb(A = 5e25  B = 50)
  )
}


Math {
  Extrapolate
  Derivatives
  Avalderivatives
  Iterations = 10
  Method = Pardiso
  -ExtendedPrecision
}

Solve {
  NewCurrent = "ignore_"
  Coupled (iterations=100) { Poisson }
  
  NewCurrent = ""
  Quasistationary (
    DoZero
    MaxStep = 0.05
    Goal { Name="left" Voltage=0.5 }
  ) {
    Coupled { poisson electron hole }
  }
}

