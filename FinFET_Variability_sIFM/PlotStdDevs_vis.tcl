load_library ifm
lib::SetInfoDef 0

#setdep  @node|sdevice@
set P    @node|sdevice@
set Nr   @Nrand@
set DEV  @Device@
set Mode @Mode@

#if "@Device@" == "PMOS"
set Vlo   0.0
set Sext -0.15
set Vhi  -1.00
set RANGE [list -1 0]
#else
set Vlo   0.0
set Sext  0.15
set Vhi   1.00
set RANGE [list 0 1]
#endif

#set Vt -1
#set sig_Vt_rdf_sIFM -1
#set sig_Vt_rdf_IV   -1
#set sig_Vt_tox_sIFM -1
#set sig_Vt_tox_IV   -1
#set sig_Vt_wfv_sIFM -1
#set sig_Vt_wfv_IV   -1
#set sig_Vt_ift_sIFM -1
#set sig_Vt_ift_IV   -1
#set sig_Vt_SUM_sIFM -1
#set sig_Vt_SUM_IV   -1

#set Ilin -1
#set sig_Ilin_rdf_sIFM -1
#set sig_Ilin_rdf_IV   -1
#set sig_Ilin_tox_sIFM -1
#set sig_Ilin_tox_IV   -1
#set sig_Ilin_wfv_sIFM -1
#set sig_Ilin_wfv_IV   -1
#set sig_Ilin_ift_sIFM -1
#set sig_Ilin_ift_IV   -1
#set sig_Ilin_SUM_sIFM -1
#set sig_Ilin_SUM_IV   -1

#set Ion -1
#set sig_Ion_rdf_sIFM -1
#set sig_Ion_rdf_IV   -1
#set sig_Ion_tox_sIFM -1
#set sig_Ion_tox_IV   -1
#set sig_Ion_wfv_sIFM -1
#set sig_Ion_wfv_IV   -1
#set sig_Ion_ift_sIFM -1
#set sig_Ion_ift_IV   -1
#set sig_Ion_SUM_sIFM -1
#set sig_Ion_SUM_IV   -1

#set log10Ioff -1
#set sig_log10Ioff_rdf_sIFM -1
#set sig_log10Ioff_rdf_IV   -1
#set sig_log10Ioff_tox_sIFM -1
#set sig_log10Ioff_tox_IV   -1
#set sig_log10Ioff_wfv_sIFM -1
#set sig_log10Ioff_wfv_IV   -1
#set sig_log10Ioff_ift_sIFM -1
#set sig_log10Ioff_ift_IV   -1
#set sig_log10Ioff_SUM_sIFM -1
#set sig_log10Ioff_SUM_IV   -1

set File(DC,$P)  IV_n${P}_mos_circuit_des.plt
set File(AC,$P)  IV_n${P}_mos_ac_des.plt

set IDs    [list rdf tox wfv ift SUM]
set COLORs [list red purple green blue black]
set FILEs [list]
foreach ID $IDs {
	lappend FILEs IV_n${P}_mos_${ID}_I_ndrain.csv
}

set DEV   mos
set GATE  ngate
set DRAIN ndrain

#----------------------------------------------------------------------#
load_file $File(DC,$P) -name Data(DC,$P)
load_file $File(AC,$P) -name Data(AC,$P)

#- Plotting the reference curves
#----------------------------------------------------------------------#
create_plot -1d -name RefIV
select_plots RefIV

create_variable -name Id -dataset Data(DC,$P) \
	-function "abs(<i($DEV,$DRAIN):Data(DC,$P)>)"
create_variable -name Vg -dataset Data(DC,$P) \
	-function "<v($GATE):Data(DC,$P)>"

create_curve -name IVref($P) -dataset Data(DC,$P) \
	-axisX "Vg" -axisY "Id"
set_curve_prop IVref($P)  -label "Reference IV " \
	-color blue -line_style solid  -line_width 5 -hide_markers

set_plot_prop -plot RefIV -title "Reference IV"
set_axis_prop -plot RefIV -axis x  -title "Gate Voltage  \[V\]" \
	-title_font_size 16 -label_font_size 14 -range $RANGE
set_axis_prop -plot RefIV -axis y  -title "Drain Current \[A\]" \
	-title_font_size 16 -label_font_size 14 -type log

#- Accessing data sets: Y matrix elements and noise-spectral densities
#- and converting data to Tcl lists for procesing
#----------------------------------------------------------------------#
set Vgs         [get_variable_data Vg -dataset Data(DC,$P)]
set Ids         [get_variable_data Id -dataset Data(DC,$P)]
set adgs        [get_variable_data a($DRAIN,$GATE) -dataset Data(AC,$P)]

#- Reference curve parameter extractions
#----------------------------------------------------------------------#
ext::ExtractVti -out Vt 	-name Vt   -v $Vgs -i $Ids -io 1e-7 -f %.3f
#if "@Mode@" == "lin"
ext::ExtractValue -out Ilin -name Ilin -x $Vgs -y $Ids -xo $Vhi
#else
ext::ExtractValue -out Ion -name Ion -x $Vgs -y $Ids -xo $Vhi
ext::ExtractIoff -out log10Ioff -name log10Ioff -v $Vgs -i $Ids -vo $Vlo -log10 1
ext::ExtractIoff -out Ioff -name noprint -v $Vgs -i $Ids -vo $Vlo -log10 0
#endif

create_plot -1d -name Sig_Id
set_plot_prop -plot Sig_Id -hide_title
create_plot -1d -name Sig_Vg
set_plot_prop -plot Sig_Vg -hide_title

lib::SetInfoDef 1

foreach ID $IDs FILE $FILEs COLOR $COLORs {
	echo $ID

# sIFM standard deviation computation
#----------------------------------------------------------------------#
	if { $ID == "SUM" } {
		set sigIds(SUM,stat) [list]
		set sigVgs(SUM,stat) [list]
		set Nv [llength $sigIds([lindex $IDs 0],stat)]
		for {set iv 0} {$iv < $Nv} {incr iv} {
			set TMPI 0
			set TMPV 0
			foreach tID [lrange $IDs 0 end-1] {
				set sI   [lindex $sigIds($tID,stat) $iv]
				set TMPI [expr $TMPI + $sI*$sI]
				set sV   [lindex $sigVgs($tID,stat) $iv]
				set TMPV [expr $TMPV + $sV*$sV]
			}
			lappend sigIds(SUM,stat) [expr sqrt($TMPI)]
			lappend sigVgs(SUM,stat) [expr sqrt($TMPV)]
		}
	} else {
		ifm::GetsIFMStdDev -out sigIV -sIFM $FILE -y $adgs
		set sigIds($ID,stat) $sigIV(I)
		set sigVgs($ID,stat) $sigIV(V)
	}

lib::SetInfoDef 0
#- sIFM parameter extractions
#----------------------------------------------------------------------#
ext::ExtractValue -out sig_Vt_sIFM -name sig_Vt_${ID}_sIFM -x $Vgs -y $sigVgs($ID,stat)) -xo $Vt -f %.3f
#if "@Mode@" == "lin"
ext::ExtractValue -out sig_Ilin_sIFM -name sig_Ilin_${ID}_sIFM -x $Vgs -y $sigIds($ID,stat)) -xo $Vhi
#else
ext::ExtractValue -out sig_Ion_sIFM  -name sig_Ion_${ID}_sIFM -x $Vgs -y $sigIds($ID,stat)) -xo $Vhi
ext::ExtractValue -out sig_Ioff_sIFM -name noprint 			  -x $Vgs -y $sigIds($ID,stat)) -xo $Vlo
	puts "DOE: sig_log10Ioff_${ID}_sIFM [format %.3e [expr $sig_Ioff_sIFM/(log(10.0)*$Ioff)]]"
#endif

#- Plotting of IFM curves
#----------------------------------------------------------------------#
	create_variable -name Vg -dataset sigs($P,$ID) -values $Vgs
	create_variable -name sigId($ID,stat) -dataset sigs($P,$ID) -values $sigIds($ID,stat)
	create_curve -name sigId($ID,stat) -plot Sig_Id -dataset sigs($P,$ID) \
	-axisX "Vg" -axisY "sigId($ID,stat)"
	set_curve_prop sigId($ID,stat) -plot Sig_Id -label "$ID" \
	-color $COLOR  -line_style solid  -line_width 5 -hide_markers
	
	create_variable -name sigVg($ID,stat) -dataset sigs($P,$ID) -values $sigVgs($ID,stat)
	create_curve -name sigVg($ID,stat) -plot Sig_Vg -dataset sigs($P,$ID) \
	-axisX "Vg" -axisY "sigVg($ID,stat)"
	set_curve_prop sigVg($ID,stat) -plot Sig_Vg -label "$ID" \
	-color $COLOR  -line_style solid  -line_width 5 -hide_markers

}

set_axis_prop -plot Sig_Id -axis x  -title "Gate Voltage \[V\]" \
	-title_font_size 16 -label_font_size 14 -range $RANGE
set_axis_prop -plot Sig_Vg -axis x  -title "Gate Voltage \[V\]" \
	-title_font_size 16 -label_font_size 14 -range $RANGE
set_axis_prop -plot Sig_Id -axis y  -title "Standard Deviations Drain Current \[A\]"\
	-title_font_size 16 -label_font_size 14 -type log
set_axis_prop -plot Sig_Vg -axis y -title "Standard Deviations Gate Voltage \[V\]" \
	-title_font_size 16 -label_font_size 14
set_legend_prop -plot Sig_Id -color_fg white -label_font_size 14
set_legend_prop -plot Sig_Vg -color_fg white -label_font_size 14

