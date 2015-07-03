% compute filter and divergence using shiftable algorithm
%
function [F, div] = computeDivergence ...
    (f,barf,sigmas,sigmar,L,w,N,M)
filt   = fspecial('gaussian', [w w], sigmas);
ct = (w+1)/2;
centerWt = filt(ct,ct);
gamma  =  1/(sqrt(N)*sigmar);
twoN    =  2^N;
[m,n] = size(f);
ii = sqrt(-1);
R = zeros(m,n);
S = zeros(m,n);
delR = zeros(m,n);
delS = zeros(m,n);
if M == 0
    for k = M : N - M
        omegak = (2*k - N)*gamma;
          ck = nchoosek(N,k)/twoN;
        U = exp(-ii*omegak*barf);
        W = conj(U);
        V = W.*f;
        barV  = imfilter(V, filt);
        barW = imfilter(W, filt);
        B = ck*U.*barV;
        C = ck*U.*barW;
        R = R + B;
        S  = S + C;
        delR = delR + omegak*B;
        delS = delS  + omegak*C;
    end
    F = real(R./S);
    delR =  centerWt - (1/(2*L+1))^2*ii*delR;
    delS  = -ii*(1/(2*L+1))^2*delS;
else
    sumck = 0;
    sumckwk = 0;
    for k = M : N - M
        omegak = (2*k - N)*gamma;
        warning('off'); %#ok<WNOFF>
        ck = nchoosek(N,k)/twoN;
        U = exp(-ii*omegak*barf);
        W = conj(U);
        V = W.*f;
        barV  = imfilter(V, filt);
        barW = imfilter(W, filt);
        B = ck*U.*barV;
        C = ck*U.*barW;
         sumck = sumck + ck;
         sumckwk = sumckwk + ck*omegak;
        R = R + B;
        S  = S + C;
        delR = delR + omegak*B;
        delS = delS  + omegak*C;
    end
    F =real(R./S);
    delR = centerWt*sumck + ii*(1/(2*L+1))^2* ...
        (centerWt*sumckwk*f - delR);
    delS = ii*(1/(2*L+1))^2*(centerWt*sumckwk - delS);
end
div  = real(sum(sum((S.*delR - R.*delS)./S.^2)));
end
