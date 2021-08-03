function [tc_mask] = targetClassify(height, attBeta532, quasiBsc1064, quasiBsc532, quasiPDR532, VDR532, quasiAE, varargin)
% TARGETCLASSIFY aerosol/cloud target classification.
% USAGE:
%    [tc_mask] = targetClassify(height, attBeta532, quasiBsc1064, quasiBsc532, quasiPDR532, VDR532, quasiAE)
% INPUTS:
%   height: numeric
%       height. (m)
%   attBeta532: matrix (height x time)
%       attenuated backscatter at 532 nm.
%   quasiBsc1064: matrix (height x time)
%       quasi particle backscatter at 1064 nm. (m^{-1}sr^{-1})
%   quasiBsc532: matrix (height x time)
%       quasi particle backscatter at 532 nm. (m^{-1}sr^{-1})
%   quasiPDR532: matrix (height x time)
%       quais particle depolarization ratio at 532 nm
%   VDR532: matrix (height x time)
%       volume depolarization ratio at 532 nm
%   quasiAE: matrix (height x time)
%       quasi Ångström exponents.
% KEYWORDS:
%   clearThresBsc1064: numeric
%   turbidThresBsc1064: numeric
%   turbidThresBsc532: numeric
%   dropletThresPDR: numeric
%   spheriodThresPDR: numeric
%   unspheroidThresPDR: numeric
%   iceThresVDR: numeric
%   iceThresPDR: numeric
%   largeThresAE: numeric
%   smallThresAE: numeric
%   cloudThresBsc1064: numeric
%   minAttnRatioBsc1064: numeric
%   searchCloudAbove: numeric
%   searchCloudBelow: numeric
%   hFullOL: numeric
% OUTPUTS:
%   tc_mask: matrix
%           '0: No signal' 
%           '1: Clean atmosphere' 
%           '2: Non-typed particles/low conc.'  
%           '3: Aerosol: small'  
%           '4: Aerosol: large, spherical'  
%           '5: Aerosol: mixture, partly non-spherical'  
%           '6: Aerosol: large, non-spherical'  
%           '7: Cloud: non-typed'  
%           '8: Cloud: water droplets'  
%           '9: Cloud: likely water droplets'  
%           '10: Cloud: ice crystals' 
%           '11: Cloud: likely ice crystal
% REFERENCES:
%   Baars, H., Seifert, P., Engelmann, R. & Wandinger, U. Target categorization of aerosol and clouds by continuous multiwavelength-polarization lidar measurements. Atmospheric Measurement Techniques 10, 3175-3201, doi:10.5194/amt-10-3175-2017 (2017).
% EXAMPLE:
% HISTORY:
%    2021-06-05: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'attBeta532', @isnumeric);
addRequired(p, 'quasiBsc1064', @isnumeric);
addRequired(p, 'quasiBsc532', @isnumeric);
addRequired(p, 'quasiPDR532', @isnumeric);
addRequired(p, 'VDR532', @isnumeric);
addRequired(p, 'quasiAE', @isnumeric);
addParameter(p, 'clearThresBsc1064', 1e-8, @isnumeric);
addParameter(p, 'turbidThresBsc1064', 2e-7, @isnumeric);
addParameter(p, 'turbidThresBsc532', 2e-7, @isnumeric);
addParameter(p, 'dropletThresPDR', 0.05, @isnumeric);
addParameter(p, 'spheriodThresPDR', 0.07, @isnumeric);
addParameter(p, 'unspheroidThresPDR', 0.2, @isnumeric);
addParameter(p, 'iceThresVDR', 0.3, @isnumeric);
addParameter(p, 'iceThresPDR', 0.35, @isnumeric);
addParameter(p, 'largeThresAE', 0.75, @isnumeric);
addParameter(p, 'smallThresAE', 0.5, @isnumeric);
addParameter(p, 'cloudThresBsc1064', 2e-5, @isnumeric);
addParameter(p, 'minAttnRatioBsc1064', 10, @isnumeric);
addParameter(p, 'searchCloudAbove', 300, @isnumeric);
addParameter(p, 'searchCloudBelow', 100, @isnumeric);
addParameter(p, 'hFullOL', 600, @isnumeric);

parse(p, height, attBeta532, quasiBsc1064, quasiBsc532, quasiPDR532, VDR532, quasiAE, varargin{:});

tc_mask = zeros(size(attBeta532));

% flags
flag_isnan_att_beta_532 = isnan(attBeta532);
flag_isnan_par_beta_1064 = isnan(quasiBsc1064);
flag_small_par_beta_1064 = quasiBsc1064 < p.Results.clearThresBsc1064;
flag_large_par_beta_1064 = (quasiBsc1064 >= p.Results.turbidThresBsc1064);
flag_large_par_beta_532 = (quasiBsc532 >= p.Results.turbidThresBsc532);
flag_water_par_depol = quasiPDR532 < p.Results.dropletThresPDR;
flag_small_par_depol = (quasiPDR532 < p.Results.spheriodThresPDR);
flag_medium_par_depol = (quasiPDR532 < p.Results.unspheroidThresPDR) & (quasiPDR532 >= p.Results.spheriodThresPDR);
flag_large_par_depol = (quasiPDR532 >= p.Results.unspheroidThresPDR);
flag_ice_par_depol = quasiPDR532 >= p.Results.iceThresPDR;
flag_ice_vol_depol = VDR532 >= p.Results.iceThresVDR;
flag_large_ang = quasiAE >= p.Results.largeThresAE;
flag_small_ang = quasiAE <= p.Results.smallThresAE;

%% typing
% aerosol and molecule
tc_mask(~ flag_isnan_att_beta_532) = 1;
tc_mask(~ flag_small_par_beta_1064 & ~ flag_isnan_par_beta_1064) = 2;
tc_mask(flag_large_par_beta_1064 & flag_large_ang & flag_small_par_depol) = 3;
tc_mask(flag_large_par_beta_1064 & flag_large_par_beta_532 & flag_medium_par_depol) = 5;
tc_mask(flag_large_par_beta_1064 & flag_large_par_beta_532 & flag_large_par_depol) = 6;
tc_mask(flag_large_par_beta_1064 & ~ flag_large_ang & flag_small_par_depol) = 4;

% cloud mask
flag_cloud = detectLiquidBits(height, quasiBsc1064, varargin{:});
tc_mask(flag_cloud) = 7;
tc_mask(flag_cloud & flag_water_par_depol) = 9;
tc_mask(flag_cloud & flag_water_par_depol & flag_small_ang) = 8;

% ice mask
tc_mask(flag_large_par_beta_1064 & flag_large_par_beta_532 & flag_ice_vol_depol) = 11;
tc_mask(flag_large_par_beta_1064 & flag_large_par_beta_532 & flag_ice_par_depol) = 10;

%% Post-preprocessing
% if cloud found, set cloud-mask above cloud top to 0
for iPrf = 1:size(attBeta532, 2)
    cloudIndx = find(tc_mask(:, iPrf) > 6 & tc_mask(:, iPrf) < 10, 1);
    nonCloudMask_above_cloud = find(tc_mask(cloudIndx:size(tc_mask, 1), iPrf) < 7 | tc_mask(cloudIndx:size(tc_mask, 1), iPrf) > 9) + cloudIndx - 1;
    if ~ isempty(nonCloudMask_above_cloud)
        tc_mask(nonCloudMask_above_cloud, iPrf) = 0;
    end
end

% set mask to 0 below full overlap height
hIndxFullOverlap = find(height >= p.Results.hFullOL, 1);
if isempty(hIndxFullOverlap)
    hIndxFullOverlap = 70;
end
tc_mask(1:hIndxFullOverlap, :) = 0;

end