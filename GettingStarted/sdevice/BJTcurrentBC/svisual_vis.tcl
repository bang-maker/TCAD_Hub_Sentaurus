#setdep @node|sdevice@

create_plot -1d -name Plot_1D
select_plots Plot_1D

# Load and plot IV curve
load_file @[relpath Ib0_n@node|sdevice@_des.plt]@ -name Ib0
create_curve -name Ib0 -dataset Ib0 \
	-axisX "collector OuterVoltage" -axisY "collector TotalCurrent" 
set_curve_prop Ib0 -label "Ib=@<Ib_ini*1e6>@<greek>m</greek>A/<greek>m</greek>m" \
	-color red -line_style solid -line_width 3

load_file @[relpath Ib1_n@node|sdevice@_des.plt]@ -name Ib1
create_curve -name Ib1 -dataset Ib1 \
	-axisX "collector OuterVoltage" -axisY "collector TotalCurrent" 
set_curve_prop Ib1 -label "Ib=@<(Ib_ini+Ib_end)/2.*1e6>@<greek>m</greek>A/<greek>m</greek>m" \
	-color blue -line_style solid -line_width 3

load_file @[relpath Ib2_n@node|sdevice@_des.plt]@ -name Ib2
create_curve -name Ib2 -dataset Ib2 \
	-axisX "collector OuterVoltage" -axisY "collector TotalCurrent" 
set_curve_prop Ib2 -label "Ib=@<Ib_end*1e6>@<greek>m</greek>A/<greek>m</greek>m" \
	-color green -line_style solid -line_width 3

	
	set_plot_prop -hide_title -show_legend
set_axis_prop -axis x -title "Collector Voltage (V)" \
	-title_font_size 24 -label_font_size 22 -type linear 
set_axis_prop -axis y -title "Collector Current (A/<greek>m</greek>m)" \
	-title_font_size 24 -label_font_size 22 -type linear
set_legend_prop -label_font_size 16 -label_font_att bold -position {0.6 0.8}

