File {
  Grid      = "@pwd@/pin.tdr"
  PMIUserFields = "fields.tdr"
  PMIPath       = "@pwd@"
  Plot      = "@tdrdat@"
  Current   = "@plot@"
  Output    = "@log@"
}

*-----------------------------------------------------------------------------*
Electrode {   
  { name="top"    voltage=0.0 }
  { name="bottom" voltage=0.0 }
}

Thermode {   
  { name="top"    temperature=320.0 }
  { name="bottom" temperature=300.0 }
}

*-----------------------------------------------------------------------------*
Plot {
  PMIUserField0
  PMIUserField197
  PMIUserField198
  PMIUserField199
  PMIUserField297
  PMIUserField298
  PMIUserField299
}

*-----------------------------------------------------------------------------*
Physics {
  AreaFactor = 1
  Thermodynamic
}

*-----------------------------------------------------------------------------*
Math {
  Transient=BE   * BE or TRBDF (default)
  Iterations = 8
}

*-----------------------------------------------------------------------------*
Solve{
  Coupled( PMI_NewtonStep(
    pmi_double_newtonstep(InfoLevel=1) 
  )) { Poisson }
  
  Plugin (Iterations=12) {
    Coupled { Poisson Electron Hole }
    Coupled( PMI_NewtonStep( 
      pmi_float_newtonstep(InfoLevel=2) 
    )) { Poisson Electron Hole Temperature }
  }
  
  Transient ( 
    InitialTime = 0.0 Finaltime = 1.0
    InitialStep = 1.0e-01 MinStep = 1.0e-09 MaxStep = 1.0e-01 
  ) {
    Coupled( PMI_NewtonStep( 
      pmi_double_newtonstep(InfoLevel=2) 
    ) ) { Poisson Electron Hole Temperature }
  }
  
  Quasistationary (
    InitialStep = 0.1 MinStep = 0.02 MaxStep = 0.1
    Decrement = 1.2 Increment = 1.5               
    Goal { Name="top"  voltage = 1 }
  ) {
    Coupled( PMI_NewtonStep( 
      pmi_float_newtonstep( InfoLevel=2  MaxIter = 3  MaxNewtonStep = 1.e-6 ) 
    )) { Poisson Electron Hole Temperature }
  }
}
