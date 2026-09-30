#setdep @previous@


# write plt file
output_dir_root   = garand.workdir

#####################################################################
### the "dbi" object is injected into the environment by gpythonsh   ###
### we can use the project name to pick up all relevant data      ###
#####################################################################
idvd_data = Data.from_db(project="@node|IdVd@", ivar="v@drain_con@", dvar="i@drain_con@")

for d in idvd_data:
    gate_bias = d.metadata["bias"]["gate"]
    d.write_plt(os.path.join(output_dir_root,"n@node@_IdVd_Vg{0}.plt".format(gate_bias)))
