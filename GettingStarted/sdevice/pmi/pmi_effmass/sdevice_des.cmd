File {
  Grid    = "@pwd@/diode.tdr"
  Current   = "@plot@"
  Plot    = "@tdrdat@"
  Output    = "@log@"
  Parameter = "@parameter@"
  PMIPath   = "@pwd@"
}

Electrode {
  { name="top"     voltage=0 }
  { name="bottom"  voltage=0 }
}

Thermode {
  { Name="top"     Temperature=300 }
  { Name="bottom"  Temperature=300 }
}

Plot {
  BandGap BandGapNarrowing EffectiveIntrinsicDensity
  eCurrent/Vector hCurrent/Vector
  Doping SpaceCharge eDensity hDensity
  ElectricField/Vector 
  eQuasiFermi hQuasiFermi
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  SRH Auger
  eMobility hMobility
  eRelativeEffectiveMass hRelativeEffectiveMass
}

Physics {
  EffectiveMass ( @EMmodel@ )
  Recombination (
    SRH(DopingDep) Auger Avalanche
  )
  Mobility (DopingDep Enormal HighFieldSaturation )
}

Math {
  Extrapolate
  Digits=5
  Iterations=10
  
  eMobilityAveraging = Element
  hMobilityAveraging = Element
}

Solve {
  Poisson
  Coupled { Poisson Electron Hole }
  Coupled { Poisson Electron Hole Temperature }

  QuasiStationary (
    InitialStep=0.04 MaxStep=0.04 MinStep=0.001
    Goal { Name="top"  voltage=2 }
  ) { Coupled { Poisson Electron Hole Temperature } }
}
