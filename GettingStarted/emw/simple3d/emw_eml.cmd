#-----------------------------------------
# $Id: //tcad/gemini/w2024.09/allTests/L1.5/GettingStarted/emw/simple3d/emw_eml.cmd#1 $
# Author: Gergoe Letay
#setdep @previous@
Globals {
  GridFile       = "@tdr@"
  ParameterFile  = "@parameter@"
  ResultFile    = "@plot@"
  LogFile        = "@log@"
  TotalTimeSteps = 5000
  CompressTDR = Yes
}

ComplexRefractiveIndex {
  WavelengthDep = {Real,Imag}
}

Boundary {
  Type  = PeriodicOblique
  Sides = {X,Y}
} 

Boundary {     
  Type  = CPML
  Sides = {Z}        
}

PlaneWaveExcitation {
  Direction  = FromBottom                                                       
  # Theta      = 0
  #    Phi    = 90
  # Psi        = 0                                 
  Wavelength = @<1000.*wavelength>@ * nm
  Intensity  = 0.1  * W/cm2
  Nrise      = 4    * number of signal periods until full power
}

Plot {                                          
  Name      = "n@node@_Ex"
  Quantity  = {AbsElectricField, Region}
  PlaneX    = 0.05    
  FinalPlot = yes
}

Extractor {
  Quantity = {absorbedPhotonDensity, PowerFluxDensity, Region}
  PlaneX = 0.05
  Name     = "n@node@_gx"
}

RTA {
  Log = {R,T,A,RTA}
  StartTick = 0
}


Detector {
  Tolerance = 1e-3
}


