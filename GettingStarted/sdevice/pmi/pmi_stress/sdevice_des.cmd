File {
  Grid      = "@pwd@/diode.tdr"
  PMIPath   = "@pwd@"
  Current   = "@plot@"
  Plot      = "@tdrdat@"
  Output    = "@log@"
}

Electrode {
  { Name = "Top"      voltage =  0.0 }
  { Name = "Bottom"   voltage = -2.0 }
}

Plot {
  StressXX StressYY StressZZ
  StressYZ StressXZ StressXY
  Doping
  Potential
  ElectricField/Vector
  eDensity hDensity
  eCurrent hCurrent ConductionCurrent
  BandGap BandGapNarrowing
  EffectiveIntrinsicDensity
  Spacecharge
}

CurrentPlot {
  StressXX(Average(Semiconductor))
  StressYY(Average(Semiconductor))
  StressZZ(Average(Semiconductor))
  StressXY(Average(Semiconductor))
  StressXZ(Average(Semiconductor))
  StressYZ(Average(Semiconductor))
}

Physics {
  Recombination (SRH (DopingDependence) Auger)
  Mobility (DopingDep HighFieldSaturation)
  Piezo (
    # these two stress definitions should produce the same result
    #if "@stress@" == "pmi"
    Stress = pmi_stress(xx=100, yy=-4e9, zz=300, yz=400, xz=500, xy=600)
    #else
    Stress = (100, -4e9, 300, 400, 500, 600)
    #endif
  )
  EffectiveIntrinsicDensity (piezo)
  # EffectiveIntrinsicDensity ()
}

Math {
  -ExtendedPrecision
  Extrapolate
  # Derivatives
  Notdamped=100
  ConstRefPot
  -Derivatives
  Iterations=20
}

Solve {
  NewCurrentFilePrefix = "ignore_"
  poisson
  coupled { poisson electron hole }
  
  NewCurrentFilePrefix = ""
  quasistationary ( InitialStep=0.05 MinStep=1e-5 Maxstep=0.1
    Increment=1.5
  Goal { Name=Bottom voltage=2 } )
  { coupled { poisson electron hole } }
}
