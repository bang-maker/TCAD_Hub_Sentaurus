
lappend WB_tool(file_types) qtcmd0
set WB_tool(qtcmd0,ext) tcl0
lappend WB_tool(file_types) script

lappend WB_tool(file_types) qtcmd
set WB_tool(qtcmd,ext) tcl
lappend WB_tool(file_types) script


# tool: SdeviceQTX
set WB_tool(SdeviceQTX,category) device
set WB_tool(SdeviceQTX,visual_category) device
set WB_tool(SdeviceQTX,acronym) qtx
set WB_tool(SdeviceQTX,after) [list START cshell]
set WB_tool(SdeviceQTX,cmd_line) @commands@
set WB_binaries(tool,SdeviceQTX) "sdevice"
set WB_manual(SdeviceQTX) $app_data(manual_dir)/SdeviceQTX.pdf
#-set Icon(SdeviceQTX) $app_data(icon_dir)/sdqtx.gif
set Icon(SdeviceQTX) [file join [gproject::Wdir] sdqtx.gif]

# generates QTX files
set WB_tool(SdeviceQTX,prologue) { ::generate_qtx_files @node@ @nStack@ @preNLregionName@ }

set WB_tool(SdeviceQTX,input) [list commands qtcmd0 parameter grid doping edit tdr epitcl pref] ; # removed qtcmd
set WB_tool(SdeviceQTX,input,pref,label)  "Preferences..."
set WB_tool(SdeviceQTX,input,pref,editor)  pref
set WB_tool(SdeviceQTX,input,pref,file)   @tool_label@_des.prf
set WB_tool(SdeviceQTX,input,commands,oldfile)  des.cmd
set WB_tool(SdeviceQTX,input,commands,file)  @tool_label@_des.cmd
set WB_tool(SdeviceQTX,input,commands,newfile)  @tool_label@_des.cmd
set WB_tool(SdeviceQTX,input,commands,label)  "SDevice Commands..."
set WB_tool(SdeviceQTX,input,commands,editor)  text
set WB_tool(SdeviceQTX,input,qtcmd0,oldfile)  0_qtx.cmd
set WB_tool(SdeviceQTX,input,qtcmd0,file)  @tool_label@_0_qtx.cmd
set WB_tool(SdeviceQTX,input,qtcmd0,newfile)  @tool_label@_0_qtx.cmd
set WB_tool(SdeviceQTX,input,qtcmd0,label)  "QTX Body Commands..."
set WB_tool(SdeviceQTX,input,qtcmd0,parametrized)  1
set WB_tool(SdeviceQTX,input,qtcmd0,editor)  text
set WB_tool(SdeviceQTX,input,qtcmd,oldfile)  qtx.cmd
set WB_tool(SdeviceQTX,input,qtcmd,file)  @tool_label@_qtx.cmd
set WB_tool(SdeviceQTX,input,qtcmd,newfile)  @tool_label@_qtx.cmd
# set WB_tool(SdeviceQTX,input,qtcmd,label)  "QTX File Generation..."
# set WB_tool(SdeviceQTX,input,qtcmd,parametrized)  1
# set WB_tool(SdeviceQTX,input,qtcmd,editor)  text
set WB_tool(SdeviceQTX,input,parameter,files)  sdevice_*.par
set WB_tool(SdeviceQTX,input,parameter,file)  .par
set WB_tool(SdeviceQTX,input,parameter,newfile)  sdevice.par
set WB_tool(SdeviceQTX,input,parameter,label)  "Parameter..."
set WB_tool(SdeviceQTX,input,parameter,parametrized)  1
set WB_tool(SdeviceQTX,input,parameter,preamble)  sdevice_par_Si
set WB_tool(SdeviceQTX,input,parameter,editor)  text
set WB_tool(SdeviceQTX,input,edit,label)  "Include Parameter File..."
set WB_tool(SdeviceQTX,input,edit,cmd)  G_ToolInput::GetDatex
set WB_tool(SdeviceQTX,output) [list log plot acplot optfarfield modegain \
dat optpattern save tdrdat]
set WB_tool(SdeviceQTX,output,acplot,file)  n@node@_ac_des.plt
set WB_tool(SdeviceQTX,output,plot,file)  n@node@_des.plt
set WB_tool(SdeviceQTX,output,optfarfield,file)  n@node@_ff_des.plt
set WB_tool(SdeviceQTX,output,modegain,file)  n@node@_gain_des.plt
set WB_tool(SdeviceQTX,output,optpattern,file)  n@node@_op_des.dat
set WB_tool(SdeviceQTX,output,files) "n@node@_* pp@node@_* *_n@node@_*"
set WB_tool(SdeviceQTX,epilogue) { extract_vars "$wdir" @stdout@ @node@ }
## parallelization settings
set WB_tool(SdeviceQTX,parallel,activate)      1       ; # activate tool parallelization settings
set WB_tool(SdeviceQTX,parallel,mt)            1       ; # supports shared memory parallelization
set WB_tool(SdeviceQTX,parallel,mpi)           0       ; # supports MPI parallelization
set WB_tool(SdeviceQTX,parallel,gpu)           0       ; # no support for GPU parallelization
set WB_tool(SdeviceQTX,parallel,autodetect)    1       ; # supports auto-detection of threads
set WB_tool(SdeviceQTX,parallel,processes)     1       ; # default (MPI): number of processes to request
set WB_tool(SdeviceQTX,parallel,distribution)  lowest  ; # default (MPI): launch less processes on the same host
                                          # highest ; # default (MPI): launch more processes on the same host
set WB_tool(SdeviceQTX,parallel,mpihosts)      ""      ; # default: user defined list of hosts for MPI processes
set WB_tool(SdeviceQTX,parallel,threads)       1       ; # default: number of threads to request
set WB_tool(SdeviceQTX,parallel,mode)          user    ; # default: no auto-detection, takes (tool,parallel,threads)
                                          # tool    ; # default: SWB detects number of threads to request
set WB_tool(SdeviceQTX,parallel,gpus)          0       ; # default (GPU): how many GPUs to request
set WB_tool(SdeviceQTX,parallel,memory)        0       ; # default: allocates memory according to queue policy,
set WB_tool(SdeviceQTX,LSF,resource)           ""      ; # default: additional LSF resources to request
set WB_tool(SdeviceQTX,SGE,resource)           ""      ; # default: additional SGE resources to request
set WB_tool(SdeviceQTX,TM,resource)            ""      ; # default: additional Torque resources to request
set WB_tool(SdeviceQTX,RTDA,resource)          ""      ; # default: additional RTDA resources to request
##
lappend WB_tool(all) SdeviceQTX

# this function contains the logic of SdeviceSBTE_qtx.cmd
proc ::generate_qtx_files { node nStack preNLregionName} {
    set ifile    "pp${node}_qtx.tcl0"
          
    for {set i 0} {$i < $nStack} {incr i} {
        set ofile "pp${node}_qtx_${i}.tcl"
        set fp [open $ofile "w"]
          
        puts $fp "set slicedChannelRegions \[list ${preNLregionName}_${i}\] "
        puts $fp "set slicedChannelName channel${i} "
        puts $fp "set file_prefix n${node}_\$slicedChannelName "
        puts $fp " "
        set fpr [open $ifile "r"]
        while { [gets $fpr NewLine] >= 0 } {
            puts $fp $NewLine
        }
        close $fpr
        puts $fp " "
        puts -nonewline $fp "ConnectBTEToMasterProcess "
        puts -nonewline $fp "connectionName=slices_n${node}_${i} "
        puts $fp            "slicedChannel=\$slicedChannelName \\"
        puts -nonewline $fp "             virtualContacts=\[list source drain\] "
        puts $fp            "outputFunctionName=output "

        close $fp
    }

}
