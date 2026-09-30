# ----------- PARAMETERIZATION FROM GLOBAL AND SPLIT OPTIONS, OR DEFAULTS -----------

# Device split parameters
gate_length       = @lgate@			# Physical gate length [nm]
tfin              = @tfin@			# Physical fin thickness [nm]
hfin              = @hfin@			# Physical fin height [nm]

# Bias parameters
vdd_nom           = @Vdd_nom@			# Supply voltage [V]
vdd_lin           = @Vdd_lin@			# Linear drain bias [V]

# Set defaults for optional parameters
mystic_verbose = False
default_temp   = 300

# Set Mystic project and output label for this stage of the flow
targetDataProject = "@node|UploadData@"		# Name of Enigma project in database
mysticProjectName = "@node@"			# Name of Mystic project in database

# Terminal mapping
drain_con 	= "@drain_con@"
gate_con 	= "@gate_con@"
source_con	= "@source_con@"
bulk_con	= "@bulk_con@"
# Terminal mapping
acdrain_con 	= "@acdrain_con@"
acgate_con 	= "@acgate_con@"
acsource_con	= "@acsource_con@"
acbulk_con	= "@acbulk_con@"

modstr		= "mosmod."
# ---------------------------- MYSTIC EXECUTION SCRIPT -----------------------------

Simulator.spiceargs = ["-C"]

# Use mean percentage error over the range of data
ErrorMethod = "rmsd"
# Switch on the fast Jacobian calculation
Optimiser.SetOptimisationParameter("jac", True)
eps=1e-5
Optimiser.SetOptimisationParameter("eps1",eps)
Optimiser.SetOptimisationParameter("eps2",eps)
Optimiser.SetOptimisationParameter("eps3",eps)
Optimiser.SetOptimisationParameter("eps4",eps)
Optimiser.SetOptimisationParameter("eps5",eps)
Optimiser.SetOptimisationParameter("eps6",eps)
Optimiser.SetOptimisationParameter("delta",1.0)
Optimiser.SetOptimisationParameter("jacobian_eps",1e-3)
Optimiser.SetOptimisationParameter("kwargs",{"eps":1e-3,"step_type":"rel","step_method":"cd"})

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

# Id-Vg data
IdVg    = mdb.Load(instances={"l":gate_length}, bias={},                       ivar=f"v{gate_con}", dvar=f"i{drain_con}", project=targetDataProject)
IdVgall = mdb.Load(instances={"l":gate_length}, bias={},                       ivar=f"v{gate_con}", dvar=f"i{drain_con}", project=targetDataProject)
IdVg_LD = mdb.Load(instances={"l":gate_length}, bias={f"{drain_con}":vdd_lin}, ivar=f"v{gate_con}", dvar=f"i{drain_con}", project=targetDataProject)
IdVg_HD = mdb.Load(instances={"l":gate_length}, bias={f"{drain_con}":vdd_nom}, ivar=f"v{gate_con}", dvar=f"i{drain_con}", project=targetDataProject)

# Id-Vg data
IdVdall  = mdb.Load(instances={"l":gate_length}, bias={},                      ivar=f"v{drain_con}", dvar=f"i{drain_con}", project=targetDataProject)
IdVd_VDD = mdb.Load(instances={"l":gate_length}, bias={f"{gate_con}":vdd_nom}, ivar=f"v{drain_con}", dvar=f"i{drain_con}", project=targetDataProject)

# C-V data
CggVgall = mdb.Load(instances={"l":gate_length}, bias={},                   dvar=f"c({gate_con},{gate_con})", project=targetDataProject)
CggVg_LD = mdb.Load(instances={"l":gate_length}, bias={f"{drain_con}":0.0}, dvar=f"c({gate_con},{gate_con})", project=targetDataProject)

# Data filters
# Calculate VtGmMax
vt_gm_val = float(IdVg_LD.VtGmMaxFinal())

#if "@Type@" == "nMOS"
BelowVDD     = ('le', vdd_nom*1.2,    "ivar")
AboveVt      = ('ge', vt_gm_val+0.05, "ivar")
BelowVt      = ('le', vt_gm_val-0.05, "ivar")
Ioff_bias    = ('le', 0.0,            "ivar")
AboveVDDnom  = ('ge', vdd_nom,        "ivar")
AboveHalfVDD = ('ge', vdd_nom/2.0,    "ivar")
LowCurrentFilter = ('lt', -1e-15,     "dvar")
#elif "@Type@" == "pMOS"
BelowVDD     = ('ge', 1.2*vdd_nom,    "ivar")
AboveVt      = ('le', vt_gm_val-0.05, "ivar")
BelowVt      = ('ge', vt_gm_val+0.05, "ivar")
Ioff_bias    = ('ge', 0.0,            "ivar")
AboveVDDnom  = ('le', vdd_nom,        "ivar")
AboveHalfVDD = ('le', vdd_nom/2.0,    "ivar")
LowCurrentFilter = ('gt', 1e-15, "dvar")
#endif

# Id-Vg filters
IdVg    = IdVg.FilterData(*BelowVDD)
IdVg_LD = IdVg_LD.FilterData(*BelowVDD)
IdVg_HD = IdVg_HD.FilterData(*BelowVDD)
Ioff_HD = IdVg_HD.FilterData(*Ioff_bias)
Ioff_LD = IdVg_LD.FilterData(*Ioff_bias)
Ion_LD = IdVg_LD.FilterData(*AboveVDDnom)
Ion_HD = IdVg_HD.FilterData(*AboveVDDnom)

IdVg_BelowVt = IdVg.FilterData(*BelowVt)
IdVg_AboveVt = IdVg.FilterData(*AboveVt)
IdVg_LD_BelowVt = IdVg_LD.FilterData(*BelowVt)
IdVg_LD_AboveVt = IdVg_LD.FilterData(*AboveVt)
IdVg_HD_BelowVt = IdVg_HD.FilterData(*BelowVt)
IdVg_HD_AboveVt = IdVg_HD.FilterData(*AboveVt)

# Id-Vd filters
IdVdall = IdVdall.FilterData(*LowCurrentFilter)
IdVd_VDD = IdVd_VDD.FilterData(*AboveHalfVDD)

# Set up parameters
PHIG 	= OptParam(f'{modstr}PHIG', 4.55656, 3, 6, 4)
CDSC 	= OptParam(f'{modstr}CDSC', 0.0147204, 0.0001, 10, 1)
CDSCD 	= OptParam(f'{modstr}CDSCD',7e-3,-1,1,1)
DVTP0 	= OptParam(f'{modstr}DVTP0', -0.01, -0.5, 0.1, 0.1)
U0   	= OptParam(f'{modstr}U0', 0.0279515, 0.0, 1.0, 0.0001)
UA   	= OptParam(f'{modstr}UA', 0, -1, 100, 0.1)
VSAT 	= OptParam(f'{modstr}VSAT', 120000, 30000, 600000, 10000)
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
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S1Parameters, Optimiser, [IdVg_LD_BelowVt], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S2Parameters,  Optimiser, [IdVg_HD_BelowVt], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S3Parameters,  Optimiser, [Ion_LD], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S4Parameters,  Optimiser, [Ion_HD], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S5Parameters,  Optimiser, [IdVd_VDD], verbose=mystic_verbose)
    ExtractionUtils.DoStage(mysticProjectName, Model, Simulator, S6Parameters,  Optimiser, [CggVg_LD], verbose=mystic_verbose)
    i+=1

    e = ExtractionUtils.PrintErrors(mysticProjectName, IdVgall, Simulator, Model, ErrorMethod)
    e2 = ExtractionUtils.PrintErrors(mysticProjectName, IdVdall, Simulator, Model, ErrorMethod)
    e3 = ExtractionUtils.PrintErrors(mysticProjectName, CggVg_LD, Simulator, Model, ErrorMethod)

# Calculate the errors
ExtractionUtils.PrintErrors(mysticProjectName, IdVg_LD_BelowVt, Simulator, Model, ErrorMethod)
ExtractionUtils.PrintErrors(mysticProjectName, IdVg_LD_AboveVt, Simulator, Model, ErrorMethod)
ExtractionUtils.PrintErrors(mysticProjectName, IdVg_HD_BelowVt, Simulator, Model, ErrorMethod)
ExtractionUtils.PrintErrors(mysticProjectName, IdVg_HD_AboveVt, Simulator, Model, ErrorMethod)

e = ExtractionUtils.PrintErrors(mysticProjectName, IdVgall, Simulator, Model, ErrorMethod)
e2 = ExtractionUtils.PrintErrors(mysticProjectName, IdVdall, Simulator, Model, ErrorMethod)
e3 = ExtractionUtils.PrintErrors(mysticProjectName, CggVgall, Simulator, Model, ErrorMethod)
print("Error_IdVg: {0}%".format(e))
print("Error_IdVd: {0}%".format(e2))
print("Error_CggVg: {0}%".format(e3))

mdb.StoreFitData(IdVgall, Model, description="RSM", error=e)

# Output .plt files
IdVgall.WritePLTFile('@pwd@/@nodedir@/n@node@_idvg')
IdVdall.WritePLTFile('@pwd@/@nodedir@/n@node@_idvd')
CggVgall.WritePLTFile('@pwd@/@nodedir@/n@node@_cggvg')


