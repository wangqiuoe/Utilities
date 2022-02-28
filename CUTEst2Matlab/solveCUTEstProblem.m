function solveCUTEstProblem(problem,algorithm_config, user_dir, algorithm_perf_sub_dir)

% Move to problem directory
cd(sprintf('%s/decoded/%s',user_dir,problem));
% Add source files to path
addpath('/home/qiw420/linux-cutest/cutest/src/matlab');

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
addpath('/home/qiw420/nonlinearOptimization/MATLAB/algorithms/')
addpath(sprintf('/home/qiw420/nonlinearOptimization/MATLAB/algorithms/%s', algorithm))

% Create problem objects and parameters
P = cutest_setup();
S = str2func(algorithm);

% common parameters
hands.f_hand = @cutest_obj;
hands.g_hand = @cutest_grad;
hands.H_hand = @cutest_hess;
hands.Hv_hand = @cutest_hprod;
x0 = P.x;
params.maxtime    = 90*60;   % max 10 minutes for each instance
params.maxiter    = 1e+8;
params.printlevel = 1;
params.subprintlevel =0;
params.subsubprintlevel =0;
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
setparams('algorithm', 'exact');
setparams('xi', 1);
% below for standard trust region parameters
%setparams("eta_s", 1e-1); 
%params.gamma_d = 0.5;
%params.gamma_i = 2;
%params.eta_vs  = 0.9; %params.eta_s;
%params.delta_max = 1e+8;
%params.gamma_ub = 1e+8;
%params.gamma_lb = 1e-8;
params.outfileID = fopen(sprintf('%s/%s/log_%s_%s.out', user_dir, algorithm_perf_sub_dir,algorithm_full_name,problem),'w');
% Optimize
%[x, info] = S(hands, x0, params);
try
    [x, info] = S(hands, x0, params);
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
    info.norm_g  = -1;
end
status    = info.status;
g_evals   = info.g_evals;
f_evals   = info.f_evals;
Hv_evals  = info.Hv_evals;
outcome   = info.outcome;
time      = info.time/60;
f         = info.f;
norm_g    = info.norm_g;
n         = length(x0);

% Save solution
fileID = fopen(sprintf('%s/%s/measure_%s.txt', user_dir, algorithm_perf_sub_dir,algorithm_full_name), 'a');
%fprintf(fileID, '%s\t%g\t%g\t%.4f\t%.4f\t%.4f\t%g\t%g\t%g\t%s\n', problem, status, iter, f, g_norm, time,f_evals, Hv_evals, outcome);
fprintf(fileID, '%s\t%g\t%g\t%.5f\t%g\t%g\t%g\t%.5f\t%.5f\t%s\n', problem, n, status, time,g_evals,f_evals, Hv_evals, f, norm_g, outcome);
fclose(fileID);
% ------------------------------------------------------------------

% Delete
cutest_terminate;

% Move back
cd(user_dir);
end
