#####################################################################
### The garand object is injected into the environment by         ###
### gpythonsh. A small amount of setup is required before usage.  ###
#####################################################################
# Set full path to Garand VE input file 
garand.inputfile = open(os.path.join("@pwd@","@nodedir@","pp@node@_eng.garinp"))
garand.clear_data= False
garand.wait      = True          


garand.inputfile["STRUCTURE  IMPORT  filename"] = "@pwd@/@tdr@"
garand.inputfile["BIAS delta"] = @<Vdd_nom/8>@
garand.inputfile["BIAS ivpoints"]=9
garand.inputfile["SIMULATION sim_type"] = "IdVd"

#####################################################################
### You can now execute Garand VE with the bias settings in the   ###
### input file already attached to this tool instance             ###
#####################################################################
#if "@Type@" == "pMOS"
gate_bias_list=[@<Vdd_nom+0.3>@, @<Vdd_nom+0.15>@, @Vdd_nom@]
#else
gate_bias_list=[@<Vdd_nom-0.3>@, @<Vdd_nom-0.15>@, @Vdd_nom@]
#endif

for vg in gate_bias_list:
    # Execute Garand VE with a different Vg every time
    garand.simulate({"bias gate": vg})    

garand.Wait() 
