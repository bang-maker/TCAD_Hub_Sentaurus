#setdep @previous@

set N     @node@

if {![info exists runVisualizerNodesTogether]} {
  puts "To see some curves select some Sentaurus Visual nodes and press \"Run Selected Visualizer Nodes Together\" button in the toolbar."
  exit 0
}


echo "#########################################"
echo "Plotting Id-Vgs curve"
echo "#########################################"
load_file "@[relpath IdVgsLin_n@node|SingleDevice@_des.plt]@" -name PLT_IdVgLin($N)

if {[lsearch [list_plots] Plot_IdVgLin] == -1} {
	create_plot -1d -name Plot_IdVgLin
}
select_plots Plot_IdVgLin

create_curve -name IdVgLin($N) -dataset PLT_IdVgLin($N) -axisX "gate OuterVoltage" -axisY "drain TotalCurrent"
set_curve_prop IdVgLin($N) -label "IdVg_Lin (nMOS)" -color $color -line_style solid -line_width 3

set_axis_prop -axis x -title "Gate Voltage (V)" \
	-title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title "Drain Current (A/&mu;m)" \
	-title_font_size 16 -label_font_size 14 -type log 

set Title "MOSFET IdVgs_Lin curve at Vds=0.1 V"

set_plot_prop -title $Title -title_font_size 16 -show_grid -show_legend 
set_grid_prop -align right
set_legend_prop -label_font_size 18 -location top_left -label_font_att bold

link_plots Plot_IdVg -unlink

load_file "@[relpath IdVgsSat_n@node|SingleDevice@_des.plt]@" -name PLT_IdVgSat($N)

if {[lsearch [list_plots] Plot_IdVgSat] == -1} {
	create_plot -1d -name Plot_IdVgSat
}
select_plots Plot_IdVgSat

create_curve -name IdVgSat($N) -dataset PLT_IdVgSat($N) -axisX "gate OuterVoltage" -axisY "drain TotalCurrent"
set_curve_prop IdVgSat($N) -label "IdVg_Sat (nMOS)" -color $color -line_style solid -line_width 3

set_axis_prop -axis x -title "Gate Voltage (V)" \
	-title_font_size 16 -label_font_size 14 -type linear 
set_axis_prop -axis y -title "Drain Current (A/&mu;m)" \
	-title_font_size 16 -label_font_size 14 -type log 

set Title "MOSFET IdVgs_Sat curve at Vds=1.1 V"

set_plot_prop -title $Title -title_font_size 16 -show_grid -show_legend 
set_grid_prop -align right
set_legend_prop -label_font_size 18 -location top_left -label_font_att bold

link_plots Plot_IdVg -unlink

