#setdep @previous@

File {
  grid  = "@tdr@"
  current = "@plot@"
  output  = "@log@"
  plot    = "@tdrdat@"
  parameter = "@parameter@"
  PMIPATH = "@pwd@"
}

Plot {
  xMoleFraction
  OpticalGeneration  
  ComplexRefractiveIndex
}

CurrentPlot {
  ModelParameter="Wavelength"
  Model="DeviceTemperature" Parameter="Temperature"
  ComplexRefractiveIndex(Average(Region="layer1"))
}

Physics {
  Temperature = 300
  Optics (
    ComplexRefractiveIndex(
      TemperatureDep
      CRIModel ( Name = "crimi_nk_hgcdte_hougen")
    )
    OpticalGeneration (
      ComputeFromMonochromaticSource
    )
    Excitation (
      fromTop
      Intensity  = 0.1 * W/cm2
      Wavelength = 4.  * um
    )
    OpticalSolver (
      TMM (
        LayerStackExtraction (
          Mode=elementWise
          # complexRefractiveIndexThreshold=0.01
        )
      )
    )
  )
} * end global physics

Physics(Region="layer1") {
  MoleFraction(xfraction=0.198)
}

Math {
  -ExtendedPrecision
  -CheckUndefinedModels
}

Solve {
  Optics
}


