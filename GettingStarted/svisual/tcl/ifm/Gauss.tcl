load_library ifm

set Moments(norm) 1.0
set Moments(ave) 0.0
set Moments(std_dev) 1.0

# Compute the y-value of a normalized Gaussian distribution for given x-value
ifm::Gauss -out G -x 0.1 -moments Moments
puts "The result is $G"	