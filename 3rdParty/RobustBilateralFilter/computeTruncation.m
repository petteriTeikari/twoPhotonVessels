function [M,N]  =  computeTruncation(inImg, sigmar, w, tol)
    T  =  maxFilter(inImg, w);
    N  =  ceil( 0.405 * (T / sigmar)^2 );
    twoN     =  2^N;
    if tol == 0
        M = 0;
    else
        if sigmar > 40
            M = 0;
        elseif sigmar > 10
            sumCoeffs = 0;
            for k = 0 : round(N/2)
                warning('off'); %#ok<WNOFF>
                sumCoeffs = sumCoeffs + nchoosek(N,k)/twoN;
                if sumCoeffs > tol/2
                    M = k;
                    break;
                end
            end
        else
            M = ceil( 0.5*( N - sqrt(4*N*log(2/tol))));
        end
    end
end