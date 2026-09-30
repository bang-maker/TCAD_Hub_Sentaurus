
#setdep @previous@

#if "@model@" == "NLM"
#noexec
#else

set n @previous@
set Type "@Type@"
set tbox @tbox@
set Nch 1e18

# Create and format frame for It-Vt if it does not yet exist
set pl [list_plots -dim 1]
if ![regexp {ItVt} $pl] {
	create_plot -1d -name ItVt

	set_axis_prop -axis x \
		-label_precision 1 -label_format fixed -label_font_size 20 \
		-title_font_size 24 -title_font_att bold -title "V<sub>g</sub> \[V\]"

		set_axis_prop -axis y -min 1e-09 -min_fixed \
		-label_precision 0 -label_format scientific -label_font_size 20 \
		-title_font_size 24 -title_font_att bold -title "Current Density \[A/cm<sup>2</sup>\]" \
		-type log

	set_legend_prop -label_font_size 20
}

# Load data
load_file n${n}_des.plt -name ds($n)

# Build It vs. Vt curve
create_curve -name ItVt($n) -dataset ds($n) -axisX {top OuterVoltage} -axisY {top TotalCurrent}
#if "@par@" != "-"
set_curve_prop ItVt($n) -line_width 3 -label "@model@ @par@ @par_val@"
#else
set_curve_prop ItVt($n) -line_width 3 -label "@model@ @case@"
#endif

#if "@case@" == "Aex10" || "@case@" == "Awx10"
zoom_plot -plot ItVt -window {1 1e-16 4.05 1e-4}
#else 
zoom_plot -plot ItVt -window {1 1e-16 4.05 1e-7}
#endif

#endif
