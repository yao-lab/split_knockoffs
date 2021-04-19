% This file reproduces Table 1 of the paper, comparing the performance of
% Split Knockoff with cross validation and Knockoff under differenct
% settings of D; and Figure 5 in Section 5.5 of the paper, showing the
% change of cross validation loss w.r.t. nu.
%
% The intermediate result will be automatically saved to
% '../result/temp.mat’ with the proceeding of the calculation. The final
% result will be saved to '../result/table_1.mat'. The whole calculation
% may takes hours to finish. 
% 
% The performance of Split Knockoff can be found in 'mean_fdr_split',
% 'mean_power_split', 'sd_fdr_split' and 'sd_power_split' variables.
% The performance of Knockoff can be found in 'mean_fdr_knock',
% 'mean_power_knock', 'sd_fdr_knock' and 'sd_power_knock' variables.


k = 20; % sparsity level
A = 1;% magnitude
n = 350;% sample size
p = 100;% dimension of variables
c = 0.5; % feature correlation

option.q = 0.2;
option.eta = 0.1;
option.method = 'knockoff';
option.stage0 = 'path';
option.normalize = true;
option.cv_rule = 'min';
option.lambda = 10.^[0: -0.01: -6];
option.k_fold = 7;

% settings for nu
option.nu = 10.^[-1: 0.4: 3];
num_nu = length(option.nu);

tests = 20;

fdr_split = zeros(3, tests);
power_split = zeros(3, tests);
fdr_knock = zeros(2, tests);
power_knock = zeros(2, tests);

cv_list = zeros(3, num_nu, tests);
chosen_nu = zeros(3, tests);

% generate D
D_G = zeros(p-1, p);

for i = 1:(p-1)
    D_G(i, i) = 1;
    D_G(i, i+1) = -1;
end

D_1 = eye(p);
D_2 = D_G;
D_3 = [eye(p); D_G];
D_s = {D_1, D_2, D_3};

%% Start the simulations

% This loop compares the performance of Knockoff and Split Knockoff with CV
% in the situations that D = D_1, D_2, D_3 respectively.

for test = 1: tests
    fprintf('Running %d percents of the simulations.\n',test/tests*100);
    option.test = test;
    simu_data = split_knockoffs.private.simu_unit_cv(n, p, D_s, A, c, k, option);
    fdr_split(:, test) = simu_data.fdr;
    power_split(:, test) = simu_data.power;
    fdr_knock(:, test) = simu_data.fdr_knock;
    power_knock(:, test) = simu_data.power_knock;
    cv_list(:, :, test) = simu_data.cv_loss;
    chosen_nu(:, test) = simu_data.chosen_nu;
    % save results
    save(sprintf('%s/result/temp', pwd));
end

mean_fdr_split = mean(fdr_split, 2);
mean_power_split = mean(power_split, 2);
sd_fdr_split= sqrt(var(fdr_split));
sd_power_split = sqrt(var(power_split));

mean_fdr_knock = mean(fdr_knock, 2);
mean_power_knock = mean(power_knock, 2);
sd_fdr_knock= sqrt(var(fdr_knock));
sd_power_knock = sqrt(var(power_knock));

% save results
save(sprintf('%s/result/table_1', pwd));

%% plot for cross validation loss

ind = 'abc';

for i = 1: 3
    mean_cv = mean(reshape(cv_list(i, :, :), [num_nu, tests]), 2);
    x = [-1:0.4:3];
    fig = figure();
    hold on
    grid on
    set(fig, 'DefaultTextInterpreter', 'latex');
    plot(x, mean_cv);
    hold off

    set(gca,'XTick',[-1:0.4:3]);
    xlabel('$\log_{10} (\nu)$');
    ylabel('Cross Validation Loss');
    saveas(gcf,sprintf('plot/figure_5%s', ind(i)),'png');
end