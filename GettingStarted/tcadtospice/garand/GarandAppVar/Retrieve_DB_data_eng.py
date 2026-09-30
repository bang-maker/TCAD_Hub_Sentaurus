#setdep @previous@
import matplotlib as mpl
mpl.use("Agg")
import matplotlib.pyplot as plt
from scipy import stats

# write plt file
output_dir_root   = garand.workdir

#####################################################################
### the "dbi" object is injected into the environment by gpythonsh   ###
### we can use the project name to pick up all relevant data      ###
#####################################################################
VT=np.zeros(int(@ensemble_size@))

# get data from DB
project_data = Data.from_db(project="@node|Variability_IdVg@", ivar="v@gate_con@", dvar="i@drain_con@")

for x,p in enumerate(project_data):
    if "@VT_only@" == "False":
       p.write_plt(os.path.join(output_dir_root,f"n@node@_variability_idvg_stage_{x}.plt"))
       VT[x]=p.Vt(@VT_current_criterion@)
    else:
       if p.metadata["TargetFound"] == "True":
          VT[x] = p.metadata["TargetVoltage"]
       else:
          VT[x] = np.nan
    

    
print(f"DOE: VT_avg {np.mean(VT):.5}")
print(f"DOE: VT_std {np.std(VT):.5}")


#plot PNG QQ-plot and save in PNG
####################################################
VTq = VT[~np.isnan(VT[:])]
(quantiles, values), (slope, intercept, r) = stats.probplot(VTq, dist='norm')
plt.figure(1)
plt.plot(values, quantiles,'o-')
plt.plot(quantiles * slope + intercept, quantiles, 'r')

#define ticks
ticks_perc=[0.1, 1, 5, 10, 20, 50, 80, 90, 95, 99]

#transfrom them from precentile to cumulative density
ticks_quan=[stats.norm.ppf(i/100.) for i in ticks_perc]

#assign new ticks
plt.yticks(ticks_quan,ticks_perc)

plt.grid()
plt.xlabel('VT [V]')
plt.ylabel('Probplot')
plt.tight_layout()
plt.savefig(os.path.join(output_dir_root,f"n@node@_VT_distribution.png"))  
####################################################
