#setdep @node|nmos@ @node|pmos@
Device nmos {

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
  }

  Physics{
    Fermi
    DefaultParametersFromFile
    Mobility( DopingDep HighFieldSaturation Enormal )
    EffectiveIntrinsicDensity( oldSlotboom )
  }

}

Device pmos{
  
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
  }
    
  Physics{
    Fermi
    DefaultParametersFromFile
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
    eMobility hMobility
    DonorConcentration AcceptorConcentration
    Doping
}

Math{
  NumberOfThreads= 4
  Extrapolate
  Notdamped=50
  Iterations=12
  Method=Blocked
  SubMethod=ParDiSo
  Transient= BE
}


File{
   Output = "@log@"
}

System{
  
  Netlist = "@pwd@/stages.cir"
  nmos "x1.m1" ( "source"=gnd  "drain"=2 "gate"=1 "substrate"=gnd ) 
               { Physics {AreaFactor= 0.2} }
  pmos "x1.m2" ( "source"=nvd  "drain"=2 "gate"=1 "substrate"=nvd ) 
               { Physics {AreaFactor= 0.3} }
  Capacitor_pset C1 ( 2 gnd ){ capacitance = 1e-15 }
  Vsource_pset vdd (nvd gnd) { dc =0 }

  initialize ( 1=@<vdd/2>@ 2=@<vdd/2>@ 3=@<vdd/2>@ 4=@<vdd/2>@ 5=@<vdd/2>@ )
  Plot "n@node@_sys_des.plt" (time() v(nvd) v(1) v(2) v(3) v(4) v(5)
                              i(vdd,nvd) 
                              i("x1.m1",2) i("x1.m2",2)
                              i("x2.m1",3) i("x2.m2",3)
                              i("x3.m1",4) i("x3.m2",4)
                              i("x4.m1",5) i("x4.m2",5)
                              i("x5.m1",1) i("x5.m2",1)
                             )
  set(gnd=0)
}


Solve{  
  NewCurrentPrefix="init_"	
  Coupled { Poisson circuit }
  Quasistationary ( 
		InitialStep= 1e-2 Increment= 1.41
		MinStep= 1e-7     MaxStep= 0.2
		Goal { parameter= vdd.dc Voltage= @vdd@ }
	){ Coupled { Poisson Electron Hole circuit} 
	}
  
  NewCurrentPrefix=""
  Transient( 
     InitialTime=0.0 FinalTime= 1e-9
     InitialStep=5e-13 Increment=1.35 
     MinStep=1e-13 MaxStep=2e-12
  ){ Coupled{ poisson electron hole circuit }
  }
 System("rm init_*.plt") 
}

