proc PLOTALL { N P } {

	load_file ${N}_n${P}_sys_des.plt -name D($N)

	create_plot -1d -name $N
	select_plots $N
	set_plot_prop -plot $N -title "$N" -title_font_size 16 -show_legend

	set_axis_prop -plot $N -axis y  -title "Vout (V)"
	set_axis_prop -plot $N -axis x  -title "Sweep"

	create_curve -name DD -plot $N -dataset D($N) -axisX "time" -axisY "v(DD)"
	set_curve_prop DD -label "DD" -color orange -line_style solid -line_width 3

	create_curve -name PRB_l -dataset D($N) -axisX time -axisY v(PRB_l)
	set_curve_prop PRB_l -label "PRB_l" -color blue -line_style solid -line_width 3 -show_markers

	create_curve -name PRB_r -dataset D($N) -axisX time -axisY v(PRB_r)
	set_curve_prop PRB_r -label "PRB_r" -color blue -line_style solid -line_width 3 -show_markers	

	create_curve -name  CH -dataset D($N) -axisX time -axisY v(CH)
	set_curve_prop CH -label "CH" -color red -line_style solid -line_width 3

	create_curve -name  CL -dataset D($N) -axisX time -axisY v(CL)
	set_curve_prop CL -label "OUT" -color red -line_style solid -line_width 3

}

