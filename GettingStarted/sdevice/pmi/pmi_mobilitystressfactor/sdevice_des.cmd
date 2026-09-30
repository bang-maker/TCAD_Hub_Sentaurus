#setdep @previous@
File {
  * input files:
  Grid=   "@tdr@"
  PMIPath= "@pwd@"
  * output files:
  Plot=   "@tdrdat@"
  Current="@plot@"
  Output= "@log@"
}

Electrode {
  { Name="source"    Voltage= 0.0 }
  { Name="drain"     Voltage= 0.0 }
  { Name="gate"      Voltage= 0.0 }
  { Name="substrate" Voltage= 0.0 }
}

Plot {
  eMobility hMobility
  eDensity hDensity
  eCurrent/Vector hCurrent/Vector
  ElectricField/Vector
  eQuasiFermi hQuasiFermi
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel
  ElectrostaticPotential
  CurrentPotential
  eEffectiveStress
  hEffectiveStress
  NearestInterfaceOrientation
  Stress
}

Physics{
  EffectiveIntrinsicDensity( OldSlotboom )     
}

Physics(Material="Silicon"){
  Mobility (
    DopingDep
    Enormal
    HighFieldSaturation
  )
  Recombination(
    SRH( DopingDependence )
  )
  Piezo (
    Stress=(0, @Stress@, 0, 0, 0, 0)
    Model (
      Mobility (
        SaturationFactor=0.0
        Factor (
          pmi_EffectiveStressModel
          ChannelDirection=2
          ApplyToMobilityComponents
        )
      )
      DOS(eMass hMass)
      DeformationPotential(Minimum ekp hkp)
    )
  )
}

Math { 
  Extrapolate
  Iterations= 20
  ExitOnFailure
}

Solve {
  *- Creating initial guess:
  Coupled(Iterations= 100){ Poisson } 
  Coupled {Poisson Electron Hole}
  
  *- Ramp drain to VdLin
  Quasistationary( 
    InitialStep= 0.1 Increment= 1.5 
    MinStep= 1e-5 MaxStep= 1 
    Goal { Name="drain" Voltage=@VdLin@ } 
  ){ Coupled {Poisson Electron Hole} } 
  
  *- Vg sweep 
  NewCurrentPrefix="IdVgLin_" 
  Quasistationary( 
    DoZero 
    InitialStep= 0.01 Increment= 1.5 
    MinStep= 1e-5 MaxStep= 0.05 
    Goal { Name="gate" Voltage= 3.0 } 
  ){ Coupled {Poisson Electron Hole} }
}
