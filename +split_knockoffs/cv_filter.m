function [result, CV_loss, nu_optimal] = cv_filter(X, D, y, option)
% Split Knockoff filter for structural sparsity problem, using cross validation.
% 
% Input Argument
% X : the design matrix.
% y : the response vector.
% D : the linear transform.
% option: options for creating the Knockoff statistics.
%	option.eta : the choice of eta for creating the knockoff copy.
%	option.q: the desired FDR control bound.
%	option.method: 'knockoff' or 'knockoff+'.
%	option.stage0: choose the method to conduct split knockoff.
%       'fixed': fixed intercept assignment for PATH ORDER method.
%           option.beta : the choice of fixed beta for step 0: 
%               'mle': maximum likelihood estimator.
%               'ridge': ridge regression choice beta with lambda = 1/nu.
%               'cv_split': cross validation choice of split LASSO over nu
%               and lambda.
%               'cv_ridge': cross validation choice of ridge regression
%               over lambda.
%       'path': take the regularization path of split LASSO as the intercept
%           assignment for PATH ORDER method.
%       'magnitude': using MAGNITUDE method.
%	option.lambda: a set of lambda appointed for path calculation.
%	option.nu: a set of nu used for Split Knockoffs.
% 	option.k_fold: the fold used in cross validation.
% 	option.cv_rule: the rule used in CV.
%       'min': choose nu with minimal CV loss.
%       'complexity': choose nu with minimal model complexity in the range
%           of 0.99 * CV_loss <= min(CV_loss).
%
% Output Argument
% result: selected features of Split Knockoffs with CV optimal selection of
%   nu. 
% CV_loss: the CV loss of Split Knockoffs w.r.t. nu.
% nu_optimal: the CV optimal nu.

nu_s = option.nu;
[results, CV_loss, complexities] = split_knockoffs.cv.loss(X, D, y, nu_s, option);
switch option.cv_rule
    case 'min'
        index = find(CV_loss == min(CV_loss), 1);
        nu_optimal = nu_s(index);
        result = results{index};
    case 'complexity'
        set = find(0.99 * CV_loss <= min(CV_loss));
        nu_potential = nu_s(set);
        complexities = complexities(set);
        result_cv = results{set};
        index = find(complexities == min(complexities), 1);
        nu_optimal = nu_potential(index);
        result = result_cv{index};
end

end