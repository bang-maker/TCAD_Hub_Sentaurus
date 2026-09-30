IOControls {
  InputFile = "@[relpath @pwd@/@tdrboundary@]@"
}

Definitions {
  # Refinement regions 
  Refinement "Default Region" {
    MaxElementSize = (0.25 0.25 )
    MinElementSize = (0.001 0.001 )
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration", Value = 1)
  }
  
  # Profiles 
  Constant "N_epi" {
    Species = "PhosphorusActiveConcentration"
    Value = 2e+15 }
  
  AnalyticalProfile "N+Collector" {
    Species = "PhosphorusActiveConcentration"
    Function = Gauss(PeakPos = 0, PeakVal = 1e+19, ValueAtDepth = 2e+15, Depth = 4)
    LateralFunction = Gauss(Factor = 0)
  }
  
  AnalyticalProfile "P_base_extrinsic_0" {
    Species = "BoronActiveConcentration"
    Function = Gauss(PeakPos = 0, PeakVal = 2e+19, StdDev = 0.07)
    LateralFunction = Gauss(Factor = 0.8)
  }
  
  AnalyticalProfile "N+emitter" {
    Species = "ArsenicActiveConcentration"
    Function = Gauss(PeakPos = 0, PeakVal = 7e+19, StdDev = 0.03)
    LateralFunction = Gauss(Factor = 0.8)
  }
  
  AnalyticalProfile "P_base_intrinsic" {
    Species = "BoronActiveConcentration"
    Function = Gauss(PeakPos = 0.1, PeakVal = 5e+17, StdDev = 0.06)
    LateralFunction = Gauss(Factor = 0.8)
  }
  
  AnalyticalProfile "P+base_ohmic_0" {
    Species = "BoronActiveConcentration"
    Function = Gauss(PeakPos = 0, PeakVal = 1e+20, ValueAtDepth = 1e+18, Depth = 0.18)
    LateralFunction = Gauss(Factor = 0.8)
  }
}

Placements {
  Refinement "Default Region" {
    Reference = "Default Region"
  }
  
  # Profiles 
  Constant "N_epi_0" {
    Reference = "N_epi"
    EvaluateWindow {
      Element = rectangle [( 0 0 ) , ( 3 12 )]
      DecayLength = 0
    }
  }
  
  AnalyticalProfile "N+Collector_0" {
    Reference = "N+Collector"
    ReferenceElement {
      Element = line [( 3 12 ) , ( 0 12 )]
      Direction = positive
    }
  }
  
  AnalyticalProfile "P_base_extrinsic_0" {
    Reference = "P_base_extrinsic_0"
    ReferenceElement {
      Element = line [( 0 0 ) , ( 1.85 0 )]
      Direction = positive
    }
  }
  
  AnalyticalProfile "N+emitter_0" {
    Reference = "N+emitter"
    ReferenceElement {
      Element = line [( 2 0 ) , ( 3 0 )]
      Direction = positive
    }
  }
  
  AnalyticalProfile "P_base_intrinsic_0" {
    Reference = "P_base_intrinsic"
    ReferenceElement {
      Element = line [( 2 0 ) , ( 3 0 )]
      Direction = positive
    }
  }
  
  AnalyticalProfile "P+base_ohmic_0" {
    Reference = "P+base_ohmic_0"
    ReferenceElement {
      Element = line [( 0 0 ) , ( 0.2 0 )]
      Direction = positive
    }
  }
  
}

