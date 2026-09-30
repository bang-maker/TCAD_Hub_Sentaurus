File {
  Grid = "@pwd@/latchup_geo.tdr"
  PMIPath = "@pwd@"
  plot    = "@tdrdat@"
  current = "@plot@" 
  output  = "@log@"
}


Electrode {
  { name="pwell" voltage=0  }      
  { name="nsource" voltage=0  }  
  { name="ndrain" voltage=0  }  
  { name="pdrain" voltage=0  }  
  { name="psource" voltage=0  }  # exclude from circuit 
  { name="nsub" voltage=0  }  
}

Plot { 
  Avalanche eAvalanche hAvalanche
  TotalRecombination
  SRHRecombination
  AugerRecombination
}

Physics (Material="Silicon") {
  Mobility ( DopingDep HighFieldSaturation Enormal)
  Recombination(
    SRH(DopingDep) 
    Auger 
    Avalanche 
    band2band(E1)
  )
}

Math {
  -ExtendedPrecision
  RelErrControl
  digits = 7
  Iterations=15
  NotDamped = 20
  Derivatives
  AvalDerivatives
  Extrapolate
  ErrRef(Electron)=1e5
  ErrRef(Hole)=1e5
  Transient=BE
  ExitOnFailure
}


Solve {
  NewCurrentPrefix="prebias_"
  Poisson
  Coupled { Poisson Electron Hole}
  Quasistationary (
    InitialStep=1e-4 Minstep=1.e-7 MaxStep=0.04
    Increment=1.3                 
    Goal { name=nsub    voltage=5.0 }
    Goal { name=psource voltage=5.0 }
  ) {
    Coupled { Poisson Electron Hole} 
  }
  
  NewCurrentPrefix="breakdown_"
  Continuation(
    NewArc
    Name="psource" 
    InitialVstep=0.01
    MinVoltage=0.0 MaxVoltage=10 
    MinCurrent=0 MaxCurrent=2e-4
    Normalized # angle comp in local normalized IV plane
    MaxIfactor	= 3
  ) { 
    Coupled ( PMI_NewtonStep( pmiNewtonStep(InfoLevel=2 MaxNewtonStep = 1.e-4 )  )) 
    { Poisson Electron Hole} 
  }
  System("rm *prebias*des.plt")
}
