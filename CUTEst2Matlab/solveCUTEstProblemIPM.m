function info = solveCUTEstProblemIPM(problem,algorithm_config, user_dir, algorithm_perf_sub_dir)

if startsWith(pwd,'/Users/wangqi/')
    % local conf
    cutest_path='/usr/local/opt/cutest/libexec/src/matlab'; 
    solver_path='/Users/wangqi/Desktop/optimizer/MATLAB/src/';
else
    % remote conf
    cutest_path='/home/qiw420/linux-cutest/cutest/src/matlab';
    solver_path='/home/qiw420/optimizer/MATLAB/src/';
end

% Move to problem directory
cd(sprintf('%s/decoded_bound/%s',user_dir,problem));
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
    elseif strcmp(kv_key,'opt_mse')
        opt_mse = str2num(kv_value);
    else
        params_given.(kv_key) = kv_value;
        algorithm_full_name = sprintf('%s-%s', algorithm_full_name, kv_value);
    end
end

% Add matlab solver to path
addpath(solver_path)

% Create problem objects and parameters
P = cutest_setup();
x0 = P.x;

%% function handles and parameters for local optimizer solver
hands.f_hand = @cutest_obj;
hands.g_hand = @cutest_grad;
hands.H_hand = @cutest_hess;
hands.Hv_hand = @cutest_hprod;
hands.l = P.bl;
hands.u =  P.bu; %x0 + 10;% for debug P.bu;

% Move x0 if it is not interior
for idx=1:length(x0)

    % Revise u(i) and l(i) if they are equal, l = x0 - 1 and u = x0 + 1 
    if hands.u(idx) == hands.l(idx)
        hands.l(idx) = x0(idx) - 1;
        hands.u(idx) = x0(idx) + 1;
    end

    if (hands.u(idx) == 1e20) && (hands.l(idx) == -1e20)
        hands.u(idx) = x0(idx) + 0.1;
        hands.l(idx) = x0(idx) - 0.1;
    end
    
    % Revise x0(i) if x0(i) is not interior between l(i) and u(i)
    if (x0(idx) >= hands.u(idx)) || (x0(idx) <= hands.l(idx))
        if (hands.u(idx) == 1e20) && (hands.l(idx) == -1e20)
            x0(idx) = 0;
        elseif (hands.u(idx) == 1e20)
            x0(idx) = hands.l(idx) + 1;
        elseif (hands.l(idx) == -1e20)
            x0(idx) = hands.u(idx) - 1;
        else
            x0(idx) = (hands.u(idx) + hands.l(idx)) / 2;
        end
    end
end

% general parameters
params.maxtime    = 60*60;
params.maxiter    = 100;
params.printlevel = 1;
params.tol        = 1e-4;
params.problem    = problem;
params.outfile_name = sprintf('%s/%s/log_%s_%s.out', user_dir, algorithm_perf_sub_dir,algorithm_full_name,problem);

try

    % check if x0 is an iterior point
    assert (( sum(x0 < hands.u) == length(x0) ) && ( sum(x0 > hands.l) == length(x0) ), 'x0 is not an interior point')

    ipm_solution_filename=sprintf('%s/IPMSolution/%s.mat', user_dir, problem);

    % solve f_cutest by IPM solver
    if ~opt_mse

        ipm = IPM(x0,hands,params);
        [x, info] = ipm.solve();
        x_star = x;
        info_star = info;
        if info.status==1
            save(ipm_solution_filename,'x_star','info_star')
        end

    % solve (f_cutest - fi)^2 MSE problem
    elseif opt_mse

        % rename problem
        problem = sprintf('%s_mse', problem);
        
        % get x_star by loading from file
        assert( isfile(ipm_solution_filename), 'no f_cutest solution exists')
        ipm_sol=load(ipm_solution_filename);
        x_star=ipm_sol.x_star;
        info_star=ipm_sol.info_star;
    
        % generate m xi
        m  = 1000;
        sigma = 0.001*eye(length(x_star));
        rng(0);
        xis = mvnrnd(x_star', sigma, m)';      % n by m
        fis = zeros(m,1);
        for i = 1:m
            fis(i) = cutest_obj(xis(:,i));
        end

        % construct mse objective and gradient function
        hands.m = m;
        hands.f_hand = @(x) 1/m * sum((cutest_obj(x) - fis).^2);
        hands.g_hand = @(x) 2/m .* cutest_grad(x) * ones(1, m) * (cutest_obj(x) - fis);
        hands.sf_hand = @(x, idx) 1/length(idx) * sum((cutest_obj(x) - fis(idx)).^2);
        hands.sg_hand = @(x, idx) 2/length(idx) .* cutest_grad(x) * ones(1, length(idx)) * (cutest_obj(x) - fis(idx));

        % construct params
        clear params;
        params.problem          = problem;
        params.printlevel       = 1;
        params.outfile_name     = sprintf('%s/%s/log_%s_%s.out', user_dir, algorithm_perf_sub_dir,algorithm_full_name,problem);
        if strcmp(algorithm, 'IPM')
            params.maxtime      = 60*60;   
            params.maxiter      = 100;
            params.tol          = 1e-4;
        elseif strcmp(algorithm, 'StochasticIPM')
            % params that are to be tuned
            params.max_subiter  = str2num(params_given.max_subiter);
            params.strategy     = params_given.strategy;
            % fixed params
            params.maxtime      = 60*60;   
            params.maxiter      = 10000;
            params.Lf           = abs(info_star.Lf * sum(2 * info_star.f_max - fis));
            params.alpha_init   = 1e-3;
        end

        % call solver
        S = eval(sprintf('%s(x0,hands,params)', algorithm));
        [x, info] = S.solve();

    end % if optimize MSE problem

catch ME
    if strcmp(ME.identifier, 'MATLAB:nomem')
        info.status=-3;
    elseif strcmp(ME.message, 'x0 is not an interior point')
        info.status=-4;
    elseif strcmp(ME.message, 'no f_cutest solution exists')
        info.status=-5;
    else
        info.status=-1;
    end
    info.outcome = ME.message;
    info.time    = -1;
    info.iter    = -1; 
    info.f       = nan;
    info.norm_r  = nan;
end % try

status    = info.status;
outcome   = info.outcome;
time      = info.time/60;
iter      = info.iter;
f         = info.f;
norm_r    = info.norm_r;
n         = length(x0);

%% Save solution
measure_filename = sprintf('%s/%s/measure_%s.txt', user_dir, algorithm_perf_sub_dir,algorithm_full_name);
% print header of measure
if ~isfile(measure_filename)
    fileID = fopen(measure_filename, 'w');
    fprintf(fileID, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'problem', 'n', 'status','iter', 'time', 'f', 'norm_r', 'outcome');
end
% print metrics of instance
fileID = fopen(measure_filename, 'a');
% TODO: correct the order of metrics in plotPerformanceProfile
fprintf(fileID, '%s\t%g\t%g\t%g\t%.5f\t%.5e\t%.5e\t%s\n', problem, n, status,iter, time,f, norm_r, outcome);
fclose(fileID);

%% Delete
cutest_terminate;

%% Move back
cd(user_dir);
end
