#setdep @node|sprocess@

   
#if "@Type@" == "nMOS"
	#define _EQS_ Poisson  eQuantumPotential  Electron  Temperature    HydrogenAtom   HydrogenMolecule   HydrogenIon
	#define _EQS1_ Poisson  eQuantumPotential  Electron  Temperature    
	#define _SHE_ eSHEDistribution
	#define _QC_ eQuantumPotential
	#define _BAND_ CB
	#define _CHARGE_ -1
	#define _CAR_ 2
	#define _InterfaceCh_ eInterfaceTrappedCharge
	#define _CHM_ Silicon
	#define _VG_ @<-1*_CHARGE_*Vg_Stress>@
	#define _VD_ @<-1*_CHARGE_*Vd_Stress>@

#elif "@Type@" == "pMOS"
	#define _EQS_ Poisson  hQuantumPotential  Hole  Temperature    HydrogenAtom   HydrogenMolecule   HydrogenIon
	#define _EQS1_ Poisson  hQuantumPotential  Hole  Temperature  
	#define _SHE_ hSHEDistribution
	#define _QC_ hQuantumPotential
	#define _BAND_ VB
	#define _CHARGE_  1
	#define _CAR_  3
	#define _InterfaceCh_ hInterfaceTrappedCharge
	#define _CHM_ SiliconGermanium
	#define _VG_ @<-1*_CHARGE_*Vg_Stress>@
	#define _VD_ @<-1*_CHARGE_*Vd_Stress>@
#endif



File{
    	Grid    = "n@node|sprocess@_e_fps.tdr"	
    	Plot    = "n@node@_des.tdr"
    	Current = "n@node@_des.plt"
    	Output  = "n@node@_des.log"
    	Param   = "@parameter@"
    	PMIPath = "./pmi"
    	PMIUserFields    = "n@node|sprocess@_e_fps.tdr"
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


CurrentPlot{
	_InterfaceCh_(Maximum(RegionInterface = "ChFin/Gateoxide1"))
    	_InterfaceCh_(Average(RegionInterface = "ChFin/Gateoxide1"))
    	_InterfaceCh_(Minimum(RegionInterface = "ChFin/Gateoxide1"))
    	Tcl (
        	Formula = "set tr1 [tcl_cp_ReadScalar _InterfaceCh_ ]
        			   set value [expr _CHARGE_ * $tr1]		"
         	Operation= " Plot= PMIUserField0 RegionInterface= \"ChFin/Gateoxide1\""  
	)

    	_InterfaceCh_(Maximum( RegionInterface = "Gateoxide1/Gateoxide2"))
    	_InterfaceCh_(Average( RegionInterface = "Gateoxide1/Gateoxide2"))
    	_InterfaceCh_(Minimum( RegionInterface = "Gateoxide1/Gateoxide2"))
    	Tcl (
         	Formula = "	set tr2 [tcl_cp_ReadScalar _InterfaceCh_ ]
         				set value [expr _CHARGE_ * $tr2]		"
         	Operation= " Plot= PMIUserField1 RegionInterface= \"Gateoxide1/Gateoxide2\" "  
	)
}
      

Thermode{
	{Name="gate" 		Temperature=298 SurfaceResistance =5e-8}
	{Name="substrate"  	Temperature=298 SurfaceResistance =2e-8}
	{Name="source"  	Temperature=298 SurfaceResistance =2e-8}
	{Name="drain"  	 	Temperature=298 SurfaceResistance =2e-8}
}
	
	
Electrode{
  	{ name="gate" 		voltage=0 }
  	{ name="substrate" 	voltage=0 }	
  	{ name="source" 	voltage=0 }
  	{ name="drain" 		voltage=0 }	
}


Physics{
	DefaultParametersFromFile
	Temperature=298
    	Thermodynamic
    	_SHE_(FullBand)     
}


Physics(Material="_CHM_"){
  	_QC_  
	AnalyticTEP
	Fermi
    	EffectiveIntrinsicDensity( OldSlotboom )
    	Mobility(
       		PhuMob
       		HighFieldSaturation
       		Enormal
   	)
   	Recombination(
       		SRH(DopingDep)
   	) 
 
}


Physics(RegionInterface = "ChFin/Gateoxide1"){
 	MSConfigs(
  		MSConfig( Name="msc0" Conc=1e13
   			State ( Name="s0" Charge=0 Hydrogen=1 )
			State ( Name="s1" Charge=_CHARGE_ Hydrogen=0 )
  			Transition ( Name="Depassivation" CEModel("CEModel_Depassivation",_CAR_)
    				To="s1" From="s0"
    				Reservoirs( "_BAND_" (Particles=+1) "HydrogenAtom" (Particles=-1) )
    				FieldFromInsulator
   			)
  		)
 	)
}

Physics(RegionInterface = "Gateoxide1/Gateoxide2"){
	MSConfigs(
  		MSConfig ( Name="msc1" Conc=5e13
   			State ( Name="s2" Charge=0 Hydrogen=1 )
			State ( Name="s3" Charge=_CHARGE_ Hydrogen=0 )
			Transition ( Name="Depassivation_1" CEModel("CEModel_PMI",1)
    				To="s3" From="s2"
    				Reservoirs( "_BAND_" (Particles=+1) "HydrogenAtom" (Particles=+1) "HydrogenMolecule" (Particles=-1))
   			)
  		)
 	  	
  		MSConfig ( Name="msc2" Conc=5e13
   			State ( Name="s4" Charge=0 Hydrogen=1 )
			State ( Name="s5" Charge=_CHARGE_ Hydrogen=0 )
			Transition ( Name="Depassivation_2" CEModel("CEModel_PMI1",1)
    				To="s5" From="s4"
    				Reservoirs( "_BAND_" (Particles=+2) "HydrogenAtom" (Particles=+1) "HydrogenIon" (Particles=-1))
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
Physics(MaterialInterface = "TiNitride/Tungsten"){
 	HydrogenDiffusion
}
Physics(Material = "Tungsten"){
  	HydrogenDiffusion
}
Physics(Material = "LowK"){
  	HydrogenDiffusion
}
Physics(Material = "Nitride"){
  	HydrogenDiffusion
}
Physics(Material = "Oxide"){
      	HydrogenDiffusion
}


Math{
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
    	SHEIterations=30
    	Method=ILS
    	RefDens_eGradQuasiFermi_ElectricField_HFS= 1e12
    	RefDens_hGradQuasiFermi_ElectricField_HFS= 1e12    
 	SHERefinement = 2 
	SHETopMargin= 2  	
	-ExitOnUnknownParameterRegion
  
}     


Solve{	
	Set(_SHE_ (Frozen))  
	Set( (MSConfig="msc0" Transition="Depassivation" CPreFactor=@Kf1@ EPreFactor= 19.8) )
	Set(
		MSConfigs(
	    		MSConfig( Name="msc0"
	        		State ( Name="s0" Value=1.0 )
			)
	        	MSConfig( Name="msc1"
	        		State ( Name="s2" Value=1.0 )
			) 
	        	MSConfig( Name="msc2"
	        		State ( Name="s4" Value=1.0 )
			) 			
			
	        	Frozen
		)
	)
	    
	Coupled(Iterations=100 LineSearchDamping=1e-4){ Poisson   _QC_}
	Coupled {  _EQS1_ }
	Quasistationary(
		InitialStep=1e-3 Increment=3.3
	       	MinStep=1e-6 MaxStep=0.2
	       	Goal { Name="drain" Voltage=_VD_ }
	       	Goal { Name="gate" Voltage=_VG_ }
		){ Coupled {  _EQS1_ } }
	 	 	 
	Set(_SHE_ (-Frozen))
	Coupled {  _EQS1_ } 
	Set(_SHE_ (Frozen))  
	Set ( MSConfigs ( -Frozen )  )
	  
#Degradation
	NewCurrentFile="Cycle_Str_"
	Transient( InitialTime=0 Finaltime = @TfinalStress@
		Increment=2 InitialStep=1e-6 MinStep=1e-18 MaxStep=@<TfinalStress/10>@
		){Coupled {  _EQS_ } 
		  Plot(FilePrefix="n@node@_HCD_Str" time=(0;0.01;1e-1;1e0;1e1;1e2;1e3) nooverwrite)
	    	}
	Set (MSConfigs( Frozen ))

}




