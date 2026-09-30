#define RAMPTO Quasistationary(MaxStep=0.01 MinStep=1e-5 InitialStep=1e-4 Goal{name =top voltage=
#define VOLTS }){coupled { circuit contact poisson} }

File {
   Grid        = "@tdr@"
   Plot        = "@tdrdat@"
   Current     = "@plot@"
   Output      = "@log@"
   param       = "@parameter@"
}

Electrode {
   { name="top"    voltage= 0.0 voltage = (-10 at 0, 10 at 0.1, -10 at 0.2, 
	   4 at 0.3, -3 at 0.4, 6.5 at 0.5) }
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
   RAMPTO  -10.0 VOLTS

  NewCurrentPrefix="trans1_"
  Transient (
     InitialTime=0 FinalTime=0.2
     InitialStep=1e-4 Increment=1.2
     MaxStep=1e-3 MinStep=1e-4
  ){ Coupled{ circuit contact poisson }
  }

  NewCurrentPrefix="trans2_"
  Transient (
     InitialTime=0.2 FinalTime=0.5
     InitialStep=1e-4 Increment=1.2
     MaxStep=1e-3 MinStep=1e-4
  ){ Coupled{ circuit contact poisson }
  }

}
