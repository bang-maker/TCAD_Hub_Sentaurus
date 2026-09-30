#setdep @previous@

set N @node@

set dname1 n@previous@

load_file @plot@ -name $dname1

if {[lsearch [list_plots] Diode_BV] == -1} {
  create_plot -1d -name Diode_BV
  set_plot_prop -plot Diode_BV -hide_title -hide_legend
  set_axis_prop -plot Diode_BV -title_font_family arial -title_font_size 20 \
    -label_font_size 14
  set_axis_prop -plot Diode_BV -axis x -title "anode voltage \[V\]" 
  set_axis_prop -plot Diode_BV -axis y -title "anode current \[A\]"\
    -type log -label_format scientific
  select_plots {Diode_BV}
}

create_curve -name revIV($N) -plot Diode_BV -dataset "$dname1" \
  -axisX {anode InnerVoltage} -axisY {anode TotalCurrent}

set Vd [get_variable_data "anode InnerVoltage" -dataset "$dname1"]
ext::AbsList -out Vdnew -x $Vd
ext::ExtractExtremum -out BV -name "BV" -x $Vdnew -y $Vdnew -type "max" -f "%.2f"

set time [get_variable_data "time" -dataset "$dname1"]
ext::ExtractValue -out tBV -name "noprint" -x $Vdnew -y $time -xo $BV -xLog 1 \
  -yLog 1 -f "%.4e"

if {[info exists runVisualizerNodesTogether]} {
  set_curve_prop revIV($N) -line_width 3 -color $color
  set_axis_prop -plot Diode_BV -axis x -min -180 -min_fixed -max 10 -max_fixed
  set_axis_prop -plot Diode_BV -axis y -min 1e-12 -min_fixed -max 1e-5 -max_fixed
  zoom_plot -plot Diode_BV -reset ;# to reset axis scaling
}
