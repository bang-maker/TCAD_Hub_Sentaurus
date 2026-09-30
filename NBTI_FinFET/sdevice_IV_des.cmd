#setdep @node|HCD@

#if "@Type@" == "nMOS"
#define _EQS_ Poisson  eQuantumPotential  Electron
#define _SHE_ eSHEDistribution
#define _QC_      eQuantumPotential
#define _InterfaceCh_ eInterfaceTrappedCharge
#define _CHARGE_  -1
#define _TRAP_  Acceptor
#define _CHM_ Silicon
#define _VD_   @<_CHARGE_ * -0.05>@
#define _VG_   @<_CHARGE_ * -0.9>@
#elif "@Type@" == "pMOS"
#define _EQS_ Poisson  hQuantumPotential  Hole 
#define _SHE_ hSHEDistribution
#define _QC_      hQuantumPotential
#define _InterfaceCh_ hInterfaceTrappedCharge
#define _CHARGE_  1
#define _TRAP_  Donor
#define _CHM_ SiliconGermanium
#define _VD_   @<_CHARGE_ * -0.05>@
#define _VG_   @<_CHARGE_ * -0.9>@
#endif



set i 0
for {set j 0} {$j < 7} {incr j} {
	if {$j<10} {
		set TDR "n@node|HCD@_HCD_Str_000${j}_des.tdr"
	} else {
		set TDR "n@node|HCD@_HCD_Str_00${j}_des.tdr"
}
	
	
sdevice "

File {
		Grid    = 	\"n@node|sprocess@_e_fps.tdr\"	
     	Plot    = 	\"n@node@_${i}_des.tdr\"
     	Current = 	\"n@node@_${i}_des.plt\"
     	Output	= 	\"n@node@_${i}_des.log\"
     	Param   = 	\"@parameter@\"
     	PMIPath	=	\".\"
     	PMIUserFields = \"${TDR}\"

}

Plot {
		eDensity hDensity
		eCurrent hCurrent
    	eTemperature hTemperature
    	ElectricField
    	InsulatorElectricField
    	SemiconductorElectricField    
    	ElectricField/vector
    	InsulatorElectricField/vector   
    	eEnormal hEnormal   
    	eQuasiFermi hQuasiFermi
    	Potential Doping SpaceCharge
    	SRH Auger 
    	AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
    	eMobility hMobility
    	DonorConcentration AcceptorConcentration
    	Doping
    	eVelocity hVelocity
    	eEparal hEparal
    	eTrappedCharge hTrappedCharge
    	Fowler
    	eInterfaceTrappedCharge hInterfaceTrappedCharge
    	OneOverDegradationTime
    	TotalInterfaceTrapConcentration
    	HydrogenAtom
    	HydrogenMolecule
    	HydrogenIon 
    	MSConfig
    	PMIUserField0
    	PMIUserField1
    	PMIUserField2
    	hSHEDensity eSHEDensity
    	hSHEEnergy  eSHEEnergy
    	hSHEVelocity eSHEVelocity
}


CurrentPlot {
		_InterfaceCh_(Maximum(RegionInterface = \"ChFin/Gateoxide1\"))
    	_InterfaceCh_(Average(RegionInterface = \"ChFin/Gateoxide1\"))
    	_InterfaceCh_(Minimum(RegionInterface = \"ChFin/Gateoxide1\"))
    	_InterfaceCh_(Maximum( RegionInterface = \"Gateoxide1/Gateoxide2\"))
    	_InterfaceCh_(Average( RegionInterface = \"Gateoxide1/Gateoxide2\"))
    	_InterfaceCh_(Minimum( RegionInterface = \"Gateoxide1/Gateoxide2\"))
}
      
   
Electrode {
  		{ name=\"gate\" 		voltage=0 	}
  		{ name=\"substrate\" 	voltage=0 	}	
  		{ name=\"source\" 		voltage=0 	}
  		{ name=\"drain\" 		voltage=0 	}	
}


Physics{
	DefaultParametersFromFile
	Temperature=298
##  Thermodynamic
    	_SHE_(FullBand)   
}

Physics(Material=\"_CHM_\"){
  	_QC_  
	Fermi
    EffectiveIntrinsicDensity( OldSlotboom )
    Mobility(
       PhuMob
       HighFieldSaturation
       Enormal
	)
   	Recombination(
       SRH( DopingDep )
	) 
}


Physics(RegionInterface = \"ChFin/Gateoxide1\"){
	Traps((_TRAP_  Uniform EnergyMid=0 fromMidBandGap EnergySig=1.12 SFactor= \"PMIUserField0\"))
}

Physics(RegionInterface = \"Gateoxide1/Gateoxide2\"){
	Traps((FixedCharge SFactor= \"PMIUserField1\"))
}



Math {
		NumberOfThreads    = 8
    	Digits=4
    	ErrRef(electron)=1.e10
    	ErrRef(hole)=1.e10
    	Notdamped=50
    	Iterations=10   
    	Transient=BE
    	ExitOnFailure
    	ExtendedPrecision
    	-CheckUndefinedModels
    	SHEIterations=25
    	Method=ILS
    	RefDens_eGradQuasiFermi_ElectricField_HFS= 1e12
    	RefDens_hGradQuasiFermi_ElectricField_HFS= 1e12      
}   



Solve {
		Set(_SHE_ (Frozen)) 	
		NewCurrentFile=\" \"  
		Coupled(Iterations=100 LineSearchDamping=1e-4){ Poisson _QC_}
	    Coupled {  _EQS_ }
	Plot(FilePrefix=\"n@node@_HCD_0\")	    
	    Quasistationary(
	    	InitialStep=1e-3 Increment=3.3
	    	MinStep=1e-9 MaxStep=0.2
	    	Goal { Name=\"drain\" Voltage= _VD_ }
	    	Goal { Name=\"gate\" Voltage = _VG_ }
	    	){ Coupled {  _EQS_ } }
	  	 
	    NewCurrentFile=\"IV_${j}_\"
	    Quasistationary(
	       	InitialStep=1e-3 Increment=1.67
	       	MinStep=1e-9 MaxStep=0.1
	       	Goal { Name=\"gate\" Voltage= 0 }
	    	){ Coupled {  _EQS_ } 
	    		CurrentPlot( Time=(Range=(0 1) Intervals=30) ) 	    
	    		}	  	 	 	   
}

"
}
