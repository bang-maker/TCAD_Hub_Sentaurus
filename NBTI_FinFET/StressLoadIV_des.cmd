#setdep @node|Stress@
#define _EQS_ Poisson   hQuantumPotential  Hole

set i 0
for {set j 0} {$j < 6} {incr j} {
		set TDR "n@node|Stress@_Str_000${j}_des.tdr"

sdevice "	
 File {
     Grid          = \"n@node|sprocess@_e_fps.tdr\"
     Plot          = \"n@node@_des.tdr\"
     Current       = \"n@node@_des.plt\"
     Output        = \"n@node@_des.log\"
     Param         = \"@parameter@\"
     PMIPath       = \"@pwd@/pmi\"
     PMIUserFields = \"${TDR}\"
  }
  
  
  electrode {
  { name=\"gate\"      voltage=0 }
  { name=\"substrate\" voltage=0 }	
  { name=\"source\"    voltage=0 }
  { name=\"drain\"     voltage=0 }	
  }

Plot {
    eDensity hDensity
    eCurrent hCurrent
    eTemperature hTemperature
    ElectricField
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
    InterfaceABDWTState1
    InterfaceABDWTState2
    ABDWTCharge
    InterfaceTTOMFraction
}


Physics {
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
    Traps((FixedCharge SFactor= \"PMIUserField0\"))
}

Physics(RegionInterface = \"Gateoxide1/Gateoxide2\"){
    Traps((FixedCharge SFactor= \"PMIUserField1\"))
}

Physics(Region = \"Gateoxide1\"){
    Traps((FixedCharge SFactor= \"PMIUserField2\"))
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
    -ExitOnUnknownParameterRegion
}  


Solve {
	    NewCurrentFile=\" \"  		
	    Coupled(Iterations=100 LineSearchDamping=1e-4){ Poisson hQuantumPotential}
	    Coupled {  _EQS_ }
	    Quasistationary(
	    	InitialStep=1e-3 Increment=1.67
	    	MinStep=1e-9 MaxStep=0.2
	    	Goal { Name=\"drain\" Voltage= -0.05 }
	    	Goal { Name=\"gate\" Voltage = -0.9 }
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

