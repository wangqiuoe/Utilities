function plotDolanMore(user_dir, algorithm_perf_sub_dir, column, suffix)

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


full_path = sprintf('%s/%s/new_measure_*.txt',user_dir,algorithm_perf_sub_dir);
files_struct = dir(full_path);
files      = cell(length(files_struct),1);
algorithms = cell(length(files_struct),1);

for i=1:length(files_struct)
    files{i}        = sprintf('%s/%s/%s', user_dir,algorithm_perf_sub_dir, files_struct(i).name);
    % avoid using '_' because of interpreter of latex when plot
    algorithms_name = strsplit(files_struct(i).name, '.');
    algorithms_name = cell2mat(algorithms_name(1));
    for ii=1:length(algorithms_name)
        if algorithms_name(ii) == '_'
            algorithms_name(ii) = '-';
        end
    end
    algorithms{i} = algorithms_name; 
end



% File format per line
% prblem status iter f g_norm time f_evals sub_iter Hv_evals
file_format = '%s\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f';

% Column to consider
column = column;

% Log scale?
options.log_scale = false;

% Maximum ratio?
options.tau_max = 15;

% Add location of profiler to path
addpath(sprintf('%s/PerformanceProfilers/src/Matlab/', user_dir));

% title
if column == 3
    options.title='iteration';
elseif column == 6
    options.title='runningtime';
elseif column == 7
    options.title='fevals';
elseif column == 8
    options.title='subiter';
elseif column == 9
    options.title='Hvevals';
end

options.suffix = suffix;

% Call profiler
profilerDolanMore(files,algorithms,file_format,column,options, user_dir, algorithm_perf_sub_dir);
