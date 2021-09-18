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
    h) # Display help.
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

    # Loop through list of algorithms
    while IFS= read -r algorithm
    do 
    
        # extract algorithm full name
        params=(${algorithm//,/ })
        fullname=''
        for i in ${!params[@]}
        do
            param=${params[$i]}
            kv=(${param//=/ })
            if [ $i -eq 0 ]
            then
                fullname=${kv[1]}
            else
                fullname=$fullname-${kv[1]}
            fi
        done

        # remove existed algorithm performance measure txt file
        filename=$algorithm_perf_sub_dir/measure_$fullname.txt
        if [ -f $filename ]
        then
            rm $filename
        fi

        # remove existed algorithm iteration log file
        filename=$algorithm_perf_sub_dir/log_$fullname.out
        if [ -f $filename ]
        then
            rm $filename
        fi

        # Loop through list of problems
        while IFS= read -r problem
        do
            # Run solveCUTEstProblem
            /Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -nojvm -r "fprintf('Solving %s with %s...\n','$problem','$algorithm'); solveCUTEstProblem('$problem','$algorithm', '$user_dir', '$algorithm_perf_sub_dir'); fprintf(' done.\n'); exit;"
    
        done < "$problem_list"

    done < "$algorithm_list"
fi

# Plot DolanMore Performance Profile of iteration
/Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -r "fprintf('Plotting DolanMore Performance Profile...\n'); plotDolanMore('$user_dir', '$algorithm_perf_sub_dir', 2);fprintf(' done.\n'); exit;"

# Plot DolanMore Performance Profile of running time
/Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -r "fprintf('Plotting DolanMore Performance Profile...\n'); plotDolanMore('$user_dir', '$algorithm_perf_sub_dir', 6);fprintf(' done.\n'); exit;"
