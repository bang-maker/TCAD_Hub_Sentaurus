load_library ifm

set RanVals [list -1.657 0.7661 2.142 1.189 -1.919 -0.6670 -0.1915 0.3662]

ifm::GetDataQuantiles -out DataQ -rvs $RanVals
ifm::GetMoments -out Moments -rvs $RanVals
ifm::GetGaussian -out GaussianQ -type q -moments Moments \
    -nsam 40 -xmin -3.5 -xmax 3.5
ifm::GetQQ -out QQ -dq DataQ -gq GaussianQ -moments Moments

create_variable -name "QQX" -dataset QQXY -values $QQ(X)
create_variable -name "QQY" -dataset QQXY -values $QQ(Y)

create_plot -1d -name QQplot
select_plots QQplot
create_curve -name qq -dataset QQXY -axisX "QQX" -axisY "QQY"