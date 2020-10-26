#!/bin/bash

# Set name of list of all problems to check
problem_list="list_decoded.txt"

# Loop through problem list
while IFS= read -r problem
do

  # Run checkConstraintsType
  /Applications/MATLAB_R2020a.app/bin/matlab -nodisplay -nodesktop -nosplash -nojvm -r "fprintf('Checking %s...','$problem'); checkConstraintsType('$problem'); fprintf(' done.\n'); exit;"

done < "$problem_list"
