#setdep @node|SPtoSD@


File{
   Output = "@log@"
   SpicePath= "@pwd@/models"
}

System{
  Vsource_pset vdd (dd 0) { dc = 0.0 }
  Vsource_pset vin (in 0) { 
    pulse = (0.0       # dc
             @vin@       # amplitude
             10e-12    # td
             10e-12    # tr
             10e-12    # tf
             60e-12    # ton
            140e-12)   # period 
  }
  Vsource_pset vss (ss 0) { dc = 0.0 }

  nmos_bsim3 nmos1 ( out  in  ss  ss ) { l=0.30u w=@wnmos@ } 
  pmos_bsim3 pmos1 ( out  in  dd  dd ) { l=0.25u w=@wpmos@ }

  Capacitor_pset cout ( out 0 ) { capacitance = 20e-15 }

  Plot "n@node@_sys_des.plt" (time() v(dd) v(in) v(out) 
                              i(nmos1,out) i(pmos1,out) i(cout,out) )
}



Solve{  
  NewCurrentPrefix="init"
  Coupled{ Circuit }

  Quasistationary( 
     InitialStep=1e-3 Increment=1.35 
     MinStep=1e-5 MaxStep=0.05 
     Goal{ Parameter=vdd.dc Voltage= @vdd@ }
     Goal{ Parameter=vin.dc Voltage= 0.0 } 
  ){ Coupled{ circuit }
  }

  NewCurrentPrefix=""
  Transient (
     InitialTime=0 FinalTime=200e-12
     InitialStep=1e-12 Increment=1.3
     MaxStep=1e-12 MinStep=1e-15
  ){ Coupled{ circuit }
  }
}
