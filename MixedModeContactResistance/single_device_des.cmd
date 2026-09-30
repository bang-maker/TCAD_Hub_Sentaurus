#seth maxV 1.0

File {
   * input files:
   Grid=   "@tdr@"
   * output files:
   Plot=   "@tdrdat@"
   Current="@plot@"
   Output= "@log@"
}

Electrode {
   { Name="C1"	Voltage= 0.0 }
   { Name="C2"	Voltage= 0.0 }
}

Physics{
	AreaFactor=@areafactor@
	EffectiveIntrinsicDensity( OldSlotboom )
	Mobility (Phumob(Phosphorus))
	Recombination( SRH( DopingDependence ) )           
}

Math { 
   Extrapolate
   Iterations= 20
   ExitOnFailure
}

Solve {
*- Creating initial guess:
   Coupled(Iterations= 100){ Poisson } 
   Coupled {Poisson Electron Hole}

   Quasistationary( 
      InitialStep= 0.01 Increment= 1.5 
      MinStep= 1e-5 MaxStep= 0.5
      Goal { Name="C2" Voltage= @maxV@ } 
   ){ Coupled {Poisson Electron Hole} }
}

