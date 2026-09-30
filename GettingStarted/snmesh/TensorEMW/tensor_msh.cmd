IOControls {
  InputFile = "@pwd@/@tdrboundary@"
  EnableSections
  Verbosity=3
}

Tensor {
  Mesh {
    MinCellSize = 0.01
  }
  
  EMW {
    Grading Off
    Parameter Filename = "@parameter@"
    Wavelength = 0.6

    #-----
    #if @example@ == 2
    CRI WavelengthDep real imag
    NPW = 5
    
    #-----
    #elif @example@ == 3
    CRI WavelengthDep real imag
    CRI material "Aluminum" WavelengthDep real
    NPW = 5

    #-----
    #elif @example@ == 4
    CRI WavelengthDep real 
    NPWX = 5
    NPWY = 10

    #-----
    #elif @example@ == 5
    CRI WavelengthDep real 
    NPW = 5
    NPW region "M3a" 30
    NPW material direction "Silicon" "y" 10

    #endif
  }
}
