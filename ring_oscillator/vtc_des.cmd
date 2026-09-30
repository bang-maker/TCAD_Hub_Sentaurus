File{
   Output = "@log@"
}

System{
  Netlist = "./stages.cir"
  Vsource_pset vdd (nvd 0) { dc = @vdd@ }

  initialize ( 1=0 2=@vdd@ 3=@vdd@ 4=@vdd@ 5=0 )
  Plot "n@node@_sys_des.plt" (time() v(nvd) v(1) v(2) v(3) v(4) v(5)
                              i(vdd,nvd) 
                              i("x1.m1",2) i("x1.m2",2)
                              i("x2.m1",3) i("x2.m2",3)
                              i("x3.m1",4) i("x3.m2",4)
                              i("x4.m1",5) i("x4.m2",5)
                              i("x5.m1",1) i("x5.m2",1)
                             )
}


Solve{  
  NewCurrentPrefix="init_"
  Coupled{ Circuit }
  
  NewCurrentPrefix=""
  Transient( 
     InitialTime=0.0 FinalTime= 1e-9
     InitialStep=1e-12 Increment=1.35 
     MinStep=0.5e-12 MaxStep=1e-11
  ){ Coupled{ circuit }
  }
 System("rm init_*.plt") 
}

Math {
	CheckTransientError
	TransientError= 1e-5
}
