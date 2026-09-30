#setdep @node|BV@
set N @node|BV@

load_library extract

# Create plot if it does not exist and set properties
if {[llength [list_plots Plot_1D]]==0} {
  create_plot -1d -name Plot_1D
  select_plots Plot_1D
  set_plot_prop -hide_title -show_legend
  set_legend_prop -label_font_size 14
  set_axis_prop -title_font_size 16 -label_font_size 14 
  set_axis_prop -axis x -title "Cathode Voltage (V)" -type linear \
  -label_format fixed -manual_precision -label_precision 0
  set_axis_prop -axis y -title "Cathode Current (A)" -type log \
  -min 1e-3 -min_fixed -max 0.1 -max_fixed
}

# Load and plot IV curve
load_file "@[relpath BV_[file tail @plot@]]@" -name PLT($N)

create_curve -name IdVd($N) -dataset PLT($N) \
  -axisX "cathode InnerVoltage" -axisY "cathode TotalCurrent" 

# set curve properties only if script is called through run visualizer button
if {[info exists runVisualizerNodesTogether]} {
  set_curve_prop IdVd($N) -label "BV(n$N) $legend" \
    -color $color -line_style $line -line_width 3
} else {
  puts "To see the curves, select both Sentaurus Visual nodes and at the toolbar"
  puts "press the \"Run selected Visualizer Nodes Together\" button."
}

# - Extraction
#----------------------------------------------------------------------#
# Extract BV
set Vds [get_variable_data "cathode InnerVoltage" -dataset PLT($N)]
set Ids [get_variable_data "cathode TotalCurrent" -dataset PLT($N)]
ext::ExtractBVi -out BVi -name BVi -v $Vds -i $Ids -io 0.1 -f %.1f

