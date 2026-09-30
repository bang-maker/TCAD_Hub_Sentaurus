#####################################################################
### The garand object is injected into the environment by         ###
### gpythonsh. A small amount of setup is required before usage.  ###
#####################################################################
# Set full path to Garand VE input file 
garand.inputfile = open(os.path.join("@pwd@","@nodedir@","pp@node@_eng.garinp"))
garand.clear_data= False
garand.wait      = True

#####################################################################
### Because of the simple structure of the Garand VE input file,  ###
### you can directly alter the options of the Garand VE           ###
### simulation. The attribute inputfile is set up like a Python   ###
### dictionary with key-value pairs; therefore, access or         ###
### substitution to all Garand VE inputs inside the file is       ###
### very easy.                                                    ###
#####################################################################
garand.inputfile["STRUCTURE  IMPORT  filename"] = "@pwd@/@tdr@"
garand.inputfile["BIAS delta"] = @<Vdd_nom/8>@
garand.inputfile["BIAS ivpoints"]=9

#####################################################################
### You can now execute Garand VE with the bias settings in the   ###
### input file already attached to this tool instance             ###
#####################################################################
garand.simulate({"bias drain": @Vdd_lin@}) # Run Garand VE full IdVg at low Vd
garand.simulate({"bias drain": @Vdd_nom@}) # Run Garand VE full IdVg at high Vd
