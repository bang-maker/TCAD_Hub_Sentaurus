IOControls {
  InputFile = "@pwd@/@tdrboundary@"
}

Definitions {
  # Refinement regions 
  Refinement "Default Region"    {
    MaxElementSize = (0.15 0.15 )
    MinElementSize = (0.05 0.05 )
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration", Value = 1)
  }

  Refinement "NoName_1" {
    MaxElementSize = (0.15 0.0004 )
    MinElementSize = (0.05 5e-05 )
  }
  
  Refinement "NoName_4" {
    MaxElementSize = (0.15 0.002 )
    MinElementSize = (0.05 0.001 )
  }
  
  Refinement "NoName_5" {
    MaxElementSize = (0.075 0.15 )
    MinElementSize = (0.025 0.05 )
  }
  
  Refinement "BaseArea" {
    MaxElementSize = (0.15 0.015 )
    MinElementSize = (0.05 0.0075 )
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration", Value = 1)
  }
  
  Refinement "Collector" {
    MaxElementSize = (0.15 0.02 )
    MinElementSize = (0.05 0.005 )
  }
  
  Refinement "Emitter" {
    MaxElementSize = (99 0.02 )
    MinElementSize = (66 0.01 )
  }
  
  Refinement "BEedge" {
    MaxElementSize = (0.02 99 )
    MinElementSize = (0.01 66 )
  }
  
  # Profiles 
  Constant "Body_n_0" {
    Species = "ArsenicActiveConcentration"
    Value = 1e+19
  }
  
  Constant "EmCap" {
    Species = "ArsenicActiveConcentration"
    Value = 5e+18
  }
  
  Constant "Emitter" {
    Species = "ArsenicActiveConcentration"
    Value = 8e+17
  }
  
  Constant "Base" {
    Species = "BoronActiveConcentration"
    Value = 1e+19
  }
  
  Constant "Coll" {
    Species = "ArsenicActiveConcentration"
    Value = 1e+17
  }
}

Placements {
  # Refinement regions 
  Refinement "Default Region" {
    Reference = "Default Region"
    # Default region 
  }
  
  Refinement "NoName_1" {
    Reference = "NoName_1"
    RefineWindow = rectangle [( -0.5 0.4 ) , ( 0 0.411 )]
  }
  
  Refinement "Collector" {
    Reference = "Collector"
    RefineWindow = rectangle [( -2.5 0.52 ) , ( 0 0.83 )]
  }
  
  Refinement "BaseArea" {
    Reference = "BaseArea"
    RefineWindow = rectangle [( -2.5 0.41 ) , ( 0 0.52 )]
  }
  
  Refinement "NoName_4" {
    Reference = "NoName_4"
    RefineWindow = rectangle [( -0.5 0.385 ) , ( 0 0.42 )]
  }
  
  Refinement "NoName_5" {
    Reference = "NoName_5"
    RefineWindow = rectangle [( -0.5 0 ) , ( 0 1.3 )]
  }
  
  Refinement "Emitter" {
    Reference = "Emitter"
    RefineWindow = rectangle [( -0.5 0.19 ) , ( 0 0.4 )]
  }
  
  Refinement "BEedge" {
    Reference = "BEedge"
    RefineWindow = rectangle [( -0.52 0.38 ) , ( -0.48 0.44 )]
  }
  
  # Profiles 
  Constant "Coll" {
    Reference = "Coll"
    EvaluateWindow {
      Element = rectangle [( -2.51 0.48 ) , ( 0.01 1.31 )]
      DecayLength = 0
    }
  }
  Constant "Body_n_0" {
    Reference = "Body_n_0"
    EvaluateWindow {
      Element = rectangle [( -2.51 0.81 ) , ( 0.01 1.3 )]
      DecayLength = 0
    }
  }
  
  Constant "Emitter" {
    Reference = "Emitter"
    EvaluateWindow {
      Element = rectangle [( -0.51 0.2 ) , ( 0.01 0.41 )]
      DecayLength = 0
    }
  }
  
  Constant "Base" {
    Reference = "Base"
    EvaluateWindow {
      Element = rectangle [( -2.51 0.41 ) , ( 0.01 0.48 )]
      DecayLength = 0
    }
  }
  
  Constant "EmCap" {
    Reference = "EmCap"
    EvaluateWindow {
      Element = rectangle [( -0.51 0 ) , ( 0.01 0.2 )]
      DecayLength = 0
    }
    Replace
  }
}

