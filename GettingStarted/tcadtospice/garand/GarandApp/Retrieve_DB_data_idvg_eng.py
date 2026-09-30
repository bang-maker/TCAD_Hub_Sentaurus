#setdep @previous@


# write plt file
output_dir_root   = garand.workdir
drain_con="@drain_con@"
drain_bias_filter=f"bias__{drain_con}"
#if "@Type@" == "pMOS"
f=-1
#else if "@Type@" == "nMOS"
f=1
#endif
ivt=f*@VT_current_criterion@

#####################################################################
### the "dbi" object is injected into the environment by gpythonsh   ###
### we can use the project name to pick up all relevant data      ###
#####################################################################

# get data from DB
project_data_ld = Data.from_db(project="@node|IdVg@", ivar="v@gate_con@", dvar="i@drain_con@",**{drain_bias_filter:@Vdd_lin@})[0]
project_data_hd = Data.from_db(project="@node|IdVg@", ivar="v@gate_con@", dvar="i@drain_con@",**{drain_bias_filter:@Vdd_nom@})[0]


project_data_ld.write_plt(os.path.join(output_dir_root,\
               f"n@node@_idvg_stage_ld_0.plt"))

VT_extr  = project_data_ld.Vt(ic=ivt)   # Threshold voltage extracted from IdVg 

print(f"DOE: VT_extr {VT_extr:.5}")

project_data_hd.write_plt(os.path.join(output_dir_root,\
               f"n@node@_idvg_stage_hd_0.plt"))
