# Script: loop_for.py

numbers = [11, 22, 33, 43]
counter, total = 1, 0
for num in numbers:
    print(f'Iteration number: {counter}')
    total += num
    print(f'Partial sum: {total}')
    counter += 1
    
print(total)     