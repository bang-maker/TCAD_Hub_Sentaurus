load_library ifm
source PLOTALL_vis.tcl
#setdep @previous@
#setdep @node|sdeviceREAD@
set P   @previous@
set PP  @node|sdeviceREAD@
PLOTALL boot $P
PLOTALL flipWL $P
PLOTALL flipWR $P
PLOTALL flipL  $PP
PLOTALL flipR  $PP

create_plot -1d -name SNM
select_plots SNM
set_plot_prop -plot SNM -title "WRITE Butterfly" -title_font_size 16 -show_legend

create_curve -name VTC_R(L) -dataset D(flipL) -axisX "v(CL)" -axisY "v(CH)"
set_curve_prop VTC_R(L) -label VTC_R(L) -color purple -line_style solid  -line_width 3 -hide_markers

create_curve -name VTC_W(R) -dataset D(flipWR) -axisX "v(CL)" -axisY "v(CH)"
set_curve_prop VTC_W(R) -label VTC_W(L) -color green -line_style solid  -line_width 3 -hide_markers

create_curve -name VTC_R(R) -dataset D(flipR) -axisX "v(CL)" -axisY "v(CH)"
set_curve_prop VTC_R(R) -label VTC_R(R) -color red -line_style solid  -line_width 3 -hide_markers

create_curve -name VTC_W(L) -dataset D(flipWL) -axisX "v(CL)" -axisY "v(CH)"
set_curve_prop VTC_W(L) -label VTC_W(L) -color blue -line_style solid  -line_width 3 -hide_markers

set CSV_L(Header,0) "Left"
set CSV_L(Data,0)   [get_variable_data v(CL) -dataset D(flipL)]
set CSV_L(Data,1)   [get_variable_data v(CH) -dataset D(flipL)]

set CSV_R(Header,0) "Right"
set CSV_R(Data,0)   [get_variable_data v(CH) -dataset D(flipWR)]
set CSV_R(Data,1)   [get_variable_data v(CL) -dataset D(flipWR)]
set Ncol 1

ifm::GetSNM -out SNM1 -squares SQ1 -vtc_left CSV_L -vtc_right CSV_R -ncol Ncol
create_variable -name SQ11_x(0) -dataset SQ1s -values $SQ1(1,X,0)
create_variable -name SQ11_y(0) -dataset SQ1s -values $SQ1(1,Y,0)
create_curve -name SQ11(0) -dataset SQ1s -axisX "SQ11_x(0)" -axisY "SQ11_y(0)"
set_curve_prop SQ11(0) -label SQ1 -color black -line_style solid  -line_width 3 -hide_markers


set CSV_L(Header,0) "Left"
set CSV_L(Data,0)   [get_variable_data v(CL) -dataset D(flipR)]
set CSV_L(Data,1)   [get_variable_data v(CH) -dataset D(flipR)]

set CSV_R(Header,0) "Right"
set CSV_R(Data,0)   [get_variable_data v(CH) -dataset D(flipWL)]
set CSV_R(Data,1)   [get_variable_data v(CL) -dataset D(flipWL)]
set Ncol 1

ifm::GetSNM -out SNM2 -squares SQ2 -vtc_left CSV_L -vtc_right CSV_R -ncol Ncol
create_variable -name SQ21_x(0) -dataset SQ2s -values $SQ2(1,X,0)
create_variable -name SQ21_y(0) -dataset SQ2s -values $SQ2(1,Y,0)
create_curve -name SQ21(0) -dataset SQ2s -axisX "SQ21_x(0)" -axisY "SQ21_y(0)"
set_curve_prop SQ21(0) -label SQ2 -color black -line_style solid  -line_width 3 -hide_markers

set_axis_prop -plot SNM -axis y  -title "Vout (V)"
set_axis_prop -plot SNM -axis x  -title "Vin (V)"
puts "DOE: SNMW [format %.2f $SNM1(left)]"



