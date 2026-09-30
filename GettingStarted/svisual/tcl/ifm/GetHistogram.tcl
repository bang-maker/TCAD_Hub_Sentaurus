load_library ifm

set Rxs [list 1 1.1 2 5 5.1 5.3 6]
ifm::GetHistogram -out Histogram -rvs $Rxs -xmin 0 -xmax 6 -nbin 6

create_variable -name "X" -dataset XY -values $Histogram(X)
create_variable -name "Y" -dataset XY -values $Histogram(Y)

create_plot -1d -name Histogram
select_plots Histogram
create_curve -name hist -dataset XY -axisX "X" -axisY "Y"