#define _STRESS_  1

#if "@Mode@" == "lin"
#define _Vd0_     0.05
#else 
#define _Vd0_     1.0
#endif
#define _Vgmin_  -0.15
#define _Vgmax_   1.15

*----------------------------------------------------------------------
Device MOS {
*----------------------------------------------------------------------
File {
	Grid=          "@Device@_fps.tdr"
#if _STRESS_
	Piezo=         "@Device@_fps.tdr"
#endif
	Parameter=     "@parameter@"
	Plot=          "@tdrdat@"
	Current=       "@plot@"
}

Electrode {
#if "@Device@" == "NMOS"
	{ Name="gate"      Voltage= 0.0 Workfunction= 4.205 }
#define _SIGN_  1.0
#define _QC_     eQuantumPotential
#define _CAR_    Electron
#elif "@Device@" == "PMOS"
	{ Name="gate"      Voltage= 0.0 Workfunction= 4.9 }
#define _SIGN_ -1.0
#define _QC_     hQuantumPotential
#define _CAR_    Hole
#endif
	{ Name="source"    Voltage= 0.0 }
	{ Name="drain"     Voltage= 0.0 }
	{ Name="substrate" Voltage= 0.0 }
}

Physics{
	Mobility(
		PhuMob
		HighFieldSaturation(GradQuasiFermi)
		Enormal( Lombardi(AutoOrientation) )
	)
	EffectiveIntrinsicDensity( BandGapNarrowing(OldSlotBoom) )
	Recombination( SRH(DopingDependence) )
#if _STRESS_
	Piezo(
		Model(
			DeformationPotential
			Mobility(
				eSubBand(Doping)
				hTensor(Kanda)
	)	)	)
#endif

	RandomizedVariation "rdf" ( Doping)
	RandomizedVariation "ift" ( TrapConcentration )
	RandomizedVariation "wfv" ( Workfunction(
		Surface = "Gate"
#if   "@Device@" == "NMOS"
		AverageGrainSize= 0.005
		GrainProbability= (0.5 0.3 0.2)
		GrainWorkfunction= (4.0 4.15 4.8)
#elif "@Device@" == "PMOS"
		AverageGrainSize= 0.005
		GrainProbability= (0.3 0.3 0.4)
		GrainWorkfunction= (4.75 4.85 5.05)
#endif
		))
	RandomizedVariation "tox" (
		Geometric ( 
			CorrelationFunction = Grain
			Surface= "Gate"
			AverageGrainSize= 0.015      * [um]
			Amplitude_Iso=    1e-3       * [um]
		)
	)
}

Physics (Material="Silicon") {
	_QC_
}

Physics (MaterialInterface="Silicon/Oxide") {
	Traps(
		(Donor    Conc= 3e11 Level
			EnergyMid= 0.25 fromConductionBand
			eXsection= 1e-10 hXsection= 1e-12
			SpaceMid= (0.0155,0.0645,0) SpaceSig=(0.0205,0.0115,1) SpatialShape= Uniform)
		(Acceptor Conc= 3e11 Level
			EnergyMid= 0.25 fromValenceBand
			eXsection= 1e-12 hXsection= 1e-10
			SpaceMid= (0.0155,0.0645,0) SpaceSig=(0.0205,0.0115,1) SpatialShape= Uniform)
	)
}

Plot{
	eDensity hDensity
	TotalCurrent/Vector * eCurrent/Vector hCurrent/Vector
	eMobility hMobility
	* eVelocity hVelocity
	eQuasiFermi hQuasiFermi
	* eTemperature Temperature hTemperature
	ElectricField/Vector Potential SpaceCharge
	Doping DonorConcentration AcceptorConcentration
	* ConductionBandEnergy
	* SRH Band2Band Auger
	* AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
	* eGradQuasiFermi/Vector hGradQuasiFermi/Vector
	* eEparallel hEparallel eENormal hENormal
	* BandGap BandGapNarrowing
	* Affinity
	* ConductionBand ValenceBand
	* eBarrierTunneling hBarrierTunneling BarrierTunneling
#if _STRESS_
	*--Stress related data
	StressXX StressYY StressZZ StressXY StressXZ StressYZ
	eMobilityStressFactorXX eMobilityStressFactorYY eMobilityStressFactorZZ
	eMobilityStressFactorXY eMobilityStressFactorXZ eMobilityStressFactorXY
	hMobilityStressFactorXX hMobilityStressFactorYY hMobilityStressFactorZZ
	hMobilityStressFactorYZ hMobilityStressFactorXZ hMobilityStressFactorXY
#endif
	eInterfaceTrappedCharge hInterfaceTrappedCharge
}

*----------------------------------------------------------------------
} * End of Device
*----------------------------------------------------------------------

File {
	Output=    "@log@"
	ACExtract= "@acplot@"
}

Math {
	Surface "Gate" ( Electrode = "gate")
	Extrapolate
	RelErrControl
	Digits= 5
	RHSmin= 1e-10
	Notdamped= 50
	Iterations= 20
	eDrForceRefDens= 1e12
	hDrForceRefDens= 1e12
	TensorGridAniso
	ExitOnFailure
	Number_Of_Threads= 4
	Wallclock
	Method= Blocked
	SubMethod= ILS
	ACMethod= Blocked
	ACSubMethod= ILS (Set=2)
	RandomizedVariation "rdf" (
			NumberOfSamples= @Nrand@
			Randomize= 46005
	)
	RandomizedVariation "wfv" (
			NumberOfSamples= @Nrand@
			Randomize= 71517
	)
	RandomizedVariation "ift" (
			NumberOfSamples= @Nrand@
			Randomize= 59448
	)
	RandomizedVariation "tox" (
			NumberOfSamples= @Nrand@
			Randomize= 64493
	)
}

System {
*- Voltage sources
	Vsource_pset vdrain  (ndrain  0) { dc= 0 }
	Vsource_pset vsource (nsource 0) { dc= 0 }
	Vsource_pset vgate   (ngate   0) { dc= 0 }

*- Physical devices
	MOS mos ( "drain"= ndrain  "source"= nsource "gate"= ngate "substrate"= 0)
	Plot "n@node@_mos_circuit" (v(ndrain) v(ngate) i(mos,ndrain) i(mos,nsource))
}

Solve {
	Coupled(Iterations= 100 LineSearchDamping= 1e-8){ Poisson _QC_}
	Coupled{ Poisson _CAR_ _QC_ }

	Quasistationary(
		InitialStep= 1e-3 Increment= 1.4
		MinStep= 1e-6 MaxStep= 0.25
		Goal { Parameter= vdrain.dc  Voltage= @<_SIGN_*_Vd0_>@ }
		Goal { Parameter= vgate.dc   Voltage= @<_SIGN_*_Vgmin_>@ }
	){ Coupled { Poisson _CAR_ _QC_} }

	NewCurrentPrefix="IV_"
	Quasistationary(
		DoZero
		InitialStep= 1e-3 Increment= 1.2
		MinStep= 1e-6 MaxStep= 0.1
		Goal { Parameter= vgate.dc  Voltage= @<_SIGN_*_Vgmax_>@ }
	){ ACCoupled (
			StartFrequency= 0 EndFrequency= 0
			-VoltageGreenFunctions
			NumberOfPoints= 1 Decade
			Node(ndrain ngate)
			ObservationNode(ndrain)
			Exclude(vdrain vgate)
			ACExtract= "n@node@_mos"
			ACcompute(   Time=(Range=(0 1) Intervals= 26) )
		){ Poisson _CAR_ _QC_ }
		CurrentPlot( Time=(Range=(0 1) Intervals= 26) )
	}
}

