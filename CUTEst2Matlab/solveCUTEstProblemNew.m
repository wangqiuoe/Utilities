function info = solveCUTEstProblem(problem,algorithm_config, user_dir, algorithm_perf_sub_dir)

if startsWith(pwd,'/Users/wangqi/')
    % local conf
    cutest_path='/usr/local/opt/cutest/libexec/src/matlab'; 
    solver_path='/Users/wangqi/Desktop/optimizer/MATLAB/src/';
else
    % remote conf
    cutest_path='/home/qiw420/linux-cutest/cutest/src/matlab';
    solver_path='/home/qiw420/nonlinearOptimization/MATLAB/algorithms/';
end

% Move to problem directory
cd(sprintf('%s/decoded/%s',user_dir,problem));
% Add source files to path
addpath(cutest_path);

% ------- subject to change for your own solver ------------------
% parse algorithm config
fields = strsplit(algorithm_config, '|');
params_given = struct;
for i=1:length(fields)
    kv = strsplit(fields{i}, '=');
    kv_key = kv{1};
    kv_value = kv{2};
    if strcmp(kv_key,'solver')
        algorithm = kv_value;
        algorithm_full_name = algorithm;
    else
        params_given.(kv_key) = kv_value;
        algorithm_full_name = sprintf('%s-%s', algorithm_full_name, kv_value);
    end
end

% Add matlab solver to path
addpath(solver_path)

% Create problem objects and parameters
P = cutest_setup();

% common parameters
hands.f_hand = @cutest_obj;
hands.g_hand = @cutest_grad;
hands.H_hand = @cutest_hess;
hands.Hv_hand = @cutest_hprod;
x0 = P.x;
hands.l = x0 - rand(size(x0));  % rand: uniform 0-1
hands.u = x0 + rand(size(x0));

params.maxtime    = 90*60;   % max 10 minutes for each instance
params.maxiter    = 1;
params.printlevel = 1;
params.tol        = 1e-5;
params.problem    = problem;

function setparams(fieldname, default_value)
    % is param is given
    if isfield(params_given, fieldname)
        fieldvalue = params_given.(fieldname);
        if isnumeric(default_value)
            fieldvalue = str2num(fieldvalue);
        end
        params.(fieldname) = fieldvalue;
    % otherwise, use default value
    else
        params.(fieldname) = default_value;
    end
end

% Trust Region parameters
%setparams('step_type', 'NewtonCG'); %'NewtonCG';%'CauchyStep'; %'More-Sorensen';
%setparams('algorithm', 'exact');
%setparams('xi', 1);

params.outfileID = fopen(sprintf('%s/%s/log_%s_%s.out', user_dir, algorithm_perf_sub_dir,algorithm_full_name,problem),'w');
% Optimize
%[x, info] = S(hands, x0, params);
try
    S = eval(sprintf('%s(x0,hands,params)', algorithm));
    [x, info] = S.solve();
catch ME
    if strcmp(ME.identifier, 'MATLAB:nomem')
        info.status=-3;
    else
        info.status=-1;
    end
    info.g_evals= -1;
    info.time   = -1;
    info.f_evals= -1;
    info.Hv_evals=-1;
    info.outcome = ME.message;
    info.f       = -1;
    info.norm_r  = -1;
    info.iter    = -1; 
end
status    = info.status;
g_evals   = info.g_evals;
f_evals   = info.f_evals;
Hv_evals  = info.Hv_evals;
outcome   = info.outcome;
time      = info.time/60;
f         = info.f;
norm_r    = info.norm_r;
iter      = info.iter;
n         = length(x0);

% Save solution
fileID = fopen(sprintf('%s/%s/measure_%s.txt', user_dir, algorithm_perf_sub_dir,algorithm_full_name), 'a');
% TODO: correct the order of metrics in plotPerformanceProfile
fprintf(fileID, '%s\t%g\t%g\t%g\t%.5f\t%g\t%g\t%g\t%.5f\t%.5f\t%s\n', problem, n, status,iter, time,g_evals,f_evals, Hv_evals, f, norm_r, outcome);
fclose(fileID);
% ------------------------------------------------------------------

% Delete
cutest_terminate;

% Move back
cd(user_dir);
end
