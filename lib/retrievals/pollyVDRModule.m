function [vdr,vdrStd] = pollyVDRModule(data,clFreGrps,flagT,flagC,polCaliFac, polCaliFacStd, smoothWin, PollyConfig)
%% Volume depolarization ratio at 355 nm
vdr = NaN(size(clFreGrps, 1), length(data.height));% VDR should be the same for Klett and raman, thus new variables are introduced
vdrStd = NaN(size(clFreGrps, 1), length(data.height));% VDR should be the same for Klett and raman, thus new variables are introduced


for iGrp = 1:size(clFreGrps, 1)

    if (sum(flagT) ~= 1) || (sum(flagC) ~= 1)
        continue;
    end

    sigT = squeeze(sum(data.signal(flagT, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bgT = squeeze(sum(data.bg(flagT, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    sigC = squeeze(sum(data.signal(flagC, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));
    bgC = squeeze(sum(data.bg(flagC, :, clFreGrps(iGrp, 1):clFreGrps(iGrp, 2)), 3));

    [thisVdr, thisVdrStd] = pollyVDR(sigT, bgT, sigC, bgC, ...
        PollyConfig.TR(flagT), 0, ...
        PollyConfig.TR(flagC), 0, ...
        polCaliFac, polCaliFacStd, smoothWin);

      % VDR should be the same for Klett and raman, thus new variables are introduced
    vdr(iGrp, :) = thisVdr;
    vdrStd(iGrp, :) = thisVdrStd;
end

end