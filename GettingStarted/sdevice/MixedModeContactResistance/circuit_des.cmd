
File {
   Output= "@log@"
}

Device RR {

File {
   * input files:
   Grid=   "@tdr@"
   * output files:
   Plot=   "@tdrdat@"
   Current="@plot@"
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

}

System {
	RR 	R1 (C1=0 C2=1)
	Vsource_pset 	Vin (1 0) 	{dc=0 }
}

Math { 
   Extrapolate
   Iterations= 20
   ExitOnFailure
   MixedModeContactResistance=@MMCR@
}

Solve {
   Coupled(Iterations= 100){ Poisson } 
   Coupled {Poisson Electron Hole}

   Quasistationary( 
      InitialStep= 0.01 Increment= 1.5 
      MinStep= 1e-5 MaxStep= 0.5
      Goal { Parameter=Vin."dc" Value= @maxV@ } 
   ){ Coupled {Poisson Electron Hole} }
}

