#setdep @node|substrate@
#setdep @node|slice3Dto2D@

Definitions {
  Refinement "global" {
    MaxElementSize = (2.0 2.0 2.0)
    MinElementSize = (0.1 0.1 0.1)
    RefineFunction = MaxTransDiff(Variable = "DopingConcentration",Value = 1)
  }
  
  # Read doping profile for channel cutline
  SubMesh "2Dplane" {
    Geofile = "@[relpath n@node|slice3Dto2D@_msh.tdr]@"
  }
  
}


Placements {
  
  SubMesh "place_tmpplane_rotation" {
    Reference = "2Dplane"
    ShiftVector = (0 0 0)
    Rotation {
      angle = 0
      axis  = X
    } 
    Rotation {
      angle = 0
      axis  = Z
    } 
    Rotation {
      angle = 180
      axis  = Y
    } 
    ShiftVector = ( -0.0 @<radius-1>@ 0 )
    EvaluateWindow {
      Element = sweepElement {
        base = rectangle [ ( 0 @<radius -yhalf -1>@ 0 ) , (-@depth@ @<radius+yhalf-1>@ 0) ]
        point = ( 0,0,0 )
        axis  = ( 1,0,0)
        angle = 360
      }
    }
    Replace
  }
  
  Refinement "global" {
    Reference = "global"
    RefineWindow=Material["Silicon"]
  }
}

