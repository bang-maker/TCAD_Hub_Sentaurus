#setdep @node|sprocess@

#if @IdVg@ == 0
#noexec
#endif


!( 

if {"@DEV_TYPE@"=="nMOS" } {
	set SIGN   1.0
	set DG   "eQuantumPotential"
	set EQN  "Poisson eQuantumPotential Electron Hole"
} else {
	set SIGN   -1.0
	set DG   "hQuantumPotential"
	set EQN  "Poisson hQuantumPotential Electron Hole"	
}

if {"@bulkBias@"=="on"} {
	set ListOfVbs { 0.0 0.5 1.0 1.5 2.0 2.5 } 
} else {
	set ListOfVbs { 0 }
}


set biasCondition @Vdrain@

if {$biasCondition=="sat"} {
	set Vd @Vdd@
} else {
	set Vd 0.1
}


set Vd [expr $SIGN * $Vd]

)!

File {
       grid=      "@tdr@"
       current=   "@plot@"
       output=    "@log@"
       plot=      "@tdrdat@"
       parameter= "@parameter@"
     }

Electrode {
            { name= "source" voltage= 0.0 } 
	        { name= "drain"  voltage= 0.0 } 
            { name= "gate"   voltage= 0.0 Barrier= @barrier@ } 
            { name= "bulk"   voltage= 0.0 }
          }
  
Physics{
   area= @W@
   EffectiveIntrinsicDensity( OldSlotboom )     
}

Physics (Material= "Silicon") {
      Recombination(Auger SRH(DopingDep)  ) 
      Mobility (Phumob Enormal HighFieldSat)
      
}

Physics ( MaterialInterface= "Oxide/Silicon" ) {
	Traps ( FixedCharge Conc= @Nint@ )
}

Physics(Region= "channel"){
      Recombination(Auger SRH(DopingDep)  )
      Mobility (Phumob Enormal HighFieldSat) 
      !(puts $DG)!       
}




Math {
   Extrapolate
   Derivatives
   Notdamped= 50
   Iterations= 12 
   method= ParDiSo   
   RelErrControl   
   eDrForceRefDens= 1e12
   hDrForceRefDens= 1e12     
   AvalDerivatives   
   eMobilityAveraging= ElementEdge
   hMobilityAveraging= ElementEdge
   ElementAvalancheMinAngle= 0 
   Number_Of_Threads= 4
}


Plot{
   TotalCurrent eCurrent/Vector hCurrent/Vector
   eDensity hDensity
   ElectricField/Vector
   eQuasiFermi hQuasiFermi
   eGradQuasiFermi/Vector hGradQuasiFermi/Vector
   Potential Doping SpaceCharge
   SRH Auger Avalanche
   eMobility hMobility
   BandGap BandGapNarrowing
   Affinity
   ConductionBand ValenceBand
   eTrappedCharge  hTrappedCharge
   eGapStatesRecombination hGapStatesRecombination
   Avalanche
   LatticeTemperature
}


Solve {	
        Poisson
        Coupled {Poisson !(puts "$DG" )!}
        Coupled (Iterations= 100 LineSearchDamping= 1e-2) {!(puts "$EQN" )!}   
	Quasistationary (
        InitialStep= 1e-4 MaxStep= 0.1 MinStep= 1e-6
!(
        puts "  Goal {name= drain voltage= $Vd }"
)!
        )
    {coupled (Iterations= 100 LineSearchDamping= 1e-2) { !(puts "$EQN" )! } }  


!(
set helpVgb 0

puts "\n######## Bulk bias ramps  ########\n"

foreach vgb $ListOfVbs {
	set vgb [expr -$vgb * $SIGN]
	puts "\n# --- Vb ramp up for bias Vb=$vgb --- #\n"
	puts "Quasistationary ("
	puts "InitialStep = 0.001" 
	puts "Minstep     = 1.0e-5" 
	puts "MaxStep     = 0.1"
	puts "Goal { name = bulk  Voltage = $vgb }"
	puts [format ") { Coupled (Iterations= 100 LineSearchDamping= 1e-2) { %s  } }" $EQN ]
	puts "save(FilePrefix=\"n@node@_Vb=$vgb\")"
}

puts "\n######## IdVg ramp ups for gate voltage ########\n"

set gateVoltage [expr $SIGN * 5.0]

foreach vgb $ListOfVbs {
	set vgb [expr -$vgb * $SIGN]
	puts "\n# --- Vg ramp for bulk bias Vb=$vgb --- #\n"
	puts "Load(FilePreFix=\"n@node@_Vb=$vgb\")"
	puts "NewCurrent=\"n@node@_IdVg_Vb_$vgb\""
	puts "Quasistationary ("
	puts "InitialStep = 1e-4" 
	puts "Minstep     = 1.0e-5" 
	puts "MaxStep     = 0.01"
	puts "Goal { name = gate Voltage = $gateVoltage}"
	puts [format ") { Coupled (Iterations= 100 LineSearchDamping= 1e-2) { %s } }" $EQN]

}
)!

}



