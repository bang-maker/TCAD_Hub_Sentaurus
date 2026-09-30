#setdep @previous@

Device DRAM{
  File{
     Grid= "@tdr|sprocess@"
     Plot= "@tdrdat@"
     Current= "@plot@"
  
     Parameter = "@parameter@"
  }

Electrode {
  { Name= "BL"  	     Voltage= 0.0 }
  { Name= "WL"   	    Voltage= 0.0 workfunction= 4.45 }
  { Name= "PG"   	    Voltage= 0.0 workfunction= 4.45 }
  { Name= "SC"   	    Voltage= 0.0 workfunction= 4.32 }  
  { Name= "substrate" Voltage= 0.0 }
}


Physics {Fermi}
Physics (Material="Silicon") {
   eQuantumPotential(AutoOrientation density)
   Mobility (
	  Enormal ( IALmob(AutoOrientation) )
	  HighFieldSaturation 
	)
  
   EffectiveIntrinsicDensity(OldSlotboom)
   Recombination(SRH(DopingDep ElectricField(Lifetime=Hurkx)) Band2Band(Model=Hurkx))
     
}

} * End of Device{}

Plot{

   eDensity hDensity
   TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
   eMobility hMobility
   eVelocity hVelocity
   eQuasiFermi hQuasiFermi
   eTemperature Temperature * hTemperature
   ElectricField/Vector Potential SpaceCharge
   SRH Band2Band * Auger
   AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
   eGradQuasiFermi/Vector hGradQuasiFermi/Vector
   eEparallel hEparallel eENormal hENormal
   ConductionBand ValenceBand
   
}

Math {  
  ExtendedPrecision
  Digits= 7
  RelErrControl                
  ErrRef(electron)= 1.0e8    
  ErrRef(hole)= 1.0e8        
  Iterations= 20
  Notdamped= 100
  ExitOnFailure
  Extrapolate
  Wallclock
  Transient= BE
  Method= Blocked
  SubMethod = ILS 
  NoCheckTransientError
  RHSmin= 1e-10
  RhsFactor= 1e20
  Number_of_Threads= 8
  -CheckUndefinedModels 
}

File {
   Output    = "@log@"
}

System {
 
   *-Physical devices:
   DRAM dram( "BL"=bl "SC"=sc "WL"=wl "PG"=pg "substrate"=0 )
   Capacitor_pset Csc (sc 0) {capacitance= 10e-15}

   Vsource_pset vsc (sc 0) { dc = 0.0 }
   Vsource_pset vin (wl 0) { dc = 0.0 }
   Vsource_pset vip (pg 0) { dc = 0.0 }
   Vsource_pset vdd (bl 0) { dc = 0.0 }
   
   *-Plot:
   Plot "n@node@_sys_des.plt" (time() v(bl) v(wl) v(sc) v(pg) 
                              i(dram,bl) i(dram,sc) )
}

Solve {

  Coupled{ Poisson	Circuit}
  Coupled(Iterations=100){ Poisson eQuantumPotential Circuit}
  Coupled(Iterations=100){ Poisson dram.eQuantumPotential dram.Electron Circuit}
  Quasistationary (
		InitialStep= 1e-6 Increment= 1.5
		Minstep= 1e-12 MaxStep= 0.1
                Goal { parameter= vsc.dc Voltage= @<0.95*Vmax>@ }
	){ Coupled {Poisson dram.eQuantumPotential dram.Electron Contact Circuit } }

  NewCurrentFile= "IdVSC_"
	Quasistationary (
		InitialStep= 1e-6 Increment= 1.5
		Minstep= 1e-12 MaxStep= 0.01
                Goal { parameter= vsc.dc Voltage= @Vmax@ }
	){ Coupled {Poisson dram.eQuantumPotential dram.Electron Contact Circuit } }
     CurrentPlot( Time=(Range= (0 1) Intervals= 50) )
   
}


