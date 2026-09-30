# Plot Id vs. Vg 

#setdep @node|NEGF@

#----------------------------------------------------------------------#

set DATE [exec date]
set WORK [exec pwd]

#----------------------------------------------------------------------#
lib::SetInfoDef 1
#----------------------------------------------------------------------#

set i  @node:index@
set N  @node@

set SYMBOL  [list square circle diamond plus x]
set NSYMBOLS [llength $SYMBOL]
set symbol   [lindex  $SYMBOL [expr $i%$NSYMBOLS]]

set COLORS  [list green blue red orange magenta violet brown black cyan]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

# Load .plt files
load_file "n@node|NEGF@_IdVg.plt"   -name iv($N)

set Vgs [get_variable_data "V(gate)" -dataset iv($N)]
set Ids [get_variable_data "I(drain)" -dataset iv($N)]
set TIds [get_variable_data "TunnelingCurrent" -dataset iv($N)]
ext::AbsList out= absIds x= $Ids ;# Compute absolute value of drain currents

create_variable -name absId -dataset iv($N) -values $absIds

##################################################

#if "@Shape@" == "Trapezoid"
 #if @Sxx@!=0 || @Syy@!=0 || @Szz@!=0
	#define _t1_  Id (@Type@ W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@ Sxx=@Sxx@ Syy=@Syy@ Szz=@Szz@)
	#define _t2_  Tunneling Current (@Type@ W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@ Sxx=@Sxx@ Syy=@Syy@ Szz=@Szz@)
    #define _t3_  Tunneling Ratio (@Type@ W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@ Sxx=@Sxx@ Syy=@Syy@ Szz=@Szz@)
 #else
	#define _t1_  Id (@Type@ W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@)
	#define _t2_  Tunneling Current (@Type@ W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@)
    #define _t3_  Tunneling Ratio (@Type@ W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@)
 #endif
#elif "@Shape@" == "Circle"
 #if @Sxx@!=0 || @Syy@!=0 || @Szz@!=0
	#define _t1_  Id (@Type@ D/L=@D@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@ Sxx=@Sxx@ Syy=@Syy@ Szz=@Szz@)
	#define _t2_  Tunneling Current (@Type@ D/L=@D@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@ Sxx=@Sxx@ Syy=@Syy@ Szz=@Szz@)
	#define _t3_  Tunneling Ratio (@Type@ D/L=@D@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@ Sxx=@Sxx@ Syy=@Syy@ Szz=@Szz@)	
 #else
	#define _t1_  Id (@Type@ D/L=@D@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@)
	#define _t2_  Tunneling Current (@Type@ D/L=@D@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@)
	#define _t3_  Tunneling Ratio (@Type@ D/L=@D@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@)	  
 #endif
#endif

# Create 1D plot
if {[lsearch [list_plots] Plot_TIV] == -1} {
	create_plot -1d -name Plot_TIV
}
select_plots Plot_TIV

# Create plot

# Create IdVg
create_curve -name IdVg($N) -dataset iv($N) -axisX "V(gate)"  -axisY "absId" 
set_curve_prop IdVg($N) -color $color -show_markers -markers_type $symbol -markers_size 9 -line_width 3 -label "_t1_"
  
# Set y-axis atributes
set_axis_prop -axis Y -type log -title "I(drain) \[A]" \
   -title_font_size 20 -label_font_size 15 -manual_padding -padding 125

# Set x-axis properties
set_axis_prop -axis x -title "V(gate) \[V\]" -title_font_size 20 -label_font_size 15

# Create Tunneling Current
create_curve -name TIdVg($N) -dataset iv($N) -axisX "V(gate)"  -axisY "TunnelingCurrent" 

set j [expr $i+1]
set color   [lindex  $COLORS [expr $j%$NCOLORS]]
set_curve_prop TIdVg($N) -color $color -show_markers -markers_type $symbol -markers_size 9 -line_width 3 -label "_t2_"
  
# Set y-axis atributes
set_axis_prop -axis Y -type log -title "I(drain) \[A]" \
   -title_font_size 20 -label_font_size 15 -manual_padding -padding 125

# Set x-axis properties
set_axis_prop -axis x -title "V(gate) \[V\]" -title_font_size 20 -label_font_size 15
  
# Create Tunneling Ratio
create_curve -plot Plot_TIV -name TRatio($N) -function abs((<TIdVg($N)>/<IdVg($N)>))*100 -y 2

set k [expr $j+1]
set color   [lindex  $COLORS [expr $k%$NCOLORS]]
set_curve_prop TRatio($N) -color $color -show_markers -markers_type $symbol -markers_size 9 -line_width 3 -label "_t3_"

# Set y2-axis atributes
set_axis_prop -axis Y2 -type linear -title "Tunneling Ratio \[%]" \
   -title_font_size 20 -label_font_size 15 -manual_padding -padding 100

# Set title
set title "Si GAA-NW - S/D Tunneling"
set_plot_prop -title $title -title_font_size 20 -title_font_att bold

set_legend_prop -label_font_size 10 -label_font_att normal


