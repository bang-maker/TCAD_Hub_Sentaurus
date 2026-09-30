Electrode {
	{ Name= "source"    Voltage= 0.0  }
	{ Name= "drain"     Voltage= 0.0  }
	{ Name= "gate"      Voltage= 0.0 Workfunction= _WF}
	{ Name= "Substrate" Voltage= 0.0 }
}



#if "@CUT@" == "SIM2N"
Physics (Material="Silicon") {
	_QP
	Mobility (
		Enormal (
			IALMob(AutoOrientation)
			RPS     # Used for remote phonon scattering (RPS)
			NegInterfaceCharge (SurfaceName="s1")  # Used for remote Coulomb scattering (RCS) and remote dipole scattering (RDS)
			PosInterfaceCharge (SurfaceName="s1")  # Used for RCS and RDS
		)
		HighFieldSaturation
	)

	EffectiveIntrinsicDensity(OldSlotboom)
	Recombination(SRH
      #if @GIDL@ 
      Band2Band(Model=@model@)
      #endif
      )
	eMultivalley(MLDA kpDOS -density)

	Piezo ( Model (
		Mobility (
			saturationfactor=0.2
			eSubband(Doping EffectiveMass Scattering(MLDA) -RelChDir110)
		)
		DOS(eMass hMass)
		DeformationPotential(Minimum ekp hkp)
	) )
}
#else
Physics (Material="SiliconGermanium") {
	_QP
	Mobility (
		Enormal (
			IALMob(AutoOrientation PhononCombination=2)
			RPS     # Used for remote phonon scattering (RPS)
			NegInterfaceCharge (SurfaceName="s1")  # Used for remote Coulomb scattering (RCS) and remote dipole scattering (RDS)
			PosInterfaceCharge (SurfaceName="s1")  # Used for RCS and RDS
		)
		HighFieldSaturation
	)

	EffectiveIntrinsicDensity(OldSlotboom NoFermi)
	Recombination(SRH)
	hMultivalley(MLDA kpDOS -density)
	
	Piezo (Model (
		Mobility (
			saturationfactor=0.2
			hSubband(Doping EffectiveMass Scattering(MLDA) -RelChDir110)
		)
		DOS(eMass hMass)
		DeformationPotential(Minimum ekp hkp)
	) )
}
#endif

Plot{
	eDensity hDensity
	TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
	eMobility hMobility
	eVelocity hVelocity
	eQuasiFermi hQuasiFermi
	eTemperature hTemperature Temperature
	ElectricField/Vector Potential SpaceCharge
	Doping DonorConcentration AcceptorConcentration
	SRH
	eGradQuasiFermi/Vector hGradQuasiFermi/Vector
	eEparallel hEparallel eENormal hENormal
	BandGap
	 "eQDDGamma"
    "hQDDGamma"
    eRelativeEffectiveMass
    hRelativeEffectiveMass
    StrainedDOSeMassFactor
    StrainedDOShMassFactor

	ElectronAffinity
    EffectiveBandGap
    eEffectiveStateDensity
    hEffectiveStateDensity
    DielectricConstant/Element
	BandGapNarrowing
	Affinity
	ConductionBand ValenceBand
	*--Stress related data
	StressXX StressYY StressZZ StressXY StressXZ StressYZ
	eMobilityStressFactorXX eMobilityStressFactorYY eMobilityStressFactorZZ
	eMobilityStressFactorXY eMobilityStressFactorXZ eMobilityStressFactorXY
	hMobilityStressFactorXX hMobilityStressFactorYY hMobilityStressFactorZZ
	hMobilityStressFactorYZ hMobilityStressFactorXZ hMobilityStressFactorXY

   eBand2BandGeneration hBand2BandGeneration
   Band2Band

}

