#setdep @node|sprocess@ 
# #setdep @node|IdVg@

#if "@Type@" == "nMOS"

#define _VDD_     @Vdd@
#define _VdLin_   @Vdd_Lin@
#define _VdSat_   @Vdd@
#define _QC_      eQuantumPotential
#define _QCo_     eQuantumPotential(AutoOrientation Density)
#define _CAR_     Electron
#define _MV_      eMultiValley(MLDA kpDOS -Density)
#define _WF_      @WF@
#define _SIGN_   1.0

#elif "@Type@" == "pMOS"

#define _VDD_     @Vdd@
#define _VdLin_   @Vdd_Lin@
#define _VdSat_   @Vdd@
#define _QC_      hQuantumPotential
#define _QCo_     hQuantumPotential(AutoOrientation Density)
#define _CAR_     Hole
#define _MV_      hMultiValley(MLDA kpDOS -Density)
#define _WF_      @WF@
#define _SIGN_   -1.0

#else
puts "Type is incorrect... @Type@"
#endif

#if "@cDir@" == "110"

#define _RelChDir_    RelChDir110

#elif "@cDir@" == "100"

#define _RelChDir_   -RelChDir110

#endif

*----------------------------------------------------------------------
Device MOS {
*----------------------------------------------------------------------
File {
  * input files:
  Grid=   "n@node|sprocess@_fps.tdr"

#if @<Strain_Impact == 1>@
  Piezo=  "n@node|sprocess@_fps.tdr"
#endif

  * output files:
  Plot=   "n@node@_des.tdr"
  Current="@plot@"
  Parameter=   "@parameter@"
}

#if @rcx@ == 0
Electrode {
  { Name="gate"        Voltage=0.0  Workfunction = _WF_ }
  { Name="drain"       Voltage=0.0  } 
  { Name="source"      Voltage=0.0  } 
  { Name="substrate"   Voltage=0.0 } 
}
#else
Electrode {
  { Name="gate"        Voltage=0.0  Workfunction = _WF_ }
  { Name="drain"       Voltage=0.0  Resist=@rcx@ } 
  { Name="source"      Voltage=0.0  Resist=@rcx@ } 
  { Name="substrate"   Voltage=0.0 } 
}
#endif
Physics {
AreaFactor=2.0
#if @<Strain_Impact == 1>@
  _MV_
#endif

  Fermi
  EffectiveIntrinsicDensity( BandGapNarrowing( OldSlotBoom ) )
  Mobility (
    Enormal( RPS InterfaceCharge(SurfaceName="S1") )
    ThinLayer(IALMob(AutoOrientation) MinAngle=(0,0))
    HighFieldSaturation(GradQuasiFermi)
  )
  Recombination ( SRH(DopingDep) Auger ) 
  ###Band2Band ( Model = Hurkx ) )

#if @<Strain_Impact == 1>@
  Piezo(
#if "@Type@" == "nMOS"
    Model(Mobility(eSubBand(Fermi EffectiveMass Scattering AutoOrientation _RelChDir_)
                   eSaturationFactor = 0.0
          )
          DeformationPotential(ekp hkp minimum)
          DOS(eMass hMass)
    )
#else
    Model(Mobility(hSubBand(Doping EffectiveMass Scattering(MLDA) AutoOrientation _RelChDir_)
                   hSaturationFactor = 0.2
          )
          DeformationPotential(ekp hkp minimum)
          DOS(eMass hMass)
    )
#endif
  )
#endif
}

#if "@Type@"=="nMOS" 
	Physics(Material= "Silicon") { _QCo_ }

#else
	Physics(Material="SiliconGermanium") { _QCo_ }
#endif



#Physics(MaterialInterface="HfO2/Oxide") {
#  Traps (
#    (FixedCharge Conc=1.0e12 Level EnergyMid=0.0 fromMidBandGap)
#    (FixedCharge Conc=-1.0e12 Level EnergyMid=0.0 fromMidBandGap)
#  )
#}

Plot {
  eDensity hDensity eCurrent/Vector hCurrent/Vector TotalCurrent/Vector
  Potential Electricfield/Vector Doping SpaceCharge
  eMobility hMobility eVelocity/Vector hVelocity/Vector
  DonorConcentration Acceptorconcentration
  BandGap Affinity BandGapNarrowing EffectiveBandGap EffectiveIntrinsicDensity
  ConductionBand ValenceBand
  eQuasiFermi hQuasiFermi eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eTemperature hTemperature 
  SRH Auger Avalanche TotalTrapConcentration
  eBand2BandGeneration hBand2BandGeneration Band2BandGeneration
  eLifetime hLifetime
*  eTrappedCharge hTrappedCharge

#if @<Strain_Impact == 1>@
  eMobilityStressFactorXX eMobilityStressFactorYY eMobilityStressFactorZZ
  eMobilityStressFactorYZ eMobilityStressFactorXZ eMobilityStressFactorXY
  hMobilityStressFactorXX hMobilityStressFactorYY hMobilityStressFactorZZ
  hMobilityStressFactorYZ hMobilityStressFactorXZ hMobilityStressFactorXY
  StressXX StressYY StressZZ StressXY StressYZ StressXZ
  
  eTensorMobilityFactorXX eTensorMobilityFactorYY eTensorMobilityFactorZZ
  hTensorMobilityFactorXX hTensorMobilityFactorYY hTensorMobilityFactorZZ
#endif

  _QC_

  xMoleFraction
  LayerThickness NearestInterfaceOrientation
  "EparallelToInterface"/Vector
  "NormalToInterface"/Vector
}

Math {
  CoordinateSystem { UCS }
#if "@Type@" == "pMOS" && @DeviceMesh@==3
#  MVMLDAcontrols( Save = "n@node@_des.kpBand" )
#   MVMLDAcontrols( Load = "n@node|IdVg@_des.kpBand" )
#endif

#if "@Type@" == "pMOS" && @DeviceMesh@==2
#  MVMLDAcontrols( Save = "n@node@_des.kpBand" )
#   MVMLDAcontrols( Load = "n@node|IdVg@_des.kpBand" )
#endif

  Surface "S1" ( MaterialInterface="HfO2/Oxide")
  ThinLayer( Mirror = ( None Min None ) )
  AutoOrientationSmoothingDistance = -1
  TensorGridAniso
  
  
   
#if "@Type@"=="nMOS"
  eQPBox({MinX=-0.001 MaxX=@<H+0.007>@ MinY=-0.001 MaxY=@<W/2+0.001>@ MinZ=@<-L/2-0.001>@ MaxZ=@<L/2+0.001>@  Attenuation_Length=0.1e-3}
  )
#endif
#if "@Type@"=="pMOS"
  hQPBox({MinX=-0.001 MaxX=@<H+0.007>@ MinY=-0.001 MaxY=@<W/2+0.001>@ MinZ=@<-L/2-0.001>@ MaxZ=@<L/2+0.001>@  Attenuation_Length=0.1e-3}
  )
#endif
  

#if @<Strain_Impact == 1>@
  StressMobilityDependence = TensorFactor
#endif
}


*----------------------------------------------------------------------
} * End of Device
*----------------------------------------------------------------------

File {
	Output= "@log@"
	ACExtract= "@acplot@"
}

Math {
	

  -CheckUndefinedModels
	
	  Extrapolate
  Derivative

  wallclock
  Method= Blocked
  SubMethod= ILS(set= 2)
  ACSubMethod= ILS(set= 2)
  RhsMin = 1e-12
  Iterations=10
  ExitOnFailure
  
  
#  errref(_QC_)=@errref@
  
  GeometricDistances
  
*  Number_of_Threads = maximum
  Number_of_Threads = @nthreads@
  WeightedVoronoiBox  
  RefDens_eGradQuasiFermi_ElectricField_HFS= 1e8
  RefDens_hGradQuasiFermi_ElectricField_HFS= 1e8 
 

}

System {
	MOS mos (drain=drain source=source gate=gate substrate=substrate)
 
        Vsource_pset vs ( source 0 ){ dc= 0 }
	Vsource_pset vc ( drain 0 ){ dc= 0 }
	Vsource_pset vg ( gate 0 ){ dc= 0 }
	Vsource_pset vb ( substrate 0 ){ dc= 0 }
}
#if 0 
Solve {
	Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson  }
	Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson _QC_ }	
	Quasistationary(
		InitialStep= 1e-2 Increment= 1.41
		MinStep= 1e-6 MaxStep= 0.1
		Goal { Parameter= vg.dc Voltage= @< 1.625*Vgg>@ }
	){ Coupled { Poisson _QC_ _CAR_ } }
	
	Quasistationary(
		InitialStep= 1e-2 Increment= 1.41
		MinStep= 1e-6 MaxStep= 0.1
		Goal { Parameter= vc.dc Voltage= _VdSat_ }
	){ Coupled { Poisson _QC_ _CAR_ } 
		Save( FilePrefix="n@node@_Vd" NoOverWrite
		Time= (Range= (0 1)  Intervals= 1)
		)
	}
	Load(FilePrefix="n@node@_Vd_0000")
	NewCurrentFile="C_0_"
	Quasistationary(
		DoZero
		InitialStep= 0.03 Increment= 1.41
		MinStep= 1e-6 MaxStep= 0.03
		Goal { Parameter= vg.dc Voltage= @<-0.625*Vgg>@ }
	){ ACCoupled (
			StartFrequency= 1 EndFrequency= 1 NumberOfPoints= 1 Decade
			Node(c g b) Exclude(vc vg vb)
			ACExtract="n@node@"
			ACCompute (Time= (Range= (0 1)  Intervals= 40))
		){ Poisson _QC_ _CAR_ }

	}
	
	Load(FilePrefix="n@node@_Vd_0001")
	NewCurrentFile="C_1_"
	Quasistationary(
		DoZero
		InitialStep= 0.03 Increment= 1.41
		MinStep= 1e-6 MaxStep= 0.03
		Goal { Parameter= vg.dc Voltage= @<-0.625*Vgg>@ }
	){ ACCoupled (
			StartFrequency= 1 EndFrequency= 1 NumberOfPoints= 1 Decade
			Node(c g b) Exclude(vc vg vb)
			ACExtract="n@node@"
			ACCompute (Time= (Range= (0 1)  Intervals= 40))
		){ Poisson _QC_ _CAR_ }

	}
	

}
#endif

Solve {
	Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson  }
	Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson _QC_ }	
	Coupled { Poisson _QC_ _CAR_ }
	
	Quasistationary(
		InitialStep= 1e-2 Increment= 1.41
		MinStep= 1e-6 MaxStep= 0.05
		Goal { Parameter= vg.dc Voltage= @<-0.0625*Vgg>@ }
	){ Coupled { Poisson _QC_ _CAR_ } }
	
	
	NewCurrentFile="C_0_"
	Quasistationary(
		DoZero
		InitialStep= 0.03 Increment= 1.41
		MinStep= 1e-6 MaxStep= 0.1
		Goal { Parameter= vg.dc Voltage= @<1*Vgg>@ }
	){ ACCoupled (
			StartFrequency= 1 EndFrequency= 1 NumberOfPoints= 1 Decade
			Node(source drain gate substrate) Exclude(vs vc vg vb)
			ACExtract="n@node@"
#			ACCompute (Time= (Range= (0 1)  Intervals= 20))
		){ Poisson _QC_ _CAR_ }

	}
	
	Quasistationary(
		InitialStep= 1e-2 Increment= 1.41
		MinStep= 1e-6 MaxStep= 0.02
		Goal { Parameter= vc.dc Voltage= _VdSat_ }
	){ Coupled { Poisson _QC_ _CAR_ } 
#		Save( FilePrefix="n@node@_Vd" NoOverWrite
#		Time= (Range= (0 1)  Intervals= 1)
#		)
	}

	
#	Load(FilePrefix="n@node@_Vd_0001")
	NewCurrentFile="C_1_"
	Quasistationary(
		DoZero
		InitialStep= 0.03 Increment= 1.41
		MinStep= 1e-6 MaxStep= 0.05
		Goal { Parameter= vg.dc Voltage= @<-0.0625*Vgg>@ }
	){ ACCoupled (
			StartFrequency= 1 EndFrequency= 1 NumberOfPoints= 1 Decade
			Node(source drain gate substrate) Exclude(vs vc vg vb)
			ACExtract="n@node@"
#			ACCompute (Time= (Range= (0 1)  Intervals= 20))
		){ Poisson _QC_ _CAR_ }

	}

}


