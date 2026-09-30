#####################################################################
### The garand object is injected into the environment by         ###
### gpythonsh. A small amount of setup is required before usage.  ###
#####################################################################
# Set full path to Garand VE input file 
garand.inputfile  = open(os.path.join("@pwd@", "@nodedir@",
                                      "pp@node@_eng.garinp"))
garand.clear_data = True
garand.wait       = True

#####################################################################
### Because of the simple structure of the Garand VE input file,  ###
### you can directly alter the options of the Garand VE           ###
### simulation. The attribute inputfile is set up like a Python   ###
### dictionary with key-value pairs; therefore, access or         ###
### substitution to all Garand VE inputs inside the file is       ###
### very easy.                                                    ###
#####################################################################
garand.inputfile["STRUCTURE  IMPORT  filename"] = "@pwd@/@tdr@"
garand.inputfile["BIAS delta"] = @<Vdd_nom/7>@
garand.inputfile["BIAS ivpoints"]=8
if @TDR@:
    garand.inputfile["OUTPUT tdr"] = "on"

#####################################################################
### You can now execute Garand VE with the bias settings in the   ###
### input file already attached to this tool instance             ###
#####################################################################
if @RDD@:
    print("RDD is enabled.")
    garand.inputfile["VARIABILITY RDD status"] = "on"

if @LER@:
    print("LER is enabled.")
    garand.inputfile["VARIABILITY LER status"] = "on"
    garand.inputfile["VARIABILITY LER rms"] = @LER_rms@

if @MGG@:
    print("MGG is enabled.")
    garand.inputfile["VARIABILITY MGG status"] = "on"
    garand.inputfile["VARIABILITY MGG diameter"] = @MGG_dia@

if @VT_only@:
    print("VT only simulation enabled. Running VT search algorithm.")
    garand.inputfile["SIMULATION sim_type "] = "target"
    garand.inputfile["SIMULATION target_current"] = @VT_current_criterion@
    garand.inputfile["SIMULATION target_acc"] = 1e-4
    garand.inputfile["SIMULATION target_iter_max"] = 25
    garand.inputfile["SIMULATION target_init_slope"] = 70

# Execute Garand VE full IdVg at low drain bias for an ensemble of devices
garand.simulate({"bias drain": @Vdd_lin@}, start=1, n=@ensemble_size@)
