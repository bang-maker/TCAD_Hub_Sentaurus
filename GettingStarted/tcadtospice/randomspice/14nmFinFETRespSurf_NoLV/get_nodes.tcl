global argc argv

if { $argc != 2 } {
    puts "Usage: gtclsh get_nodes.tcl <PROJECT> <TOOL LABEL>"	
    exit 1
}

# SWB project path
set project [lindex $argv 0]

# tool label
set toolLabel [lindex $argv 1]

# scenario
set scen "all"

# -------- Initializing SWB application environment
Application_Init SWB "" 1.0 
Application_LoadToolDB

# -------- Loading project content
gproject::New $project
gproject::LoadToolDB
gproject::LoadTree
gproject::LoadVariables

# get the rightmost step of the given tool
set step [lindex [gtree::ToolSteps $toolLabel] end]
if { $step < 0 } {
    # no such tool in the flow
    return 
}

# -------- get nodes of the given tool
set nodes [gtree::AllStepNodes $scen $step]
puts $nodes


