load_library extract

# Extract breakdown voltage of a n-p-n bipolar transistor
load_file DATA/IcVcBV_npn_des.plt -name BV
set Vcbs [get_variable_data "collector InnerVoltage" -dataset BV]
set Ics [get_variable_data "collector TotalCurrent" -dataset BV]

ext::ExtractBVi -out BVcboi -name "out" -v $Vcbs -i $Ics -io 1e-12 -f "%.3f"