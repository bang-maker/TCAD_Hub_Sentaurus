#setdep @previous@

set N @node@

set dname1 n@previous@

load_file @plot@ -name $dname1

if {[lsearch [list_plots] Diode_BV] == -1} {
  create_plot -1d -name IaVac
  set_plot_prop -plot IaVac -hide_title -hide_legend
  set_axis_prop -plot IaVac -title_font_size 20 -label_font_size 14
  set_axis_prop -plot IaVac -axis y -title "anode current \[A\]"
  set_axis_prop -plot IaVac -axis x -title "anode voltage \[V\]"
  select_plots {IaVac}
}

create_curve -name IV($N) -plot IaVac -dataset "$dname1" \
  -axisX {anode InnerVoltage} -axisY {anode TotalCurrent}

#- Vknee Extraction
#----------------------------------------------------------------------#
set Io    1e-4 ; # [A/um]
set Vd [get_variable_data "anode InnerVoltage"  -dataset $dname1]
set Id [get_variable_data "anode TotalCurrent"  -dataset $dname1]
ext::ExtractVti -out Vknee -name Vknee -v $Vd -i $Id -io $Io

if {[info exists runVisualizerNodesTogether]} {
  set_curve_prop  IV($N) -line_width 3 -color $color
  set_axis_prop -plot IaVac -axis y -min -0.2 -min_fixed -max 7 -max_fixed
  zoom_plot -plot IaVac -reset ;# to reset axis scaling
}
