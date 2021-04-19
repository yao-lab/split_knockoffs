function simu_data = simu_unit_cv(n, p, D_s, A, c, k, option)
% the simulation unit for simulation experiments with cross validation.
%
% input argument
% n: the sample size
% p: the dimension of variables
% D_s: the set of linear transform
% A: SNR
% c: feature correlation
% k: number of nonnulls in beta
% option: option for split knockoffs
%
% output argument
% simu_data: a structure contains the following elements
%   simu_data.fdr: fdr of cv optimal nu in split knockoffs
%   simu_data.power: power of cv optimal nu in split knockoffs
%   simu_data.fdr_knock: fdr of knockoffs
%   simu_data.power_knock: power of knockoffs
%   simu_data.cv_list: length(D_s) * length(nu_s) matrix with cv loss for
%       each nu for each D
%   simu_data.chosen_nu: cv selected nu for each D

sigma = 1; % noise level
test = option.test;
num_nu = length(option.nu);

% generate X
Sigma = zeros(p, p);
for i = 1: p
    for j = 1: p
        Sigma(i, j) = c^(abs(i - j));
    end
end

rng(100);
X = mvnrnd(zeros(p, 1), Sigma, n); % generate X

% generate beta and gamma
beta_true = zeros(p, 1);
for i = 1: k
    beta_true(i, 1) = A;
    if rem(i, 3) == 1
        beta_true(i, 1) = -A;
    end
end

% create matrices to store results
fdr_cv = zeros(3, 1);
power_cv = zeros(3, 1);
cv_list = zeros(3, num_nu);
chosen_nu = zeros(3, 1);
fdr_knockoff = zeros(2, 1);
power_knockoff = zeros(2, 1);

%%%%%%%%%%%%%%% begin simulation %%%%%%%%%%%%%

for D_choice = 1: 3
    
    D = D_s{D_choice};
    
    m = size(D, 1);
    gamma_true = D * beta_true;
    
    % generate varepsilon
    rng(test);
    
    % generate noise and y
    varepsilon = randn(n, 1) * sqrt(sigma);
    y = X * beta_true + varepsilon;
   
    
    % running knockoff as a comparison
    if m <= p
        result = split_knockoffs.private.convert_knockoff(X, D, y, option);
        [fdr_knockoff(D_choice, 1), power_knockoff(D_choice, 1)] = split_knockoffs.private.simu_eval(gamma_true, result);
    end
    
    [result, cv_list(D_choice, :), chosen_nu(D_choice)] = split_knockoffs.cv_filter(X, D, y, option);
    [fdr_cv(D_choice, 1), power_cv(D_choice, 1)] = split_knockoffs.private.simu_eval(gamma_true, result);
end

% compute the means

simu_data = struct;

simu_data.fdr = fdr_cv;
simu_data.power = power_cv;

simu_data.fdr_knock = fdr_knockoff;
simu_data.power_knock = power_knockoff;

simu_data.cv_loss = cv_list;
simu_data.chosen_nu = chosen_nu;

end