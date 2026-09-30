
File{
  Grid      = "@tdr@"
  Plot      = "@tdrdat@"
  Parameter = "@parameter@"
  Current   = "@plot@"
  Output    = "@log@"
  ACExtract = "@acplot@"
}

Electrode{
  { Name="source"    Voltage=0.0 }
  { Name="drain"     Voltage=0.0 }
  { Name="gate"      Voltage=0.0 }
  { Name="substrate" Voltage=0.0 }
}

Physics{
  Fermi
  EffectiveIntrinsicDensity( OldSlotboom )     
  Mobility(
    DopingDep
    eHighFieldsaturation( GradQuasiFermi )
    hHighFieldsaturation( GradQuasiFermi )
    Enormal
  )
  Recombination(
    SRH( DopingDep TempDependence )
  )           
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
  SRH Band2Band # Auger
  ImpactIonization eImpactIonization hImpactIonization
  
  *--Driving forces
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  
  *--Band structure/Composition
  BandGap 
  BandGapNarrowing
  Affinity
  ConductionBand ValenceBand
  eQuantumPotential
}

Math {
  RelErrControl
  Digits=5                  * (default)
  ErrRef(electron)=1.e10    * (default)
  ErrRef(hole)=1.e10        * (default)
  Iterations=20
  Notdamped=100
  Method=Blocked
  SubMethod=Super
  ACMethod=Blocked 
  ACSubMethod=Super
  ImplicitACSystem
}




Solve {
	
  NewCurrentPrefix="init_"
  Coupled(Iterations=100){ Poisson }
  Coupled{ Poisson Electron Hole }
  
  Quasistationary ( 
    InitialStep=0.1 Increment=1.3
    MaxStep=0.5 Minstep=1.e-5  
    Goal { name=gate Voltage=-3.0 }
  ){ Coupled { Poisson Electron Hole } }
  
  NewCurrentPrefix=""
  Quasistationary (
    InitialStep=0.01 Increment=1.3
    MaxStep=0.05 Minstep=1.e-5 
    Goal { name=gate Voltage=3.0 }
  ){ ACCoupled (
      StartFrequency=1e6 EndFrequency=1e6 NumberOfPoints=1 Decade
      ACCompute (Time = (Range = (0 1)  Intervals = 40))
  ){ Poisson Electron Hole }
  }
}
