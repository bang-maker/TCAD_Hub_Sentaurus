#setdep @previous@

Device "MOS" {
  File {
    Grid                 = "@tdr@"
    Plot(Collected)      = "@tdrdat@"
    Parameter            = "@parameter@"
    Current              = "@plot@"
    * Note: No "Output=" here!
  }
  
  Electrode {
    { Name="source"    Voltage=0.0 }
    { Name="drain"     Voltage=0.0 }
    { Name="gate"      Voltage=-1.0 }
    { Name="substrate" Voltage=0.0 }
  }
  
  Physics {
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
} * End of Device{}

* Other devices
#Device [device2]{
#  *... 
#} *End of Device{} 

Plot {
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
  Transient=BE
  Method=Blocked
  SubMethod=ParDiSo
  ExitOnFailure
}

File {
  Output    = "@log@"
}

System { *contains the netlist
  *-Physical devices:
  MOS nmos1 ( "source"=dd  "drain"=out "gate"=in "substrate"=0 )
  
  *-Lumped elements:
  Vsource_pset vdd (dd 0) { dc = 1.1 }
  Vsource_pset vin (in 0) { 
    pulse = (0.0       # dc
      1.5       # amplitude
      10e-11    # td
      10e-11    # tr
      10e-11    # tf
      60e-11    # ton
    140e-11)   # period 
  }
  Capacitor_pset cout ( out 0 ){ capacitance = 3e-14 }
  
  *-Plot:
  Plot "n@node@_sys_des.plt" (time() v(in) v(out) 
  i(nmos1,out) i(cout,out) )
}

Solve {
  Coupled(Iterations=100){ Poisson }
  Transient (
    InitialTime=0 FinalTime=100e-11
    InitialStep=1e-11 Increment=1.3
    MaxStep=5e-11 MinStep=1e-15
  ){ 
    Coupled { nmos1.poisson nmos1.electron nmos1.hole nmos1.contact circuit }
    CurrentPlot(Time = (Range = (0 100e-11)  Intervals = 40)) 
    Plot(FilePrefix= "n@node@" Time = (Range = (0 100e-11)  Intervals = 10)) 
  }
}
