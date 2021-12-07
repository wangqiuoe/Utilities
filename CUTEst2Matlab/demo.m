clc;clear;
cd('decoded/SCOSINE/'); % FLETCBV2 n = 10000, more-sorensen converge slow
addpath('/usr/local/opt/cutest/libexec/src/matlab');
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/')
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/itrace/')
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/trace/')
addpath('/Users/wangqi/Desktop/nonlinear-optimization-course/MATLAB/algorithms/uncMIN_TR/')
% Create problem objects and parameters
%cutest_terminate;
P = cutest_setup();
% common parameters
hands.f_hand = @cutest_obj;
hands.g_hand = @cutest_grad;
hands.H_hand = @cutest_hess;
hands.Hv_hand = @cutest_hprod;
x0 = P.x;
g0 = norm(hands.g_hand(x0));
params.maxtime    = 10*60;   % max 10 minutes for each instance
params.maxiter    = 100;
params.printlevel = 1;
params.subprintlevel = 0;
params.tol        = 1e-4;

params.algorithm='inexact';
params.xi = 100;
[x, info] = itrace(hands, x0, params);

%params.step_type='NewtonCG';
%[x, info] = uncMIN_TR(hands, x0, params);


%params.xi = 0.01;
%[x_1, info_1] = itrace(hands, x0, params);

%params.xi = 0.1;
%[x_2, info_2] = itrace(hands, x0, params);


%params.xi = 1;
%[x_3, info_3] = itrace(hands, x0, params);

%params.xi = 100;
%[x_4, info_4] = itrace(hands, x0, params);

%params.algorithm='exact';
%[x_exact, info_exact] = itrace(hands, x0, params);
%params.step_type='More-Sorensen';
%[x_ori, info_ori] = trace(hands, x0, params);
cutest_terminate;