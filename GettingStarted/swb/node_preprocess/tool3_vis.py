#set result3 -1
dummy='''
@param1@
@param2@
@param3:+2@
@param2|-1:+2@
@param1:all@
@param1|-2:all@
!(
puts [lsort -unique [list @param1:all@]]
)!
'''

xvar = 10*@result2@
print(f'DOE: result3 {xvar:.3e}')