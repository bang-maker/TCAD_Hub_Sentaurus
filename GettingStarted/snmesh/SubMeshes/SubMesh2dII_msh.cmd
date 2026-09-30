IOControls {
  InputFile= "@pwd@/SubMesh2dII_bnd.tdr"
}

Definitions {
  Refinement "Default Region" {
    MaxElementSize = (1 1 )
    MinElementSize = (0.05 0.05 )
    RefineFunction = MaxInterval(
      Variable = "ImpactIonization", 
      cmin=1e20, cmax=1e30, targetLength=0.05, 
      scaling=1, rolloff
    )
    RefineFunction = MaxTransDiff(Variable="DopingConcentration", Value=1)
  }
  SubMesh "SubMesh_0" {
    Geofile  = "@pwd@/submesh_input3.tdr"
  }
}
Placements {
  Refinement "Default Region" {
    Reference = "Default Region"
  }
  SubMesh "SubMesh_0" {
    Reference = "SubMesh_0"
  }
}

