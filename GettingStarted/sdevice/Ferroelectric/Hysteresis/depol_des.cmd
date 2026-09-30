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
   { name="top"    voltage= 0.0 voltage = (-10 at 0, 8 at 0.1, -6 at 0.2, 5 at 0.3, 
      -4 at 0.4, 3 at 0.5, -2 at 0.6, 1 at 0.7, -0.5 at 0.8, 0.25 at 0.9, -0.1 at 1) }
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

   NewCurrentPrefix="trans_"
   Transient (
     InitialTime=0 FinalTime=1
     InitialStep=1e-4 Increment=1.2
     MaxStep=1e-3 MinStep=1e-4
   ){ Coupled{ circuit contact poisson } }

   Plot ( FilePrefix= "n@node@_trans" )
}
