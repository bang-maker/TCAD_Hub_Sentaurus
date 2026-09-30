Definitions {
  Refinement "Si" {
    MaxElementSize = (0.5 0.5 0.5)
  }
  Refinement "Ox" {
    MaxElementSize = (0.125 0.125 0.125)
  }
}

Placements {
  Refinement "Si" {
    Reference = "Si"
    RefineWindow = material ["Silicon"]
  }
  Refinement "Ox" {
    Reference = "Ox"
    RefineWindow = material ["Oxide"]
  }
}
