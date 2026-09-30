#setdep @node|NWgen@

IOControls {
  EnableTools
  inputFile  = "n@node|NWgen@_fps.tdr"
  outputFile = "n@node@_x_msh.tdr"
}

Tools {
  Slice {
    normal   = (0 0 1)
    location = (0 0 0)
  }
}


