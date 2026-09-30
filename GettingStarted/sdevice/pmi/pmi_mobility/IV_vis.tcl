#setdep @previous@
if {![info exists runVisualizerNodesTogether]} {
  puts "To see some curves select some Sentaurus Visual nodes and press \"Run Selected Visualizer Nodes Together\" button in the toolbar."
  exit 0
}

set n @previous@

# Create plot if it does not exist and set properties
if {[llength [list_plots Plot_IdVg]]==0} {
  create_plot -1d -name Plot_IdVg
  set_plot_prop -plot Plot_IdVg -hide_title -show_legend
  set_axis_prop -plot Plot_IdVg -title_font_size 16 -label_font_size 14 
  set_axis_prop -plot Plot_IdVg -axis x -title "Gate Voltage (V)" -type linear 
  set_axis_prop -plot Plot_IdVg -axis y -title "Drain Current (A/<greek>m</greek>m)" -type linear
  set_legend_prop -plot Plot_IdVg -label_font_size 14 -location bottom_right
}
select_plots Plot_IdVg

# Load and create IdVg curve
load_file @[relpath IdVgLin_n@node|sdevice@_des.plt]@ -name PLT($n)
create_curve -name IdVg($n) -dataset PLT($n) \
  -axisX "gate InnerVoltage" -axisY "drain TotalCurrent"

set_curve_prop IdVg($n) -label "IdVg($legend)" -color $color \
  -line_style solid -line_width 3

# Create plot if it does not exist and set properties
if {[llength [list_plots Plot_IdVd]]==0} {
  create_plot -1d -name Plot_IdVd
  link_plots Plot_IdVd -unlink
  set_plot_prop -plot Plot_IdVd -hide_title -show_legend
  set_axis_prop -plot Plot_IdVd -title_font_size 16 -label_font_size 14 
  set_axis_prop -plot Plot_IdVd -axis x -title "Drain Voltage (V)" -type linear 
  set_axis_prop -plot Plot_IdVd -axis y -title "Drain Current (A/<greek>m</greek>m)" -type linear
  set_legend_prop -plot Plot_IdVd -label_font_size 14 -location bottom_right
}
select_plots Plot_IdVd

# Load and create IdVg curve
load_file @[relpath IdVd_n@node|sdevice@_des.plt]@ -name PLT2($n)
create_curve -name IdVd($n) -dataset PLT2($n) \
  -axisX "drain InnerVoltage" -axisY "drain TotalCurrent"

set_curve_prop IdVd($n) -label "IdVd($legend)" -color $color \
  -line_style solid -line_width 3
