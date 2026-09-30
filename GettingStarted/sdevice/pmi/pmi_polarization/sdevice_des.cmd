File {
  Grid      = "@pwd@/slab.tdr"
  PMIPath   = "@pwd@"
  Plot      = "@tdrdat@"
  Current   = "@plot@"
  Output    = "@log@"
}

Electrode {
  { Name = "left"    voltage = 0.0 }
  { Name = "right"   voltage = 1.0 }
}

Plot {
  Doping
  Potential 
  eQuasiFermi hQuasiFermi
  eGradQuasiFermi hGradQuasiFermi
  ElectricField/Vector
  eDensity hDensity
  eCurrent hCurrent ConductionCurrent
  BandGap BandGapNarrowing
  EffectiveIntrinsicDensity
  Spacecharge
  StressXX StressYY StressZZ
  StressYZ StressXZ StressXY
  PE_Polarization/vector
  PE_Charge
}

Physics {
  Recombination (SRH (DopingDependence) Auger)
  Mobility (DopingDep)
  Piezo ( 
    Stress = (100, -2e9, 300, 400, 500, 600)
  )
  EffectiveIntrinsicDensity (piezo)
  
  piezoelectric_polarization (
    pmi_polarization(  
      x0 = 6          # [um]
      c  = 0.5        # [um^(-2)]
      a  = 1e-5       # [C cm^(-2)]
    )
  )
}

Math {
  -ExtendedPrecision
  Notdamped=100
  Iterations=30
}

Solve {
  poisson
  coupled { poisson electron hole }
}
