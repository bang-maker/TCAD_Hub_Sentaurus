#setdep @previous@

#define _tend_ 1
#define _Vdd_ 1e12
#define _Res_ @res@

#define _AvaModel_ @amodel@

Electrode { 
  { Name= "anode"  Voltage= 0.0 Resist= 0.001 Material="PolySi"(N=1e20) } 
  { Name= "cathode" Voltage= (0.0 at 0, _Vdd_ at _tend_) Resist=_Res_ }
}

File {
  Grid    = "@tdr@"
  Plot    = "@tdrdat@"
  Current = "@plot@"
  Output  = "@log@"
  Param   = "@parameter@"
}

Physics {
  AreaFactor= @areafactor@
  Temperature=300.
  Fermi
  DefaultParametersFromFile
  Recombination (
    SRH(DopingDependence TempDependence)
    Auger
    Avalanche(_AvaModel_)
  )  
  Mobility ( 
    DopingDependence
    HighFieldSaturation
    Enormal
  )
  IncompleteIonization (
    Split (
      Doping = "NitrogenConcentration"
      Weights = (0.5 0.5)
    )
  )
  EffectiveIntrinsicDensity ( Slotboom NoFermi )
  
  #if @aniso@   
  #seth miscut_rad @<(90-miscut)*atan(1)/45>@
  #seth dx @[format %.3f @<sin(miscut_rad)>@ ]@
  #seth dy @[format %.3f @<cos(miscut_rad)>@ ]@
   
  Aniso (
    Mobility 
    Poisson
    Avalanche
    direction(SimulationSystem)= (@dx@ @dy@ 0)
  )
  #endif   

}

Physics(MaterialInterface= "SiliconCarbide/Oxide") {
  Traps (FixedCharge Conc=5e10
    Add2TotalDoping
  )
}

Plot {
  Potential SpaceCharge
  eDensity hDensity
  eCurrent hCurrent TotalCurrent/vector CurrentPotential
  ElectricField/vector
  eQuasiFermi hQuasiFermi
  egradQuasiFermi hgradQuasiFermi
  SRH Auger
  ImpactIonization eImpactIonization hImpactIonization
  eMobility hMobility
  eMobilityAniso hMobilityAniso
  eMobilityAnisoFactor hMobilityAnisoFactor
  DielectricConstant DielectricConstantAniso
  Doping DonorConcentration DonorPlusConcentration AcceptorConcentration AccepMinusConcentration
  NitrogenConcentration_split1 NitrogenActiveConcentration_split1 NitrogenPlusConcentration_split1
  NitrogenConcentration_split2 NitrogenActiveConcentration_split2 NitrogenPlusConcentration_split2
  AluminumConcentration AluminumActiveConcentration
  ConductionBandEnergy ValenceBandEnergy BandGap
}

Math {  
  Number_of_threads= 4
  Wallclock
  ExitOnFailure
  #if @extra@ == 1
  Extrapolate 
  #elif @extra@ == 2
  Extrapolate(order=2)
  #endif
  Digits=5
  ErrRef(electron)= 1e-2
  ErrRef(hole)= 1e-2
  RHSmax= 1e70
  RHSFactor= 1e120
  #if @update@   
  RhsAndUpdateConvergence 
  RHSmin= 1e-3
  #else
  RHSmin= 1e-30
  #endif   
  CdensityMin= 1e-20
  Notdamped= 100
  Iterations= 15
  ExtendedPrecision(@EP@)
  Method=Blocked
  #if "@slae@" == "ILS"
  SubMethod= ILS(set=25)  
  #else
  SubMethod= Super
  #endif
  ILSrc= "set (25) {
    iterative(gmres(100), tolrel=1e-10, tolunprec=1e-4, tolabs=0, maxit=200);
    preconditioning(ilut(1.5e-6,-1), right);
    ordering(symmetric=nd, nonsymmetric=mpsilst);
    options(compact=yes, linscale=0, refineresidual=10, verbose=0);
  };"
  Transient= BE
  #if @aniso@   
  TensorGridAniso(aniso)
  #endif
  ComputeGradQuasiFermiAtContacts = UseQuasiFermi
  RefDens_eGradQuasiFermi_ElectricField_HFS= 1e14
  RefDens_hGradQuasiFermi_ElectricField_HFS= 1e14
  -PlotLoadable
}

Solve {
  Coupled(Iterations= 1000 LineSearchDamping= 1e-2){ Poisson }
  Coupled(Iterations= 100)  { Poisson Electron Hole }
  
  NewCurrent = "BV_"
  Transient (
    InitialTime= 0 FinalTime= _tend_  
    InitialStep= @<_tend_*1e5/abs(_Vdd_)>@ MinStep = @<_tend_*1e-14>@ Maxstep= @<_tend_*0.05>@ 
    Increment= 1.4 Decrement= 2
    BreakCriteria { Current(Contact = "cathode" Absval = 0.1) }
  ) { coupled { Poisson Electron Hole }  }
  System ("rm n@node@_des.plt")   
}  

