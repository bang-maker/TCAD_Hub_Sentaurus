#setdep @previous|all@

set N     @node@
# set curve properties only if script is called through run visualizer button
if {![info exists runVisualizerNodesTogether]} {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
  exit 0 
}
echo "#########################################"
echo "Plotting Id-Vgs curve"
echo "#########################################"
load_file "@[relpath IdVgs_n@node|IdVgs@_des.plt]@" -name PLT_IdVg($N)

if {[lsearch [list_plots] Plot_IdVg] == -1} {
  create_plot -1d -name Plot_IdVg
}
select_plots Plot_IdVg

create_curve -name IdVg($N) -dataset PLT_IdVg($N) -axisX "gate OuterVoltage" -axisY "drain TotalCurrent"
set_curve_prop IdVg($N) -label "IdVg (nMOS) $legend" -color $color -line_style solid -line_width 3

set_axis_prop -title_font_size 16 -label_font_size 14
set_axis_prop -axis x -title "Gate Voltage (V)"  -type linear 
set_axis_prop -axis y -title "Drain Current (A/&mu;m)" -type log 

#if "@tmodel@" == "Thermo"
create_curve -name TmaxVg($N) -dataset PLT_IdVg($N)  -axisX "gate OuterVoltage" -axisY2 Tmax
set_curve_prop TmaxVg($N) -label "TmaxVg $legend" -color $color -line_style dot -line_width 3
set_axis_prop -axis y2 -title "Tmax (K)"  -type linear 
set Title "MOSFET IdVgs/Tmax curves at Vds=1.1 V (@tmodel@ model)"
#elif "@tmodel@" == "HD"
create_curve -name TmaxVg($N) -dataset PLT_IdVg($N)  -axisX "gate OuterVoltage" -axisY2 lTmax
set_curve_prop TmaxVg($N) -label "TmaxVg $legend" -color $color -line_style dot -line_width 3
set_axis_prop -axis y2 -title "Tmax (K)"  -type linear 
set Title "MOSFET IdVgs/Tmax curves at Vds=1.1 V (@tmodel@ model)"
#else
set Title "MOSFET IdVgs curve at Vds=1.1 V (@tmodel@ model)"
#endif

set_plot_prop -title $Title -title_font_size 16 -show_grid -show_legend 
set_grid_prop -align right
set_legend_prop -label_font_size 12 -location bottom_right 

link_plots Plot_IdVg -unlink

echo "#########################################"
echo "Plotting Id-Vds curve"
echo "#########################################"
load_file "@[relpath IdVds_n@node|IdVds@_des.plt]@" -name PLT_IdVd($N)

if {[lsearch [list_plots] Plot_IdVd] == -1} {
  create_plot -1d -name Plot_IdVd
}
select_plots Plot_IdVd

create_curve -name IdVd($N) -dataset PLT_IdVd($N) -axisX "drain OuterVoltage" -axisY "drain TotalCurrent"
set_curve_prop IdVd($N) -label "IdVd (nMOS) $legend" -color $color -line_style solid -line_width 3
set_axis_prop -title_font_size 16 -label_font_size 14
set_axis_prop -axis x -title "Drain Voltage (V)" -type linear 
set_axis_prop -axis y -title "Drain Current (A/&mu;m)" -type linear 

#if "@tmodel@" == "Thermo"
create_curve -name TmaxVd($N) -dataset PLT_IdVd($N)  -axisX "drain OuterVoltage" -axisY2 Tmax
set_curve_prop TmaxVd($N) -label "TmaxVd $legend" -color $color -line_style dot -line_width 3
set_axis_prop -axis y2 -title "Tmax (K)" -type linear 
set Title "MOSFET IdVds/Tmax curves at Vgs=1 V (@tmodel@ model)"
#elif "@tmodel@" == "HD"
create_curve -name TmaxVd($N) -dataset PLT_IdVd($N)  -axisX "drain OuterVoltage" -axisY2 lTmax
set_curve_prop TmaxVd($N) -label "TmaxVd $legend" -color $color -line_style dot -line_width 3
set_axis_prop -axis y2 -title "Tmax (K)" -type linear 
set Title "MOSFET IdVds/Tmax curves at Vgs=1. V (@tmodel@ model)"
#else
set Title "MOSFET IdVds curve at Vgs=1. V (@tmodel@ model)"
#endif

set_plot_prop -title $Title -title_font_size 16 -show_grid -show_legend 
set_grid_prop -align right
set_legend_prop -label_font_size 12 -location bottom_right 

link_plots Plot_IdVd -unlink

echo "#########################################"
echo "Plotting Id-Vds BV curve"
echo "#########################################"
load_file "@[relpath BV_n@node|BV@_des.plt]@" -name PLT_BV($N)

if {[lsearch [list_plots] Plot_BV] == -1} {
  create_plot -1d -name Plot_BV
}
select_plots Plot_BV

create_curve -name BV($N) -dataset PLT_BV($N) -axisX "drain InnerVoltage" -axisY "drain TotalCurrent"
set_curve_prop BV($N) -label "off-state BV (nMOS) $legend" -color $color -line_style solid -line_width 3
set_axis_prop -title_font_size 16 -label_font_size 14
set_axis_prop -axis x -title "Drain Voltage (V)" -type linear 
set_axis_prop -axis y -title "Drain Current (A/&mu;m)" -type linear 

#if "@tmodel@" == "Thermo"
create_curve -name TmaxVd($N) -dataset PLT_BV($N)  -axisX "drain InnerVoltage" -axisY2 Tmax
set_curve_prop TmaxVd($N) -label "TmaxVd $legend" -color $color -line_style dot -line_width 3
set_axis_prop -axis y2 -title "Tmax (K)"  -type linear 
set Title "MOSFET off-state I-V/Tmax-V curves (@tmodel@ model)"
#elif "@tmodel@" == "HD"
create_curve -name TmaxVd($N) -dataset PLT_BV($N)  -axisX "drain InnerVoltage" -axisY2 lTmax
set_curve_prop TmaxVd($N) -label "TmaxVd $legend" -color $color -line_style dot -line_width 3
set_axis_prop -axis y2 -title "Tmax (K)" -type linear 
set Title "MOSFET off-state I-V/Tmax-V curves (@tmodel@ model)"
#else
set Title "MOSFET off-state I-V (@tmodel@ model)"
#endif

set_plot_prop -title $Title -title_font_size 16 -show_grid -show_legend 
set_grid_prop -align right
set_legend_prop -label_font_size 12 -location top_left 

link_plots Plot_BV -unlink

