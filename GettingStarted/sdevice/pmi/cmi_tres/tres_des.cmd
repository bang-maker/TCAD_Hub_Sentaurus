File {
  Output = "tres"
  Current = "tres"
  CMIPath = "."
}

System {
  Thermal (tR t300)
  Set (t300 = 300)
  set (n0=0)
  Resistor_pset rt (t300 tR) {resistance = 1e3}
  Vsource_pset vin (n1 n0) { pwl = (0 0   1 1) }
  tres_pset tres (n1 n0 tR) { r=2 alpha=0.1 beta=0. tref=300}
  Plot "tres_des.plt" (time()  v(n0) v(n1) i(tres n0) t(tR) h(tres tR))
}

Solve {
  Transient (
    # InitialTime = 0.0  FinalTime = 1.0e-3
    # InitialStep = 4.0e-5  MaxStep = 4.0e-5
    InitialTime = 0     FinalTime = 1
    InitialStep = 0.02  MaxStep = 0.02  MinStep = 1e-6
  ) {
    Coupled {Circuit TCircuit}
    # Coupled {Circuit}
  }
}
