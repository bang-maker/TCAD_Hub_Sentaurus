#--------------------
#- $Id: //tcad/support/main/modules/inspect/my/mylog.tcl#4 $
#- helpers for opto tasks
#--------------------

package require Tcl 8.4

namespace eval mylog {
  variable version [regsub {.*#([0-9]+).*} {$Id: //tcad/support/main/modules/inspect/my/mylog.tcl#4 $} {\1}]
  variable mydebug 0
  variable RELEASE 13.0
  variable pi 3.1415926
    
  #----------------------------------------------------------------------#
  proc dbputs {str {dbglevel 1}} {
    # puts text if mydebug is true
    variable mydebug
    if { [ catch { set caller [lindex [info level -1] 0]}]} {
      set caller "main program"
    }
    if {$mydebug==1&&$mydebug>=$dbglevel} {
      puts "$str"
    } elseif {$mydebug>10 && $mydebug>=[expr $dbglevel-10]} {      
      set FID [open "mylog.log" a]
      puts $FID "$caller>$str"
      close $FID
    } elseif {$mydebug>=$dbglevel} {
      puts "$caller>$str"
    }
  }
  #------------------------------------------------------------
  # returns the byte position of 
  # if pos is not specified the search starts from the current position otherwise from pos
  proc find {FID fstr {pos -1}} {
    if {$pos >= 0} {seek $FID $pos}
    while {[gets $FID line] >= 0} {
      if {[regexp $fstr $line]} {
        return [tell $FID]
        break
      }
    }
    return -1
  }
  #------------------------------------------------------------
  # returns the line containing fstr
  # pos gives the starting position using seek
  # count returns the first count occurancies 
  proc grep {FID fstr {pos -1} {count 1}} {
    if {$pos >= 0} {seek $FID $pos}
    set c 0
    set res {}
    while {[gets $FID line] >= 0} {
      if {[regexp $fstr $line]} {
        lappend res $line
        incr c 
        if {$c >= $count} {break}
      }
    }
    if {$count == 1} {
      if {[llength $res] >= 1} {
        return [lindex $res 0]
      } 
    } elseif {$count > 1} {
      return $res
    }
    return ""
  }
  
  #------------------------------------------------------------
  # takes the line matching gstr and extracts the regular expression rstr
  proc extract {FID gstr rstr} {
    set line [grep $FID $gstr]
    dbputs "extract>line: \"$line\"" 9
    set res ""
    if {[string length $line] > 0} {
      regexp $rstr $line junk res
    }
    dbputs "extract>res: $res" 9
    return $res
  }
  
  #----------------------------------------------------------------------#
  proc getDoe { fin {doeNameList {}}} {
    set result {}
    if { [catch { set FID [open $fin r] } err] } {
      catch { close $FID }
      error $err
    }
    set doelist {}
    while {[gets $FID line] >= 0} {
      if { [regexp {^DOE\:[ \t]*([a-zA-Z0-9_]+)[ \t]*(.*)[ \t]*$} $line match name value] } {
        lappend doelist [list $name $value]
      }
    }
    dbputs "doelist: $doelist, len:[llength $doeNameList]" 5
    if {[llength $doeNameList]==0} {
      set result $doelist
    } else {
      foreach doeName $doeNameList {
        set doeName [string map {( {} ) {} _ {} - {}} $doeName]
        foreach doe $doelist {
          set name [lindex $doe 0]
          set name [string map {( {} ) {} _ {} - {}} $name]
          set value [lindex $doe 1]
          dbputs "name: $name doeName: $doeName" 5
          if {[string match "$doeName" "$name"]} {
            lappend result [list $name $value]
          };#endif
        };#end foreach doe
      };#end foreach doeName
    };#endif
    dbputs "result: $result" 5
    close $FID
    return $result
  }
    
  #----------------------------------------------------------------------#
  proc getProfileFromEmwLog { flog } {
    if { [catch { set FID [open $flog r] } err] } {
      catch { close $FID }
      error $err
    }
    array set r {}
    array set str {}
    set fields {wcTotal wcTimeStep wcPp wcSensor wcPlot wcExtractor wcGrid wcMaterial}
    foreach var $fields { set r($var) x }
    # emw
    set pos [find $FID {Profile \'emw\'}]
    #set pos [find $FID {^\s*all runs}]
    if {$pos >= 0} { 
      set r(wcTotal) [extract $FID {^\s*all runs} {([0-9eE\.\-\+]+)$}]
      set r(wcGrid) [extract $FID {grid_manager_init$} {([0-9eE\.\-\+]+)\s+grid_manager_init$}]
      set r(wcMaterial) [extract $FID {material_manager_init$} {([0-9eE\.\-\+]+)\s+material_manager_init$}]
      # fdtd timestepping
      set pos [find $FID {Profile \'fdtd_time_stepping\'}]
      if {$pos < 0} { puts "Warning: could not find time stepping data in profiling part of the log. Ensure you ran emw with --profile." }
      set fdtdtime [extract $FID {^\s*all runs} {([0-9eE\.\-\+]+)$}]
      # get all sensors/plots/extractors
      foreach v {wcPlot wcSensor wcExtractor} k {plot sensor extractor} {
        seek $FID $pos
        dbputs "v=$v k=$k" 9
        set r($v) 0
        while {[set line [grep $FID "^\\s*child.*$k\\w*\$"]] != ""} {
          dbputs "line=$line" 9
          set x [regsub ".+\\s+(\[0-9eE\\.\\-\\+\]+)\\s+$k\\w*\$" "$line" {\1}]
          dbputs "x=$x" 9
          set r($v) [expr $r($v)+$x]
          if {"$k" == "sensor"} {
            set sname [regsub ".+\\s+${k}_(\\w*)\$" "$line" {\1}]
            set r(${v}_$sname) $x
          }
        }
      }
      # timestepping fdtdtime - sensor-plot-extractor
      set r(wcTimeStep) [expr $fdtdtime-$r(wcSensor)-$r(wcPlot)-$r(wcExtractor)]
      set r(wcPp) [expr $r(wcGrid)+$r(wcMaterial)+$r(wcSensor)+$r(wcPlot)+$r(wcExtractor)]
    } else {
      puts "Warning: could not find profiling part in log. Ensure you ran emw with --profile." 
    }
    dbputs "result: [array get r]" 5
    return [array get r]
  }
  
  #----------------------------------------------------------------------#
  proc getRuntimeFromEmwLog { flog} {
    if { [catch { set FID [open $flog r] } err] } {
      catch { close $FID }
      error $err
    }
    array set r {}
    array set str {}
    foreach var {cells dt timeSteps nx ny nz cpml} {
      set r($var) 0
    }
    foreach var {totalTime totalCpuTime fdtdTime fdtdCpuTime GPU_type} {
      set r($var) 0
      set str($var) ""
    }
    while {[gets $FID line] >= 0} {
      regexp {^Grid size:.*=\s*([0-9]+)\s*cells} $line match r(cells)
      regexp {^Number of threads.*:\s*([0-9]+)\s*} $line match r(threads)
      regexp {^Time step set to\s*([0-9e\.\+\-]+)s} $line match r(dt)
      regexp {.*met\s+after\s*([0-9]+).*} $line match r(timeSteps)
      regexp {^Time\s+Stepper:\s+done:\s+([0-9]+)\s+steps} $line match r(timeSteps)
      regexp {Terminating\s+after\s*([0-9]+).*} $line match r(timeSteps)
      regexp {Wall clock time \(total\):\s*(.+)} $line match str(totalTime)
      regexp {Total CPU time \(total\):\s*(.+)} $line match str(totalCpuTime)
      regexp {Wall clock time \(time stepping loop\):\s*(.+)} $line match str(fdtdTime)
      regexp {Total CPU time \(time stepping loop\):\s*(.+)} $line match str(fdtdCpuTime)
      regexp {^Grid size:\s*([0-9]+)\s*x} $line match r(nx)
      regexp {^Grid size:.*x\s*([0-9]+)\s*x} $line match r(ny)
      regexp {^Grid size:.*x\s*([0-9]+)\s*=*} $line match r(nz)
      regexp {.*thickness.*=\s*([0-9]+)} $line match r(cpml)
      regexp {^Accelerator \(GPU\) device number .*\(([^)]*)} $line match r(GPU_type)
    }
    close $FID
    foreach var {totalTime totalCpuTime fdtdTime fdtdCpuTime} {
      dbputs "str($var): $str($var)" 5
      if {[string length $str($var)] > 0} {
        set h 0
        set m 0
        set s 0
        regexp {([0-9\.]+)h} $str($var) match h
        regexp {([0-9\.]+)min} $str($var) match m
        regexp {([0-9\.]+)s} $str($var) match s
        dbputs "$var: h: $h m: $m s: $s" 5
        set r($var) [expr 3600*$h+60*$m+$s]
      }
    }
    dbputs "result: [array get r]" 5
    return [array get r]
  }
}
  
package provide mylog $mylog::version
