# Plot band dispersion (E-k) 

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

load_file n@node|SBTE@_bte_SliceK.tdr -name Ek
create_plot -1d -name p1 -dataset Ek
select_plots p1

#if "@Type@" == "nMOS"
#-set EkidList [list Delta1_0 Delta1_1 Delta2_0 Delta2_1 Delta3_0 Delta3_1]
set EkidList {Delta1_0 Delta1_1 Delta3_0 Delta3_1}
set Colors   {blue blue red red}
set LSs      {solid dash solid dash}

#else
set EkidList {Gamma_0 Gamma_2 Gamma_4 Gamma_6 Gamma_8}
set Colors   {black blue red cyan magenta}
set LSs      {solid solid solid solid solid}

#endif

foreach Ekid $EkidList c $Colors ls $LSs {
 create_curve -plot p1 -dataset {Ek} -axisX k -axisY ${Ekid}_Dispersion \
              -name C_${Ekid}
        
 set_curve_prop -plot p1 C_${Ekid} -label ${Ekid} \
                -color $c -line_width 3 -line_style $ls              
}

# Set x-axis properties
set_axis_prop -axis x -title "k" -title_font_size 25 -title_font_att bold \
              -label_font_size 20 -min -0.25 -min_fixed -max 0.25 -max_fixed

# Set y-axis properties
set_axis_prop -axis y -title "Energy \[eV\]" -title_font_size 25 \
              -title_font_att bold -label_font_size 20 \
              -min -0.10 -min_fixed -max 0.50 -max_fixed 

#Set title
set_plot_prop -title "E-k dispersion - @Type@" -title_font_size 25 -title_font_att bold

set_window_full -on

set_legend_prop -label_font_size 20 -position {0.46 0.89}

#if _PNG_
export_view zFig_n@node@_Ek.png -format png -overwrite
export_view zFig_n@node@_Ek.tif -format tif -overwrite
export_view zFig_n@node@_Ek.eps -format eps -overwrite
#endif

