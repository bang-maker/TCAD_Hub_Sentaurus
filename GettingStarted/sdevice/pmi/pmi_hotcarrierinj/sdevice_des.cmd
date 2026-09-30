File {
  Grid    = "@pwd@/nmos.tdr"
  Current   = "@plot@"
  Plot    = "@tdrdat@"
  Output    = "@log@"
  Parameter = "@parameter@"
  PMIPath   = "@pwd@"
}

Electrode {
  { name="source" voltage=0.0 }
  { name="drain" voltage=0.0  }
  { name="gate" voltage=0.0 barrier=-0.55 }
  { name="substrate" voltage=0.0 }
}

Plot {
  eDensity hDensity
  eCurrent hCurrent
  ElectricField
  eQuasiFermi hQuasiFermi 
  Potential Doping SpaceCharge
  SRH Auger Avalanche
  eMobility hMobility
  DonorConcentration AcceptorConcentration
  EffectiveIntrinsicDensity
  Doping
  HotElectronInjection
  HotElectronInjection/RegionInterface
}

Physics {
  EffectiveIntrinsicDensity(oldSlotboom noFermi)
  Mobility (
    DopingDep 
    HighFieldSaturation
    Enormal
  )
  Recombination (
    SRH(DopingDep)
    Avalanche(Eparallel)
  )
}

#if "@HCImodel@" != "none"
Physics(MaterialInterface="Silicon/Oxide"){
  GateCurrent( GateName="gate" @HCImodel@ )
}
#endif

Math {
  Extrapolate
  Digits=5
  Iterations=20
  
  -ParallelToInterfaceInBoundaryLayer
  eMobilityAveraging = Element
  hMobilityAveraging = Element
}

Solve {
  Poisson
  Coupled{ Poisson Electron Hole }
  
  Quasistationary (
    Initialstep=0.01 MaxStep=0.5 
    Minstep=1.e-4 Increment=2.0
    Goal {name="drain" voltage=3.75}
  ) { Coupled { Poisson Electron Hole } }
  
  Quasistationary (
    Initialstep=3.e-3 MaxStep=0.1 
    Minstep=1.e-4 Increment=1.3
    Goal {name="gate" voltage=6.0}
  ) { Coupled { Poisson Electron Hole } }
}
