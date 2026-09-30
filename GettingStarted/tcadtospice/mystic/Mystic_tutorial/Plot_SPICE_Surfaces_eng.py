#setdep @node|Mystic_Response_Surface:all@

from plt3d_helpers import CheckErrors
from plt_helpers import get_mystic_RSM_FoMs

#if @node:index@ == 1

## Variables
vt_cc	 =1e-7

## Set column names for the FoMs
cols  =["VT_lin", "VT_sat", "DIBL", "Ion_lin", "Ion_sat", "Ioff_lin", "Ioff_sat"]
abstol=[0.005   , 0.005   , 0.015 , 5e-7     , 3e-6	, 0.2       , 0.2       ]
reltol=[5	, 5	  , 20    , 3        , 1	, 2         , 2         ]


# Retrieve the data from the database
rsm_projects_n=dbi.get_project(swb__Type="nMOS", swb__tool_label="Mystic_Response_Surface")
rsm_projects_p=dbi.get_project(swb__Type="pMOS", swb__tool_label="Mystic_Response_Surface")

doe	=rsm_projects_n[0].metadata["doe"]								  
axes_list = list(doe.keys()) 

nmos_TCAD, nmos_MYSTIC = get_mystic_RSM_FoMs(rsm_projects_n, vt_cc=1e-7)
pmos_TCAD, pmos_MYSTIC = get_mystic_RSM_FoMs(rsm_projects_p, vt_cc=1e-7)

nT=nmos_TCAD.drop(axes_list,axis=1)
nM=nmos_MYSTIC.drop(axes_list,axis=1)
plotter._dist_data=[nT,nM]
plotter.plot_scatter_matrix(filename="@pwd@/@nodedir@/n@node@_nMOS_scattermatrix", multiplot=True)

CheckErrors(cols, abstol, reltol, axes_list=axes_list, refdata=nmos_TCAD, fitdata=nmos_MYSTIC, outpath="@pwd@/@nodedir@", prefix="n@node@_nMOS")
CheckErrors(cols, abstol, reltol, axes_list=axes_list, refdata=pmos_TCAD, fitdata=pmos_MYSTIC, outpath="@pwd@/@nodedir@", prefix="n@node@_pMOS")

#else
#noexec
#endif 
                      
