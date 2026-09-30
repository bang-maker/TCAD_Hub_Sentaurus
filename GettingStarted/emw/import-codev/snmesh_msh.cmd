IOControls {
	EnableSections
}

Tensor {
  EMW {
    # parameter filename = "@parameter@"
    ComplexRefractiveIndex WavelengthDep  Real  Imag
    wavelength = @wavelength@
  	NPW = 8
    Grading off
  }
}
