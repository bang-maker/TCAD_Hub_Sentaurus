
IOControls {
  InputFile= "@pwd@/SubMesh1d_bnd.tdr"
}


Definitions {
  AnalyticalProfile "AnalyticalProfileDefinition_1" {
    Function = subMesh1D(datafile = "@pwd@/1d_As.plx", scale = 1)
    LateralFunction = Gauss(Factor = 0.2)
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
    ReferenceElement {
      Element = Line [(0.75 0) (1.25 0)]
    }
  }
  Refinement "RefinementPlacement_1" {
    Reference = "RefinementDefinition_1"
    RefineWindow = material ["Silicon"]
  }
}
