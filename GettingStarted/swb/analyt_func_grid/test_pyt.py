x = @x@
y = @y@

value = (x**2+y-11)**2 + (x+y**2-7)**2
constraint = x - y

print(f"DOE: error {value}")
print(f"DOE: constr {constraint}")
