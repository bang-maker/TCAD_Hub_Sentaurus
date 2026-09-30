# -------- PARAMETERIZATION FROM GLOBAL AND SPLIT OPTIONS, OR DEFAULTS --------

# Set data masks and log interpolation globally
from libfromage.data import Data
Data.set_options(data_mask=True)

# Device split parameters
tfin    = @tfin@    # Physical fin thickness [m]
hfin    = @hfin@    # Physical fin height [m]
wf0     = @workfn@    # Workfunction

# Bias parameters
vdd_lin = @Vdd_lin@   # Linear drain bias [V]

# Set defaults for optional parameters
mystic_verbose = False

# Set Mystic project and output label for this stage of the flow
# Name of target data project in database
targetDataProject = "@node|UploadData@" 

# Terminal mapping
drain_con   = "@drain_con@"
gate_con  = "@gate_con@"
source_con  = "@source_con@"
bulk_con  = "@bulk_con@"

modstr    = "mosmod."
#--------------------------- MYSTIC EXECUTION SCRIPT ---------------------------

# Store the initial model to the project
# This will always be the first stage here, so set overwrite to True
mdb.StoreInitialModel(Model, overwrite=True)

Simulator.spiceargs = ["-C"]

# Use mean percentage error over the range of data
ErrorMethod = "rmsd"
# Switch on the fast Jacobian calculation
Optimizer.SetOptimizationParameter("jac", True)

eps=1e-3
Optimizer.SetOptimizationParameter("eps1",eps)
Optimizer.SetOptimizationParameter("eps2",eps)
Optimizer.SetOptimizationParameter("eps3",eps)
Optimizer.SetOptimizationParameter("eps4",eps)
Optimizer.SetOptimizationParameter("eps5",eps)
Optimizer.SetOptimizationParameter("eps6",eps)
Optimizer.SetOptimizationParameter("jacobian_eps",1e-3)
Optimizer.SetOptimizationParameter("kwargs",{"eps":1e-3,\
                                             "step_type":"abs",
                                             "step_method":"cd"})

# Set up the fin geometry parameters
Model.SetModelParameter(f'{modstr}TFIN',tfin)
Model.SetModelParameter(f'{modstr}HFIN',hfin)
Model.SetModelParameter(f'{modstr}PHIG',wf0)
Model.SetModelParameter('r_sc',@rcx@)
Model.SetModelParameter('r_dc',@rcx@)

# Some strategy defaults
Model.SetModelParameter(f'{modstr}ETA0', 0.0)
Model.SetModelParameter(f'{modstr}DVTP1',1.0)
Model.SetModelParameter(f'{modstr}CGSL', 1e-20)

IdVg   = mdb.Load(dvar=f'i{drain_con}',  ivar=f'v{gate_con}',  \
                  project=targetDataProject, combine=True).resample(step=0.025)
IsVg   = mdb.Load(dvar=f'i{source_con}', ivar=f'v{gate_con}',  \
                  project=targetDataProject, combine=True).resample(step=0.025)
IsVd   = mdb.Load(dvar=f'i{source_con}', ivar=f'v{drain_con}', \
                  project=targetDataProject, combine=True).resample(step=0.025)

IdVgld        = IdVg.FilterData('eq', vdd_lin, dtype=f"bias.{drain_con}")
vt_gm_val = float(IdVgld.VtGmMaxFinal())

# Apply filters
#if "@Type@" == "nMOS"
IsVg         = IsVg.FilterData(  'gt', 1e-13,          dtype="dvar", mask=False)
IsVgld         = IsVg.FilterData(  'eq', vdd_lin,    dtype=f"bias.{drain_con}")
IsVgld_BelowVt = IsVgld.FilterData('le', vt_gm_val-0.05, dtype="ivar")
IsVgld_AboveVt = IsVgld.FilterData('ge', vt_gm_val+0.05, dtype="ivar")
IsVd         = IsVd.FilterData(  'gt', 1e-13,    dtype="dvar", mask=False)
#elif "@Type@" == "pMOS"
IsVg         = IsVg.FilterData(  'lt', -1e-13,   dtype="dvar", mask=False)
IsVgld         = IsVg.FilterData(  'eq', vdd_lin,    dtype=f"bias.{drain_con}")
IsVgld_BelowVt = IsVgld.FilterData('ge', vt_gm_val+0.05, dtype="ivar")
IsVgld_AboveVt = IsVgld.FilterData('le', vt_gm_val-0.05, dtype="ivar")
IsVd         = IsVd.FilterData(  'lt', -1e-13,   dtype="dvar", mask=False)
#endif

# Set up parameters
phigval = Model.GetModelParameter(f'{modstr}PHIG')
PHIG    = OptParam(f'{modstr}PHIG',   phigval, phigval-0.5, phigval+0.5, 1)
CDSC    = OptParam(f'{modstr}CDSC',   0.001,   0.0,     10.0,  1)
U0      = OptParam(f'{modstr}U0',     0.02,    0.006,     1.0,   0.02)
UA      = OptParam(f'{modstr}UA',     0.3,     0.0,     100.0,   1.0)
ETAMOB  = OptParam(f'{modstr}ETAMOB', 2,       0,     10,    2)
EU      = OptParam(f'{modstr}EU',     2.5,     0.1,     10.0,  2)
UD      = OptParam(f'{modstr}UD',     0.1,     0.0,     1,     0.1)
UCS     = OptParam(f'{modstr}UCS',    1.0,     0.0,     10,    1)

Simulator.SetSimulationGMIN(1e-18)

Stage1Parameters=[PHIG,CDSC]
Stage2Parameters=[U0,UA,EU,UD,UCS,ETAMOB]
Stage3Parameters=[PHIG,CDSC,U0,UA,EU,UD,ETAMOB,UCS]

fit_error=1000
x=0
while (x < 5 and fit_error>2.0):
    ExtractionUtils.DoStage("LD_step1", Model, Simulator, Stage1Parameters, \
                            Optimizer, [IsVgld_BelowVt],verbose=mystic_verbose)
    ExtractionUtils.DoStage("LD_step2", Model, Simulator, Stage2Parameters, \
                            Optimizer, [IsVgld_AboveVt],verbose=mystic_verbose)
    ExtractionUtils.DoStage("LD_step3", Model, Simulator, Stage3Parameters, \
                            Optimizer, [IsVgld_BelowVt,IsVgld_AboveVt], [1,2],\
                            verbose=mystic_verbose)
    fit_error=ExtractionUtils.PrintErrors("LD_step3_error", \
                                          IsVgld, Simulator, Model, ErrorMethod)
    x+=1

ExtractionUtils.PrintErrors("LD_step_IsVgld_error", \
                           IsVg, Simulator, Model, ErrorMethod)
ExtractionUtils.PrintErrors("LD_step_IsVd_error", \
                           IsVd,   Simulator, Model, ErrorMethod)

mdb.StoreFitData(IsVg, Model, error=fit_error)
mdb.StoreFitData(IsVd, Model, error=fit_error)

Optimizer.write_parameter_csv('@pwd@/@nodedir@/n@node@-idvg-ld-pars')
ExtractionUtils.PrintErrors("LD_step_IdVgld_error", \
                           IdVgld, Simulator, Model, ErrorMethod)

IdVgld.WritePLTFile('@pwd@/@nodedir@/n@node@-idvg-ld')
