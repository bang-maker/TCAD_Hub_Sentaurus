load_library extract

# Create a list of 11 linearly spaced values between 0 and 1 
ext::Linspace -out X -xmin 0 -xmax 1 -n 11

puts "Xs: $X"
#-> Xs: 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1