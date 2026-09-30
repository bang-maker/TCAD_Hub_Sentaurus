
#if "@Type@" == "nMOS"

#define _VDD_     @Vdd@
#define _VdLin_   0.05
#define _VdSat_   @Vdd@
#define _QC_      eQuantumPotential
#define _QCo_     eQuantumPotential(AutoOrientation Density)
#define _CAR_     Electron
#define _MV_      eMultiValley(MLDA kpDOS -Density)
#define _WF_      @WF@
#define _SIGN_   1.0


#elif "@Type@" == "pMOS"

#define _VDD_     @<-1.0*Vdd>@
#define _VdLin_   -0.05
#define _VdSat_   @<-1.0*Vdd>@
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

File {
  * input files:
  Grid=   "n@node|-2@_e_fps.tdr"

#if @<Strain_Impact == 1>@
  Piezo=  "n@node|-2@_e_fps.tdr"
#endif

  * output files:
  Plot=   "n@node@_des.tdr"
  Current="@plot@"
  Output= "@log@"
  Parameter=   "@parameter@"
}

Electrode {
  { Name="gate"        Voltage=0.0  Workfunction = _WF_ }
  { Name="drain"       Voltage=0.0  DistResist=1.5e-8 } 
  { Name="source"      Voltage=0.0  DistResist=1.5e-8 } 
  { Name="substrate"   Voltage=0.0 } 
}

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
  Recombination ( SRH(DopingDep) Auger Band2Band ( Model = Hurkx ) )

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
Physics(Region="ChFin") { _QCo_ }
Physics(Region="ChStop") { _QCo_ }
Physics(Region="SDepi.1") { _QCo_ }
Physics(Region="SDepi.2") { _QCo_ }


Physics(MaterialInterface="HfO2/Oxide") {
  Traps (
    (FixedCharge Conc=1.0e12 Level EnergyMid=0.0 fromMidBandGap)
    (FixedCharge Conc=-1.0e12 Level EnergyMid=0.0 fromMidBandGap)
  )
}


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
#if "@Type@" == "pMOS"
#   MVMLDAcontrols( Save = "n@node@_des.kpBand" )
#  MVMLDAcontrols( Load = "n@node@_des.kpBand" )
#endif

  -CheckUndefinedModels
  Surface "S1" ( MaterialInterface="HfO2/Oxide")
  ThinLayer( Mirror = ( None Min None ) )
  AutoOrientationSmoothingDistance = -1
  GeometricDistances
  
  Extrapolate
  Derivative
  Method=ILS
  wallclock
  RhsMin = 1e-12
  Iterations=20
  ExitOnFailure

* Number_of_Threads = maximum
  Number_of_Threads = 4 
  
#if @<Strain_Impact == 1>@
  StressSG
#endif
}


Solve {
	
	Coupled ( Iterations= 100 LineSearchDamping= 1e-8 ){ Poisson _QC_ }
	Coupled { Poisson _CAR_ _QC_ }

	NewCurrentFile="tmp_0_"
	Quasistationary(
		DoZero
		InitialStep= 1e-5 Increment= 2
		MinStep= 1e-6 MaxStep= 0.5
		Goal { Name="drain" Voltage= _VDD_ }
	){ Coupled { Poisson _QC_ _CAR_ }
		Save( FilePrefix="n@node@_Vd" NoOverWrite
			Time=(0.0625;1.0000000)
		)
	}

	NewCurrentFile="IdVg_0_"
	Load(FilePrefix="n@node@_Vd_0000")
	Quasistationary(
		DoZero
		InitialStep=0.03 Increment=1.41
		MinStep=1e-5 MaxStep=0.03
		Goal { Name="gate" Voltage= @<_SIGN_*Vgg>@ }
		){ Coupled { Poisson _QC_ _CAR_ }
			CurrentPlot( Time=(Range=(0 1) Intervals=40) )
			Plot( FilePrefix="Vg_n@node@_0" NoOverWrite
				Time=(Range=(0 1) Intervals=10)
			)
		}

	NewCurrentFile="IdVg_1_"
	Load(FilePrefix="n@node@_Vd_0001")
	Quasistationary(
		DoZero
		InitialStep=0.03 Increment=1.41
		MinStep=1e-5 MaxStep=0.03
		Goal { Name="gate" Voltage= @<_SIGN_*Vgg>@ }
		){ Coupled { Poisson _QC_ _CAR_ }
			CurrentPlot( Time=(Range=(0 1) Intervals=40) )
			Plot( FilePrefix="Vg_n@node@_1" NoOverWrite
				Time=(Range=(0 1) Intervals=10)
			)
		}

}






