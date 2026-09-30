IOControls {
	EnableSections
	InputFile="@pwd@/nmos_full_msh.tdr"
	OutputFile="@tdrboundary/o@"
}

Tools {
	Mesh2bnd {
		accuracy=0.001
		shortedge=0.001
	}
}
