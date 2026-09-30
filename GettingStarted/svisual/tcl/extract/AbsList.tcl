load_library extract

load_file DATA/IdVgLin_pMOS_des.plt -name DC
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]
puts "Ids: $Ids"

# Compute  absolute value of drain currents
ext::AbsList -out Idabs -x $Ids
puts "Idabs: $Idabs"

#-> Ids: -5.40e-10 -9.56e-10 -9.11723e-08 ... -6.73e-05
#-> Idabs: 5.40e-10 9.56e-10 9.11723e-08 ... 6.73e-05