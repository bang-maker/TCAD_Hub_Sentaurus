#setdep @previous@

*--------------------------------------------------
File {
  grid  = "@tdr@"
  current = "@plot@"
  output  = "@log@"
  plot    = "@tdrdat@"
  parameter = "@parameter@"
  PMIPATH = "@pwd@"
}

*--------------------------------------------------
Plot {
  * *-- optics 
  OpticalGeneration  
  ComplexRefractiveIndex
}

*--------------------------------------------------
CurrentPlot {
	ModelParameter="Wavelength"
  Model="DeviceTemperature" Parameter="Temperature"
  ComplexRefractiveIndex(Average(Material="Silicon"))
}

*--------------------------------------------------
Physics {
  Temperature = @T@
  Optics (
    ComplexRefractiveIndex(
      WavelengthDep  (real imag)
      TemperatureDep (real)
      CRIModel ( Name = "crimi_k_si_rss" )	
    )
    OpticalGeneration (
      ComputeFromMonochromaticSource
    )
    Excitation (
      fromTop
      Intensity  = 0.1 * W/cm2
      Wavelength = 0.2  * um 
    )
    OpticalSolver (
      TMM (
        LayerStackExtraction ()
      )
    )
  )
} * end global physics

Math {
  -ExtendedPrecision
}

*--------------------------------------------------
Solve {
  Quasistationary (
    DoZero
    InitialStep=0.05   MaxStep=0.05   MinStep=0.05
    Goal { ModelParameter="Wavelength" value=1.2 }
  ) {
    Optics
  }
}


