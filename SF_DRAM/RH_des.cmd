#setdep @node|sprocess@ 

#define _Vcore_  1.2 
#define _Vcore2_ 0.6
#define _Vth_    0.8
#define _Vod_    1.2
#define _Vbbw_   0.0
#define _Carrier_ dram.Electron dram.Hole
#define _TAT_ ElectricField(Lifetime=Hurkx)

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
       hQuantumPotential(AutoOrientation density)
   Mobility (
	  Enormal ( IALmob(AutoOrientation) )
	  HighFieldSaturation 
	)
  
   EffectiveIntrinsicDensity(OldSlotboom)
   Recombination( SRH(DopingDep _TAT_)
  		  Band2Band(Model=Hurkx) 
		)
}

Physics( RegionInterface= "SiTr_1/Oxide_2" ){
   GateCurrent(Fowler)
   Traps(
   (Acceptor Gaussian fromMidBandGap Conc=@conc@ EnergyMid=0 EnergySig=0.1 
   eXsection=1e-8 hXsection=1e-8)
         )      
}

Physics( Region= "SiTr_1" ){	
   Traps(
   (Acceptor Gaussian fromMidBandGap Conc=@conc@ EnergyMid=0 EnergySig=0.1 
   eXsection=1e-8 hXsection=1e-8)
  	)
}

} * End of Device{}


Plot{

   Doping DonorConcentration AcceptorConcentration
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
   BandGap
   BandGapNarrowing 
   eTrappedCharge hTrappedCharge
   eInterfaceTrappedCharge hInterfaceTrappedCharge
   TotalTrapConcentration
}

Math {
  
  RelErrControl
  Digits= 4                  
  ErrRef(electron)=1.0e8    
  ErrRef(hole)=1.0e8        
  Iterations=20
  Notdamped=100
  ExitOnFailure
  Extrapolate
  Wallclock
  Transient=BE
  Method=Blocked
  SubMethod= ILS(Set=2)       
  NoCheckTransientError
  RHSmin= 1e-15
  RhsFactor= 1e20
  Number_of_Threads= 8
  -CheckUndefinedModels 

  RefDens_eGradQuasiFermi_EparallelToInterface_HFS= 1e12
  RefDens_hGradQuasiFermi_EparallelToInterface_HFS= 1e12
}

File {
   Output    = "@log@"
}

System {
   
   *-Physical devices:
   DRAM dram( "BL"=bl "SC"=sc "WL"=wl "PG"= pg "substrate"=0 )   
   Capacitor_pset Csn (sc 0) {capacitance= 10e-15}
   Capacitor_pset Cbl (bl 0) {capacitance= 45e-15}
    
   
   Set(sc=0)    
   Set(bl=0)
   #define _td_   6.75e-9
   #define _tr_   1.25e-9
   #define _tf_   1.25e-9
   #define _ton_  @Ton@
   #define _pd_   @<_tr_+_ton_+_tf_+_ton_>@

 
   *-Voltage source:
   Vsource_pset vwl (wl 0) { dc = 0.0 }
   Vsource_pset vpg (pg bbw) {
    pulse = ( 0.0       # dc
              2.2       # amplitude: need overdrive, _Vcore_+_Vth_*_Vod_
             _td_       # td
             _tr_       # tr
             _tf_       # tf
             _ton_      # ton
             _pd_       # period 
           ) 
   }
   Vsource_pset vbbw (bbw 0) { dc = 0.0 }

   *-Plot:
   Plot "n@node@_sys_des.plt" (time() v(bl) v(wl) v(pg) v(sc)
                              i(dram,bl) i(dram,pg) i(dram,sc) )
}

Solve {
  
  Coupled(Iterations=100){ Poisson Circuit }
  Coupled(Iterations=100){ Poisson _Carrier_ Circuit }
  
  ## Precharge
  NewCurrentFile= "PreCharge_"
	Quasistationary (
	      InitialStep= 1e-6 Increment= 1.5
	      Minstep= 1e-12 MaxStep= 0.1           
              Goal { Node="bl" Voltage= _Vcore2_ }
              Goal { Node="sc" Voltage= 0.0 }
	                 
   	){ Coupled {Poisson _Carrier_ Contact Circuit} }

  Unset(sc)
  Unset(bl)

  NewCurrentFile= "rh_"
  Transient (
     InitialTime=0 FinalTime= 1.0e-7 
     InitialStep=1e-11 Increment=1.3 decrement= 2.1
     MaxStep=1e-3 MinStep=1e-15
     ){ Coupled {Poisson _Carrier_ Contact Circuit} 
          
     Plot(FilePrefix="n@node@_t0"  time=(0.0) )
     Plot(FilePrefix="n@node@_t1"  time=(@<_td_+_tr_+_ton_>@) )
     Plot(FilePrefix="n@node@_t2"  time=(@<_td_+_tr_+_ton_+_tf_>@) )
     Plot(FilePrefix="n@node@_t3"  time=(@<_td_+_tr_+_ton_+_tf_+_tf_/5>@) )
     Plot(FilePrefix="n@node@_t4"  time=(@<_td_+_tr_+_ton_+_tf_+_tf_/2>@) )
     Plot(FilePrefix="n@node@_t5"  time=(1.0e-7) )
     }
}

