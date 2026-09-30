File {
  Grid    = "@pwd@/diode.tdr"
  Current   = "@plot@"
  Plot    = "@tdrdat@"
  Output    = "@log@"
  Parameter = "@parameter@"
  PMIPath   = "@pwd@"
}

Electrode {
  { name="top"     voltage=0.8 }
  { name="bottom"  voltage=0 }
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
}

Physics {
  EffectiveIntrinsicDensity (
    @BGNmodel@
  )
  Recombination (
    SRH(DopingDep) Auger Avalanche
  )
  Mobility( DopingDep Enormal HighFieldSaturation )
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
  
  QuasiStationary (
    InitialStep=0.1 MaxStep=0.1 MinStep=0.001
    Goal { name="top"  voltage=2 }
  ) {
    Coupled { Poisson Electron Hole } 
  }
}
