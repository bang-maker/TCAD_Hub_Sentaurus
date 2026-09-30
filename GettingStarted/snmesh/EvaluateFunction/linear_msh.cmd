Definitions {
  AnalyticalProfile "linear" {
    Species = "PhosphorusActiveConcentration"
    Function = General( init = "fmax=10^18;fmin=10^16"  
        function = "10.*(fmin-fmax)*x+2.*fmax-fmin" value = 0)
  }
  Constant "ConstantProfileDefinition_1" {
    Species = "PhosphorusActiveConcentration"
    Value = 1e+18
  }
  Constant "ConstantProfileDefinition_2" {
    Species = "PhosphorusActiveConcentration"
    Value = 1e+16
  }
  Refinement "RefinementDefinition_1" {
    MaxElementSize = ( 0.01 0.5 0 )
    MinElementSize = ( 0.001 0.1 0 )
  }
}

Placements {
  AnalyticalProfile "AnalyticalProfilePlacement_1" {
    Reference = "linear"
    Replace
  }
  Constant "ConstantProfilePlacement_1" {
    Reference = "ConstantProfileDefinition_1"
    Replace
    EvaluateWindow {
      Element = region ["region_1"]
    }
  }
  Constant "ConstantProfilePlacement_2" {
    Reference = "ConstantProfileDefinition_2"
    Replace
    EvaluateWindow {
      Element = region ["region_3"]
    }
  }
  Refinement "RefinementPlacement_1" {
    Reference = "RefinementDefinition_1"
    RefineWindow = Rectangle [(0 0) (1 0.3)]
  }
}
