import sys
import pandas as pd
import os

problem_list           = sys.argv[1]
user_dir               = sys.argv[2]
algorithm_perf_sub_dir = sys.argv[3]
inner                  = int(sys.argv[4])

measure_full_path      = '%s/%s' %(user_dir, algorithm_perf_sub_dir)

df_problem_list = pd.read_table(problem_list, sep = '\t', header=None)

os_list = os.listdir(measure_full_path)

if inner:
    inner_problem_set = set(df_problem_list[0])

for measure_file in os_list:

    if not measure_file.startswith('measure'):
        continue

    old_measure_file_full_path = '%s/%s' %(measure_full_path, measure_file)
    new_measure_file_full_path = '%s/new_%s' %(measure_full_path, measure_file)

    # read the original measure file
    df_measure_list_old = pd.read_table(old_measure_file_full_path, sep = '\t', header=None)

    # create the new measure file by merge old measure file with problem list
    df_measure_list_new = df_problem_list.merge(df_measure_list_old,on=0, how='left')

    # set the measure for unsolved problem in given problem list as -1
    df_measure_list_new.fillna(-1,inplace=True)

    # set problem name as index
    df_measure_list_new.set_index(0, inplace=True)
    df_measure_list_new.index.name = None

    # set the measure for unsolved problem in measure list as -1 (if originally greater than 0)
    mask = df_measure_list_new[1] <= 0
    df_measure_list_new.loc[mask] = -1
    df_measure_list_new.replace(0,-1, inplace=True)

    solved_problem_set = set(df_measure_list_new[df_measure_list_new[1] > 0].index.to_list())
    print('%s - len of solved_problem_set:%s' %(measure_file, len(solved_problem_set)))
    if inner:
        inner_problem_set = inner_problem_set.intersection(solved_problem_set)

    # save old measure into another file startswith old_, and new measure into original file
    df_measure_list_new.to_csv(new_measure_file_full_path, sep='\t', header=None)

if inner:
    df_inner_problem = pd.Series(list(inner_problem_set), name=0)
    
    for measure_file in os_list:
        if not measure_file.startswith('new_measure'):
            continue
    
        new_measure_file_full_path = '%s/%s' %(measure_full_path, measure_file)
        df_measure_list_new = pd.read_table(new_measure_file_full_path, sep = '\t', header=None)
        print('%s = len of inner problem: %s' %(measure_file, df_inner_problem.shape[0]))
        df_measure_list_new = df_measure_list_new.merge(df_inner_problem, on=0, how='right')
        df_measure_list_new.to_csv(new_measure_file_full_path, index=False, sep='\t', header=None)

