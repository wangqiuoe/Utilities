function plotDolanMore(user_dir, algorithm_perf_sub_dir, column, suffix, list_algorithm)

% plotDolanMore
%
% Author      : Qi Wang
% Description : Tests Matlab implementation of Dolan and Moré profiler.
% Note        : This file provides the following inputs:
%
% user_dir               ~ current absolute directory
% algorithm_perf_sub_dir ~ sub directory under user_dir that contains 
%                          performance of algorithm (each algorithm is 
%                          contained in one file, and the file name is 
%                          [algorithm name].txt)
% file_format            ~ string indicating format of each line of input files
% column                 ~ column containing performance measure data of interest
% options                ~ struct of (optional) options
%                          see profilerDolanMore for more information about options
%
% Example : Suppose that there are two input files:
%
% algorithm_1.txt, with contents:
% problem_1  1  2.0
% problem_2  3  4.0
%
% algorithm_2.txt, with contents:
% problem_1  5  6.0
% problem_2 -1 -1.0
%
% where the first column in each line indicates a problem name, the second
% column indicates the number of iterations required, and the third column
% indicates the final value of the objective function.  To generate a
% performance profile for the number of iterations required, the inputs
% could be given as follows:
%
% >> user_dir = '/Users/wangqi/Desktop/cutest_test/Utilities/CUTEst2Matlab';
% >> algorithm_perf_sub_dir = 'output'
% >> file_format = '%s\t%d\t%f';
% >> column = 2;
% >> options.log_scale = true;
% >> options.tau_max   = inf;
%
% Notes :
% - Use a negative value to indicate failure to solve a problem
% - All other performance measure values should be strictly positive (not zero)
% - All lines of the input files must have the same format
% - All input files must have the same number of lines


algorithms=cell(0);
colors=cell(0);   % specify the color
files = cell(0);
f_in = fopen(list_algorithm, 'r');
j=1;
while ~feof(f_in)
    tline = fgetl(f_in);
    algorithm_config = strsplit(tline, '|');
    n_params = length(algorithm_config);
    algorithm = cell(n_params,1);
    for i=1:n_params
        kv = strsplit(algorithm_config{i}, '=');
        if i==1
            algorithm{i} = upper(kv{2});    % upper the solver's name
        else
            algorithm{i} = kv{2};
        end
    end
    algorithms{j} = strjoin(algorithm, '-');
    if strcmp(algorithms{j}, 'TRACE-inexact-0.01') 
        color = '#7E2F8E';
    elseif strcmp(algorithms{j}, 'TRACE-inexact-1') 
        color = '#EDB120';
    elseif strcmp(algorithms{j}, 'TRACE-inexact-100') 
        color = '#D95319';
    elseif strcmp(algorithms{j}, 'TRACE-exact') 
        color = '#0072BD';
    elseif strcmp(algorithms{j}, 'ARC-1') 
        color = '#77AC30';
    elseif strcmp(algorithms{j}, 'TRNTCG') 
        color = '#A2142F';
    end
    colors{j} = color;        
    files{j} = sprintf('%s/%s/new_measure_%s.txt',user_dir,algorithm_perf_sub_dir, algorithms{j} );
    j = j+1;
end
fclose(f_in);


% File format per line
% prblem status iter f g_norm time f_evals sub_iter Hv_evals
%file_format = '%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f';
file_format='%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f';

% Column to consider
column = column;

% Log scale?
options.log_scale = false;

% Maximum ratio?
options.tau_max = 20;

% Add location of profiler to path
addpath(sprintf('%s/PerformanceProfilers/src/Matlab/', user_dir));

% title
if column == 4
    options.title='runningtime';
elseif column == 5
    options.title='gradient-evals';
elseif column == 6
    options.title='function-evals';
elseif column == 7
    options.title='Hv-evals';
end

options.suffix = suffix;
options.style='slides';     % for slides
options.colors=colors;      % for specify colors
% Call profiler
profilerDolanMore(files,algorithms,file_format,column,options, user_dir, algorithm_perf_sub_dir);
