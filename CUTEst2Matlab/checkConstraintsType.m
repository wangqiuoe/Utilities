function checkConstraintsType(name, user_dir)

% Add CUTEst-to-Matlab directory to path
addpath('/usr/local/opt/cutest/libexec/src/matlab');

% Set output file handles
foutu = fopen('list_unconstrained.txt','a');
foute = fopen('list_equality_constrained.txt','a');
foutg = fopen('list_generally_constrained.txt','a');

% Move to directory of problem 'name' (input to this function)
cd(sprintf('%s/decoded/%s',user_dir,name));

% Set up CUTEst
prob = cutest_setup();

% Determine number of variables
n_vars = prob.n;

% Determine numbers of constraints
% CUTEst returns 1e+20 for infinity
n_conb = sum(prob.bl > -1e+18) + sum(prob.bu < 1e+18);
n_cons = prob.m;
if n_cons == 0
  n_coni = 0;
  n_cone = 0;
else
  n_coni = sum(prob.cl < prob.cu);
  n_cone = n_cons - n_coni;
end

% Terminate CUTEst
cutest_terminate;

% Move back to script directory
cd(user_dir);

% Print sizes
fileID = fopen(sprintf('%s/problem_info.txt', user_dir), 'a');
fprintf(fileID, '%10s, variables = %8d, equality = %8d, inequality = %8d, bounds = %8d\n',name, n_vars,n_cone,n_coni,n_conb);
fclose(fileID);

% Add problem name to appropriate list
if n_conb == 0 && n_cons == 0
  fprintf(foutu,'%s\n',name);
  fprintf(' UNCONSTRAINED!\n');
elseif n_conb == 0 && n_cons > 0 && n_cone == n_cons
  fprintf(foute,'%s\n',name);
  fprintf(' EQUALITY CONSTRAINED!\n');
else
  fprintf(foutg,'%s\n',name);
  fprintf('\n');
end

% Close files
fclose(foutu);
fclose(foute);
fclose(foutg);

