function flagCloudFree = polly_cloudscreen(height, signal, slope_thres, search_region)
    %polly_cloudscreen search cloud-free profiles
    %	Usage:
    %		flagCloudFree = polly_cloudscreen(height, signal, slope_thres, search_region)
    %	Inputs:
    %		height: array
    %			height. [m]
    %		signal: array
    %			photon count rate. [MHz] height * time
    %		slope_thres: float
    %			threshold of the slope to determine whether there is strong backscatter signal. [MHz*m]
    %		search_region: 2-elements array
    %			[base, top]. [m]
    %	Outputs:
    %		flagCloudFree: boolean
    %			whether the profile is cloud free. 
    %	History:
    %		2018-03-04. First edition by zhenping.
    %	Copyright:
    %		Ground-based remote sensing group. (TROPOS)
    
    if nargin < 4
        error('Not enough inputs!')
    end
    
    if search_region(2) <= height(1)
        error('not a valid search_region.');
    end
    
    if search_region(1) < height(1)
        warning('Base of search_region is lower than %f, set it to be %f', height(1), height(1));
        search_region(1) = height(1);
    end
    
    flagCloudFree = false(1, size(signal, 2));
    
    % Range Corrected Signal
    RCS = signal .* repmat(height', 1, size(signal, 2)).^2;
    
    search_indx = int32((search_region - height(1))/(height(2) - height(1))) + 1;
    
    for indx = 1:size(signal, 2)
        
        if isnan(RCS(1, indx))
            continue;
        end
    
        slope = [0; diff(RCS(:, indx))]/(height(2) - height(1));
    
        if isempty(find(slope(search_indx(1):search_indx(2)) >= slope_thres, 1))
            flagCloudFree(indx) = true;
        end
    
    end
    
end