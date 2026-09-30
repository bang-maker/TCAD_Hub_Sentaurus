Definitions {
  Refinement "global" {
    MaxElementSize = (0.5 0.5 0.5)
  }
  Refinement "rectangle" {
    MaxElementSize = (0.125 0.125 0.125)
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
