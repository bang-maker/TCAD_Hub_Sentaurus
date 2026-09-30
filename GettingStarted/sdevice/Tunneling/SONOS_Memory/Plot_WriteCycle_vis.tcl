## Script to plot the charge trapped in the nitride region during program and erase cycles

#setdep @node|ProgramErase@

set N @node@

#----------------------------------------------------------------------#
load_file n@node|ProgramErase@_des.plt  -name trap_charge($N)

if {[lsearch [list_plots] Plot_ProgErase] == -1} {
	create_plot -1d -name Plot_ProgErase
	set_plot_prop -title "Program/Erase Cycles" -title_font_size 16 -show_legend
	set_axis_prop -axis x -title {Time [s]} \
		-title_font_size 16 -label_font_size 14 -type linear 
	set_axis_prop -axis y -title {Charge Density [C/cm<sup>3</sup>]} \
		-title_font_size 16 -label_font_size 14 -type linear -range {-1e19 1e19}
	set_axis_prop -axis y2 -title {Voltage [V]} \
	-title_font_size 16 -label_font_size 14 -type linear -range {-10 10}	
	set_legend_prop -label_font_size 12 -label_font_att bold -location top_right 	
}
select_plots Plot_ProgErase

create_curve -name trapped_electrons($N) -dataset trap_charge($N) \
	-axisX "time" -axisY "Aveplot eTrappedCharge"
create_curve -name trapped_holes($N) -dataset trap_charge($N) \
	-axisX "time" -axisY "Aveplot hTrappedCharge"
create_curve -name Vg($N) -dataset trap_charge($N) \
	-axisX "time" -axisY2 "gate OuterVoltage"	
		
set_curve_prop trapped_electrons($N) -label "Trapped Electron Charge Density" \
	-color blue -line_style solid -line_width 3
set_curve_prop trapped_holes($N) -label "Trapped Hole Charge Density" \
	-color red -line_style solid -line_width 3	
set_curve_prop Vg($N) -label "Gate Voltage" \
	-color black -line_style dash -line_width 3	
