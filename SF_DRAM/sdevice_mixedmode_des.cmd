#setdep @node|sprocess@
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
  { Name= "WL"   	    Voltage= 0.0 workfunction= 4.55 }
  { Name= "PG"   	    Voltage= 0.0 workfunction= 4.55 }
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
   Recombination(SRH(DopingDep ElectricField(Lifetime=Hurkx) ) Band2Band(Model=Hurkx))
     
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
  RelErrControl
  Digits=5                  
  ErrRef(electron)= 1.0e10    
  ErrRef(hole)= 1.0e10        
  Iterations= 20
  Notdamped= 100
  ExitOnFailure
  Extrapolate
  Wallclock
  Transient= BE
  Method= Blocked
  SubMethod= ILS  
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
   DRAM dram( "BL"=bl "SC"=sc "WL"=wl "PG"= pg "substrate"=0 )
   Capacitor_pset Csc (sc cp) {capacitance= 10e-15} 
   Resistor_pset R0 (sc 0) {resistance= 1e20} 
  
   set(sc=0) 
   
**- Micron DDR4-083E (clock tick time tCK=0.83 nsec)
**- tRC=55 tCK ==> (tr=5+ton=40+tf=5+tWR=5)=55*0.83
**- WL=12 tCK  ==> (tr=1+ton=10+tf=1)=12*0.83
**- BL=8  tCK  ==> (tr=1+ton=6+tf=1)=8*0.83
**- tWRT_L=9  tCK  ==> READ-to-WRITE delay

*-Voltage source:
**- BL  OFF -> PRECHARGE -> ON --> PRECHAGE --> OFF
**-     10   5    15     1  16   1     7     5
   Vsource_pset vdd (bl bdc) {
   pulse = ( 0.0        # dc
             0.6        # amplitude
             30.0e-10   # td
             12.5e-10   # tr
             12.5e-10   # tf
             200.0e-10  # ton
             6.4 )      # period 
            }
   Vsource_pset vdc (bdc 0) { dc = 0.0}

**- Capacitor OFF -> PRECHARGE -> OFF
**-           10   5    40     5
   Vsource_pset vcp (cp 0) { dc = 0.0}
   Vsource_pset vpg (pg 0) { dc = 0.0}

**- WL OFF -> ON -> OFF
**-    30  1 10  1
   Vsource_pset vin (wl 0) { 
   pulse = ( 0.0       # dc
             1.2       # amplitude
             67.5e-10  # td
             12.5e-10  # tr
             12.5e-10  # tf
             125.0e-10 # ton
             6.4 )     # period 
           }
  
   *-Plot:
   Plot "n@node@_sys_des.plt" (time() v(bl) v(wl) v(pg) v(sc) v(cp) 
                              i(dram,bl) i(dram,sc) )
}

Solve {

  Coupled{ Poisson	Circuit}

  Coupled(Iterations=100){ Poisson dram.eQuantumPotential	Circuit}

  ## Precharge
  NewCurrentFile= "PreCharge_"
	Quasistationary (
		InitialStep= 1e-6 Increment= 1.5
		Minstep= 1e-11 MaxStep= 0.1
		Goal { parameter=vdc.dc Voltage= 0.6 }
		Goal { parameter=vcp.dc Voltage= 0.6 }
	){ Coupled {Poisson dram.eQuantumPotential dram.Electron Contact Circuit } }
  
  Unset(sc)

  NewCurrentFile= "Write_"
  Transient (
     InitialTime=0 FinalTime=285.0e-10 
     InitialStep=1e-11 Increment=1.3 decrement=2.1
     MaxStep=1e-3 MinStep=1e-15
  ){ Coupled{ Poisson dram.eQuantumPotential dram.Electron Contact Circuit } }
   
}


