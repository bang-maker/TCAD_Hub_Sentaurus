# Breakdown voltage extraction current
set Ilevel 1e-8
set N @node@
set fname @pwd@/break.plt

# What we do depends on whether we run interactively or in batch mode
if {![info exists runVisualizerNodesTogether]} {
  # --------- Extraction -------------------------------------------------
  load_library extract
  load_file $fname -name PLT($N)
  
  # Extract BV
  set Vcs [get_variable_data "Collector InnerVoltage" -dataset PLT($N)]
  set Ics [get_variable_data "Collector TotalCurrent" -dataset PLT($N)]
  
  ext::ExtractBVv -out BV_vmax   -name out -v $Vcs -i $Ics -sign +1  -f %.2f
  ext::ExtractBVi -out BV_Ilevel -name out -v $Vcs -i $Ics -io $Ilevel -f %.2f
} else { 
  # --------- Plotting -------------------------------------------------
  if {[llength [list_plots Plot_1D]]==0} {
    create_plot -1d -name Plot_1D
    select_plots Plot_1D
    set_plot_prop -hide_title -show_legend
    set_axis_prop -title_font_size 24 -label_font_size 20 
    set_axis_prop -axis x -title "Collector Voltage (V)" -type linear \
      -label_format fixed -manual_precision -label_precision 0
    set_axis_prop -axis y -title "Collector Current (A)" -type log \
      -min 1e-15 -min_fixed -max $Ilevel -max_fixed
    set_legend_prop -label_font_size 16 -label_font_att bold
  }
  
  # Load and Plot IV curve
  load_file $fname -name PLT($N)
  create_curve -name IcVc($N) -dataset PLT($N) \
    -axisX "Collector InnerVoltage" -axisY "Collector TotalCurrent"
  set_curve_prop IcVc($N) -label "IcVc(n$N) $legend" \
    -color $color -line_style solid -line_width 3 -show_markers 
}
