Definitions {
  Multibox "mb" {
    MaxElementSize = (1 1)
    MinElementSize = (0.1 0.1)
    Ratio = (2 1)
  }
}
Placements {
  Multibox "mb" {
    Reference = "mb"
    RefineWindow = rectangle[(0 0) (2 2)]
  }
}

