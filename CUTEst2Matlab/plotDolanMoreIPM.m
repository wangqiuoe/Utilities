function plotDolanMoreIPM(user_dir, algorithm_perf_sub_dir, column, suffix, list_algorithm)

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

% File format per line
file_format='%s\t%f\t%f\t%f\t%f\t%f\t%f';

% Column to consider
column = column;

% Log scale?
options.log_scale = false;

% Maximum ratio?
options.tau_max = 50;

% Add location of profiler to path
addpath(sprintf('%s/PerformanceProfilers/src/Matlab/', user_dir));

% title
if column == 6
    options.title='f';
elseif column == 7
    options.title='norm KKT';
end

options.suffix = suffix;
options.style='paper';     % for slides

algorithms=cell(0);
colors=cell(0);   % specify the color
files = cell(0);
f_in = fopen(list_algorithm, 'r');
j=1;
while ~feof(f_in)
    tline = fgetl(f_in);
    algorithm_config = strsplit(tline, '|');
    n_params = length(algorithm_config);
    algorithm = {};
    ii=1;
    for i=1:n_params
        kv = strsplit(algorithm_config{i}, '=');
        if ~strcmp(kv{1}, 'opt_mse')    % ignore the opt_mse sign
            if i==1
                algorithm{ii} = kv{2};  
            else
                algorithm{ii} = kv{2};
            end
            ii = ii + 1;
        end
    end
    algorithm_temp = strjoin(algorithm, '-');

    algorithms{j} = algorithm_temp;

    files{j} = sprintf('%s/%s/new_measure_%s.txt',user_dir,algorithm_perf_sub_dir, algorithms{j} );
    j = j+1;
end
fclose(f_in);

%options.colors=colors;      % for specify colors
% Call profiler
profilerDolanMore(files,algorithms,file_format,column,options, user_dir, algorithm_perf_sub_dir);
