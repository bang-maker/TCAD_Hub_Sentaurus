################  Add Circuit file to SDevice input list #########

set WB_tool(file_types) [list circuit]
set WB_tool(circuit,ext) scf
set WB_tool(sdevice,input) [list commands parameter config grid doping edit tdr circuit]

set WB_tool(sdevice,input,circuit,file)  circuit.scf
set WB_tool(sdevice,input,circuit,label)  "Circuit..."
set WB_tool(sdevice,input,circuit,parametrized)  1
set WB_tool(sdevice,input,circuit,editor)  text

set WB_tool(sdevice,prologue) { catch {os_mkdir_rel n@node@ @nodedirpath@}; \
  os_cp @nodedirpath@/pp@node@_des.scf @nodedirpath@/n@node@/pp@node@_des.scf}


