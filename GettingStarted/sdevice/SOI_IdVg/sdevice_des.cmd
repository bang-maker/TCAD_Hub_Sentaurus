*----------------------------------------------------------------------
*-Setting global variable:
#set Vdd 1.5

*----------------------------------------------------------------------
*-Conditional setting of local variables:
#if @Vd@ < 0.1
#define _TRANSMOD_     * DriftDiffusion
#define _DRIVINGFORCE_ GradQuasiFermi
#define _B2BAVAL_      * No band-to-band and impact ionization
#define _EQUATIONS_    Poisson Electron Hole
#else 
#define _TRANSMOD_     Hydrodynamics( eTemperature )
#define _DRIVINGFORCE_ CarrierTempDrive
#define _B2BAVAL_      Band2Band(E2) Avalanche(CarrierTempDrive)
#define _EQUATIONS_    Poisson Electron Hole eTemperature 
#endif
*----------------------------------------------------------------------

Electrode {
  { Name="source"    Voltage= 0.0 Resistor= 40 }
  { Name="drain"     Voltage= 0.0 Resistor= 40 }
  { Name="gate"      Voltage=-0.1 }
  { Name="substrate" Voltage= 0.0 }
  *-Conditional inclusion of code:
  #if [string compare @Body@ "Tied"] == 0
  { Name="bodytie"   Voltage=0.0 eRecVelocity=0 }
  #endif
}

File {
  *-Predefined SWB parameters
  Grid    = "@tdr@"
  Plot    = "@tdrdat@"
  Current = "@plot@"
  Output  = "@log@"
  Param   = "@parameter@"
}

Physics {
  *-Using local variables:
  _TRANSMOD_
  eQCvanDort
  EffectiveIntrinsicDensity( OldSlotboom )     
  Recombination( SRH(DopingDep) )           
}

Physics(Material="Silicon") {
  Mobility(
    PhuMob
    eHighFieldsaturation( _DRIVINGFORCE_ )
    hHighFieldsaturation( GradQuasiFermi )
    Enormal
  )
  Recombination(
    SRH( DopingDep )
    _B2BAVAL_
  )  
}

Plot {
  *--Density and Currents, etc
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  
  *--Temperature 
  eTemperature * Temperature hTemperature
  
  *--Fields and charges
  ElectricField/Vector Potential SpaceCharge
  
  *--Doping Profiles
  Doping DonorConcentration AcceptorConcentration
  
  *--Generation/Recombination
  SRH Band2Band * Auger
  ImpactIonization eImpactIonization hImpactIonization
  
  *--Driving forces
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  
  *--Band structure/Composition
  BandGap 
  BandGapNarrowing
  Affinity
  ConductionBand ValenceBand
  
  *--Traps
  * eTrappedCharge  hTrappedCharge
  * eGapStatesRecombination hGapStatesRecombination
}

Math {
  Extrapolate
  Avalderivatives
  RelErrControl
  Digits=5
  ErrRef(electron)=1.e10
  ErrRef(hole)=1.e10
  Notdamped=50
  Iterations=20
  DirectCurrent
}

Solve {
  NewCurrentPrefix="init"
  Coupled(Iterations=100){ Poisson }
  Coupled{ Poisson Electron Hole }
  
  Quasistationary(
    InitialStep=1e-1 Increment=1.2
    Minstep=1e-5 MaxStep=0.1
    Goal{ Name="drain" Voltage= @Vd@ }
  ){ Coupled{ _EQUATIONS_ } }
  
  NewCurrentPrefix=""
  Quasistationary(
    DoZero
    InitialStep=5e-2 Increment=1.5
    Minstep=1e-5 MaxStep=0.05
    Goal{ Name="gate" Voltage= @Vdd@ }
  ){ Coupled{ _EQUATIONS_ }
    *-Arithmetic with variables: enforcing ~0.1V steps for all values of Vdd
    CurrentPlot( Time=(Range=(0 1) Intervals=@<int(Vdd/0.1)>@ )
    )
  }
}
