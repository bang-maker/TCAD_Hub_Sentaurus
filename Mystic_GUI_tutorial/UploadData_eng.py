############################################################
################### Inputs (target data) ###################
############################################################
ds = dbi.create_dataset(node_prj, "ivs", clean=True)

metadata = {"temperature": 300,
            "nodes": ["drain","gate","source","substrate"]}

upload_data_iv = ["targets/IdVg_ld.plt",
                  "targets/IdVg_hd.plt",
                  "targets/IdVd_a.plt",
                  "targets/IdVd_b.plt",
                  "targets/IdVd_c.plt"]

Data.from_plt(upload_data_iv, metadata=metadata, upload_ds=ds) 


upload_data_cv = ["targets/CV_a.plt", "targets/CV_b.plt"]

Data.from_plt(upload_data_cv, metadata=metadata, upload_ds=ds) 


