#setdep @node|IdVg@

## Define field names based upon device type

#if "@Type@" == "nMOS"
  set prefix e
#else
  set prefix h
#endif

## Physical device parameters and useful conversion factors (for clarity)
set sweeppoints  5
# start the cut 5nm out of the gate
set start_posz   @<-1*L/2 - 0.005>@   
# set end_posz     @<-1*L/2 - 0.020>@
set end_posz     -0.030
set start_posx   @<H/4>@
set end_posx     @<3*H/4>@
set start_posy   0.001
set end_posy     0.001

set var_k        0

while {$var_k < $sweeppoints} {
   set valz  [expr ($start_posz + $var_k*($end_posz-$start_posz)/($sweeppoints-1))]
   set valx  [expr ($start_posx + $var_k*($end_posx-$start_posx)/($sweeppoints-1))]
   lappend z_list $valz
   lappend x_list $valx
   incr var_k
}
lappend y_list 0.001

set TDR Vg_n@node|IdVg@_0_0000_des.tdr
load_file $TDR -name struct
create_plot -dataset struct -name Plot1
set_field_prop -plot Plot1 -geom struct eMobility -show_bands

foreach y $y_list {
  foreach z $z_list  {
    foreach x $x_list  {
      puts $x
      puts $y
      puts $z
#      lappend field_list [eval probe_field -coord "{$x $y $z}" -field ${prefix}Mobility -plot Plot1 -region SDEpi.1 -geom struct]
      lappend field_list [eval probe_field -coord "{$x $y $z}" -field ${prefix}Mobility -plot Plot1 -geom struct]
    }
  }
}


puts $field_list
set sorted_list [lsort $field_list]

set mean_mob [expr ([join $sorted_list +])/[llength $sorted_list]]
puts [format "DOE: mean_mob %.2f" $mean_mob]

set min_mob [lindex $sorted_list 0]
set max_mob [lindex $sorted_list end]

puts [format "DOE: min_mob %.2f" $min_mob]
puts [format "DOE: max_mob %.2f" $max_mob]


