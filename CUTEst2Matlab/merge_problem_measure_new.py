import sys
import pandas as pd
import os

#problem_list           = sys.argv[1]
#user_dir               = sys.argv[2]
#algorithm_perf_sub_dir = sys.argv[3]

algorithm_list         = sys.argv[1] #'list_algorithm_trace.txt'
user_dir               = sys.argv[2] #'.' 
algorithm_perf_sub_dir = sys.argv[3] #'measure_1207'

measure_full_path      = '%s/%s' %(user_dir, algorithm_perf_sub_dir)

problem_set_enough_mem_time = set()
dfs = {}

algorithms = []

# remove all new_measure* file
cmd = 'rm %s/new_*' %(measure_full_path)
os.system(cmd)

with open(algorithm_list) as fin:
    for line in fin:
        words = line.strip().split('|')
        algorithm = []
        for word in words:
            params = word.split('=')[1]
            algorithm.append(params)
        algorithm = '-'.join(algorithm)
        algorithms.append('measure_%s.txt' %(algorithm))
        measure_file = 'measure_%s.txt' %(algorithm)

        old_measure_file_full_path = '%s/%s' %(measure_full_path, measure_file)

        # read the original measure file
        df_measure_list_old = pd.read_table(old_measure_file_full_path, sep = '\t', header=None)

        # filter failed case of out of memory and running time
        df_measure_list_old = df_measure_list_old[df_measure_list_old[1] >= -1]

        # filter cases that has been solved at initialization
        df_measure_list_old = df_measure_list_old[df_measure_list_old[2] != 0]
        
        # set problem name as index
        df_measure_list_old.set_index(0, inplace=True)

        # set the measure for unsolved problem in measure list as -1 (if originally greater than 0)
        mask = df_measure_list_old[1] < 0
        # header: problem 0, status 1, iter 2, f 3, g_norm 4, time 5,f_evals 6,sub_iter 7, Hv_evals8, outcome9
        df_measure_list_old.loc[mask, [2,3,4,5,6,7,8]] = -1

        # repace Hv_evals columns 0 by -1 since exact algorithms are zeros
        df_measure_list_old[8].replace(0,-1, inplace=True)


        # check if there are cases has zero iterations
        mask = df_measure_list_old[2] == 0
        if df_measure_list_old.loc[mask].shape[0] > 0:
            print('  %s - has zero iteration cases' %(measure_file))
            print(df_measure_list_old.loc[mask])
            df_measure_list_old.loc[mask, 2] = 1

        # find the problem set that all algorithms has enough memory and running time
        problem_set = set(df_measure_list_old.index.to_list())
        print('%s - len of problem_set with enough mem and time: %s' %(measure_file, len(problem_set)))
        if problem_set_enough_mem_time:
            #print(problem_set.difference(problem_set_enough_mem_time))
            problem_set_enough_mem_time = problem_set_enough_mem_time.intersection(problem_set)
        else:
            problem_set_enough_mem_time = problem_set

        dfs[measure_file]=df_measure_list_old


# save problems that all algorithms has enough memory and running time
df_problem = pd.Series(list(problem_set_enough_mem_time), name=0)
for measure_file, df in dfs.items():
    new_measure_file_full_path = '%s/new_%s' %(measure_full_path, measure_file)
    df_measure_list_new = df.merge(df_problem, left_on=0, right_on=0, how='right')
    print('%s - len of intersected problem: %s' %(measure_file, df_measure_list_new.shape[0]))
    df_measure_list_new.drop(9, axis=1, inplace=True)
    df_measure_list_new.to_csv(new_measure_file_full_path, index=False, sep='\t', header=None)

