# load TDR file
set mydata2D [load_file @pwd@/npn_msh.tdr]
# create new plot
set myplot2D [create_plot -dataset $mydata2D]

# create 1D cutline normal to X-axis at point x=-0.005
set mydata1D [create_cutline -plot $myplot2D -type x -at -0.005]

export_variables {DopingConcentration xMoleFraction Y} \
    -dataset $mydata1D -filename "n@node@_data.csv" -overwrite

exit
