function [vdr,vdrStd] = pollyVDRModuleGHK(data,clFreGrps,flagT,flagC,polCaliEta, voldep_sys_uncertainty, smoothWin, PollyConfig)
%% Volume depolarization ratio at any wavelegth
vdr = NaN(size(clFreGrps, 1), length(data.height));% VDR should be the same for Klett and raman, thus new variables are introduced
vdrStd = NaN(size(clFreGrps, 1), length(data.height));% VDR should be the same for Klett and raman, thus new variables are introduced


for iGrp = 1:size(clFreGrps, 1)

    if (sum(flagT) ~= 1) || (sum(flagC) ~= 1)
        continue;
    end

    sigT = squeeze(sum(data.signal(flagT, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    %bgT = squeeze(sum(data.bg(flagT, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    sigC = squeeze(sum(data.signal(flagC, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    %bgC = squeeze(sum(data.bg(flagC, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    [thisVdr, thisVdrStd] = pollyVDRGHK(sigT, sigC, ...
        PollyConfig.G(flagT), PollyConfig.G(flagC), ...
        PollyConfig.H(flagT), PollyConfig.H(flagC), ...
        polCaliEta, voldep_sys_uncertainty, smoothWin);

      % VDR should be the same for Klett and raman, thus new variables are introduced
    vdr(iGrp, :) = thisVdr;
    vdrStd(iGrp, :) = thisVdrStd;
end

end