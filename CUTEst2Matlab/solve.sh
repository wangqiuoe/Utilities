#!/bin/bash

# Set name of list of all problems to solve
problem_list="list_solve.txt"

# Set name of list of all algorithms to run
algorithm_list="list_algorithms.txt"

# Create output directory
if [ ! -d "output" ]
then
  mkdir output;
fi

# Loop through list of problems
while IFS= read -r problem
do

  # Loop through list of algorithms
  while IFS= read -r algorithm
  do

    # Run solveCUTEstProblem
    /Applications/MATLAB_R2020a.app/bin/matlab -nodisplay -nodesktop -nosplash -nojvm -r "fprintf('Solving %s with %s...','$problem','$algorithm'); solveCUTEstProblem('$problem','$algorithm'); fprintf(' done.\n'); exit;"

  done < "$algorithm_list"

done < "$problem_list"
