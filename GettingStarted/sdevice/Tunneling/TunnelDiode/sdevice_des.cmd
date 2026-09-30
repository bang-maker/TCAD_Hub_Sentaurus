#setdep @previous@

   #define _Apath_ 4e14
   #define _Bpath_ 1.9e7
   #define _Ppath_ 0

   #if "@par@" == "Ppath" 
      #define _Ppath_ @par_val@
   #endif

   #if "@par@" == "Permeation"
       #define _Permeation_ @par_val@
   #else
       #define _Permeation_ 40e-7
   #endif

   #if "@case@" == "direct"  
      #define _Ppath_ 0
      #if "@par@" == "Apath" 
         #define _Apath_ @par_val@
         #define _Bpath_ 1.9e7
      #elif "@par@" == "Bpath" 
         #define _Bpath_ @par_val@
         #define _Apath_ 1e19
      #endif
   #elif "@case@" == "phonon-assisted"
      #define _Ppath_ 0.037
      #if "@par@" == "Apath" 
         #define _Apath_ @par_val@
      #endif
   #endif

#####################################
File {
	Grid=      "@tdr@"
	Parameter= "@parameter@"
	Current=   "@plot@"
	Plot=      "@tdrdat@"
	Output=    "@log@"
   #if "@model@" == "static"
      NonLocalPlot= "n@node@_nl"
   #endif
}

Electrode {
	{ Name= "cathode"  Voltage= 0 }
	{ Name= "anode"  Voltage= 0 }
}

Physics {
	AreaFactor= @<1e11/wtot>@
	Mobility ( DopingDependence)
	Recombination ( 
	   	SRH Auger Radiative
	   #if "@model@" == "dynamic" 
		Band2Band (
			Model= NonlocalPath
		)
		#endif
	)	
	EffectiveIntrinsicDensity( NoBandGapNarrowing )
	HeteroInterface
	Fermi

   #if "@model@" == "static"   
      #if "@case@" == "B2BFull"
         eBarrierTunneling "NLM" (Band2Band=Full)
         hBarrierTunneling "NLM" (Band2Band=Full)
      #elif "@case@" == "eBarr_B2BFull"
         eBarrierTunneling "NLM" (Band2Band=Full)
      #elif "@case@" == "hBarr_B2BFull"
         hBarrierTunneling "NLM" (Band2Band=Full)
      #endif
   #endif

}

#if "@model@" == "static" 
* Plot some variables using non-local mesh for easy visualization in S-Visual
* NonLocalPlot ((-0.025 0.1001) (0 0.1001) (0.002 0.1001) (0.004 0.1001) (0.006 0.1001) (0.008 0.1001) (0.01 0.1001) (0.025 0.1001)) { 
NonLocalPlot ((-0.025 0.1) (0.025 0.1)) { 
   eDensity hDensity
   ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy
   eBarrierTunneling hBarrierTunneling
   ElectrostaticPotential
}
#endif

Plot {
*- Carrier Densities:
	eDensity hDensity
	EffectiveIntrinsicDensity IntrinsicDensity
	eEquilibriumDensity hEquilibriumDensity

*- Currents and current components:
	Current/Vector eCurrent/Vector hCurrent/Vector
	eMobility hMobility eVelocity hVelocity
	
*- Fields, Potentials and Charge distributions
	ElectricField/Vector Potential SpaceCharge
	
*- Generation/Recombination
	srhRecombination AugerRecombination RadiativeRecombination TotalRecombination	
	eLifeTime hLifeTime

*- Doping Profiles
	Doping DonorConcentration AcceptorConcentration

*- Band structure
	BandGap BandGapNarrowing ElectronAffinity
	ConductionBandEnergy ValenceBandEnergy
	eQuasiFermiEnergy hQuasiFermiEnergy

#if "@model@" == "dynamic"
*- Band2Band Tunneling
  	eBand2BandGeneration hBand2BandGeneration Band2BandGeneration
	SemiconductorGradConductionBand SemiconductorGradValenceBand
#elif "@model@" == "static" 	
    eBarrierTunneling hBarrierTunneling
    NonLocal
#endif    
}

CurrentPlot {
    #if "@model@" == "dynamic" 
	Band2BandGeneration(Integrate(Semiconductor))
	eBand2BandGeneration(Integrate(Semiconductor))
	hBand2BandGeneration(Integrate(Semiconductor))
	#elif "@model@" == "static" 
	eBarrierTunneling(Integrate(Semiconductor))
	hBarrierTunneling(Integrate(Semiconductor))
	#endif
	srhRecombination(Integrate(Semiconductor))	
    TotalRecombination( Integrate(Semiconductor))	
}

Math {
	CurrentPlot(IntegrationUnit= cm)

   #if "@model@" == "static" 
      Nonlocal "NLM" ( 
       RegionInterface="phigh/nhigh"
       Length=40e-7           # [cm] distance to anchor point
       Permeation = _Permeation_

      )	
   #endif			 
}

Solve {
	NewCurrentPrefix= "tmp"
	Poisson  
	* Save TDR file at zero bias. Useful for plotting band diagram at equilibrium.
	Plot (FilePrefix= "n@node@_Poisson")
	Electron 
	Hole
	Coupled {Poisson Electron}
	Coupled {Poisson Electron Hole}
	Plot (FilePrefix= "n@node@_Zero")

	Quasistationary ( 
		InitialStep= 0.02 Increment= 2 Decrement= 2
		MinStep= 0.001     MaxStep= 0.02
		Goal { Name="anode" Voltage= -0.5 }
	){ Coupled { Poisson Hole Electron } 
	}	

	NewCurrentPrefix= ""
	Quasistationary ( 
		InitialStep= 0.02 Increment= 2 Decrement= 2
		MinStep= 0.001     MaxStep= 0.02
		Plot {Range= (0 1) Intervals= 5}
		Goal { Name="anode" Voltage= 0.5 }
	){ Coupled { Poisson Hole Electron } 
	   Plot(FilePrefix= "n@node@_0.06V" When(Contact = "anode" voltage = 0.06 ))
	}	
	
	System("rm -f tmp*")
}
