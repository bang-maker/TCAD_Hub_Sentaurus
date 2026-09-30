Electrode{
  { Name="emitter"   Voltage=0 }
  { Name="base"      Voltage=0 }
  { Name="collector" Voltage=0 }
}


File{
  Grid      = "@tdr@"
  Plot      = "@tdrdat@"
  Current   = "@plot@"
  Output    = "@log@"
  Parameter = "@parameter@"
}

Physics {
  Hydro(eTemperature)
  Mobility(
    eHighFieldsaturation(CarrierTempDrive)
    hHighFieldSaturation
  ) 
  Recombination(  
    SRH
    Radiative
    Auger
  )
  EffectiveIntrinsicDensity(Nobandgapnarrowing)
}

Physics( Material= "GaAs" ) {
  Mobility(DopingDep)
}

Physics( Region= "AlGaAs_Emitter" ) {
  MoleFraction( 
    XFraction=0.3 
    Grading( 
      (RegionInterface = ( "GaAs_Emitter_Cap" "AlGaAs_Emitter" )
      XFraction=0.0 GrDistance=0.10)
      (RegionInterface = ( "GaAs_Base" "AlGaAs_Emitter" )
      XFraction=0.0 GrDistance=0.025)
    )
  )
}

Physics( RegionInterface = "Passivation/GaAs_Base" ) {
  Traps(
    (Donor    Level fromCondBand
      Conc=1e10 EnergyMid=0.61
    eXsection=1e-12 hXsection=1e-12) 
    (Acceptor Gaussian fromValBand
      Conc=1e10 EnergyMid=0.59 EnergySig=0.1
    eXsection=1e-12 hXsection=1e-12) 
  )
}

Plot{
  *-Carrier Densities:
  eDensity hDensity
  # EffectiveIntrinsicDensity IntrinsicDensity
  # eEquilibriumDensity hEquilibriumDensity
  
  *-Currents and current components:
  Current/Vector eCurrent/Vector hCurrent/Vector
  # ConductionCurrent/Vector DisplacementCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  
  *-Fields, Potentials and Charge distributions
  ElectricField/Vector 
  Potential 
  eQuasiFermi hQuasiFermi
  SpaceCharge
  
  *-Driving forces
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel 
  eENormal hENormal
  # eEffectiveField hEffectiveField
  
  *-Temperatures
  LatticeTemperature
  eTemperature hTemperature
  
  *-Generation/Recombination
  SRHRecombination Band2Band AugerRecombination RadiativeRecombination
  # ImpactIonization eImpactIonization hImpactIonization
  TotalRecombination
  eLifeTime hLifeTime
  SurfaceRecombination
  
  *-Doping Profiles
  Doping 
  DonorConcentration AcceptorConcentration
  
  *-Band structure
  BandGap 
  BandGapNarrowing
  ElectronAffinity
  ConductionBandEnergy ValenceBand
  
  *-Composition
  xMoleFraction # yMoleFraction
  
  *-Traps
  eTrappedCharge hTrappedCharge
  eGapStatesRecombination hGapStatesRecombination
  
  *-Tunneling
  # BarrierTunneling eBarrierTunneling hBarrierTunneling
  # eSchenkTunnel hSchenkTunnel
  
}

Math{
  Extrapolate
  NotDamped=200
  Iterations=20
  RelerrControl
  ErrRef(Electron)  = 1.e8
  ErrRef(Hole)      = 1.e8
}

Solve{
  Coupled ( Iterations=100 ) { Poisson }
  Coupled { Poisson Electron Hole eTemperature }
  
  Plot(FilePrefix="n@node@_Ini")
  
  NewCurrentPrefix=n@node@_init
  Quasistationary(
    InitialStep=1e-2 Increment=1.5 
    Minstep=1e-6     MaxStep=0.5 
    Goal{ Name="base"      Voltage=0.5 }
    Goal{ Name="collector" Voltage=3.0 }
  ){ Coupled { Poisson Electron Hole eTemperature } }
  
  NewCurrentPrefix=""
  Quasistationary(
    InitialStep=0.05 Increment=1.5
    Minstep=1e-8     MaxStep=0.05
    Goal{ Name="base"      Voltage=2.0 }
    Goal{ Name="collector" Voltage=4.5 }
  ){ Coupled{ Poisson Electron Hole eTemperature } }
  
}
