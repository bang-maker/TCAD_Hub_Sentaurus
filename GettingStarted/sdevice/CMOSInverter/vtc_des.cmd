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
  Vsource_pset vin (in 0) { dc = 0.0 }

  NMOS nmos1 ( "source"=0  "drain"=out "gate"=in "substrate"=0 )
  PMOS pmos1 ( "source"=dd "drain"=out "gate"=in "substrate"=dd )  
  Capacitor_pset cout ( out 0 ){ capacitance = 3e-14 }

  Plot "n@node@_sys_des.plt" (time() v(in) v(out) 
                              i(nmos1,out) i(pmos1,out) i(cout,out) )
}

Solve{  
  NewCurrentPrefix="init"
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
  Quasistationary( 
     InitialStep=1e-3 Increment=1.35 
     MinStep=1e-5 MaxStep=0.01 
     Goal{ Parameter=vin.dc Voltage= 1.5 } 
  ){ Coupled{ nmos1.poisson nmos1.electron nmos1.hole nmos1.contact 
              pmos1.poisson pmos1.electron pmos1.hole pmos1.contact
              circuit }
  }
}

