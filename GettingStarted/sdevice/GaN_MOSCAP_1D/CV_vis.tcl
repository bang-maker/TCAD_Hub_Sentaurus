# Compute CV (low and high frequency curves)

set n @previous@

#if @QS@
set lgnd "Quasi-stationary"
set nx "QS"
#else
set lgnd "Ramp rate: @<5.0/dt>@ V/s"
set nx "@<10.0/dt>@"
#endif

# Create new formatted frame if it does not yet exist
if {[lsearch [list_plots] Plot_C($nx)] == -1} {
	create_plot -1d -name Plot_C($nx)
	## set_plot_prop -title "C<sub>gg</sub> vs. V<sub>g</sub>" -show_legend -show_grid -hide_title
	set_plot_prop -title "$lgnd" -show_grid
	set_axis_prop -axis x -title {V<sub>GS</sub> [V]} \
		-title_font_size 14 -label_font_size 16 -type linear -title_font_att bold
	set_axis_prop -axis y -title {C<sub>GG</sub> [pF/mm]} \
		-label_format preferred -manual_precision -label_precision 1 -type linear \
		-title_font_size 14 -label_font_size 16 -type linear -title_font_att bold
	set_legend_prop -location bottom_right
}

# Plot quasi-static and HF capacitances

# First load file with "quasi-static" data and build corresponding curve from dQg/dVg
load_file C_n${n}_des.plt -name DS_C($n)
create_variable -name Clf -dataset DS_C($n) -function "diff(<gate Charge:DS_C($n)>,<gate OuterVoltage:DS_C($n)>)"
create_curve -name Cglf($n) -plot Plot_C($nx) -dataset DS_C($n) \
	-axisX "gate OuterVoltage" -axisY Clf

# Format curve and multiply capacitance by 1e6 to get it in uF/cm^2
set_curve_prop Cglf($n) -label "LF" -line_width 2 -yScale 1e+6

# Now repeat for high frequency curve from AC analysis
load_file n${n}_ac_des.plt -name DS_HF($n)
create_curve -name Cghf($n) -plot Plot_C($nx) -dataset DS_HF($n) \
	-axisX v(1) -axisY c(1,1)
set clr [get_curve_prop Cglf($n) -color]
set_curve_prop Cghf($n) -label "HF" -line_width 2 -yScale 1e+6 \
	-color $clr -line_style dash

set Cgg [get_variable_data "Clf" -dataset DS_C($n)]
set Vg [get_variable_data "gate OuterVoltage" -dataset DS_C($n)]
ext::ExtractValue -out Cg_inv -x $Vg -y $Cgg -xo 0

