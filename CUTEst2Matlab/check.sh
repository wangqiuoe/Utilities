#!/bin/bash

# Set name of list of all problems to check
problem_list="list_decoded.txt"
user_dir="/Users/wangqi/Desktop/cutest_test/Utilities/CUTEst2Matlab"

# rm existed problem info file
rm ${user_dir}/problem_info.txt

# Loop through problem list
while IFS= read -r problem
do

  # Run checkConstraintsType
  /Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -nojvm -r "fprintf('Checking %s...','$problem'); checkConstraintsType('$problem', '$user_dir'); fprintf(' done.\n'); exit;"

done < "$problem_list"
