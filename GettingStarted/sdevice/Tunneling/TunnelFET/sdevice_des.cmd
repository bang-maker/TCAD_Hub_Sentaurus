
Electrode {
	{ Name= "source"    Voltage= 0.0  }
	{ Name= "drain"     Voltage= 0.0  }
	{ Name= "gate"      Voltage= 0.0 Workfunction= 4.3}
}

File {
	Grid= 		"@tdr@"
	Parameter=	"@parameter@"
	
	Current= 	"@plot@"
	Plot= 		"@tdrdat@"
	Output= 	"@log@"
	
}

Physics {
	Temperature= 300
   Fermi
	EffectiveIntrinsicDensity(NoBandGapNarrowing)
	Recombination (
		SRH(DopingDependence)
      #if "@model@" != "-" 
      Band2Band(Model=@model@)
      #endif
	)
}

Plot {
   DopingConcentration
	ElectricField/Vector	
	ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy
	eGradQuasiFermi hGradQuasiFermi	
	eBarrierTunneling hBarrierTunneling
	SRH Avalanche	
	NonLocal
   eBand2BandGeneration hBand2BandGeneration
   Band2Band
}

Math {
	Extrapolate
	Iterations= 16
	RHSMin= 1e-8
	ExtendedPrecision(128)
	Digits= 10
	-CheckUndefinedModels
}


Solve {
	NewCurrentFile="n@node@_init_"
	Coupled (Iterations= 10000)  {Poisson}
	Coupled (Iterations= 10000)  {Poisson Electron Hole}

	Plot(FilePrefix="n@node@_Zero")

	QuasiStationary(
	    InitialStep= 0.1 MinStep= 1e-4
	    Goal{Name="drain" Voltage=1}
	){
	    Coupled{Poisson Electron Hole}
	}

	Plot(FilePrefix="n@node@_drain")

	NewCurrentFile= ""
	QuasiStationary(
	    DoZero
	    InitialStep= 0.01 MinStep= 1e-4
	    Goal{Name="gate" Voltage= 3}
	){
	    Coupled{Poisson Electron Hole}
	    CurrentPlot(Time=(Range=(0 1) Intervals= 200))
	    ##Plot(FilePrefix="n@node@_ss" NoOverwrite Time=(0.0;0.2;0.4;0.6;0.8))
	}
}
