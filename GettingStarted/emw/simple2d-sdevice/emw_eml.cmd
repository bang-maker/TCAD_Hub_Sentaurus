#-----------------------------------------
# $Id: //tcad/gemini/w2024.09/allTests/L1.5/GettingStarted/emw/simple2d-sdevice/emw_eml.cmd#1 $
# Author: Gergoe Letay
#setdep @previous@
Globals {
  GridFile       = "@tdr@"
  ParameterFile  = "@parameter@"
  ResultFile     = "@plot@"
  LogFile        = "@log@"
  TotalTimeSteps = 5000
}

ComplexRefractiveIndex {
  WavelengthDep = {Real,Imag}
}

Boundary {
  Type = periodicOblique
  Sides = {X}
} 

Boundary {     
  Type = CPML
  Sides = {Y}        
}

PlaneWaveExcitation {
  BoxCorner1 = {0. , -0.5, 0.}    
  BoxCorner2 = {0.1, -0.5, 0.}
  Theta      = 0
  Psi        = 0                                 
  Wavelength = @<1000.*wavelength>@ * nm
  Intensity  = 0.1 * W/cm2
  Nrise      =  4   * number of signal periods until full power
}

Extractor {
  Name     = "n@node@_g"
  Quantity = {absorbedPhotonDensity, PowerFluxDensity}
  GridFile = "@[relpath n@node|sde@_el_msh.tdr]@"
}

Extractor {
  Name     = "n@node@_gtensor"
  Quantity = {absorbedPhotonDensity, Region}
}

Sensor {
  Name       = "total"
  Quantity   = PhotonFluxDensity 
  BoxCorner1 = {0.0, -0.2, 0}
  BoxCorner2 = {0.1, -0.2, 0}
  Mode       = {Integrate}
}

Sensor {
  Name       = "reflected"
  Quantity   = PhotonFluxDensity 
  BoxCorner1 = {0.0, -0.9, 0}
  BoxCorner2 = {0.1, -0.9, 0}
  Mode       = {Integrate}
}

Sensor {
  Name       = "transmitted"
  Quantity   = PhotonFluxDensity 
  BoxCorner1 = {0.0, 1, 0}
  BoxCorner2 = {0.1, 1, 0}
  Mode       = {Integrate}
}

Sensor {
  Name       = "absorbed"
  Quantity   = absorbedPhotonDensity
  BoxCorner1 = {0.0, 0, 0}
  BoxCorner2 = {0.1, 1, 0}
  Mode       = {Integrate}
}

Detector {
  Tolerance = 1e-3
}


