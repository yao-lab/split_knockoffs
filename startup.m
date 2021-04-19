% add path
addpath(pwd)

% check dependency
if ~exist('glmnet_matlab','dir')  % return('Did not find glmnet_matlab!')
    disp('Package glmnet_matlab is required!')
    addpath('../glmnet_matlab/')
end