Title "tools section is used to rotate the structure"

IOControls {
	EnableSections
	InputFile="@pwd@/nmos_full_msh.tdr"
	OutputFile="@tdr/o@"
}

Tools {
  Set Transformation{
    rotation {
      axis = ( 0 0 1)
      angle = 180
    }
    Translation = (0 2 0)
  }
  Apply Transformation
}
