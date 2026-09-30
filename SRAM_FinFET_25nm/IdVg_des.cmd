#setdep @node|sprocess@

#-- FullStructure Specification
#define _WFn_   4.2
#define _WFp_   4.9
#define _QC_    eQuantumPotential hQuantumPotential

#define _HFin_  @HFin@
#define _Ymax_  @YMax@
#define _Z1_    0.0
#define _Z2_    @<ZMax/2.0-0.08>@
#define _Z3_    @<ZMax/2.0+0.08>@
#define _Z4_    @ZMax@ 
#define _Xtop_  @<-0.25*HFin>@


File {
  #if @[string match "SRAM10T" @Domain@]@
  Grid      = "n@node|sprocess@_fps.tdr"
  Piezo     = "n@node|sprocess@_fps.tdr"
  #endif
  Parameter = "@parameter@"
  **Plot      = "@tdrdat@"   *To reduce project size
  Current   = "@plot@"
  Output    = "@log@"
 
}

Electrode {

#if @[string match @Domain@ "SRAM10T"]@      
  { Name= "SourceP1"    Voltage= 0.0 }
  { Name= "DrainP1"     Voltage= 0.0 }
  { Name= "GateP1"      Voltage= 0.0 Workfunction= _WFp_}

  { Name= "SourceN1"    Voltage= 0.0 }
  { Name= "DrainN1"     Voltage= 0.0 }
  { Name= "GateN1"      Voltage= 0.0 Workfunction= _WFn_}
 
  { Name= "SourceN2"    Voltage= 0.0 }
  { Name= "DrainN2"     Voltage= 0.0 }
  { Name= "GateN2"      Voltage= 0.0 Workfunction= _WFn_}
  
  { Name= "SourceP2"    Voltage= 0.0 }
  { Name= "DrainP2"     Voltage= 0.0 }
  { Name= "GateP2"      Voltage= 0.0 Workfunction= _WFp_}
  
  
  { Name= "DrainACC1"   Voltage= 0.0 }
  { Name= "GateACC1"    Voltage= 0.0 Workfunction= _WFn_}
  { Name= "GateA1"      Voltage= 0.0 }
  { Name= "DrainACC2"   Voltage= 0.0 }
  { Name= "GateACC2"    Voltage= 0.0 Workfunction= _WFn_}
  { Name= "GateA2"      Voltage= 0.0 }
  
  { Name= "SubnWell1"   Voltage= 0.0 }
  { Name= "SubnWell2"   Voltage= 0.0 }
  { Name= "substrate"   Voltage= 0.0 }

#endif
}

Physics {
  Mobility(
    PhuMob
    HighFieldSaturation
    Enormal ( Lombardi( AutoOrientation ) )
    )
  EffectiveIntrinsicDensity( OldSlotboom )
  Recombination(SRH(DopingDep))
  Piezo(
    Model(
      DeformationPotential
      Mobility(
         eSubBand(Doping)
         hTensor(Kanda)
      	      )
         )
       )
}
       
Physics (Material="SiliconGermanium") {      
	_QC_
}


Plot{
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  eTemperature Temperature * hTemperature
  ElectricField/Vector Potential SpaceCharge
  Doping DonorConcentration AcceptorConcentration
  SRH Band2Band * Auger
  AvalancheGeneration eAvalancheGeneration hAvalancheGeneration
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  BandGap 
  BandGapNarrowing
  Affinity
  ConductionBand ValenceBand
  eBarrierTunneling hBarrierTunneling * BarrierTunneling
  eTrappedCharge  hTrappedCharge
  eGapStatesRecombination hGapStatesRecombination
  eDirectTunnel hDirectTunnel
  *--Stress related data
   StressXX StressYY StressZZ StressXY StressXZ StressYZ
}

Math {

  eQPBox({MinX=_Xtop_ MaxX=_HFin_ MinY=0.0 MaxY=_Ymax_ MinZ=_Z1_ MaxZ=_Z2_ Attenuation_Length=1e-3}
         {MinX=_Xtop_ MaxX=_HFin_ MinY=0.0 MaxY=_Ymax_ MinZ=_Z3_ MaxZ=_Z4_ Attenuation_Length=1e-3}
        )
   
  hQPBox({MinX=_Xtop_ MaxX=_HFin_ MinY=0.0 MaxY=_Ymax_ MinZ=_Z2_ MaxZ=_Z3_ Attenuation_Length=2e-3})

  Extrapolate
  RelErrControl
  Digits= 5
  RHSmin= 1e-10
  Notdamped= 50
  Iterations= 20
  ExitOnFailure
  eDrForceRefDens= 1e12
  hDrForceRefDens= 1e12
  TensorGridAniso
  StressMobilityDependence= TensorFactor
  StressLimit= 4e9  #[Pa]

  Method= ILS
  Number_Of_Threads= 8
}

Solve {
  Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson _QC_  }
  
  Save ( FilePrefix= "n@node@_init" )
  Quasistationary(
    InitialStep= 1e-3 Increment= 1.35 
    MinStep= 1e-8 MaxStep= 0.1
    
#if @[ string match "SRAM10T" @Domain@]@
    Goal { Name="DrainN1" Voltage=@VdLin@ }
    Goal { Name="DrainN2" Voltage=@VdLin@ }
    Goal { Name="DrainP1" Voltage=@<-VdLin>@ }
    Goal { Name="DrainP2" Voltage=@<-VdLin>@ }
#endif
  ){ Coupled { Poisson Electron Hole _QC_  } }
  Save ( FilePrefix= "n@node@_VdLin" )

#-- Ramp drain to VdSat
  Load ( FilePreFix= "n@node@_init" )
  Quasistationary( 
    InitialStep= 1e-3 Increment= 1.35 
    MinStep= 1e-8 MaxStep= 0.1
    
#if @[ string match "SRAM10T" @Domain@]@
    Goal { Name="DrainN1" Voltage=@Vgg@ }
    Goal { Name="DrainN2" Voltage=@Vgg@ }
    Goal { Name="DrainP1" Voltage=@<-Vgg>@ }
    Goal { Name="DrainP2" Voltage=@<-Vgg>@ }
#endif
  ){ Coupled { Poisson Electron Hole _QC_ } }
    Save ( FilePrefix= "n@node@_VdSat" )

#-- Vg sweep for Vd=VdLin
  NewCurrentPrefix= "IdVg_VdLin_" 
  Load ( FilePrefix= "n@node@_VdLin" )
  Quasistationary( 
    DoZero 
    InitialStep= 1e-3 Increment= 1.35 
    MinStep= 1e-6 MaxStep= 0.05

#if @[ string match "SRAM10T" @Domain@]@
    Goal { Name="GateN1"   Voltage=@Vgg@ }
    Goal { Name="GateN2"   Voltage=@Vgg@ }
    Goal { Name="GateACC1" Voltage=@Vgg@ }
    Goal { Name="GateACC2" Voltage=@Vgg@ }
    Goal { Name="GateP1"   Voltage=@<-Vgg>@ }   
    Goal { Name="GateP2"   Voltage=@<-Vgg>@ }
#endif
  ){ Coupled { Poisson Electron Hole _QC_ } }
  
#-- Vg sweep for Vd=VdSat
  NewCurrentPrefix= "IdVg_VdSat_" 
  Load ( FilePrefix= "n@node@_VdSat" )
  Quasistationary( 
    DoZero 
    InitialStep= 1e-2 Increment= 1.35 
    MinStep= 1e-6 MaxStep= 0.05

#if @[ string match "SRAM10T" @Domain@]@
    Goal { Name="GateN1"   Voltage=@Vgg@ }
    Goal { Name="GateN2"   Voltage=@Vgg@ }
    Goal { Name="GateACC1" Voltage=@Vgg@ }
    Goal { Name="GateACC2" Voltage=@Vgg@ }
    Goal { Name="GateP1"   Voltage=@<-Vgg>@ }   
    Goal { Name="GateP2"   Voltage=@<-Vgg>@ }

#endif
  ){ Coupled { Poisson Electron Hole _QC_ } }
   
}

