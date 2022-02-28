clc;clear;
cd('/Users/wangqi/Desktop/Utilities/CUTEst2Matlab/decoded/DIXMAANB/'); % FMINSRF2 n = 10000, more-sorensen converge slow 
addpath('/usr/local/opt/cutest/libexec/src/matlab');
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/')
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/itrace2/')
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/trace/')
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/uncMIN_TR/')
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/arc/')
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/trntcg/')
% Create problem objects and parameters
%cutest_terminate;
P = cutest_setup();
rng(419);
% common parameters
hands.f_hand = @cutest_obj;
hands.g_hand = @cutest_grad;
hands.H_hand = @cutest_hess;
hands.Hv_hand = @cutest_hprod;
x0 = P.x;
g0 = norm(hands.g_hand(x0));
params.maxtime    = 10*60;   % max 10 minutes for each instance
params.maxiter    = 1e5;
params.printlevel = 1;
params.subprintlevel = 0;
params.subsubprintlevel = 0;
params.tol        = 1e-5;

%params.algorithm='exact';
%params.xi = 0.1;
%[x_t, info_t] = itrace(hands, x0, params);
params.algorithm='inexact';
params.xi = 1;
%profile on -historysize 5000000000
[x_it, info_it] = itrace(hands, x0, params);
%p1 = profile('info');
%profile off
%params.xi = 0.01;
%[x_it_small, info_it_small] = itrace(hands, x0, params);

%params.xi = 0.0001;
%profile on -historysize 5000000000
%[x_arc, info_arc] = arc(hands, x0, params);
%p2 = profile('info');
%profile off
%params.xi = 0.25;
%[x_cg, info_cg] = trntcg(hands, x0, params);
%cutest_terminate;

