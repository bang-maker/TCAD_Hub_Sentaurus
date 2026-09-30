# CMOS inverter (with very long L)
# Test for HSpice BSIM4 MOS Level 54
# Level 53 is supposed to be equivalent to BSIM4

File {
  Output = "@log@"
  Current = "@plot@"
  SPICEPath = "@[relpath n@node@]@"
}

System {
  Vsource_pset Vdd (3 0) { dc = 5 }
  Vsource_pset Vin (2 0) { pwl = (0.0e+00 0.0
                                  3.0e-9 0.0
                                  3.1e-9 5.0
                                  6.1e-9 5.0
                                  6.2e-9 0.0
                                  9.2e-9 0.0

        )}

#  RESDUM Rdummy( "Anode"=1 "Cathode"=2)
  Capacitor_pset CL (4 0) { capacitance = 2e-15}
  PMOS_comp_pset PMOS1   (4 2 3 3)    { w=1.8e-6 l=0.6e-6 }
  NMOS_comp_pset NMOS1   (4 2 0 0)    { w=0.9e-6 l=0.6e-6 }

  Initialize( 2=0 4=4.8)
  plot "n@node@_des.plt" (time()  v(2)  v(4))
}

Math {
  Iterations = 40
}

Solve {

  Coupled { Poisson }
  Coupled { Poisson Electron Hole }
  Coupled { Poisson Electron Hole Contact Circuit }

  Transient (InitialTime = 0  FinalTime = 9e-9
             InitialStep = 1e-13  MaxStep = 0.1e-10
             Increment = 3  Decrement = 3) { 
    Coupled {Circuit }
  } 
}
