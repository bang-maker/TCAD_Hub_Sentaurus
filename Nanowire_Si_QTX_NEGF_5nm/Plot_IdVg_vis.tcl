# Plot Id vs. Vg 

#setdep @node|NEGF@

#----------------------------------------------------------------------#

set DATE [exec date]
set WORK [exec pwd]
puts " "
puts "--------------------------------------------------- "
puts "   SVISUAL variable extraction: "
puts "--------------------------------------------------- "
puts " "
puts "Date      : $DATE "
puts "Directory : $WORK "
puts " "

#set VTL          0.0
#set VTS          0.0
#set SSlin        x
#set SSsat        x
#set IDLIN_uA     x
#set IDSAT_uA     x
#set IOFF_nA      x

#----------------------------------------------------------------------#
lib::SetInfoDef 1
#----------------------------------------------------------------------#

set Fpitch        0.016
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
ext::AbsList out= absIds x= $Ids ;# Compute absolute value of drain currents
set Id_um [list ]
foreach i $absIds {
	set ti [expr ($i / $Fpitch)]
	lappend Id_um $ti
}

create_variable -name absId -dataset iv($N) -values $absIds
create_variable -name Id_um -dataset iv($N) -values $Id_um

#- Extraction
#----------------------------------------------------------------------#
echo "#########################################"
echo "Extracting parameters from Id-Vgs curve"
echo "#########################################"

#- Defining current level for Vti extraction
#----------------------------------------------------------------------#
set Io    1.0e-6 ; # [A/um]
puts  "Io: VT Current Level = $Io "
#if "@Type@" == "pMOS"
	set Vo   -1.0e-4
#else
	set Vo    1.0e-4
#endif

#if @< abs(VDRAIN)<0.1 >@

ext::ExtractVti       out= Vti    name= "VTL"       v= $Vgs i= $Id_um  io= $Io         f= %.3f
ext::RemoveDuplicates -out IV -x $Vgs -y $Id_um
ext::ExtractSS        out= SSlin  name= "SSlin"     v= $IV(X)  i= $IV(Y)  vo= $Vo         f= %.1f
ext::ExtractExtremum  out= Idmax  name= "noprint"   x= $Vgs y= $Id_um  extremum= "max" f= %.1f
puts "DOE: IDLIN_uA [format %.1f [expr ($Idmax * 1e6)]]"

if { $Vti != "x" } {
echo "VTL (Vg at Io= [format %.3e $Io] A/um) is [format %.3f $Vti] V"
}
echo "Max IdLin is [format %.3e $Idmax] A/um"

#else

ext::ExtractVti       out= Vti    name= "VTS"       v= $Vgs i= $Id_um  io= $Io           f= %.3f
ext::RemoveDuplicates -out IV -x $Vgs -y $Id_um
ext::ExtractSS        out= SSsat  name= "SSsat"     v= $IV(X)  i= $IV(Y)  vo= $Vo         f= %.1f
ext::ExtractExtremum  out= Idmax  name= "noprint"   x= $Vgs y= $Id_um  extremum= "max"   f= %.1f
ext::ExtractIoff      out= Ioff   name= "noprint"   v= $Vgs i= $Id_um  vo= $Vo log10= 0  f= %.2e
puts "DOE: IDSAT_uA [format %.1f [expr ($Idmax * 1e6)]]"
if { $Ioff != "x" } {
	puts "DOE: IOFF_nA [format %.2e [expr ($Ioff * 1e9)]]"
}

if { $Vti != "x" } {
	echo "VTS (Vg at Io= [format %.3e $Io] A/um) is [format %.3f $Vti] V"
}
echo "Max IdSat is [format %.3e $Idmax] A/um"
if { $Ioff != "x" } {
	puts "Ioff is [format %.3e $Ioff] A/um"
}

#endif

##################################################


# Determine carrier density to consider
#if [string compare @Type@ nMOS]==0
  set carrier eDensity
#else
  set carrier hDensity
#endif

#if "@Shape@" == "Trapezoid"
 #if @Sxx@!=0 || @Syy@!=0 || @Szz@!=0
  #define _t1_  @Type@ W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@ Sxx=@Sxx@ Syy=@Syy@ Szz=@Szz@
 #else
  #define _t1_  @Type@ W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@
 #endif
#elif "@Shape@" == "Circle"
 #if @Sxx@!=0 || @Syy@!=0 || @Szz@!=0
  #define _t1_  @Type@ D/L=@D@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@ Sxx=@Sxx@ Syy=@Syy@ Szz=@Szz@
 #else
  #define _t1_  @Type@ D/L=@D@nm/@L@nm Rc=@Rc@<greek>W</greek> Vd=@VDRAIN@V Scattering=@Scattering@ SelfHeating=@SelfHeating@  
 #endif
#endif

# Create 1D plot
if {[lsearch [list_plots] Plot_IV] == -1} {
	create_plot -1d -name Plot_IV
}
select_plots Plot_IV

#-create_variable -name absId -dataset iv -function -1*<I(drain):iv>

# loop over Y axes. Y1 will be linear, Y2 will be log
foreach YaxisSet [list {Y log -show_legend} {Y2 linear -hide_legend}] {

  set Yaxis  [lindex $YaxisSet 0]
  set Yscale [lindex $YaxisSet 1]
  set Legend [lindex $YaxisSet 2]
   
  # Create plot
  set label "_t1_"
  create_curve -name IdVg_${Yscale}_($N) -dataset iv($N) -axisX "V(gate)"  -axis${Yaxis} "Id_um" 
  set_curve_prop IdVg_${Yscale}_($N) -color $color -show_markers -markers_type $symbol -markers_size 9 -line_width 3 -label $label $Legend
  
  # Set y-axis atributes
  set_axis_prop -axis [string tolower $Yaxis] -type $Yscale -title "I(drain) \[A/<greek>m</greek>m\]" \
     -title_font_size 20 -label_font_size 15 -manual_padding -padding 125
  
};# end loop over linear and log scale
 

# Set x-axis properties
set_axis_prop -axis x -title "V(gate) \[V\]" -title_font_size 20 -label_font_size 15
  
# Set title
set title "Si GAA-NW - IdVg"
set_plot_prop -title $title -title_font_size 20 -title_font_att bold

set_legend_prop -label_font_size 12 -label_font_att normal


