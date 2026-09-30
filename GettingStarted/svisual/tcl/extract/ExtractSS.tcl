load_library extract

load_file DATA/IdVgLin_nMOS_des.plt -name DC
set Vgs [get_variable_data "gate OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]

set Vgo 1e-2
ext::ExtractSS -out SSlin -name "out" -v $Vgs -i $Ids -vo $Vgo