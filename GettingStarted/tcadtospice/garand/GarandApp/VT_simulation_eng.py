#####################################################################
### The garand object is injected into the environment by         ###
### gpythonsh. A small amount of setup is required before usage.  ###
#####################################################################
# Set full path to Garand VE input file 

garand.inputfile = open(os.path.join("@pwd@","@nodedir@","pp@node@_eng.garinp"))
garand.clear_data= False
garand.wait      = True

VT_init = 0.0  # Initial Vg value for the VT search algorithm 

#####################################################################
### Because of the simple structure of the Garand VE input file,  ###
### you can directly alter the options of the Garand VE           ###
### simulation. The attribute inputfile is set up like a Python   ###
### dictionary with key-value pairs; therefore, access or         ###
### substitution to all Garand VE inputs inside the file is       ### 
### very easy.                                                    ###
#####################################################################
garand.inputfile["STRUCTURE  IMPORT  filename"] = "@pwd@/@tdr@"
garand.inputfile["SIMULATION sim_type "]         = "target" 
garand.inputfile["SIMULATION target_current"]    = @VT_current_criterion@
garand.inputfile["SIMULATION target_acc"]        = 1e-4
garand.inputfile["SIMULATION target_iter_max"]   = 25
garand.inputfile["SIMULATION target_init_slope"] = 70

#####################################################################
### You can now execute Garand VE with the bias settings in the   ###
### input file already attached to this tool instance             ###
#####################################################################
# Run Garand VE VT search, at low VD, starting VT search from Vg=0.0

garand.simulate({"BIAS drain": @Vdd_lin@, "BIAS gate": VT_init}) 


