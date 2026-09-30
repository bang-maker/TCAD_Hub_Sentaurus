#setdep @previous@

IOControls {
	EnableTensor
	UnstructuredTensorMesh=True
	EnableSections
	inputFile="n@node|NWgen@_bnd.tdr"
	outputFile="n@node@_msh.tdr"
	numThreads=1
	verbosity=3
}

Definitions {
	Submesh "ReadDoping" {
		Geofile = "n@node|NWgen@_fps.tdr"
	}
}

Placements {
	Submesh "ReadDoping" {
		Reference = "ReadDoping" 
	}
}

Tensor {
  Mesh {
    grading off
    maxCellSize direction "x" 0.0002
    maxCellSize direction "y" 0.0002
    maxCellSize direction "z" 0.00025
  }
}
