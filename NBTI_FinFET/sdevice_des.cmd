#setdep @node|Stress@

#define _initTime_ 0
#define _finalTime_ @TfinalStress@

#define _EQ_ Poisson   hQuantumPotential  Hole





set i 0
for {set j 0} {$j < 7} {incr j} {
		set TDR "n@node|Stress@_Str_000${j}_des.tdr"

	
	
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


   
   
Electrode {
  		{ name=\"gate\" 		voltage=0 	}
  		{ name=\"substrate\" 	voltage=0 	}	
  		{ name=\"source\" 		voltage=0 	}
  		{ name=\"drain\" 		voltage=0 	}	
}


Physics{
    EffectiveIntrinsicDensity( OldSlotboom )
    Temperature= @Temp@
}

Physics(Material=\"SiliconGermanium\"){
  hQuantumPotential    
    Mobility(
       PhuMob
       HighFieldSaturation( GradQuasiFermi )
       Enormal
   )
   Recombination(
       SRH( DopingDep )
   )       
}



Physics(RegionInterface = \"ChFin/Gateoxide1\"){
	Traps((Donor Uniform EnergyMid=0 fromMidBandGap EnergySig=1.12 SFactor= \"PMIUserField0\"))
}

Physics(RegionInterface = \"Gateoxide1/Gateoxide2\"){
	Traps((FixedCharge SFactor= \"PMIUserField1\"))
}



Math {
    NumberOfThreads    = 4  
    Extrapolate
    Digits=5
    ErrRef(electron)=1.e10
    ErrRef(hole)=1.e10
    Notdamped=50
    Iterations=20
    transient=BE
    ExitOnFailure
    ExtendedPrecision
    -CheckUndefinedModels   
}   



Solve {
		
		NewCurrentFile=\" \"  
		Coupled(Iterations=100 LineSearchDamping=1e-4){ Poisson hQuantumPotential}
	    Coupled {  _EQ_ }
	Plot(FilePrefix=\"n@node@_Str_0\")	    
	    Quasistationary(
	    	InitialStep=1e-3 Increment=3.3
	    	MinStep=1e-9 MaxStep=0.2
	    	Goal { Name=\"drain\" Voltage= -0.05 }
	    	Goal { Name=\"gate\" Voltage = 0 }
	    	){ Coupled {  _EQ_ } }
	  	 
	    NewCurrentFile=\"IV_${j}_\"
	    Quasistationary(
	       	InitialStep=1e-3 Increment=1.67
	       	MinStep=1e-9 MaxStep=0.1
	       	Goal { Name=\"gate\" Voltage= -1.2 }
	    	){ Coupled {  _EQ_ } 
	    		CurrentPlot( Time=(Range=(0 1) Intervals=30) ) 	    
	    		}	  	 	 	   
}

"
}
