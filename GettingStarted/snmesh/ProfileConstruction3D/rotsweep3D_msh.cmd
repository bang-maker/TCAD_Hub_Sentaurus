#setdep @node|one2two@

Definitions {
  Refinement "global" {
    MaxElementSize = (0.2 0.2 0.5)
    MinElementSize = (0.01 0.01 0.01)
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
  }
  
  SubMesh "2Dplane" {
    Geofile = "@[relpath n@node|one2two@_msh.tdr]@"
  }
}

Placements {
	
  SubMesh "place_tmpplane_r1" {
    Reference = "2Dplane"
    ShiftVector = (0 0 0)
    Rotation {
      angle = -90
      axis  = X
    } 
    ShiftVector = ( 0 1.5 0 )
    EvaluateWindow {
      Element = sweepElement {
        base  = rectangle [ ( 0 1.5 0 ) , (3.1 1.5 1) ]
        point = ( 0,1.5,0 )
        axis  = ( 0,0,1)
        angle = 90
      }
    }
    Replace
  }
	
  SubMesh "place_tmpplane" {
    Reference = "2Dplane"
    ShiftVector = (0 0 0)
    Rotation {
      angle = -90
      axis  = X
    } 
    EvaluateWindow {
      Element = cuboid [(0 -1.5 -10), (10 1.5 10)] 
    }
    Replace
  }

  SubMesh "place_tmpplane_r2" {
    Reference = "2Dplane"
    ShiftVector = (0 0 0)
    Rotation {
      angle = -90
      axis  = X
    } 
    ShiftVector = ( 0 -1.5 0 )
    EvaluateWindow {
      Element = sweepElement {
        base  = rectangle [ ( 0 -1.5 0 ) , (3.1 -1.5 1) ]
        point = ( 0,-1.5,0 )
        axis  = ( 0,0,1)
        angle = -90
      }
    }
    Replace
  }
  Refinement "global" {
    Reference = "global"
    RefineWindow=Material["Silicon"]
  }
}
