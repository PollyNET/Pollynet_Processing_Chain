function [ hBIndx, hTIndx ] = rayleighfit(height, sig_aer, pc, bg, sig_mol, dpIndx, layerThickConstrain, slopeConstrain, SNRConstrain, flagShowDetail)
    %rayleighfit search the clean region with rayleigh fit algorithm.
    %   Usage:
    %       [ hBIndx, hTIndx ] = rayleighfit(height, sig_aer, sig_mol, dpIndx, layerThickConstrain, pureRayleighConstrain, SNRConstrain, flagShowDetail)
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
    %           constrain for the uncertainty of the regressed extinction coefficient in the reference height. (see test 3 in Baars et al, ACP, 2016)
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
    %       an emerging network of automated Raman-polarization lidars for continuous 
    %       aerosol profiling." Atmospheric Chemistry and Physics 16(8): 5111-5137.
    %   History:
    %       2018-01-01. First edition by Zhenping.
    %       2018-07-05. Add the SNR constrain for the reference height.
    %   Copyright:
    %       Ground-based remote sensing. (TROPOS)
    
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
    hIndxT_Test = NaN(1, length(dpIndx));   % index of the top of the qualified region
    hIndxB_Test = NaN(1, length(dpIndx));   % index pf the bottom of the qualified region
    mean_resid = NaN(1, length(dpIndx));   % mean value of the residual
    std_resid = NaN(1, length(dpIndx));   % standard deviation of the residual
    slope_resid = NaN(1, length(dpIndx));   % slope of the residual in the tested region
    msre_resid = NaN(1, length(dpIndx));    % mean square root error of the linear regression in the tested region
    Astat = NaN(1, length(dpIndx));    % Anderson-darling test statistics
    
    % search for the qualified region.
    for iIndx = 1:length(dpIndx) - 1
        test1 = true;   % test result for test1
        test2 = true;   % test result for test2
        test3 = true;   % test result for test3
        test4 = true;   % test result for test4
        test5 = true;   % test result for test5
        iDpBIndx = dpIndx(iIndx); iDpTIndx = dpIndx(iIndx + 1);
        % determine whether the range of the region is larger than layerThickConstrain
        if ~ ((height(iDpTIndx) - height(iDpBIndx)) > layerThickConstrain) && (flagShowDetail)
            fprintf('Region %d: %f - %f is less than %5.1fm\n', iIndx, height(iDpBIndx), height(iDpTIndx), layerThickConstrain);
            continue;
        elseif ~ ((height(iDpTIndx) - height(iDpBIndx)) > layerThickConstrain)
            continue;
        end
    
        % normalize the recorded signal to the molecular signal
        if sum(sig_aer(iDpBIndx:iDpTIndx)) == 0   % not a valid signal profile
            continue;
        end
        sig_factor = nanmean(sig_mol(iDpBIndx:iDpTIndx)) / nanmean(sig_aer(iDpBIndx:iDpTIndx));
        sig_aer_norm = sig_aer * sig_factor;
        std_aer_norm = sig_aer_norm ./ sqrt(pc + bg);
    
        % Quality test 1: Pure Rayleigh conditions. Holger
        % x = height(iDpBIndx:iDpTIndx);
    %     xNorm = double((x - (max(x) - min(x)) / 2) / (max(x) - min(x)));
    %     yTmp = sig_aer_norm(iDpBIndx:iDpTIndx) ./ sig_mol(iDpBIndx:iDpTIndx);
    %     y = yTmp(yTmp > 0);
    %     xNorm = xNorm(yTmp > 0);
    %     y = log(y) / (-2);
    %     yNorm = double((y - (max(y) - min(y)) / 2) / (max(y) - min(y)));
    %     if length(yNorm) <= 10 && flagShowDetail
    %         fprintf('Region %d: signal is too noisy.\n', iIndx);
    %         test1 = false;
    %     elseif length(yNorm) <= 10
    %         test1 = false;
    %     end
    % 
    %     fitRes = fit(xNorm', yNorm', 'poly1');
    %     fitCoef = coeffvalues(fitRes);
    %     fitConf = confint(fitRes);
    %     deltaCoef(1) = abs(fitConf(1, 1) - fitCoef(1));
    %     if ~ (abs(fitRes.p1) <= pureRayleighConstrain * deltaCoef) && (flagShowDetail)
    %         fprintf('Slope: %f, uncertainty: %f\n', fitRes.p1, deltaCoef);
    %         fprintf('Region %d: %f - %f fails in Pure Rayleigh condition test.\n', iIndx, height(iDpBIndx), height(iDpTIndx));
    %       test1 = false;
    %     elseif ~ (abs(fitRes.p1) <= pureRayleighConstrain * deltaCoef)
    %         test1 = false;
    %     end
    
        % Quality test 2: near and far - range cross criteria.
        winLen = fix(layerThickConstrain / (height(2) - height(1)));
        if winLen <= 0
            warning('layerThickConstrain is too small.');
            winLen = 5;
        end
        for jIndx = dpIndx(1):winLen:(length(sig_aer) - winLen - dpIndx(1) + 1)
            deltaSig_aer = nanstd(sig_aer_norm(jIndx:(jIndx + winLen)));
            meanSig_aer = nanmean(sig_aer_norm(jIndx:(jIndx + winLen)));
            meanSig_mol = nanmean(sig_mol(jIndx:(jIndx + winLen)));
            SNRTmp = nansum(pc(jIndx:(jIndx + winLen))) ./ sqrt(nansum(pc(jIndx:(jIndx + winLen)) + bg(jIndx:(jIndx + winLen))));
            SNRTmp(isinf(SNRTmp)) = 0;
            if SNRTmp < sqrt(winLen)
                continue;
            end
    
            if ~ ((meanSig_aer + deltaSig_aer) >= meanSig_mol) && (flagShowDetail)
                fprintf('Region %d: %f - %f fails in near and far-Range cross test.\n', iIndx, height(iDpBIndx), height(iDpTIndx));
                test2 = false;
                break;
            elseif ~ ((meanSig_aer + deltaSig_aer) >= meanSig_mol)
                test2 = false;
                break;
            end
        end
        
        % Quality test 3: white-noise criterion.
        residual = sig_aer_norm(iDpBIndx:iDpTIndx) - sig_mol(iDpBIndx:iDpTIndx);
        x = height(iDpBIndx:iDpTIndx)/1e3;
        if length(residual) <= 10 && flagShowDetail
            fprintf('Region %d: signal is too noisy.\n', iIndx);
            test3 = false;
            continue;
        elseif length(residual) <= 10
            test3 = false;
            continue;
        end
    
        [thisIntersect, thisSlope] = chi2fit(x, residual, std_aer_norm(iDpBIndx:iDpTIndx));
        residual_fit = thisIntersect + thisSlope * x;
        et = residual - residual_fit;
        d = sum((et(2:end) - et(1:(end-1))).^2) / sum(et.^2);
        if ~((d >= 0.5) && (d <= 3.5)) && (flagShowDetail)
            fprintf('Region %d: %f - %f fails in white-noise criterion.\n', iIndx, height(iDpBIndx), height(iDpTIndx));
            test3 = false;
            continue;
        elseif ~((d >= 0.5) && (d <= 3.5))
            test3 = false;
            continue;
        end
        % residual = sig_aer_norm(iDpBIndx:iDpTIndx) - sig_mol(iDpBIndx:iDpTIndx);
        % x = height(iDpBIndx:iDpTIndx)/1e3;
        % x = [ones(length(x), 1), x'];
        % [b, ~, r] = regress(residual', x);
        % warning('off', 'stats:pvaluedw:ExactUnavailable');
        % [~, d] = dwtest(r, x);
        % if ~((d >= 0.5) && (d <= 3.5)) && (flagShowDetail)
        %     fprintf('Region %d: %f - %f fails in white-noise criterion.\n', iIndx, height(iDpBIndx), height(iDpTIndx));
        %     test3 = false;
        %     continue;
        % elseif ~((d >= 0.5) && (d <= 3.5))
        %     test3 = false;
        %     continue;
        % end
    
        % Quality test 4: SNR check
        % which is assured in Douglas-Peucker algorithm
        SNR = nansum(pc(dpIndx(iIndx):dpIndx(iIndx + 1))) ./ ...
               sqrt(nansum(pc(dpIndx(iIndx):dpIndx(iIndx + 1)) + bg(dpIndx(iIndx):dpIndx(iIndx + 1))));
        if isinf(SNR) || isnan(SNR)
            SNR = 0;
        end
        if SNR < SNRConstrain && flagShowDetail
            fprintf('Region %d: %f - %f fails in SNR criterion.\n', iIndx, height(iDpBIndx), height(iDpTIndx));
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
        [~, molSlope, ~, ~] = chi2fit(x, y_mol, zeros(size(x)));
        if ~ (molSlope <= (aerSlope + deltaAerSlope * slopeConstrain) && (molSlope >= (aerSlope - deltaAerSlope * slopeConstrain))) && (flagShowDetail)
            fprintf('Slope_aer: %f, delta_Slope_aer: %f, Slope_mol: %f\n', aerSlope, deltaAerSlope, molSlope);
            fprintf('Region %d: %f - %f fails in slope test.\n', iIndx, height(iDpBIndx), height(iDpTIndx));
            test5 = false;
            continue;
        elseif ~ (molSlope <= (aerSlope + deltaAerSlope * slopeConstrain) && (molSlope >= (aerSlope - deltaAerSlope * slopeConstrain)))
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
        msre_resid(numTest) =  sum(et.^2);
    
        % Anderson Darling test after wikipedia.org  
        normP = normpdf((residual - mean_resid(numTest)) / std_resid(numTest));
        A = sum((2*(1:length(residual)) - 1) .* log(normP) + (2 * (length(residual)-1:-1:0) + 1) .* log(1 - normP));
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
    X_val = abs(mean_resid) .* abs(std_resid) .* abs(slope_resid) .* abs(msre_resid) .* abs(Astat);
    % X_val = abs(slope_resid) .* abs(msre_resid) .* abs(Astat);
    X_val(X_val == 0) = NaN;
    [~, indxBest_Int] = min(X_val);
    
    if flagShowDetail 
        fprintf('The best interval is %f - %f\n', height(hIndxB_Test(indxBest_Int)), height(hIndxT_Test(indxBest_Int)));
    end
    
    hBIndx = hIndxB_Test(indxBest_Int);
    hTIndx = hIndxT_Test(indxBest_Int);
    end