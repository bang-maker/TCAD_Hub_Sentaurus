IOControls {
	EnableSections
	InputFile="@pwd@/nmos_half_msh.tdr"
	OutputFile="@pwd@/nmos_full_msh.tdr"
}

Tools {
	Reflection {
		axis = xmin
		map "drain" = "source"
	}
}

