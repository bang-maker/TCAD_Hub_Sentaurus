# ---------- PARAMETERIZATION FROM GLOBAL AND SPLIT OPTIONS, OR DEFAULTS ----------

# Set data masks and log interpolation globally
from libfromage.data import Data
Data.set_options(data_mask=True)
                 
# Device split parameters
gate_length       = @lgate@        # Physical gate length [m]
tfin              = @tfin@         # Physical fin thickness [m]
hfin              = @hfin@         # Physical fin height [m]
wf0               = @workfn@         # Workfunction

# Bias parameters
vdd_nom           = @Vdd_nom@        # Supply voltage [V]
vdd_lin           = @Vdd_lin@        # Supply voltage [V]
vdd_cgg           = 0.0

# Simulation parameters
mystic_verbose    = False

# Set Mystic project and output label for this stage of the flow
targetDataProject = "@node|UploadData@"      # Name of target data project in database

# Terminal mapping
drain_con   = "@acdrain_con@"
gate_con  = "@acgate_con@"
source_con  = "@acsource_con@"
bulk_con  = "@acbulk_con@"

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
Optimizer.SetOptimizationParameter("kwargs",{"eps":1e-3,"step_type":"abs","step_method":"cd"})

# Load the model from the previous stage
Model = mdb.GetFitModel()
# ------------------------------------------------------------------- #
Model.SetModelParameter(f'{modstr}cgso',1e-10)
Model.SetModelParameter(f'{modstr}cgdo',1e-10)
Model.SetModelParameter(f'{modstr}cgsl',1e-10)
Model.SetModelParameter(f'{modstr}cgdl',1e-10)
     
# Load data
CV_raw    = mdb.Load(dvar=f'c({gate_con},{gate_con})', \
                           project=targetDataProject).resample(step=0.05)

# Filter out high-drain C-V data as only the low-drain C-V data is used
CV_raw_ld = CV_raw.FilterData('eq', vdd_cgg, dtype=f"bias.{drain_con}")

# Filter out extra data using the Vt of the device
IdVg      = mdb.Load(dvar=f'i{drain_con}', ivar=f'v{gate_con}',  \
                           project=targetDataProject).resample(step=0.025)
IdVg_ld   = IdVg.FilterData('eq', vdd_lin, dtype=f"bias.{drain_con}")
vt_gm_val   = float(IdVg_ld.VtGmMaxFinal())

#if "@Type@" == "nMOS"
AboveAccu   = ('ge', -0.15,   "ivar")
BelowInv1   = ('le', vt_gm_val-0.1, "ivar")
BelowInv2   = ('le', vt_gm_val, "ivar")
AboveInv    = ('ge', vt_gm_val+0.1, "ivar")
HighGate    = ('le', 1.0,     "ivar")
#else if "@Type@" == "pMOS"
AboveAccu   = ('le', 0.1,     "ivar")
BelowInv1   = ('ge', vt_gm_val+0.1, "ivar")
BelowInv2   = ('ge', vt_gm_val,   "ivar")
AboveInv    = ('le', vt_gm_val-0.1, "ivar")
HighGate    = ('ge', -1.0,    "ivar")
#endif

CV_filtered_ld = CV_raw_ld.FilterData(*HighGate)
CV_BelowInv1_ld = CV_filtered_ld.FilterData(*BelowInv1)
CV_BelowInv2_ld = CV_filtered_ld.FilterData(*BelowInv2)
CV_AboveInv_ld = CV_filtered_ld.FilterData(*AboveInv)

# Set up C-V parameters 
cgso     = OptParam(f'{modstr}cgso',  1e-11,  1e-20,  1e-8, 1e-10)
qmtcencv = OptParam(f'{modstr}qmtcencv',0.5,  1e-3, 20, 1.0) 
ckappas  = OptParam(f'{modstr}ckappas', 0.6,  0.05, 200,  0.2)
qm0      = OptParam(f'{modstr}qm0', 0.001,  1e-4, 10, 1.0) 
cgsl     = OptParam(f'{modstr}cgsl',  1e-11,  1e-20,  1e-8, 1e-10)
deltawcv = OptParam(f'{modstr}deltawcv',0,  -30e-9, 30e-9,  1e-8)

cgdo     = LinkedOptParam(f'{modstr}cgdo',cgso)
ckappad  = LinkedOptParam(f'{modstr}ckappad',ckappas) 
cgdl     = LinkedOptParam(f'{modstr}cgdl',cgsl)

# Set up parameter sets
CVParameters_BelowInv_1 = [cgso,cgdo]
CVParameters_BelowInv_2 = [ckappas,cgsl,cgdl]
CVParameters_AboveInv   = [deltawcv,qmtcencv,qm0]
AllPars                 = [cgso,cgdo,ckappas,ckappad,\
                           cgsl,cgdl,deltawcv,qmtcencv,qm0]
x=0
fit_error=1e9
# Run extraction
while (x<2 and fit_error>1):
    for j in range(1): ExtractionUtils.DoStage("CV_step1", Model, \
                       Simulator, CVParameters_BelowInv_1, Optimizer, 
                       [CV_BelowInv1_ld])
    for j in range(1): ExtractionUtils.DoStage("CV_step2", Model, \
                       Simulator, CVParameters_BelowInv_2, Optimizer, 
                       [CV_BelowInv2_ld])
    for j in range(1): ExtractionUtils.DoStage("CV_step3", Model, \
                       Simulator, CVParameters_AboveInv, Optimizer, \
                       [CV_AboveInv_ld])
    fit_error = ExtractionUtils.PrintErrors("CV_step3_error", 
                        CV_filtered_ld, Simulator, Model, ErrorMethod)
    x+=1

for j in range(3): ExtractionUtils.DoStage("CV_step4", Model, Simulator, \
                   AllPars, Optimizer, [CV_filtered_ld])

print("\n Final Errors: ")
fit_error = ExtractionUtils.PrintErrors("CV_step4_error", CV_filtered_ld, \
            Simulator, Model, ErrorMethod)


# Store fit data and parameters in the database
mdb.StoreFitData(CV_filtered_ld, Model, error=fit_error)

Optimizer.write_parameter_csv('@pwd@/@nodedir@/n@node@-cv-pars')
CV_filtered_ld.WritePLTFile('@pwd@/@nodedir@/n@node@-cv')
Model.WriteModel("@pwd@/@nodedir@/n@node@_final_model.mod")

