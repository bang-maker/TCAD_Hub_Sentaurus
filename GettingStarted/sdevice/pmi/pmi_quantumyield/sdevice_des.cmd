*--------------------------------------------------
File {
  *-Input
  Grid            = "@pwd@/solarcell_msh.tdr"
  PMIPath         = "@pwd@"
  *-Output
  Plot(collected) = "@tdrdat@"
  Current         = "@plot@"
  Output          = "@log@"
}

*--------------------------------------------------
Electrode {   
  { name="nContact" voltage=0.0 }
  { name="pContact" voltage=0.0 }
}

*--------------------------------------------------
Thermode {
  { name="pContact" temperature=300.0 }
}

*--------------------------------------------------
Plot {
  DopingConcentration
  eQuasiFermiPotential hQuasiFermiPotential BandGap ConductionBandEnergy ValenceBandEnergy 
  eCurrent/Vector hCurrent/Vector current/vector
  SpaceCharge eDensity hDensity
  Potential
  eMobility hMobility
  SRH Auger TotalRecombination 
  eLifeTime hLifeTime * SRH 
  EffectiveIntrinsicDensity IntrinsicDensity
  QuantumYield
  ThermalizationYield
  AbsorbedPhotonDensity
  OpticalGeneration
  ComplexRefractiveIndex
  Temperature
  ThermalConductivity
  eJouleHeat hJouleHeat
  RecombinationHeat
  ThomsonHeat
  PeltierHeat
  OpticalAbsorptionHeat
}

*--------------------------------------------------
CurrentPlot{
  ModelParameter="Wavelength"
  OpticalGeneration(Integrate(Semiconductor)) *used to calculate IQE in Inspect
  Temperature(Average(Semiconductor)) 
  Temperature(Maximum(Semiconductor)) 
}

*--------------------------------------------------
Physics {
  Area = 5000000000 * to get current in mA/cm^2         
  Recombination(
    SRH
    Auger
  )
  Mobility(
    DopingDep
  )
  EffectiveIntrinsicDensity(
    BandGapNarrowing (delAlamo)
  )
  Optics (
    ComplexRefractiveIndex (
      WavelengthDep(Real Imag)
      CarrierDep(Imag)
    )
    OpticalGeneration (
      #if [string match "pmi" "@QY@"]
      QuantumYield( PMIModel = "pmi_qy_eg")
      #else
      QuantumYield( StepFunction(Bandgap) )
      #endif
      ComputeFromMonochromaticSource
    ) * end OpticalGeneration
    Excitation (
      fromTop
      Polarization = 0.5
      Wavelength = 0.7  *[um]
      Intensity = 0  *[W/cm2]
      Window(
        Line(x1=5 x2=20)
      )
    )
    OpticalSolver (
      TMM (
        IntensityPattern = Envelope
        LayerStackExtraction()
      ) *end TMM
    ) * end OpticalSolver
  ) * end optics
} * end physics

*--------------------------------------------------
Math {
  # Extrapolate 
  # Derivatives   
  RelErrControl 
  Digits=5              
  Iterations=8  
  Notdamped=100 
  # SubMethod=ParDiSo
  # Method=Blocked
  AutoCNPMinStepFactor=0
  AutoNPMinStepFactor=0
}

*--------------------------------------------------
Solve {
  NewCurrentPrefix = "tmp_"
  Poisson
  Coupled { Poisson Electron Hole Temperature }
  
  Quasistationary ( 
    InitialStep = 1  MaxStep = 1  Minstep = 1
    Goal { modelParameter="Intensity" value=0.1 }
  ) { 
    Coupled { Poisson Electron Hole Temperature }
  }
  
  NewCurrentPrefix = ""
  Quasistationary ( 
    DoZero
    InitialStep = 0.2  MaxStep = 0.2  Minstep = 0.2
    Goal { modelParameter="Wavelength" value=1.2 }
  ) { 
    Coupled { Poisson Electron Hole Temperature }
    Plot(FilePrefix=n@node@)
  }
  System("rm -f tmp*") *remove the plot we dont need anymore.              
}




