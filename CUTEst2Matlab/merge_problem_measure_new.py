import sys
import pandas as pd
import os

algorithm_list         = sys.argv[1] #'list_algorithm_trace.txt'
problem_list           = sys.argv[2] #'list_prob_all.txt'
user_dir               = sys.argv[3] #'.' 
algorithm_perf_sub_dir = sys.argv[4] #'trace_output_1213'

measure_full_path      = '%s/%s' %(user_dir, algorithm_perf_sub_dir)
prob_list_full_path    = '%s/%s' %(user_dir, problem_list)

problem_set_enough_mem_time = set()
dfs = {}

algorithms = []

# remove all new_measure* file
cmd = 'rm %s/new_*' %(measure_full_path)
os.system(cmd)

# read problem_list
df_prob = pd.read_table(prob_list_full_path, header=None) 

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

        # merge with problem list
        df_measure_list_old = df_measure_list_old.merge(df_prob, on=0, how='right')

        # fillna
        df_measure_list_old = df_measure_list_old.fillna(-2)

        # filter cases that has been solved at initialization
        mask_solved_at_initial = df_measure_list_old[4] == 0
        problem_solved_at_initial = df_measure_list_old.loc[mask_solved_at_initial]
        if problem_solved_at_initial.shape[0] > 0:
            print('DEBUG!! problems solved at initialization:', problem_solved_at_initial)
        df_measure_list_old = df_measure_list_old[df_measure_list_old[4] != 0]

        # get status statistics
        status_stat = pd.DataFrame(df_measure_list_old[2].value_counts())
        status_stat.columns = ['status_count']
        status_stat['percent'] = status_stat['status_count'] / df_prob.shape[0]
        status_stat.loc['Column_Total']= status_stat.sum(numeric_only=True, axis=0)
        print(status_stat)

        # filter failed case
        df_measure_list_old = df_measure_list_old[df_measure_list_old[2] == 0]

        # set problem name as index
        df_measure_list_old.set_index(0, inplace=True)

        # set the measure for unsolved problem in measure list as -1 (if originally greater than 0)
        mask = df_measure_list_old[2] < 0
        # header:  problem0, n1, status2, time3,g_evals4,f_evals5, Hv_evals6, f7, norm_g8, outcome9
        df_measure_list_old.loc[mask, [3,4,5,6,7,8]] = -1

        # repace Hv_evals columns 0 by -1 since exact algorithms are zeros
        df_measure_list_old[6].replace(0,-1, inplace=True)


        # check if there are cases has zero iterations
        mask = df_measure_list_old[4] == 0
        if df_measure_list_old.loc[mask].shape[0] > 0:
            print('  %s - has zero iteration cases' %(measure_file))
            print(df_measure_list_old.loc[mask])
            df_measure_list_old.loc[mask, 4] = 1

        # find the problem set that all algorithms has enough memory and running time
        problem_set = set(df_measure_list_old.index.to_list())
        print('%s - len of solved problems: %s' %(measure_file, len(problem_set)))
        if problem_set_enough_mem_time:
            problem_set_enough_mem_time = problem_set_enough_mem_time.intersection(problem_set)
        else:
            problem_set_enough_mem_time = problem_set

        dfs[measure_file]=df_measure_list_old


# save problems that all algorithms has enough memory and running time
df_problem = pd.Series(list(problem_set_enough_mem_time), name=0)
for measure_file, df in dfs.items():
    new_measure_file_full_path = '%s/new_%s' %(measure_full_path, measure_file)
    df_measure_list_new = df.merge(df_problem, left_on=0, right_on=0, how='right')
    print('%s - len of intersected solved problems: %s' %(measure_file, df_measure_list_new.shape[0]))
    df_measure_list_new.drop(9, axis=1, inplace=True)
    df_measure_list_new.to_csv(new_measure_file_full_path, index=False, sep='\t', header=None)

