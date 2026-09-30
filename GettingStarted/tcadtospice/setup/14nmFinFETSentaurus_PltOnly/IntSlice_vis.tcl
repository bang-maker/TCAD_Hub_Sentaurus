#setdep @node|IdVg@
set Type @Type@
set N @node@
set Vgg @Vgg@
set Hfin @H@
set Tfin @W@

if {$Type == "nMOS"} {set dens eDensity} 
if {$Type == "pMOS"} {set dens hDensity}

set ll [list 0 1 2 3 4 5 6 7 8 9 10]

set densint [list]
set vlist [list]
set dv [expr $Vgg/10]

foreach l $ll {
	set Number [format "%04d" $l]
	load_file "Vg_n@node|IdVg@_0_${Number}_des.tdr" -name PLT($N,$l)
	create_plot -dataset PLT($N,$l)
	select_plots Plot_PLT($N,$l)

	create_cutplane -plot Plot_PLT($N,$l) -type z -at @vert_cutline_coord@
	create_plot -dataset C1(PLT($N,$l)) -ref_plot Plot_PLT($N,$l)
	select_plots Plot_C1(PLT($N,$l))

	set int [integrate_field -plot Plot_C1(PLT($N,$l)) -field $dens -geom C1(PLT($N,$l))]

	# cutlines for DG calib
	select_plots Plot_PLT($N,$l)
	create_cutline -plot Plot_PLT($N,$l) -type free -points {-0.01 0.0001 0 @H@ 0.0001 0} 
	if { $l == 0 } {
             create_plot -dataset C1(PLT($N,$l))_2 -1d -name "cutlineX"
        }
	select_plots "cutlineX"
	create_curve -plot "cutlineX" -dataset "{C1(PLT($N,$l))_2}" -axisX X -axisY $dens

        #puts $myface

	select_plots Plot_PLT($N,$l)
	create_cutline -plot Plot_PLT($N,$l) -type free -points {@horiz_cutline_coord@ 0.0 0 @horiz_cutline_coord@ @<W/2+0.003>@ 0}
	if { $l == 0 } {
	     create_plot -dataset C2(PLT($N,$l)) -1d -name "cutlineY"
        }
 	create_curve -plot "cutlineY" -dataset "{C2(PLT($N,$l))}" -axisX Y -axisY $dens

	#account for half structure. multiply integral by 2.
	lappend densint [expr 2.*$int] 
	
	set v [expr $dv*$l] 
	lappend vlist $v 

}

export_curves {Curve_1 Curve_2 Curve_3 Curve_4 Curve_5 Curve_6 Curve_7 Curve_8 Curve_9 Curve_10 Curve_11} -plot cutlineY -filename n${N}_CutlineY.csv -format csv -overwrite
export_curves {Curve_1 Curve_2 Curve_3 Curve_4 Curve_5 Curve_6 Curve_7 Curve_8 Curve_9 Curve_10 Curve_11} -plot cutlineX -filename n${N}_CutlineX.csv -format csv -overwrite

create_variable -name Vg -dataset DS($N) -values $vlist
create_variable -name ${dens}_int -dataset DS($N) -values $densint
create_plot -1d -name Plot_DensVg($N)
create_curve -plot Plot_DensVg($N) -dataset DS($N) -axisX Vg -axisY ${dens}_int

export_variables "Vg ${dens}_int" -dataset DS($N) -filename "n${N}_${Type}_${dens}_int.csv" -overwrite


	create_cutline -plot Plot_C1(PLT($N,$l)) -type x -at [expr $Hfin/2]

	create_plot -1d -name C1(C1(PLT($N,$l))) 
	select_plots C1(C1(PLT($N,$l)))
	create_curve -name "$dens" -plot C1(C1(PLT($N,$l))) -dataset C1(C1(PLT($N,$l))) -axisX Y -axisY $dens

	export_curves "$dens" -plot C1(C1(PLT($N,$l))) -filename n${N}_${Type}_${dens}vsY.csv -overwrite
   
	create_cutline -plot Plot_C1(PLT($N,$l)) -type y -at [expr $Tfin/4]

	create_plot -1d -name C2(C1(PLT($N,$l))) 
	select_plots C2(C1(PLT($N,$l)))
	create_curve -name "$dens" -plot C2(C1(PLT($N,$l))) -dataset C2(C1(PLT($N,$l))) -axisX X -axisY $dens

	export_curves "$dens" -plot C2(C1(PLT($N,$l))) -filename n${N}_${Type}_${dens}vsX.csv -overwrite

	
