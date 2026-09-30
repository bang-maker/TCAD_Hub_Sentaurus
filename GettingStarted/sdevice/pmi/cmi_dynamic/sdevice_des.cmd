File {
  Output = "@log@"
  Current = "@plot@"
  CMIPath = "."
}

System {
  Vsource_pset vin (1 0) { sine = (0 10 @freq@ 0 0) }
  coupled_pset coupled_inst (2 0 3 0) { ind1 = @L1@  ind2 = @L2@  k = @k@ }
  Resistor_pset r12 (1 2) { resistance = 5 }
  Resistor_pset r30 (3 0) { resistance = 5meg }
  
  Plot "n@node@_des.plt" (time ()  v (1)  v (2)  v (3)  coupled_inst.i1)
}

Math {
  RhsMin = 1e-10
  SimStats
  CheckTransientError
  TransientDigits=4
}

Solve {
  
  Transient (InitialTime = 0.0  FinalTime = @<2./freq>@
    InitialStep = @<1./freq/256>@  MaxStep = @<1./freq/64>@
  ) {
    Coupled {Circuit}
    Currentplot ( Time = (range=(0 @<2./freq>@) intervals=128 ) )
  }
}