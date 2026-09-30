#setdep @node|-1@

IOControls {
	InputFile = "@tdr/i@"
	OutputFile= "@tdr/o@"
	EnableSections
}

Tools {
  Slice {
    normal = (0 0 1)
    location = (0. 0. 0.)
  }
}
