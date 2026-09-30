*-----------------------------------------
* $Id: //tcad/support/main/examples/getting-started/emw/simple2d/emw_eml.cmd#9 $
* Author: Gergoe Letay
#setdep @previous@
Globals {
  GridFile        = "@tdr@"
  ParameterFile   = "@parameter@"
  ResultFile      = "@plot@"
  LogFile         = "@log@"
  NumberOfThreads = 1
  Kernel          = Synopsys
  TotalTimeSteps  = 50000
  OverSampling    = 3.6
}

ComplexRefractiveIndex {
   WavelengthDep = {Real,Imag}
}


DispersiveMedia {
  Material = {"Silver"}
  Model = SingleDipoleDrude
  ModelParameters = ComputeFromComplexRefractiveIndex
  InterfaceAveraging = yes
}

Boundary {
  Type  = periodicOblique
  Sides = {X}
} 

Boundary {     
  Type  = CPML
  Sides = {Y}        
}

PlaneWaveExcitation {
  PlaneY     = -0.5    
  Theta      = 0
  Psi        = 0                                                             
  Wavelength = @<1000.*wavelength>@ * nm
  Intensity  = 0.1  * W/cm2
  Nrise      = 8    * number of signal periods until full power
}

Save {
  Name = "@save@"
  Quantity = {AbsorbedPhotonDensity, PowerFluxDensity}
}

Detector {
  Tolerance = 1e-4
}


