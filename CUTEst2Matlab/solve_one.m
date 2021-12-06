
problem='SPARSINE';
user_dir='.';
algorithm_config='solver=itrace|algorithm=inexact|xi=100';
%algorithm_config='solver=uncMIN_TR';


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
g0 = norm(hands.g_hand(x0));
params.maxtime    = 60*60;   % max 10 minutes for each instance
params.maxiter    = 1e5;
params.printlevel = 1;
params.subprintlevel = 0;
params.tol        = 1e-4;
params.problem    = problem;

params.algorithm = 'inexact';
params.xi        = 100;
% Trust Region parameters
%params.step_type = 'NewtonCG';
%setparams('step_type', 'NewtonCG'); %'NewtonCG';%'CauchyStep'; %'More-Sorensen';
% below for standard trust region parameters
%setparams("eta_s", 1e-1); 
%params.gamma_d = 0.5;
%params.gamma_i = 2;
%params.eta_vs  = 0.9; %params.eta_s;
%params.delta_max = 1e+8;
%params.gamma_ub = 1e+8;
%params.gamma_lb = 1e-8;
%params.outfileID = fopen(sprintf('%s/%s/log_%s_%s.out', user_dir, algorithm_perf_sub_dir,algorithm_full_name,problem),'w');
params.outfileID = fopen('/home/qiw420/Utilities/CUTEst2Matlab/demo_debug.out', 'w');
% Optimize
try
    [x, info] = S(hands, x0, params);
catch ME
    fprintf('%s',ME.message);
    info.f     = -1;
    info.iter  = -1;
    info.status= -1;
    info.norm_g= -1;
    info.time  = -1;
end
f         = info.f;
iter      = info.iter;
status    = info.status;
g_norm    = info.norm_g;
f_evals   = info.f_evals;
sub_iter  = info.sub_iter;
if status ~= 0
    iter = -1;
end
time      = info.time/60;


% Delete
cutest_terminate;
