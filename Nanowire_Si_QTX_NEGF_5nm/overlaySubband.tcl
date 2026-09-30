
# Setting up XY plot
select_plots Plot1d
create_curve -plot "Plot1d" -dataset cc($N) -axisX "ChannelCoordinate" -axisY "${sb}"

#Getting data to draw lines in 2D:
set valuesX [get_curve_data "Curve_1" -axisX]
set valuesY [get_curve_data "Curve_1" -axisY]

# Iterate over the X and Y values of the curve and create a line for each segment
select_plots ${pid}
set dataLength [llength $valuesX]
for { set i2 1 } { $i2 < $dataLength } { incr i2 } {
	set i1 [expr $i2 - 1]
	
	# Getting the pair of value for each segment of the curve
	set p1 "[lindex $valuesX $i1] [lindex $valuesY $i1]"
	set p2 "[lindex $valuesX $i2] [lindex $valuesY $i2]"
	
	# create a segment line with the values extracted before
	set line [draw_line  -p1 $p1 -p2 $p2 -plot ${pid}]
	
	# coloring each line with red color
	set_line_prop $line -line_color "black"
}