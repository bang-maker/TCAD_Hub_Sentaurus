###########################################################
## FN par
   #define _Ae_ 1.87e-07
   #define _Aw_ 1.23e-06

## DT par
   #define _E_barrier_e_ 3.15
   #define _m_ins_e_ 0.5
   #define _m_ins_h_ 0.77
   #define _m_dos_e_si_ 0.32
   #define _m_dos_h_si_ 0.3

# NLT par
   #define _NLT_ 0
   #define _Box_Traps_ 0
   #define _Box_Traps_NLM_ 0
   #define _NLM_Length_ 8e-7

   #define _mte_ 0.4
   #define _mth_ 0.32
   #define _mt_e_si_ 0.19
   #define _mt_h_si_ 0.16
   #define _gc_ 2.1
   #define _gv_ 0.66

# TAT par
   #define _HuangRhys_ 70 
   #define _PhononEnergy_ 0.02
   #define _gamma_ 1

###########################################################
#if "@model@" == "FN" 

   #if "@case@" == "Aex50"
      #define _Ae_ @<1.87e-7*50>@
   #elif "@case@" == "Awx50"
      #define _Aw_ @<1.23e-6*50>@
   #endif

#elif "@model@" == "DT"

   #if "@par@" == "m_dos_e_si" 
      #define _m_dos_e_si_ @par_val@
   #elif "@par@" == "m_dos_h_si" 
      #define _m_dos_h_si_ @par_val@
   #elif "@par@" == "m_ins_e"
      #define _m_ins_e_ @par_val@
   #elif "@par@" == "m_ins_h"
      #define _m_ins_h_ @par_val@
   #elif "@par@" == "E_barrier_e"
      #define _E_barrier_e_ @par_val@
   #endif

   #if "@case@" == "FixedCharge"
      #define _Box_Traps_ 1
      #define _m_ins_e_ 0.385
   #endif
   

#elif "@model@" == "NLT" 
   #define _NLT_ 1
   #if "@case@" == "FixedCharge"  
      #define _Box_Traps_ 1
   #endif
   #if "@par@" == "mt_e_ox" 
      #define _mte_ @par_val@
   #elif "@par@" == "mt_h_ox"
      #define _mth_ @par_val@
   #elif "@par@" == "mt_e_si"
      #define _mt_e_si_ @par_val@
   #elif "@par@" == "gc"
      #define _gc_ @par_val@
   #elif "@par@" == "gv"
      #define _gv_ @par_val@
   #endif
      
#elif "@model@" == "TAT" 
   #define _Box_Traps_ 1
   #define _Box_Traps_NLM_ 1
   #define _NLM_Length_ 3e-7

   #if "@par@" == "HuangRhys"
      #define _HuangRhys_ @par_val@
   #endif

   #if "@par@" == "PhononEnergy"
      #define _PhononEnergy_ @par_val@
   #endif

   #if "@par@" == "gamma"
      #define _gamma_ @par_val@
   #endif

#elif "@model@" == "NLM"
   #define _NLT_ 1
   #if "@case@" == "OxTraps"
      #define _Box_Traps_ 1
      #define _Box_Traps_NLM_ 1
   #endif
#endif

###########################################################
#Coupled equations
#if "@case@" == "DensityGradient"
   #define _DensityGradient_ eQuantumPotential hQuantumPotential
   #define _CarrierHeating_ 
   #define _hydro_ 
#elif "@case@" == "CarrierHeating"
   #define _DensityGradient_
   #define _CarrierHeating_ eTemperature hTemperature
   #define _hydro_ Hydrodynamic
#else
   #define _DensityGradient_
   #define _CarrierHeating_ 
   #define _hydro_ 
#endif

###########################################################
Electrode {
   #if "@GateMat@" == "PolySi"
        { Name="top"  Voltage= 0.0}
   #else
        { Name="top"  Voltage= 0.0 Schottky Workfunction= 4.1}
   #endif
        { Name="bot"  Voltage= 0.0}
}

File {
	Grid= 		"@tdr@"
	Parameter=	"@parameter@"
	
	Current= 	"@plot@"
	Plot= 		"@tdrdat@"
	Output= 	"@log@"
	#if "@model@" == "NLT" || "@model@" == "NLM" || "@model@" == "TAT" 
      #if _NLM_Length_ >= @tbox@e-7 
	   NonLocalPlot= "n@node@_nl"
      #endif
   #endif
}

Physics {
	AreaFactor= 1.25e9 * So current is given in A/cm^2
	Temperature= 300
   _DensityGradient_
   _hydro_
	Recombination (
		SRH(DopingDependence)
	)
	
   #if _NLT_
      #if "@case@" == "eBarr" 
	      eBarrierTunneling "NLM_top"
      #elif "@case@" == "hBarr" 
	      hBarrierTunneling "NLM_top"
      #elif "@case@" == "eBarr_B2BFull" 
	      eBarrierTunneling "NLM_top" (Band2Band=Full)
      #elif "@case@" == "hBarr_B2BFull" 
	      hBarrierTunneling "NLM_top" (Band2Band=Full)
      #elif "@case@" == "B2BFull" 
	      eBarrierTunneling "NLM_top" (Band2Band=Full)
	      hBarrierTunneling "NLM_top" (Band2Band=Full)
      #elif "@case@" == "Band2BandFull"
	      eBarrierTunneling "NLM_top" (Band2Band=Full)
	      hBarrierTunneling "NLM_top" (Band2Band=Full)
      #elif "@case@" == "BarrierNLM" 
	      eBarrierTunneling "NLM_B"
	      hBarrierTunneling "NLM_B"
      #else
	      eBarrierTunneling "NLM_top"
	      hBarrierTunneling "NLM_top"
      #endif
   #endif

}

Physics(RegionInterface="r.ox/r.si") {
	#if "@model@"=="DT"
	   GateCurrent(DirectTunneling GateName="top")
	#elif "@model@"=="FN" 
	   GateCurrent(Fowler GateName="top")
	#endif
}

#if _Box_Traps_ 
Physics(region="r.ox") {
   Traps(
      (
      #if "@case@" == "FixedCharge"
         FixedCharge
         conc=1e20
      #else   
         Acceptor Level 
         #if "@par@" == "Emid"
         EnergyMid= @par_val@ 
         #else
         EnergyMid= 1.5 
         #endif

         FromConductionBand Conc= 1e19
         #if "@par@" == "Xsec"
         eXSection= @par_val@ hXSection= @par_val@
         #else
         eXSection= 1e-10 hXSection= 1e-10
         #endif
      #endif

      #if "@model@" == "TAT" || "@model@" == "DT" && "@case@" == "FixedCharge" || "@model@" == "NLT" && "@case@" == "FixedCharge"
      SpatialShape= Uniform SpaceMid=(-2e-3,0,0) SpaceSig=(0.4e-3,100,100)
      #endif

      #if _Box_Traps_NLM_
         #if "@case@" == "NLM_top" 
         eBarrierTunneling(NonLocal= "NLM_top" )
         hBarrierTunneling(NonLocal= "NLM_top" )
         #elif "@case@" == "NLM_bot" 
         eBarrierTunneling(NonLocal= "NLM_bot")
         hBarrierTunneling(NonLocal= "NLM_bot")
         #elif "@case@" == "NLM_both"
         eBarrierTunneling(NonLocal= "NLM_top" NonLocal= "NLM_bot")
         hBarrierTunneling(NonLocal= "NLM_top" NonLocal= "NLM_bot")
         #endif	
         #if "@par@" == "TrapVolume"
            TrapVolume= @par_val@
         #else
            TrapVolume= 1e-5
         #endif
         HuangRhys=_HuangRhys_
         PhononEnergy=_PhononEnergy_
         gamma=_gamma_
      #endif
      )
   )
}
#endif

#if _NLT_ || "@model@" == "TAT" 
* Plot some variables using non-local mesh for easy visualization in S-Visual
NonLocalPlot ((-0.006 0) (0.002 0)) { 
   eDensity hDensity
   eBarrierTunneling hBarrierTunneling
   ElectrostaticPotential
   eQuasiFermiEnergy hQuasiFermiEnergy
   ConductionBandEnergy ValenceBandEnergy 

}
#endif

Plot {
   DopingConcentration
	ElectricField/Vector	
	ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy
	eGradQuasiFermi hGradQuasiFermi	
	SRH
   eMobility hMobility

	#if "@model@"=="NLT"	|| "@model@" == "NLM" || "@model@"=="TAT" 
	   NonLocal
	   eBarrierTunneling hBarrierTunneling
   #endif

	#if "@model@"=="DT"
      eSchenkTunnel hSchenkTunnel
   #endif

	#if "@model@"=="TAT" || "@model@" == "TAT_UT" || "@model@" == "NLT" && "@case@" == "FixedCharge" || "@model@" == "DT" && "@case@" == "FixedCharge"
      eTrappedCharge hTrappedCharge
      eGapStatesRecombination hGapStatesRecombination
      TotalTrapConcentration   * plots total bulk trap concentration
      TotalInterfaceTrapConcentration  * plots total interface trap concentration 
      TrappingRates
   #endif
}

CurrentPlot {
   ElectricField/Vector(Average(Region="r.ox"))
}

Math {
	Extrapolate
	Iterations= 40
   RHSMin= 1e-8
   CNormPrint
	ExtendedPrecision(128)
	Digits= 8
	
#if "@model@" == "NLT" || "@model@" == "NLM" 

   #if "@case@" == "BarrierNLM" 
	   NonLocal "NLM_B" (
         Barrier(Region="r.ox")
	   )
   #else
	   NonLocal "NLM_top" (
         #if "@GateMat@" == "PolySi"
		      RegionInterface="r.polysi/r.ox"
            #elif "@GateMat@" == "-"
            Electrode="top"
         #endif

         #if "@par@"== "NLM_Length"
   		   Length= @par_val@
         #else
		      Length= _NLM_Length_
         #endif

         #if "@case@"== "Ref"
             -Endpoint(Material="PolySi")
         #endif

         #if "@case@"== "Permeation"
             -Endpoint(Material="PolySi")
             Permeation=2e-7
         #endif

         #if "@par@"== "Digits"
   		   Digits= @par_val@
         #endif

         #if "@par@"== "EnergyResolution"
   		   EnergyResolution= @par_val@
         #endif
	   )
   #endif

#elif "@model@" == "TAT"  

   #if "@case@" == "NLM_top"
	NonLocal "NLM_top" (
		   RegionInterface="r.polysi/r.ox"
      -Endpoint(Material="PolySi")
      Endpoint(Material="Oxide")
         #if "@par@"== "NLM_Length"
   		   Length= @par_val@
         #else
		      Length= _NLM_Length_
         #endif
	)
   #elif "@case@" == "NLM_bot"
	NonLocal "NLM_bot" (
		RegionInterface="r.si/r.ox"
      -Endpoint(Material="Silicon")
      Endpoint(Material="Oxide")
         #if "@par@"== "NLM_Length"
   		   Length= @par_val@
         #else
		      Length= _NLM_Length_
         #endif
	)

   #elif "@case@" == "NLM_both" 
	NonLocal "NLM_top" (
		RegionInterface="r.polysi/r.ox"
      -Endpoint(Material="PolySi")
         #if "@par@"== "NLM_Length"
   		   Length= @par_val@e-7
         #else
		      Length= _NLM_Length_
         #endif
	)
	NonLocal "NLM_bot" (
		RegionInterface="r.si/r.ox"
      -Endpoint(Material="Silicon")
         #if "@par@"== "NLM_Length"
   		   Length= @par_val@
         #else
		      Length= _NLM_Length_
         #endif
		# Digits= 5
		# EnergyResolution= 1e-5
	)
   #endif

#endif
	
	-CheckUndefinedModels
}


Solve {
	NewCurrentFile="n@node@_init_"
	Coupled (Iterations= 10000)  {Poisson _DensityGradient_ }
	Coupled (Iterations= 10000)  {Poisson Electron Hole _DensityGradient_ }

#if "@model@" != "NLM"

	Plot(FilePrefix="n@node@_Zero")

	QuasiStationary(
	    InitialStep= 0.1 MinStep= 1e-4
	    Goal{Name="top" Voltage=@vgmin@}
	){
	    Coupled{Poisson Electron Hole _DensityGradient_ _CarrierHeating_}
	}
	Plot(FilePrefix="n@node@_Neg")

	NewCurrentFile= ""
	QuasiStationary(
	    DoZero
	    InitialStep= 0.01 MinStep= 1e-8
	    Goal{Name="top" Voltage= @vgmax@}
	){
	    Coupled{Poisson Electron Hole _DensityGradient_ _CarrierHeating_}
	    CurrentPlot(Time=(Range=(0 1) Intervals= 200))
       Plot(FilePrefix="n@node@_1V" Time=(0.625) )
	}

#endif

}

