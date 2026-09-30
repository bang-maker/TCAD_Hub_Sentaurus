File {
  Grid       = "@tdr@"
  Parameters = "@parameter@"
  PMIPath    = "@pwd@"
  Output     = "@log@"
  Current    = "@plot@"
}

Electrode {
  { Name="top"  Voltage=0
    Current = (
      0.0    at 0.,
      2.0e-4 at 0.1e-9,
      2.0e-4 at 20.e-9,
      0.0    at 20.1e-9,
      0.0    at 1. 
    )
  }
  { Name="bottom"   Voltage=0 }
}

Thermode {
  { name="top"    Temperature=300 SurfaceResistance = 1.e-5 } 
  { name="bottom" Temperature=300 SurfaceResistance = 1.e-5 } 
}

Plot {
  xMoleFraction
  MSConfig
  eQDDShiftMSConfig hQDDShiftMSConfig
  HeatCapacity
}  

# chalco region: 0.01 x 0.002
# ( 0.005 -0.001) left bottom corner of chalcogenide
# (-0.005  0.001) upper right corner of chalcogenide
# (0.0 0.00) center of chalco
CurrentPlot {
  LatticeTemperature (
    (0.0049 -0.0009) (0.0000 -0.0009) (0.0049 0) (0.0 0)
    Maximum(Material="ChalcogenideC")
    Minimum(Material="ChalcogenideC")
    Integrate(Material="ChalcogenideC")
    Average(Material="ChalcogenideC")
  )
  eQDDShiftMSConfig (
    (0.0049 -0.0009) (0.0000 -0.0009) (0.0049 0) (0.0 0)
    Maximum(Material="ChalcogenideC")
    Minimum(Material="ChalcogenideC")
    Integrate(Material="ChalcogenideC")
    Average(Material="ChalcogenideC")
  )
  hQDDShiftMSConfig (
    (0.0049 -0.0009) (0.0000 -0.0009) (0.0049 0) (0.0 0)
    Maximum(Material="ChalcogenideC")
    Minimum(Material="ChalcogenideC")
    Integrate(Material="ChalcogenideC")
    Average(Material="ChalcogenideC")
  )
  eQuantumPotential (
    (0.0049 -0.0009) (0.0000 -0.0009) (0.0049 0) (0.0 0)
    Maximum(Material="ChalcogenideC")
    Minimum(Material="ChalcogenideC")
    Integrate(Material="ChalcogenideC")
    Average(Material="ChalcogenideC")
  )
  hQuantumPotential (
    (0.0049 -0.0009) (0.0000 -0.0009) (0.0049 0) (0.0 0)
    Maximum(Material="ChalcogenideC")
    Minimum(Material="ChalcogenideC")
    Integrate(Material="ChalcogenideC")
    Average(Material="ChalcogenideC")
  )
  PMIUserField0 (
    (0.0049 -0.0009) (0.0000 -0.0009) (0.0049 0) (0.0 0)
    Maximum(Material="ChalcogenideC")
    Minimum(Material="ChalcogenideC")
    Integrate(Material="ChalcogenideC")
    Average(Material="ChalcogenideC")
  )
  PMIUserField1 (
    (0.0049 -0.0009) (0.0000 -0.0009) (0.0049 0) (0.0 0)
    Maximum(Material="ChalcogenideC")
    Minimum(Material="ChalcogenideC")
    Integrate(Material="ChalcogenideC")
    Average(Material="ChalcogenideC")
  )
  PMIUserField2 (
    (0.0049 -0.0009) (0.0000 -0.0009) (0.0049 0) (0.0 0)
    Maximum(Material="ChalcogenideC")
    Minimum(Material="ChalcogenideC")
    Integrate(Material="ChalcogenideC")
    Average(Material="ChalcogenideC")
  )
}

Physics {
  Temperature=300.
  Thermodynamic
  ThermalConductivity (Constant Conductivity) 
  HeatCapacity(Constant)
  Thermionic
  
}

Physics (Material="ChalcogenideC") {
  eQuantumPotential # restrict eQDD on phase-change material
  hQuantumPotential # restrict eQDD on phase-change material
  
  Traps (
    (eNeutral Level Conc=1e20 FromCondBand EnergyMid=0.2
    eXsection=1e-12 hXsection=1e-12 SFactor="xMoleFraction")
    (hNeutral Level Conc=1e20 FromValBand EnergyMid=0.2
    eXsection=1e-12 hXsection=1e-12 SFactor="xMoleFraction")
  )
  
  MSConfigs (
    MSConfig ( Name = "ca"
      Conc = 1.
      State ( Name = "c" )
      State ( Name = "a" )
      State ( Name = "m" )
      Transition(Name="ca" to="c" from="a" CEModel("pmi_ce_msconfig" 0 ))
      Transition(Name="cm" to="c" from="m" CEModel("pmi_ce_msconfig" 1 ))
      Transition(Name="am" to="a" from="m" CEModel("pmi_ce_msconfig" 2 ))
      eBandEdgeShift ( "pmi_abes" )
      hBandEdgeShift ( "pmi_abes" )
    )
  )
}

Math {
  -ExtendedPrecision
  Extrapolate
  Transient = BE
  Iterations=20
  Method=Pardiso
  
  AutoCNPMinStepFactor = 0
  AutoNPMinStepFactor = 0
  
  RelErrControl
  
  eMobilityAveraging = Element
  hMobilityAveraging = Element
  -GeometricDistances
  ParameterInheritance = None
  
  NumberOfAssemblyThreads = 1
}

Math (Material="ChalcogenideC") {
  BreakCriteria { LatticeTemperature (Maxval = 2000) }
}


Solve {
  set ( "top" mode current )
  
  poisson
  Coupled { Poisson Electron Hole Temperature
  eQuantumPotential hQuantumPotential }
  
  Transient (
    InitialTime=0. Finaltime=1.e-7 
    InitialStep=1e-11 MinStep=1e-15 MaxStep=1.e-1
    Increment=1.41
  ) {
    Coupled { Poisson Electron Hole Temperature
    eQuantumPotential hQuantumPotential } 
    plot ( FilePrefix = "n@node@_TR_Ireset" 
      Time = ( 0.0 ; 1e-9 ; 2e-9 ;
      range = ( 5e-9 20e-9) intervals = 3;
      range = (20e-9  1e-7) intervals = 4
      ) 
      NoOverwrite
    ){""}
  }
  Plot ( FilePrefix = "n@node@_final_Ireset" )
}
