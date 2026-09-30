load_library extract
lib::SetInfoDef 1

load_file DATA/IdVgLin_nMOS_des.plt -name DC
set Vgs [get_variable_data "gate OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]

ext::ExtractVtsat -out VtiLin -name "out" -v $Vgs -i $Ids 