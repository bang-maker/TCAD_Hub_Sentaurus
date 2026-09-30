#setdep @node|diode@

Device PN {
  Electrode {
    { name="anode"    Voltage=0.0 eRecVelocity= 1.5e7 hRecVelocity= 1.2e7 }   
    { name="cathode"  Voltage=0.0 eRecVelocity= 1.5e7 hRecVelocity= 1.2e7 }
    
  }
  
  File {
    Grid    = "@tdr@"
    Plot    = "@tdrdat@"
    Current = "@plot@"
  }
  
  Physics {
    Mobility( PhuMob HighFieldSaturation(GradQuasiFermi) )
    EffectiveIntrinsicDensity( oldSlotboom )
    Recombination ( SRH Auger )
  }
  
}

Math { 
  HBPlotFilePerNewton	
  HB { 
    MDFT  
    LogDensity
    
    UpdateScale(Electron) = 1.e-0 
    UpdateScale(Hole)     = 1.e-2 
    UpdateScale(Poisson)  = 1.e-0
    UpdateScale(Contact)  = 1.e-0
    UpdateScale(Circuit)  = 1.e-0
    
    RhsScale(Electron)    = 1.e-6  
    RhsScale(Hole)        = 1.e-6 
    RhsScale(Poisson)     = 1.e-1  
    RhsScale(Circuit)     = 1.e-6
    RhsScale(Contact)     = 1.e-8
    
  }
  
  Extrapolate   
  Notdamped=50
  Iterations=20
  ComputeGradQuasiFermiAtContacts= UseQuasiFermi  
  
  Method= ILS
  Number_Of_Threads = 4
}

Plot {
  eDensity hDensity
  eCurrent hCurrent
  ElectricField eEnormal hEnormal
  eQuasiFermi hQuasiFermi
  Potential Doping SpaceCharge
  SRH Auger 
  ImpactIonization
  eMobility hMobility
  DonorConcentration AcceptorConcentration
  Doping
  eVelocity hVelocity
  TotalCurrent
}

File {
  Output  = "@log@"
}

System {
  PN pn (cathode=c anode=a)
  sd_hb_vsource_pset "va" (a  c) { dc= 0.0 
    freq= @f1@ mag= 0.0 phase= -90.
  }
  set(c=0)
  HBPlot "n@node@_hbplot" ( v(a) i(pn a)) * HB circuit output
}

Solve {
  System("rm *n@node@_*_Hdom_des.plt *n@node@_*_Tdom_des.plt")
  
  Coupled { Poisson }
  Coupled { Poisson Electron Hole }
  Quasistationary (
    InitialStep=1e-3 Increment=1.5
    MaxStep=@<1.0/20>@ Minstep=1.e-8 
    Goal { Parameter="va"."dc" Voltage=@Vdc@}
  )  
  {Coupled  { Poisson Electron Hole } }
  
  
  Quasistationary (
    InitialStep=1e-3 Increment=1.5
    MaxStep=@<1.0/25>@ Minstep=1.e-8 
    Goal { Parameter="va"."mag"  Value= @mag@ }
  )  
  {HBCoupled (
      Tone ( Frequency = "va"."freq"  NumberOfHarmonics = @NumHarm@ )
      Initialize = DCMode
      Method = ILS
      GMRES ( Tolerance = 1e-5 MaxIterations = 80 Restart = 20 )
  ) { Poisson Electron Hole }
  }
  
}

