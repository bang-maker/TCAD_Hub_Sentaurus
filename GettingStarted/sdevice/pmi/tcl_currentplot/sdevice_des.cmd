File {
  Grid      = "@pwd@/block.tdr"
  Plot      = "@tdrdat@"
  Current   = "@plot@"
  Output    = "@log@"
}

Electrode {
  { name="left"   Voltage=0 }
  { name="right"  Voltage=0 }
}

Plot {
  DopingConcentration
  ArsenicActiveConcentration
  BoronActiveConcentration
  xMoleFraction
  eMobility  hMobility
  eDensity  hDensity
  eJouleHeat
  PMIUserField12
  VertexIndex
  DopingWells
}

CurrentPlot {
  Potential (50)
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Node = 50  Interpolation = Linear  ArsinhFactor = 1"
    Dataset   = "Tcl_50 ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential ((7.2 2.2))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Coordinate = (7.2 2.2)  Interpolation = linear"
    Dataset   = "Tcl_7.2_2.2 ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Minimum (Region = "R.GaInP" Coordinates))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Minimum  Region = R.GaInP"
    Dataset   = "Tcl_Min_R.GaInP ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Maximum (Material = "GaInP" Coordinates))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Maximum  Material = GaInP"
    Dataset   = "Tcl_Max_GaInP ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Average (RegionInterface = "R.Ox_middle/R.GaInP" Coordinates))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Average  RegionInterface = \"R.Ox_middle/R.GaInP\""
    Dataset   = "Tcl_Ave_R.Ox_middle/R.GaInP ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Integrate (MaterialInterface = "Oxide/Silicon" Coordinates))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Integrate  MaterialInterface = \"Oxide/Silicon\""
    Dataset   = "Tcl_Int_R.Ox_middle/R.GaInP ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Minimum (Semiconductor Coordinates))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Minimum  Semiconductor"
    Dataset   = "Tcl_Min_Semi ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Maximum (Insulator Coordinates))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Maximum  Insulator"
    Dataset   = "Tcl_Max_Ins ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  # Potential (Average (Conductor Coordinates)) :# conductor is not allowed here
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Average  Conductor"
    Dataset   = "Tcl_Ave_Cond ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Integrate (Everywhere Coordinates))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Integrate  Everywhere  IntegrationUnit = um"
    Dataset   = "Tcl_Int ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Average (DopingWell (6.25 1.75)  Coordinates))
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Average  DopingWell = (6.25 1.75)"
    Dataset   = "Tcl_Ave_Well ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  Potential (Integrate (Window [(3 4) (6 7)]  Coordinates) )
  Tcl (
    Formula   = "set value [tcl_cp_ReadScalar ElectrostaticPotential]"
    Operation = "Integrate  Window = [(3 4) (6 7)]"
    Dataset   = "Tcl_Int_Window ElectrostaticPotential"
    Function  = "ElectrostaticPotential"
  )
  
  # Use a global counter variable
  # plot a simplistic function q*eDensity*eMobility on a PMIUserField
  Tcl (
    Init      = "set counter 0"
    Formula   = "incr counter
    set q 1.602e-19
    set n [tcl_cp_ReadScalar eDensity]
    set mu [tcl_cp_ReadScalar eMobility]
    set value [expr $q * $n * $mu]"
    Unit      = "Ohm^-1*cm^-1"
    Operation = "Plot = PMIUserField12  Semiconductor"
    Finish    = "puts \"Tcl CurrentPlot: used $counter calls\""
  )
  
  # Use a global counter variable
  # intgrate a vector field eCurrent*Efield
  eJouleHeat (Integrate (Semiconductor  Coordinates))
  Tcl (
    Formula   = "set value 0
    for {set d 0} {$d < $tcl_cp_dim} {incr d} {
      set j [tcl_cp_ReadVector eCurrentDensity $d]
      set f [tcl_cp_ReadVector ElectricField $d]
      set value [expr $value + $j * $f]
    }"
    Operation = "Integrate  Semiconductor  IntegrationUnit = cm"
    Dataset   = "Tcl_Int_Semi eJouleHeat"
    Function  = "JouleHeat"
  )

  # calculate conductivity as average of q*eDensity*eMobility
  Tcl (
    Formula   = "set q 1.602e-19
    set n [tcl_cp_ReadScalar eDensity]
    set mu [tcl_cp_ReadScalar eMobility]
    set value [expr $q * $n * $mu]"
    Dataset   = "Tcl_Ave_R.GaInP_Ref eConductivity"
    Function  = "Conductivity"
    Operation = "Average  Region = R.GaInP"
  )
  
  # calculate conductivity as average of q*eDensity*eMobility
  # calling an external tcl file
  Tcl (
    Tcl                 = "source conductivity.tcl"
    Conductivity_Region = "R.GaInP"
  )
}

Physics (RegionInterface = "R.InP/R.GaInP") {
  Thermionic
}

Physics (RegionInterface = "R.GaInP/R.GaP") {
  Thermionic
}

Math {
  -ExtendedPrecision
  extrapolate
  digits = 5
  Notdamped=20
  Iterations=10
  ConstRefPot
  Derivatives
  RelErrControl
  DirectCurrent
  
  eMobilityAveraging = Element
  hMobilityAveraging = Element
  -GeometricDistances
  ParameterInheritance = None
  
  # CurrentPlot (IntegrationUnit = cm)
}

Solve {
  NewCurrentPrefix = "initial_"
  Poisson
  
  NewCurrentPrefix = ""
  Quasistationary (
    DoZero
    InitialStep = 0.1  MaxStep = 0.1
    Goal {name = "right"  value = 20}
  ) {
    Coupled { Poisson Electron Hole } 
  }
}
