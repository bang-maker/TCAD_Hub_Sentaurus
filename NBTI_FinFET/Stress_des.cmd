#setdep @node|sprocess@

#define _initTime_ 0
#define _finalTime_ @TfinalStress@
#define _EQ_ Poisson   hQuantumPotential  Hole HydrogenAtom  HydrogenMolecule HydrogenSpeciesA HydrogenIon

	
 File {
     Grid          = "n@node|sprocess@_e_fps.tdr"
     Plot          = "n@node@_des.tdr"
     Current       = "n@node@_des.plt"
     Output        = "n@node@_des.log"
     Param         = "@parameter@"
     PMIPath       = "@pwd@/pmi"
     PMIUserFields = "n@node|sprocess@_e_fps.tdr"
  }
  
  
  Electrode {
      { name="gate"      voltage=0 }
      { name="substrate" voltage=0 }	
      { name="source"    voltage=0 }
      { name="drain"     voltage=0 }	
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
    PMIUserField90
    PMIUserField91
    PMIUserField0
    PMIUserField1
    PMIUserField2
    InterfaceABDWTState1
    InterfaceABDWTState2
    ABDWTCharge
    InterfaceTTOMFraction
}


CurrentPlot{
    hInterfaceTrappedCharge(Maximum(RegionInterface = "ChFin/Gateoxide1"))
    hInterfaceTrappedCharge(Average(RegionInterface = "ChFin/Gateoxide1"))
    hInterfaceTrappedCharge(Minimum(RegionInterface = "ChFin/Gateoxide1"))
    	Tcl (
        	Formula = "set value [tcl_cp_ReadScalar hInterfaceTrappedCharge ]"
         	Operation= " Plot= PMIUserField0 RegionInterface = \"ChFin/Gateoxide1\""  
	)

    hInterfaceTrappedCharge(Maximum(RegionInterface = "Gateoxide1/Gateoxide2"))
    hInterfaceTrappedCharge(Average(RegionInterface = "Gateoxide1/Gateoxide2"))
    hInterfaceTrappedCharge(Minimum(RegionInterface = "Gateoxide1/Gateoxide2"))
    	Tcl (
         	Formula = "set value [tcl_cp_ReadScalar hInterfaceTrappedCharge ]"
         	Operation= " Plot= PMIUserField1 RegionInterface= \"Gateoxide1/Gateoxide2\" "  
	) 
 

    ABDWTCharge(Maximum(Region  = "Gateoxide1"))
    ABDWTCharge(Average(Region  = "Gateoxide1"))
    ABDWTCharge(Minimum(Region  = "Gateoxide1"))       
    	Tcl (
        	Formula = "set value [tcl_cp_ReadScalar ABDWTCharge ]"
         	Operation= " Plot= PMIUserField2 Region  = \"Gateoxide1\""  
	)
    }



Physics{
    EffectiveIntrinsicDensity( OldSlotboom )
    Temperature= @Temp@
}

Physics(Material="SiliconGermanium"){
    hQuantumPotential    
    Mobility(
       PhuMob
       HighFieldSaturation( GradQuasiFermi )
       Enormal
   )
   Recombination(
       SRH( DopingDep )
   ) 
   HydrogenDiffusion         
}


Physics(RegionInterface = "ChFin/Gateoxide1"){
    MSConfigs (
        MSConfig ( Name="msc0" Conc=1.5e13
            State ( Name="s0" Charge=0 Hydrogen=1 TTOM)
            State ( Name="s1" Charge=1 Hydrogen=0 TTOM)
            Transition ( Name="Depassivation" CEModel("CEModel_Depassivation",1) To="s1" From="s0"
                	Reservoirs( "VB" (Particles=+1) "HydrogenAtom" (Particles=-1) )
                	FieldFromInsulator
            		)
        	)
	
	
	MSConfig ( Name="msc2" Conc=1e13
   		State ( Name="s4" Charge=0 Hydrogen=1 )
		State ( Name="s5" Charge=1 Hydrogen=0 )
  		Transition ( Name="Depassivation_2" CEModel("CEModel_Depassivation_2",7) To="s5" From="s4"
    			Reservoirs( "VB" (Particles=+1) "HydrogenSpeciesA" (Particles=-1) )
    			FieldFromInsulator
   			)
  		)		
    )

    ABDWT (
        Conc=  6.5e20
        NumberOfSamples = 100 )
}


Physics(RegionInterface = "Gateoxide1/Gateoxide2"){
    MSConfigs (
        MSConfig ( Name="msc1" Conc=5e13
            State ( Name="s2" Charge=0 Hydrogen=1 )
            State ( Name="s3" Charge=1 Hydrogen=0 )
                Transition ( Name="Depassivation_1" CEModel("CEModel_PMI2",1) To="s3" From="s2"
                Reservoirs( "VB" (Particles=+1) "HydrogenAtom" (Particles=+1) "HydrogenMolecule" (Particles=-1))
                )
        )
		
	MSConfig ( Name="msc3" Conc= 1e13
   	    State ( Name="s6" Charge=0 Hydrogen=1 )
	    State ( Name="s7" Charge=1 Hydrogen=0 )
		Transition ( Name="Depassivation_3" CEModel("CEModel_PMI1",1) To="s7" From="s6"
    		Reservoirs( "VB" (Particles=1) "HydrogenSpeciesA" (Particles=+1) "HydrogenMolecule" (Particles=-1))
   		)
  	)
 
  	MSConfig ( Name="msc4" Conc=1e13
   	    State ( Name="s8" Charge=0 Hydrogen=1 )
	    State ( Name="s9" Charge=1 Hydrogen=0 )
		Transition ( Name="Depassivation_4" CEModel("CEModel_PMI",1) To="s9" From="s8"
    		Reservoirs( "VB" (Particles=2) "HydrogenSpeciesA" (Particles=+1) "HydrogenIon" (Particles=-1))
   		)
  	)	   
    )
    HydrogenDiffusion   
  
}

Physics(Material = "InterfacialOxide"){
      HydrogenDiffusion
}
Physics(Material= "HfO2"){
    HydrogenDiffusion
}
Physics(MaterialInterface = "HfO2/TiNitride"){
    HydrogenDiffusion
}
Physics(Material = "TiNitride"){
     HydrogenDiffusion
}
Physics(MaterialInterface = "Tungsten/TiNitride"){
    HydrogenDiffusion
}
Physics(Material = "Tungsten"){
    HydrogenDiffusion
}
Physics(Material = "LowK"){
    HydrogenDiffusion
}
Physics(Material = "Oxide"){
    HydrogenDiffusion
}
Physics(Material = "Nitride"){
    HydrogenDiffusion
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
    ExtendedPrecision(128)
    -CheckUndefinedModels
    -ExitOnUnknownParameterRegion
}  

Solve {
	    Set( (MSConfig="msc0" Transition="Depassivation" CPreFactor=14e2 EPreFactor= 19.8e2) )
	    Set( (MSConfig="msc2" Transition="Depassivation_2" CPreFactor=5e-4 EPreFactor= 5.4e0) )	    
	    Set (MSConfigs (
	 	 	MSConfig ( Name="msc0" State ( Name="s0" Value=1.0 ))
	 	 	MSConfig ( Name="msc1" State ( Name="s2" Value=1.0 ))	
	 	 	MSConfig ( Name="msc2" State ( Name="s4" Value=1.0 ))			
	 	 	MSConfig ( Name="msc3" State ( Name="s6" Value=1.0 ))			
	 	 	MSConfig ( Name="msc4" State ( Name="s8" Value=1.0 ))									
	        Frozen 
		    ) 
		)
	    
	    Coupled(Iterations=100 LineSearchDamping=1e-4){ Poisson  hQuantumPotential}
	    Coupled { Poisson   Hole hQuantumPotential}
	    Coupled { _EQ_}
	    Quasistationary(
	        InitialStep=1e-3 Increment=1.35
	        MinStep=1e-6 MaxStep=0.2
	        Goal { Name="gate" Voltage=@Vg_Stress@ }
	     ){ Coupled { Poisson Hole hQuantumPotential} }
	
	    Set (MSConfigs ( -Frozen ) )
	  
#  Degradation
	    NewCurrentFile="Stress_"
	    Transient( InitialTime=_initTime_ Finaltime = @TfinalStress@
	               Increment=1.6 InitialStep=1e-6 MaxStep=@<TfinalStress/5>@){
	               Coupled { _EQ_}
		       Plot(FilePrefix="n@node@_Str" time=(0;1e-1;1e0;1e1;1e2;1e3) nooverwrite)	 
	 		}
	    Set (MSConfigs ( Frozen ) )

}




