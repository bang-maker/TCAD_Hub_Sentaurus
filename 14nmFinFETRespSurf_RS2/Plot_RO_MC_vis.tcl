#setdep @node|RO_MC_Simulation@
create_plot -1d
create_plot -1d


set dsname "n@node|RO_MC_Simulation@_RO_data"
load_file @pwd@/n@node|RO_MC_Simulation@_/${dsname}.csv
   
create_curve -plot Plot_1 -dataset $dsname -axisX freq -axisY pwr -name ${dsname}_fp
create_curve -plot Plot_2 -dataset $dsname -axisX freq -axisY leakage -name ${dsname}_fl
set_curve_prop -plot Plot_1 ${dsname}_fp -show_markers -hide_line -yScale -1 -markers_size 10 
set_curve_prop -plot Plot_2 ${dsname}_fl -show_markers -hide_line -yScale -1 -markers_size 10 -markers_type cross -line_width 5



set_axis_prop -plot Plot_1 -axis x -title "Frequency (Hz)"
set_axis_prop -plot Plot_1 -axis x -title_font_family arial -title_font_size 25 -title_font_color #000000 -title_font_att normal
set_axis_prop -plot Plot_1 -axis x -scale_font_family arial -label_font_size 20 -scale_font_color #000000 -label_font_att normal
set_axis_prop -plot Plot_2 -axis x -title "Frequency (Hz)"
set_axis_prop -plot Plot_2 -axis x -title_font_family arial -title_font_size 25 -title_font_color #000000 -title_font_att normal
set_axis_prop -plot Plot_2 -axis x -scale_font_family arial -label_font_size 20 -scale_font_color #000000 -label_font_att normal

set_axis_prop -plot Plot_1 -axis y -title "Power (W)"
set_axis_prop -plot Plot_1 -axis y -title_font_family arial -title_font_size 25 -title_font_color #000000 -title_font_att normal
set_axis_prop -plot Plot_1 -axis y -scale_font_family arial -label_font_size 25 -scale_font_color #000000 -label_font_att normal

set_axis_prop -plot Plot_2 -axis y -title "Leakage"
set_axis_prop -plot Plot_2 -axis y -title_font_family arial -title_font_size 25 -title_font_color #000000 -title_font_att normal
set_axis_prop -plot Plot_2 -axis y -scale_font_family arial -label_font_size 20 -scale_font_color #000000 -label_font_att normal


set_legend_prop -plot Plot_1 -label_font_family arial -label_font_size 15 -label_font_color #000000 -label_font_att normal
set_legend_prop -plot Plot_1 -color_fg #ffffff
set_legend_prop -plot Plot_1 -position {0.684912 0.433913}

set_plot_prop -plot {Plot_1 Plot_2} -hide_title -show_grid

