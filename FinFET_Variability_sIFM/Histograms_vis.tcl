load_library ifm
lib::SetInfoDef 1
#setdep @node|PlotIVs@
set DEV  @Device@
set Node @node|PlotIVs@
set IVmethod @Method@
set Mode     @Mode@

set IDs    [list rdf tox wfv ift SUM]

if { $Mode == "lin" && $IVmethod == "weighted" } {
	set Pars   [list Vt Idhig]
	set Labels [list "V<sub>th</sub>" "I<sub>lin</sub>"]
	set Units  [list "\[V\]" "\[A\]"]
} elseif { $Mode == "sat" && $IVmethod == "weighted" } {
	set Pars   [list Vt]
	set Labels [list "V<sub>th</sub>" ]
	set Units  [list "\[V\]" ]
} elseif { $Mode == "sat" && $IVmethod == "dI" } {
	set Pars   [list Idhig]
	set Labels [list "I<sub>on</sub>"]
	set Units  [list "\[A\]"]
} elseif { $Mode == "sat" && $IVmethod == "exp" } {
	set Pars   [list Idlow]
	set Labels [list "log<sub>10</sub> Ioff"]
	set Units  [list "\[1\]"]
}

set count 1
foreach ID $IDs  {
	puts "Loading n${Node}_${DEV}_${ID}_Pars.csv"
	load_file n${Node}_${DEV}_${ID}_Pars.csv -name CSV($ID)
	foreach Par $Pars Label $Labels Unit $Units {
		set vals($ID,$Par) [get_variable_data $Par -dataset CSV($ID)]
		set Title($count) "($count) $DEV $ID $IVmethod"
		puts $Title($count)

		ifm::GetMoments -out Moments -rvs $vals($ID,$Par)

		set Nbin 100
		set Xmin [expr $Moments(ave) - 4.0*$Moments(std_dev)]
		set Xmax [expr $Moments(ave) + 4.0*$Moments(std_dev)]
		ifm::GetHistogram -out Histogram -rvs $vals($ID,$Par) -nbin $Nbin -xmin $Xmin -xmax $Xmax
		set Moments(norm) 1.0
		ifm::GetGaussian -out Gaussian -moments Moments -nsam [expr 3*$Nbin] -xmin $Xmin -xmax $Xmax
	
# - Histogram
		create_plot -1d -name H($ID,$Par)
		select_plots H($ID,$Par)
		set_plot_prop -plot H($ID,$Par) -title "$Title($count)"
		incr count

		create_variable -name "H_x($Par)" -dataset "H($ID)" -values $Histogram(X)
		create_variable -name "H_y($Par)" -dataset "H($ID)" -values $Histogram(Y)
		create_curve -name xdist -dataset H($ID) -axisX "H_x($Par)" -axisY "H_y($Par)"
		set_curve_prop xdist -label "Data" -color blue -line_style solid  -line_width 2 -hide_markers
		
		create_variable -name "G_x($Par)" -dataset "G($ID)" -values $Gaussian(X)
		create_variable -name "G_y($Par)" -dataset "G($ID)" -values $Gaussian(Y)
		create_curve -name gdist -dataset G($ID) -axisX "G_x($Par)" -axisY "G_y($Par)"
		set_curve_prop gdist -label "GaussFit" -color red -line_style solid  -line_width 2 -hide_markers

		set_axis_prop -plot H($ID,$Par) -axis x  -title "$Label $Unit" \
			-title_font_size 16 -label_font_size 14
		set_axis_prop -plot H($ID,$Par) -axis y  -title "Normalized Frequency" \
			-title_font_size 16 -label_font_size 14
	
		ifm::GetDataQuantiles -out DataQ -rvs $vals($ID,$Par)
		set Xmin   [expr $Moments(ave) - 3.0*$Moments(std_dev)]
		set Xmax   [expr $Moments(ave) + 3.0*$Moments(std_dev)]
		ifm::GetGaussian -out GaussianQ -type q -moments Moments -nsam 200 -xmin $Xmin -xmax $Xmax
		ifm::GetQQ -out QQ -dq DataQ -gq GaussianQ -moments Moments
		ifm::GetQQ -out QQo -dq GaussianQ -gq GaussianQ -moments Moments
	
# - QQ 
		create_variable -name "Qo_x($Par)" -dataset Qo($ID) -values $QQo(X)
		create_variable -name "Qo_y($Par)" -dataset Qo($ID) -values $QQo(Y)
		create_curve -name QQo -dataset Qo($ID) -axisX "Qo_x($Par)" -axisY2 "Qo_y($Par)"
		set_curve_prop QQo -label "Unity" -color gray -line_style dash  -line_width 2 -hide_markers

		create_variable -name "Q_x($Par)" -dataset Q($ID) -values $QQ(X)
		create_variable -name "Q_y($Par)" -dataset Q($ID) -values $QQ(Y)
		create_curve -name QQ -dataset Q($ID) -axisX "Q_x($Par)" -axisY2 "Q_y($Par)"
		set_curve_prop QQ -label "QQ" -color black -line_style solid  -line_width 3 -hide_markers

		
		set_axis_prop -plot H($ID,$Par) -axis y2  -title "Variation" \
			-title_font_size 16 -label_font_size 14
	}
}
# windows_style -style max 


