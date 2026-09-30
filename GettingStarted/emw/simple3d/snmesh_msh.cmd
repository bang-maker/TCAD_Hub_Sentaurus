IOControls {
	EnableSections
}

Tensor {
#  MESH {
#    MinCellSize direction Y = 1
#  }
  EMW {
    parameter filename = "@parameter@"
    ComplexRefractiveIndex WavelengthDep  Real  Imag
    wavelength = @wavelength@
    NPWX = 5
    NPWY = 5
    NPWZ = 30
    Grading off
  }
}



