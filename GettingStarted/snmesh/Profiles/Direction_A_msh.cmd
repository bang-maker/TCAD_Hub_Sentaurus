Definitions {
  Refinement "RefinementDefinition_1" {
    MaxElementSize = (0.02 0.02)
  }
  AnalyticalProfile "abc" {
    Species = "BoronActiveConcentration"
    Function = Gauss(PeakPos=0, PeakVal=1e+18, ValueAtDepth=1e15, Depth=0.5)
    LateralFunction = Erf(Factor=0)
  }
}

Placements {
  AnalyticalProfile "abc" {
    Reference = "abc"
    ReferenceElement {
      Element = Line [(1 0.75) (1 1.25)]
      Direction = positive
    }
  }
  Refinement "RefinementPlacement_1" {
    Reference = "RefinementDefinition_1"
    RefineWindow = material ["Silicon"]
  }
}
