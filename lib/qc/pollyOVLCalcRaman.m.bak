function [olFunc, olStd, olFunc0, olAttri] = pollyOVLCalcRaman(Lambda_el, Lambda_Ra, height, sigFRel, sigFRRa, bgFRel, bgFRRa, varargin)
% POLLYOVLCALCRaman calculate overlap function from polly measurements
% based on Wandinger and Ansmann 2002 https://doi.org/10.1364/AO.41.000511
%
% USAGE:
%    [olFunc, olStd,olFunc0, olAttri] = pollyOVLCalc(height, sigFRel, sigFRRa, bgFRel, bgFRRa)
%
% INPUTS:
%    height: array
%        height above ground. (m)
%    sigFRel: array
%        far-field elastic signal.
%    sigFRRa: array
%        far-field Raman signal.
%    bgFRel: array
%        far-field elastic-signal background.
%    bgFRRa: array
%        far-field Raman-signal background.
%
% KEYWORDS:
%    hFullOverlap: numeric
%        minimum height with complete overlap (default: 600). (m)
%    PC2PCR: numeric
%        conversion factor from photon count to photon count rate (default: 1).
%    aerBsC: array
%        particle basckcattering derived with the Raman method (m-1).
%    pressure: array
%        atmospheric pressure profiles (hPa)
%    temperature: array
%        atmospheric temperature profiles (K)
%    AE: numeric
%        Angström exponent
%    smoothbins: numeric
%        number of bins for smoothing
%    hres: numeric
%        instrument height resolution
%    refH: array
%        reference heigh index array (m)
%    refbeta: numeric
%       value of particle baskcattering at reference height
%    smoothklett: numeric
%        Bins of the smoothing window for the signal in Klett_fernald retrieval

% OUTPUTS:
%    olFunc: numeric
%        overlap function.
%    olStd: numeric
%        standard deviation of overlap function.
%    olFunc0: numeric
%        overlap function with no smoothing
%    olAttri: struct
%        sigFRel: numeric
%            far-field signal.
%        sigFRRa: numeric
%            near-field signal.
%        LR_derived: numeric
%            derived LR in iterative procedure
%
% HISTORY:
%    - 2023-06-06: first edition by Cristofer
%
% .. Authors: - jimenez@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'sigFRel', @isnumeric);
addRequired(p, 'sigFRRa', @isnumeric);
addRequired(p, 'bgFRel', @isnumeric);
addRequired(p, 'bgFRRa', @isnumeric);
addParameter(p, 'hFullOverlap', 600, @isnumeric);
addParameter(p, 'PC2PCR', 1, @isnumeric);
addParameter(p, 'aerBsc', 1, @isnumeric);
addParameter(p, 'pressure', 1, @isnumeric);
addParameter(p, 'temperature', 1, @isnumeric);
addParameter(p, 'AE', 1, @isnumeric);
addParameter(p, 'smoothbins', 1, @isnumeric);
addParameter(p, 'hres', 1, @isnumeric);
%for iterative version
addParameter(p, 'refH', 1, @isnumeric);
addParameter(p, 'refbeta', 1, @isnumeric);
addParameter(p, 'smoothklett', 1, @isnumeric);



parse(p, height, sigFRel, sigFRRa, bgFRel, bgFRRa, varargin{:});

olAttri = struct();

if size(p.Results.aerBsc,1)>0
    
    [mBscRa, mExtRa] = rayleigh_scattering(Lambda_Ra, p.Results.pressure, p.Results.temperature + 273.17, 380, 70);
    [~, mExtel] = rayleigh_scattering(Lambda_el, p.Results.pressure, p.Results.temperature + 273.17, 380, 70); % mBscel
    
    mExtRa=mean(mExtRa,1);
    mBscRa=mean(mBscRa,1);
    
    mExtel=mean(mExtel,1);
 %   mBscel=mean(mBscel,1);
    
    sigFRRa0=sigFRRa;

    for i=1:5
        sigFRRa=smooth(sigFRRa,p.Results.smoothbins)';
        sigFRel=smooth(sigFRel,p.Results.smoothbins)';
    end
    
    

     aerBsc_mean=nanmean(p.Results.aerBsc,1);
    
        
        if size(aerBsc_mean,1)>0
            aerBsc_mean(1:5)=aerBsc_mean(5);  %replace first 5 bins by a constant value
        else
            aerBsc_mean=0;
        end
        
        aerBsc_mean0=aerBsc_mean;
        aerBsc_mean=smooth(aerBsc_mean,p.Results.smoothbins)';
        
        
        
    LR0=30:2:80; %LR array to search best LR.
    
    for ii=1:length(LR0)+1
        
        if ii==length(LR0)+1 
        [~,indx_min]=min(diff_norm); %set now the best LR
        LR=LR0(indx_min);
        else
             LR=LR0(ii);
        
        end
       
                %% overlap method (iterative version) %currently noisy and therefore not being saved
%        
%         refH=height([max(p.Results.refH(:,1)) max(p.Results.refH(:,2))]);
%         
%         Delta_ovl=1;
%         sigFRel_it=sigFRel;
%         
%         for i=1:20
%             sigFRel_it=sigFRel_it./Delta_ovl;
% 
%         [Aerbscklett, ~] = pollyFernald(height, sigFRel_it, bgFRel, LR, refH, p.Results.refbeta, mBscel, p.Results.smoothklett);
%         
%         
%         Delta_ovl=1-(aerBsc_mean-Aerbscklett)./(aerBsc_mean+mBscel);
%         
% 
%             
%         end
        
         
        %% overlap calculation (direct version)

        transRa = exp(-cumsum((mExtRa+LR*aerBsc_mean*(Lambda_el/Lambda_Ra)^p.Results.AE) .* [height(1), diff(height)]));
        transel = exp(-cumsum((mExtel+LR*aerBsc_mean) .* [height(1), diff(height)]));
        transRa0 = exp(-cumsum((mExtRa+LR*aerBsc_mean0*(Lambda_el/Lambda_Ra)^p.Results.AE) .* [height(1), diff(height)]));
        transel0 = exp(-cumsum((mExtel+LR*aerBsc_mean0) .* [height(1), diff(height)]));
        
        
        if (~ isempty(sigFRRa)) && (~ isempty(sigFRel))
            fullOverlapIndx = find(height >= p.Results.hFullOverlap, 1);
            if isempty(fullOverlapIndx)
                error('The index with full overlap can not be found.');
            end
        end
        
        olFunc=sigFRRa.*height.*height./mBscRa./transel./transRa;
        olFunc0=sigFRRa0.*height.*height./mBscRa./transel0./transRa0;

        for i=1:5
            olFunc=smooth(olFunc,3)';
        end
        
        [ovl_norm, ~, ~] = mean_stable(olFunc, 40, fullOverlapIndx-round(37.5/p.Results.hres), fullOverlapIndx+round(2250/p.Results.hres), 0.1);
        [ovl_norm0, ~, ~] = mean_stable(olFunc0, 40, fullOverlapIndx-round(37.5/p.Results.hres), fullOverlapIndx+round(2250/p.Results.hres), 0.1);
        
        if (~isempty(ovl_norm) && length(ovl_norm)==1)
            olFunc=olFunc/ovl_norm;
        else
            olFunc= olFunc/nanmean(olFunc(fullOverlapIndx+round(150/p.Results.hres):fullOverlapIndx+round(1500/p.Results.hres)));
        end
        
        if (~isempty(ovl_norm0) && length(ovl_norm0)==1)
            olFunc0=olFunc0/ovl_norm0;
        else
            olFunc0= olFunc0/nanmean(olFunc0(fullOverlapIndx+round(150/p.Results.hres):fullOverlapIndx+round(1500/p.Results.hres)));
        end
        
        bin_ini=ceil(180/p.Results.hres); %first bin to start searching full overlap height. % Please replace the 180 by a paramter in future.
 
        full_ovl_indx=find(diff(olFunc(bin_ini:end))<=0,1,'first')+bin_ini-1;%-1+1  % estimated full overlap height.
            
        if isempty(full_ovl_indx)
            full_ovl_indx=fullOverlapIndx;
        end
        
        %olFunc0=olFunc0/olFunc(full_ovl_indx); %normalize raw version to this estimated full_ovl_indx.
              
        diff_norm(ii)=nansum(abs(1-olFunc(full_ovl_indx:full_ovl_indx+round(1500/p.Results.hres))));
        
        olFunc(full_ovl_indx:end)=olFunc(full_ovl_indx);
        olFunc=olFunc/olFunc(full_ovl_indx); %renormalization
        
        if (full_ovl_indx-bin_ini)<1
            full_ovl_indx=bin_ini+1;
        end
            
        [~, norm_index0]=max(olFunc(full_ovl_indx-bin_ini:full_ovl_indx+bin_ini*3));
        norm_index=norm_index0+full_ovl_indx-bin_ini-1;
        olFunc=olFunc./mean(olFunc(norm_index-1:norm_index+1));
        
        half_ovl_indx=find(olFunc>=0.95,1,'first');%-1+1
        
        if isempty(half_ovl_indx)
            half_ovl_indx=full_ovl_indx-floor(150/p.Results.hres); % I guess it must be 180 as well. Please replace by paramter
        end
        %smoothing before full overlap to avoid oscilations on that part.
        for i=1:6
            %smoothing before full overlap to avoid S-shape near to the
            %full overlap.
            olFunc(half_ovl_indx:norm_index+round(bin_ini/2))=smooth(olFunc(half_ovl_indx:norm_index+round(bin_ini/2)),5)';
            
        end
        end
        
        olFunc(olFunc<1e-5)=1e-5; %set a minimum possible value, avoid zeros and negative

    end
    
   olFunc=olFunc';
   olFunc0=olFunc0';
    
    olStd=[];
    
    if (~ isempty(sigFRel)) && (~ isempty(sigFRRa))
        olAttri.sigFRelel = sigFRel * p.Results.PC2PCR;
        olAttri.sigNRRa = sigFRRa * p.Results.PC2PCR;
        olAttri.LR_derived=LR;
    end
    
end

end
