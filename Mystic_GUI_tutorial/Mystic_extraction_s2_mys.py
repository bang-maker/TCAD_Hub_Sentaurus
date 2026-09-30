
from libfromage.data import Data
Data.set_options(data_mask=True)

# Bias parameters
vdd_nom           = 0.8                    # Supply Voltage [V]
vdd_lin           = 0.05                    # Linear drain bias [V]

# Simulation parameters
mystic_verbose    = False

# Set Mystic project and output label for this stage of the flow
targetDataProject = "@node|UploadData@"   # Name of target data project in database

modstr        = "mosmod."

# ---------------------------- MYSTIC EXECUTION SCRIPT -----------------------------
Simulator.spiceargs = ['-C']

# Optimizer settings
Optimizer.SetMethod("least_squares")
Optimizer.SetOptimizationParameter("method", "trf")
Optimizer.SetOptimizationParameter("ftol", 1e-7)
Optimizer.SetOptimizationParameter("xtol", 1e-7)
Optimizer.SetOptimizationParameter("gtol", 1e-7)
Optimizer.SetOptimizationParameter("jac", True)

# Load the model from the previous stage
Model = mdb.GetFitModel()
# ------------------------------------------------------------------- #
IdVg     = mdb.Load(dvar="idrain", ivar="vgate", 
                  project=targetDataProject, combine=True).resample(step=0.025)
IdVd     = mdb.Load(dvar="idrain", ivar="vdrain", 
                  project=targetDataProject, combine=True).resample(step=0.025)    

IdVg     = IdVg.FilterData('lt', -1e-13,  dtype="dvar", mask=False)
IdVgld   = IdVg.FilterData('eq', vdd_lin, dtype="bias.drain")
IdVghd   = IdVg.FilterData('eq', vdd_nom, dtype="bias.drain")

IdVg._name = "IdVg"
IdVg.interactive = True

IdVd._name = "IdVd"
IdVd.interactive = True

# Calculate VtGmMax
vt_gm_val = float(IdVgld.VtGmMaxFinal())

IdVgld_BelowVt = IdVgld.FilterData("gt", vt_gm_val+0.02, dtype="ivar")
IdVgld_AboveVt = IdVgld.FilterData("lt", vt_gm_val+0.02, dtype="ivar")
IdVghd_BelowVt = IdVghd.FilterData("gt", vt_gm_val+0.02, dtype="ivar")
IdVghd_AboveVt = IdVghd.FilterData("lt", vt_gm_val+0.02, dtype="ivar")

IdVd_vdd = IdVd.FilterData('eq', vdd_nom, dtype="bias.gate")

# Ion and Ioff FoM targets
Ion_sat     = IdVghd.MakeFoMTarget('ion',  vdd_nom)
Ioff_sat    = IdVghd.MakeFoMTarget("ioff", -0.1)

# Set up parameters
phigval  = Model.GetModelParameter(f'{modstr}PHIG')
PHIG     = OptParam(f'{modstr}PHIG',   phigval, phigval-0.5, phigval+0.5, 1.0)
ETA0     = OptParam(f'{modstr}ETA0',   2.0,    0.0,   100,    0.1)
CDSC     = OptParam(f'{modstr}CDSC',   7e-3,   0.0,   10.0,   1.0)
CDSCD    = OptParam(f'{modstr}CDSCD',  7e-3,   0.0,   1.0,    1.0)
U0       = OptParam(f'{modstr}U0',     0.02,   0.001, 10.0,   0.001)
UA       = OptParam(f'{modstr}UA',     0.3,    0.0,   100.0,  0.01)
ETAMOB   = OptParam(f'{modstr}ETAMOB', 2.0,    0.0,   100,    2.0)
EU       = OptParam(f'{modstr}EU',     2.5,    0.1,   10.0,   0.1)
VSAT     = OptParam(f'{modstr}VSAT',   100000, 20000, 600000, 10000)
PTWG     = OptParam(f'{modstr}PTWG',   0.0,    0.0,   100.0,  0.1)
KSATIV   = OptParam(f'{modstr}KSATIV', 1.0,    -5.0,  5.0,    1.0)
MEXP     = OptParam(f'{modstr}MEXP',   4.0,    2.0,   10.0,   4.0)
PVAG     = OptParam(f'{modstr}PVAG',   1.0,    0.0,   100.0,  1.0)
PDIBL2   = OptParam(f'{modstr}PDIBL2', 1e-3,   1e-16, 1.0,    0.0001)
DVTP0    = OptParam(f'{modstr}DVTP0',  -0.01,  -0.5,  0.1,    0.005)
UD       = OptParam(f'{modstr}UD',     0.1,    0.0,   1.0,    0.1)
UCS      = OptParam(f'{modstr}UCS',    1.0,    0.0,   10.0,   1.0)

Simulator.set_options(gmin=1e-18)

Stage1aParameters = [DVTP0]
Stage1bParameters = [CDSCD]
Stage1Parameters  = [DVTP0,CDSCD]
Stage2aParameters = [VSAT]
Stage2Parameters  = [KSATIV,MEXP,PVAG,PDIBL2,DVTP0,CDSCD]
Stage3Parameters  = [PHIG,KSATIV,MEXP,PVAG,CDSC,U0,ETAMOB,EU,UA,DVTP0,PDIBL2,VSAT]

IdVg_error = ExtractionUtils.PrintErrors("Initial", IdVg, Simulator, Model, 
                                         plot_style={"fit":{"colour":"#0000ff"}})
IdVd_error = ExtractionUtils.PrintErrors("Initial", IdVd, Simulator, Model,
                                         plot_style={"fit":{"colour":"#0000ff"}})

IdVg.WritePLTFile('@pwd@/@nodedir@/n@node@-IdVg-hd-init')
IdVd.WritePLTFile('@pwd@/@nodedir@/n@node@-IdVd-hd-init')

x=0.0

while (x < 5 and  (IdVg_error > 3.5 or IdVd_error > 3.5)):
    ExtractionUtils.DoStage("HD_step1", Model, Simulator, Stage1aParameters, Optimizer, [Ioff_sat], verbose=mystic_verbose)
    ExtractionUtils.DoStage("HD_step2", Model, Simulator, Stage1bParameters, Optimizer, [IdVghd_BelowVt], verbose=mystic_verbose)
    ExtractionUtils.DoStage("HD_step3", Model, Simulator, Stage1Parameters, Optimizer, [IdVghd_BelowVt], verbose=mystic_verbose)
    ExtractionUtils.DoStage("HD_step4", Model, Simulator, Stage2aParameters, Optimizer, [Ion_sat], verbose=mystic_verbose)
    ExtractionUtils.DoStage("HD_step5", Model, Simulator, Stage2Parameters, Optimizer, [IdVghd,IdVd], verbose=mystic_verbose)
    IdVg_error = ExtractionUtils.PrintErrors("IdVg", IdVg, Simulator, Model)
    IdVd_error = ExtractionUtils.PrintErrors("IdVd", IdVd, Simulator, Model)
    x+=1

ExtractionUtils.DoStage("HD_step6", Model, Simulator, Stage3Parameters, Optimizer, 
                        [IdVg,IdVd,IdVd_vdd], [1,1,2],verbose=mystic_verbose)

IdVg_error = ExtractionUtils.PrintErrors("IdVg", IdVg, Simulator, Model)
IdVd_error = ExtractionUtils.PrintErrors("IdVd", IdVd, Simulator, Model)

mdb.StoreFitData(IdVg, Model, error=IdVg_error)
mdb.StoreFitData(IdVd, Model, error=IdVd_error)

IdVg.WritePLTFile('@pwd@/@nodedir@/n@node@-idvg-hd')
IdVd.WritePLTFile('@pwd@/@nodedir@/n@node@-idvd-hd')

Optimizer.write_parameter_csv('@pwd@/@nodedir@/n@node@-idvg-hd-parameters')


