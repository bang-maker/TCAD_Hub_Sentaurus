Definitions {
  Refinement "global" {
    MaxElementSize = (0.5 0.5 0.5)
  }
  Refinement "polygon" {
    MaxElementSize = (0.25 0.25 0.25)
  }
}

Placements {
  Refinement "global" {
    Reference="global"
  }
  Refinement "polygon" {
    Reference = "polygon"
    RefineWindow = region ["PolygonR"]
  }
}

