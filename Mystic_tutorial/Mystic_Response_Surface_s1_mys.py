# ----------- PARAMETERIZATION FROM GLOBAL AND SPLIT OPTIONS, OR DEFAULTS ------

# Set data masks and log interpolation globally
from libfromage.data import Data
Data.set_options(data_mask=True)

# Device split parameters
gate_length       = @lgate@     # Physical gate length [nm]
tfin              = @tfin@      # Physical fin thickness [nm]
hfin              = @hfin@      # Physical fin height [nm]

# Bias parameters
vdd_nom           = @Vdd_nom@   # Supply voltage [V]
vdd_lin           = @Vdd_lin@   # Linear drain bias [V]

# Set defaults for optional parameters
mystic_verbose = False
default_temp   = 300

# Set Mystic project and output label for this stage of the flow
targetDataProject = "@node|UploadData@" # Name of target data project in database
mysticProjectName = "@node@"            # Name of Mystic project in database

# Terminal mapping
drain_con     = "@drain_con@"
gate_con      = "@gate_con@"
source_con    = "@source_con@"
bulk_con      = "@bulk_con@"
# Terminal mapping
acdrain_con   = "@acdrain_con@"
acgate_con    = "@acgate_con@"
acsource_con  = "@acsource_con@"
acbulk_con    = "@acbulk_con@"

modstr        = "mosmod."
# ---------------------------- MYSTIC EXECUTION SCRIPT -------------------------

Simulator.spiceargs = ["-C"]

# Use mean percentage error over the range of data
ErrorMethod = "rmsd"
# Switch on the fast Jacobian calculation
Optimizer.SetOptimizationParameter("jac", True)
eps=1e-5
Optimizer.SetOptimizationParameter("eps1",eps)
Optimizer.SetOptimizationParameter("eps2",eps)
Optimizer.SetOptimizationParameter("eps3",eps)
Optimizer.SetOptimizationParameter("eps4",eps)
Optimizer.SetOptimizationParameter("eps5",eps)
Optimizer.SetOptimizationParameter("eps6",eps)
Optimizer.SetOptimizationParameter("delta",1.0)
Optimizer.SetOptimizationParameter("jacobian_eps",1e-3)
Optimizer.SetOptimizationParameter("kwargs", {"eps": 1e-3,
                                              "step_type": "rel",
                                              "step_method": "cd"})

# ------------------------------------------------------------------- #
# Load the data/model from the previous stage
Model = mdb.GetFitModel()
# This will always be the first stage here, so set overwrite to True
mdb.StoreInitialModel(Model, overwrite=True)
# ------------------------------------------------------------------- #

# Pick up geometric parameters
setparams = ["tfin","hfin"]
Model.SetModelParameter(f'{modstr}TFIN',tfin)
Model.SetModelParameter(f'{modstr}HFIN',hfin)

# Load data
IdVgall  = mdb.Load(ivar=f"v{gate_con}", dvar=f"i{drain_con}",
                    project=targetDataProject)
IdVdall  = mdb.Load(ivar=f"v{drain_con}", dvar=f"i{drain_con}",
                    project=targetDataProject)
CggVgall = mdb.Load(dvar=f"c({gate_con},{gate_con})",
                    project=targetDataProject)

# Data filters

#if "@Type@" == "nMOS"
IdVgall = IdVgall.FilterData("lt", -1e-15, "dvar")
IdVg    = IdVgall.FilterData("le", vdd_nom*1.2, "ivar")
IdVdall = IdVdall.FilterData("lt", -1e-15, "dvar")
#else
IdVgall = IdVgall.FilterData("gt", 1e-15, "dvar")
IdVg    = IdVgall.FilterData("ge", vdd_nom*1.2, "ivar")
IdVdall = IdVdall.FilterData("gt", 1e-15, "dvar")
#endif

# IdVg filters
IdVgld  = IdVg.FilterData("eq", vdd_lin, f"bias.{drain_con}")
IdVghd  = IdVg.FilterData("eq", vdd_nom, f"bias.{drain_con}")
Ionld   = IdVgld.FilterData("ge", vdd_nom, "ivar")
Ionhd   = IdVghd.FilterData("ge", vdd_nom, "ivar")

# Calculate VtGmMax
vt_gm_val = float(IdVgld.VtGmMaxFinal())

#if "@Type@" == "nMOS"
IdVg_BelowVt = IdVg.FilterData("le", vt_gm_val-0.05, "ivar")
IdVg_AboveVt = IdVg.FilterData("ge", vt_gm_val+0.05, "ivar")
#else
IdVg_BelowVt = IdVg.FilterData("ge", vt_gm_val+0.05, "ivar")
IdVg_AboveVt = IdVg.FilterData("le", vt_gm_val-0.05, "ivar")
#endif

IdVgld_BelowVt = IdVg_BelowVt.FilterData("eq", vdd_lin, f"bias.{drain_con}")
IdVgld_AboveVt = IdVg_AboveVt.FilterData("eq", vdd_lin, f"bias.{drain_con}")
IdVghd_BelowVt = IdVg_BelowVt.FilterData("eq", vdd_nom, f"bias.{drain_con}")
IdVghd_AboveVt = IdVg_AboveVt.FilterData("eq", vdd_nom, f"bias.{drain_con}")

# Id-Vd filters
IdVd_vdd = IdVdall.FilterData("eq", vdd_nom, f"bias.{gate_con}")
IdVd_vdd = IdVd_vdd.FilterData("le", vdd_nom/2.0, "ivar")

# C-V filters
CggVgld = CggVgall.FilterData("eq", 0.0, f"bias.{drain_con}")

# Set up parameters
PHIG  = OptParam(f'{modstr}PHIG', 4.55656, 3, 6, 4)
CDSC  = OptParam(f'{modstr}CDSC', 0.0147204, 0.0001, 10, 1)
CDSCD   = OptParam(f'{modstr}CDSCD',7e-3,-1,1,1)
DVTP0   = OptParam(f'{modstr}DVTP0', -0.01, -0.5, 0.1, 0.1)
U0    = OptParam(f'{modstr}U0', 0.0279515, 0.0, 1.0, 0.0001)
UA    = OptParam(f'{modstr}UA', 0, -1, 100, 0.1)
VSAT  = OptParam(f'{modstr}VSAT', 120000, 30000, 600000, 10000)
# Added for Id-Vd
KSATIV  = OptParam(f'{modstr}KSATIV',1,-5,5,1)
MEXP    = OptParam(f'{modstr}MEXP',4,2,10,4)
PVAG    = OptParam(f'{modstr}PVAG',1,0,100,1)
PDIBL2  = OptParam(f'{modstr}PDIBL2',1e-3,1e-16,1,1e-6)
# Added for Cgg-Vg
deltawcv = OptParam(f'{modstr}deltawcv',0,-30e-9, 30e-9,1e-8)
cgso     = OptParam(f'{modstr}cgso',1e-20,1e-25,1,1e-9)
cgdo     = LinkedOptParam(f'{modstr}cgdo',cgso)

# Group parameters for the stages
S1Parameters=ParameterSet([PHIG,CDSC])
S2Parameters=ParameterSet([DVTP0,CDSCD])
S3Parameters=ParameterSet([U0])
S4Parameters=ParameterSet([KSATIV])
S5Parameters=ParameterSet([MEXP])
S6Parameters = ParameterSet([deltawcv,cgso,cgdo])

# Perform the extraction
results = dict()
e=100
e2=100
e3=100
i=0
while i<5 and (e>3 or e2>3 or e3>3):
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S1Parameters,
                            Optimizer, [IdVgld_BelowVt], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S2Parameters,
                            Optimizer, [IdVghd_BelowVt], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S3Parameters,
                            Optimizer, [Ionld], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S4Parameters,
                            Optimizer, [Ionhd], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S5Parameters,
                            Optimizer, [IdVd_vdd], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S6Parameters,
                            Optimizer, [CggVgld], verbose=mystic_verbose)
    i += 1

    e = ExtractionUtils.PrintErrors(mysticProjectName, IdVgall, Simulator,
                                    Model, ErrorMethod)
    e2 = ExtractionUtils.PrintErrors(mysticProjectName, IdVdall, Simulator,
                                     Model, ErrorMethod)
    e3 = ExtractionUtils.PrintErrors(mysticProjectName, CggVgld, Simulator,
                                     Model, ErrorMethod)

# Calculate the errors.
ExtractionUtils.PrintErrors(mysticProjectName, IdVgld_BelowVt, Simulator,
                            Model, ErrorMethod)
ExtractionUtils.PrintErrors(mysticProjectName, IdVgld_AboveVt, Simulator,
                            Model, ErrorMethod)
ExtractionUtils.PrintErrors(mysticProjectName, IdVghd_BelowVt, Simulator,
                            Model, ErrorMethod)
ExtractionUtils.PrintErrors(mysticProjectName, IdVghd_AboveVt, Simulator,
                            Model, ErrorMethod)

e = ExtractionUtils.PrintErrors(mysticProjectName, IdVgall, Simulator,
                                Model, ErrorMethod)
e2 = ExtractionUtils.PrintErrors(mysticProjectName, IdVdall, Simulator,
                                 Model, ErrorMethod)
e3 = ExtractionUtils.PrintErrors(mysticProjectName, CggVgall, Simulator,
                                 Model, ErrorMethod)
print("Error_IdVg: {0}%".format(e))
print("Error_IdVd: {0}%".format(e2))
print("Error_CggVg: {0}%".format(e3))

mdb.StoreFitData(IdVgall, Model, description="RSM", error=e)

# Output .plt files
IdVgall.WritePLTFile('@pwd@/@nodedir@/n@node@_idvg')
IdVdall.WritePLTFile('@pwd@/@nodedir@/n@node@_idvd')
CggVgall.WritePLTFile('@pwd@/@nodedir@/n@node@_cggvg')
