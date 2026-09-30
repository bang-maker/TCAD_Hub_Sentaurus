#setdep @previous@
load_library physicalconstants
#-----------------------------------------
# extract photo generated current jph and short circuit current jsc
#- define some parameters
set varj "cathode TotalCurrent"
set varG "IntegrSemiconductor OpticalGeneration"
set q $const::ElementaryCharge

#- load sdevice plot file
set ds [load_file_datasets "@plot@"]

# extract optical generation convert to current density mA/cm2
set G [lindex [get_variable_data $varG -dataset $ds] end] 
set jph [expr 1e-12*$q*$G] ;# [A]
set jsc [lindex [get_variable_data $varj -dataset $ds] end] 

# write it back to swb
puts [format "DOE: jph %.2e"   $jph]
puts [format "DOE: jsc %.2e"   $jsc]
