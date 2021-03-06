% This script reproduces Figure 4 of the paper, comparing the performance
% of Knockoff and Split Knockoff in extreme settings of SNR.
% The final workspace is saved to '../result/snr.mat'.

%% choose parameters

k = 20; % sparsity level
A_s = [0.25, 4]; % magnitude
n = 350;% sample size
p = 100;% dimention of variables
c = 0.5; % feature correlation

option = struct;
option.q = 0.2;
option.eta = 0.1;
option.method = 'knockoff';
option.stage0 = 'path';
option.normalize = true;
option.lambda = 10.^[0: -0.01: -6];

% settings for nu
expo = [-1: 0.2: 3];
option.nu = 10.^expo;

num_nu = length(option.nu);

%% calculation

% generate D
D_G = zeros(p-1, p);

for i = 1:(p-1)
    D_G(i, i) = 1;
    D_G(i, i+1) = -1;
end

D = D_G;

fdr_glmnet = zeros(2, num_nu);
power_glmnet = zeros(2, num_nu);

fdr_knock = zeros(2, 1);
power_knock = zeros(2, 1);


for i = 1: 2 
    A = A_s(i);
    simu_data = split_knockoffs.private.simu_unit(n, p, D, A, c, k, option);
    fdr_glmnet(i,  :) = simu_data.fdr_split;
    power_glmnet(i,  :) = simu_data.power_split;
    fdr_knock(i) = simu_data.fdr_knock;
    power_knock(i) = simu_data.power_knock;
end

% save results
save(sprintf('%s/result/snr', pwd));

%% plot for FDR
x = expo;
fdr_split = fdr_glmnet(1, :);
fdr_split = reshape(fdr_split, [num_nu, 1]);
fdr_split_plus = fdr_glmnet(2, :);
fdr_split_plus = reshape(fdr_split_plus, [num_nu, 1]);
fdr_knock_ = fdr_knock(1);
fdr_knock_plus_ = fdr_knock(2);
fdr_knock_ = repelem(fdr_knock_, num_nu);
fdr_knock_plus_ = repelem(fdr_knock_plus_, num_nu);

fig = figure();
hold on
grid on
set(fig, 'DefaultTextInterpreter', 'latex');
plot(x, fdr_split,'r')
plot(x, fdr_split_plus, 'b')
plot(x, fdr_knock_,'-.r')
plot(x, fdr_knock_plus_, '-.b')
hold off


axis([-1,3,0,1]);
set(gca,'XTick',[-1:0.2:3]);
set(gca,'YTick',[0:0.2:1]);
line = refline(0,option.q);
set(line, 'LineStyle', ':', 'Color', 'black');
legend('split Knockoff (SNR = 0.25)','split Knockoff (SNR = 4)', 'Knockoff (SNR = 0.25)', 'Knockoff (SNR = 4)');
xlabel('$\log_{10} (\nu)$');
ylabel('FDR');

saveas(gcf,'plot/figure_4a','png');

%% plot for Power
x = expo;
power_split = power_glmnet(1, :);
power_split = reshape(power_split, [num_nu, 1]);
power_split_plus = power_glmnet(2, :);
power_split_plus = reshape(power_split_plus, [num_nu, 1]);
power_knock_ = power_knock(1);
power_knock_plus_ = power_knock(2);
power_knock_ = repelem(power_knock_, num_nu);
power_knock_plus_ = repelem(power_knock_plus_, num_nu);

fig = figure();
hold on
grid on
set(fig, 'DefaultTextInterpreter', 'latex');
plot(x, power_split,'r')
plot(x, power_split_plus, 'b')
plot(x, power_knock_,'-.r')
plot(x, power_knock_plus_, '-.b')
hold off


axis([-1,3,0,1]);
set(gca,'XTick',[-1:0.2:3]);
set(gca,'YTick',[0:0.2:1]);
legend('split Knockoff (SNR = 0.25)','split Knockoff (SNR = 4)', 'Knockoff (SNR = 0.25)', 'Knockoff (SNR = 4)');
xlabel('$\log_{10} (\nu)$');
ylabel('Power');

saveas(gcf,'plot/figure_4b','png');