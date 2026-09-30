File {
  Grid       = "@tdr@"
  Parameters = "@parameter@"
  PMIPath    = "@pwd@"
  Current    = "@plot@"
  Output     = "@log@"
}

Electrode {
  { Name="top"      Voltage=0
    Current = (
      0.    at 0., 
      1.e-6 at 0.1e-9,
      1.e-6 at 120.e-9,
      0.    at 120.1e-9,
      0.    at 1.
    )
  }
  { Name="bottom"   Voltage=0 }
}

Thermode {
  { name="top" Temperature=300 SurfaceResistance = 1.e-5 } # at semiconductor
  { name="bottom" Temperature=300 SurfaceResistance = 1.e-5 } # at metal
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
  
  #  eQuantumPotential not solved globally 
  #  hQuantumPotential not solved globally 
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
  #  Recombination (Avalanche(Lackner))
  
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
  *   CNormPrint
  
  NewtonPlot (Residual Error NEWTONPLOTSTEP=1.e100)
  
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
  
  * init simulation
  NewCurrentPrefix = "ignore_"
  poisson
  
  * ramp until melting
  NewCurrentPrefix = ""
  
  Coupled { Poisson Electron Hole Temperature
  eQuantumPotential hQuantumPotential }
  
  Quasistat (
    InitialStep = 0.0125 MinStep = 1.e-5 MaxStep = 1
    Goal { Name = "top" Current = 3.e-4 }  
  ) {
    Coupled (Digits = 8) { Poisson Electron Hole Temperature
    eQuantumPotential hQuantumPotential } 
  }
  Plot ( FilePrefix = "n@node@_melted_dc" )
  
  * freeze phase 'c'
  * (i.e. set prefactors of all transitions involving 'c' to zero)
  Set (
    (Device="" MSConfig="ca" Transition="cm" PreFactor=0.)
    (Device="" MSConfig="ca" Transition="ca" CPreFactor=0.)
    (Device="" MSConfig="ca" Transition="ca" EPreFactor=0.)
  )
  
  * ramp back to zero current with frozen (almost vanishing) phase 'c'
  NewCurrentPrefix="frozen_c_"
  
  Quasistat (
    DoZero 
    InitialStep = 0.025 MinStep = 1.e-5 MaxStep = 0.1 
    Goal { Name = "top" Current = 0. }
  ) {
    Coupled { Poisson Electron Hole Temperature
    eQuantumPotential hQuantumPotential }
  }
  Plot ( FilePrefix = "n@node@_final_dc" )
}

