load_library extract

load_file DATA/IdVgLin_nMOS_des.plt -name DC
set Vgs [get_variable_data "gate OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]

ext::ExtractSsub -out Ssub -name "out" -v $Vgs -i $Ids