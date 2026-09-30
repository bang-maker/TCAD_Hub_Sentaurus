load_library ifm

set Vs [list 1 2 3 4 5]
ifm::GetMoments -out Moments -rvs $Vs

puts $Moments(norm)
#-> 5

puts $Moments(ave)
#-> 3

puts $Moments(rms)
#-> 3.31662479036

puts $Moments(std_dev)
#-> 1.41421356237

puts $Moments(skew)
#-> 0.0

puts $Moments(kurtx)
#-> -1.3