# -------- PARAMETERIZATION FROM GLOBAL AND SPLIT OPTIONS, OR DEFAULTS --------

# Set data masks and log interpolation globally
from libfromage.data import Data
Data.set_options(data_mask=True)

tfin           = 8e-09        # Physical fin thickness [m]
hfin           = 4e-08        # Physical fin height [m]
wf0            = 4.301        # Workfunction

# Bias parameters
vdd_lin        = 0.05        # Linear drain bias [V]

# Set defaults for optional parameters
mystic_verbose = False

# Set Mystic project and output label for this stage of the flow
# Name of target data project in database
targetDataProject = "@node|UploadData@" 

modstr    = "mosmod."
#--------------------------- MYSTIC EXECUTION SCRIPT ---------------------------

# Store the initial model to the project
# This will always be the first stage here, so set overwrite to True
mdb.StoreInitialModel(Model, overwrite=True)

Simulator.spiceargs = ["-C"]

# Optimizer settings
Optimizer.SetMethod("least_squares")
Optimizer.SetOptimizationParameter("method", "trf")
Optimizer.SetOptimizationParameter("ftol", 1e-7)
Optimizer.SetOptimizationParameter("xtol", 1e-7)
Optimizer.SetOptimizationParameter("gtol", 1e-7)
Optimizer.SetOptimizationParameter("jac", True)


Model.SetModelParameter(f'{modstr}TFIN',tfin)
Model.SetModelParameter(f'{modstr}HFIN',hfin)
Model.SetModelParameter(f'{modstr}PHIG',wf0)
Model.SetModelParameter('r_sc',0)
Model.SetModelParameter('r_dc',0)

# Some strategy defaults
Model.SetModelParameter(f'{modstr}ETA0', 0.0)
Model.SetModelParameter(f'{modstr}DVTP1',1.0)
Model.SetModelParameter(f'{modstr}CGSL', 1e-20)

IdVg = mdb.Load(dvar='idrain',  ivar='vgate', 
                  project=targetDataProject, combine=True).resample(step=0.025)
IdVgld        = IdVg.FilterData('eq', vdd_lin, dtype="bias.drain")

vt_gm_val = float(IdVgld.VtGmMaxFinal())

# Apply filters
IdVgld         = IdVgld.FilterData('lt', -1e-13, dtype="dvar", mask=False)
IdVgld_BelowVt = IdVgld.FilterData('le', vt_gm_val-0.05, dtype="ivar")
IdVgld_AboveVt = IdVgld.FilterData('ge', vt_gm_val+0.05, dtype="ivar")

IdVgld._name = "IdVgld"
IdVgld.interactive = True

# Set up parameters
phigval = Model.GetModelParameter(f'{modstr}PHIG')
PHIG    = OptParam(f'{modstr}PHIG',   phigval, phigval-0.5, phigval+0.5, 1.0)
CDSC    = OptParam(f'{modstr}CDSC',   0.001,   0.0,   10.0,  1.0)
U0      = OptParam(f'{modstr}U0',     0.02,    0.006, 1.0,   0.02)
UA      = OptParam(f'{modstr}UA',     0.3,     0.0,   100.0, 1.0)
ETAMOB  = OptParam(f'{modstr}ETAMOB', 2.0,     0.0,   10.0,  2.0)
EU      = OptParam(f'{modstr}EU',     2.5,     0.1,   10.0,  2.0)
UD      = OptParam(f'{modstr}UD',     0.1,     0.0,   1.0,   0.1)
UCS     = OptParam(f'{modstr}UCS',    1.0,     0.0,   10.0,  1.0)

Simulator.set_options(gmin=1e-18)

Stage1Parameters = [PHIG,CDSC]
Stage2Parameters = [U0,UA,EU,UD,UCS,ETAMOB]
Stage3Parameters = [PHIG,CDSC,U0,UA,EU,UD,ETAMOB,UCS]

fit_error=ExtractionUtils.PrintErrors("Initial", IdVgld, Simulator, Model, 
            plot_style={"fit":{"colour":"#0000ff"}})
IdVgld.WritePLTFile("@pwd@/@nodedir@/n@node@-IdVg-ld-init")

x=0
while (x < 5 and fit_error>2.0):
    ExtractionUtils.DoStage("Step1", Model, Simulator, Stage1Parameters,                             
                            Optimizer, [IdVgld_BelowVt],verbose=mystic_verbose)
    ExtractionUtils.DoStage("Step2", Model, Simulator, Stage2Parameters,                             
                            Optimizer, [IdVgld_AboveVt],verbose=mystic_verbose)
    ExtractionUtils.DoStage("Step3", Model, Simulator, Stage3Parameters,                             
                            Optimizer, [IdVgld_BelowVt,IdVgld_AboveVt], [1,2], verbose=mystic_verbose)
    fit_error=ExtractionUtils.PrintErrors("IdVgld", IdVgld, Simulator, Model)
    x+=1

ExtractionUtils.PrintErrors("IdVgld", IdVgld, Simulator, Model)

IdVgld.WritePLTFile('@pwd@/@nodedir@/n@node@-idvg-ld')
Optimizer.write_parameter_csv("@pwd@/@nodedir@/n@node@-IdVg-ld-parameters")
mdb.StoreFitData(IdVgld, Model, error=fit_error)
