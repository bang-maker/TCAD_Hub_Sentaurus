print('--------------------------------------------------------------------')
print('1. Getting Started')
print('--------------------------------------------------------------------')

print('\n-------------------------------')
print('1.2 Using the Python Interpreter')
print('-------------------------------')
import sys
sys.version

1 + 2
'Hello, TCAD Users!'

print(1 + 2)
print('Hello, TCAD Users!')

from add import *
print(z)

print('\n-------------------------------')
print('1.3.3.1 Simple Statements and Indentation')
print('-------------------------------')
# Following statements have no space to the left
x = 1       # assignment statement
y = 2
z = x + y
print(z)    # print statement

print('\n-------------------------------')
print('1.3.3.2 Compound Statements and Indentation')
print('-------------------------------')
def add(x, y):      # header line: 0 space
    result = x + y  # function body: 4 spaces
    return result   # function body: 4 spaces
    
    
print('\n-------------------------------')
print('1.3.3.3 Multiple Simple Statements on One Line')
print('-------------------------------')    
x = 1; y = 2; z = x + y; print(z)

print('\n-------------------------------')
print('1.3.3.4 Line Continuation')
print('-------------------------------')    
my_list = [11, 22, 33, 44, 55, 66, 77, 88]

# Line Continuation using \
my_list = [11, 22, 33, 44, \
           55, 66, 77, 88]
           
# Implied continuation inside brackets   
my_list = [
    11, 22, 33, 44,
    55, 66, 77, 88, 
]
my_list

# Breaking long lines using parentheses
x = (    
    11 + 22
    + 33 + 44
    + 55 + 66
)
x

x = (
11 + 22
   + 33 + 44
       + 55 + 66
)
x

print('\n--------------------------------------------------------------------')
print('1.4 Online Help')
print('--------------------------------------------------------------------')
# help(print)  # help on built-in print function
# help(int)    # help on int object

import math  # Import math module
# Get list of variables and functions defined in math module
print(dir(math))  
# help(math)  # help on math module
# help(math.sin) # help on sine function in math module

print('\n--------------------------------------------------------------------')
print('2. Python Statements, Objects, and Loops')
print('--------------------------------------------------------------------')

print('\n-------------------------------')
print('2.2 Built-in Data Types')
print('-------------------------------')

print('\n-------------------------------')
print('2.2.1 Numeric Types: int, float, and complex')
print('-------------------------------')
3000  # create integer
type(3000)

3000.0  # create float using decimal point
type(3000.0)  # type of 3000.0 is float

3.0e3  # Create float using scientific notation

1j    # Create imaginary unit
3e2j  # Create purely imaginary number
300 + 3e2j  # Create complex number
type(3e2j)
type(300 + 3e2j)
0 + 1j

print('\n-------------------------------')
print('2.2.2 Boolean Type')
print('-------------------------------')
False
True
type(True)  # type of True is bool

print('\n-------------------------------')
print('2.2.3 NoneType')
print('-------------------------------')
None
type(None)
print(None)

print('\n-------------------------------')
print('2.2.5.1 Strings')
print('-------------------------------')
'Hello, World'
"Hello, World"
type('Hello, World')

"That\'s not what I said!"
"That's not what I said!" 

'''This is  
a multiline string
'''

print('''This is  
a multiline string
'''
)

print('\n-------------------------------')
print('2.2.5.2 Lists and Tuples')
print('-------------------------------')
[1, 2.4, True, None, 'Python']  # create list object

(1, 2.4, True, None, 'Python')  # creating tuple with parentheses
1, 2.4, True, None, 'Python'  # creating tuple without parentheses
1 + 2, 1 * 2
[1, 2, 3]  # all values are integers
(1.0, 2.0, 3.0)  # all values are floats

print('\n-------------------------------')
print('2.2.5.3 One-Dimensional NumPy Arrays')
print('-------------------------------')
import numpy as np  # import NumPy package

# Create 1D NumPy array using a list of integers
np.array([1, 2, 3])  

# Create 1D NumPy array using a tuple of floats
np.array((1.0, 2.0, 3.0))

type(np.array([1, 2, 3, 4]))

print('\n-------------------------------')
print('2.2.5.4 Indexing Sequences')
print('-------------------------------')
len([1, 2.4, True, None, 'Python'])
len(np.array([1, 2, 3, 4]))
[10, 20, 30, 40][0]  # first element or element in position 0
[10, 20, 30, 40][1]  # second element or element in position 1
[10, 20, 30, 40][-1]  # last element  
[10, 20, 30, 40][-2]  # second-last element

np.array([1, 2, 3, 4])[0]  # first element
np.array([1, 2, 3, 4])[-1]  # last element

print('\n-------------------------------')
print('2.2.6 Introduction to Dictionaries')
print('-------------------------------')
{'x': 1, (1, 1): [10, 20]} 
type({'x': 1, (1, 1): [10, 20]})
# Use key 'x' to access value 1
{'x': 1, (1, 1): [10, 20]}['x']

print('\n--------------------------------------------------------------------')
print('2.2 Built-in Data Types')
print('--------------------------------------------------------------------')
3 + 5  # Addition
0.5 ** 2 # Exponentiation

print('\n-------------------------------')
print('2.3.1 Scalar Operations')
print('-------------------------------')
3 / 2  # Floating-point division
3 // 2  # Integer division
4 + 3 * 2  # Multiplication is performed before addition
(4 + 3) * 2  # Addition is performed before multiplication
(4 + 3) * (2) 

2 + 3.0 
(2 + 3.0) * (1 + 2j)

print('\n-------------------------------')
print('2.3.2 Using Arithmetic Operators With Sequence Types (Lists, Tuples, and Strings)')
print('-------------------------------')
[1, 2] + [3, 4]  # concatenates two lists
3 * [1, 2]  # repeats the sequence of elements 1, 2 three times
# string concatenation
'The value of pi is ' + '3.141592653589793'  
'The value of pi is ' '3.141592653589793' 

(
    '0.424 0.0374 0.313 0.263 0.414 0.408'
    ' -0.344 -0.294 -0.232 -0.182 x -0.374'
)

[0] * 5  # Create a list of length 5 filled with zeros

print('\n-------------------------------')
print('2.3.3 NumPy Array Operations')
print('-------------------------------')
# Multiply a 1D array by a scalar 
3 * np.array([1, 2])  #  performs elementwise scalar multiplication

# Add two 1D NumPy arrays 
np.array([1, 2]) + np.array([3, 4]) # performs array addition

# Multiply two 1D arrays
np.array([1, -2]) * np.array([2, 1]) # performs array multiplication

# Multiply a 1D array and a list
np.array([1, -2]) * [2, 1]

1/np.array([2, 4, 8])

np.array([2, 4, 6]) ** 2  # Squares each element of array

np.array([2, 2, 2]) ** np.array([1, 2, 3]) # elementwise exponentiation

np.zeros(3)
np.full(5, 3.141)

print('\n--------------------------------------------------------------------')
print('2.4 Variables and Assignment Statement')
print('--------------------------------------------------------------------')
# Assign value 1.6e-19 to variable electron_charge
electron_charge = 1.6e-19 
electron_charge
print(electron_charge)

print('\n-------------------------------')
print('2.4.1 Reassignment, Increment, and Augmented Assignment')
print('-------------------------------')
count = 1          # Initialize count
# Increment count by 1
count = count + 1  # Reassign count
count

count = 1          # Initialize count 
count += 1         # Equivalent to count = count + 1
count

x = 1        # Initialize x. x is an integer
x
x = 'Hello'  # Reassign x.  Now x is a string
x

print('\n-------------------------------')
print('2.4.2 Variable Names')
print('-------------------------------')
import keyword
# Get list of Python keywords using kwlist attribute
keywords = keyword.kwlist  
keywords

lambda_ = 650e-9  # Wavelength of red light in m

print('\n-------------------------------')
print('2.4.3 Printing Variables')
print('-------------------------------')
electron_charge = 1.6e-19 
print('The elementary charge is', electron_charge, 'C')
print('The elementary charge is')
print(electron_charge, 'C')

print('\n-------------------------------')
print('2.4.3.1 Formatted Strings (f-Strings) and Format Specification')
print('-------------------------------')
print(f'The elementary charge is {electron_charge} C')
type(f'The elementary charge is ')

temp_celsius = 54.435
# Print temp_celsius in fixed-point notation with 2 digits after decimal point
print(f'|{temp_celsius:.2f}| C')  # Fractional part is rounded 
# Print value at least 7 characters wide. Default precision=6 is used.
print(f'|{temp_celsius:7f}| C')
# Print value at least 7 characters wide and 2 digits after decimal point
print(f'|{temp_celsius:7.2f}| C')  # pads with white spaces on the left

# Print with default precision using scientific notation
print(f'{temp_celsius:e} C')
# Print value with 2 digits after the decimal place 
print(f'{temp_celsius:.2e} C')

rsh = {"d": [2.023, 7.4849], "xj": [-9.5898, -7.5669]}
# Print the value for a particular key in a dictionary 
print(f'Thickness of each layer: {rsh["d"]= }')

vt = 0.65894  
print(f'{vt= :.3f}')

print('\n-------------------------------')
print('2.4.4 Deleting Variables')
print('-------------------------------')
count = 3
print(f'count: {count}') 
del count  # delete variable count

print('\n-------------------------------')
print('2.4.5 Defining Variables as Constants')
print('-------------------------------')
count = 1  # count is 1 
count = 2  # Now, count is 2

ELEMENTARY_CHARGE = 1.6021773349e-19  # C

print('\n-------------------------------')
print('2.4.6 Tuple Assignment')
print('-------------------------------')
x, y = 1 + 2, 2 * 3  
x
y

x = 1, 2
type(x)

print('\n-------------------------------')
print('2.4.7 Sequence Packing and Unpacking')
print('-------------------------------')
[1, 2]

x, y = [1, 2]   
x
y

print('\n-------------------------------')
print('2.5.3 Python Variable Model')
print('-------------------------------')
x = 2
id(x)  # get memory address of object
x

print('\n-------------------------------')
print('2.5.4 Assignment and Binding')
print('-------------------------------')
my_list = [1, 2.4, True, None, 'Python']
my_tuple = (1, 2.4, True, None, 'Python')
my_dict = {'x': 1, (1, 1): [10, 20]} 

print('\n-------------------------------')
print('2.5.5 Properties of Objects')
print('-------------------------------')
2  # Create int object
id(2)
2  # Create int object and print its value 
'Hello'
np.array([10, 20.5, 30])
type(2)

x = 2         # x is assigned to int object
x
id(x)

x = 'Hello'   # x is assigned to str object
x
id(x)

x = [1, 2, 3]  # x is reassigned to list object
x
id(x)

print('\n-------------------------------')
print('2.5.5.1 Mutability of Objects')
print('-------------------------------')
numbers = [10, 20, 30, 40]  # Create list object
# Access first element of numbers list and assign to it 100 
numbers[0] = 100 
numbers

numbers = [10, 20, 30, 40] 
numbers = np.array([10, 20, 30, 40]) # Create ndarray object
numbers[0] = 100 
numbers

greeting = 'Hello, World!' 
# Change first character of greeting
# greeting[0] = 'h'  # Immutable objects cannot be changed 

print('\n-------------------------------')
print('2.5.5.2 Equality of Objects')
print('-------------------------------')
str1 = 'TCAD' 
str2 = 'TCAD'
id(str1), id(str2)
str1 is str2
str1, str2, str3 = 'TCAD', 'TCAD', 'Python'
str1 is str3

str1, str2, str3 = 'TCAD', 'TCAD', 'Python'
str1 is not str2, str1 is not str3

str1 == str2, str1 == str3

x = [10, 20, 30]
y = [10, 20, 30]
x == y, x is y

x = np.array([10, 20, 30])
y = np.array([10, 20, 30])
x is y, np.array_equal(x, y)

print('\n-------------------------------')
print('2.5.5.3 Aliasing, Assignment, and Mutable Objects')
print('-------------------------------')
x = [10, 20, 30] 
y = x  # Assigns id of x to y
x is y  # verify that x and y are aliases

y[0] = 1  # Change y
y
x  # x is also changed

x = np.array([10, 20, 30])  
y = x     # Both x and y refer to same object
x is y
y[0] = 1  # Changing y changes x
x

print('\n-------------------------------')
print('2.5.5.4 Copying Objects')
print('-------------------------------')
x = [10, 20, 30] 
# Create a slice of entire sequence and assign to z
z = x[:] 
z
x == z, x is z

x = np.array([10, 20, 30])  
z = x[:]  # Assign a slice of x to  z 
z[0] = 0  # Change z 
x         # x is also changed

x = np.array([10, 20, 30])  
# Make a copy of array x and assign to y
y = x.copy()
# Test for identity equality and equivalence 
y is x, np.array_equal(x, y) 

print('--------------------------------------------------------------------')
print('3. Modules, Functions, and Classes')
print('--------------------------------------------------------------------')

print('\n-------------------------------')
print('3.1.2 Using Modules')
print('-------------------------------')
import math  # Now, the entire math module is available
import numpy as np

from math import degrees, pi
radius = 1
# Use the name pi instead of math.pi
pi * (radius ** 2), 2 * pi * radius 
# Use the name degrees instead of math.degrees
degrees(pi)

print('\n-------------------------------')
print('3.1.2.1 Modules as Objects')
print('-------------------------------')
import math
# access constant pi defined in math module
math.pi

# Some other constants defined in math library
math.e, math.tau, math.inf, math.nan

# Calculate area and circumference of a circle of radius 1 unit
radius = 1
math.pi * (radius ** 2), 2 * math.pi * radius

print('\n-------------------------------')
print('3.1.3 Mathematical Constants')
print('-------------------------------')
import math
math.pi * 1j

print('\n-------------------------------')
print('3.1.4 Physical Constants: scipy.constants Module')
print('-------------------------------')
import scipy.constants as const
const.epsilon_0  # Access vacuum permeability
dir(const)
const.c, const.speed_of_light

print('\n-------------------------------')
print('3.1.4.1 Unit Conversion')
print('-------------------------------')
const.eV  # one electron volt in joules 
# Conversion factor for converting micrometer to m 
const.micron # 1 micrometer = 1e-6 m
5 * const.nano  # Convert 5 nm to m
5e-9 / const.nano  # Convert 5e-9 m to nm

print('\n-------------------------------')
print('3.2.1 Using Functions')
print('-------------------------------')
abs(1 + 1j)  # Call abs function with argument 1 + 1j

print(print('Hello, World!'))

type(print('Hello, World'))

print('\n-------------------------------')
print('3.2.1.1 Using Built-in Functions')
print('-------------------------------')
# Get help on abs function
# help(abs)  # call help function with argument abs

print('\n-------------------------------')
print('3.2.1.2 Using Mathematical Functions')
print('-------------------------------')
import math
# Call sin function defined in math module
math.sin(math.pi / 2) 

# Calculate pi using inverse sin function
pi = 2.0 * math.asin(1.0)
print(f'pi = {pi:.5f}')

# Verify Euler's identity
import math, cmath  # Importing multiple modules
cmath.exp(math.pi * 1j) + 1
1.2246467991473532e-16j

# help(math.sin)  # help on sin function in math module

print('\n-------------------------------')
print('3.2.1.3 Composing Functions')
print('-------------------------------')
math.exp(math.log(math.e))

# Compute maximum of of 2, 3, 4 and then square the maximum
pow(max(2, 3, 4), 2)

print('\n-------------------------------')
print('3.2.1.3 Composing Functions')
print('-------------------------------')
math.degrees(math.pi)

# Convert several angles from degrees to radians
angle_radians = np.array([0, np.pi/4, np.pi/2, 3*np.pi/4, np.pi])
np.rad2deg(angle_radians)

# Compute hypotenuse of a right-angled triangle
side1 = np.array([1, 2, 3])
side2 = np.array([5, 5, 6])
np.hypot(side1, side2)

np.sin(np.pi/2)

z = np.array([1 + 1j, -1 + 1j, -1, -1j, -1 - 1j])
np.real(z)  # Real part of array of complex numbers
np.conjugate(z)  # conjugate of array of complex numbers

x = np.array([1, 2, np.nan, 3])
np.sum(x)
np.nansum(x)

print('\n-------------------------------')
print('3.2.2 User-Defined Functions')
print('-------------------------------')
from resistivity import *
# help(resistivity)
type(resistivity)
resistivity(1e17, 700)

print('\n-------------------------------')
print('3.2.3 Local and Global Variables')
print('-------------------------------')
const.e
x, y = 1, 2
globals()

print('\n-------------------------------')
print('3.2.4 Returning Multiple Values')
print('-------------------------------')
divmod(5, 3)

print('\n-------------------------------')
print('3.3.1.1 Creating Objects')
print('-------------------------------')
z = 2 + 3j  # Create complex object using literals
z

z = complex(2, 3)  # Create complex object using constructor
z 
type(z)

print('\n-------------------------------')
print('3.3.1.2 Attributes: State and Behavior of Objects')
print('-------------------------------')
print(dir(z))

# help(z.conjugate)

print('\n-------------------------------')
print('3.3.1.3 Referencing Data Attributes')
print('-------------------------------')
x = 2
x

x = [2, 3]
x[0], x[1]  # Access list elements

z = 2 + 3j
z.real, z.imag

print('\n-------------------------------')
print('3.3.1.4 Referencing Methods')
print('-------------------------------')
(2 + 3j).conjugate()  # Call conjugate() method on complex object 
z = 2 + 3j     # Define variable 
z.conjugate()  # Call conjugate() method on object

print('\n-------------------------------')
print('3.3.1.5 Referencing Dunder Methods (Advanced)')
print('-------------------------------')
z1 = 1 + 2j  
z2 = 3 + 4j
z1 + z2      # Addition using + operator
z1.__add__(z2)  # Addition using method call 

z1 = 1 + 2j 
abs(z1), z1.__abs__()

2 + 3  # scalar addition
[2, 4] + [3, 6]  # concatenation
np.array([2, 4]) + np.array([3, 6])  # array addition

# help(complex)

print('\n-------------------------------')
print('3.3.2 User-Defined Classes')
print('-------------------------------')
from vector import *
# help(Vector2d)

v = Vector2d(1, 2)
type(v)  # v is an object of type Vector2d
vars(v)

v.x  # Access the x-component of vector
v.y  # Access the y-component of vector
v.length()  # Compute length of vector

w = Vector2d(0, 0)  # Create null vector
w.x, w.y
# Create unit vector in x-direction
w.x = 1  # Attribute assignment
w.x, w.y
u = Vector2d(0, 0)  # Creates a new Vector2d object and assigns to u
v = u
v.y = 1   # Update y data-attribute of v
u.x, u.y  # The y data-attribute of u is also updated

import copy
u = Vector2d(0, 0)
v = copy.copy(u)  # Create a new Vector2d object by copying u
v.y = 1           # Update y data-attribute of v
u.y               # The y data-attribute of u is not updated
u is v

print('--------------------------------------------------------------------')
print('4. Loops, Conditional Branching, and Operations on Sequences')
print('--------------------------------------------------------------------')

print('\n-------------------------------')
print('4.1.1 Membership Testing')
print('-------------------------------')
numbers = [11, 22, 33, 43]
22 in numbers

print('\n-------------------------------')
print('4.1.2 Range Object')
print('-------------------------------')
range(1, 6, 2)

for i in range(1, 6, 2):
    print(i)
    
integers = list(range(1, 6, 2))
integers

list(range(6, 1, -2))

list(range(0, 4))  # start=0, stop=4, step=1 (default)
list(range(4))     # start=0 (default), stop=4, step=1 (default)

for _ in range(3):
   print("Hello, World")
   
print('\n-------------------------------')
print('4.1.3 enumerate Function')
print('-------------------------------')  
greeting = 'Hello'
for i_elem in enumerate(greeting):
    print(i_elem)
    
print('\n-------------------------------')
print('4.1.4 Iterating Over Two Sequences')
print('-------------------------------')  
# Iterating over two lists of unequal length
numbers = list(range(1, 7))
chars = 'abcde'
for num_char in zip(numbers, chars):
    print(num_char)
    
print('\n-------------------------------')
print('4.2.1 Comparison Operators')
print('-------------------------------')  
5 == 5  # Test whether 5 is equal to 5
5.5 < 2.0  # Test whether 5.5 is strictly less than 2.0
2 * 5 < 6 / 2

print('\n-------------------------------')
print('4.2.2 Boolean Operators')
print('-------------------------------') 
not True
not False

True and False
True or False

3 > 2 and 1 > 2

x = 0 
y = 5
x != 0 and y / x

print('\n-------------------------------')
print('4.3.1 Creating Special Sequences')
print('-------------------------------') 
empty_list = []
empty_list, len(empty_list)

empty_str = ''
empty_str, len(empty_str)

singleton_list = [1]
singleton_list, len(singleton_list)

(1)
# Use equality operator to test whether two values are same
(1) == 1 
singleton_tuple = (1, )
type(singleton_tuple)
singleton_tuple 

greeting = 'Hello, World!'
letter = greeting[0]  # Extract single character
letter, type(letter)

print('\n-------------------------------')
print('4.3.1.1 Creating Special Arrays')
print('-------------------------------') 
empty_arr = np.empty(0)
empty_arr

freq = np.logspace(1, 5, 5)
freq

integer_arr = np.arange(1, 5)  # Creates an array of ints
integer_arr

float_arr = np.arange(1, 5.0)  # Creates an array of floats
float_arr

integer_arr.dtype, float_arr.dtype

numbers = np.array([1, 2.0, 3, 4])
numbers, numbers.dtype

numbers = np.array([1, 2.0, 3+4j, 4])
numbers, numbers.dtype

numbers = np.array([0, 1, 2], dtype='float64')  # Creates an array of floats
numbers, numbers.dtype

print('\n-------------------------------')
print('4.3.2 Slicing')
print('-------------------------------') 
# Indexing
[10, 20, 30, 40][0]  # first element or element in position 0

import numpy as np
my_lst = [0, 10, 20, 30, 40]
my_arr = np.array(my_lst)  

# Every other element from position 1 (included) to 4 (excluded)
my_lst[0:4:2]  # Slicing a list 

# Every other element from position 1 (included) to 4 (excluded)
my_arr[0:4:2]  # Slicing an array

# Slicing using default value of step = 1
my_arr[1:4]  # elements from position 1 (included) to 4 (excluded)

# Omitting start 
my_arr[:4]  # elements from position 0 (included) to 4 (excluded)

# Omitting stop 
my_arr[2:]  # elements from position 1 (included) to end of list

# Create copy of list
my_lst[:]  # elements from position 0 (included) to end of list

my_arr[::-1]  # Reverse array

my_lst[2:3]  # elements from position 1 (included) to 3 (excluded)

my_arr[2:3]  # elements from position 1 (included) to 3 (excluded)

my_arr = np.array([0, 10, 20, 30, 40])  
# Create array slice and assign to my_arr_view
my_arr_view = my_arr[:3]

my_arr_view[0] = 10  # Update my_arr_view
my_arr               # my_arr is also updated

my_arr = np.array([0, 10, 20, 30, 40])  
# Create new array containing copy of subarray
my_arr_copy = np.copy(my_arr[:3]) 
my_arr_copy

my_arr_copy[0] = 10   # Update my_arr_copy
my_arr                # my_arr does not change

print('\n-------------------------------')
print('4.3.5 String Methods')
print('-------------------------------')
'Hello World'.upper()
greeting = 'Hello World'
print(f'Before call to upper: {greeting= }')
greeting.upper()
print(f'After call to upper : {greeting= }')

greeting = 'Hello World'
'ello' in greeting
'hell' in greeting

print('\n-------------------------------')
print('4.4 More on scipy.constants Module')
print('-------------------------------')
import scipy.constants as const 
# Search for the key for speed of light using the string 'cuu'
const.find('cuu')
const.physical_constants['speed of light in vacuum']
const.value('speed of light in vacuum')
const.unit('speed of light in vacuum')