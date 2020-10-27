function solveCUTEstProblem(name,algorithm)

% Add source files to path
addpath('/Users/frankecurtis/Dropbox/git/StochasticSQP/StochasticSQP/problems/');
addpath('/Users/frankecurtis/Dropbox/git/StochasticSQP/StochasticSQP/src/');
addpath('/usr/local/opt/cutest/libexec/src/matlab');

% Move to problem directory
cd(sprintf('/Users/frankecurtis/Dropbox/git/Utilities/CUTEst2Matlab/decoded/%s',name));

% Create objects
P = ProblemCUTEst;
S = StochasticSQP;

% Add file report
S.reporter.addFileReport(Enumerations.R_SOLVER,Enumerations.R_PER_ITERATION,...
                         sprintf('/Users/frankecurtis/Dropbox/git/Utilities/CUTEst2Matlab/output/%s_%s.out',name,algorithm));

% Set options
if strcmp(algorithm,'Subgradient')
  S.options.modifyOption(S.reporter,'direction_computation','Subgradient');
  S.options.modifyOption(S.reporter,'merit_parameter_computation','Fixed');
  S.options.modifyOption(S.reporter,'stepsize_computation','Conservative');
  S.options.modifyOption(S.reporter,'merit_parameter_initial',1e-04);
  S.options.modifyOption(S.reporter,'SCC_stepsize_scaling',1e-01);
end

% Optimize
S.optimize(P);

% Solution (best)
[x,yE,yI,infeasibility,stationarity] = S.solution;

% Save solution
save(sprintf('/Users/frankecurtis/Dropbox/git/Utilities/CUTEst2Matlab/output/%s_%s.mat',name,algorithm),'x','yE','yI','infeasibility','stationarity');

% Delete objects
delete(P);
delete(S);

% Move back
cd('/Users/frankecurtis/Dropbox/git/Utilities/CUTEst2Matlab');
