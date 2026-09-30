Device NMOS {

  Electrode{
    { Name="source"    Voltage=0.0 }
    { Name="drain"     Voltage=0.0 }
    { Name="gate"      Voltage=0.0 }
    { Name="substrate" Voltage=0.0 }
  }

  File{
     Grid    = "@tdr|nmos@" 
     Plot    = "@tdrdat@"
     Current = "@plot@"
     Param   = "@parameter@"
  }

  Physics{
    AreaFactor=5
    Mobility( DopingDep HighFieldSaturation Enormal )
    EffectiveIntrinsicDensity( oldSlotboom )
  }

}

Device PMOS{
  
  Electrode{
    { Name="source"    Voltage=0.0 }
    { Name="drain"     Voltage=0.0 }
    { Name="gate"      Voltage=0.0 } 
    { Name="substrate" Voltage=0.0 }
  }

  File{
     Grid    = "@tdr|pmos@"
     Plot    = "@tdrdat@"
     Current = "@plot@"
     Param   = "@parameter@"
  }
    
  Physics{
    AreaFactor=10
    Mobility( DopingDep HighFieldSaturation Enormal )
    EffectiveIntrinsicDensity( oldSlotboom )
  }

}

File{
   Output = "@log@"
}

Plot{
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
}

Math{
  Extrapolate
  RelErrControl
  Digits=4
  Notdamped=50
  Iterations=12
  Transient=BE
  Method=Blocked
  SubMethod=ParDiSo
}

System{
  Vsource_pset vdd (dd 0) { dc = 0.0 }
  Vsource_pset vin (in 0) { 
    pulse = (0.0       # dc
             1.5       # amplitude
             10e-12    # td
             10e-12    # tr
             10e-12    # tf
             60e-12    # ton
            140e-12)   # period 
  }

  NMOS nmos1 ( "source"=0  "drain"=out "gate"=in "substrate"=0 )
  PMOS pmos1 ( "source"=dd "drain"=out "gate"=in "substrate"=dd )  
  Capacitor_pset cout ( out 0 ){ capacitance = 3e-14 }

  Plot "n@node@_sys_des.plt" (time() v(in) v(out) 
                              i(nmos1,out) i(pmos1,out) i(cout,out) )
}

Solve{  
  NewCurrentPrefix="init_"
  Coupled(Iterations=100){ Poisson }
  Coupled{ Poisson Electron Hole Contact Circuit }

  Quasistationary( 
     InitialStep=1e-3 Increment=1.35 
     MinStep=1e-5 MaxStep=0.05 
     Goal{ Parameter=vdd.dc Voltage= 1.5 } 
  ){ Coupled{ nmos1.poisson nmos1.electron nmos1.hole nmos1.contact 
              pmos1.poisson pmos1.electron pmos1.hole pmos1.contact
              circuit }
  }

  NewCurrentPrefix=""
  Transient (
     InitialTime=0 FinalTime=200e-12
     InitialStep=1e-12 Increment=1.3
     MaxStep=5e-12 MinStep=1e-15
     TurningPoints (
     	 ( Condition ( Time ( 1e-11 ; 8e-11 ; 1.5e-10 ) ) Value= 3.0e-13 )
     	 ( Condition ( Time ( Range= ( 1e-11 2e-11 ) ; Range= ( 8e-11 9e-11 ) ; 
     	 	Range= ( 1.5e-10 1.6e-10 ) ) ) Value= 1.0e-12 )
     )
  ){ Coupled{ nmos1.poisson nmos1.electron nmos1.hole nmos1.contact 
              pmos1.poisson pmos1.electron pmos1.hole pmos1.contact
              circuit }
  }
}


