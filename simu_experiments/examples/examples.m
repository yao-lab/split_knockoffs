% This script reproduces the figures of FDR and power in Section 5.2, 5.3, 5.4
% of the paper, comparing the performance of Split Knockoffs and Knockoffs.  
%
% The intermediate result will be automatically saved to
% '../result/temp.mat’ with the proceeding of the calculation. The final
% result will be saved to '../result/examples.mat'. The whole calculation
% may takes hours to finish. 

%% choose parameters

k = 20; % sparsity level
A = 1; % magnitude
n = 350;% sample size
p = 100;% dimention of variables
c = 0.5; % feature correlation

option = struct;
option.q = 0.2;
option.eta = 0.1;
option.stage0 = 'path';
option.normalize = true;
option.lambda = 10.^[0: -0.01: -6];

% settings for nu
expo = [-1: 0.2: 3];
option.nu = 10.^expo;

num_nu = length(option.nu);

%% calculation

% generate D1, D2, and D3
D_G = zeros(p-1, p);

for i = 1:(p-1)
    D_G(i, i) = 1;
    D_G(i, i+1) = -1;
end

D_1 = eye(p);
D_2 = D_G;
D_3 = [eye(p); D_G];
D_s = {D_1, D_2, D_3};

fdr_split = zeros(2, 3, num_nu);
power_split = zeros(2, 3, num_nu);

fdr_knock = zeros(2, 2);
power_knock = zeros(2, 2);

num_method = 2;
method_s = {'knockoff', 'knockoff+'};


% Calculating the examples, the calculation for each example may take 1
% hour.
for meth = 1: 2
    % choose the method of Knockoff or Knockoff+
    method = method_s{meth};
    fprintf('Running examples for %s.\n', method);
    option.method = method;
    for i = 1: 3
        % choose the respective D for each example
        fprintf('Running example for D_%d.\n', i);
        D = D_s{i};
        simu_data = split_knockoffs.private.simu_unit(n, p, D, A, c, k, option);
        fdr_split(meth, i,  :) = simu_data.fdr_split;
        power_split(meth, i,  :) = simu_data.power_split;
        if i < 3
            fdr_knock(meth, i) = simu_data.fdr_knock;
            power_knock(meth, i) = simu_data.power_knock;
        end
        save(sprintf('%s/result/temp',pwd));
    end
end

% save results
save(sprintf('%s/result/examples', pwd));

%% plot for FDR

mark = 'adg';

for i = 1: 3
    x = expo;
    fdr = fdr_split(1, i, :);
    fdr = reshape(fdr, [num_nu, 1]);
    fdr_plus = fdr_split(2, i, :);
    fdr_plus = reshape(fdr_plus, [num_nu, 1]);
    if i < 3
        fdr_knock_ = fdr_knock(1, i);
        fdr_knock_plus_ = fdr_knock(2, i);
        fdr_knock_ = repelem(fdr_knock_, num_nu);
        fdr_knock_plus_ = repelem(fdr_knock_plus_, num_nu);
        
        fig = figure();
        hold on
        grid on
        set(fig, 'DefaultTextInterpreter', 'latex');
        plot(x, fdr,'r')
        plot(x, fdr_plus, 'b')
        plot(x, fdr_knock_,'-.r')
        plot(x, fdr_knock_plus_, '-.b')
        hold off
        
        %axis equal;
        axis([-1,3,0,1]);
        set(gca,'XTick',[-1:0.2:3]);
        set(gca,'YTick',[0:0.2:1]);
        line = refline(0,option.q);
        set(line, 'LineStyle', ':', 'Color', 'black');
        legend('split Knockoff','split Knockoff+', 'Knockoff', 'Knockoff+');
        xlabel('$\log_{10} (\nu)$');
        ylabel('FDR');
    else
        fig = figure();
        hold on
        grid on
        set(fig, 'DefaultTextInterpreter', 'latex');
        plot(x, fdr,'r')
        plot(x, fdr_plus, 'b')
        hold off
        
        %axis equal;
        axis([-1,3,0,1]);
        set(gca,'XTick',[-1:0.2:3]);
        set(gca,'YTick',[0:0.2:1]);
        line = refline(0,option.q);
        set(line, 'LineStyle', ':', 'Color', 'black');
        legend('split Knockoff','split Knockoff+');
        xlabel('$\log_{10} (\nu)$');
        ylabel('FDR');
    end
    saveas(gcf,sprintf('plot/figure_2%s', mark(i)),'png');
end

%% plot for Power

mark = 'beh';

for i = 1: 3
    x = expo;
    power = power_split(1, i, :);
    power = reshape(power, [num_nu, 1]);
    power_plus = power_split(2, i, :);
    power_plus = reshape(power_plus, [num_nu, 1]);
    if i < 3
        power_knock_ = power_knock(1, i);
        power_knock_plus_ = power_knock(2, i);
        power_knock_ = repelem(power_knock_, num_nu);
        power_knock_plus_ = repelem(power_knock_plus_, num_nu);
        
        fig = figure();
        hold on
        grid on
        set(fig, 'DefaultTextInterpreter', 'latex');
        plot(x, power,'r')
        plot(x, power_plus, 'b')
        plot(x, power_knock_,'-.r')
        plot(x, power_knock_plus_, '-.b')
        hold off
        
        

        %axis equal;
        axis([-1,3,0,1]);
        set(gca,'XTick',[-1:0.2:3]);
        set(gca,'YTick',[0:0.2:1]);
        legend('split Knockoff','split Knockoff+', 'Knockoff', 'Knockoff+');
        xlabel('$\log_{10} (\nu)$');
        ylabel('Power');
    else
        fig = figure();
        hold on
        grid on
        set(fig, 'DefaultTextInterpreter', 'latex');
        plot(x, power,'r')
        plot(x, power_plus, 'b')
        hold off
        
        %axis equal;
        axis([-1,3,0,1]);
        set(gca,'XTick',[-1:0.2:3]);
        set(gca,'YTick',[0:0.2:1]);
        legend('split Knockoff','split Knockoff+');
        xlabel('$\log_{10} (\nu)$');
        ylabel('Power');
    end
    saveas(gcf,sprintf('plot/figure_2%s', mark(i)),'png');
end