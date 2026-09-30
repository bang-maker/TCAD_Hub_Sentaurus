
File {
   Grid        = "@tdr@"
   Plot        = "@tdrdat@"
   Current     = "@plot@"
   Output      = "@log@"
   param       = "@parameter@"
}

Electrode {
   { name="top" voltage= 0.0 }
   { name="bottom"    voltage= 0.0 }
}

Physics {
   Polarization
}

Plot {
   Polarization/Vector
   ElectricField/Vector
   DisplacementCurrent
   ElectricField
}

Math {
   Extrapolate
   Digits = 5
   Notdamped=20
   Iterations=10
   Derivatives
   RelErrControl
}

Currentplot {
   Polarization/Vector (( 0 0 ))
   ElectricField/Vector (( 0 0 ))
}

Solve {
    *initial solution
    poisson

NewCurrentPrefix = "r1_"
  Transient(
     InitialTime=0 FinalTime=1
     InitialStep=1e-4 Increment=1.2
     MaxStep=1e-3 MinStep=1e-4
    Goal{ Name="top" Voltage=10  }
  ) { Coupled { Poisson } }
    Plot ( FilePrefix= "n@node@_r1" )

NewCurrentPrefix = "r2_"
  Transient(
     InitialTime=0 FinalTime=1
     InitialStep=1e-4 Increment=1.2
     MaxStep=1e-3 MinStep=1e-4
    Goal{ Name="top" Voltage=-10  }
  ) { Coupled { Poisson } }
    Plot ( FilePrefix= "n@node@_r2" )

NewCurrentPrefix = "r3_"
  Transient(
     InitialTime=0 FinalTime=1
     InitialStep=1e-4 Increment=1.2
     MaxStep=1e-3 MinStep=1e-4
    Goal{ Name="top" Voltage=10  }
  ) { Coupled { Poisson } }

}
