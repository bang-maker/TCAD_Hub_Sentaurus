
IOControls {
  InputFile= "@pwd@/SubMesh2d_bnd.tdr"
}

Definitions {
  SubMesh "SubMesh" {
    Geofile = "@pwd@/submesh_input2.tdr"
  }
  Constant "Const.Gate" {
    Species = "ArsenicActiveConcentration"
    Value = 6e+19
  }
  Refinement "RSize.Silicon" {
    MaxElementSize = ( 0.11625 0.125 )
    MinElementSize = ( 0.058125 0.11111111111111 )
  }
  Refinement "RSize.SD" {
    MaxElementSize = ( 0.066666666666667 0.025664425 )
    MinElementSize = ( 0.006 0.006 )
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
  }
  Refinement "RSize.GD" {
    MaxElementSize = ( 0.006 0.006 0 )
    MinElementSize = ( 0.0048 0.0048 0 )
  }
  Multibox "MBSize.Channel"
 {
    MaxElementSize = ( 0.01625 0.03416635 )
    MinElementSize = ( 0.008125 0.0002 )
    Ratio = ( -1.45 1.45 )
  }
  Multibox "MBSize.Gate"
 {
    MaxElementSize = ( 99 0.044577614352351 )
    MinElementSize = ( 66 0.0003 )
    Ratio = ( 0 -1.75 )
  }
}

Placements {
  SubMesh "SubMesh_R" {
    Reference = "SubMesh"
    SelectWindow {
      AttachPoint = ( 0 0 0 )
      ToPoint = ( 0 0 0 )
    }
    Replace
    EvaluateWindow {
      Element = Rectangle [(-0.01 -0.1910638574094) (0.475 2.01)]
    }
  }
  Constant "PlaceCD.Gate" {
    Reference = "Const.Gate"
    Replace
    EvaluateWindow {
      Element = material ["PolySi"]
      DecayLength = 0
    }
  }
  Refinement "RPlace.Silicon" {
    Reference = "RSize.Silicon"
    RefineWindow = material ["Silicon"]
  }
  Refinement "RPlace.SD" {
    Reference = "RSize.SD"
    RefineWindow = Rectangle [(0.065 0) (0.465 0.20595)]
  }
  Refinement "RPlace.GD" {
    Reference = "RSize.GD"
    RefineWindow = Rectangle [(0.04045 0.0006346) (0.06045 0.04846749)]
  }
  Multibox "MBPlace.Channel" {
    Reference = "MBSize.Channel"
    RefineWindow = Rectangle [(0 0.0006346) (0.055495 0.06865)]
  }
  Multibox "MBPlace.Gate" {
    Reference = "MBSize.Gate"
    RefineWindow = Rectangle [(0 -0.1810638574094) (0.065 -0.0027534)]
  }
}

