Definitions {
  AnalyticalProfile "AnalyticalProfileDefinition_1" {
    Function = subMesh1D(datafile = "@pwd@/1d_As.plx", scale = 1)
    LateralFunction = Gauss(Factor = 0.0)
  }
  Refinement "RefinementDefinition_1" {
    MaxElementSize = ( 0.2 0.2 0.2 )
    MinElementSize = ( 0.005 0.005 0.005 )
    RefineFunction = MaxTransDiff(Variable = "ArsenicActiveConcentration",Value = 1)
  }
}

Placements {
  AnalyticalProfile "AnalyticalProfilePlacement_1" {
    Reference = "AnalyticalProfileDefinition_1"
    ReferenceElement {Element = Line [(0 -0.5) (0 1.5)]}
  }
  Refinement "RefinementPlacement_1" {
    Reference = "RefinementDefinition_1"
    RefineWindow = material ["Silicon"]
  }
}
