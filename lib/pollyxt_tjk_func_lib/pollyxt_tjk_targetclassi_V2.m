function [tc_mask] = pollyxt_tjk_targetclassi_V2(data, config)
%pollyxt_tjk_targetclassi_V2 Aerosol target classification based on algorithms presented in H.Baar et al, 2017, ATM. The inputs of quasi retrieving results are based on the improved quasi retrieving method. Detailed information about this improvement can be found '../../doc/quasi_retrieving_V2.pdf'
%   Example:
%       [tc_mask] = pollyxt_tjk_targetclassi_V2(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       tc_mask: matrix
%			'0: No signal' 
%			'1: Clean atmosphere' 
%			'2: Non-typed particles/low conc.'  
%			'3: Aerosol: small'  
%			'4: Aerosol: large, spherical'  
%			'5: Aerosol: mixture, partly non-spherical'  
%			'6: Aerosol: large, non-spherical'  
%			'7: Cloud: non-typed'  
%			'8: Cloud: water droplets'  
%			'9: Cloud: likely water droplets'  
%			'10: Cloud: ice crystals' 
%			'11: Cloud: likely ice crystal
%   History:
%       2019-08-03. First Edition by Zhenping
%       2019-08-30. Add SNR criteria to treat the bits with low SNR as 'No Signal'.
%   Contact:
%       zhenping@tropos.de

tc_mask = zeros(size(data.att_beta_355));

if isempty(tc_mask)
    return;
end

% some flags
flag_isnan_att_beta_355 = isnan(data.att_beta_355);
flag_isnan_par_beta_1064 = isnan(data.quasi_par_beta_1064_V2);
flag_small_par_beta_1064 = data.quasi_par_beta_1064_V2 < config.clear_thres_par_beta_1064;
flag_large_par_beta_1064 = (data.quasi_par_beta_1064_V2 >= config.turbid_thres_par_beta_1064);
flag_large_par_beta_532 = (data.quasi_par_beta_532_V2 >= config.turbid_thres_par_beta_532);
flag_water_par_depol = data.quasi_parDepol_532_V2 < config.droplet_thres_par_depol;
flag_small_par_depol = (data.quasi_parDepol_532_V2 < config.spheroid_thres_par_depol);
flag_medium_par_depol = (data.quasi_parDepol_532_V2 < config.unspheroid_thres_par_depol) & (data.quasi_parDepol_532_V2 >= config.spheroid_thres_par_depol);
flag_large_par_depol = (data.quasi_parDepol_532_V2 >= config.unspheroid_thres_par_depol);
flag_ice_par_depol = data.quasi_parDepol_532_V2 >= config.ice_thres_par_depol;
flag_ice_vol_depol = data.volDepol_532 >= config.ice_thres_vol_depol;
flag_large_ang = data.quasi_ang_532_1064_V2 >= config.large_thres_ang;
flag_small_ang = data.quasi_ang_532_1064_V2 <= config.small_thres_ang;

%% typing
% aerosol and molecule
tc_mask(~ flag_isnan_att_beta_355) = 1;
tc_mask(~ flag_small_par_beta_1064 & ~ flag_isnan_par_beta_1064) = 2;
tc_mask(flag_large_par_beta_1064 & flag_large_ang & flag_small_par_depol) = 3;
tc_mask(flag_large_par_beta_1064 & flag_large_par_beta_532 & flag_medium_par_depol) = 5;
tc_mask(flag_large_par_beta_1064 & flag_large_par_beta_532 & flag_large_par_depol) = 6;
tc_mask(flag_large_par_beta_1064 & ~ flag_large_ang & flag_small_par_depol) = 4;

% cloud mask
flag_cloud = flag_cloud_search(data.height, data.quasi_par_beta_1064_V2, config);
tc_mask(flag_cloud) = 7;
tc_mask(flag_cloud & flag_water_par_depol) = 9;
tc_mask(flag_cloud & flag_water_par_depol & flag_small_ang) = 8;

% ice mask
tc_mask(flag_large_par_beta_1064 & flag_large_par_beta_532 & flag_ice_vol_depol) = 11;
tc_mask(flag_large_par_beta_1064 & flag_large_par_beta_532 & flag_ice_par_depol) = 10;

%% Post-preprocessing
% if cloud found, set cloud-mask above cloud top to 0
for iTime = 1:length(data.mTime)
    cloudIndx = find(tc_mask(:, iTime) > 6 & tc_mask(:, iTime) < 10, 1);
    nonCloudMask_above_cloud = find(tc_mask(cloudIndx:size(tc_mask, 1), iTime) < 7 | tc_mask(cloudIndx:size(tc_mask, 1), iTime) > 9) + cloudIndx - 1;
    if ~ isempty(nonCloudMask_above_cloud)
        tc_mask(nonCloudMask_above_cloud, iTime) = 0;
    end
end

%% set the value during the depolarization calibration period or in fog conditions to 0
tc_mask(:, data.depCalMask | data.fogMask | data.shutterOnMask) = 0;

%% set the value with low SNR to 0
tc_mask((data.quality_mask_532_V2 ~= 0) | (data.quality_mask_1064_V2 ~= 0) | (data.quality_mask_volDepol_532_V2 ~= 0)) = 0;


function flag_cloud = flag_cloud_search(height, beta_1064, config)

beta_1064(~isfinite(beta_1064)) = 0;
flag_cloud = false(size(beta_1064));
hRes = height(2) - height(1);

jump_distance = 250;   % [m]
jump_hBins = ceil(jump_distance / hRes);

if config.search_cloud_above < jump_distance
    warning('config.search_cloud_above should be larger than jump_distance (%5d).', jump_distance);
    warning('Set config.search_cloud_above equals to jump_distance.');
    config.search_cloud_above = jump_distance;
end
search_bins_above = ceil(config.search_cloud_above / hRes);
search_bins_below = ceil(config.search_cloud_below / hRes);

diff_factor = 0.25;

for iTime = 1:size(beta_1064, 2)
    start_bin = 2;

    while start_bin <= (size(beta_1064, 1) - jump_hBins)
        hIndxHighBeta = find(beta_1064(start_bin:(size(beta_1064, 1) - search_bins_above), iTime) > config.cloud_thres_par_beta_1064, 1) + start_bin - 1;

        if isempty(hIndxHighBeta)
            break;
        end

        if min(beta_1064(hIndxHighBeta:(hIndxHighBeta + jump_hBins), iTime) ./ beta_1064(hIndxHighBeta, iTime)) < 1/config.min_atten_par_beta_1064

            search_start = max(1, hIndxHighBeta - search_bins_below);
            diff_beta_1064 = diff(beta_1064(search_start:hIndxHighBeta, iTime));
            max_diff = max(diff_beta_1064);

            base_cloud = find(diff_beta_1064 > max_diff*diff_factor, 1) + search_start;
            top_cloud = find(beta_1064((hIndxHighBeta + 1):(hIndxHighBeta + search_bins_above), iTime) ~= 0, 1, 'last') + hIndxHighBeta - 1;
            if isempty(top_cloud)
                diff_beta_1064 = diff(beta_1064(hIndxHighBeta:(hIndxHighBeta + search_bins_above), iTime));
                max_diff = max(-diff_beta_1064);
                top_cloud = find(-diff_beta_1064 > max_diff*diff_factor) + hIndxHighBeta - 1;
            end
            
            flag_cloud(base_cloud:top_cloud, iTime) = true;
            start_bin = top_cloud + 1;
        else
            start_bin = hIndxHighBeta + 1;
        end
    end

end