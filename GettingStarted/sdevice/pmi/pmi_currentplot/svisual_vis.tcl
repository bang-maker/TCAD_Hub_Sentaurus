#setdep @previous@
set n @node@

#- define some dataset and variable names 
set ds  [file tail [file rootname @plot@]]

set varVbuiltin "Pos(7.7,6.3) ElectrostaticPotential"   
set varVpmi "Position(7.7,6.3,0) ElectrostaticPotential"    

load_file_datasets "@plot@" ;# returns the all geometries or "dataset name"

#-extract photon flux
set Vbuiltin  [lindex [get_variable_data $varVbuiltin -dataset $ds] end]
set Vpmi      [lindex [get_variable_data $varVpmi     -dataset $ds] end] 

#-write values to swb
puts [format "DOE: Vbuiltin %.6g" $Vbuiltin]
puts [format "DOE: Vpmi %.6g"     $Vpmi]


