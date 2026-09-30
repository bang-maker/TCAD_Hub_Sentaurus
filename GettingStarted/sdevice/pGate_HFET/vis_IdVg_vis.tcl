#setdep @node|IdVg:all@

set nodes  [list @node|IdVg:all@]
set strain [list @StrainFrom:all@]
set Vds    [list @Vds:all@]
create_plot -1d
select_plots Plot_1

foreach n $nodes st $strain vd $Vds {
  #if "@prjorg@" == "traditional"
  set File n${n}_IdVg_n${n}_des.plt
  #else
  set File "../${n}/n${n}_IdVg_n${n}_des.plt"
  #endif
  set Data IdVg_n${n}
  load_file $File -geoms 0 -name $Data
  create_curve -name $n -plot Plot_1 -dataset $Data -axisX {gate InnerVoltage} -axisY {drain TotalCurrent}
  if {[string match -nocase $st file]} {
   set_curve_prop -plot Plot_1 $n -show_markers -markers_size 7 -hide_line
   set_curve_prop -plot Plot_1 $n -label "V<sub>ds</sub>=[format %02d ${vd}]V full strain model"
  } elseif {[string match -nocase $st stress]} {
   set_curve_prop -plot Plot_1 $n -line_width 3 -line_style dash
   set_curve_prop -plot Plot_1 $n -label "V<sub>ds</sub>=[format %02d ${vd}]V full stress model"
  } elseif {[string match -nocase $st model]} {
   set_curve_prop -plot Plot_1 $n -line_width 3
   set_curve_prop -plot Plot_1 $n -label "V<sub>ds</sub>=[format %02d ${vd}]V simplified strain model"
  }
}

set_axis_prop -plot Plot_1 -axis x -min -0.1 -min_fixed
set_axis_prop -plot Plot_1 -axis x -max 4.1 -max_fixed
set_axis_prop -plot Plot_1 -axis x -title "gate voltage \[V\]"
set_axis_prop -plot Plot_1 -axis x -title_font_family arial -title_font_size 20 -title_font_color #000000 -title_font_att normal
set_axis_prop -plot Plot_1 -axis x -scale_font_family arial -label_font_size 16 -scale_font_color #000000 -label_font_att normal

set_axis_prop -plot Plot_1 -axis y -min -2e-05 -min_fixed
set_axis_prop -plot Plot_1 -axis y -max  0.001 -max_fixed
set_axis_prop -plot Plot_1 -axis y -title "drain current \[A/&mu;m\]"
set_axis_prop -plot Plot_1 -axis y -title_font_family arial -title_font_size 20 -title_font_color #000000 -title_font_att normal
set_axis_prop -plot Plot_1 -axis y -scale_font_family arial -label_font_size 16 -scale_font_color #000000 -label_font_att normal

set_legend_prop -plot Plot_1 -label_font_family arial -label_font_size 14 -label_font_color #000000 -label_font_att normal
set_plot_prop -plot Plot_1 -hide_title


