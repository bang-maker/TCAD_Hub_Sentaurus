#setdep @node|UploadData@
# Extract "UploadData" project from the database

UploadData_prj	= dbi.get_project("@node|UploadData@")

print("*"*32)
print(f"Upload data DB name: {UploadData_prj.name}")
print("*"*32)
print(f"Upload data metadata: {UploadData_prj.metadata}")
print("*"*32)

# Load simple Id-Vg data from the UploadData node
idvg = Data.from_db(project="@node|UploadData@",\
                    ivar="v@gate_con@", dvar="i@drain_con@")

print("*"*32)
print(idvg)
print("*"*32)
#--------------------------------------------------------------------------------------------#
# Gather data from multiple nodes
# In this example, all data is loaded where:
#    - simulation is IdVd
#    - MOSFET type is nMOS
#    - Sentaurus Workbench parameter W is 0.008

projects   = dbi.get_project(swb__Type="nMOS", swb__W=0.008)
projects   = [p.name for p in projects]
idvd_vg0p6 = Data.from_db(project=projects, ivar="v@drain_con@",\
                          dvar="i@drain_con@", bias={f"@gate_con@":0.6})

print("*"*32)
print(idvd_vg0p6)
print(len(idvd_vg0p6))
print("*"*32)


