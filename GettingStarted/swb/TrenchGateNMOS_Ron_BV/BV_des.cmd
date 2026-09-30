## Tool: Sentaurus Device 
## Characteristics: Breakdown voltage
## Dependency: Should be run after the process simulation of NMOS device
#setdep @node|DevMesh@
#if @< [string compare SBD NO] == 0 && [string compare SIM IV] == 0 >@
#noexec
#endif


File {
	grid      = "@[relpath n@node|DevMesh@_final_fps.tdr]@"
	current   = "@plot@"
	output    = "@log@"
	plot      = "@tdrdat@"
	parameter = "@parameter@"
}

Electrode {
	{ name="drain" voltage=0.0 resistance= 1.0e13  }
	#if @<[string compare SBD "YES"] == 0>@
	{ Name="source" Schottky Workfunction= @phin@ Voltage= 0.0 }
	#else
	{ Name="source" Voltage= 0.0 }
	#endif
	## -- { Name="gate" Voltage= 0.0 Material= "PolySi"}
	{ Name="gate" Voltage= 0.0 }
}

Thermode{
	{ Name="drain" Temperature= @Tamb@ SurfaceResistance= @ThermalR@ } 
	{ Name="source"   Temperature= @Tamb@ SurfaceResistance= @ThermalR@ } 
	{ Name="gate"      Temperature= @Tamb@ SurfaceResistance= @ThermalR@ }  
}

## Physics models
Physics {
	AreaFactor  = @AF@
	Temperature = @Tamb@
	Mobility(
		PhuMob Enormal
		HighFieldSaturation(EparallelToInterface)
	)
	Recombination(
		SRH( DopingDep TempDependence)	
		Auger
		Avalanche(GradQuasiFermi)
	)
	EffectiveIntrinsicDensity( OldSlotboom )
}

Physics (MaterialInterface="Oxide/Silicon") {
	Traps(FixedCharge Conc= 0.0)
}

Plot{
   eDensity hDensity
   TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
   eMobility hMobility
   eVelocity hVelocity
   eQuasiFermi hQuasiFermi 
   Temperature
   eTemperature  hTemperature
   ElectricField/Vector Potential SpaceCharge
   Doping DonorConcentration AcceptorConcentration
   SRH Auger Band2Band  
   ImpactIonization eImpactIonization hImpactIonization
   eGradQuasiFermi/Vector hGradQuasiFermi/Vector
   eEparallel hEparallel eENormal hENormal
   BandGapNarrowing
}

Math {
	Extrapolate
	Notdamped= 50
	Iterations= 15		
	Digits           = 5   
	ErrRef(electron) = @<1e-1*ni>@
	ErrRef(hole)     = @<1e-1*ni>@
	RHSmin= 1e-20
	RefDens_eGradQuasiFermi_EParallelToInterface= 1.0e12
	RefDens_hGradQuasiFermi_EParallelToInterface= 1.0e12
	Number_of_threads= 2
	## For Schottky contact
	#if @<[string compare SBD "YES"] == 0>@
		NonLocal "NLM" (
		Electrode= "source"
		Length= 1e-6
		Digits= 4
		EnergyResolution= 0.001
		)
	#endif
}
Solve {
	
	## Initial Solution
	Coupled { Poisson }
	Coupled(Iterations=100 LineSearchDamping=1e-4){ Poisson Electron } 
	Coupled {Poisson Electron Hole}     
	
	NewCurrentPrefix="BV_" 
	
	## Ramp drain voltage until the device drain current exceeds 100 uA  
	Quasistationary( 
	InitialStep= 1e-4 MinStep= 1e-15 MaxStep= 0.01
	Increment= 3.0 Decrement= 5.0
 	Goal { Name="drain" Voltage= 1.0e4 } 
	BreakCriteria {Current (Contact="drain" Absval= 100.0e-6 ) } 	      
	){ Coupled { Poisson Electron Hole } }   	   
	
}




