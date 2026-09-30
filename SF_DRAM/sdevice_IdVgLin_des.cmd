#setdep @previous@

#define _Vdd_  1.2
#define _TAT_ ElectricField(Lifetime=Hurkx)

Electrode{
  { Name= "SC"   	   Voltage= 0.0 }
  { Name= "BL"  	    Voltage= 0.0 }
  { Name= "WL"   	   Voltage= 0.0 workfunction= 4.55 }
  { Name= "PG"   	   Voltage= 0.0 workfunction= 4.55 }  
  { Name= "substrate"       Voltage= 0.0 }
}

File{
  Grid= "@tdr@"
  Plot= "@tdrdat@"

  Parameter = "@parameter@"
  Current= "@plot@"
  Output= "@log@"
}

Physics {Fermi}

Physics (Material="Silicon") {
   eQuantumPotential(AutoOrientation density)
   Mobility (
	  Enormal ( IALmob(AutoOrientation) )
	  HighFieldSaturation  
	)
  
   EffectiveIntrinsicDensity(OldSlotboom)
   Recombination(SRH(DopingDep _TAT_ ) Band2Band(Model=Hurkx))
     
}


Plot{
*-Carrier Densities:
  eDensity hDensity
  * EffectiveIntrinsicDensity IntrinsicDensity
  * eEquilibriumDensity hEquilibriumDensity

*-Currents and current components:
  Current/Vector * eCurrent/Vector hCurrent/Vector
  * ConductionCurrent/Vector DisplacementCurrent/Vector
  * eMobility hMobility
  * eVelocity hVelocity

*-Fields, Potentials and Charge distributions
  ElectricField/Vector 
  Potential 
  SpaceCharge

*-Doping Profiles
  Doping 
  
*-Band structure
  * BandGap 
  * BandGapNarrowing
  * ElectronAffinity
  * ConductionBandEnergy ValenceBand
    eQuantumPotential hQuantumPotential
}

Math{
  Number_Of_Threads= 8
  Extrapolate
  Digits= 5
  Notdamped= 100
  Iterations= 20
  ExitOnFailure
  RHSMin= 1e-10
  RhsFactor= 1e20
  Method= ILS
  -CheckUndefinedModels
  
} 

Solve{
  Coupled(Iterations= 100 LineSearchDamping= 1e-4 ){ Poisson eQuantumPotential }
  Coupled { Poisson Electron eQuantumPotential }
 
 
#--Ramp BitLine (BL)


Quasistationary(
     InitialStep= 5e-2 Increment= 1.35
     MinStep= 1e-8 MaxStep= 0.1
     Goal{ Name= "BL" Voltage= 0.05 }
  ){ Coupled { Poisson Electron eQuantumPotential } }

  #-- Sweep WL 
  
  Quasistationary( 
    InitialStep= 1e-3 Increment= 1.25 Decrement= 1.25
    MinStep= 1e-8 MaxStep= 0.05 
    Goal { Name= "WL" Voltage= @<-0.05*_Vdd_>@ } 
  ){ Coupled { Poisson Electron eQuantumPotential } }
  
   
  NewCurrentFile= "IdVgLin_"
  Quasistationary(
    DoZero
    InitialStep= 1e-3 Increment= 1.25
     MinStep= 1e-8 MaxStep= 0.05
     Goal{ Name= "WL" Voltage= _Vdd_ }
  ){ Coupled { Poisson Electron eQuantumPotential } 
     CurrentPlot( Time=(Range= (0 1) Intervals= 40) )
   }
}

