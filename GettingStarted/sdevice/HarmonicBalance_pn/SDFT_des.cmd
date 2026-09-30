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
    LogDensity    
  }
  -NewHBFileNames
  Extrapolate 
  Notdamped=50
  Iterations=30
  ComputeGradQuasiFermiAtContacts= UseQuasiFermi  
  
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
  Vsource_pset "va" (a  c) { sine = (0.0 0.0 @f1@ 0 0) }
  set(c=0)
  HBPlot "n@node@_hbplot" ( v(a) i(pn a))
}


Solve {
  System("rm *n@node@_*_Fmag_des.plt    *n@node@_*_Fphase_des.plt")
  System("rm *n@node@_*_Fdomain_des.plt *n@node@_*_Tdomain_des.plt")
  System("rm *n@node@_*_Hdom_des.plt    *n@node@_*_Tdom_des.plt")
  
  Coupled { Poisson }
  Coupled { Poisson Electron Hole }
  Quasistationary (
    InitialStep=1e-3 Increment=1.5
    MaxStep=@<1.0/20>@ Minstep=1.e-8 
    Goal { Parameter=va."sine[0]" Voltage=@Vdc@ }
  )  
  {Coupled  { Poisson Electron Hole } }
  
  Quasistationary (
    InitialStep=1e-3 Increment=1.5
    MaxStep=@<1.0/25>@ Minstep=1.e-8 
    Goal {Parameter="va"."sine[1]"  Value=@mag@}
  )  
  { HBCoupled (
      Tone ( Frequency = "va"."sine[2]" NumberOfHarmonics = @NumHarm@ )
      Initialize = DCMode
      Method = ILS
      GMRES ( Tolerance = 1e-5 MaxIterations = 80 Restart = 20 )
      RhsMin= 5e-3
  ) { Poisson Electron Hole }
  }
  
}

