load_library ifm
lib::SetInfoDef 1

#setdep @node|sdevice@
set P   @node|sdevice@
set Nr  @Nrand@
set Device @Device@
set N   @node@


set jmin @jmin@ ;# Starting index for plotting curves
set jmax @jmax@ ;# Ending   index for plotting curves

set nodeID    n${N}_${Device}
set IVmethod  @Method@
set Mode      @Mode@

set DCfile  IV_n${P}_mos_circuit_des.plt
set ACfile  IV_n${P}_mos_ac_des.plt

set IDs [list rdf tox wfv ift SUM]
set FILEs [list]
foreach ID $IDs {
	lappend FILEs IV_n${P}_mos_${ID}_I_ndrain.csv
}

set IoffLog10 1

set DEV   mos
set GATE  ngate
set DRAIN ndrain

if { $Device == "PMOS" } {
	set sgn -1.0
	set Vhi -1.0
	set Vlo  0.0
	set RANGE {-1 0}
} else {
	set sgn 1.0
	set Vhi 1.0
	set Vlo 0.0
	set RANGE {0 1}
}

#----------------------------------------------------------------------#
# Plotting Reference IV curve
create_plot -1d -name RefIV
select_plots RefIV
set_plot_prop -plot RefIV -title "Reference IV (using \"$IVmethod\" method)" -title_font_size 16

load_file $DCfile -name DC($P)
load_file $ACfile -name AC($P)

create_variable -name Id -dataset DC($P) \
	-function "-1*($sgn)*<i($DEV,$DRAIN):DC($P)>"
create_variable -name Vg -dataset DC($P) \
	-function "<v($GATE):DC($P)>"

set adgs [get_variable_data a($DRAIN,$GATE) -dataset AC($P)]

ifm::GetMOSWeights -out Ws -y $adgs
create_variable -name W -dataset DC($P) -values $Ws

create_curve -name IVref($P) -dataset DC($P) \
	-axisX "Vg" -axisY "Id"
set_curve_prop IVref($P) -label "Reference IV" \
	-color black -line_style solid  -line_width 2 -hide_markers

create_curve -name adg($P) -dataset AC($P) \
	-axisX "v($GATE)" -axisY "a($DRAIN,$GATE)"
set_curve_prop adg($P) -plot RefIV -label "Transcond." \
	-color red -line_style solid  -line_width 2 -hide_markers

if { $IVmethod == "weighted" } {
	create_curve -name W($P) -dataset DC($P) \
		-axisX "Vg" -axisY2 "W"
	set_curve_prop W($P) -plot RefIV -label "Weights" \
		-color green -line_style solid  -line_width 2 -hide_markers
		set_axis_prop -plot RefIV -axis y2 -title "Weight Factor (1)"
}

set_axis_prop -axis y  -title "Drain Current \[A\]" \
	-title_font_size 16 -label_font_size 14
set_axis_prop -axis x  -title "Gate Voltage \[V\]"  -range $RANGE \
	-title_font_size 16 -label_font_size 14

set Vgs [get_variable_data Vg -dataset DC($P)]
set Ids [get_variable_data Id -dataset DC($P)]

ifm::ReadsIFM -out sIFM -nrow Nrow -ncol Ncol -files $FILEs -ids $IDs

foreach ID $IDs {
echo "Working on: $ID"
ifm::GetMOSIVs -out IV -sifm sIFM -nrow Nrow -ncol Ncol -method $IVmethod -sgn $sgn -v $Vgs -i $Ids -y $adgs -id $ID -smooth yes

puts "Extracting Vt and Idhig/low for randomized devices from index 0 to [expr $Nr-1] ..."
set Fou   [open ${nodeID}_${ID}_Pars.csv w]
puts $Fou "Vt,Idhig,Idlow"
set Vts [list]
set Idhigs [list]
set Idlows [list]
for {set j 0} {$j < $Nr} {incr j} {
	set FLAG 1
	ext::ExtractVti -out Vt -name noprint -v $IV(X,$j) -i $IV(Y,$j) -io 1e-7
	# puts "$j: Vt=$Vt"
	ext::ExtractValue -out Idhig -name noprint -x $IV(X,$j) -y $IV(Y,$j) -xo $Vhi
	# puts "$j: Idhig=$Idhig"
	ext::ExtractIoff -out Idlow -name noprint -v $IV(X,$j) -i $IV(Y,$j) -vo $Vlo -log10 $IoffLog10
	# puts "$j: Idlow=$Idlow"
	# echo ">$j) $ID: Vt=$Vt Idhig=$Idhig Idlow=$Idlow <"
	if { $Vt != "x" && $Idhig != "x" && $Idlow != "x" } {
		lappend Vts $Vt
		lappend Idhigs $Idhig
		lappend Idlows $Idlow
		puts $Fou "[format %.5e $Vt],[format %.5e $Idhig],[format %.5e $Idlow]"
	}
	if { [expr $j%500] == 0 } { puts $j }
}
close $Fou
puts "  ... done"

create_plot -1d -name $ID 
select_plots $ID 
set_plot_prop -plot $ID -title "[string toupper $ID]" -title_font_size 16  -hide_legend

puts "Plotting IV for randomized devices from index $jmin to $jmax ..."
for {set j $jmin} {$j < $jmax} {incr j} {
	create_variable -name V -dataset RanIV($P,$ID,$j) -values $IV(X,$j)
	create_variable -name I -dataset RanIV($P,$ID,$j) -values $IV(Y,$j)
	create_curve -name IV($j) -dataset RanIV($P,$ID,$j) \
	-axisX "V" -axisY "I"
	set_curve_prop IV($j)  \
	-color blue -line_style solid  -line_width 1 -hide_markers
	if { [expr $j%10] == 0 } { puts $j }

}
create_curve -name IVref($P) -dataset DC($P) \
	-axisX "Vg" -axisY "Id"
set_curve_prop IVref($P) -label "Reference IV $Mode" \
	-color black -line_style solid  -line_width 2 -hide_markers
set_axis_prop -plot $ID -axis x  -title "Gate Voltage \[V\]" \
	-range $RANGE -title_font_size 16 -label_font_size 14
set_axis_prop -plot $ID -axis y  -title "Drain Current \[A\]" \
	-title_font_size 16 -label_font_size 14

if { $IVmethod == "weighted" } {
	ifm::GetMoments -out Moments -rvs $Vts
	puts "DOE:  sig_Vt_${ID}_IV [format %.3f $Moments(std_dev)]"
}

if { $Mode == "lin" && $IVmethod == "weighted"} {
	ifm::GetMoments -out Moments -rvs $Idhigs
	puts "DOE:  sig_Ilin_${ID}_IV [format %.3e $Moments(std_dev)]"
} elseif { $Mode == "sat" && $IVmethod == "dI"}  {
	ifm::GetMoments -out Moments -rvs $Idhigs
	puts "DOE:  sig_Ion_${ID}_IV [format %.3e $Moments(std_dev)]"
} elseif { $Mode == "sat" && $IVmethod == "exp"}  {
	ifm::GetMoments -out Moments -rvs $Idlows
	puts "DOE:  sig_log10Ioff_${ID}_IV [format %.3e $Moments(std_dev)]"
}

}
puts "  ... done"


