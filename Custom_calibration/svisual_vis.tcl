#setdep @node|sprocess@
# only run interactively when called with visualize selected nodes
if {![info exists runVisualizerNodesTogether]} {exit 0}
#--------------
echo "defining some parameters"
set n @node@
switch @calibration@ {
  on {set color red}
  off {set color blue}
}

#----------------------------------------------
echo "loading plt files"
#load_file "@[relpath n@node|sprocess@_PWellimpl.plx]@" -name dsPwell($n)
load_file "@[relpath n@previous@_PWellimpl.plx]@"     -name dsPwellImp($n)
load_file "@[relpath n@previous@_PWellrta_init.plx]@" -name dsPwellAnn($n)
load_file "@[relpath n@previous@_LDDimpl.plx]@"       -name dsLddImp($n)
load_file "@[relpath n@previous@_LDDrta.plx]@"        -name dsLddAnn($n)

#----------------------------------------------
echo "creating plots"
if {[llength [list_plots]] == 0} {
	create_plot -1d -name PpwellImp
	set_plot_prop -title "PWell as implanted"
	create_plot -1d -name PpwellAnn
	set_plot_prop -title "Pwell annealed"
	create_plot -1d -name PLddImp
	set_plot_prop -title "LDD as implanted"
		create_plot -1d -name PLddAnn
	set_plot_prop -title "LDD annealed"
	link_plots [list_plots] -unlink
	link_plots [list_plots] -special {axis_x}
	foreach p [list_plots] {
	  select_plots $p
	  set_plot_prop -title_font_size 16
	  set_axis_prop -title_font_size 16 -label_font_size 14                                                                                                                                                  
	  set_axis_prop -axis x -title {Depth [<greek>m</greek>m]} -min -0.01 -min_fixed -max 0.35 -max_fixed
	  set_axis_prop -axis y -title {Concentration [cm<sup>-3</sup>]} -type log -min 1e15 -min_fixed 	
	  set_legend_prop -label_font_size 14 -location top_right
	}
}                  

#----------------------------------------------
echo "pwell implant"
select_plots PpwellImp
#----------
echo "create interstitial curve"
create_curve -name cPwellImp($n,i) -dataset dsPwellImp($n) -axisX "Int_Implant x" -axisY "Int_Implant y"
set_curve_prop cPwellImp($n,i) -label "Interstitial $legend" \
  -color $color -line_width 3 -hide_markers
#----------
echo "create Total Boron curve"
if {[llength [list_curves "cPwellImp(*,B)"]] == 0} {
  create_curve -name cPwellImp($n,B) -dataset dsPwellImp($n) -axisX "Boron_Implant x" -axisY "Boron_Implant y"
  set_curve_prop cPwellImp($n,B) -label "Total Boron" \
    -color black -line_width 1 -show_markers -markers_size 8
}


#----------------------------------------------
echo "pwell annealed"
select_plots PpwellAnn
#----------
echo "create active Boron curve"
create_curve -name cPwellAnn($n,B) -dataset dsPwellAnn($n) -axisX "BActive x" -axisY "BActive y"
set_curve_prop cPwellAnn($n,B) -label "Active Boron $legend" \
  -color $color -line_width 3 -hide_markers
#----------
echo "create Boron curve"
if {[llength [list_curves "cPwellAnn(*,Btot)"]] == 0} {
  create_curve -name cPwellAnn($n,Btot) -dataset dsPwellAnn($n) -axisX "BTotal x" -axisY "BTotal y"
  set_curve_prop cPwellAnn($n,Btot) -label "Total Boron" \
    -color black -line_width 1 -show_markers -markers_size 8
}

#----------------------------------------------
echo "LDD implant"
select_plots PLddImp
#----------
echo "create Boron curve"
create_curve -name cLddImp($n,B) -dataset dsLddImp($n) -axisX "Boron_Implant x" -axisY "Boron_Implant y"
set_curve_prop cLddImp($n,B) -label "Boron $legend" \
  -color $color -line_width 3  -hide_markers
#----------
echo "create Arsenic curve"
create_curve -name cLddImp($n,As) -dataset dsLddImp($n) -axisX "Arsenic_Implant x" -axisY "Arsenic_Implant y"
set_curve_prop cLddImp($n,As) -label "Arsenic $legend" \
  -color $color -line_width 3 -line_style dot -hide_markers


#----------------------------------------------
echo "LDD annealed"
select_plots PLddAnn
#----------

echo "create active Boron curves"
create_curve -name cLddAnn($n,B) -dataset dsLddAnn($n) -axisX "BActive x" -axisY "BActive y"
set_curve_prop cLddAnn($n,B) -label "Active Boron $legend" \
  -color $color -line_width 3 -hide_markers
#----------
echo "create active Arsenic curve"
create_curve -name cLddAnn($n,As) -dataset dsLddAnn($n) -axisX "AsActive x" -axisY "AsActive y"
set_curve_prop cLddAnn($n,As) -label "Active Arsenic $legend" \
  -color $color -line_width 3 -line_style dot -hide_markers
#----------
echo "create total Boron curve"
if {[llength [list_curves "cLddAnn(*,Btot)"]] == 0} {
  create_curve -name cLddAnn($n,Btot) -dataset dsLddAnn($n) -axisX "BTotal x" -axisY "BTotal y"
  set_curve_prop cLddAnn($n,Btot) -label "Total Boron" \
    -color black -line_width 1 -show_markers -markers_size 8
}
