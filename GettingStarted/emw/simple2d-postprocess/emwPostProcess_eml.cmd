*-----------------------------------------
* $Id: //tcad/support/main/examples/getting-started/emw/simple2d/emw_eml.cmd#9 $
* Author: Gergoe Letay
#setdep @previous@
Globals {
  LoadFile    = "@load@"
  ResultFile  = "@plot@"
  LogFile     = "@log@"
}

Extractor {
  Name     = "n@node@_g"
  Quantity = {absorbedPhotonDensity, Region}
}

Sensor {
  Name       = "total"
  Quantity   = PhotonFluxDensity 
  PlaneY     = -0.25
  Mode       = {Integrate}
}

Sensor {
  Name       = "reflected"
  Quantity   = PhotonFluxDensity 
  PlaneY     = -1
  Mode       = {Integrate}
}

Sensor {
  Name       = "transmitted"
  Quantity   = PhotonFluxDensity 
  PlaneY     = 1.25
  Mode       = {Integrate}
}

Sensor {
  Name     = "absorbed_sub"
  Quantity = absorbedPhotonDensity
  Region   = {"substrate"}
  Mode     = {Integrate}
}

Sensor {
  Name     = "absorbed_met"
  Quantity = absorbedPhotonDensity
  Region   = {"metal"}
  Mode     = {Integrate}
}

Sensor {
  Name       = "intersected"
  Quantity   = absorbedPhotonDensity
  Region     = {"substrate"}
  BoxCorner1 = {0. , -1, 0}
  BoxCorner2 = {0.05, 1, 0}
  Domains    = Intersecting
  Mode       = {Integrate}
}

