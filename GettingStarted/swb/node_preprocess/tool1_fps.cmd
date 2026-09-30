#set VAR1 @node@

#seth result1 -1

set dummy {
@node@
@node:2@

@node:first@
@node:last@

@node:+2@
#if "@node@" == "@node:last@"
# last node, no next experiment exists. 
# do not execute this node
#noexec
#else
@node:+1@
#endif

@node:index@
@node:max@

@node|1@
@node|+1@

@node|tool1@
@node|tool2@

@node:all@
@node|tool1:all@

@node|1:all@
@node|tool2:all@

@[lsort -unique "@node|1:all@" ]@

@tdrboundary/o@
}

set mynode [expr 10*@node@]
puts "DOE: result1 $mynode"
# puts [format "DOE: result1b %.2f" $pi]