Definitions {
  Refinement "global" {
    MaxElementSize = (0.5 0.5 0.5)
    MinElementSize = ( 0.01 0.01 0.01 )
  }
  Refinement "rectangle" {
    MaxElementSize = ( 0.05 0.05 0.01 )
    MinElementSize = ( 0.01 0.01 0.01 )
  }
}

Placements {
  Refinement "global" {
    Reference="global"
  }  
  Refinement "rectangle" {
    Reference = "rectangle"
    RefineWindow = Rectangle [(0.75 0.75) (1.25 1.25)]
  }
}

AxisAligned {
  smoothing=true
  maxNeighborRatio=@maxRatio@
}
