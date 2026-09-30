#-----------------------------------------
# extract short circuit current jsc
# and output result to swb
#setdep @previous@
# load emw plot file
set ds [load_file "@plot@"] ;# -> returns the first geometry or "dataset name" only
            
#- set ds [load_file_datasets "@plot@"] ;# -> returns all geometries or "dataset name"

# extract last value for current
set jsc [lindex [get_variable_data "nContact TotalCurrent" -dataset $ds] end]

# write it back to swb
puts [format "DOE: jsc %.3g"   $jsc]


