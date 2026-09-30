#define _Idmax_ 1.3e-3
#define _tend_ 1.

#if "@BVmethod@" == "ABA_poisson"
#define _EQUATIONSET_   Poisson 
#else
#define _EQUATIONSET_   Poisson Electron Hole
#endif

#if "@BVmethod@" == "resistor" || "@BVmethod@" == "transient"
#define _Vdd_ 100000.
#elif [string match "*ABA*" "@BVmethod@"]
#define _Vdd_ 100.
#else
#define _Vdd_ 10.
#endif

File{
  Grid      = "@tdr@"
  Plot      = "@tdrdat@"
  Parameter = "@parameter@"
  Current   = "@plot@"
  Output    = "@log@"
}

Electrode{
  #if "@BVmethod@" == "resistor"
  { Name="drain"     Voltage=0.0 Resistor= 1e7  }
  #elif "@BVmethod@" == "transient"
  { Name="drain" Voltage=0.0 Voltage=(0. at 0., _Vdd_ at _tend_) Resistor= 1e7 }
  #else
  { Name="drain"     Voltage=0.0 }
  #endif   
  { Name="source"    Voltage=0.0 }
  { Name="gate"      Voltage=0.0 Barrier= -0.55 }
  { Name="substrate" Voltage=0.0 }
}

Physics{
  
  #if "@BVmethod@" == "ABA_poisson"
  Recombination(
    Avalanche(ElectricField)
  )
  #else   
  EffectiveIntrinsicDensity( OldSlotboom )     
  Mobility(
    DopingDep
    HighFieldsaturation( GradQuasiFermi )
    Enormal
  )
  Recombination(
    SRH( DopingDep )
    Band2Band(Model= NonLocalPath)
    Avalanche( GradQuasiFermi )
  )
  #endif
  Fermi
}

#if "@BVmethod@" == "ABA_coupled"
CurrentPlot {
  ImpactIonization (Integrate(Semiconductor))
}
#endif


#if "@BVmethod@" == "transient"
CurrentPlot {
  ImpactIonization(Maximum(Semiconductor Coordinates))
  ElectricField   (Maximum(Semiconductor Coordinates))
}
#endif


Plot{
  *--Density and Currents, etc
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  *--Fields and charges
  ElectricField/Vector Potential SpaceCharge
  
  *--Doping Profiles
  Doping 
  
  *--Generation/Recombination
  SRH Band2Band * Auger
  ImpactIonization eImpactIonization hImpactIonization
  eIonIntegral hIonIntegral MeanIonIntegral eAlphaAvalanche hAlphaAvalanche
}

Math {
  #if ![string match "*transient*" "@BVmethod@"]
  Extrapolate
  #endif  
  Iterations=20
  Notdamped =100
  RelErrControl
  #if [string match "*ABA*" "@BVmethod@"]
  ComputeIonizationIntegrals ( )
  BreakAtIonIntegral(1 1.1)
  #if "@BVmethod@" == "ABA_coupled"
  AvalPostProcessing
  #endif
  #else
  AvalDerivatives
  ErrRef(Electron)=1.e10
  ErrRef(Hole)=1.e10
  BreakCriteria{ Current(Contact="drain" AbsVal=_Idmax_) } 
  #endif  
  Transient=BE
}

#if [string match "*ABA*" "@BVmethod@"]
Solve {
  *- Build-up of initial solution:
  Coupled(Iterations=100){ Poisson }
  Coupled { Poisson Electron Hole }
  
  Quasistationary(
    InitialStep=@<1e-2/100>@ Increment=1.41 
    MinStep=@<1e-5/100>@ MaxStep=0.025
    Goal{ Name="drain" Voltage=_Vdd_ }
  ) { Coupled { _EQUATIONSET_ } }
}
#elif "@BVmethod@" == "resistor"
Solve {
  *- Build-up of initial solution:
  Coupled(Iterations=100){ Poisson }
  Coupled { Poisson Electron Hole }
  
  Quasistationary(
    InitialStep=@<1e-2/100000>@ Increment=1.41 
    MinStep=@<1e-5/100000>@ MaxStep=0.025
    Goal{ Name="drain" Voltage=_Vdd_ }
  ) { Coupled { _EQUATIONSET_ } }
}
#elif "@BVmethod@" == "voltage2current"
Solve {
  *- Build-up of initial solution:
  Coupled(Iterations=100){ Poisson }
  Coupled { Poisson Electron Hole }
  
  Quasistationary(
    InitialStep=@<1e-2/5.0>@ Increment=1.41 
    MinStep=@<1e-5/5.0>@ MaxStep=0.025
    Goal{ Name="drain" Voltage=6. }
  ) { Coupled { _EQUATIONSET_ } }
  
  Set ("drain" mode current)
  QuasiStationary ( 
    InitialStep=1e-6 Maxstep=0.05 MinStep=1e-9 Increment=1.41 
    Goal { name=drain current=_Idmax_ }
  ) { Coupled { _EQUATIONSET_ } }
}
#elif "@BVmethod@" == "continuation"
Solve {
  *- Build-up of initial solution:
  Coupled(Iterations=100){ Poisson }
  Coupled { Poisson Electron Hole }
  
  Continuation(
    Name="drain"                     * Curve is traced at this electrode
    InitialVStep=0.1                 * Initial voltage step
    Increment=1.41 Decrement=2
    MaxVstep=0.25                    * Limits voltage step along curve trace
    NewArc
    MinVoltage=-0.001 MaxVoltage=100 * Define the I-V window where
    MinCurrent=0 MaxCurrent=_Idmax_  * IV curve is traced
    Vadapt=2.0                       * Up to this voltage, a Quasistationary
                                     * with voltage ramping is used instead
                                     * of continuation
    Iadapt=1e-8                      * Up to this current, a Quasistationary
                                     * with voltage ramping is used instead
                                     * of continuation
  ) { Coupled { _EQUATIONSET_ } }
}
#elif "@BVmethod@" == "transient"
Solve {
  *- Build-up of initial solution:
  Coupled(Iterations=100){ Poisson }
  Coupled { Poisson Electron Hole }
  
  Transient (
    InitialTime= 0. FinalTime= _tend_
    InitialStep= @<_tend_*0.1/_Vdd_>@ Increment= 1.41
    Minstep= @<_tend_*1e-5/_Vdd_>@  MaxStep= @<_tend_/100.>@ 
  ) { Coupled { _EQUATIONSET_ } }
}
#endif
