#!/bin/bash

# Set name of list of all problems to solve
problem_list="list_unconstrained.txt"

# Set name of list of all algorithms to run
algorithm_list="list_algorithms.txt"

# set the user directory (use current directory)
user_dir=$PWD  #"/Users/wangqi/Desktop/cutest_test/Utilities/CUTEst2Matlab"

# set the algorithm performance sub directory
algorithm_perf_sub_dir="output"

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ":h:o:p:a:d:s:" arg; do
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
    s) # plot_suffix
      suffix=${OPTARG}
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
        params=(${algorithm//|/ })
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
            err_log=log/log_${fullname}_$problem.err 
            filename=$err_log
            if [ -f $filename ]
            then
                rm $filename
            fi

            out_log=log/log_${fullname}_$problem.out
            filename=$out_log
            if [ -f $filename ]
            then
                rm $filename
            fi
            
            N_name=${fullname}_$problem

            # Run solveCUTEstProblem
            qsub -N $N_name -l nodes=1:ppn=2 -q short -l pmem=8gb -l vmem=8gb -e $err_log -o $out_log -v PROBLEM=$problem,ALGORITHM=${algorithm},USER_DIR=$user_dir,ALGORITHM_PERF_SUB_DIR=$algorithm_perf_sub_dir  run_one_problem.pbs
            #qsub -N $N_name -l nodes=1:ppn=2 -q short -l mem=8gb -l vmem=8gb -e $err_log -o $out_log -v PROBLEM=$problem,ALGORITHM=${algorithm},USER_DIR=$user_dir,ALGORITHM_PERF_SUB_DIR=$algorithm_perf_sub_dir  run_one_problem.pbs
            #qsub -q short -l mem=4gb -l vmem=4gb -e "log.err" -o "log.out" /usr/local/matlab/R2014b/bin/matlab -nodisplay -nodesktop -nosplash -nojvm -r "fprintf('Solving %s with %s...\n','$problem','$algorithm'); cd $user_dir;solveCUTEstProblem('$problem','$algorithm', '$user_dir', '$algorithm_perf_sub_dir'); fprintf(' done.\n'); exit;"
    
        done < "$problem_list"

    done < "$algorithm_list"
fi

if [ $optimize == 0 ]
then

    # Loop through list of algorithms
    while IFS= read -r algorithm
    do
        echo $algorithm
        # extract algorithm full name
        params=(${algorithm//|/ })
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
            echo $filename exists.
        else
            cat $algorithm_perf_sub_dir/measure_${fullname}_*.txt > $filename
        fi

    done < "$algorithm_list" 


    # merge the measure performance file with problem_list 
    python merge_problem_measure_new.py $algorithm_list $problem_list $user_dir $algorithm_perf_sub_dir

    # Plot DolanMore Performance Profile of running time
    #/Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -r "fprintf('Plotting DolanMore Performance Profile of running time...\n'); plotDolanMore('$user_dir', '$algorithm_perf_sub_dir', 4, '$suffix', '$algorithm_list');fprintf(' done.\n'); exit;"

    # Plot DolanMore Performance Profile of gradient evaluations
    /Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -r "fprintf('Plotting DolanMore Performance Profile of gradient evaluations...\n'); plotDolanMore('$user_dir', '$algorithm_perf_sub_dir', 5, '$suffix', '$algorithm_list');fprintf(' done.\n'); exit;"
    # Plot DolanMore Performance Profile of function evaluations
    /Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -r "fprintf('Plotting DolanMore Performance Profile of function evaluations...\n'); plotDolanMore('$user_dir', '$algorithm_perf_sub_dir', 6, '$suffix', '$algorithm_list');fprintf(' done.\n'); exit;"
    # Plot DolanMore Performance Profile of Hessian vector evaluations
    /Applications/MATLAB_R2021a.app/bin/matlab -nodisplay -nodesktop -nosplash -r "fprintf('Plotting DolanMore Performance Profile of Hessian vector evaluations...\n'); plotDolanMore('$user_dir', '$algorithm_perf_sub_dir', 7, '$suffix', '$algorithm_list');fprintf(' done.\n'); exit;"
fi
