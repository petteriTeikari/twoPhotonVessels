function [ima_lambda_opt alpha beta i] = ...
        poisson_nlmeans(ima_nse, ...
                        ima_lambda_init, ...
                        hW, hB, ...
                        tol, maxIter)
                    
                        % maxIter added by Petteri

    % Poisson NL means (by Charles Deledalle)
    % email: deledalle@telecom-paristech.fr

    M = size(ima_nse, 1);
    N = size(ima_nse, 2);

    % Initial and range of the paramters
    alpha_min       = 0.01  * (2*hB+1)^2;
    alpha_max       = 10     * (2*hB+1)^2;
    beta_min        = 0.01  * (2*hB+1)^2;
    beta_max        = 10    * (2*hB+1)^2;
    alpha_start     = 0.1   * (2*hB+1)^2;
    beta_start      = 0.1   * (2*hB+1)^2;

    pures = [];
    alpha       = alpha_start;
    beta        = beta_start;
    i = 1;
    stop = 0;
    ima_lambda_hat = ima_lambda_init;
    iterCount = 0;
    fprintf('   iter: ')
    while ~stop
        
        fprintf('%d ', i)
        iterCount = iterCount + 1;
        
            [ima_lambda_est ...
             ima_pure ...
             ima_dpure_dalpha ...
             ima_d2pure_dalpha2 ...
             ima_dpure_dbeta ...
             ima_d2pure_dbeta2 ...
             ima_d2pure_dalpha_dbeta] = ...
                poisson_nlmeans_kernel(ima_nse, ...
                                       ima_lambda_hat, ...
                                       alpha, ...
                                       beta, ...
                                       hW, hB);
        

        ima_pure = ...
            ima_pure((1+hW+hB):(M-hW-hB), (1+hW+hB):(N-hW-hB));
        ima_dpure_dalpha = ...
            ima_dpure_dalpha((1+hW+hB):(M-hW-hB), (1+hW+hB):(N-hW-hB));
        ima_d2pure_dalpha2 = ...
            ima_d2pure_dalpha2((1+hW+hB):(M-hW-hB), (1+hW+hB):(N-hW-hB));
        ima_dpure_dbeta = ...
            ima_dpure_dbeta((1+hW+hB):(M-hW-hB), (1+hW+hB):(N-hW-hB));
        ima_d2pure_dbeta2 = ...
            ima_d2pure_dbeta2((1+hW+hB):(M-hW-hB), (1+hW+hB):(N-hW-hB));
        ima_d2pure_dalpha_dbeta = ...
            ima_d2pure_dalpha_dbeta((1+hW+hB):(M-hW-hB), (1+hW+hB):(N-hW-hB));

        ima_pure(isnan(ima_pure)) = ...
            max2(ima_pure(~isnan(ima_pure)));
        ima_pure(isinf(ima_pure)) = ...
            max2(ima_pure(~isinf(ima_pure)));
        ima_dpure_dalpha(isnan(ima_dpure_dalpha)) = ...
            min2(ima_dpure_dalpha(~isnan(ima_dpure_dalpha)));
        ima_dpure_dalpha(isinf(ima_dpure_dalpha)) = ...
            min2(ima_dpure_dalpha(~isinf(ima_dpure_dalpha)));
        ima_d2pure_dalpha2(isnan(ima_d2pure_dalpha2)) = ...
            max2(ima_d2pure_dalpha2(~isnan(ima_d2pure_dalpha2)));
        ima_d2pure_dalpha2(isinf(ima_d2pure_dalpha2)) = ...
            max2(ima_d2pure_dalpha2(~isinf(ima_d2pure_dalpha2)));
        ima_dpure_dbeta(isnan(ima_dpure_dbeta)) = ...
            min2(ima_dpure_dbeta(~isnan(ima_dpure_dbeta)));
        ima_dpure_dbeta(isinf(ima_dpure_dbeta)) = ...
            min2(ima_dpure_dbeta(~isinf(ima_dpure_dbeta)));
        ima_d2pure_dbeta2(isnan(ima_d2pure_dbeta2)) = ...
            max2(ima_d2pure_dbeta2(~isnan(ima_d2pure_dbeta2)));
        ima_d2pure_dbeta2(isinf(ima_d2pure_dbeta2)) = ...
            max2(ima_d2pure_dbeta2(~isinf(ima_d2pure_dbeta2)));
        ima_d2pure_dalpha_dbeta(isnan(ima_d2pure_dalpha_dbeta)) = ...
            max2(ima_d2pure_dalpha_dbeta(~isnan(ima_d2pure_dalpha_dbeta)));
        ima_d2pure_dalpha_dbeta(isinf(ima_d2pure_dalpha_dbeta)) = ...
            max2(ima_d2pure_dalpha_dbeta(~isinf(ima_d2pure_dalpha_dbeta)));

        mean_pure                  = mean2(ima_pure);
        mean_dpure_dalpha          = mean2(ima_dpure_dalpha);
        mean_d2pure_dalpha2        = mean2(ima_d2pure_dalpha2);
        mean_dpure_dbeta           = mean2(ima_dpure_dbeta);
        mean_d2pure_dbeta2         = mean2(ima_d2pure_dbeta2);
        mean_dpure_dalpha_dbeta    = mean2(ima_dpure_dbeta);
        mean_d2pure_dalpha_dbeta   = mean2(ima_d2pure_dalpha_dbeta);

        %{
        fprintf('it. %d\tPURE=%f\ttime=%f\n', ...
                i, mean_pure, time)

        fprintf('\tdRda=%f\td2Rda2=%f\ta=%f\n', ...
                mean_dpure_dalpha, ...
                mean_d2pure_dalpha2, ...
                alpha)

        fprintf('\tdRdb=%f\td2Rdb2=%f\tb=%f\n', ...
                mean_dpure_dbeta, ...
                mean_d2pure_dbeta2, ...
                beta)

        fprintf('\td2Rdadb=%f\n', ...
                mean_d2pure_dalpha_dbeta)
        %}

        pures(i) = mean_pure;

        H = ([[abs(mean_d2pure_dalpha2)    mean_d2pure_dalpha_dbeta] ; ...
              [mean_d2pure_dalpha_dbeta    abs(mean_d2pure_dbeta2)]]);

        if (mean_dpure_dalpha == 0 && mean_d2pure_dalpha2 == 0)
            H(1, 1) = 1;
        end
        if (mean_dpure_dbeta == 0 && mean_d2pure_dbeta2 == 0)
            H(2, 2) = 1;
        end
        invH = inv(H);
        alpha_new = alpha ...
            - invH(1, 1) * mean_dpure_dalpha ...
            - invH(1, 2) * mean_dpure_dbeta;
        beta_new = beta ...
            - invH(2, 2) * mean_dpure_dbeta ...
            - invH(2, 1) * mean_dpure_dalpha;
        alpha_new = max([alpha_new alpha_min]);
        alpha_new = min([alpha_new alpha_max]);
        beta_new = max([beta_new  beta_min]);
        beta_new = min([beta_new beta_max]);

        if i <= 1
            chgt_pure = inf;
        else
            chgt_pure = abs((pures(i-1) - pures(i)));
        end

        if chgt_pure < tol
            fprintf('== Converge ==\n');
            ima_lambda_opt = ima_lambda_est;
            stop = 1;
            
        elseif iterCount == maxIter
            fprintf('== Not converged in maxIter iterations ==\n');
            disp(['   .- Change = ', num2str(chgt_pure), '< tolerance = ', num2str(tol)])
            ima_lambda_opt = ima_lambda_est;
            stop = 1;
            
            
        else
            % fprintf('== Change parameters ==\n');
            alpha = alpha_new;
            beta = beta_new;
            i = i + 1;
        end
        
        
        if stop ~= 1
            % disp([' ... iter: ', num2str(i), ' | change: ', num2str(chgt_pure), ', tolerance = ', num2str(tol)])
        end

    end

function M = max2(mat)

    M = max(max(mat));

function m = min2(mat)

    m = min(min(mat));
