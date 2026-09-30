*-----------------------------------------
* $Id: //tcad/gemini/w2024.09/allTests/L1.5/GettingStarted/emw/simple2d/emw_eml.cmd#1 $
* Author: Gergoe Letay
#setdep @previous@
Globals {
  GridFile        = "@tdr@"
  ParameterFile   = "@parameter@"
  ResultFile     = "@plot@"
  LogFile         = "@log@"
  NumberOfThreads = 1
  TotalTimeSteps  = 5000
  ## OverSampling    = 1.4
}

ComplexRefractiveIndex {
  Region = "ambient"
}

ComplexRefractiveIndex {
  Material = "Silicon"
  WavelengthDep = {Real,Imag}
}

Boundary {
  Type  = PeriodicOblique
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
  Nrise      = 4    * number of signal periods until full power
}

* Plot the absolute value of the electric field at the end of the simulation
Plot {
  Name      = "n@node@_Eabs"
  Quantity  = {AbsElectricField, AbsMagneticField, Region}
  TickStep  = 300
  StartTick = 100
  EndTick   = 800
  FinalPlot = yes
}                                       

Plot {
  Name       = "n@node@_Si"
  BoxCorner1 = {min,   0, 0}
  BoxCorner2 = {max, max, 0}
  Quantity   = {AbsElectricField, Region}
}                                       

Extractor {
  Name     = "n@node@_g"
  Quantity = {AbsorbedPhotonDensity, Region}
}

Sensor {
  Name       = "total"
  Quantity   = PhotonFluxDensity 
  PlaneY     = -0.2
  Mode       = {Integrate}
}

Sensor {
  Name       = "reflected"
  Quantity   = PhotonFluxDensity 
  PlaneY     = min
  Mode       = {Integrate}
}

Sensor {
  Name       = "transmitted"
  Quantity   = PhotonFluxDensity 
  PlaneY     = max
  Mode       = {Integrate}
}

Sensor {
  Name     = "absorbed"
  Quantity = AbsorbedPhotonDensity
  BoxCorner1 = {min, min, 0}
  BoxCorner2 = {max, max, 0}
  Mode     = {Integrate}
}

Sensor {
  Name     = "absorbedSub"
  Quantity = AbsorbedPhotonDensity
  Region   = {"substrate"}
  Mode     = {Integrate}
}

Sensor {
  Name       = "intersected"
  Quantity   = AbsorbedPhotonDensity
  Region     = {"substrate"}
  BoxCorner1 = {min , min, 0}
  BoxCorner2 = {0.05, max, 0}
  Domains    = Intersecting
  Mode       = {Integrate}
}

Detector {
  Tolerance = 1e-3
}


