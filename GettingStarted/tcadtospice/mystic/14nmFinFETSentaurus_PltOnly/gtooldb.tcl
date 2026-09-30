# tool: cshell_enigma
set WB_tool(cshell_enigma,category) utility
set WB_tool(cshell_enigma,visual_category) utility
set WB_tool(cshell_enigma,acronym) csh
set WB_tool(cshell_enigma,after) all
set WB_tool(cshell_enigma,cmd_line) @commands@
set WB_binaries(tool,cshell_enigma) /bin/csh
#set Icon(cshell_enigma) $app_data(icon_dir)/shell.gif
set wdir [gproject::Wdir]
set Icon(cshell_enigma) $wdir/GSS_FinFET_Templates/icons/enigma.gif
set WB_tool(cshell_enigma,input) [list commands pref]
#set WB_tool(cshell_enigma,input) [list commands mako pref]
set WB_tool(cshell_enigma,input,commands,label)  Commands...
set WB_tool(cshell_enigma,input,commands,editor)  text
#set WB_tool(cshell_enigma,input,mako,label)  Mako...
#set WB_tool(cshell_enigma,input,mako,file)  GSS_FinFET_Templates/templates/@tool_label@.py.mako
#set WB_tool(cshell_enigma,input,mako,editor)  text
set WB_tool(cshell_enigma,output) [list]
set WB_tool(cshell_enigma,epilogue) { extract_vars "$wdir" @stdout@ @node@; waiting "$wdir" @node@ @acronym@ }
set WB_tool(cshell_enigma,output,files) "n@node@_* pp@node@_*"
set option1 "skip ~/.chsrc"
set option2 "use ~/.chsrc"
set WB_tool(cshell_enigma,exec_mode) $option1 ; # (option1 | option2 )
set WB_tool(cshell_enigma,$option1,option)  "-f"
set WB_tool(cshell_enigma,$option2,option)  ""
set WB_tool(cshell_enigma,input,pref,file)  @tool_label@_csh.prf
set WB_tool(cshell_enigma,input,pref,label)  "Preferences..."
set WB_tool(cshell_enigma,input,pref,editor)  pref
lappend WB_tool(all) cshell_enigma
