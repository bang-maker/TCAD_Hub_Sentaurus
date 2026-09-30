#setdep @node|Mapping@

############################################################
################### Inputs (target data) ###################
############################################################

# Get the DoE coordinate of this point
doe = {"@axis1@": @lgate@,
       "@axis2@": @hfin@,
       "@axis3@": @tfin@,
       "@axis4@": @afin@,
       "@axis5@": @tspacer@ }

# Check whether you are at a midpoint
if (doe["@axis1@"] == @axis1_midpoint@) and \
    (doe["@axis2@"] == @axis2_midpoint@) and \
    (doe["@axis3@"] == @axis3_midpoint@) and \
    (doe["@axis4@"] == @axis4_midpoint@) and \
    (doe["@axis5@"] == @axis5_midpoint@):
    midpoint = True
    print("DOE: midpoint True")
else:
    midpoint = False
    print("DOE: midpoint False")
   
# Update project metadata
node_prj.add_metadata(doe=doe, midpoint=midpoint)

### ---------------------------------------------------------------- ###
ds = dbi.create_dataset(node_prj, "ivs", clean=True)

metadata={"temperature": @temp@,
          "instances": {"l": @lgate@}}

upload_data_iv = ["@ppwd@/IdVg_0_n@pnode|IdVg@_des.plt",
                  "@ppwd@/IdVg_1_n@pnode|IdVg@_des.plt",
                  "@ppwd@/IdVd_0_n@pnode|IdVd@_des.plt",
                  "@ppwd@/IdVd_1_n@pnode|IdVd@_des.plt",
                  "@ppwd@/IdVd_2_n@pnode|IdVd@_des.plt"]

Data.from_plt(upload_data_iv, 
              metadata=dict(metadata, nodes=["@drain_con@", "@gate_con@",
                                             "@source_con@", "@bulk_con@"]),
              upload_ds=ds)

upload_data_cv = ["@ppwd@/C_0_n@pnode|CV@_ac_des.plt",
                  "@ppwd@/C_1_n@pnode|CV@_ac_des.plt"]

Data.from_plt(upload_data_cv,
              metadata=dict(**metadata, nodes=["@acdrain_con@", "@acgate_con@",
                                               "@acsource_con@",
                                               "@acbulk_con@"]),
              upload_ds=ds)
