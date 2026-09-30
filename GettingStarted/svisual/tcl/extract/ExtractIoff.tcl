load_library extract

load_file DATA/IdVgSat_pMOS_des.plt -name DC
set Vgs [get_variable_data "gate OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]
ext::AbsList -out absIds -x $Ids ;# Compute absolute value of drain currents

ext::ExtractIoff -out Ioff -name "out" -v $Vgs -i $absIds -vo -1e-4 -log10 0
puts "Ioff: [format %.3e $Ioff] A/um"
#-> Ioff: 4.009e-06 A/um

ext::ExtractIoff -out log10Ioff -name "noprint" -v $Vgs -i $absIds -vo -1e-4 -log10 1
puts "Log10Ioff: [format %.3f $log10Ioff]"
#-> Log10Ioff: -5.397 