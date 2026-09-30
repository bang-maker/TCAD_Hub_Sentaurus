Title "SnMesh boundary conforming interface refinement example"

IOControls {
	EnableSections
}

Definitions {
  Refinement "global" {
    MaxElementSize = (0.5 0.5 1)
    MinElementSize = (0.01 0.01 0.01)
  }
  Refinement "Ox" {
    MaxElementSize = (0.125 0.125 1)
  }
}

Placements {
  Refinement "global" {
    Reference = "global"
  }
  Refinement "Ox" {
    Reference = "Ox"
    RefineWindow = material ["Oxide"]
  }
}


Offsetting {

  noffset material "Silicon" {
    maxlevel=6
  }

  noffset material "Oxide" {
    maxlevel=6
  }

  noffset material "Silicon" "Oxide" {
    hlocal=0.01
    factor=1.5
  }

  noffset material "Oxide" "Silicon" {
    hlocal=0.015
    factor=1.6
  }
}
