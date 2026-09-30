IOControls {
  EnableSections
  Verbosity = 3
}

Tensor {
  EMW {
    parameter filename = "@parameter@"
    ComplexRefractiveIndex WavelengthDep  Real  Imag
    wavelength = @wavelength@
    NPWX = 5
    NPWY = 60
    Grading off
  }
}
