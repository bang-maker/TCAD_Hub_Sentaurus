# Plot subband Ninv, Velocity, Energy, and Occupancy 

#setdep @node|SBTE@ 

# Set _PNG_ to 1 to export plots in png, tif and eps formats
#define _PNG_ 0

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

#if "@Type@" == "nMOS"
#-set sbList [list Delta1_0 Delta1_1 Delta2_0 Delta2_1 Delta3_0 Delta3_1]
set sbList {Delta1_0 Delta1_1 Delta3_0 Delta3_1}
set Colors   {black blue red cyan}
#define _inv_ 
 
#else
set sbList {Gamma_0 Gamma_2 Gamma_4 Gamma_6 Gamma_8}
set Colors   {black blue red cyan magenta}
#define _inv_ -inverted

#endif

load_file n@node|SBTE@_bte_CC.tdr -name cc_sbte

### Plot subband Energy
set pid p4
create_plot -1d -name ${pid}
select_plots ${pid}

foreach sb $sbList c $Colors {
create_curve -plot ${pid} -dataset cc_sbte -name c_e_${sb} \
             -axisX ChannelCoordinate -axisY ${sb}_SubbandEnergy

set_curve_prop -plot ${pid} c_e_${sb} -label ${sb}_Energy -color $c \
               -line_width 3 -line_style solid
}

# Set x-axis properties
set_axis_prop -plot ${pid} -axis x \
              -title "Channel direction \[<greek>m</greek>m\]" \
              -title_font_size 25 -title_font_att bold -label_font_size 20  

# Set y-axis properties              
set_axis_prop -plot ${pid} -axis y \
              -title "Energy \[eV\]" \
              -title_font_size 25 -title_font_att bold -label_font_size 20  

                             
# Set title
set title "@Shape@ - @Type@, Vg=@VGATE@V/Vd=@VDRAIN@V."
set_plot_prop -plot ${pid} -title $title \
              -title_font_size 30 -title_font_att bold

set_window_full -on
set_legend_prop -plot ${pid} -label_font_size 16 -label_font_att normal \
                -position {0.18 0.73}

#if _PNG_
export_view zFig_n@node@_CC_Sub_E.png -format png -overwrite
export_view zFig_n@node@_CC_Sub_E.tif -format tif -overwrite
export_view zFig_n@node@_CC_Sub_E.eps -format eps -overwrite
#endif





