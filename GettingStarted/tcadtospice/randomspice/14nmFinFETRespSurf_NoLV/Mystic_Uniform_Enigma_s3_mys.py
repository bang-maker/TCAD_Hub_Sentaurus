import patch
# ----------- PARAMETERIZATION FROM GLOBAL AND SPLIT OPTIONS, OR DEFAULTS -----------

# Device split parameters
gate_length       = @lgate@			# Physical gate length [m]
tfin              = @tfin@			# Physical fin thickness [m]
hfin              = @hfin@			# Physical fin height [m]
wf0               = @workfn@			# Workfunction

# Bias parameters
vdd_nom           = @Vdd_nom@			# Supply voltage [V]
vdd_cgg           = 0.0

# Simulation parameters
mystic_verbose    = False

# Set Mystic project and output label for this stage of the flow
targetDataProject = "@node|UploadData@"		# Name of Enigma project in database

# Terminal mapping
drain_con 	= "@acdrain_con@".lower()
gate_con 	= "@acgate_con@".lower()
source_con	= "@acsource_con@".lower()
bulk_con	= "@acbulk_con@".lower()

modstr		= "mosmod."
# ---------------------------- MYSTIC EXECUTION SCRIPT -----------------------------

Simulator.SetAdditionalSpiceArguments(['-C'])
   
# Use mean percentage error over the range of data
ErrorMethod = "rmsd"
Optimiser.SetOptimisationParameter("jac", True)
eps=1e-5
Optimiser.SetOptimisationParameter("eps1",eps)
Optimiser.SetOptimisationParameter("eps2",eps)
Optimiser.SetOptimisationParameter("eps3",eps)
Optimiser.SetOptimisationParameter("eps4",eps)
Optimiser.SetOptimisationParameter("eps5",eps)
Optimiser.SetOptimisationParameter("eps6",eps)
Optimiser.SetOptimisationParameter("jacobian_eps",1e-3)
Optimiser.SetOptimisationParameter("kwargs",{"eps":1e-3,"step_type":"abs","step_method":"cd"})

# Load the data/model from the previous stage
Model = mdb.GetFitModel()
# ------------------------------------------------------------------- #
Model.SetModelParameter(f'{modstr}cgso',1e-10)
Model.SetModelParameter(f'{modstr}cgdo',1e-10)
Model.SetModelParameter(f'{modstr}cgsl',1e-10)
Model.SetModelParameter(f'{modstr}cgdl',1e-10)
     
# Load data
CV_raw  =mdb.Load(dvar=f'c({gate_con},{gate_con})', project=targetDataProject).resample(step=0.05)

# Filter out high-drain C-V data as only low-drain C-V data is required for extraction
CV_raw_ld	= 	CV_raw.FilterData(		'eq', 	vdd_cgg, 	dtype=f"bias.{drain_con}")

# Filter out extra data
#if "@Type@" == "nMOS"
AboveAccu = 	('ge', -0.15, "ivar")
BelowInv1  = 	('le', 0.1,   "ivar")
BelowInv2  = 	('le', 0.2,   "ivar")
AboveInv  = 	('ge', 0.3,   "ivar")
HighGate  = 	('le', 1.0,   "ivar")
#else if "@Type@" == "pMOS"
AboveAccu = 	('le', 0.1,  "ivar")
BelowInv1  = 	('ge', -0.1, "ivar")
BelowInv2  = 	('ge', -0.2, "ivar")
AboveInv  = 	('le', -0.3, "ivar")
HighGate  = 	('ge', -1.0, "ivar")
#endif


CV_filtered_ld = CV_raw_ld.FilterData(*HighGate)
CV_BelowInv1_ld = CV_filtered_ld.FilterData(*BelowInv1)
CV_BelowInv2_ld = CV_filtered_ld.FilterData(*BelowInv2)
CV_AboveInv_ld = CV_filtered_ld.FilterData(*AboveInv)

# Set up C-V parameters 
cgso     = OptParam(		f'{modstr}cgso',	1e-11,	1e-20,	1e-8,	1e-10)
cgdo     = LinkedOptParam(f'{modstr}cgdo',cgso)
qmtcencv = OptParam(		f'{modstr}qmtcencv',	0.5,	1e-3,	20,	1.0) 
ckappas  = OptParam(		f'{modstr}ckappas',	0.6,	0.05,	200,	0.2)
ckappad  = LinkedOptParam(f'{modstr}ckappad',ckappas) 
qm0      = OptParam(		f'{modstr}qm0',		0.001,	1e-4,	10,	1.0) 
cgsl     = OptParam(		f'{modstr}cgsl',	1e-11,	1e-20,	1e-8,	1e-10)
cgdl     = LinkedOptParam(f'{modstr}cgdl',cgsl)
deltawcv = OptParam(		f'{modstr}deltawcv',	0,	-30e-9, 30e-9,	1e-8)

# Set up parameter sets
CVParameters_BelowInv_1    	= [cgso,cgdo]
CVParameters_BelowInv_2 	= [ckappas,cgsl,cgdl]
CVParameters_AboveInv    	= [deltawcv,qmtcencv,qm0]
AllPars                  	= [cgso,cgdo,ckappas,ckappad,cgsl,cgdl,deltawcv,qmtcencv,qm0]

x=0
fit_error=1e9
# Run extraction
while (x<2 and fit_error>1):
    for j in range(1): ExtractionUtils.DoStage("CV_step1", Model, Simulator, CVParameters_BelowInv_1, Optimiser, [CV_BelowInv1_ld])
    for j in range(1): ExtractionUtils.DoStage("CV_step2", Model, Simulator, CVParameters_BelowInv_2, Optimiser, [CV_BelowInv2_ld])
    for j in range(1): ExtractionUtils.DoStage("CV_step3", Model, Simulator, CVParameters_AboveInv, Optimiser, [CV_AboveInv_ld])
    fit_error = ExtractionUtils.PrintErrors("CV_step3_error", CV_filtered_ld, Simulator, Model, ErrorMethod)
    x+=1

for j in range(3): ExtractionUtils.DoStage("CV_step4", Model, Simulator, AllPars, Optimiser, [CV_filtered_ld])

print("\n Final Errors: ")
fit_error = ExtractionUtils.PrintErrors("CV_step4_error", CV_filtered_ld, Simulator, Model, ErrorMethod)


# Store fit data and parameters in database
mdb.StoreFitData(CV_filtered_ld, Model, error=fit_error)

Optimiser.write_parameter_csv('@pwd@/@nodedir@/n@node@-cv-pars')
CV_filtered_ld.WritePLTFile('@pwd@/@nodedir@/n@node@-cv')

