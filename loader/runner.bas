# a points to basic program

# Find the first basic line with a non zero high byte in line number

1 let a=peek val"23635"+val"256"*peek val"23636"
3 if peek a then print usr (a+val"5"):stop
7 let a=a+peek(a+val"2")+val"4":goto pi

2023 rem MACHINE_CODE_HERE
