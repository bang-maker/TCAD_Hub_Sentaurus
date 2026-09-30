Definitions {
  Refinement "RefinementDefinition_1" {
    MaxElementSize = (0.02 0.02)
  }
  Constant "prof1" {
    Species = "BoronActiveConcentration"
    Value = 1e+16
  }
  Constant "prof2" {
    Species = "BoronActiveConcentration"
    Value = 1e+18
  }
  Constant "prof3" {
     Species = "ArsenicActiveConcentration"
     Value = 1e+18
  }
}

Placements {
  Refinement "RefinementPlacement_1" {
    Reference = "RefinementDefinition_1"
    RefineWindow = material ["Silicon"]
  }
  Constant "prof1" {
    Reference = "prof1"
    EvaluateWindow {
      Element = material ["Silicon"]
    }
  }
  Constant "prof2" {
    Reference = "prof2"
    EvaluateWindow {
      Element = Rectangle [(0.2 0.2) (0.8 0.8)]
    }
    Replace
  }
  Constant "prof3" {
    Reference = "prof3"
    EvaluateWindow {
      Element = Rectangle [(0.7 0.7) (1.8 1.8)]
    }
  }
}
