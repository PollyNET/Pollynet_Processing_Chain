function [ hBIndx, hTIndx ] = rayleighfit(height, sig_aer, pc, bg, sig_mol, ...
    dpIndx, layerThickConstrain, slopeConstrain, SNRConstrain, flagShowDetail)
%RAYLEIGHFIT search the clean region with rayleigh fit algorithm.
%   Usage:
%       [ hBIndx, hTIndx ] = rayleighfit(height, sig_aer, sig_mol, dpIndx, 
%               layerThickConstrain, pureRayleighConstrain, SNRConstrain, 
%               flagShowDetail)
%   Inputs:
%       height: array
%           height. [m]
%       sig_aer: array
%           range corrected signal. 
%       pc: array
%           photon count signal.
%       bg: array
%           background.
%       sig_mol: array
%           range corrected molecular signal.
%       dpIndx: array
%           index of the region which is calculated by Douglas-Peucker algorithm.
%       layerThickConstrain: float
%           constrain for the reference layer thickness. [m]
%       pureRayleighConstrain: float
%           constrain for the uncertainty of the regressed extinction 
%           coefficient in the reference height. 
%           (see test 3 in Baars et al, ACP, 2016)
%       SNRConstrain: float
%           minimum SNR for the signal at the reference height.
%       flagShowDetail: boolean
%           if flagShowDetail is true, the calculation information will be
%           printed. Default is false.
%   Outputs:
%       hBIndx: int
%           index of the bottom of the searched region. If the region is not
%           found, NaN will be returned.
%       hTIndx: int
%           index of the top of the searched region. If the region is not found,
%           NaN will be returned.
%   References:
%       Baars, H., et al. (2016). "An overview of the first decade of Polly NET: 
%       an emerging network of automated Raman-polarization lidars for 
%       continuous aerosol profiling." Atmospheric Chemistry and Physics 16(8): 
%       5111-5137.
%   History:
%       2018-01-01. First edition by Zhenping.
%       2018-07-05. Add the SNR constrain for the reference height.
%       2019-01-01. change the single array to double to avoid overflow in 
%                   chi2fit.
%       2019-05-26. Strengthen the criteria for Near-Far Range test.
%                   Old: (meanSig_aer + deltaSig_aer) >= meanSig_mol
%                   New: (meanSig_aer + deltaSig_aer/3) >= meanSig_mol
%       2019-08-03. Using the SNR for the final determination. The higher SNR of
%                   the reference, the better.
%       2019-09-15. Fix the bug in slope criteria.
%  Contact:
%       zhenping@tropos.de

if (nargin <= 6)
    error('Not enouth inputs.');
end

if (~ismatrix(sig_aer) || ~ismatrix(sig_mol))
    error('sig_aer and sig_mol must be 1-dimensional array');
end

if ~ (exist('flagShowDetail', 'var') == 1)
    flagShowDetail = false;
end

if isempty(dpIndx)
    warning('dpIndx is empty');
    hBIndx = NaN;
    hTIndx = NaN;
    return;
end

% parameter initialize
numTest = 0;   % number of qualified clean region
hIndxT_Test = NaN(1, length(dpIndx));   % index of the top of the qualified 
                                        % region
hIndxB_Test = NaN(1, length(dpIndx));   % index pf the bottom of the qualified   
                                        % region
mean_resid = NaN(1, length(dpIndx));   % mean value of the residual
std_resid = NaN(1, length(dpIndx));   % standard deviation of the residual
slope_resid = NaN(1, length(dpIndx));   % slope of the residual in the tested 
                                        % region
msre_resid = NaN(1, length(dpIndx));    % mean square root error of the linear 
                                        % regression in the tested region
Astat = NaN(1, length(dpIndx));    % Anderson-darling test statistics
SNR_ref = NaN(1, length(dpIndx));   % SNR of the reference heights

% search for the qualified region.
for iIndx = 1:length(dpIndx) - 1
    test1 = true;   % test result for test1
    test2 = true;   % test result for test2
    test3 = true;   % test result for test3
    test4 = true;   % test result for test4
    test5 = true;   % test result for test5
    iDpBIndx = dpIndx(iIndx); iDpTIndx = dpIndx(iIndx + 1);
    % determine whether the range of the region is larger than 
    % layerThickConstrain
    if ~ ((height(iDpTIndx) - height(iDpBIndx)) > layerThickConstrain) && ...
         (flagShowDetail)
        fprintf('Region %d: %f - %f is less than %5.1fm\n', iIndx, ...
                height(iDpBIndx), height(iDpTIndx), layerThickConstrain);
        continue;
    elseif ~ ((height(iDpTIndx) - height(iDpBIndx)) > layerThickConstrain)
        continue;
    end

    % normalize the recorded signal to the molecular signal
    if sum(sig_aer(iDpBIndx:iDpTIndx)) == 0   % not a valid signal profile
        continue;
    end
    sig_factor = nanmean(sig_mol(iDpBIndx:iDpTIndx)) / ...
                 nanmean(sig_aer(iDpBIndx:iDpTIndx));
    sig_aer_norm = sig_aer * sig_factor;
    std_aer_norm = sig_aer_norm ./ sqrt(pc + bg);

    % Quality test 1: Pure Rayleigh conditions. Holger
    %% it was replaced with similar criteria in test 5.

    % Quality test 2: near and far - range cross criteria.
    winLen = fix(layerThickConstrain / (height(2) - height(1)));
    if winLen <= 0
        warning('layerThickConstrain is too small.');
        winLen = 5;
    end
    for jIndx = dpIndx(1):winLen:(dpIndx(end) - winLen)
        deltaSig_aer = nanstd(sig_aer_norm(jIndx:(jIndx + winLen)));
        meanSig_aer = nanmean(sig_aer_norm(jIndx:(jIndx + winLen)));
        meanSig_mol = nanmean(sig_mol(jIndx:(jIndx + winLen)));
        SNRTmp = polly_SNR(nansum(pc(jIndx:(jIndx + winLen))), ...
                           nansum(bg(jIndx:(jIndx + winLen))));

        if ~ ((meanSig_aer + deltaSig_aer/3) >= meanSig_mol) && (flagShowDetail)
            fprintf(['Region %d: %f - %f fails in near and far-Range ' ...
                     'cross test.\n'], iIndx, height(iDpBIndx), ...
                     height(iDpTIndx));
            test2 = false;
            break;
        elseif ~ ((meanSig_aer + deltaSig_aer/3) >= meanSig_mol)
            test2 = false;
            break;
        end
    end
    
    % Quality test 3: white-noise criterion.
    residual = sig_aer_norm(iDpBIndx:iDpTIndx) - sig_mol(iDpBIndx:iDpTIndx);
    x = height(iDpBIndx:iDpTIndx) / 1e3;
    if length(residual) <= 10 && flagShowDetail
        fprintf('Region %d: signal is too noisy.\n', iIndx);
        test3 = false;
        continue;
    elseif length(residual) <= 10
        test3 = false;
        continue;
    end

    [thisIntersect, thisSlope] = chi2fit(x, double(residual), ...
                                    double(std_aer_norm(iDpBIndx:iDpTIndx)));
    residual_fit = thisIntersect + thisSlope * x;
    et = residual - residual_fit;
    d = sum((et(2:end) - et(1:(end-1))).^2) / sum(et.^2);
    if ~((d >= 1) && (d <= 3)) && (flagShowDetail)
        fprintf('Region %d: %f - %f fails in white-noise criterion.\n', ...
                iIndx, height(iDpBIndx), height(iDpTIndx));
        test3 = false;
        continue;
    elseif ~((d >= 1) && (d <= 3))
        test3 = false;
        continue;
    end

    % Quality test 4: SNR check
    % which is assured in Douglas-Peucker algorithm
    SNR = polly_SNR(nansum(pc(dpIndx(iIndx):dpIndx(iIndx + 1))), ...
                    nansum(bg(dpIndx(iIndx):dpIndx(iIndx + 1))));
    if SNR < SNRConstrain && flagShowDetail
        fprintf('Region %d: %f - %f fails in SNR criterion.\n', iIndx, ...
                height(iDpBIndx), height(iDpTIndx));
        test4 = false;
        continue;
    elseif SNR < SNRConstrain
        test4 = false;
        continue;
    end

    % Quality test 5: slope check
    x = height(iDpBIndx:iDpTIndx);
    yTmp_aer = sig_aer_norm(iDpBIndx:iDpTIndx);
    yTmp_mol = sig_mol(iDpBIndx:iDpTIndx);
    std_yTmp_aer = std_aer_norm(iDpBIndx:iDpTIndx);
    y_aer = yTmp_aer(yTmp_aer > 0);
    y_mol = yTmp_mol(yTmp_aer > 0);
    std_y_aer = std_yTmp_aer(yTmp_aer > 0);
    x = x(yTmp_aer > 0);
    std_y_aer = std_y_aer ./ y_aer;
    y_aer = log(y_aer);
    y_mol = log(y_mol);
    if length(y_aer) <= 10 && flagShowDetail
        fprintf('Region %d: signal is too noisy.\n', iIndx);
        test5 = false;
        continue;
    elseif length(y_aer) <= 10
        test5 = false;
        continue;
    end
    
    [~, aerSlope, ~, deltaAerSlope] = chi2fit(x, y_aer, std_y_aer);
    [~, molSlope, ~, deltaMolSlope] = chi2fit(x, y_mol, zeros(size(x)));
    if ~ (molSlope <= (aerSlope + (deltaAerSlope + deltaMolSlope) * ...
                       slopeConstrain) && ...
         (molSlope >= (aerSlope - (deltaAerSlope + deltaMolSlope) * ...
                       slopeConstrain))) && ...
         (flagShowDetail)
        fprintf('Slope_aer: %f, delta_Slope_aer: %f, Slope_mol: %f\n', ...
                aerSlope, deltaAerSlope, molSlope);
        fprintf('Region %d: %f - %f fails in slope test.\n', iIndx, ...
                height(iDpBIndx), height(iDpTIndx));
        test5 = false;
        continue;
    elseif ~ (molSlope <= (aerSlope + (deltaAerSlope + deltaMolSlope) * ...
                          slopeConstrain) && ...
             (molSlope >= (aerSlope - (deltaAerSlope + deltaMolSlope) * ...
                          slopeConstrain)))
        test5 = false;
        continue;
    end
    
    if ~ (test1 && test2 && test3 && test4 && test5)
        continue;
    end

    % save the statistics to determine which interval is the best.
    numTest = numTest + 1;
    hIndxB_Test(numTest) = dpIndx(iIndx);
    hIndxT_Test(numTest) = dpIndx(iIndx + 1);
    mean_resid(numTest) = nanmean(residual);
    std_resid(numTest) = nanstd(residual);
    slope_resid(numTest) = thisSlope;
    msre_resid(numTest) = sum(et.^2);
    SNR_ref(numTest) = SNR;

    % Anderson Darling test after wikipedia.org  
    normP = normpdf((residual - mean_resid(numTest)) / std_resid(numTest));
    A = sum((2 * (1:length(residual)) - 1) .* log(normP) + ...
            (2 * (length(residual)-1:-1:0) + 1) .* log(1 - normP));
    A = (length(residual) * (-1)) - A/length(residual);
    Astat(numTest) = A * (1+ 0.75/length(residual) + 2.25/length(residual)^2);
end

if numTest == 0
    if (flagShowDetail)
        fprintf('None clean region is found.\n');
    end
    hBIndx = NaN;
    hTIndx = NaN;
    return;
end

% search the best fit region
X_val = abs(mean_resid) .* abs(std_resid) .* abs(slope_resid) .* ...
        abs(msre_resid) .* abs(Astat) ./ SNR_ref;
% X_val = abs(slope_resid) .* abs(msre_resid) .* abs(Astat);
X_val(X_val == 0) = NaN;
[~, indxBest_Int] = min(X_val);

if flagShowDetail 
    fprintf('The best interval is %f - %f\n', ...
            height(hIndxB_Test(indxBest_Int)), ...
            height(hIndxT_Test(indxBest_Int)));
end

hBIndx = hIndxB_Test(indxBest_Int);
hTIndx = hIndxT_Test(indxBest_Int);

end