
#if "@Type@"=="nMOS"
#define  _GateCurrentModel_  eFiegna
#define  _VdLin 0.05
#define  _VdSat 1.00
#define  _Vg    @<Vg>@
#define  _QC_   eQuantumPotential
#define  _CAR_  Electron Hole
#elif "@Type@"=="pMOS"
#define  _GateCurrentModel_  hFiegna
#define  _VdLin -0.05
#define  _VdSat -1.00
#define  _Vg    @<-Vg>@
#define  _QC_   hQuantumPotential
#define  _CAR_  Electron Hole
#endif


Electrode {
  { name="drain"             Voltage= 0.0}
  #if "@Type@"=="nMOS"
  { name="gate" Material = "PolySi"(N)  Voltage= 0.0}
  #elif "@Type@"=="pMOS"
  { name="gate" Material = "PolySi"(P)  Voltage= 0.0}
  #endif
  { name="source"            Voltage= 0.0}
  { name="substrate"         Voltage= 0.0}
}


File {
  Grid      = "@tdr@"
  Piezo     = "@tdr@"
  Plot      = "@tdrdat@"
  Parameter = "@parameter@"
  Current   = "@plot@"
  Output    = "@log@"
}


Physics {
  DefaultParametersFromFile
  EffectiveIntrinsicDensity(OldSlotboom )
}

Physics (material= "Silicon") {
  #if @[string match @Type@ "nMOS"]@
  eQuantumPotential
  eMultiValley(MLDA kpDOS -Density)
  #elif @[string match @Type@ "pMOS"]@
  hQuantumPotential
  hMultiValley(MLDA kpDOS -Density)
  #endif
  
  Mobility(
    Enormal ( IALMob( AutoOrientation ) Lombardi_highk )
    HighFieldSaturation( EparallelToInterface )
  )
  
  Piezo(
    Model(
      DeformationPotential(ekp hkp minimum)
      DOS( emass hmass )
      
      #if @[string match @Type@ "nMOS"]@
      Mobility( eSubband(Fermi  EffectiveMass Scattering(MLDA) )
        eSaturationFactor= 0.0
      )
      #elif @[string match @Type@ "pMOS"]@
      Mobility( hSubband(Doping EffectiveMass Scattering(MLDA) )
        hSaturationFactor= 0.0
      )
      #endif
    )
  )
  
  Recombination(
    SRH(DopingDependence TempDependence) 
    Auger 
  Band2Band(Model=Schenk) )
}



Physics(Material="PolySilicon") {
  Mobility(
    PhuMob
    HighFieldSaturation( GradQuasiFermi )
  )
  
  Recombination(SRH(DopingDependence))
}

Physics (MaterialInterface="Silicon/Oxide") {
  GateCurrent(GateName= "gate" _GateCurrentModel_)
}


Plot{
  
  *--Density and Currents, etc
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  
  *--Temperature 
  Temperature * eTemperature  hTemperature
  
  *--Fields and charges
  ElectricField/Vector Potential SpaceCharge
  
  *--Doping Profiles
  Doping DonorConcentration AcceptorConcentration
  
  *--Generation/Recombination
  SRH Auger # Band2Band  
  ImpactIonization eImpactIonization hImpactIonization
  
  *--Driving forces
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  
  *--Band structure/Composition
  BandGap 
  BandGapNarrowing
  * Affinity
  ConductionBand ValenceBand
  eQuantumPotential hQuantumPotential
  
  StressXX StressXY StressXZ StressYY StressYZ StressZZ
}


Math {
  CoordinateSystem { AsIs }
  Extrapolate
  Notdamped= 50
  Iterations= 15
  ExitOnFailure
  
  eMobilityAveraging= ElementEdge        # uses edge mobility instead of element one for electron mobility
  hMobilityAveraging= ElementEdge        # uses edge mobility instead of element one for hole mobility
  GeometricDistances                     # when needed, compute distance to the interface instead of closest point on the interface
  
  EnormalInterface( MaterialInterface= "Oxide/Silicon" )    
  
}

Solve {
  Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson _QC_}
  Quasistationary(
    DoZero
    InitialStep= 1e-3 Increment= 1.5 
    MinStep= 1e-6 MaxStep= 0.025
    Goal { Name= "drain"  Voltage= _VdLin }
  ){ Coupled { Poisson _CAR_ _QC_} }
  Save ( FilePrefix= "n@node@_VdLin" )
  
  Quasistationary( 
    InitialStep= 1e-3 Increment= 1.5 
    MinStep= 1e-6 MaxStep= 0.025
    Goal { Name= "drain"  Voltage= _VdSat }
  ){ Coupled { Poisson _CAR_ _QC_} }
  Save ( FilePrefix= "n@node@_VdSat" )
  
  #-- Vg sweep for Vd=VdLin
  NewCurrentPrefix= "IdVg_VdLin_" 
  Load ( FilePrefix= "n@node@_VdLin" )
  Quasistationary( 
    DoZero 
    InitialStep= 1e-3 Increment= 1.35 
    MinStep= 1e-6 MaxStep= 0.025
    Goal { Name= "gate" Voltage= _Vg }
    
  ){ Coupled { Poisson _CAR_ _QC_} }
  
  #-- Vg sweep for Vd=VdSat
  NewCurrentPrefix= "IdVg_VdSat_" 
  Load ( FilePrefix= "n@node@_VdSat" )
  Quasistationary( 
    DoZero 
    InitialStep= 1e-2 Increment= 1.35 
    MinStep= 1e-6 MaxStep= 0.025
    Goal { Name= "gate" Voltage= _Vg }
    
  ){ Coupled { Poisson _CAR_ _QC_} }
  
  System("rm -f n@node@_des.plt") *remove superfluous plots
}

