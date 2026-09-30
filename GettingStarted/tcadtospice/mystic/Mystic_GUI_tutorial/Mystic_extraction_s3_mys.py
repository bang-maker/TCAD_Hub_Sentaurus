
from libfromage.data import Data
Data.set_options(data_mask=True)

# Bias parameters
vdd_nom           = 0.8                    # Supply voltage [V]
vdd_lin           = 0.05                   # Supply voltage [V]
vdd_cgg           = 0.0

# Simulation parameters
mystic_verbose    = False

# Set Mystic project and output label for this stage of the flow
targetDataProject = "@node|UploadData@"      # Name of target data project in database

modstr    = "mosmod."
# ---------------------------- MYSTIC EXECUTION SCRIPT -----------------------------

Simulator.spiceargs = ["-C"]
   
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
Model.SetModelParameter(f'{modstr}cgso',1e-10)
Model.SetModelParameter(f'{modstr}cgdo',1e-10)
Model.SetModelParameter(f'{modstr}cgsl',1e-10)
Model.SetModelParameter(f'{modstr}cgdl',1e-10)
     
# Load data
CV = mdb.Load(dvar='c(gate,gate)', 
                     project=targetDataProject).resample(step=0.05)

# Filter out high-drain C-V data as only the low-drain C-V data is used
CVld = CV.FilterData('eq', vdd_cgg, dtype="bias.drain")

# Filter out extra data using the Vt of the device
IdVg      = mdb.Load(dvar='idrain', ivar='vgate',  
                           project=targetDataProject).resample(step=0.025)
IdVg_ld   = IdVg.FilterData('eq', vdd_lin, dtype="bias.drain")
vt_gm_val   = float(IdVg_ld.VtGmMaxFinal())

CV_filtered_ld  = CVld.FilterData('le', 1.0, "ivar")
CV_BelowInv1_ld = CV_filtered_ld.FilterData('le', vt_gm_val-0.1, "ivar")
CV_BelowInv2_ld = CV_filtered_ld.FilterData('le', vt_gm_val,     "ivar")
CV_AboveInv_ld  = CV_filtered_ld.FilterData('ge', vt_gm_val+0.1, "ivar")

# Set up C-V parameters
cgso     = OptParam(f'{modstr}cgso',     1e-11, 1e-20,  1e-8,  1e-10)
qmtcencv = OptParam(f'{modstr}qmtcencv', 0.5,   1e-3,   20.0,  1.0) 
ckappas  = OptParam(f'{modstr}ckappas',  0.6,   0.05,   200.0, 0.2)
qm0      = OptParam(f'{modstr}qm0',      0.001, 1e-4,   10.0,  1.0) 
cgsl     = OptParam(f'{modstr}cgsl',     1e-11, 1e-20,  1e-8,  1e-10)
deltawcv = OptParam(f'{modstr}deltawcv', 0.0,   -30e-9, 30e-9, 1e-8)

cgdo     = LinkedOptParam(f'{modstr}cgdo',cgso)
ckappad  = LinkedOptParam(f'{modstr}ckappad',ckappas) 
cgdl     = LinkedOptParam(f'{modstr}cgdl',cgsl)

CVld._name = "CVld"
CVld.interactive = True

CVParameters_BelowInv_1 = [cgso,cgdo]
CVParameters_BelowInv_2 = [ckappas,cgsl,cgdl]
CVParameters_AboveInv   = [deltawcv,qmtcencv,qm0]
AllPars                 = [cgso,cgdo,ckappas,ckappad,cgsl,cgdl,deltawcv,qmtcencv,qm0]

x=0
fit_error = ExtractionUtils.PrintErrors("Initial", CVld, Simulator, Model, plot_style={"fit":{"colour":"#0000ff"}})
CVld.WritePLTFile("@pwd@/@nodedir@/n@node@-CV-ld-init")

while (x<2 and fit_error>1.0):
    ExtractionUtils.DoStage("CV_step1", Model, Simulator, CVParameters_BelowInv_1, Optimizer, 
                            [CV_BelowInv1_ld])
    ExtractionUtils.DoStage("CV_step2", Model, Simulator, CVParameters_BelowInv_2, Optimizer, 
                            [CV_BelowInv2_ld])
    ExtractionUtils.DoStage("CV_step3", Model, Simulator, CVParameters_AboveInv, Optimizer, 
                            [CV_AboveInv_ld])
    fit_error = ExtractionUtils.PrintErrors("CV error", CV_filtered_ld, Simulator, Model)
    x+=1

for j in range(3): 
    ExtractionUtils.DoStage("CV_step4", Model, Simulator, AllPars, Optimizer, 
                            [CV_filtered_ld])

fit_error = ExtractionUtils.PrintErrors("CV error", CV_filtered_ld, Simulator, Model)

# Store fit data and parameters in the database
mdb.StoreFitData(CVld, Model, error=fit_error)

CVld.WritePLTFile("@pwd@/@nodedir@/n@node@-CV-ld")
Model.write("@pwd@/@nodedir@/n@node@-final.mod")
Optimizer.write_parameter_csv("@pwd@/@nodedir@/n@node@-CV-parameters")


