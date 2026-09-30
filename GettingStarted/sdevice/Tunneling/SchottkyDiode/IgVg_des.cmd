#define _g_c_ 2.1
#define _g_v_ 0.66
#define _mt_e_ 0.2
#define _mt_h_ 0.25

File {
	Grid= 			"@tdr@"
	Parameter= 		"@parameter@"
	
	Current= 		"@plot@"
	Plot= 			"@tdrdat@"
	Output=			"@log@"
	NonLocalPlot= "n@node@_nl"
} 

Electrode {
	{ Name= bot	Voltage= 0.0}
	{ Name= top  	Voltage= 0.0 Workfunction= @WF@ 
      #if "@ContactType@" == "schottky"
         Schottky
      #endif
      }
}

Physics { 
	# Latest set of calibrated parameters from the MaterialDB 
	DefaultParametersFromFile 
	
	Fermi
	
	Mobility (
		DopingDependence
		HighFieldSaturation
	)
    
	Recombination (
		SRH 
	)
	
	# Significant incomplete ionization of Mg in GaN
	IncompleteIonization
	
	# No data available on bandgap narrowing. Therefore, turn model off
	EffectiveIntrinsicDensity ( NoBandGapNarrowing )
	
	#if "@Tun@" == "eBarr"
	   eBarrierTunneling "NLM_Gate"
	#elif "@Tun@" == "eBarr_B2BFull"
	   eBarrierTunneling "NLM_Gate" (Band2Band=Full)
	#endif
}

Plot { 
	ElectricField/Vector 
	eMobility hMobility
	eCurrent/Vector hCurrent/Vector TotalCurrent/Vector CurrentPotential
	
	DopingConcentration DonorConcentration AcceptorConcentration
		
	SpaceCharge
	ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy
	EffectiveBandgap Affinity
	
	xMoleFraction

	eBarrierTunneling hBarrierTunneling eGapStatesRecombination hGapStatesRecombination
	SRH Radiative
	
	NonLocal

   eBand2BandGeneration hBand2BandGeneration
   Band2Band

}

NonLocalPlot ((0 0)) { 
       eDensity
       hDensity
       ConductionBandEnergy
       ValenceBandEnergy
       eQuasiFermiEnergy
       hQuasiFermiEnergy
       eBarrierTunneling
       hBarrierTunneling  
       ElectrostaticPotential
}

Math {
	Extrapolate
	ExtendedPrecision
	Iterations= 21
	RHSMax= 1e30
	
	# Recommended for simulations including anistropic models
	# Included for consistency with simulation of full p-gate HEMT simulations
	TensorGridAniso(Aniso)
	
	# Ensure solution is sufficiently precise
	# Inclusion of tunneling, sometimes, leads to convergence with err<1 but large RHS
	CheckRhsAfterUpdate
	RHSMin= 1e-3
	
	# Use the iterative solver ILS with set 11, appropriate for simulation of GaN-based devices
	# Using ILS allows for multy-threaded simulations
	# Included for consistency with simulation of full p-gate HEMT simulations
	Method= ILS(set= 11)
	ILSrc="
		set(11){
			iterative(gmres(100), tolrel=1e-12, tolunprec=1e-6, tolabs=0, maxit=200);
			preconditioning(ilut(5.0e-7,-1), right);
			ordering(symmetric=nd, nonsymmetric=mpsilst);
			options(compact=yes, linscale=0, refineresidual=10, verbose=0);
		};
	"
	Number_of_Threads= 4

	Transient= BE

	ErrRef(electron)= 1e8
	ErrRef(hole)= 1e8
	RefDens_eGradQuasiFermi_EParalleltoInterface= 1e8
	RefDens_hGradQuasiFermi_ElectricField= 1e8
	
	DirectCurrent

	# ElementEdge averaging is recommended in recent releases compared to the default "Element"
	eMobilityAveraging= ElementEdge
	hMobilityAveraging= ElementEdge
	
	# Forces S-Device to recompute DopingConcentration
	ComputeDopingConcentration
	
	# Non-local mesh
	NonLocal "NLM_Gate" (
		Electrode="top"
		Length= @Length@
		Digits= 4
	)

    -CheckUndefinedModels

	# Optional computation of simulation performance statistics
	# Data saved in the plt file along with other data such as terminal voltages, currents
	SimStats
}

Solve {
	# Solution at initial conditions
	Coupled(Iterations= 1000 LineSearchDamping= 1e-4){ Poisson }
	Coupled(Iterations= 100) { Poisson Electron Hole }

	# Save relevant data for the IdVg curve in a new file
	NewCurrentFile="IgVg_"
	
	Transient ( 
		# So displacement current is small enough
		InitialTime= 0 FinalTime= 10
		InitialStep= 0.01 MinStep= 1.0e-5 Maxstep= 0.01
		Goal { Name= top Voltage= +7.0 }
	) {                  
		Coupled { Poisson Electron Hole } 
		Plot(FilePrefix="n@node@_ss" Time=(Range=(0 10) Intervals= 7) NoOverwrite)
	}
}

