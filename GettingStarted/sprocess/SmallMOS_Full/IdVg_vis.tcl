#setdep @node|sdevice@
load_library extract

set N @node|sdevice@

load_file @[relpath IdVg_n@node|sdevice@_des.plt]@ -name PLT($N)

if {[llength [list_plots Plot_IdVg]]==0} {
  create_plot -1d -name Plot_IdVg
  set_plot_prop -hide_title -show_legend
  set_axis_prop -title_font_size 16 -label_font_size 14 
  set_axis_prop -axis x -title {Gate Voltage [V]} -type linear 
  set_axis_prop -axis y -title {Drain Current [A/<greek>m</greek>m]} -type linear
  set_legend_prop -label_font_size 14
}
select_plots Plot_IdVg

create_curve -name IdVg($N) -dataset PLT($N) \
  -axisX "gate InnerVoltage" -axisY "drain TotalCurrent"

# if the script is called through run select visualizer nodes together button
if {[info exists runVisualizerNodesTogether]} {	
  set_curve_prop IdVg($N) -label "IdVg $legend" \
    -color $color -line_style $line -line_width 3
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}

# - Extraction
# ----------------------------------------------------------------------#
load_library extract

#----------------------------------------------------------------------#
set Vgs [get_variable_data "gate OuterVoltage"  -dataset PLT($N)]
set Ids [get_variable_data "drain TotalCurrent" -dataset PLT($N)]
ext::ExtractVtgm     out=Vtgm  name=Vtgm  v= $Vgs i= $Ids 
ext::ExtractExtremum out=Idmax name=Idmax x= $Vgs y= $Ids type=max
ext::ExtractSS       out=SS    name=SS    v= $Vgs i= $Ids vo= 0.01
ext::ExtractGm       out=gm    name=gm    v= $Vgs i= $Ids

