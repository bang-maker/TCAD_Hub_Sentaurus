#setdep @previous@


# write plt file
output_dir_root = garand.workdir

#####################################################################
### the "dbi" object is injected into the environment by gpythonsh   ###
### we can use the project name to pick up all relevant data      ###
#####################################################################

data = Data.from_db(project="@node|VT_simulation@", ivar="v@gate_con@",
                    dvar="i@drain_con@")[0]

if data.metadata["TargetFound"] == "True":
    VT = data.metadata["TargetVoltage"]
else:
    VT = np.nan

print(f"DOE: VT_sim {VT:.5}")
