IOControls {
  InputFile = "@pwd@/@tdrboundary@"
  EnableSections
  Verbosity=3
}
Tensor {
  Mesh {
    #----------------------------------------
    #if @example@ == 2
    
    #----------------------------------------
    #elif @example@ == 3
    grading off
    
    #----------------------------------------
    #elif @example@ == 4
    grading off
    minCellSize = 0.01 
    maxCellSize = 0.1
    
    #----------------------------------------
    #elif @example@ == 5
    grading off
    minCellSize = 0.05
    maxCellSize = 0.1
    maxCellSize material "Aluminum" 0.01 
    
    #----------------------------------------
    #elif @example@ == 6
    grading off
    minCellSize = 0.01 
    maxCellSize = 0.1
    maxCellSize region direction "M6" "y" 0.02 
    
    #----------------------------------------
    #elif @example@ == 7
    grading off
    minCellSize = 0.01 
    maxCellSize = 0.1
    maxBndCellSize interface material "Aluminum" "Insulator2" 0.01 
    
    #----------------------------------------
    #elif @example@ == 8
    grading off
    minCellSize = 0.01 
    maxCellSize = 0.1
    window "PD" -0.5 0.5 0.2 0.5
    maxCellSize window direction "PD" "x" 0.05
    maxCellSize window direction "PD" "y" 0.02
    
    #----------------------------------------
    #elif @example@ == 9
    numPointsX = 20
    numPointsY = 50
    #endif
  }
}
