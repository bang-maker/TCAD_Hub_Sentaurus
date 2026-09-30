load_library ifm

set Moments(norm) 1.0
set Moments(ave) 0.0
set Moments(std_dev) 1.0

ifm::GetGaussian -out Gaussian -type f -moments Moments \
    -nsam 100 -xmin -3.5 -xmax 3.5
    
create_plot -1d -name Gaussian
select_plots Gaussian    
create_variable -name "GX" -dataset GXY -values $Gaussian(X)
create_variable -name "GY" -dataset GXY -values $Gaussian(Y)
create_curve -name gauss -dataset GXY -axisX "GX" -axisY "GY"