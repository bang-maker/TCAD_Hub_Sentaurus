IOControls {
  InputFile = "@pwd@/@tdrboundary@"
}

Definitions {
  Constant "ConstantProfileDefinition_1" {
    Species = "BoronActiveConcentration"
    Value = @conc@
  }
  Refinement "RefinementDefinition_1" {
    MaxElementSize = ( 0.5 0.5 )
    MinElementSize = ( 0.1 0.1 )
  }
}

Placements {
  Constant "ConstantProfilePlacement_1" {
    Reference = "ConstantProfileDefinition_1"
    EvaluateWindow {
      Element = material ["Silicon"]
    }
  }
  Refinement "RefinementPlacement_1" {
    Reference = "RefinementDefinition_1"
    RefineWindow = material ["Silicon"]
  }
}

