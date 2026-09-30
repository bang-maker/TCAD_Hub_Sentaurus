
#setdep @node|BV@
set N @node|BV@
set fname @plot@

set Ibvi 1e-4

# What we do depends on whether we run interactively or in batch mode
if {![info exists runVisualizerNodesTogether]} {
  # --------- Extraction -------------------------------------------------
  load_library extract
  
  load_file $fname -name PLT($N)
  # Extract BV
  #if "@BVmethod@" == "ABA_poisson"
  set Vds [get_variable_data "drain InnerVoltage" -dataset PLT($N)]
  set IIs [get_variable_data "PhiHole" -dataset PLT($N)]
  ext::ExtractValue -out BV -name BV -x $IIs -y $Vds -xo 1.0 -f %.2f
  
  #elif "@BVmethod@" == "ABA_coupled"
  create_variable -name II -dataset PLT($N) \
    -function "<IntegrSemiconductor ImpactIonization:PLT($N)>*1.6e-19*1e-12"
  create_variable -name IIO -dataset PLT($N) \
    -function "<II:PLT($N)>-<drain TotalCurrent:PLT($N)>"
  set Vds [lreverse [get_variable_data "drain InnerVoltage" -dataset PLT($N)]]
  set IIs [lreverse [get_variable_data "IIO" -dataset PLT($N)]]
  
  ext::ExtractValue -out BV -name BV -x $IIs -y $Vds -xo 0.0 -f %.2f
  #else
  set Vds [get_variable_data "drain InnerVoltage" -dataset PLT($N)]
  set Ids [get_variable_data "drain TotalCurrent" -dataset PLT($N)]
  
  ext::ExtractBVi -out BV -name BV -v $Vds -i $Ids -io $Ibvi -f %.2f
  #endif
} elseif {[file exists $fname]} { 
  # --------- Plotting -------------------------------------------------
  if {[llength [list_plots Plot_1D]]==0} {
    create_plot -1d -name Plot_1D
    select_plots Plot_1D
    set_plot_prop -hide_title -show_legend
    set_axis_prop -title_font_size 24 -label_font_size 22 -type linear 
    set_axis_prop -axis x -title "Voltage (V)" \
      -label_format fixed -manual_precision -label_precision 0
    set_axis_prop -axis y -title "Current (A/<greek>m</greek>m)" -type log 
    set_axis_prop -axis y2 -title "Ionization Integral (1)" 
    set_legend_prop -label_font_size 16 -label_font_att bold
  }
  
  # Load and plot IV curve
  load_file $fname -name PLT($N)
  #if "@BVmethod@" == "ABA_poisson"
  create_curve -name eII($N) -dataset PLT($N) \
    -axisX "drain InnerVoltage" -axisY2 "PhiElectron"
  set_curve_prop eII($N) -label "eIonIntegral(n$N) $legend" \
    -color $color -line_style dash -line_width 3
  create_curve -name hII($N) -dataset PLT($N) \
    -axisX "drain InnerVoltage" -axisY2 "PhiHole"
  set_curve_prop hII($N) -label "hIonIntegral(n$N) $legend" \
    -color $color -line_style dot -line_width 3
  #elif "@BVmethod@" == "ABA_coupled"
  create_curve -name IdVd($N) -dataset PLT($N) \
    -axisX "drain InnerVoltage" -axisY "drain TotalCurrent"
  set_curve_prop IdVd($N) -label "Conduction Current(n$N) $legend" \
    -color $color -line_style solid -line_width 3
  create_variable -name II -dataset PLT($N) \
    -function "<IntegrSemiconductor ImpactIonization:PLT($N)>*1.6e-19*1e-12"
  create_curve -name II($N) -dataset PLT($N) \
    -axisX "drain InnerVoltage" -axisY "II"
  set_curve_prop II($N) -label "Avalanche Current(n$N) $legend" \
    -color $color -line_style dash -line_width 3
  #else
  create_curve -name IdVd($N) -dataset PLT($N) \
    -axisX "drain InnerVoltage" -axisY "drain TotalCurrent"
  set_curve_prop IdVd($N) -label "IdVd(n$N) $legend" \
    -color $color -line_style solid -line_width 3
  #endif
  # range settings always at the end, otherwise new curves might reset the range
  set_axis_prop -axis y -min 1e-9 -min_fixed -max $Ibvi -max_fixed
  set_axis_prop -axis y2 -min 0.0 -min_fixed -max 1.2 -max_fixed
  
}
