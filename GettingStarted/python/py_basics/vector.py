# Script: vector.py   
import math

# Define class
class Vector2d:
    """A class to represent a two-dimensional vector x i + y j
    in Cartesian coordinates.
    
    Attribute x: x-component of the vector
    Attribute y: y-component of the vector
    """
    
    # initializer
    def __init__(self, x, y):
        """Initializes the state of Vector2d object."""
        # Define data attributes
        self.x = x
        self.y = y
    
    # define methods
    def length(self):
        """Return length of a vector"""
        return math.sqrt(self.x ** 2 + self.y ** 2)  
    

# Create a Vector2d object to represent a 2D vector
v = Vector2d(1, 2)

# Compute length of the vector
length_vector = v.length()
print(f'|v| = {length_vector}')