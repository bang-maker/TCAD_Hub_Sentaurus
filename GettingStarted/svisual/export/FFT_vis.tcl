#--- load data; create signal vs time curve ------------------------------------
load_file transient.plt -name "ACdata"
create_plot -1d -name "FFT"
link_plots "FFT" -unlink
create_curve -name signal -plot "FFT" -dataset "ACdata" \
             -axisX "time" -axisY "gate InnerVoltage"
#-------------------------------------------------------------------------------

#--- extract time step and period from dataset                     -------------
#--- data for one period with 2^n equidistant data points required -------------
set tlist [get_variable_data "time"  -dataset "ACdata"]

set np    [llength $tlist]                     ;#number of data points
set t0    [lindex $tlist 0]                    ;#start time
set dt    [expr [lindex $tlist 1]-$t0]         ;#time step
set t1    [expr [lindex $tlist end]+$dt]       ;#end time of period

set tp    [expr $t1-$t0]                       ;#period duration
set fper  [expr 1.0/$tp]                       ;#period frequency
set fmax  [expr 1.0/$dt]                       ;#max representable frequency
set anorm [expr 1.0/double($np)]               ;#normalization 
#-------------------------------------------------------------------------------


#--- test for 2^n data points --------------------------------------------------
if  { [expr fmod(log($np)/log(2.0),1)] > 1e-16 } { 
      puts "number of data points not 2^n" ; exit 
}
#--- test datapoints equidistant? - tolerance can be adjusted ------------------
set tol [expr $dt*1e-12]
for { set it 1 } { $it < $np } { incr it } {
      set tp1 [lindex $tlist $it] ; set tp0 [lindex $tlist [expr $it-1]] 
      if { [expr abs($tp1-$tp0-$dt)] > $tol } {
      	   puts "data points are not equidistant"; exit
      }
}
#-------------------------------------------------------------------------------


# ----- perform FFT ------------------------------------------------------------
create_curve -name ffre  -plot "FFT" -function "fftre(<signal>)"
create_curve -name ffim  -plot "FFT" -function "fftim(<signal>)"
remove_curves "signal"
#-------------------------------------------------------------------------------

set_axis_prop -plot "FFT" -axis y -title "fourier coefficient"
set_axis_prop -plot "FFT" -axis x -title number
set_axis_prop -plot "FFT" -axis x -title_font_family arial -title_font_size 20 
set_axis_prop -plot "FFT" -axis y -title_font_family arial -title_font_size 20 

set_legend_prop -plot "FFT" -label_font_family arial -label_font_size 16
set_legend_prop -plot "FFT" -location top_right

set_plot_prop -plot "FFT" -hide_title

# ----- export FFT data for later use ------------------------------------------
export_curves {ffre ffim} -plot "FFT" -filename ./FFTdata.plx -format plx \
  -overwrite
#-------------------------------------------------------------------------------

#--- get spectral data ---------------------------------------------------------
set freqs  [get_curve_data ffre -plot "FFT" -axisX]
set fftr   [get_curve_data ffre -plot "FFT" -axisY]
set ffti   [get_curve_data ffim -plot "FFT" -axisY]
# remove_curves {ffre ffim}


#------------ normalize and reorder spectrum -----------------------------------
set frequency [list]
set RePart    [list]
set ImPart    [list]
set AbsPart   [list]
set nNyq      [expr $np/2.0]
foreach  freq $freqs ffr $fftr ffi $ffti {
 if { $freq > $nNyq } {	
  lappend frequency [expr $freq*$fper-$fmax]
  lappend RePart    [expr $ffr*$anorm]
  lappend ImPart    [expr $ffi*$anorm]
  lappend AbsPart   [expr $anorm*sqrt($ffr*$ffr + $ffi*$ffi)]
}}
foreach  freq $freqs ffr $fftr ffi $ffti {
 if { $freq <= $nNyq } {	
  lappend frequency [expr $freq*$fper]
  lappend RePart    [expr $ffr*$anorm]
  lappend ImPart    [expr $ffi*$anorm]
  lappend AbsPart   [expr $anorm*sqrt($ffr*$ffr + $ffi*$ffi)]
}}

create_variable -name "frequency" -dataset "FFTdata" -values $frequency
create_variable -name "real_part" -dataset "FFTdata" -values $RePart
create_variable -name "imag_part" -dataset "FFTdata" -values $ImPart
create_variable -name "magnitude" -dataset "FFTdata" -values $AbsPart

create_plot -1d -name "symFFT"
link_plots "symFFT" -unlink
create_curve -name absval   -plot "symFFT" -dataset "FFTdata" \
             -axisX "frequency" -axisY "magnitude"
create_curve -name realpart -plot "symFFT" -dataset "FFTdata" \
             -axisX "frequency" -axisY "real_part"
create_curve -name imagpart -plot "symFFT" -dataset "FFTdata" \
             -axisX "frequency" -axisY "imag_part"

set_axis_prop -plot "symFFT" -axis x -min   [expr -5.0*$fper] -min_fixed
set_axis_prop -plot "symFFT" -axis x -max   [expr +5.0*$fper] -max_fixed
set_axis_prop -plot "symFFT" -axis y -range [list -0.3 0.6]

set_axis_prop -plot "symFFT" -axis x -title "frequency \[Hz\]"
set_axis_prop -plot "symFFT" -axis y -title "spectral components \[V\]"
set_axis_prop -plot "symFFT" -axis x -title_font_size 20 
set_axis_prop -plot "symFFT" -axis y -title_font_size 20 

set_axis_prop -plot "symFFT" -axis x -manual_precision
set_axis_prop -plot "symFFT" -axis x -label_format scientific
set_axis_prop -plot "symFFT" -axis x -label_precision 0
set_axis_prop -plot "symFFT" -axis x -manual_spacing
set_axis_prop -plot "symFFT" -axis x -anchor 0 -spacing 5e+08

set_curve_prop -plot "symFFT" "imagpart" -label fftim
set_curve_prop -plot "symFFT" "realpart" -label fftre
set_curve_prop -plot "symFFT" "absval"   -label magnitude

set_curve_prop -plot "symFFT" "absval realpart imagpart" -show_markers
set_curve_prop -plot "symFFT" "realpart imagpart" -markers_type diamondf
set_curve_prop -plot "symFFT" "realpart imagpart" -markers_size 12
set_curve_prop -plot "symFFT" "realpart imagpart" -line_width 1
set_curve_prop -plot "symFFT" "absval" -markers_type circle
set_curve_prop -plot "symFFT" "absval" -markers_size 14
set_curve_prop -plot "symFFT" "absval" -line_width 2

set_legend_prop -plot "symFFT" -label_font_family arial -label_font_size 16 
set_legend_prop -plot "symFFT" -location top_left

set_plot_prop -plot "symFFT" -hide_title


#-------------------------------------------------------------------------------
#--- inverse FFT ---------------------------------------------------------------
#-------------------------------------------------------------------------------

#--- load fft data from file and create fft-plot -------------------------------
load_file ./FFTdata.plx -name "iFFTdata"
create_plot -1d -name "iFFT"
link_plots "iFFT" -unlink
create_curve -name ffre -plot "iFFT" -dataset "iFFTdata" \
             -axisX "ffre x" -axisY "ffre y"
create_curve -name ffim -plot "iFFT" -dataset "iFFTdata" \
             -axisX "ffim x" -axisY "ffim y"
                
# ----- perform inverse FFT ----------------------------------------------------
create_curve -name sim -plot "iFFT" -function "ifftre(<ffim>)/$np"
create_curve -name sre -plot "iFFT" -function "ifftim(<ffre>)"
set_curve_prop -plot "iFFT" "sim sre" -xScale [expr $tp/$np]
remove_curves "ffre ffim"

set_axis_prop -plot "iFFT" -axis x -title "time \[s\]"
set_axis_prop -plot "iFFT" -axis y -title "signal components"

set_axis_prop -plot "iFFT" -axis x -range [list 0 $tp]

set_axis_prop -plot "iFFT" -axis x -title_font_size 20
set_axis_prop -plot "iFFT" -axis y -title_font_size 20 

set_axis_prop -plot "iFFT" -axis x -manual_precision
set_axis_prop -plot "iFFT" -axis x -label_format scientific
set_axis_prop -plot "iFFT" -axis x -label_precision 0
set_axis_prop -plot "iFFT" -axis x -manual_spacing
set_axis_prop -plot "iFFT" -axis x -anchor 0 -spacing 5e-9

set_curve_prop  -plot "iFFT" "sre" -label ifftRe
set_curve_prop  -plot "iFFT" "sim" -label ifftIm
set_curve_prop  -plot "iFFT" "sre sim" -line_width 3

set_legend_prop -plot "iFFT" -label_font_size 16 
set_legend_prop -plot "iFFT" -location bottom_left

set_plot_prop  -plot "iFFT" -hide_title


windows_style -style max
select_plots "symFFT"
