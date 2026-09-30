#setdep @node|SDFT@

if {![info exists runVisualizerNodesTogether]||[llength $nodelist] > 1} {
  puts "To see some curves select a single Sentaurus Visual node and press \"Run Selected Visualizer Nodes Together\" button in the toolbar."
  exit 0
}

load_library extract

#- Get final Hdom HB file of interest.       
set fName [lindex [lsort [glob "@[relpath pn_n@node|SDFT@_*_Hdom_des.plt]@"]] end]
puts "$fName"


if {[llength [list_plots]] == 0} {
  create_plot -1d -name "IaTime"
  set_plot_prop -hide_title
  set_axis_prop -title_font_size 20
  set_axis_prop -axis x  -title {time [s]}
  set_axis_prop -axis y  -title {Anode current [A]}
  set_axis_prop -axis y2 -title {Anode voltage [V]}
  set_legend_prop -label_font_size 18 -location bottom_left
  link_plots  "IaTime" -unlink
  #---
  create_plot -1d -name "VaIa"
  set_plot_prop -hide_legend -hide_title
  set_axis_prop -title_font_size 20
  set_axis_prop -axis x -title {Anode voltage [V]}
  set_axis_prop -axis y -title {Anode current [A]}
  link_plots "VaIa" -unlink
}

load_file $fName -name DS

#- get coefficients for all frequencies
set freqs  [get_variable_data "frequency"        -dataset DS]
set resva  [get_variable_data "Re(V_in(anode))"  -dataset DS]
set imsva  [get_variable_data "Im(V_in(anode))"  -dataset DS]
set resia  [get_variable_data "Re(I_t(anode))"   -dataset DS]
set imsia  [get_variable_data "Im(I_t(anode))"   -dataset DS]

proc timedomain { time frequencies revals imvals } {
  set duepi [expr 2.0*acos(-1)]
  set value_td 0.0
  foreach fq $frequencies re $revals im $imvals {
    set value_td [expr $value_td + $re*cos($duepi*$fq*$time) - $im*sin($duepi*$fq*$time)]
  }
  return $value_td
}
puts "testcall = [timedomain 0.0 $freqs $resva $imsva]"

set times [list]
set Time  [expr 1.0/@f1@]
set dt [expr 1.0/@<64*f1>@]
set tmp 0.0
set vas [list]
set ias [list]
while { $tmp <= $Time } {
  lappend vas [timedomain $tmp $freqs $resva $imsva]
  lappend ias [timedomain $tmp $freqs $resia $imsia]
  set tmp [expr $tmp + $dt]
  lappend times $tmp
}

remove_datasets DS

create_variable -name "time"  -dataset "TimeValues" -values $times
create_variable -name "va"    -dataset "TimeValues" -values $vas
create_variable -name "ia"    -dataset "TimeValues" -values $ias

select_plots "IaTime"
create_curve -name "ia_t" -dataset "TimeValues" -axisX "time" -axisY  "ia"
set_curve_prop "ia_t" -label "I<sub>anode</sub>" -color blue -line_width 3
create_curve -name "va_t" -dataset "TimeValues" -axisX "time" -axisY2 "va"
set_curve_prop "va_t" -label "V<sub>anode</sub>" -color green -line_width 3

#--- 
select_plots "VaIa"
create_curve -name "iava" -dataset "TimeValues" -axisX va -axisY ia
set_curve_prop "iava" -color darkGreen -line_width 3

# windows_style -style max         
# select_plots "IaTime"
