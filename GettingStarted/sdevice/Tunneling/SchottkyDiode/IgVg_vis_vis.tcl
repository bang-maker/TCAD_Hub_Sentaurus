#setdep @node|IgVg@
# Plot IgVg

# Some auxiliary variables
set n @node|IgVg@

# Create new formatted frame if it does not yet exist
if {[lsearch [list_plots] IV_plot] == -1} {
	create_plot -1d -name IV_plot
	set_plot_prop -title "I<sub>DS</sub> vs. V<sub>GS</sub>"  -show_grid -hide_title
	set_axis_prop -axis x -title {V<sub>top</sub> [V]} -type linear \
	-title_font_size 20 -label_font_size 18 -title_font_att bold
	
	set_axis_prop -axis y -title {I<sub>top</sub> [A/cm<sup>2</sup>]} \
		-label_format scientific -label_precision 0 -type log \
	-title_font_size 20 -label_font_size 18 -title_font_att bold
	
	set_legend_prop -location top_right -label_font_size 20
}

# Load simulated data and create curves
if [file exists IgVg_n${n}_des.plt] {
	load_file IgVg_n${n}_des.plt -name G_Sim($n)

	create_curve -name Igs($n) -plot IV_plot -dataset G_Sim($n) \
		-axisX {top OuterVoltage} -axisY {top TotalCurrent}
	set_curve_prop Igs($n) -line_width 2 \
		# -label "<greek>F</greek><sub>M</sub> = @WF@ eV" \
		# -label "E<sub>t</sub> = @Et1@ eV" \
		# -label "N<sub>t</sub> = @Nt1@ \[cm<sup>-3</sup>\]" \
		# -label "V<sub>t</sub> = @Vt1@ \[<greek>m</greek>m<sup>3</sup>\]" \
		# -label "TAT: @TAT1@, Tun: @Tun@, <greek>F</greek><sub>M</sub> = @WF@ eV, m<sub>th</sub> = @mth@" \
		# -label "@Tun@ Length=@Length@" \
		# -label "@Length@ cm" \
		-label "mesh fac. = @mesh_fac@" \
		# -label "@Tun@ @par@ @par_val@" \
		# -label "dx = @<f*0.25>@ nm" \
		# -label "l = @<NLMt*1e3>@ nm" \
		# -label "r = @<r*1e3>@ nm" \
		# -label "D<sub>it</sub> = @Dit@ \[cm<sup>-2</sup>\]" \
		# Scale curve so Ig is given in A/cm^2
		-yScale 2e6
}

set Vgs [get_variable_data "top OuterVoltage" -dataset G_Sim($n)]
create_variable -name Iscld -dataset G_Sim($n) -function "12.5e8*<top TotalCurrent:G_Sim($n)>"
set Igs [get_variable_data Iscld -dataset G_Sim($n)]
ext::ExtractValue -out I6 -x $Vgs -y $Igs -xo 6.0 -yLog 1
