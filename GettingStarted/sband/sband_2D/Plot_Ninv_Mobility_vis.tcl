#setdep @previous@
set mydataset [load_file @[relpath n@node|Compute_Density_Mobility@_epm.plt]]@
if {[llength [list_plots]] == 0} {
set myplot [create_plot -1d]
set_axis_prop -plot $myplot -axis x -title "VG (V)" \
	-title_font_size 16 -label_font_size 16 -type linear 
set_axis_prop -plot $myplot -axis y2 -title "Ninv \(cm<sup>-3</sup>\)" \
	-title_font_size 16 -label_font_size 16 -type linear 
set_axis_prop -plot $myplot -axis y -title "Mobility \(cm<sup>2</sup>/V-s\)" \
	-title_font_size 16 -label_font_size 16 -type linear
} else {
select_plots $myplot
}

set mycurve [create_curve -axisX V(gate) -axisY2 Ninv -dataset $mydataset -plot $myplot]
set_curve_prop $mycurve -plot $myplot -label "Ninv: @Type@, H=@H@, W=@W@" -line_width 3 -line_style dash -show_markers 
set my_color [get_curve_prop $mycurve -plot $myplot -color]
set_legend_prop -plot $myplot -label_font_family arial -label_font_size 12 

set mycurve2 [create_curve -axisX V(gate) -axisY MobilityXX -dataset $mydataset -plot $myplot]
set_curve_prop $mycurve2 -plot $myplot -label "Mob: @Type@ H=@H@, W=@W@" -line_width 3 -line_style dash -markers_type square -show_markers -color $my_color 
set_legend_prop -plot $myplot -label_font_family arial -label_font_size 12 
export_view n@node@_Mobility_Density.png -plots $myplot -format png -overwrite -resolution 1024x768



