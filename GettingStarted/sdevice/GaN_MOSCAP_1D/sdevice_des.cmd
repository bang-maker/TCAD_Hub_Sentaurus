Device MOSCAP {
  Electrode {
    { Name="gate"  Voltage= 0.0 Workfunction= 5.0}
    { Name="subs"  Voltage= 0.0 }
  }
  
  File {
    Grid= "@tdr@"
    Parameter= "@parameter@"
    
    Current= "@plot@"
    Plot= "@tdrdat@"
  }
  
  Physics {
    AreaFactor= 5e8   * So capacitance given in F/cm^2
    Fermi
    Mobility(
      DopingDependence
    )
    Recombination(
      SRH
    )
    
    DefaultParametersFromFile
  }
  
  Physics (MaterialInterface="GaN/Oxide") {
    Traps (
      Acceptor Level EnergyMid= 1.0 FromMidbandgap Conc= 5e11
      eXSection= 1e-15 hXSection= 1e-15
    )
    
    * Assume the majority of polarization charge is compensated by fixed charges
    Piezoelectric_Polarization(strain Activation= 0.05)
  }
}


File {
  Output= "@log@"
  ACextract= "@acplot@"
}

Math {
  Extrapolate
  Iterations= 12
  
  #if @QS@
  ExtendedPrecision(256)
  #else
  ExtendedPrecision
  #endif
  Digits= 8
  RHSMin= 1e-15
  
  Transient= BE
}

System {
  MOSCAP C ("gate"=1 "subs"=0)
  #if @QS@
  Vsource_pset Vg (1 0) {dc= 0}
  #else
  Vsource_pset Vg (1 0) {pwl= (0 0  @<0.1*dt>@ +5.0 @<1.1*dt>@ -5.0)}
  #endif
}

Solve {
  NewCurrentFile="Junk_"
  Coupled (Iterations= 10000) {Poisson}
  Coupled (Iterations= 10000) {Poisson Electron Hole}
  
  #if @QS@
  Quasistationary(
    InitialStep= 0.01 MaxStep= 0.05 MinStep= 1e-5
    Goal {Parameter= Vg.dc Value= +5.0}
  ) {
    Coupled{Poisson Electron Hole}
  }
  #else
  Transient(
    InitialTime= 0 FinalTime= @<0.1*dt>@
    InitialStep= @<0.01*dt>@ MaxStep= @<0.1*dt>@ MinStep= @<1e-5*dt>@
  ) {
    Coupled{Poisson Electron Hole}
  }
  #endif
  
  NewCurrentFile=""
  #if @QS@
  Quasistationary(
    InitialStep= 0.01 MaxStep= 0.01 MinStep= 1e-7
    Goal {Parameter= Vg.dc Value= -5.0}
  ) {
    ACCoupled(
      StartFrequency= 1e6 EndFrequency= 1e6
      NumberOfPoints= 1
      Node(1) Exclude(Vg)
    ) {Poisson Electron Hole}
  }
  #else
  Transient(
    InitialTime= @<0.1*dt>@ FinalTime= @<1.1*dt>@
    InitialStep= @<0.01*dt>@ MaxStep= @<0.01*dt>@ MinStep= @<1e-5*dt>@
  ) {
    ACCoupled(
      StartFrequency= 1e6 EndFrequency= 1e6
      NumberOfPoints= 1
      Node(1) Exclude(Vg)
    ) {Poisson Electron Hole}
  }
  #endif
}
