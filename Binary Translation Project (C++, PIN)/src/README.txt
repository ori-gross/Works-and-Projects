## information ##
Ron Lebedinsky 323118885
Ori Gross 318829330

## Compilation Instrustions ##
put project.cpp and project.h in $PIN_ROOT/source/tools/SimpleExamples

cd $PIN_ROOT/source/tools/SimpleExamples

make clean

make project.test

## Run Tool ##
cd $PIN_ROOT/source/tools/SimpleExamples

time ../../../pin -t ./obj-intel64/project.so -create_tc2 -- <cc1 path>/cc1 <expr.i path>/expr.i

e.g.:
time ../../../pin -t ./obj-intel64/project.so -create_tc2 -- ../../../../final_project/cc1 ../../../../final_project/expr.i


## Threshold Description ##
To indentify the hot target in an indirect jump/call we have 2 parameters: JUMP_COUNT_THRESHOLD and PERCENTAGE_OF_JUMPS_THRESHOLD.
Using PERCENTAGE_OF_JUMPS_THRESHOLD = 50 we always choose the target address which the most jumps/calls to.
Using JUMP_COUNT_THRESHOLD = 512 we filter out indirect jumps/calls which aren't really common so the tradeoff of adding more instructations to the code to stay in TC2 would actually pay off.