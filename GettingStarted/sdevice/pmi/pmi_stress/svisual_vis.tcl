#setdep @previous@

#- define some dataset and variable names 
set ds  [file tail [file rootname @plot@]]
set varS "AveSemiconductor Stress"
set stresses {XX YY ZZ YZ XZ XY}

load_file_datasets "@plot@" ;# returns the all geometries or "dataset name"

foreach d $stresses {
  #-extract photon flux
  set S($d) [lindex [get_variable_data "$varS$d" -dataset $ds] end]
  #-write values to swb
  puts [format "DOE: S$d %.3g" $S($d)]
}

