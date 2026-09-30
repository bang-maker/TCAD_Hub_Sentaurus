Definitions {
  AnalyticalProfile "AnalyticalProfileDefinition_1" {
    Species = "BoronActiveConcentration"
    Function = Gauss(PeakPos = 0, PeakVal = 1e+18, ValueAtDepth = 1e+15, Depth = 0.5)
    LateralFunction = Gauss(Factor = 0.4)
  }
  Refinement "global" {
    MaxElementSize = ( 0.2 0.2 0.2 )
    MinElementSize = ( 0.025 0.025 0.025 )
    RefineFunction = MaxTransDiff(Variable = "BoronActiveConcentration",Value = 1)
  }
}

Placements {
  AnalyticalProfile "AnalyticalProfilePlacement_1" {
    Reference = "AnalyticalProfileDefinition_1"
    ReferenceElement {
      Element = Polygon [ (0 0.6455353498458 1.2340006828308) (0 0.7217012643814 1.0977472066879) (0 0.8740332126617 1.2043803930283) (0 1.0380829572678 1.2043803930283) (0 1.090813279151 1.0740509033203)
                          (0 1.1376847028732 0.8904049396514) (0 0.8681743144989 0.6712145209312) (0 0.8916099667549 0.5349610447883) (0 1.2021328210831 0.5290369987487) (0 1.4482073783875 0.6652904748916) 
                          (0 1.4716430902481 0.9970381259918) (0 1.3661825656891 1.3050894737244) (0 1.1611202955246 1.4354188442230) (0 0.77443158626556 1.370254158973)]
    }
  }
  Refinement "gloabl" {
    Reference = "global"
    RefineWindow = material ["Silicon"]
  }
}

Delaunizer {
  maxPoints=1000000
}

