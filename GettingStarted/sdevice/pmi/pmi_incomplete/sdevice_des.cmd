File {
  Grid       = "@pwd@/SiC_resistor.tdr"
  Parameters = "@parameter@"
  Output     = "@log@"
  Current    = "@plot@"
  Plot       = "@tdrdat@"
  PMIPath    = "@pwd@"
}

Electrode {
  { name = "Contact_0" voltage=0 }
  { name = "Contact_1" voltage=0 }
}

Plot {
  AlDoping AlMinusDoping
  LatticeTemperature
  Doping AcceptorConcentration DonorConcentration
  AccepMinusConcentration
}

CurrentPlot {
  LatticeTemperature ((0.5 0.5))
  AlDoping ((0.5 0.5))
  AlMinusDoping((0.5 0.5))
}

Physics {
  IncompleteIonization( 
    Model( pmi_incomplete("AlDoping") )
  )
}

Math {
  -ExtendedPrecision
}

Solve {
  Coupled {poisson}
  Quasistationary (
    InitialStep= 1e-2 Increment= 1.5 
    MinStep= 1e-5 MaxStep= 0.1
    Goal { Model="DeviceTemperature" Parameter="Temperature" Value= 400}
  ) { Coupled { poisson electron hole } }
}
