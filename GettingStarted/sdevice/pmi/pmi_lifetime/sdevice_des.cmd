File {
  Grid          = "@pwd@/diode.tdr"
  Parameters = "@parameter@"
  Output     = "@log@"
  Current    = "@plot@"
  Plot       = "@tdrdat@"
  PMIPath    = "@pwd@"
}

Electrode {
  { Name="top"    voltage=0.8 }
  { Name="bottom" voltage=0   }
}

Thermode {
  { Name="top"    Temperature=300 }
  { Name="bottom" Temperature=300 }
}

Plot { 
  Doping AcceptorConcentration DonorConcentration
  Potential 
  ElectricField 
  eDensity hDensity
  eMobility hMobility
  eCurrent hCurrent ConductionCurrent
  effectiveIntrinsicDensity
  ElectricField
  eQuasiFermi hQuasiFermi
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel
  SpaceCharge
  BandGap
  SRHRecombination 
  eLifeTime 
  hLifeTime 
}

Physics {
  Recombination (
    SRH (
      #if "@pmi@" != "builtin"
      @pmi@
      #endif
    )
  )
  Mobility (DopingDependence PhuMob HighFieldSaturation)
}

Math {
  -ExtendedPrecision
  Extrapolate
  Derivatives
  AvalDerivatives
  RelErrControl  
  Digits=5
  ErrRef(electron)=1e8
  ErrRef(hole)    =1e8
  Iterations=10
}

Solve {
  Quasistationary(
    InitialStep=0.003 Minstep=0.001 MaxStep=0.05
    Goal {Name="top"  voltage=50}
  ) {
    Coupled { Poisson Electron Hole Temperature }
  }
}
