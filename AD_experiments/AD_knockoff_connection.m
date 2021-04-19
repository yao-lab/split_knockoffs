% This script reproduces experiments on the connection selection of
% Alzheimer’s Disease. 
% Connection selection result is shown in the 'result_edge' variable.
% The final workspace is saved to '../results/connection.mat'.

%% Parameter Setting

% add path
root = pwd;
addpath(sprintf('%s/data/AALfeat', root));


data1 = 15;
data2 = 30;

option.q = 0.2;
option.eta = 0.1;
option.method = 'knockoff';
option.stage0 = 'path';
option.normalize = true;
option.lambda = 10.^[0: -0.01: -6];
option.nu = 10.^[-1: 0.1: 1];

num_nu = length(option.nu);
result_edge = cell(num_nu, 1);

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
id = [1:1:90]; % select the Cerebrum
X = X(:,id);
X = split_knockoffs.private.normc(X);

%% Calculate D matrix according to the edge set
p = length(id);
connect = load('aalConect.mat');
Edges = connect.B.Edges;
Edges = Edges.Variables;
Edges = Edges(:,:);
Edges = Edges(ismember(Edges(:,1),id) & ismember(Edges(:,2),id),:);

m = size(Edges,1);
D = zeros(m,p);
for i = 1:m
    D(i,Edges(i,1)) = 1;
    D(i,Edges(i,2)) = -1;
end
D = D(:,id); % select the Cerebrum

%% Split Knockoff
results_number = split_knockoffs.filter(X, D, y, option);

for i = 1: num_nu
    S = results_number{i};
    results = Edges(S, :);
    results(:, 3) = [];
    connection = connect.aalLabel.Var2(results);
    result_edge{i} = connection;
end


% save results
save(sprintf('%s/results/connection', pwd));
