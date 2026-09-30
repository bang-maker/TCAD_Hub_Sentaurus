#setdep @previous@


load_file n@previous@_/n@previous@_idvg_stage_ld_0.plt
create_plot -1d -name Plot_1 
select_plots Plot_1

create_curve -plot Plot_1 -dataset n@previous@_idvg_stage_ld_0 -axisX vgate -axisY idrain
set_curve_prop -plot Plot_1 {Curve_1} -line_width 3


load_file n@previous@_/n@previous@_idvg_stage_hd_0.plt
select_plots Plot_1

create_curve -plot Plot_1 -dataset n@previous@_idvg_stage_hd_0 -axisX vgate -axisY idrain
set_curve_prop -plot Plot_1 {Curve_2} -line_width 3

