# Plot Id vs. Vg 

#setdep @node|SBTE@

# Set _PNG_ to 1 to export plots in png, tif and eps formats
#define _PNG_ 0

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
#set IOFF_nA      x

#if _OffLevel_
#set WF50pA      0.0
#set WF100pA     0.0
#set WF1nA       0.0
#set WF10nA      0.0
#set WF100nA     0.0
#endif

#----------------------------------------------------------------------#
lib::SetInfoDef 1
#----------------------------------------------------------------------#

set Fpitch        0.016

# Load .plt files
load_file "n@node|SBTE@_IdVg.plt"   -name iv

set Vgs [get_variable_data "V(gate)" -dataset iv]
set Ids [get_variable_data "I(drain)" -dataset iv]
ext::AbsList out= absIds x= $Ids ;# Compute absolute value of drain currents
set Id_um [list ]
foreach i $absIds {
 set ti [expr ($i / $Fpitch)]
 lappend Id_um $ti
}
#-puts $absIds
#-puts $Ids_um
create_variable -name absId -dataset iv -values $absIds
create_variable -name Id_um -dataset iv -values $Id_um

#-puts $Vgs
#-puts $Ids

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


#if _OffLevel_
ext::ExtractVti out= Vti50pA  name= "noprint" v= $Vgs i= $Id_um io= [expr (50e-12 * 1)]  f= %.3f
ext::ExtractVti out= Vti100pA name= "noprint" v= $Vgs i= $Id_um io= [expr (100e-12 * 1)] f= %.3f
ext::ExtractVti out= Vti1nA   name= "noprint" v= $Vgs i= $Id_um io= [expr (1e-9 * 1)]    f= %.3f
ext::ExtractVti out= Vti10nA  name= "noprint" v= $Vgs i= $Id_um io= [expr (10e-9 * 1)]   f= %.3f
ext::ExtractVti out= Vti100nA name= "noprint" v= $Vgs i= $Id_um io= [expr (100e-9 * 1)]  f= %.3f
if { $Vti50pA != "x" } {
puts "DOE: WF50pA  [format %.3f [expr (@WF@ - $Vti50pA)]]"
}
if { $Vti100pA != "x" } {
puts "DOE: WF100pA  [format %.3f [expr (@WF@ - $Vti100pA)]]"
}
if { $Vti1nA != "x" } {
puts "DOE: WF1nA   [format %.3f [expr (@WF@ - $Vti1nA)]]"
}
if { $Vti10nA != "x" } {
puts "DOE: WF10nA   [format %.3f [expr (@WF@ - $Vti10nA)]]"
}
if { $Vti100nA != "x" } {
puts "DOE: WF100nA [format %.3f [expr (@WF@ - $Vti100nA)]]"
}
#endif


#endif

##################################################


# Determine carrier density to consider
#if [string compare @Type@ nMOS]==0
  set carrier eDensity
#else
  set carrier hDensity
#endif

#if "@Shape@" == "Trapezoid"
#define _t1_  W/H/L=@<0.5*(Wtop+Wbottom)>@nm/@H@nm/@L@nm
#elif "@Shape@" == "Circle"
#define _t1_  D/L=@D@nm/@L@nm
#endif

# Create 1D plot
create_plot -1d

#-create_variable -name absId -dataset iv -function -1*<I(drain):iv>

# loop over Y axes. Y1 will be linear, Y2 will be log
foreach YaxisSet [list {Y log} {Y2 linear}] {

  set Yaxis  [lindex $YaxisSet 0]
  set Yscale [lindex $YaxisSet 1]
   
  # Create plot
  set label "I(drain)"
  create_curve -name sBand_$Yscale -dataset iv -axisX "V(gate)"  -axis${Yaxis} "Id_um" 
  set_curve_prop sBand_$Yscale -label $label -color black -show_markers -markers_size 7
  ##set_curve_prop sBand_$Yscale -hide_line 
  
  # Set y-axis atributes
  set_axis_prop -axis [string tolower $Yaxis] -type $Yscale -title "I(drain) \[A/<greek>m</greek>m\]" \
     -title_font_size 25 -label_font_size 20 -label_format scientific  -label_precision 1
  
};# end loop over linear and log scale
 

# Set x-axis properties
set_axis_prop -axis x -title "V(gate) \[V\]" -title_font_size 25 -label_font_size 20  
  
# Set title
set title "Si @Shape@ GAA-NW _t1_, Vd=@VDRAIN@V."
set_plot_prop -title $title -title_font_size 20 -title_font_att bold

set_window_full -on
set_legend_prop -label_font_size 14 -label_font_att normal

#if _PNG_
export_view zFig_n@node@_IdVg.png -format png -overwrite
#-export_view zFig_n@node@_IdVg.eps -format eps -overwrite -resolution 1000x1000
#endif

