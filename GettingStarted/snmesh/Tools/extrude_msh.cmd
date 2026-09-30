IOControls {
	EnableSections
	InputFile="@pwd@/nmos_full_msh.tdr"
	OutputFile="@tdr/o@"
}

Tools {
	Extrude {
		extension = 0.5
		steps = 5
	}
}
