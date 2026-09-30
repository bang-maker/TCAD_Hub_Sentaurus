load_library extract

# Extract gm for a p-MOSFET
load_file DATA/IdVgLin_pMOS_des.plt -name DC
set Vgs [get_variable_data "gate OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]
ext::AbsList -out absIds -x $Ids

ext::ExtractGm -out gmLin -name "out" -v $Vgs -i $absIds

puts "Max gm: [format %.3e $gmLin] S/um"
#-> Max gm: 1.913e-04 S/um