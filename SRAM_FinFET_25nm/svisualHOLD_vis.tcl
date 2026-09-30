load_library ifm
source PLOTALL_vis.tcl
#setdep @previous@
set P @previous@
PLOTALL boot $P
PLOTALL flipL $P
PLOTALL flipR $P

create_plot -1d -name SNM
select_plots SNM
set_plot_prop -plot SNM -title "HOLD Butterfly" -title_font_size 16 -show_legend

set CSV_L(Header,0) "Left"
set CSV_L(Data,0)   [get_variable_data v(CL) -dataset D(flipL)]
set CSV_L(Data,1)   [get_variable_data v(CH) -dataset D(flipL)]

set CSV_R(Header,0) "Right"
set CSV_R(Data,0)   [get_variable_data v(CH) -dataset D(flipR)]
set CSV_R(Data,1)   [get_variable_data v(CL) -dataset D(flipR)]
set Ncol 1

ifm::GetSNM -out SNM -squares SQ -vtc_left CSV_L -vtc_right CSV_R -ncol Ncol

create_curve -name VTC(L) -dataset D(flipL) -axisX "v(CL)" -axisY "v(CH)"
set_curve_prop VTC(L) -label VTC(L) -color red -line_style solid  -line_width 3 -hide_markers

create_curve -name VTC(R) -dataset D(flipR) -axisX "v(CL)" -axisY "v(CH)"
set_curve_prop VTC(R) -label VTC(R) -color blue -line_style solid  -line_width 3 -hide_markers

create_variable -name SQ1_x(0) -dataset SQs -values $SQ(1,X,0)
create_variable -name SQ1_y(0) -dataset SQs -values $SQ(1,Y,0)
create_variable -name SQ2_x(0) -dataset SQs -values $SQ(2,X,0)
create_variable -name SQ2_y(0) -dataset SQs -values $SQ(2,Y,0)
	
create_curve -name SQ1(0) -dataset SQs -axisX "SQ1_x(0)" -axisY "SQ1_y(0)"
create_curve -name SQ2(0) -dataset SQs -axisX "SQ2_x(0)" -axisY "SQ2_y(0)"

set_curve_prop SQ1(0) -label SQ1 -color black -line_style solid  -line_width 3 -hide_markers
set_curve_prop SQ2(0) -label SQ2 -color black -line_style solid  -line_width 3 -hide_markers

set_axis_prop -plot SNM -axis y  -title "Vout (V)"
set_axis_prop -plot SNM -axis x  -title "Vin (V)"

puts "DOE: SNMH [format %.2f $SNM(left)]"
