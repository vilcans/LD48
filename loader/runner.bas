# a points to basic program

# Find the first basic line with a non zero high byte in line number

5 let a=peek val"23635"+val"256"*peek val"23636"
6 if peek a then print usr (a+5):stop
7 let a=a+peek(a+val"2")+val"4":goto val"6"

2021 rem MACHINE_CODE_HERE
