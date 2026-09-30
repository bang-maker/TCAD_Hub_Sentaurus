IOControls {
        InputFile = "@pwd@/prcsim_bnd.tdr"
  EnableTensor
} * end IOControls

Definitions {
  SubMesh "SubMesh" {              
		Geofile = "@pwd@/prcsim_fps.tdr"
  }
} * end Definitions

Placements {
  SubMesh "SubMesh" {
    Reference = "SubMesh"
  }                             
} * end placements

#----------------------------------------
#if "@example@" == "T1"
Tensor {
  Mesh {
    Doping
  }
} * end Tensor

#----------------------------------------
#elif "@example@" == "T2"
Tensor {
  Mesh {
    window "finemesh" 0.0 0.036 0.0 0.01 -0.1 0.1
	window "finemesh1" 0.0 0.036 0.0 0.01 0.1 0.2
	window "finemesh2" 0.0 0.036 0.0 0.01 -0.2 -0.1
    
    maxCellSize window "finemesh" 0.0015
    
    maxCellSize window direction "finemesh" "x" 0.00075
    maxCellSize window direction "finemesh" "y" 0.00075
    
	maxCellSize window "finemesh1" 0.00075		
	maxCellSize window "finemesh2" 0.00075
    
    Doping
  }
} * end Tensor

#----------------------------------------
#elif "@example@" == "T3"
Tensor {
  Mesh {
    window "finemesh" 0.0 0.036 0.0 0.01 -0.01 0.001
	window "finemesh1" 0.0 0.036 0.0 0.01 0.01 0.2
	window "finemesh2" 0.0 0.036 0.0 0.01 -0.2 -0.01
    
    maxCellSize window "finemesh" 0.0015
    
    maxCellSize window direction "finemesh" "x" 0.00075
    maxCellSize window direction "finemesh" "y" 0.00075
    
	maxCellSize window "finemesh1" 0.005		
	maxCellSize window "finemesh2" 0.005
    
    Doping
  }
} * end Tensor

#----------------------------------------
#elif "@example@" == "T4"
Tensor {
  Mesh {
    maxCellSize region "ChFin"  0.0015
    maxCellSize region direction "ChFin" "x" 0.00075
    maxCellSize region direction "ChFin" "y" 0.00075
    
    maxCellSize region direction "SDepi.1" "X" 0.005
    maxCellSize region direction "SDepi.2" "x" 0.005
    
    maxCellSize region "GATEox_1"  0.0015
    maxCellSize region direction "GATEox_1" "x" 0.0005
    maxCellSize region direction "GATEox_1" "y" 0.0005
    
    maxCellSize region "HfO2_1"  0.0015
    maxCellSize region direction "HfO2_1" "x" 0.0005
    maxCellSize region direction "HfO2_1" "y" 0.0005
    
    Doping
  }
} * end Tensor
#endif
