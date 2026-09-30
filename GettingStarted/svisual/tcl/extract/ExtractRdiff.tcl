load_library extract

# Extract on-state output resistance of a p-n-p bipolar transistor
load_file DATA/IcVc_pnp_des.plt -name IcVce
set Vcs [get_variable_data "collector OuterVoltage" -dataset IcVce]
set Ics [get_variable_data "collector TotalCurrent" -dataset IcVce]
ext::AbsList -out absIcs -x $Ics ;# Compute absolute value of collector current

ext::ExtractRdiff -out Ron -name "out" -v $Vcs -i $absIcs -vo -1.25 -f "%.2e"

puts "Ron (at Vcs= -1.25 V): [format %.2e $Ron] Ohm-um"
#-> Ron: 3.35e+04 Ohm-um