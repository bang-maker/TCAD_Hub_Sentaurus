#setdep @previous@

set disp_file [open n@node|-1@_disp.txt]
set max_disp [lindex [read $disp_file] 3]
puts "\n$max_disp\n"
puts "DOE: MaxDispZ $max_disp"
