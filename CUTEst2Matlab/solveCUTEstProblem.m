function solveCUTEstProblem(name,algorithm, user_dir, algorithm_perf_sub_dir)

% Move to problem directory
cd(sprintf('%s/decoded/%s',user_dir,name));
% Add source files to path
addpath('/usr/local/opt/cutest/libexec/src/matlab');

% ------- subject to change for your own solver ------------------
% Add matlab solver to path
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/')
addpath(sprintf('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/%s', algorithm))

% Create problem objects and parameters
P = cutest_setup();
S = str2func(algorithm);

% common parameters
[n,~] = cutest_dims();
hands.f_hand = @cutest_obj;
hands.g_hand = @cutest_grad;
hands.H_hand = @cutest_hess;
hands.Hv_hand = @cutest_hprod;
x0 = P.x;
params.maxtime    = 10*60;   % max 10 minutes for each instance
params.maxiter    = 1e+5;
params.printlevel = 0;
params.tol        = 1e-8;

% Trust Region parameters
params.step_type   = 'NewtonCG'; %'NewtonCG';%'CauchyStep'; %'More-Sorensen';
params.gamma_d = 0.5;
params.gamma_i = 2;
params.eta_vs  = 0.1;
params.eta_s   = 0.1;
params.delta_max = 1e+8;
params.gamma_ub = 1e+8;
params.gamma_lb = 1e-8;

% Optimize
[x, info] = S(hands, x0, params);
f         = info.f;
iter      = info.iter;
status    = info.status;
if status ~= 0
    iter = -1;
    f    = -1;
end

% Save solution
fileID = fopen(sprintf('%s/%s/%s.txt', user_dir, algorithm_perf_sub_dir, algorithm), 'a');
fprintf(fileID, '%s\t%g\t%.8f\n', name, iter, f);
fclose(fileID);
% ------------------------------------------------------------------

% Delete
cutest_terminate;

% Move back
cd(user_dir);
