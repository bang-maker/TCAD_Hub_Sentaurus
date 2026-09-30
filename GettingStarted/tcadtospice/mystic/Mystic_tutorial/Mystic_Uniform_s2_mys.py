# ----------- PARAMETERIZATION FROM GLOBAL AND SPLIT OPTIONS, OR DEFAULTS -----------

# Set data masks and log interpolation globally
from libfromage.data import Data
Data.set_options(data_mask=True)
                 
# Device split parameters
gate_length       = @lgate@     # Physical gate length [m]
tfin              = @tfin@      # Physical fin thickness [m]
hfin              = @hfin@      # Physical fin height [m]
wf0               = @workfn@      # Workfunction

# Bias parameters
vdd_nom           = @Vdd_nom@     # Supply voltage [V]
vdd_lin           = @Vdd_lin@     # Linear drain bias [V]
idvd_hvg          = @Vdd_nom@

# Simulation parameters
mystic_verbose    = False

# Set Mystic project and output label for this stage of the flow
targetDataProject = "@node|UploadData@"   # Name of target data project in database

# Terminal mapping
drain_con   = "@drain_con@"
gate_con  = "@gate_con@"
source_con  = "@source_con@"
bulk_con  = "@bulk_con@"

modstr    = "mosmod."
# ---------------------------- MYSTIC EXECUTION SCRIPT -----------------------------

Simulator.spiceargs = ["-C"]

# Use mean percentage error over the range of data
ErrorMethod = "rmsd"
Optimizer.SetOptimizationParameter("jac", True)
eps=1e-5
Optimizer.SetOptimizationParameter("eps1",eps)
Optimizer.SetOptimizationParameter("eps2",eps)
Optimizer.SetOptimizationParameter("eps3",eps)
Optimizer.SetOptimizationParameter("eps4",eps)
Optimizer.SetOptimizationParameter("eps5",eps)
Optimizer.SetOptimizationParameter("eps6",eps)
Optimizer.SetOptimizationParameter("jacobian_eps",1e-3)
Optimizer.SetOptimizationParameter("kwargs", \
  {"eps":1e-3,"step_type":"abs","step_method":"cd"})

# Load the model from the previous stage
Model = mdb.GetFitModel()
# ------------------------------------------------------------------- #


IsVg     = mdb.GetFitData(ivar=f"v{gate_con}",  dvar=f"i{source_con}")
IsVd     = mdb.GetFitData(ivar=f"v{drain_con}", dvar=f"i{source_con}")
IdVg     = mdb.Load(dvar=f"i{drain_con}", ivar=f"v{gate_con}", \
                  project=targetDataProject, combine=True).resample(step=0.025)
IdVd     = mdb.Load(dvar=f"i{drain_con}", ivar=f"v{drain_con}", \
                  project=targetDataProject, combine=True).resample(step=0.025)

IsVgld   = IsVg.FilterData('eq', vdd_lin,       dtype=f"bias.{drain_con}")
IsVghd   = IsVg.FilterData('eq', vdd_nom,       dtype=f"bias.{drain_con}")
IdVgld   = IdVg.FilterData('eq', vdd_lin, dtype=f"bias.{drain_con}")
IsVd_vdd = IsVd.FilterData('eq', vdd_nom,       dtype=f"bias.{gate_con}")

# Calculate VtGmMax
vt_gm_val = float(IdVgld.VtGmMaxFinal())
ivt       = float(IdVgld[0](vt_gm_val))

#if "@Type@" == "nMOS"
IsVgld_BelowVt = IsVgld.FilterData("lt", vt_gm_val-0.02, dtype="ivar")
IsVgld_AboveVt = IsVgld.FilterData("gt", vt_gm_val-0.02, dtype="ivar")
IsVghd_BelowVt = IsVghd.FilterData("lt", vt_gm_val-0.02, dtype="ivar")
IsVghd_AboveVt = IsVghd.FilterData("gt", vt_gm_val-0.02, dtype="ivar")
off = 0.1
#else
IsVgld_BelowVt = IsVgld.FilterData("gt", vt_gm_val+0.02, dtype="ivar")
IsVgld_AboveVt = IsVgld.FilterData("lt", vt_gm_val+0.02, dtype="ivar")
IsVghd_BelowVt = IsVghd.FilterData("gt", vt_gm_val+0.02, dtype="ivar")
IsVghd_AboveVt = IsVghd.FilterData("lt", vt_gm_val+0.02, dtype="ivar")
off = -0.1
#endif

# Set up FoM extraction targets
Ion_sat  = IsVghd.MakeFoMTarget('ion',  vdd_nom)
Ioff_sat = IsVghd.MakeFoMTarget("ioff", off)

# Set up parameters
phigval  = Model.GetModelParameter(f'{modstr}PHIG')
PHIG     = OptParam(f'{modstr}PHIG',   phigval, phigval-0.5, phigval+0.5, 1)
ETA0     = OptParam(f'{modstr}ETA0',   2,       0,       100,   0.1)
CDSC     = OptParam(f'{modstr}CDSC',   7e-3,  0.0,       10.0,    1)
CDSCD    = OptParam(f'{modstr}CDSCD',  7e-3,  0,       1,     1)
U0       = OptParam(f'{modstr}U0',     0.02,  0.001,       10.0,    0.001)
UA       = OptParam(f'{modstr}UA',     0.3, 0.0,       100.0,   0.01)
ETAMOB   = OptParam(f'{modstr}ETAMOB', 2, 0,       100,   2)
EU       = OptParam(f'{modstr}EU',     2.5, 0.1,       10.0,    0.1)
VSAT     = OptParam(f'{modstr}VSAT',   100000,  20000,       600000,    10000)
PTWG     = OptParam(f'{modstr}PTWG',   0, 0,       100,   0.1)
KSATIV   = OptParam(f'{modstr}KSATIV', 1, -5,      5,     1)
MEXP     = OptParam(f'{modstr}MEXP',   4, 2,       10,    4)
PVAG     = OptParam(f'{modstr}PVAG',   1, 0,       100,   1)
PDIBL2   = OptParam(f'{modstr}PDIBL2', 1e-3,  1e-16,       1,     0.0001)
DVTP0    = OptParam(f'{modstr}DVTP0',  -0.01,   -0.5,        0.1,     0.005)
UD       = OptParam(f'{modstr}UD',     0.1, 0.0,       1,     0.1)
UCS      = OptParam(f'{modstr}UCS',    1.0, 0.0,       10,    1)

Simulator.SetSimulationGMIN(1e-18)

# Compact model parameter sets for initial fit
Stage1aParameters = [DVTP0]
Stage1bParameters = [CDSCD]
Stage1Parameters  = [DVTP0,CDSCD]
Stage2aParameters = [VSAT]
Stage2Parameters  = [KSATIV,MEXP,PVAG,PDIBL2,DVTP0,CDSCD]
Stage3Parameters  = [PHIG,KSATIV,MEXP,PVAG,CDSC,U0,ETAMOB,\
                     EU,UA,DVTP0,PDIBL2,VSAT]

isvg_error=1000.0
isvd_error=1000.0
x=0.0
# Extraction strategy

while (x < 5 and  (isvg_error > 3.5 or isvd_error > 3.5)):
    ExtractionUtils.DoStage("HD_step1", Model, Simulator, Stage1aParameters, \
                           Optimizer, [Ioff_sat], verbose=mystic_verbose)
    ExtractionUtils.DoStage("HD_step2", Model, Simulator, Stage1bParameters, \
                           Optimizer, [IsVghd_BelowVt], verbose=mystic_verbose)
    ExtractionUtils.DoStage("HD_step3", Model, Simulator, Stage1Parameters, \
                           Optimizer, [IsVghd_BelowVt], verbose=mystic_verbose)
    ExtractionUtils.DoStage("HD_step4", Model, Simulator, Stage2aParameters, \
                           Optimizer, [Ion_sat], verbose=mystic_verbose)
    ExtractionUtils.DoStage("HD_step5", Model, Simulator, Stage2Parameters, \
                           Optimizer, [IsVghd,IsVd], verbose=mystic_verbose)
    isvg_error = ExtractionUtils.PrintErrors("HD_step5_err", IsVg, Simulator,\
                           Model, ErrorMethod)
    isvd_error = ExtractionUtils.PrintErrors("HD_step5_err", IsVd, Simulator,\
                           Model, ErrorMethod)
    x+=1

ExtractionUtils.DoStage("HD_step6", Model, Simulator, Stage3Parameters, \
                Optimizer, [IsVg,IsVd,IsVd_vdd], [1,1,2],verbose=mystic_verbose)

isvg_error = ExtractionUtils.PrintErrors("HD_IsVg_err", IsVg, Simulator, \
                                         Model, ErrorMethod)
isvd_error = ExtractionUtils.PrintErrors("HD_IsVd_err", IsVd, Simulator, \
                                         Model, ErrorMethod)

mdb.StoreFitData(IsVg, Model, error=isvg_error)
mdb.StoreFitData(IsVd, Model, error=isvd_error)

Optimizer.write_parameter_csv('@pwd@/@nodedir@/n@node@-idvg-hd-pars')
ExtractionUtils.PrintErrors("HD_IdVg_err", IdVg, Simulator, Model, ErrorMethod)
ExtractionUtils.PrintErrors("HD_IdVd_err", IdVd, Simulator, Model, ErrorMethod)
IdVg.WritePLTFile('@pwd@/@nodedir@/n@node@-idvg-hd')
IdVd.WritePLTFile('@pwd@/@nodedir@/n@node@-idvd-hd')

