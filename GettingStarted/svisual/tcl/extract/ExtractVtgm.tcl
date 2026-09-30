load_library extract

# Extract Vtgm for a p-MOSFET
load_file DATA/IdVgLin_pMOS_des.plt -name DC
set Vgs [get_variable_data "gate OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]
ext::AbsList -out absIds -x $Ids

ext::ExtractVtgm -out Vtgm -name "out" -v $Vgs -i $absIds

puts "Vt (Max gm method): [format %.3f $Vtgm] V"
#-> Vt (Max gm method): -0.503 V