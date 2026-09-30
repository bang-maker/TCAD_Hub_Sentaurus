Title "tools section is used to translate the structure in the direction ( 0.1 0 0)"

IOControls {
	EnableSections
	InputFile="@pwd@/nmos_full_msh.tdr"
	OutputFile="@tdr/o@"
}

Tools { 
	Set Transformation {
		Translation = ( 0.1 0 0)
	}
	Apply Transformation
}
