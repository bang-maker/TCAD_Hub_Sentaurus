# Script: list_zip.py 
numbers = list(range(1, 7))
chars = 'abcde'
for num, char in zip(numbers, chars):
    print(f'The {num} letter of the alphabet is {char}')