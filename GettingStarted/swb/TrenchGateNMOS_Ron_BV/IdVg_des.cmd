## Tool: Sentaurus Device 
## Characteristics: IdVg
## Dependency: Should be run after the process simulation of NMOS device
#setdep @node|DevMesh@

#if @< [string compare SBD NO] == 0 && [string compare SIM IV] == 0 >@
#noexec
#endif

#set ni @[format "%.1e" [expr 9.38e19*(@Tamb@/300.0)*(@Tamb@/300.0)*exp(-6884.0/@Tamb@)]]@

## Input and Output Files
File {
  grid      = "@[relpath n@node|DevMesh@_final_fps.tdr]@"
  current   = "@plot@"
  output    = "@log@"
  plot      = "@tdrdat@"
  parameter = "@parameter@"
}

## Electrical contacts
Electrode {
  { Name="drain" Voltage= 0.0 }
  #if @<[string compare SBD "YES"] == 0>@
  { Name="source" Schottky Workfunction= @phin@ Voltage= 0.0 }
  #else
  { Name="source" Voltage= 0.0 }
  #endif
  ## -- { Name="gate" Voltage= 0.0 Material= "PolySi"}
  { Name="gate" Voltage= 0.0 }
}

## Thermal contacts
Thermode {
  { Name= "drain" Temperature= @Tamb@ SurfaceResistance= @ThermalR@ } 
  { Name= "source"   Temperature= @Tamb@ SurfaceResistance= @ThermalR@ } 
  { Name= "gate"      Temperature= @Tamb@ SurfaceResistance= @ThermalR@ }  
}

## Physics models
Physics {
  AreaFactor  = @AF@
  Temperature = @Tamb@
  Mobility(
    PhuMob Enormal
    HighFieldSaturation(EparallelToInterface) 
  )
  Recombination(
    SRH( DopingDep TempDependence)  
    Auger 
  )
  EffectiveIntrinsicDensity( OldSlotboom )
  ## Thermodyanmic Simulations
  ## -- Thermodynamic  
}

Physics (MaterialInterface="Oxide/Silicon") {
  Traps(FixedCharge Conc= 0.0)
}

Plot{
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi 
  Temperature
  eTemperature  hTemperature
  ElectricField/Vector Potential SpaceCharge
  Doping DonorConcentration AcceptorConcentration
  SRH Auger Band2Band  
  ImpactIonization eImpactIonization hImpactIonization
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  BandGapNarrowing
}

Math {
  Extrapolate
  Notdamped=50
  Iterations=12   
  Digits           = 6    
  ErrRef(electron) = @<1e-1*ni>@
  ErrRef(hole)     = @<1e-1*ni>@
  RHSmin=1e-20
  ## For Multi-threading
  Number_of_threads= 2
  RefDens_eGradQuasiFermi_EParallelToInterface= 1.0e12
  RefDens_hGradQuasiFermi_EParallelToInterface= 1.0e12      
  ## For Schottky contact
  #if @<[string compare SBD "YES"] == 0>@
  NonLocal "NLM" (
    Electrode= "source"
    Length= 1e-6
    Digits= 4
    EnergyResolution= 0.001
  )
  #endif
}

Solve {
  *- Initial Solution
  Coupled { poisson }
  Coupled(Iterations=100 LineSearchDamping=1e-4){ Poisson Electron } 
  Coupled { Poisson Electron Hole }  
  
  *- Vd sweep
  Quasistationary( 
    InitialStep= 1e-4 MinStep= 1e-5 MaxStep= 1.0
    Increment= 1.5 Decrement= 2.0
    Goal { Name="drain" Voltage= @Vd@ }                 
  ){ Coupled { Poisson Electron Hole }  }   
  
  NewCurrentPrefix="IdVg_" 
  
  *- Vg sweep
  Quasistationary( 
    InitialStep= 1e-4 MinStep= 1e-5 MaxStep= 0.1
    Increment= 1.5 Decrement= 2.0
    Goal { Name="gate" Voltage= 8.0 }         
  ){ Coupled { Poisson Electron Hole } 
    CurrentPlot( Time=(Range=(0 1) Intervals= 40 )  )
  }
  
}



