File {
  Grid      = "@pwd@/block.tdr"
  Plot      = "@tdrdat@"
  Current   = "@plot@"
  Output    = "@log@"
  PMIPath   = "@pwd@"
}

Electrode {
  { name="left"   Voltage=0 }
  { name="right"  Voltage=0 }
}

Plot {
  DopingConcentration
  ArsenicActiveConcentration
  BoronActiveConcentration
  xMoleFraction
  PMIUserField0
}

CurrentPlot {
  Potential ((7.7 6.3))
  PMIModel (name="@pmi@" x=7.7 y=6.3 scale=1)
}

Physics (RegionInterface = "R.InP/R.GaInP") {
  Thermionic
}

Physics (RegionInterface = "R.GaInP/R.GaP") {
  Thermionic
}

Math {
  #if @extPrec@
  ExtendedPrecision(128)
	#else
  -ExtendedPrecision
  #endif
  extrapolate
  digits = 5
  Notdamped=20
  Iterations=10
  Derivatives
  RelErrControl
  DirectCurrent
  
  eMobilityAveraging = Element
  hMobilityAveraging = Element
  -GeometricDistances
  ParameterInheritance = None
}


Solve {
  NewCurrentPrefix = "initial_"
  Poisson
  
  NewCurrentPrefix = ""
  Quasistationary (
    DoZero
    InitialStep = 0.1  MaxStep = 0.1
    Goal {name = "right"  value = 20}
  ) {
    Coupled { Poisson Electron Hole } 
  }
  
}
