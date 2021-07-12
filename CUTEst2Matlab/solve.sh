#!/bin/bash

# Set name of list of all problems to solve
problem_list="list_unconstrained.txt"

# Set name of list of all algorithms to run
algorithm_list="list_algorithms.txt"

# set the user directory (use current directory)
user_dir=$(PWD)  #"/Users/wangqi/Desktop/cutest_test/Utilities/CUTEst2Matlab"

# set the algorithm performance sub directory
algorithm_perf_sub_dir="output"

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ":h:o:p:a:d:" arg; do
  case $arg in
    o) # 1 if need optimization 0 otherwise.
      optimize=${OPTARG}
      [ $optimize -eq 0 -o $optimize -eq 1 ] \
        || echo "param o needs to be either 1 or 0, $optimize found instead."
      ;;
    p) # problem list file, default list_unconstrained.txt
      problem_list=${OPTARG}
      ;;
    a) # algorithm list file, default list_algorithms.txt
      algorithm_list=${OPTARG}
      ;;
    d) # algorithm_perf_sub_dir, default output
      algorithm_perf_sub_dir=${OPTARG}
      ;;
    h | *) # Display help.
      usage
      exit 0
      ;;
  esac
done


# Create algorithm performance sub directory
if [ ! -d $algorithm_perf_sub_dir ]
then
  mkdir $algorithm_perf_sub_dir;
fi

if [ $optimize == 1 ]
then
    # remove existed algorithm performance sub
    if [ -d $algorithm_perf_sub_dir ]
    then
        rm $algorithm_perf_sub_dir/*
    fi
    
    # Loop through list of problems
    while IFS= read -r problem
    do
    
      # Loop through list of algorithms
      while IFS= read -r algorithm
      do
    
        # Run solveCUTEstProblem
        /Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -nojvm -r "fprintf('Solving %s with %s...','$problem','$algorithm'); solveCUTEstProblem('$problem','$algorithm', '$user_dir', '$algorithm_perf_sub_dir'); fprintf(' done.\n'); exit;"
    
      done < "$algorithm_list"
    
    done < "$problem_list"
fi

# Plot DolanMore Performance Profile
/Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -r "fprintf('Plotting DolanMore Performance Profile...'); plotDolanMore('$user_dir', '$algorithm_perf_sub_dir');fprintf(' done.\n'); exit;"
