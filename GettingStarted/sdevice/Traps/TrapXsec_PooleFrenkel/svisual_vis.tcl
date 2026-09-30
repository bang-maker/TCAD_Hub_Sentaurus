# inputs
    set pltfile ./n@previous@_des.plt   ;# input
    set xaxis "c1 OuterVoltage"   ;# input                
    set yaxis "c2 TotalCurrent"   ;# input
    set set_axes_titles 1
    set set_curve_prop 1
    set set_generic_options 1
    
    # load data, create plot and curve
    set mydataset [load_file $pltfile]	
    if {[lsearch [list_plots] Plot_1] == -1} {
       set myplot [create_plot -1d]
    }
    set mycurve [create_curve -plot $myplot -dataset $mydataset -axisX "$xaxis" -axisY "$yaxis"]
    
    if $set_axes_titles {
       set xaxisT "Vg \[V\]"   ;# input
       set yaxisT "Id \[A/um\]"   ;# input
       set_axis_prop -plot $myplot -axis y -title "$yaxisT" -type log
       set_axis_prop -plot $myplot -axis x -title "$xaxisT"

    }
    
    if $set_curve_prop {

       #if "@Xsec_model@" == "default"
       set curve_label "@Xsec_model@"   ;# input
       #elif "@Xsec_model@" == "PooleFrenkel" && "@par@" == "-"
       set curve_label "@Xsec_model@"   ;# input
       #elif "@Xsec_model@" == "PooleFrenkel" && "@par@" != "-"
       set curve_label "@Xsec_model@, @par@=@par_val@"   ;# input
       #endif
       set_curve_prop -plot $myplot $mycurve -label "$curve_label"
       set_curve_prop -plot $myplot $mycurve -line_width 3
    }
    
    if $set_generic_options {
       set sizes 20
       set sizes2 16
       set myplot $myplot
       ## axis properties: axis title, axis font 
       set_axis_prop -plot $myplot -axis x -title_font_family arial -title_font_size $sizes -title_font_color #000000 -title_font_att normal
       set_axis_prop -plot $myplot -axis x -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att normal
    
       set_axis_prop -plot $myplot -axis y -title_font_family arial -title_font_size $sizes -title_font_color #000000 -title_font_att normal
       set_axis_prop -plot $myplot -axis y -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att normal
    
       set_axis_prop -plot $myplot -axis y2 -title_font_family arial -title_font_size $sizes -title_font_color #000000 -title_font_att normal
       set_axis_prop -plot $myplot -axis y2 -label_font_family arial -label_font_size $sizes -label_font_color #000000 -label_font_att normal
    
       ## legend properties
       set_legend_prop -plot $myplot -label_font_family arial -label_font_size $sizes2 -label_font_color #000000 -label_font_att bold
    }
