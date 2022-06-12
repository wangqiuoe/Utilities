function info = solveCUTEstProblemNew(problem,algorithm_config, user_dir, algorithm_perf_sub_dir)

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
cd(sprintf('%s/decoded_dir/%s',user_dir,problem));
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
x0 = P.x;



%% function handles and parameters for local optimizer solver
hands.f_hand = @cutest_obj;
hands.g_hand = @cutest_grad;
hands.H_hand = @cutest_hess;
hands.Hv_hand = @cutest_hprod;
hands.l = P.bl;
hands.u =  P.bu; %x0 + 10;% for debug P.bu;

%% general parameters
params.maxtime    = 60*60;
params.maxiter    = 1e4;
params.printlevel = 1;
params.tol        = 1e-4;
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
params.outfile_name = sprintf('%s/%s/log_%s_%s.out', user_dir, algorithm_perf_sub_dir,algorithm_full_name,problem);
if isfile(params.outfile_name)
    delete(params.outfile_name)
end

%% Optimize
function [f_val,g_val] = cutest_func(x)
    f_val = cutest_obj(x);
    g_val = cutest_grad(x);
end
try

    %% Move x0 if it is not interior
    for idx=1:length(x0)
        % Revise u(i) and l(i) if they are equal 
        if hands.u(idx) == hands.l(idx)

            % if l and u are zero, l = -1 and u = 1 
            if hands.u(idx) == 0
                hands.u(idx) =  1;
                hands.l(idx) = -1;
            else
                hands.u(idx) = hands.u(idx) + 0.1 * abs(hands.u(idx));
                hands.l(idx) = hands.l(idx) - 0.1 * abs(hands.l(idx));
            end
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

    %% check if x0 is an iterior point
    assert (( sum(x0 < hands.u) == length(x0) ) && ( sum(x0 > hands.l) == length(x0) ), 'x0 is not an interior point')

    %%% compute unconstrained sol
    %options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true);
    %fun = @cutest_func;
    %[x_unc, f_unc] = fminunc(fun,x0,options);
    %fprintf('unconstrained norm_x: %.4f, f: %.4f', norm(x_unc), f_unc)
    
    %% for stochastic IPM
    if startsWith(algorithm, 'StochasticIPM')

        % check if deterministic solution exists
        ipm_solution_filename=sprintf('%s/IPMSolution/%s.mat', user_dir, problem);
        assert (isfile(ipm_solution_filename), 'no deterministic solution exists')
        
        % load deterministic sol
        load(ipm_solution_filename);
        x_det=x;
        L_det=L;

        % generate yi
        M = 100;
        y_std = 0.1;
        y = x_det + y_std*randn(length(x_det), M);
        hands.y = y;
        params.L = L_det;
        params.maxiter=1000; % max stochastic gradient evaluations
        params.tol = 1e-4;
    end
    S = eval(sprintf('%s(x0,hands,params)', algorithm));
    
    %% 
    [x, info] = S.solve();
catch ME
    if strcmp(ME.identifier, 'MATLAB:nomem')
        info.status=-3;
    elseif strcmp(ME.message, 'x0 is not an interior point')
        info.status=-4;
    elseif strcmp(ME.message, 'no deterministic solution exists')
        info.status=-5;
    else
        info.status=-1;
    end
    info.time   = -1;
    info.outcome = ME.message;
    info.f       = -1;
    info.iter    = -1; 
end
status    = info.status;
outcome   = info.outcome;
time      = info.time/60;
f         = info.f;
iter      = info.iter;
n         = length(x0);

%% Save solution
measure_filename = sprintf('%s/%s/measure_%s.txt', user_dir, algorithm_perf_sub_dir,algorithm_full_name);
% print header of measure
if ~isfile(measure_filename)
    fileID = fopen(measure_filename, 'w');
    fprintf(fileID, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'problem', 'n', 'status','iter', 'time', 'f', 'outcome');
end
fileID = fopen(measure_filename, 'a');
% TODO: correct the order of metrics in plotPerformanceProfile
fprintf(fileID, '%s\t%g\t%g\t%g\t%.5f\t%.5f\t%s\n', problem, n, status,iter, time,f, outcome);
fclose(fileID);

%% Save x and info.L if startsWith(algorithm, 'IPM')
if strcmp(algorithm, 'IPM') && info.status==1
    L = info.L;
    solution_filename=sprintf('%s/IPMSolution/%s.mat', user_dir, problem);
    save(solution_filename,'x','L')
end
% ------------------------------------------------------------------

%% Delete
cutest_terminate;

%% Move back
cd(user_dir);
end
