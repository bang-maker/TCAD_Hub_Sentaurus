Title "Mesh interface refinement example"

IOControls {
	EnableSections
}

Definitions {
  Refinement "global" {
    MaxElementSize = (1 1 1)
    MinElementSize = (0.01 0.01 0.01)
    RefineFunction = MaxLenInt(Interface("Silicon","SiO2"), 
             value=0.01, factor=2, DoubleSide)
    RefineFunction = MaxLenInt(Interface("PolySi","All"), 
             value=0.01, factor=2, DoubleSide)
  }
}

Placements {
  Refinement "global" {
    Reference = "global"
  }
}
AxisAligned {
  MaxAspectRatio=10
}
