Definitions {
  Constant "const" {
  Species = "BoronActiveConcentration"
    Value = 1e+18
  }
  Refinement "RefinementDefinition_1" {
    MaxElementSize = ( 0.02 0.02 0.02 )
  }
}

Placements {
  Constant "const" {
    Reference = "const"
    EvaluateWindow {
      Element = Rectangle [(0.75 0.75) (1.25 1.25)]
      DecayLength = 0.
    }
  }
  Refinement "RefinementPlacement_1" {
    Reference = "RefinementDefinition_1"
    RefineWindow = material ["Silicon"]
  }
}
