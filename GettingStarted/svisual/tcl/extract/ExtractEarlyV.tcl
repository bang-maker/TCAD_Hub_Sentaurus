load_library extract

# Extract Early voltage for a p-n-p bipolar transistor
load_file DATA/IcVc_pnp_des.plt -name IcVce

set Vcs [get_variable_data "collector OuterVoltage" -dataset IcVce]
set Ics [get_variable_data "collector TotalCurrent" -dataset IcVce]
ext::AbsList -out absIcs -x $Ics ;# Compute absolute value of collector current

ext::ExtractEarlyV -out Va -name "out" -v $Vcs -i $absIcs -vo -1.25 -f "%.2f"