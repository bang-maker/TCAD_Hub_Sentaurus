load_library extract

load_file DATA/IdVd_nMOS_des.plt -name DC
set Vds [get_variable_data "drain OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]

ext::ExtractVdlin -out Vdlin -name "out" -v $Vds -i $Ids -io 1e-4 -f "%.4f"