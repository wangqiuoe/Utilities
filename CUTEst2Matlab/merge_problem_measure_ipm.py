import sys
import pandas as pd
import numpy as np
import os

algorithm_list         = sys.argv[1] #'list_algorithm_trace.txt'
problem_list           = sys.argv[2] #'list_prob_all.txt'
user_dir               = sys.argv[3] #'.' 
algorithm_perf_sub_dir = sys.argv[4] #'trace_output_1213'
take_intersection      = 1

measure_full_path      = '%s/%s' %(user_dir, algorithm_perf_sub_dir)
prob_list_full_path    = '%s/%s' %(user_dir, problem_list)

dfs = {}

algorithms = []

# remove all new_measure* file
cmd = 'rm %s/new_*' %(measure_full_path)
os.system(cmd)

# read problem_list
df_prob = pd.read_table(prob_list_full_path, names=['problem']) 
df_prob['problem'] = df_prob['problem'].apply(lambda x: x+"_mse")

print('Number of problems: ', df_prob.shape[0])
print('---------------------------------------')

problem_all_solved = set(df_prob['problem'])

with open(algorithm_list) as fin:
    for line in fin:
        words = line.strip().split('|')
        algorithm = []
        for word in words:
            params = word.split('=')
            if params[0] == 'opt_mse':
                pass
            else:
                algorithm.append(params[1])
        algorithm = '-'.join(algorithm)
        algorithms.append('measure_%s.txt' %(algorithm))
        measure_file = 'measure_%s.txt' %(algorithm)

        old_measure_file_full_path = '%s/%s' %(measure_full_path, measure_file)

        # read the original measure file
        df_measure_list_old = pd.read_table(old_measure_file_full_path, sep = '\t', dtype={'n': int, 'status': int, 'iter': int, 'f': float, 'norm_r': float})

        # add epsilon to all f and norm_r, in case some are zeros
        epsilon = 1e-16
        df_measure_list_old['f'] = df_measure_list_old['f'] + epsilon
        df_measure_list_old['norm_r'] = df_measure_list_old['norm_r'] + epsilon

        # merge with problem list
        df_measure_list_old = pd.merge(df_prob, df_measure_list_old, on='problem', how='left')

        # check nan, inf
        df_failed = df_measure_list_old[df_measure_list_old.isin([np.nan, np.inf, -np.inf]).any(1)]
        print(measure_file)
        print('Number of Inf or NaN cases: ', df_failed.shape[0])
        print('---------------------------')

        # get set of problems solved by all algorithms
        problem_solved = set(df_measure_list_old[~df_measure_list_old.isin([np.nan, np.inf, -np.inf]).any(1)]['problem'])
        if take_intersection:
            problem_all_solved = problem_all_solved.intersection(problem_solved)

        # fillna
        df_measure_list_old = df_measure_list_old.fillna(np.inf)

        # drop outcome
        df_measure_list_old.drop('outcome', axis=1, inplace=True)

        # dict of all measure file
        dfs[measure_file] = df_measure_list_old

# save problems that all algorithms has enough memory and running time
df_problem = pd.Series(list(problem_all_solved), name='problem')
for measure_file, df in dfs.items():
    # save revised measure files
    new_measure_file_full_path = '%s/new_%s' %(measure_full_path, measure_file)
    df_measure_list_new = df.merge(df_problem, left_on='problem', right_on='problem', how='right')
    print('%s - len of intersected solved problems: %s' %(measure_file, df_measure_list_new.shape[0]))
    df_measure_list_new.to_csv(new_measure_file_full_path, index=False, sep='\t', header=None)
