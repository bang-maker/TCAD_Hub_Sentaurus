#setdep @previous@
Globals {
  GridFile        = "@tdr@"
  LogFile         = "@log@"
  ResultFile      = "@plot@"
  NumberofThreads = 1
  TotalTimeSteps  = 10000
}

ComplexRefractiveIndex {
  WavelengthDep = {Real, Imag}
}

Boundary {
  Type  = CPML
  Sides = {X,Y,Z}
}

CodeVExcitation {
   InputDataFile    = {"@pwd@/data_z1.dat", "@pwd@/data_z2.dat"}
   AnchorPoint1     = {-0.5, -0.5, -0.3125}
   AnchorPoint2     = {-0.5, -0.5, -0.25}
   Wavelength       = 550
   Nrise            = 5
}

Plot {
  Boxcorner1   = {0, -0.5, -0.5}
  Boxcorner2   = {0,  0.5,  0.5}
  Name     = "n@node@_xcut"
  Quantity = {AbsElectricField}
}                             

Extractor {
  Boxcorner1   = {-0.5, -0.5, 0.}
  Boxcorner2   = { 0.5,  0.5, 0.5}
  Name     = "n@node@_g"
  Quantity = {AbsorbedPhotonDensity}
}

Detector {
  Tolerance = 1e-3
}
