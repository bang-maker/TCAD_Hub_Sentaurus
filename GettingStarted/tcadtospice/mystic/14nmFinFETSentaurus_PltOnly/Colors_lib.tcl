proc hsvToRgb {h s v} {
	set Hi [expr { int( double($h) / 60 ) % 6 }]
	set f [expr { double($h) / 60 - $Hi }]
	set s [expr { double($s)/255 }]
	set v [expr { double($v)/255 }]
	set p [expr { double($v) * (1 - $s) }]
	set q [expr { double($v) * (1 - $f * $s) }]
	set t [expr { double($v) * (1 - (1 - $f) * $s) }]
	switch -- $Hi {
		0 {
			set r $v
			set g $t
			set b $p
		}
		1 {
			set r $q
			set g $v
			set b $p
		}
		2 {
			set r $p
			set g $v
			set b $t
		}
		3 {
			set r $p
			set g $q
			set b $v
		}
		4 {
			set r $t
			set g $p
			set b $v
		}
		5 {
			set r $v
			set g $p
			set b $q
		}
		default {
			error "Wrong Hi value in hsvToRgb procedure! This should never happen!"
		}
	}
	set r [expr {round($r*255)}]
	set g [expr {round($g*255)}]
	set b [expr {round($b*255)}]
	return "#[format %02x $r][format %02x $g][format %02x $b]"
}

proc GetColors { NC Sat Lum } {
	set dC [expr 255/($NC-1)]
	set Colors [list]
	for {set i 0} {$i < $NC} {incr i} {
		set h [expr $i*$dC]
		lappend Colors [hsvToRgb $h $Sat $Lum]
		# puts "$i $h"
	}
	return $Colors
}

