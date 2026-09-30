#setdep @node|sprocess@

#if @IdVd@ == 0
#noexec
#endif

!( 

set Vd 5.0
set biases { 0.5 1.0 1.5 2.0 2.5 3.0 } 

if {"@DEV_TYPE@"=="nMOS" } {
	set SIGN   1.0
	set DG     "eQuantumPotential"
	set EQN   "Poisson  Electron Hole eQuantumPotential"  
} else  {
	set SIGN   -1.0
	set DG     "hQuantumPotential"
	set EQN   "Poisson  Electron Hole hQuantumPotential"  
}

set Vd [expr $Vd * $SIGN]


)!

File {
   Grid=      "@tdr@"
   Parameter= "@parameter@"
   Plot=      "@tdrdat@"
   Current=   "@plot@"
   Output=    "@log@"
}

Electrode {
   { Name= "source"    	Voltage= 0.0 }
   { Name= "drain"     	Voltage= 0.0 }
   { Name= "gate"      	Voltage= 0.0 Barrier= @barrier@ }
   { Name= "bulk"    	Voltage= 0.0 }
   
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



Insert= "PlotSection_des.cmd"


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


solve { NewCurrentPrefix= "n@node@"

               Coupled { poisson }
               Coupled (Iterations= 100 LineSearchDamping= 1e-2){ Poisson !(puts $DG)! } 
               Coupled (Iterations= 100 LineSearchDamping= 1e-2){ !(puts $EQN )! }
	       save(FilePrefix= "n@node@_Vg=0.0")
	       NewCurrentPrefix= "n@node@"

!(


set ListOfVgs $biases
set helpVgs 0.0

foreach vgs $ListOfVgs {
	set vgs [expr $vgs * $SIGN]
	puts "load(FilePrefix=\"n@node@_Vg=$helpVgs\")"
	puts "Quasistationary ("
	puts "InitialStep = 0.001" 
	puts "Minstep     = 1.0e-5" 
	puts "MaxStep     = 0.1"
	puts "Goal { name = gate  Voltage = $vgs }"
	puts [format ") { Coupled (Iterations=100 LineSearchDamping=1e-2) { %s } }" $EQN]
	set helpVgs $vgs
	puts "save(FilePrefix=\"n@node@_Vg=$vgs\")"
	puts "NewCurrentPrefix=\"n@node@_Vg=$vgs\""
	puts "Quasistationary ("
	puts "InitialStep = 0.001" 
	puts "Minstep     = 1.0e-5" 
	puts "MaxStep     = 0.1"
	puts "Goal { name = drain  Voltage = $Vd }"
	puts [format ") { Coupled (Iterations=100 LineSearchDamping=1e-2) { %s } }" $EQN]	
	puts "NewCurrentPrefix=\"n@node@\""
	puts "* ---------------------------------------"
}


)!

}



