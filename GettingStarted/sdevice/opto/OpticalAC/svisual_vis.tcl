#setdep @previous@

set N @node@
set LAMBDA @lambda@ 

set MYFILE "n@previous@_ac_des.plt"

set MYDATA [load_file $MYFILE]

if {[llength [list_plots]] == 0} {
  set MYPLOT [create_plot -1d]
  select_plots $MYPLOT
  
  set_plot_prop -hide_title -show_grid
  
  set_axis_prop -title_font_size 20  -label_font_size 16 

  set_axis_prop -axis x \
    -title {Frequency (GHz)} \
    -type log 

  set_axis_prop -axis y \
    -title {QE} 

  set_axis_prop -axis y2 \
    -title {10log<sub>10</sub>[QE] (dB)} \
    -spacing 1 \
    -manual_spacing    
  
  set_legend_prop -label_font_size 12 -location bottom_left
}

create_variable -name GHz \
  -dataset $MYDATA \
  -function 1e-9*<frequency:$MYDATA>

create_variable -name 10logQE \
  -dataset $MYDATA \
  -function 10.0*log10(<photo_a(np):$MYDATA>)

set MYCURVE1($N) [create_curve -dataset $MYDATA -axisX GHz -axisY  photo_a(np) ]
set MYCURVE2($N) [create_curve -dataset $MYDATA -axisX GHz -axisY2 10logQE     ]
   
set freq3db [probe_curve $MYCURVE2($N) -valueY2 -3.0 ]
set qe3db   [probe_curve $MYCURVE1($N) -valueX  $freq3db]

puts [format "DOE: 3dB_freq_GHz %.3f" $freq3db]
puts [format "DOE: 3dB_qe %.3f" $qe3db]


if {[info exists runVisualizerNodesTogether]} { 
  
  set_curve_prop $MYCURVE1($N) \
    -line_width 3 \
    -label "QE $legend" \
    -color $color

  set_curve_prop $MYCURVE2($N) \
    -line_width 3 \
    -line_style dash \
    -label "10log(QE) $legend" \
    -color $color
}
