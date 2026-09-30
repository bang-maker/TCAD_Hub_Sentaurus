### Set up some parameters
set DEVNAME  n@node|Garand_MC@

###set SDEVNAME n@pnode|IdVg@
set results_dir "@pwd@/results/nodes"

#if "@Type@" == "nMOS"
set SIGN          1.0
set YaxisSetList  [list {Y log "-not_inverted"} {Y2 linear "-not_inverted"}]
set BMCfile       "BACKWARD_MC_ELEC_OUTPUT"
set EMCfile       "INTERMITTENT_ELEC_OUTPUT"
#elif "@Type@" == "pMOS"
set SIGN          -1.0
set BMCfile       "BACKWARD_MC_HOLE_OUTPUT"
set EMCfile       "INTERMITTENT_HOLE_OUTPUT"
#endif

set Vdd @VDD@
set Vdlin [expr $SIGN * 0.05]
set Vdsat [expr $SIGN * $Vdd]

### Defining current level for Vti extraction
set Io    [expr 1e-7] ; # [A]

set legend_size 20
set label_size  20
set line_width  3

set mc_colour    darkblue
set dd_colour    darkcyan
set sd_colour    darkred

set MCNODE [list @node|Garand_MC:all@]
set DDNODE [list @node|Garand_DD:all@]
set DEV [list @Type:all@]
set VDS [list @Vd:all@]
set VGS [list @Vg:all@]

set NodeDev @Type@
set NodeVd @Vd@

set current_lin [list]
set error_lin [list]
set upper_lin [list]
set lower_lin [list]
set bias_lin [list]
set current_dd_lin [list]
set bias_dd_lin [list]
set current_sat [list]
set error_sat [list]
set upper_sat [list]
set lower_sat [list]
set bias_sat [list]
set current_dd_sat [list]
set bias_dd_sat [list]

set plot_mc_lin false
set plot_mc_sat false
set plot_dd_lin false
set plot_dd_sat false

set curve_dd_lin false
set curve_dd_sat false
set curve_mc_lin false
set curve_mc_sat false

foreach MC $MCNODE DD $DDNODE D $DEV VD $VDS VG $VGS {

    if { $D == $NodeDev && $VD == $Vdlin } {

#       Get DD Idlin from Garand output file and append to list of Idlin(Vg)
        set FILE "${results_dir}/${DD}/n${DD}_IdVg_Vd${VD}_Vsub0.0_1.dat"
        echo $FILE

        if { [file exists $FILE] == 1} {
            set f [open $FILE]
            set lines [split [read $f] \n]
            close $f

            set matches {}
            set matches [lindex $lines 2]

            set plot_dd_lin true
            lappend current_dd_lin [lindex $matches 1]
            lappend bias_dd_lin $VG
        }

#       Get MC Idlin from Garand output file and append to list of Idlin(Vg)
        set BMC_FILE "${results_dir}/${MC}/data/${BMCfile}"
        if { [file exists $BMC_FILE] == 1} {
          set BMC_time [file mtime $BMC_FILE]
          set BMC_CURRENT_LINE "AVERAGE CURRENT"
        } else {
          set BMC_time 0
          set BMC_CURRENT_LINE ""
        }
        set EMC_FILE "${results_dir}/${MC}/data/${EMCfile}"
        if { [file exists $EMC_FILE] == 1} {
          set EMC_time [file mtime $EMC_FILE]
          set EMC_CURRENT_LINE "CURRENT THROUGH TEST PLANE"
        } else {
          set EMC_time 0
          set EMC_CURRENT_LINE ""
        }

        if {$BMC_time > $EMC_time} {
          set FILE $BMC_FILE
          set CURRENT_LINE $BMC_CURRENT_LINE
          set OFFSET 1
        } elseif {$EMC_time > $BMC_time} {
          set FILE $EMC_FILE
          set CURRENT_LINE $EMC_CURRENT_LINE
          set OFFSET 3
        } else {
          set FILE EMPTY
        }
        echo $FILE

        if { [file exists $FILE] == 1} {
            set f [open $FILE]
            set lines [split [read $f] \n]
            close $f

            foreach line $lines { if [regexp $CURRENT_LINE $line]==1 {puts $line; set currentline $line}}
            set strings [split $currentline " "]
            set this_current [lindex $strings [expr [lsearch $strings +/-*] - 1] ]
            set this_error   [lindex $strings [expr [lsearch $strings +/-*] + $OFFSET] ]
            if {$this_current != 0.0} {
                set plot_mc_lin true
                lappend current_lin $this_current
                lappend error_lin   $this_error
                lappend bias_lin $VG }
        }
    }

    if { $D == $NodeDev && $VD == $Vdsat } {

#       Get DD Idsat from Garand output file and append to list of Idsat(Vg)
        set FILE "${results_dir}/${DD}/n${DD}_IdVg_Vd${VD}_Vsub0.0_1.dat"
        echo $FILE

        if { [file exists $FILE] == 1} {
            set f [open $FILE]
            set lines [split [read $f] \n]
            close $f

            set matches {}
            set matches [lindex $lines 2]

            set plot_dd_sat true
            lappend current_dd_sat [lindex $matches 1]
            lappend bias_dd_sat $VG
        }

#       Get MC Idsat from Garand output file and append to list of Idsat(Vg)
        set BMC_FILE "${results_dir}/${MC}/data/${BMCfile}"
        if { [file exists $BMC_FILE] == 1} {
          set BMC_time [file mtime $BMC_FILE]
          set BMC_CURRENT_LINE "AVERAGE CURRENT"
        } else {
          set BMC_time 0
          set BMC_CURRENT_LINE ""
        }
        set EMC_FILE "${results_dir}/${MC}/data/${EMCfile}"
        if { [file exists $EMC_FILE] == 1} {
          set EMC_time [file mtime $EMC_FILE]
          set EMC_CURRENT_LINE "CURRENT THROUGH TEST PLANE"
        } else {
          set EMC_time 0
          set EMC_CURRENT_LINE ""
        }

        if {$BMC_time > $EMC_time} {
          set FILE $BMC_FILE
          set CURRENT_LINE $BMC_CURRENT_LINE
          set OFFSET 1
        } elseif {$EMC_time > $BMC_time} {
          set FILE $EMC_FILE
          set CURRENT_LINE $EMC_CURRENT_LINE
          set OFFSET 3
        } else {
          set FILE EMPTY
        }
        echo $FILE

        if { [file exists $FILE] == 1} {
            set f [open $FILE]
            set lines [split [read $f] \n]
            close $f

            foreach line $lines { if [regexp $CURRENT_LINE $line]==1 {puts $line; set currentline $line}}
            set strings [split $currentline " "]
            set this_current [lindex $strings [expr [lsearch $strings +/-*] - 1] ]
            set this_error   [lindex $strings [expr [lsearch $strings +/-*] + $OFFSET] ]
            if {$this_current != 0.0} {
                set plot_mc_sat true
                lappend current_sat $this_current
                lappend error_sat   $this_error
                lappend bias_sat $VG }
        }
    }
}

# Exit if there is no I-V data to plot
if { $plot_mc_lin == false && $plot_mc_sat == false && $plot_dd_lin == false && $plot_dd_sat ==false } {
    echo "No I-V data to plot"
    exit
}

### Sort data into order based on Vg
if { $plot_dd_lin == true} {
    set data {}
    foreach bias_dd $bias_dd_lin curr_dd $current_dd_lin {
           set values {}
           lappend values $bias_dd
           lappend values $curr_dd
           lappend data   $values
    }
    set bias_dd_lin {} ; set current_dd_lin {}

    if { [llength $data] > 0 } {

        set sorted_data [lsort -index 0 -increasing -real $data]

        foreach val $sorted_data {
            lappend bias_dd_lin     [lindex $val 0]
            lappend current_dd_lin  [lindex $val 1]
        }
    }

    if { [llength $data] > 1 } {set curve_dd_lin true}
}
if { $plot_dd_sat == true} {
    set data {}
    foreach bias_dd $bias_dd_sat curr_dd $current_dd_sat {
           set values {}
           lappend values $bias_dd
           lappend values $curr_dd
           lappend data   $values
    }
    set bias_dd_sat {} ; set current_dd_sat {}

    if { [llength $data] > 0 } {

        set sorted_data [lsort -index 0 -increasing -real $data]

        foreach val $sorted_data {
            lappend bias_dd_sat     [lindex $val 0]
            lappend current_dd_sat  [lindex $val 1]
        }
    }

    if { [llength $data] > 1 } {set curve_dd_sat true}
}
if { $plot_mc_lin == true} {
    set data {}
    foreach bias $bias_lin curr $current_lin err $error_lin {
           set values {}
           lappend values $bias
           lappend values $curr
           lappend values $err
           lappend data   $values
    }
    set bias_lin {} ; set current_lin {}; set error_lin {}

    if { [llength $data] > 0 } {

        set sorted_data [lsort -index 0 -increasing -real $data]

        foreach val $sorted_data {
            lappend bias_lin        [lindex $val 0]
            lappend current_lin     [lindex $val 1]
            lappend upper_lin       [expr [lindex $val 1] + [lindex $val 2]]
            lappend lower_lin       [expr [lindex $val 1] - [lindex $val 2]]
        }
    }

    if { [llength $data] > 1 } {set curve_mc_lin true}
}
if { $plot_mc_sat == true} {
    set data {}
    foreach bias $bias_sat curr $current_sat err $error_sat {
           set values {}
           lappend values $bias
           lappend values $curr
           lappend values $err
           lappend data   $values
    }
    set bias_sat {} ; set current_sat {}; set error_sat {}

    if { [llength $data] > 0 } {

        set sorted_data [lsort -index 0 -increasing -real $data]

        foreach val $sorted_data {
            lappend bias_sat        [lindex $val 0]
            lappend current_sat     [lindex $val 1]
            lappend upper_sat       [expr [lindex $val 1] + [lindex $val 2]]
            lappend lower_sat       [expr [lindex $val 1] - [lindex $val 2]]
        }
    }

    if { [llength $data] > 1 } {set curve_mc_sat true}
}

set PLOTNAME MC-Results
create_plot -1d -name $PLOTNAME
set_legend_prop -plot $PLOTNAME -label_font_family arial -label_font_size $legend_size -label_font_color black -label_font_att normal

#if "@Type@" == "nMOS"
set_legend_prop -plot $PLOTNAME -location top_left
#elif "@Type@" == "pMOS"
set_legend_prop -plot $PLOTNAME -location top_right
#endif

### Set up plots at Vdlin (GarandDD)
if { $plot_dd_lin == true } {
    # Set up curves with linear y-axis
    puts "DD lin: VglinDD=$bias_dd_lin; IdlinDD=$current_dd_lin"
    create_variable -name IdlinDD -dataset DDl -values $current_dd_lin
    create_variable -name VglinDD -dataset DDl -values $bias_dd_lin 
    ext::AbsList -out absIdlinDD -x $current_dd_lin

    create_curve -name ddlin -plot $PLOTNAME -dataset DDl  -axisX "VglinDD" -axisY "IdlinDD"

#if "@Type@" == "pMOS"
    set_curve_prop -plot $PLOTNAME {ddlin} -yScale -1
#endif

    # Set up curves with log y-axis
    create_curve -name ddlin2 -plot $PLOTNAME -dataset DDl  -axisX "VglinDD" -axisY2 "IdlinDD"

    # Colour the lines
    set_curve_prop -plot $PLOTNAME {ddlin ddlin2} -line_width $line_width -color $dd_colour -line_style dashdot -show_markers -markers_size 10

    # Add legends
    set_curve_prop -plot $PLOTNAME {ddlin ddlin2} -label Garand -hide_legend
    set_curve_prop -plot $PLOTNAME {ddlin} -show_legend
}

### Set up plots at Vdsat (GarandDD)
if { $plot_dd_sat == true } {
    # Set up curves with linear y-axis
    puts "DD sat: VgsatDD=$bias_dd_sat; IdsatDD=$current_dd_sat"
    create_variable -name IdsatDD -dataset DDs -values $current_dd_sat
    create_variable -name VgsatDD -dataset DDs -values $bias_dd_sat 
    ext::AbsList -out absIdsatDD -x $current_dd_sat

    create_curve -name ddsat -plot $PLOTNAME -dataset DDs  -axisX "VgsatDD" -axisY "IdsatDD"

#if "@Type@" == "pMOS"
    set_curve_prop -plot $PLOTNAME {ddsat} -yScale -1
#endif

    # Set up curves with log y-axis
    create_curve -name ddsat2 -plot $PLOTNAME -dataset DDs  -axisX "VgsatDD" -axisY2 "IdsatDD"

    # Colour the lines
    set_curve_prop -plot $PLOTNAME {ddsat ddsat2} -line_width $line_width -color $dd_colour -line_style dashdot -show_markers -markers_size 10

    # Add legends
    set_curve_prop -plot $PLOTNAME {ddsat ddsat2} -label Garand -hide_legend
    if { $plot_dd_lin == false } {set_curve_prop -plot $PLOTNAME {ddsat} -show_legend}
}

### Set up plots at Vdlin (GarandMC)
if { $plot_mc_lin == true } {
    # Set up curves with linear y-axis
    puts "MC lin: Vglin=$bias_lin; Idlin=$current_lin"
    create_variable -name Vglin  -dataset EMCl -values $bias_lin 
    create_variable -name Idlin  -dataset EMCl -values $current_lin
    create_variable -name Idlin+ -dataset EMCl -values $upper_lin
    create_variable -name Idlin- -dataset EMCl -values $lower_lin
    ext::AbsList -out absIdlin -x $current_lin

    create_curve -name mclin  -plot $PLOTNAME -dataset EMCl -axisX "Vglin"   -axisY "Idlin"
    create_curve -name mclin+ -plot $PLOTNAME -dataset EMCl -axisX "Vglin"   -axisY "Idlin+"
    create_curve -name mclin- -plot $PLOTNAME -dataset EMCl -axisX "Vglin"   -axisY "Idlin-"

    # Set up curves with log y-axis
    create_curve -name mclin2  -plot $PLOTNAME -dataset EMCl -axisX "Vglin"   -axisY2 "Idlin"
    create_curve -name mclin2+ -plot $PLOTNAME -dataset EMCl -axisX "Vglin"   -axisY2 "Idlin+"
    create_curve -name mclin2- -plot $PLOTNAME -dataset EMCl -axisX "Vglin"   -axisY2 "Idlin-"

#if "@Type@" == "pMOS"
    set_curve_prop -plot $PLOTNAME {mclin mclin+ mclin- mclin2 mclin2+ mclin2-} -yScale -1
#endif

    # Colour the lines
    set_curve_prop -plot $PLOTNAME {mclin mclin+ mclin- mclin2 mclin2+ mclin2-} -line_width $line_width -color $mc_colour
    set_curve_prop -plot $PLOTNAME {mclin mclin2} -show_markers -markers_size 10
    set_curve_prop -plot $PLOTNAME {mclin+ mclin- mclin2+ mclin2-} -line_style dot -hide

    # Add legends
    set_curve_prop -plot $PLOTNAME {mclin mclin+ mclin- mclin2 mclin2+ mclin2-} -label GarandMC -hide_legend
    set_curve_prop -plot $PLOTNAME {mclin} -show_legend
}

### Set up plots at Vdsat (GarandMC)
if { $plot_mc_sat == true } {
    # Set up curves with linear y-axis
    puts "MC sat: Vgsat=$bias_sat; Idsat=$current_sat"
    create_variable -name Vgsat  -dataset EMCs -values $bias_sat
    create_variable -name Idsat  -dataset EMCs -values $current_sat
    create_variable -name Idsat+ -dataset EMCs -values $upper_sat
    create_variable -name Idsat- -dataset EMCs -values $lower_sat
    ext::AbsList -out absIdsat -x $current_sat

    create_curve -name mcsat  -plot $PLOTNAME -dataset EMCs -axisX "Vgsat"   -axisY "Idsat"
    create_curve -name mcsat+ -plot $PLOTNAME -dataset EMCs -axisX "Vgsat"   -axisY "Idsat+"
    create_curve -name mcsat- -plot $PLOTNAME -dataset EMCs -axisX "Vgsat"   -axisY "Idsat-"

    # Set up curves with log y-axis
    create_curve -name mcsat2  -plot $PLOTNAME -dataset EMCs -axisX "Vgsat"   -axisY2 "Idsat"
    create_curve -name mcsat2+ -plot $PLOTNAME -dataset EMCs -axisX "Vgsat"   -axisY2 "Idsat+"
    create_curve -name mcsat2- -plot $PLOTNAME -dataset EMCs -axisX "Vgsat"   -axisY2 "Idsat-"

#if "@Type@" == "pMOS"
    set_curve_prop -plot $PLOTNAME {mcsat mcsat+ mcsat- mcsat2 mcsat2+ mcsat2-} -yScale -1
#endif

    # Colour the lines
    set_curve_prop -plot $PLOTNAME {mcsat mcsat+ mcsat- mcsat2 mcsat2+ mcsat2-} -line_width $line_width -color $mc_colour
    set_curve_prop -plot $PLOTNAME {mcsat mcsat2} -show_markers -markers_size 10
    set_curve_prop -plot $PLOTNAME {mcsat+ mcsat- mcsat2+ mcsat2-} -line_style dot -hide

    # Add legends
    set_curve_prop -plot $PLOTNAME {mcsat mcsat+ mcsat- mcsat2 mcsat2+ mcsat2-} -label GarandMC -hide_legend
    if { $plot_mc_lin == false } {set_curve_prop -plot $PLOTNAME {mcsat} -show_legend}
}


set_plot_prop -plot $PLOTNAME -title_font_family arial -title_font_size $label_size -title_font_color black -title_font_att normal

### Tidy up axes

#if "@Type@" == "nMOS"
set_axis_prop -plot $PLOTNAME -axis x -title "Vg \[V\]" -min 0 -min_fixed -max $Vdd -max_fixed
set_axis_prop -plot $PLOTNAME -axis y  -min 1e-13 -min_fixed -max 2e-06 -max_fixed -type log
set_axis_prop -plot $PLOTNAME -axis y2 -min 0.0   -min_fixed -max 2e-06 -max_fixed
#elif "@Type@" == "pMOS"
set_axis_prop -plot $PLOTNAME -axis x -title "Vg \[V\]" -min -$Vdd -min_fixed -max 0 -max_fixed
set_axis_prop -plot $PLOTNAME -axis y  -min 0.0   -min_fixed -max 2e-06 -max_fixed
set_axis_prop -plot $PLOTNAME -axis y2 -min 1e-13 -min_fixed -max 2e-06 -max_fixed -type log
#endif

set_axis_prop -plot $PLOTNAME -axis y -title "Id \[A\]"
set_axis_prop -plot $PLOTNAME -axis y -title_font_family arial -title_font_size $label_size -title_font_color black -title_font_att normal
set_axis_prop -plot $PLOTNAME -axis y -scale_font_family arial -scale_font_size $label_size -scale_font_color black -scale_font_att normal

set_axis_prop -plot $PLOTNAME -axis y2 -title "Id \[A\]"
set_axis_prop -plot $PLOTNAME -axis y2 -title_font_family arial -title_font_size $label_size -title_font_color black -title_font_att normal
set_axis_prop -plot $PLOTNAME -axis y2 -scale_font_family arial -scale_font_size $label_size -scale_font_color black -scale_font_att normal

set_axis_prop -plot $PLOTNAME -axis x -title_font_family arial -title_font_size $label_size -title_font_color black -title_font_att normal
set_axis_prop -plot $PLOTNAME -axis x -scale_font_family arial -scale_font_size $label_size -scale_font_color black -scale_font_att normal

### Write results to file
if {$plot_dd_lin == true } { export_curves -plot $PLOTNAME {ddlin}               -filename ${results_dir}/@node@/n@node@_Garand_IdVg_lin.plx   -format plx -overwrite }
if {$plot_dd_sat == true } { export_curves -plot $PLOTNAME {ddsat}               -filename ${results_dir}/@node@/n@node@_Garand_IdVg_sat.plx   -format plx -overwrite }
if {$plot_dd_lin == true } { export_curves -plot $PLOTNAME {ddlin}               -filename ${results_dir}/@node@/n@node@_Garand_IdVg_lin.csv   -format csv -overwrite }
if {$plot_dd_sat == true } { export_curves -plot $PLOTNAME {ddsat}               -filename ${results_dir}/@node@/n@node@_Garand_IdVg_sat.csv   -format csv -overwrite }
if {$plot_mc_lin == true } {
    set_curve_prop -plot $PLOTNAME {mclin } -label mclin
    set_curve_prop -plot $PLOTNAME {mclin+} -label mclin+
    set_curve_prop -plot $PLOTNAME {mclin-} -label mclin-
    export_curves  -plot $PLOTNAME {mclin mclin+ mclin-} -filename ${results_dir}/@node@/n@node@_GarandMC_IdVg_lin.plx -format plx -overwrite
    export_curves  -plot $PLOTNAME {mclin mclin+ mclin-} -filename ${results_dir}/@node@/n@node@_GarandMC_IdVg_lin.csv -format csv -overwrite
    set_curve_prop -plot $PLOTNAME {mclin mclin+ mclin- mclin2 mclin2+ mclin2-} -label GarandMC
}
if {$plot_mc_sat == true } {
    set_curve_prop -plot $PLOTNAME {mcsat } -label mcsat
    set_curve_prop -plot $PLOTNAME {mcsat+} -label mcsat+
    set_curve_prop -plot $PLOTNAME {mcsat-} -label mcsat-
    export_curves  -plot $PLOTNAME {mcsat mcsat+ mcsat-} -filename ${results_dir}/@node@/n@node@_GarandMC_IdVg_sat.plx -format plx -overwrite
    export_curves  -plot $PLOTNAME {mcsat mcsat+ mcsat-} -filename ${results_dir}/@node@/n@node@_GarandMC_IdVg_sat.csv -format csv -overwrite
    set_curve_prop -plot $PLOTNAME {mcsat mcsat+ mcsat- mcsat2 mcsat2+ mcsat2-} -label GarandMC
}

### =============================================================
### Extraction of FOMs
### Set some defaults so we are sure the results are new
puts "DOE: Vtgm x"
puts "DOE: VtiLin x"
puts "DOE: IdLin x"
puts "DOE: SSlin x"
puts "DOE: gmLin x"

puts "DOE: VtiSat x"
puts "DOE: IdSat x"
puts "DOE: Ioff x"
puts "DOE: SSsat x"
puts "DOE: gmsat x"

puts "DOE: VtgmDD x"
puts "DOE: VtiLinDD x"
puts "DOE: IdLinDD x"
puts "DOE: SSlinDD x"
puts "DOE: gmLinDD x"

puts "DOE: VtiSatDD x"
puts "DOE: IdSatDD x"
puts "DOE: IoffDD x"
puts "DOE: SSsatDD x"
puts "DOE: gmsatDD x"

## Extract for GarandMC linear
if {$curve_mc_lin == true } {
    ext::ExtractVtgm     -out Vt     -name "Vtgm"    -v $bias_lin -i $absIdlin 
    ext::ExtractVti      -out Vti    -name "VtiLin"  -v $bias_lin -i $absIdlin  -io $Io 
    ext::ExtractExtremum -out Idmax  -name "IdLin"   -x $bias_lin -y $absIdlin -type "max"
#if "@Type@" == "nMOS"
    ext::ExtractExtremum -out Vgminl -name "noprint" -y $bias_lin -x $absIdlin -type "min"
#elif "@Type@" == "pMOS"
    ext::ExtractExtremum -out Vgminl -name "noprint" -y $bias_lin -x $absIdlin -type "max"
#endif
    ext::ExtractSS       -out SS     -name "SSlin"   -v $bias_lin -i $absIdlin -vo $Vgminl
    ext::ExtractGm       -out gm     -name "gmLin"   -v $bias_lin -i $absIdlin 

    echo "Vt (Max gm method) is [format %.3g $Vt] V"
    echo "Vti (Vg at Io= [format %.3e $Io] A/um) is [format %.3f $Vti] V"
    echo "Max IdLin is [format %.3e $Idmax] A/um"
    echo "SSlin is [format %.3f $SS] mV/dec"
    echo "Max gm is [format %.3e $gm] S/um"
}

# Extract for GarandMC staturation
if {$curve_mc_sat == true } {
    ext::ExtractVti      -out VtiSat -name "VtiSat"  -v $bias_sat -i $absIdsat  -io $Io 
    ext::ExtractExtremum -out IdSat  -name "IdSat"   -x $bias_sat -y $absIdsat -type "max"
    ext::ExtractExtremum -out Ioff   -name "Ioff"    -x $bias_sat -y $absIdsat -type "min"
#if "@Type@" == "nMOS"
    ext::ExtractExtremum -out Vgmins -name "noprint" -y $bias_sat -x $absIdsat -type "min"
#elif "@Type@" == "pMOS"
    ext::ExtractExtremum -out Vgmins -name "noprint" -y $bias_sat -x $absIdsat -type "max"
#endif
    ext::ExtractSS       -out SSsat  -name "SSsat"   -v $bias_sat -i $absIdsat -vo $Vgmins
    ext::ExtractGm       -out gmSat  -name "gmSat"   -v $bias_sat -i $absIdsat 

echo "VtiSat (Vg at Io= [format %.3e $Io] A/um) is [format %.3f $VtiSat] V"
echo "Saturation Current IdSat is [format %.3e $IdSat] A/um"
echo "Leakage Current Ioff is [format %.3e $Ioff] A/um"
echo "SSsat is [format %.3f $SSsat] mV/dec"
echo "Max gmSat is [format %.3e $gmSat] S/um"
}

## Extract for GarandDD linear
if {$curve_dd_lin == true } {
ext::ExtractVtgm     -out Vtdd     -name "VtgmDD"    -v $bias_dd_lin -i $absIdlinDD 
ext::ExtractVti      -out Vtidd    -name "VtiLinDD"  -v $bias_dd_lin -i $absIdlinDD  -io $Io 
ext::ExtractExtremum -out Idmaxdd  -name "IdLinDD"   -x $bias_dd_lin -y $absIdlinDD -type "max"
#if "@Type@" == "nMOS"
ext::ExtractExtremum -out Vgminldd -name "noprint" -y $bias_dd_lin -x $absIdlinDD -type "min"
#elif "@Type@" == "pMOS"
ext::ExtractExtremum -out Vgminldd -name "noprint" -y $bias_dd_lin -x $absIdlinDD -type "max"
#endif
ext::ExtractSS       -out SSdd     -name "SSlinDD"   -v $bias_dd_lin -i $absIdlinDD -vo $Vgminldd
ext::ExtractGm       -out gmdd     -name "gmLinDD"   -v $bias_dd_lin -i $absIdlinDD 

echo "Vt DD (Max gm method) is [format %.3g $Vtdd] V"
echo "Vti DD (Vg at Io= [format %.3e $Io] A/um) is [format %.3f $Vtidd] V"
echo "Max IdLin DD is [format %.3e $Idmaxdd] A/um"
echo "SSlin DD is [format %.3f $SSdd] mV/dec"
echo "Max gm DD is [format %.3e $gmdd] S/um"
}

## Extract for GarandDD saturation
if {$curve_dd_sat == true } {
ext::ExtractVti      -out VtiSatdd -name "VtiSatDD"   -v $bias_dd_sat -i $absIdsatDD  -io $Io 
ext::ExtractExtremum -out IdSatdd  -name "IdSatDD"    -x $bias_dd_sat -y $absIdsatDD -type "max"
ext::ExtractExtremum -out Ioffdd   -name "IoffDD"     -x $bias_dd_sat -y $absIdsatDD -type "min"
#if "@Type@" == "nMOS"
ext::ExtractExtremum -out Vgminsdd -name "noprint" -y $bias_dd_sat -x $absIdsatDD -type "min"
#elif "@Type@" == "pMOS"
ext::ExtractExtremum -out Vgminsdd -name "noprint" -y $bias_dd_sat -x $absIdsatDD -type "max"
#endif
ext::ExtractSS       -out SSsatdd  -name "SSsatDD"    -v $bias_dd_sat -i $absIdsatDD -vo $Vgminsdd
ext::ExtractGm       -out gmSatdd  -name "gmSatDD"    -v $bias_dd_sat -i $absIdsatDD 


echo "VtiSat DD (Vg at Io= [format %.3e $Io] A/um) is [format %.3f $VtiSatdd] V"
echo "Saturation Current IdSat DD is [format %.3e $IdSatdd] A/um"
echo "Leakage Current Ioff DD is [format %.3e $Ioffdd] A/um"
echo "SSsat DD is [format %.3f $SSsatdd] mV/dec"
echo "Max gmSat DD is [format %.3e $gmSatdd] S/um"
}




