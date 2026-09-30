
   #define _NLM_tox_ 0
   #define _NLM_box_ 0
   #define _NLM_mox_ 0
   #define _NLM_mox2_ 0

   #define _NLT_tox_ 0
   #define _NLT_box_ 0
   #define _NLT_mox_ 0
   #define _TXsec_ 1e-15
   #define _TV_ 1e-15
   #define _Length_box_ 9.7e-7 
   #define _Length_tox_ 11.9e-7
   #define _Emid_Acc_VB_ 2

   #if "@CTL_Traps@" == "1"
      #define _AccTraps_ @CTL_Traps@
      #define _DonTraps_ @CTL_Traps@
   #elif "@CTL_Traps@" == "Acc"
      #define _AccTraps_ 1
      #define _DonTraps_ 0
   #elif "@CTL_Traps@" == "Don"
      #define _AccTraps_ 0
      #define _DonTraps_ 1
   #else
      #define _AccTraps_ 0
      #define _DonTraps_ 0
   #endif

   #if "@par@" == "TXsec"
      #define _TXsec_ @par_val@
   #elif "@par@" == "TV"
      #define _TV_ @par_val@
   #elif "@par@" == "Length_tox"
      #define _Length_tox_ @par_val@
   #elif "@par@" == "Length_box"
      #define _Length_box_ @par_val@
   #elif "@par@" == "Emid_Acc_VB"
      #define _Emid_Acc_VB_ @par_val@
   #endif

   #define _NLT_box_Traps_ 0
   #define _NLT_tox_Traps_ 0
   #define _NLT_mox_Traps_ 0

#if "@case@" == "NLM_box"
   #define _NLM_box_ 1
   #define _NLT_box_Traps_ 1
#elif "@case@" == "NLM_tox"
   #define _NLM_tox_ 1
   #define _NLT_tox_Traps_ 1
#elif "@case@" == "NLM_mox"
   #define _NLM_mox_ 1
#elif "@case@" == "NLT_box"
   #define _NLM_box_ 1
   #define _NLT_box_ @NLT@
#elif "@case@" == "NLT_tox"
   #define _NLM_tox_ 1
   #define _NLT_tox_ @NLT@
#elif "@case@" == "NLT_box_tox"
   #define _NLM_box_ 1
   #define _NLT_box_ @NLT@
   #define _NLM_tox_ 1
   #define _NLT_tox_ @NLT@
#elif "@case@" == "NLT_box_mox"
   #define _NLM_box_ 1
   #define _NLT_box_ @NLT@
   #define _NLM_mox_ 1
   #define _NLT_mox_ @NLT@
#elif "@case@" == "NLT_box_mox_tox"
   #define _NLM_box_ 1
   #define _NLT_box_ @NLT@
   #define _NLM_mox_ 1
   #define _NLT_mox_ @NLT@
   #define _NLM_tox_ 1
   #define _NLT_tox_ @NLT@
#endif

#if "@CTL_Traps@" != "0" && @CTL_TAT@
   #if "@case@" == "NLT_box"
      #define _NLT_box_Traps_ 1 
      #define _NLT_box_Traps_ 1

   #elif "@case@" == "NLT_box_tox"
      #define _NLT_box_Traps_ 1 
      #define _NLT_box_Traps_ 1
      #define _NLT_tox_Traps_ 1 
      #define _NLT_tox_Traps_ 1

   #elif "@case@" == "NLT_box_mox"
      #define _NLT_box_Traps_ 1 
      #define _NLT_box_Traps_ 1
      #define _NLT_mox_Traps_ 1 
      #define _NLT_mox_Traps_ 1
   #elif "@case@" == "NLT_box_mox_tox"
      #define _NLT_box_Traps_ 1 
      #define _NLT_box_Traps_ 1
      #define _NLT_mox_Traps_ 1 
      #define _NLT_mox_Traps_ 1
      #define _NLT_tox_Traps_ 1 
      #define _NLT_tox_Traps_ 1
   #endif

#endif

File {
	Grid=      "@tdr@"
	Parameter= "@parameter@"
	Current=   "@plot@"
	Plot=      "@tdrdat@"
	Output=    "@log@"

   #if 1
      NonLocalPlot= "n@node@_nl"
   #endif

}

Electrode {
	{Name="gate" 	Voltage= 0 Material= "PolySi" 
	
	Voltage=(
	!(
	 set t1p 0
	 for { set i 1 } { $i <= @cycles@ } { incr i } { 
	   set t2p [expr $t1p + 1e-6]
	   set t3p [expr $t1p + (@dtp@*1e-3)]	   
	   set t4p [expr $t2p + (@dtp@*1e-3)]
	   	   
	   set t1e [expr $t3p + 2.5e-3]
	   set t2e [expr $t1e + 1e-6]
	   set t3e [expr $t1e + (@dte@*1e-3)]
	   set t4e [expr $t2e + (@dte@*1e-3)]
   
	    puts "      0 at [format %0.6e $t1p], @Vgp@ at [format %0.6e $t2p], @Vgp@ at [format %0.6e $t3p], 0 at [format %0.6e $t4p],"
	      puts "	0 at [format %0.6e $t1e], @Vge@ at [format %0.6e $t2e], @Vge@ at [format %0.6e $t3e], 0 at [format %0.6e $t4e],"
	   set t1p [expr $t3e + 5e-3]
	 }
	 
	 )!
	 )}
           
	{Name="substrate" Voltage= 0}
	{Name="drain"	Voltage= 0}
	{Name="source"	Voltage= 0}
}

Physics {

#if _NLT_box_
	eBarrierTunneling "NLM_box" 
	hBarrierTunneling "NLM_box"
#endif

#if _NLT_tox_
	eBarrierTunneling "NLM_tox" 
	hBarrierTunneling "NLM_tox"
#endif

#if _NLT_mox_
	eBarrierTunneling "NLM_mox" 
	hBarrierTunneling "NLM_mox"
#endif

}

Physics(Material="Silicon") {
	Recombination(SRH(DopingDependence))
	Mobility(DopingDependence HighFieldSaturation)
}

#if _DonTraps_ || _AccTraps_

#if "@struct@" == "1CTL"
####################################
Physics(Region="R.Gatesn") {

	Traps(
#if _DonTraps_
	    (Donor Level EnergyMid= 3 FromConductionBand 
	    Conc= 1e19
	    eXSection= _TXsec_ hXSection= _TXsec_
#if _NLT_box_Traps_ && !_NLT_tox_Traps_
	    eBarrierTunneling(NonLocal= "NLM_box")
		 hBarrierTunneling(NonLocal= "NLM_box")
#elif !_NLT_box_Traps_ && _NLT_tox_Traps_
	    eBarrierTunneling(NonLocal= "NLM_tox")
	    hBarrierTunneling(NonLocal= "NLM_tox")
#elif _NLT_box_Traps_ && _NLT_tox_Traps_
	    eBarrierTunneling(NonLocal= "NLM_tox" NonLocal= "NLM_box")
	    hBarrierTunneling(NonLocal= "NLM_tox" NonLocal= "NLM_box")
#endif
        TrapVolume= _TV_
	   )
#endif

#if _AccTraps_
	   (Acceptor Level EnergyMid= _Emid_Acc_VB_ FromValenceBand 
	    Conc= 1e19
	    eXSection= _TXsec_ hXSection= _TXsec_
#if _NLT_box_Traps_ && !_NLT_tox_Traps_
	    eBarrierTunneling(NonLocal= "NLM_box")
		 hBarrierTunneling(NonLocal= "NLM_box")
#elif !_NLT_box_Traps_ && _NLT_tox_Traps_
	    eBarrierTunneling(NonLocal= "NLM_tox")
	    hBarrierTunneling(NonLocal= "NLM_tox")
#elif _NLT_box_Traps_ && _NLT_tox_Traps_ 
	    eBarrierTunneling(NonLocal= "NLM_tox" NonLocal= "NLM_box")
	    hBarrierTunneling(NonLocal= "NLM_tox" NonLocal= "NLM_box")
#endif
        TrapVolume= _TV_
        )
#endif

	)
}

#elif "@struct@" == "2CTLs"
####################################
Physics(Region="R.Gatesn") {

	Traps(
#if _DonTraps_
	    (Donor Level EnergyMid= 2.5 FromConductionBand 
	    Conc= 1e19
	    eXSection= 1e-13 hXSection= 1e-13
   #if _NLT_box_Traps_ && !_NLT_mox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_box")
		    hBarrierTunneling(NonLocal= "NLM_box")
   #elif !_NLT_box_Traps_ && _NLT_mox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_mox")
	       hBarrierTunneling(NonLocal= "NLM_mox")
   #elif _NLT_box_Traps_ && _NLT_mox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_box" NonLocal= "NLM_mox")
	       hBarrierTunneling(NonLocal= "NLM_box" NonLocal= "NLM_mox")
   #endif

        TrapVolume= _TV_
	   )
#endif

#if _AccTraps_
	   (Acceptor Level EnergyMid= 2.5 FromValenceBand 
	    Conc= 1e19
	    eXSection= 1e-13 hXSection= 1e-13
   #if _NLT_box_Traps_ && !_NLT_mox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_box")
		    hBarrierTunneling(NonLocal= "NLM_box")
   #elif !_NLT_box_Traps_ && _NLT_mox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_mox")
	       hBarrierTunneling(NonLocal= "NLM_mox")
   #elif _NLT_box_Traps_ && _NLT_mox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_box" NonLocal= "NLM_mox")
	       hBarrierTunneling(NonLocal= "NLM_box" NonLocal= "NLM_mox")
   #endif
        TrapVolume= _TV_
        )
#endif

	)
}

Physics(Region="R.Gatesn2") {

	Traps(
#if _DonTraps_
	    (Donor Level EnergyMid= 2.5 FromConductionBand 
	    Conc= 1e19
	    eXSection= 1e-13 hXSection= 1e-13
   #if _NLT_mox_Traps_ && !_NLT_tox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_mox")
		    hBarrierTunneling(NonLocal= "NLM_mox")
   #elif !_NLT_mox_Traps_ && _NLT_tox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_tox")
	       hBarrierTunneling(NonLocal= "NLM_tox")
   #elif _NLT_mox_Traps_ && _NLT_tox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_tox" NonLocal= "NLM_mox")
	       hBarrierTunneling(NonLocal= "NLM_tox" NonLocal= "NLM_mox")
   #endif

        TrapVolume= _TV_
	   )
#endif

#if _AccTraps_
	   (Acceptor Level EnergyMid= 1.0 FromConductionBand 
	    Conc= 1e19
	    eXSection= 1e-13 hXSection= 1e-13
   #if _NLT_mox_Traps_ && !_NLT_tox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_mox")
		    hBarrierTunneling(NonLocal= "NLM_mox")
   #elif !_NLT_mox_Traps_ && _NLT_tox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_tox")
	       hBarrierTunneling(NonLocal= "NLM_tox")
   #elif _NLT_mox_Traps_ && _NLT_tox_Traps_
	       eBarrierTunneling(NonLocal= "NLM_tox" NonLocal= "NLM_mox")
	       hBarrierTunneling(NonLocal= "NLM_tox" NonLocal= "NLM_mox")
   #endif
        TrapVolume= _TV_
        )
#endif

	)
}

#endif

#endif

CurrentPlot {
#if "@struct@" == "2CTLs"
	SpaceCharge(Average(Name="plot" Region="R.Gatesn" Region="R.Gatesn2"))
	eDensity(Average(Name="plot" Region="R.Gatesn" Region="R.Gatesn2"))
	hDensity(Average(Name="plot"  Region="R.Gatesn" Region="R.Gatesn2"))
	eTrappedCharge(Average(Name="plot" Region="R.Gatesn" Region="R.Gatesn2"))
	hTrappedCharge(Average(Name="plot"  Region="R.Gatesn" Region="R.Gatesn2"))
#else
	SpaceCharge(Average(Name="plot" Region="R.Gatesn"))
	eDensity(Average(Name="plot" Region="R.Gatesn"))
	hDensity(Average(Name="plot"  Region="R.Gatesn"))
	eTrappedCharge(Average(Name="plot" Region="R.Gatesn"))
	hTrappedCharge(Average(Name="plot"  Region="R.Gatesn"))
#endif
}	

Plot {
	eCurrent/Vector hCurrent/Vector
    ElectricField	
    eQuasiFermi hQuasiFermi EffectiveBandgap
	ConductionBandEnergy ValenceBandEnergy
    Doping SpaceCharge DonorConcentration AcceptorConcentration
	SRH Auger 
	eMobility hMobility
    eVelocity hVelocity
	eEparallel hEparallel	
	eDirectTunnel hDirectTunnel	
	eBarrierTunneling hBarrierTunneling	
	eTrappedCharge hTrappedCharge
   eGapStatesRecombination hGapStatesRecombination
   TrappingRates
	NonLocal
}

NonLocalPlot ((-12e-3 0) (0 0) ) { 
   eDensity hDensity
   ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy
   eBarrierTunneling hBarrierTunneling
   ElectrostaticPotential
	eTrappedCharge hTrappedCharge
}

NonLocalPlot ((0 0)) { 
   eDensity hDensity
   ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy
   eBarrierTunneling hBarrierTunneling
   ElectrostaticPotential
	eTrappedCharge hTrappedCharge
}

Math 	{

#if _NLM_box_
	NonLocal "NLM_box" (
		RegionInterface="R.Gateoxb/R.Substrate"
		Length= _Length_box_
		Digits= 4
		EnergyResolution= 1e-4
      -Endpoint(Material="Silicon")
		)		
#endif

#if _NLM_tox_
	NonLocal "NLM_tox" (
		RegionInterface="R.Gateoxt/R.Polygate"
		Length= _Length_tox_
		Digits= 4
		EnergyResolution= 1e-4
      -Endpoint(Material="PolySi")
		)	
#endif

#if _NLM_mox2_
	NonLocal "NLM_mox" (
		RegionInterface="R.Gateoxb2/R.Gatesn"
		Length= 9e-7
		Digits= 4
		EnergyResolution= 1e-4
      -Endpoint(region="R.Gatesn")
      Permeation = 3e-7
		)		
#endif

#if _NLM_mox_
	NonLocal "NLM_mox" (
		RegionInterface="R.Gatesn2/R.Gateoxb2"
		Length= 9e-7
		Digits= 4
		EnergyResolution= 1e-4
      -Endpoint(region="R.Gatesn2")
      #Permeation = 3e-7
		)		
#endif

*  CNormPrint
  	Iterations= 25
	Transient= BE
}

Solve {
# initial solution
	Set(TrapFilling= Empty)
    Coupled (Iterations= 100) { Poisson }
    Coupled (Iterations= 100) { Poisson Electron}
    Coupled (Iterations= 100 Digits= 8) { Poisson Electron Hole }
	
	Plot(FilePrefix="n@node@_Zero")

#if "@case@" != "NLM_tox" && "@case@" != "NLM_mox" 
    UnSet(TrapFilling)

	Transient(
	    InitialTime= 0 FinalTime= !(puts [expr $t1p])! 
	    InitialStep= 1e-7 Minstep= 1.e-10 MaxStep= 1e-2
   !(
   puts "TurningPoints ( 
      ([expr $t1p] 1e-7) ([expr $t2p] 1e-7) ([expr $t3p] 1e-9) ([expr $t4p] 1e-7)  
      ([expr $t1e] 1e-7) ([expr $t2e] 1e-7) ([expr $t3e] 1e-7) ([expr $t4e] 1e-7)  
      )"
      )!

	){ Coupled { Poisson Electron Hole } 

      !(		
	puts "Plot(FilePrefix=\"n@node@_programmed\" Time=([format %0.6e [expr $t3p]]))"
	puts "Plot(FilePrefix=\"n@node@_programmed_no_bias\" Time=([format %0.6e [expr $t1e]]))"
	puts "Save(FilePrefix=\"n@node@_programmed\" Time=([format %0.6e [expr $t1e]]))"
	puts "Plot(FilePrefix=\"n@node@_erased\" Time=([format %0.6e [expr $t3e]]))"
	puts "Plot(FilePrefix=\"n@node@_erased_no_bias\" Time=([format %0.6e [expr $t1p]]))"
	puts "Save(FilePrefix=\"n@node@_erased\" Time=([format %0.6e [expr $t1p]]))"  
        )!
	}
#endif

}
		
