set WB_viewer(graphic,files)	"*.\{png,jpg,gif,jpeg,tif\}"
set WB_viewer(graphic,label)	"Graphic"
set WB_viewer(graphic,nbfiles) 	10
set WB_viewer(graphic,cmd_line) @files@
set WB_viewer(graphic,exec_dir) @pwd@
set WB_binaries(viewer,graphic) eog
lappend WB_viewer(all) graphic
