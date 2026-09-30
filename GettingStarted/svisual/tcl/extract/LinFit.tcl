load_library extract
lib::SetInfoDef 1

set Xs [list 20 60 100 140 180 220 260 300 340 380]
set Ys [list 0.18 0.37 0.35 0.78 0.56 0.75 1.18 1.36 1.17 1.65]

ext::LinFit -out XY -x $Xs -y $Ys -xmin [lindex $Xs 0] -xmax [lindex $Xs end]

puts "Estimated slope: $XY(slope)"
puts "Estimated y-intercept: $XY(yintercept)"
puts "Root-MSE: $XY(RMSE)"

#-> Estimated slope: 0.00383
#-> Estimated y-intercept: 0.06924
#-> Root-MSE: 0.159