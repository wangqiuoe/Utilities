#!/bin/bash

# Set name of list of all problems to solve
problem_list="list_equality_constrained.txt"

# Loop through list of problems
while IFS= read -r problem
do

  # Run solveCUTEstProblem
  /Applications/MATLAB_R2020a.app/bin/matlab -nodisplay -nodesktop -nosplash -nojvm -r "fprintf('Solving %s...','$problem'); solveCUTEstProblem('$problem'); fprintf(' done.\n'); exit;"

done < "$problem_list"
