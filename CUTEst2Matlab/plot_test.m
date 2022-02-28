user_dir='.';
algorithm_perf_sub_dir = 'trace_output_1213';
suffix='all';
list_algorithm = 'list_algorithm_trace.txt';
plotDolanMore(user_dir, algorithm_perf_sub_dir, 4, suffix, list_algorithm)

%{
f_in = fopen('list_algorithm_trace.txt', 'r');
%solver=itrace|algorithm=inexact|xi=1
file_format = '%s %s %s';
algorithm_config = textscan(f_in,file_format, 'delimiter','|');
fclose(f_in);
n_algorithms = length(algorithm_config{1});
algorithms = cell(n_algorithms, 1);
files = cell(n_algorithms,1);

n_params = length(algorithm_config);
for j=1:n_algorithms
    algorithm = cell(n_params,1);
    for i=1:n_params
        kv = strsplit(algorithm_config{i}{j}, '=');
        algorithm{i} = kv{2};
    end
    algorithms{j} = strjoin(algorithm, '-');
    files{j} = sprintf('%s/%s/new_measure_%s.txt',user_dir,algorithm_perf_sub_dir, algorithms{j} );
end
%}