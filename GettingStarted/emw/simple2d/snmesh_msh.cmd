#-----------------------------------------
# $Id: //tcad/gemini/w2024.09/allTests/L1.5/GettingStarted/emw/simple2d/snmesh_msh.cmd#1 $
# Author: Gergoe Letay
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
    NPWY = 30
    Grading off
  }
}
