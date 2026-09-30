#setdep @previous@
####################
# default parameters
# wavelength of incident light in um
#seth wavelength 0.6
# number of points per wavelength
#seth npw 15
# number of points per wavelength in z direction
#seth npwz 20
# factor to multiply npw settings for maxNPW setting.
#seth fmax 1.5

IOControls {
  EnableSections
  Verbosity = 3
  NumThreads = 4
}

Tensor {
  #  MESH {
  #    minCellSize direction Y = 1
  #  }
  EMW {
    parameter filename = "@parameter@"
    ComplexRefractiveIndex WavelengthDep  Real  Imag
    wavelength = @wavelength@
    #if "@npwz@" != "_"
    NPWx = @npw@
    NPWy = @npw@
    NPWz = @npwz@
    maxNPWx = @<fmax*npw>@
    maxNPWy = @<fmax*npw>@
    maxNPWz = @<fmax*npwz>@
    #else
    NPW = @npw@
    maxNPW = @<fmax*npw>@
    #endif
    Grading off
  }
}
