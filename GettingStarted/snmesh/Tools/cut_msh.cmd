IOControls {
	EnableSections
	InputFile="@pwd@/nmos_full_msh.tdr"
	OutputFile="@tdr/o@"
}

Tools {
	Sweepmesh {
		extension = 0.5
		steps = 5
	}

	Cut {
		normal = (0 -1 0)
		location = (0 0.5 0)
	}
}

