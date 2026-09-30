Electrode{
  { name="base"      voltage=0 }
  { name="emitter"   voltage=0 }
  { name="collector" voltage=0 }
}

File{
  Grid    = "@tdr@"
  Plot    = "@tdrdat@"
  Current = "@plot@"
  Output  = "@log@"
}

Plot{
  *--Density and Currents, etc
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  
  *--Temperature 
  eTemperature Temperature * hTemperature
  
  *--Fields and charges
  ElectricField/Vector Potential SpaceCharge
  
  *--Doping Profiles
  Doping DonorConcentration AcceptorConcentration
  
  *--Generation/Recombination
  SRH Band2Band * Auger
  ImpactIonization eImpactIonization hImpactIonization
  
  *--Driving forces
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  
  *--Band structure/Composition
  BandGap 
  BandGapNarrowing
  Affinity
  ConductionBand ValenceBand
}


Physics{
  Recombination(
    SRH(DopingDep)
    Auger
  )   
  Mobility( DopingDep HighFieldSaturation)
  EffectiveIntrinsicDensity( OldSlotboom )
}

Math{
  Extrapolate  
  RelErrControl  
  Digits=5
  ErrRef(electron)= 1.0e7
  ErrRef(hole)    = 1.0e7
  Iterations=20
  Notdamped=100
}

Solve {

  Coupled(Iterations=100){ Poisson }
  Coupled{ Poisson Electron Hole }
  
  Quasistationary ( 
    InitialStep=0.01 Increment=1.3
    MaxStep =0.2 MinStep = 1e-6 
    Goal{ Name="base" Voltage=0.5 }
  ){ Coupled {Poisson Electron Hole } }
  
  Set( "base" mode current ) 
  
  Quasistationary ( 
    InitialStep=0.01 Increment=1.3
    MaxStep =0.2 MinStep = 1e-6 
    Goal{ Name="base" Current=@Ib_ini@ }
  ){ Coupled {Poisson Electron Hole } }
  
  Quasistationary ( 
    InitialStep=0.01 Increment=1.3
    MaxStep =0.2 MinStep = 1e-6 
    Goal{ Name="base" Current=@Ib_end@ }
  ){ Coupled {Poisson Electron Hole }  
    Save(FilePrefix="n@node@_Ib" Time=(0.0;0.5;1) NoOverWrite )
  }
  
  NewCurrentPrefix="Ib0_"
  Load(FilePrefix="n@node@_Ib_0000")
  
  Quasistationary ( 
    InitialStep=0.01 Increment=1.3
    MaxStep =0.2 MinStep = 1e-6 
    Goal{ Name="collector" Voltage=1.0 }
  ){ Coupled {Poisson Electron Hole}
  }
  
  NewCurrentPrefix="Ib1_"
  Load(FilePrefix="n@node@_Ib_0001")
  
  Quasistationary ( 
    InitialStep=0.01 Increment=1.3
    MaxStep =0.2 MinStep = 1e-6 
    Goal{ Name="collector" Voltage=1.0 }
  ){ Coupled {Poisson Electron Hole}
  }
  
  NewCurrentPrefix="Ib2_"
  Load(FilePrefix="n@node@_Ib_0002")
  
  Quasistationary ( 
    InitialStep=0.01 Increment=1.3
    MaxStep =0.2 MinStep = 1e-6 
    Goal{ Name="collector" Voltage=1.0 }
  ){ Coupled {Poisson Electron Hole}
  }
}






