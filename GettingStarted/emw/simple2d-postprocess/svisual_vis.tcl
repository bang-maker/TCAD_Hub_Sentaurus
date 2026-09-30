#-----------------------------------------
# extract reflection R, transmission T and absorption A of a emw simulation
# and output result to swb
#setdep @previous@
# load emw plot file
set ds [load_file "@plot@"] ;# -> returns the first geometry or "dataset name" only
#- set ds [load_file_datasets "@plot@"] ;# -> returns the all geometries or "dataset name"

# extract photon flux
set Ntot  [lindex [get_variable_data "totalIntegr PlaneYmax/PhotonFluxDensity"              -dataset $ds] end]
set Nr    [lindex [get_variable_data "reflectedIntegr PlaneYmin/PhotonFluxDensity"          -dataset $ds] end] 
set Nt    [lindex [get_variable_data "transmittedIntegr PlaneYmax/PhotonFluxDensity"        -dataset $ds] end]
set Nsub  [lindex [get_variable_data "absorbed_subIntegr substrate/AbsorbedPhotonDensity" -dataset $ds] end]
set Nmet  [lindex [get_variable_data "absorbed_metIntegr metal/AbsorbedPhotonDensity"     -dataset $ds] end]
set Ni    [expr $Ntot+$Nr]

# calculate relative values
set R     [expr 1.*$Nr/$Ni]
set T     [expr 1.*$Nt/$Ni]
set Asub  [expr 1.*$Nsub/$Ni]
set Amet  [expr 1.*$Nmet/$Ni]
set RTA [expr $R+$T+$Asub+$Amet]

# write it back to swb
puts [format "DOE: R %.3f"    $R]
puts [format "DOE: T %.3f"    $T]
puts [format "DOE: Asub %.3f" $Asub]
puts [format "DOE: Amet %.3f" $Amet]
puts [format "DOE: RTA %.3f" $RTA]


