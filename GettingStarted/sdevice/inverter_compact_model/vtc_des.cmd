#setdep @node|SPtoSD@

File{
   Output = "@log@"
   SpicePath= "@pwd@/models"
}

System{
  Vsource_pset vdd (dd 0) { dc = 0.0 }
  Vsource_pset vin (in 0) { dc = 0.0 }
  Vsource_pset vss (ss 0) { dc = 0.0 }

  nmos_bsim3 mosn1 ( out  in  ss  ss ) { l=0.30u w=@wnmos@ } 
  pmos_bsim3 mosp1 ( out  in  dd  dd ) { l=0.25u w=@wpmos@ }

  Capacitor_pset cout ( out 0 ) { capacitance = 20e-15 }

  Plot "n@node@_sys_des.plt" (time() v(dd) v(in) v(out) 
                              i(mosn1,out) i(mosp1,out) i(cout,out) )
}


Solve{  
  NewCurrentPrefix="init_"
  Coupled{ Circuit }
  
  Quasistationary( 
     InitialStep=1e-3 Increment=1.35 
     MinStep=1e-5 MaxStep=0.05 
     Goal{ Parameter=vdd.dc Voltage= @vdd@ } 
  ){ Coupled{ circuit }
  }

  NewCurrentPrefix=""
  Quasistationary( 
     InitialStep=1e-3 Increment=1.35 
     MinStep=1e-5 MaxStep=0.01 
     Goal{ Parameter=vin.dc Voltage= @vin@ } 
  ){ Coupled{ circuit }
  }
  
}
