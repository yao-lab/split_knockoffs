% This script reproduces experiments on lesion region selection of
% Alzheimer’s Disease. 
% Selected regions for split Knockoff are shown in 'result_full' variable. 
% Selected regions for Knockoff are shown in 'result_knockoff' variable.
% The final workspace is saved to '../results/region.mat'.

root = pwd;
addpath(sprintf('%s/data/AALfeat', root));

%% Parameter Setting

data1 = 15;
data2 = 30;

option.q = 0.2;
option.eta = 0.1;
option.method = 'knockoff';
option.stage0 = 'path';
option.k_fold = 5;
option.normalize = true;
option.nu = 10.^[-1: 0.1: 1];
option.lambda = 10.^[0: -0.01: -6];

%% Response Variable Y
% load 15 T data
y_AD = load(sprintf('ADAS_%d_AD.mat', data1)); 
y_AD = y_AD.ADAS;
y_MCI = load(sprintf('ADAS_%d_MCI.mat', data1));
y_MCI = y_MCI.ADAS;
y_NC = load(sprintf('ADAS_%d_NC.mat', data1));
y_NC = y_NC.ADAS;
y1 = [y_AD;y_MCI;y_NC];

% load 30 T data
y_AD = load(sprintf('ADAS_%d_AD.mat', data2)); 
y_AD = y_AD.ADAS;
y_MCI = load(sprintf('ADAS_%d_MCI.mat', data2));
y_MCI = y_MCI.ADAS;
y_NC = load(sprintf('ADAS_%d_NC.mat', data2));
y_NC = y_NC.ADAS;
y2 = [y_AD;y_MCI;y_NC];

y = [y1; y2];
index = find( y < 0);
y(index) = []; % rule out samples with invalid scores
y = split_knockoffs.private.normc(y);


%% Covariates X
% load 15 T data
X_AD = load(sprintf('AAL_%d_AD_feature_TIV.mat', data1));
X_AD = X_AD.feature_TIV;
X_MCI = load(sprintf('AAL_%d_MCI_feature_TIV.mat', data1));
X_MCI = X_MCI.feature_TIV;
X_NC = load(sprintf('AAL_%d_NC_feature_TIV.mat', data1));
X_NC = X_NC.feature_TIV;
X_1 = [X_AD; X_MCI;X_NC];

% load 30 T data
X_AD = load(sprintf('AAL_%d_AD_feature_TIV.mat', data2));
X_AD = X_AD.feature_TIV;
X_MCI = load(sprintf('AAL_%d_MCI_feature_TIV.mat', data2));
X_MCI = X_MCI.feature_TIV;
X_NC = load(sprintf('AAL_%d_NC_feature_TIV.mat', data2));
X_NC = X_NC.feature_TIV;
X_2 = [X_AD; X_MCI;X_NC];

X = [X_1; X_2];
X = double(X);
[n,~] = size(X);
X(index, :) = []; % rule out samples with invalid scores
id = [1:1:90]; % select Cerebrum
X = X(:,id);
X = split_knockoffs.private.normc(X);


%% Set D matrix
p = size(X, 2);
connect = load('aalConect.mat');
D = eye(p);

%% Knockoff
S = split_knockoffs.private.convert_knockoff(X, D, y, option);
result_knockoff = connect.aalLabel.Var2(S);

%% Split Knockoff
num_nu = length(option.nu);
results = split_knockoffs.filter(X, D, y, option);
result_full = cell(num_nu, 1);

for i = 1: num_nu
S = results{i};
result_full{i} = connect.aalLabel.Var2(S);
end

CV_loss = split_knockoffs.cv.model_loss(X, y, results, option);

% save results
save(sprintf('%s/results/region', pwd));