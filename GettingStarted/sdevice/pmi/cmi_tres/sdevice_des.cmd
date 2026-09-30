File {
  Output = "@log@"
  CMIPath = "."
}

System {
  Thermal (tR t300)
  Set (t300 = 300)
  set (n0=0)
  Resistor_pset rt (t300 tR) {resistance = 1e3}
  Vsource_pset vin (n1 n0) { pwl = (0 0   1 0.1) }
  tres_pset tres (n1 n0 tR) { r=2 alpha=@alpha@ beta=0. tref=300}
  Plot "@plot@" (time()  v(n0) v(n1) i(tres n0) t(tR) h(tres tR))
}

Solve {
  Transient (
    InitialTime = 0     FinalTime = 1
    InitialStep = 0.01  MaxStep = 0.01  MinStep = 1e-6
  ) {
    Coupled {Circuit TCircuit}
  }
}
