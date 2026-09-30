#setdep @node|SdeviceSBTE@

#define _OffLevel_ 1
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
#set IOFF_pA      x

#if _OffLevel_
#set WF1pA      0.0
#set WF10pA     0.0
#endif

set i  @node:index@
set N  @node@

set SYMBOL  [list square circle diamond plus x]
set NSYMBOLS [llength $SYMBOL]
set symbol   [lindex  $SYMBOL [expr $i%$NSYMBOLS]]

set COLORS  [list green blue red orange magenta violet brown black cyan]
set NCOLORS [llength $COLORS]
set color   [lindex  $COLORS [expr $i%$NCOLORS]]

#----------------------------------------------------------------------#
load_library extract
lib::SetInfoDef 1
#----------------------------------------------------------------------#

set plot IdVg_@plot@

load_file "$plot" -name iv($N)
puts "load_file = $plot"
   
create_variable -name absIds -dataset iv($N) -function "abs(<drain TotalCurrent:iv($N)>)"

set Vgs [get_variable_data "gate OuterVoltage" -dataset iv($N)]
set Ids [get_variable_data "absIds" -dataset iv($N)]

# Create 1D plot
if {[lsearch [list_plots] Plot_IV] == -1} {
	create_plot -1d -name Plot_IV
}
select_plots Plot_IV

#define _t1_  L=@L@um Vd=@VDRAIN@V Scattering=@Scattering@ Type=@Type@

#if "@Type@" == "nMOS"
# loop over Y axes. Y1 will be linear, Y2 will be log
foreach YaxisSet [list {Y log -show_legend} {Y2 linear -hide_legend}] {

  set Yaxis  [lindex $YaxisSet 0]
  set Yscale [lindex $YaxisSet 1]
  set Legend [lindex $YaxisSet 2]
    
  # Set y-axis atributes
  set_axis_prop -axis [string tolower $Yaxis] -type $Yscale -title "I(drain) \[A]" \
     -title_font_size 20 -label_font_size 15 -manual_padding -padding 125
     
  # Create plot
  set label "_t1_"
  create_curve -name IdVg_${Yscale}_($N) -dataset iv($N) -axisX "gate OuterVoltage"  -axis${Yaxis} "absIds" 
  set_curve_prop IdVg_${Yscale}_($N) -color $color -hide_markers -line_width 3  -line_style solid -label $label $Legend
    
};# end loop over linear and log scale
 
#elif "@Type@" == "pMOS"
# loop over Y axes. Y1 will be linear, Y2 will be log
foreach YaxisSet [list {Y linear -show_legend} {Y2 log -hide_legend}] {

  set Yaxis  [lindex $YaxisSet 0]
  set Yscale [lindex $YaxisSet 1]
  set Legend [lindex $YaxisSet 2]
    
  # Set y-axis atributes
  set_axis_prop -axis [string tolower $Yaxis] -type $Yscale -title "I(drain) \[A]" \
     -title_font_size 20 -label_font_size 15 -manual_padding -padding 125
     
  # Create plot
  set label "_t1_"
  create_curve -name IdVg_${Yscale}_($N) -dataset iv($N) -axisX "gate OuterVoltage"  -axis${Yaxis} "absIds" 
  set_curve_prop IdVg_${Yscale}_($N) -color $color -hide_markers -line_width 3  -line_style solid -label $label $Legend
    
};# end loop over linear and log scale
#endif

# Set x-axis properties
set_axis_prop -axis x -title "V(gate) \[V\]" -title_font_size 20 -label_font_size 15
  
# Set title
##set title "Id-Vgs for @Material2D@"
##set_plot_prop -title $title -title_font_size 14

set_legend_prop -label_font_size 12 -label_font_att normal


#- Extraction
#----------------------------------------------------------------------#
echo "#########################################"
echo "Extracting parameters from Id-Vgs curve"
echo "#########################################"

#- Defining current level for Vti extraction
#----------------------------------------------------------------------#
set Io    @<10e-9/L>@ ; # [A/um]
puts  "Io: VT Current Level = $Io "
#if "@Type@" == "pMOS"
set Vo   -1.0e-4 
#else
set Vo    1.0e-4 
#endif

#if @< abs(VDRAIN)<0.1 >@

ext::ExtractVti -out Vti -name noprint -v $Vgs -i $Ids -io $Io -f %.3f
ext::RemoveDuplicates -out IV -x $Vgs -y $Ids
ext::ExtractValue -out ty -x $IV(X) -y $IV(Y) -xo $Vo
puts "ty = $ty"
if { $ty != "x" } {
 ext::ExtractSS        out= SSlin  name= noprint  v= $IV(X)  i= $IV(Y)  vo= $Vo  f= %.1f
}
ext::ExtractExtremum -out Idmax -name noprint -x $Vgs -y $Ids -extremum max -f %.1f


if { $Vti != "x" } {
 puts "DOE: VTL [format %.3f $Vti]"
 echo "VTL (Vg at Io= [format %.3e $Io] A) is [format %.3f $Vti] V"
}
if { $ty != "x" } {
 if { $SSlin != "x" } {
  puts "DOE: SSlin [format %.1f $SSlin]"
  echo "SSlin is [format %.1f $SSlin] V"
 }
}
if { $Idmax != "x" } {
 puts "DOE: IDLIN_uA [format %.1f [expr ($Idmax * 1e6)]]"
 echo "Max IdLin is [format %.3e $Idmax] uA"
}

#else

ext::ExtractVti -out Vti -name noprint -v $Vgs -i $Ids -io $Io -f %.3f
ext::RemoveDuplicates -out IV -x $Vgs -y $Ids
ext::ExtractValue -out ty -x $IV(X) -y $IV(Y) -xo $Vo
puts "ty = $ty"
if { $ty != "x" } {
 ext::ExtractSS        out= SSsat  name= noprint  v= $IV(X)  i= $IV(Y)  vo= $Vo  f= %.1f
}
ext::ExtractExtremum -out Idmax -name noprint -x $Vgs -y $Ids -extremum max          -f %.1f
ext::ExtractIoff     -out Ioff  -name noprint -v $Vgs -i $Ids -vo $Vo       -log10 0 -f %.2e

if { $Vti != "x" } {
 puts "DOE: VTS [format %.3f $Vti]"
 echo "VTS (Vg at Io= [format %.3e $Io] A) is [format %.3f $Vti] V"
}
if { $ty != "x" } {
 if { $SSsat != "x" } {
  puts "DOE: SSsat [format %.1f $SSsat]"
  echo "SSsat is [format %.1f $SSsat] V"
 }
}
if { $Idmax != "x" } {
 puts "DOE: IDSAT_uA [format %.1f [expr ($Idmax * 1e6)]]"
 echo "Max IdSat is [format %.3e $Idmax] uA"
}
if { $Ioff != "x" } {
 puts "DOE: IOFF_pA [format %.2e [expr ($Ioff * 1e12)]]"
 puts "Ioff is [format %.3e $Ioff] pA"
}


#if _OffLevel_
ext::ExtractVti       out= Vti1pA    name= "noprint"       v= $Vgs i= $Ids  io= 1e-12           f= %.3f
ext::ExtractVti       out= Vti10pA   name= "noprint"       v= $Vgs i= $Ids  io= 10e-12          f= %.3f
if { $Vti1pA != "x" } {
puts "DOE: WF1pA  [format %.3f [expr (@WF@ - $Vti1pA)]]"
}
if { $Vti10pA != "x" } {
puts "DOE: WF10pA  [format %.3f [expr (@WF@ - $Vti10pA)]]"
}
#endif

#endif

##################################################

##exit
