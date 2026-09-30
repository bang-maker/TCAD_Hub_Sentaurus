#setdep @node|IdVg@

#set Vti x
#set VtiS x
#set SS x
#set DIBL x

set Lg @L@
set W @W@
set H @H@
set W [expr $W+$H*2]
set io [expr 1e-7*$W/$Lg]

set Type @Type@
set N @node@
#----------------------------------------------------------------------#
source Colors_lib.tcl
lib::SetInfoDef 1
if { $Type == "nMOS" } { set SIGN 1 } else { set SIGN -1 }

puts "Gate Length: $Lg um \n"

#----------------------------------------------------------------------#
set NVd 2
set NCOLORS $NVd
set COLORS  [GetColors $NCOLORS 200 200]

#----------------------------------------------------------------------#
echo "#########################################"
echo "Plotting Id-Vg (lin) curve"
echo "#########################################"

if {[lsearch [list_plots] Plot_IdVg] == -1} {
	create_plot -1d -name Plot_IdVg
	set_plot_prop -title "I<sub>d</sub>-V<sub>gs</sub> Curves" -title_font_size 16 -show_legend
	set_axis_prop -axis x -title {Gate Voltage [V]} -title_font_size 16 -label_font_size 14 -type linear
	set_axis_prop -axis y -title {Drain Current [A]} -title_font_size 16 -label_font_size 14 -type linear
	set_legend_prop -label_font_size 12 -location bottom_right -label_font_att bold
}
select_plots Plot_IdVg


set PLTs [lsort [glob IdVg_?_n@node|IdVg@_des.plt]]
set Vds  [list]
set curves [list]
set i 0
foreach PLT $PLTs {
	load_file $PLT -name PLT($N,$i)
	set color   [lindex  $COLORS [expr $i%$NCOLORS]]

	set tmp [get_variable_data "drain OuterVoltage" -dataset PLT($N,$i)]
	set Vd  [lindex $tmp 0]
	lappend Vds $Vd

	set Vgs [get_variable_data "gate OuterVoltage" -dataset PLT($N,$i)]
	set Vga($Vd) $Vgs

	set Ids [get_variable_data "drain TotalCurrent" -dataset PLT($N,$i)]
	set Ida($Vd) $Ids

        if { $Vd==[expr @Vdd_Lin@] } {
            ext::ExtractVti  -out Vti -name Vti -v $Vgs -i $Ids -io $io
        } elseif { $Vd==[expr @Vdd@] } { 
            ext::ExtractVti  -out VtiS -name VtiS -v $Vgs -i $Ids -io $io 
        set vv [expr $VtiS*0.1] 
        
	ext::ExtractSS   -out SS  -name SS -v $Vgs -i $Ids -vo $vv        
	}
	
	
	create_curve -name IdVg($Vd,$N) -dataset PLT($N,$i)	-axisX "gate OuterVoltage" -axisY "drain TotalCurrent"
	set_curve_prop IdVg($Vd,$N) -label "IdVg($Vd)" -color $color -line_style solid -line_width 3
	lappend curves IdVg($Vd,$N)
	
	incr i
}
set DIBL [expr abs($Vti-$VtiS)/(@Vdd@-@Vdd_Lin@)]
puts "DOE: DIBL  [format %#.2g $DIBL]"
                                                                          
export_curves $curves -plot Plot_IdVg -filename n${N}_${Type}_IdVg.csv -format csv -overwrite

