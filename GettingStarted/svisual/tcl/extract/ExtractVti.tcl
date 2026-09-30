load_library extract

load_file DATA/IdVgLin_nMOS_des.plt -name DC
set Vgs [get_variable_data "gate OuterVoltage" -dataset DC]
set Ids [get_variable_data "drain TotalCurrent" -dataset DC]

set lgate 0.022 ;# um
set io [expr 100e-9/$lgate] ;# subthreshold current level [A/um]	
ext::ExtractVti -out VtiLin -name "out" -v $Vgs -i $Ids -io $io