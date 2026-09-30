#setdep @previous@




#if (@VT_only@ == "True") 

load_file n@previous@_/n@previous@_VT_distribution.png
create_plot -dataset n@previous@_VT_distribution


#else   

create_plot -1d -name Plot_1  
for {set i 0} {$i < @ensemble_size@} {incr i} {
    load_file n@previous@_/n@previous@_variability_idvg_stage_${i}.plt
    select_plots Plot_1
    
    set curve_no [format "Curve_%d" [expr {$i+1}]]

    create_curve -plot Plot_1 -dataset n@previous@_variability_idvg_stage_${i} -axisX vgate -axisY idrain
    set_curve_prop -plot Plot_1 $curve_no -line_width 3
}


#endif



