# Plot subband Ninv, Velocity, Energy, and Occupancy 

#setdep @node|NEGF@ 

#----------------------------------------------------------------------#

set DATE [exec date]
set WORK [exec pwd]
puts " "
puts "Date      : $DATE "
puts "Directory : $WORK "
puts " "

#----------------------------------------------------------------------#
lib::SetInfoDef 1
#----------------------------------------------------------------------#

set i  @node:index@
set N  @node@

set LINESTYLE  [list solid dash dot dashdot dashdotdot]
set NLINESTYLE [llength $LINESTYLE]
set linestyle  [lindex  $LINESTYLE [expr $i%$NLINESTYLE]]

#if "@Type@" == "nMOS"
	set sbList {Delta1_0 Delta1_1 Delta3_0 Delta3_1}
	set Colors   {black blue red cyan}
#else
	set sbList {Gamma_0 Gamma_2 Gamma_4 Gamma_6 Gamma_8}
	set Colors   {black blue red cyan magenta}
#endif

load_file n@node|NEGF@_negf_CC.tdr -name cc_negf($N)

### Plot subband Energy
# Create 1D plot
if {[lsearch [list_plots] Plot_CC] == -1} {
	create_plot -1d -name Plot_CC
}
select_plots Plot_CC

foreach sb $sbList c $Colors {
set label "${sb}_SubbandEnergy - @Shape@ @Type@, Vg=@VGATE@V/Vd=@VDRAIN@V, Rc=@Rc@<greek>W</greek>, Scattering=@Scattering@, SelfHeating=@SelfHeating@, Szz=@Szz@"
create_curve -plot Plot_CC -dataset cc_negf($N) -name c_e_${sb}_${N} \
             -axisX ChannelCoordinate -axisY ${sb}_SubbandEnergy

set_curve_prop -plot Plot_CC c_e_${sb}_${N} -label $label -color $c \
               -line_width 3 -line_style $linestyle
}

# Set x-axis properties
set_axis_prop -plot Plot_CC -axis x -title "Channel direction \[<greek>m</greek>m\]" \
              -title_font_size 20 -label_font_size 15  

# Set y-axis properties              
set_axis_prop -plot Plot_CC -axis y -title "Energy \[eV\]" \
              -title_font_size 20 -label_font_size 15  

                             
# Set title
set title "Si GAA-NW - Subband Energy"
set_plot_prop -plot Plot_CC -title $title \
              -title_font_size 20 -title_font_att bold

set_legend_prop -plot Plot_CC -label_font_size 10 -label_font_att normal 






