#setdep @node|Mystic_Uniform_Enigma@

#if "@midpoint@" == "True"

# Mystic plot node labels
set gate_label v@gate_con@
set drain_label v@drain_con@
set source_label i@drain_con@
set cap_label c(@acgate_con@,@acgate_con@)

set DEVNAME n@node|Mystic_Uniform_Enigma@

### load garand target
#if "@Type@" == "nMOS"
set vdlin @Vdd_lin@
set vdd @Vdd_nom@
set zero 0.0
set idvds {0.4 0.6 0.8}
#else
set vdlin @Vdd_lin@
set vdd @Vdd_nom@
set zero 0.0
set idvds {-0.4 -0.6 -0.8}
#endif

set idvgld idvg-hd-drain$vdlin\_gate$zero\_source$zero\_substrate$zero
set idvghd idvg-hd-drain$vdd\_gate$zero\_source$zero\_substrate$zero

load_file @pwd@/@nodedir|Mystic_Uniform_Enigma@/$DEVNAME-$idvgld.plt
load_file @pwd@/@nodedir|Mystic_Uniform_Enigma@/$DEVNAME-$idvghd.plt

#################### IdVg plot ###################


set PLOTNAME IdVg
create_plot -1d -name $PLOTNAME
set_plot_prop -plot $PLOTNAME -hide_title
create_curve -name ld_target_log -plot $PLOTNAME -dataset $DEVNAME-$idvgld -axisX "{$gate_label OuterVoltage}" -axisY "{$source_label TotalCurrent}"
set_curve_prop ld_target_log -label ld_target_log -color black -show_markers -markers_size 9 -markers_type circle -line_width 3 -hide_line

create_curve -name hd_target_log -plot $PLOTNAME -dataset $DEVNAME-$idvghd -axisX "{$gate_label OuterVoltage}" -axisY "{$source_label TotalCurrent}"
set_curve_prop hd_target_log -label hd_target_log -color black -show_markers -markers_size 9 -markers_type circle -line_width 3 -hide_line

create_curve -name ld_fit_log -plot $PLOTNAME -dataset $DEVNAME-$idvgld -axisX "{$gate_label OuterVoltage}" -axisY "{$source_label TotalCurrent fitted}"
set_curve_prop ld_fit_log -label ld_fit_log -color red -line_style dash -line_width 3

create_curve -name hd_fit_log -plot $PLOTNAME -dataset $DEVNAME-$idvghd -axisX "{$gate_label OuterVoltage}" -axisY "{$source_label TotalCurrent fitted}"
set_curve_prop hd_fit_log -label hd_fit_log -color red -line_style dash -line_width 3


set_axis_prop -plot $PLOTNAME -axis y -type log 
set_axis_prop -plot $PLOTNAME -axis x -title Vg -title_font_family "Arial" -title_font_size 24 -label_font_size 22 -manual_spacing -spacing 0.1
set_axis_prop -plot $PLOTNAME -axis y -title log(Id(A)) -title_font_family "Arial" -title_font_size 24 -label_font_size 22 

create_curve -name ld_target -plot $PLOTNAME -dataset $DEVNAME-$idvgld -axisX "{$gate_label OuterVoltage}" -axisY2 "{$source_label TotalCurrent}"
set_curve_prop ld_target -label ld_target -color black -show_markers -markers_size 9 -markers_type circle -line_width 3 -hide_legend -hide_line

create_curve -name hd_target -plot $PLOTNAME -dataset $DEVNAME-$idvghd -axisX "{$gate_label OuterVoltage}" -axisY2 "{$source_label TotalCurrent}"
set_curve_prop hd_target -label hd_target -color black -show_markers -markers_size 9 -markers_type circle -line_width 3 -hide_legend -hide_line

create_curve -name ld_fit -plot $PLOTNAME -dataset $DEVNAME-$idvgld -axisX "{$gate_label OuterVoltage}" -axisY2 "{$source_label TotalCurrent fitted}"
set_curve_prop ld_fit -label ld_fit -color red -line_style dash -line_width 3 -hide_legend

create_curve -name hd_fit -plot $PLOTNAME -dataset $DEVNAME-$idvghd -axisX "{$gate_label OuterVoltage}" -axisY2 "{$source_label TotalCurrent fitted}"
set_curve_prop hd_fit -label hd_fit -color red -line_style dash -line_width 3 -hide_legend

set_axis_prop -plot $PLOTNAME -axis y2 -title Id(A)

#################### IdVd plot ###################
set col_list {black red green blue purple}
set PLOTNAME IdVd

create_plot -1d -name $PLOTNAME
set_plot_prop -plot $PLOTNAME -hide_title
foreach vg $idvds {
    set idvd idvd-hd-drain$zero\_gate$vg\_source$zero\_substrate$zero

    load_file @pwd@/@nodedir|Mystic_Uniform_Enigma@/$DEVNAME-$idvd.plt

    create_curve -name vg_target_$vg -plot $PLOTNAME -dataset $DEVNAME-$idvd -axisX "{$drain_label OuterVoltage}" -axisY "{$source_label TotalCurrent}"
    set_curve_prop vg_target_$vg -label vg_target_$vg -color black -show_markers -markers_size 9 -markers_type circle -line_width 3 -hide_line
    create_curve -name vg_fit_$vg -plot $PLOTNAME -dataset $DEVNAME-$idvd -axisX "{$drain_label OuterVoltage}" -axisY "{$source_label TotalCurrent fitted}"
    set_curve_prop vg_fit_$vg -label vg_fit_$vg -color red -line_style dash -line_width 3

    incr i
      
  }

set_axis_prop -plot $PLOTNAME -axis x -title Vd -title_font_family "Arial" -title_font_size 24 -label_font_size 22 -manual_spacing -spacing 0.1
set_axis_prop -plot $PLOTNAME -axis y -title Id -title_font_family "Arial" -title_font_size 24 -label_font_size 22 
set_legend_prop -plot $PLOTNAME -label_font_size 14 -color_fg white

#################### CggVg plot ###################
set cvld cv-drain$zero\_gate$zero\_source$zero\_substrate$zero
load_file @pwd@/@nodedir|Mystic_Uniform_Enigma@/$DEVNAME-$cvld.plt
set PLOTNAME CggVg

create_plot -1d -name $PLOTNAME
set_plot_prop -plot $PLOTNAME -hide_title
create_curve -name CggVg_target -plot $PLOTNAME -dataset $DEVNAME-$cvld -axisX "{$gate_label OuterVoltage}" -axisY "{$cap_label Capacitance}"
set_curve_prop  CggVg_target -label  CggVg_target_vd0 -color black -show_markers -markers_size 9 -markers_type circle -line_width 3 -hide_line
create_curve -name CggVg_fit -plot $PLOTNAME -dataset $DEVNAME-$cvld -axisX "{$gate_label OuterVoltage}" -axisY "{$cap_label Capacitance fitted}"
set_curve_prop CggVg_fit -label CggVg_fit -color red -line_style dash -line_width 3

set_axis_prop -plot $PLOTNAME -axis x -title Vg -title_font_family "Arial" -title_font_size 24 -label_font_size 22 -manual_spacing -spacing 0.1
set_axis_prop -plot $PLOTNAME -axis y -title Cgg -min 0 -min_fixed -title_font_family "Arial" -title_font_size 24 -label_font_size 22
set_legend_prop -plot $PLOTNAME -label_font_size 14 -color_fg white

#windows_style -style max

#else
#noexec
#endif
