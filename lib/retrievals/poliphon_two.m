function [POLIPHON2] = poliphon_two(aerBsc355_raman, pdr355_raman, aerBsc532_raman, pdr532_raman,...
          aerBsc1064_raman, pdr1064_raman, aerBsc355_raman_d1, aerBsc355_raman_nd1, aerBsc532_raman_d1, aerBsc532_raman_nd1, ...
          aerBsc1064_raman_d1, aerBsc1064_raman_nd1, err_aerBsc355_raman_d1, err_aerBsc355_raman_nd1, err_aerBsc532_raman_d1, ...
          err_aerBsc532_raman_nd1, err_aerBsc1064_raman_d1, err_aerBsc1064_raman_nd1, temperature, pressure, ...
          aerBsc355_klett, pdr355_klett, ...
          aerBsc532_klett, pdr532_klett, aerBsc1064_klett, pdr1064_klett,...
          aerBsc355_klett_d1, aerBsc355_klett_nd1, ...
          aerBsc532_klett_d1, aerBsc532_klett_nd1, aerBsc1064_klett_d1, aerBsc1064_klett_nd1, ...
          err_aerBsc355_klett_d1, err_aerBsc355_klett_nd1, ...
          err_aerBsc532_klett_d1,err_aerBsc532_klett_nd1, err_aerBsc1064_klett_d1, err_aerBsc1064_klett_nd1)

% POLIPHON_TWO applies the two-step POLIPHON methodology
% as described in Mamouri and Ansmann, 2014
%
% INPUT:
%   aerBsc532_raman     - total particle backscatter coefficient at 532 nm (Raman)
%   pdr532_raman        - particle linear depolarization ratio at 532 nm (Raman)
%   aerBsc532_raman_d1  - total dust backscatter from one-step method (POLIPHON1)
% Backscatter coefficient (355, 532, 1064 nm - Raman/Klett)
% Particle linear depolarization ratio (355, 532, 1064 nm - Raman/Klett)
% Total dust backscatter coefficient from one-step POLIPHON
% OUTPUT:
%   POLIPHON2 - structure containing:
%       - Fine, coarse and total dust backscatter coefficients
%       - Non-dust backscatter coefficients
%       - Error estimates
%
%
% HISTORY:
%
% .. Authors: - jneumann@tropos.de
%             - floutsi@tropos.de
%
% step one: non-dust and fine dust || non-dust, fine dust and coarse dust ||
%           coarse dust
% step two: non-dust || non-dust and fine dust
% depolarization ratio constants (from Mamouri & Ansmann, Table 1)
% AAF: As of now the value correspond to 532 nm. In the future we should
% include the rest of the values for 355 and 1064 nm (as [X 0.35 x])
% % delta_dc   = 0.35; % coarse dust
% % delta_df   = 0.16; % fine dust
% % delta_nd   = 0.05; % non-dust
% % delta_nddf = 0.12; % residual depol (mixed fine dust + non-dust)
Dcd = [0.30, 0.35, 0.39];   %depol coarse dust for 355, 532,1064 nm
Dfd = [0.21, 0.16, 0.09];   %depol fine dust for 355, 532,1064 nm
Dnd = [0.05, 0.05, 0.05];   %depol non dust for 355, 532,1064 nm
% add new conversion factors
% names from BERTHA script
% preallocate the variables 
sz        = size(aerBsc532_raman);
Pndfd     = NaN(sz);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aerBsc355_raman_d1        = NaN(sz);
aerBsc355_raman_nd1       = NaN(sz);
aerBsc532_raman_d1        = NaN(sz);
aerBsc532_raman_nd1       = NaN(sz);
aerBsc1064_raman_d1        = NaN(sz);
aerBsc1064_raman_nd1       = NaN(sz);
aerBsc355_klett_d2        = NaN(sz);
aerBsc355_klett_dc2       = NaN(sz);
aerBsc355_klett_df2       = NaN(sz);
aerBsc355_klett_nddf2     = NaN(sz);
aerBsc355_klett_nd2       = NaN(sz);
err_aerBsc355_klett_d2    = NaN(sz);
err_aerBsc355_klett_dc2   = NaN(sz);
err_aerBsc355_klett_df2   = NaN(sz);
err_aerBsc355_klett_nddf2 = NaN(sz);
err_aerBsc355_klett_nd2   = NaN(sz);
aerBsc532_klett_d2        = NaN(sz);
aerBsc532_klett_dc2       = NaN(sz);
aerBsc532_klett_df2       = NaN(sz);
aerBsc532_klett_nddf2     = NaN(sz);
aerBsc532_klett_nd2       = NaN(sz);
err_aerBsc532_klett_d2    = NaN(sz);
err_aerBsc532_klett_dc2   = NaN(sz);
err_aerBsc532_klett_df2   = NaN(sz);
err_aerBsc532_klett_nddf2 = NaN(sz);
err_aerBsc532_klett_nd2   = NaN(sz);
aerBsc1064_klett_d2        = NaN(sz);
aerBsc1064_klett_dc2       = NaN(sz);
aerBsc1064_klett_df2       = NaN(sz);
aerBsc1064_klett_nddf2     = NaN(sz);
aerBsc1064_klett_nd2       = NaN(sz);
err_aerBsc1064_klett_d2    = NaN(sz);
err_aerBsc1064_klett_dc2   = NaN(sz);
err_aerBsc1064_klett_df2   = NaN(sz);
err_aerBsc1064_klett_nddf2 = NaN(sz);
err_aerBsc1064_klett_nd2   = NaN(sz);
aerBsc355_raman_d2        = NaN(sz);
aerBsc355_raman_dc2       = NaN(sz);
aerBsc355_raman_df2       = NaN(sz);
aerBsc355_raman_nddf2     = NaN(sz);
aerBsc355_raman_nd2       = NaN(sz);
err_aerBsc355_raman_d2    = NaN(sz);
err_aerBsc355_raman_dc2   = NaN(sz);
err_aerBsc355_raman_df2   = NaN(sz);
err_aerBsc355_raman_nddf2 = NaN(sz);
err_aerBsc355_raman_nd2   = NaN(sz);
aerBsc532_raman_d2        = NaN(sz);
aerBsc532_raman_dc2       = NaN(sz);
aerBsc532_raman_df2       = NaN(sz);
aerBsc532_raman_nddf2     = NaN(sz);
aerBsc532_raman_nd2       = NaN(sz);
err_aerBsc532_raman_d2    = NaN(sz);
err_aerBsc532_raman_dc2   = NaN(sz);
err_aerBsc532_raman_df2   = NaN(sz);
err_aerBsc532_raman_nddf2 = NaN(sz);
err_aerBsc532_raman_nd2   = NaN(sz);
aerBsc1064_raman_d2        = NaN(sz);
aerBsc1064_raman_dc2       = NaN(sz);
aerBsc1064_raman_df2       = NaN(sz);
aerBsc1064_raman_nddf2     = NaN(sz);
aerBsc1064_raman_nd2       = NaN(sz);
err_aerBsc1064_raman_d2    = NaN(sz);
err_aerBsc1064_raman_dc2   = NaN(sz);
err_aerBsc1064_raman_df2   = NaN(sz);
err_aerBsc1064_raman_nddf2 = NaN(sz);
err_aerBsc1064_raman_nd2   = NaN(sz);
ext_d_raman_355 = NaN(sz);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mixing Ratio 
dgfd = (2);
dgnd = (2);
for i=1:3
    dgfd(i) = 2*Dfd(i)/(1+Dfd(i));
    dgnd(i) = 2*Dnd(i)/(1+Dnd(i));
end

% mixing ratio of fine dust and non dust -> dndfd
%mr      = (0:2.500625156289073e-04:1);
step = size(aerBsc355_raman,2);
mr = linspace(0, 1, step);
dgndfd  = (size(mr,2):2); 
dndfd_e = (size(mr,2):2); %estimated depol of fine mode and non dust, depending on mixing ratio
for i=1:3
    for c=1:size(mr,2)
        dgndfd(i,c)  = mr(c)*dgnd(i)+(1-mr(c))*dgfd(i);
        dndfd_e(i,c) = dgndfd(i,c)/(2-dgndfd(i,c));
    end
end

%% klett 355
for i=1:size(aerBsc355_klett,1) % this loop shall be repeated for each bsc  % every retrieval profile
    for n=1:size(aerBsc355_klett,2) % every height 
        if isnan(aerBsc355_klett(i,n)) || isnan(pdr355_klett(i,n)) || (isnan(aerBsc355_klett(i,n)) && isnan(pdr355_klett(i,n)))
            aerBsc355_klett_d2(i,n)        = NaN;
            aerBsc355_klett_dc2(i,n)       = NaN;
            aerBsc355_klett_df2(i,n)       = NaN;
            aerBsc355_klett_nddf2(i,n)     = NaN;
            aerBsc355_klett_nd2(i,n)       = NaN;
            err_aerBsc355_klett_d2(i,n)    = NaN;
            err_aerBsc355_klett_dc2(i,n)   = NaN;
            err_aerBsc355_klett_df2(i,n)   = NaN;
            err_aerBsc355_klett_nddf2(i,n) = NaN;
            err_aerBsc355_klett_nd2(i,n)   = NaN;
        else
            if pdr355_klett(i,n)<dndfd_e(1,n)
                aerBsc355_klett_dc2(i,n) = 0;
            elseif pdr355_klett(i,n)>Dcd(1)
                aerBsc355_klett_dc2(i,n) = aerBsc355_klett(i,n);
            else
                    aerBsc355_klett_dc2(i,n) = aerBsc355_klett(i,n)*(pdr355_klett(i,n)-dndfd_e(1,n))*(1+Dcd(1))/(Dcd(1)-dndfd_e(1,n))/(1+pdr355_klett(i,n));
            end

            aerBsc355_klett_nddf2(i,n) = aerBsc355_klett(i,n)-aerBsc355_klett_dc2(i,n);
        end
        if pdr532_raman(i,n)<=dndfd_e(1,n)                
            Pndfd(i,n) = pdr532_raman(i,n);
        else
            Pndfd(i,n) = dndfd_e(1,n);
        end
    end

    for n=1:size(aerBsc355_klett,2)
        if Pndfd(i,n)>=Dnd(1)
            aerBsc355_klett_df2(i,n) = aerBsc355_klett_nddf2(i,n)*(Pndfd(i,n)-Dnd(1))*(1+Dfd(1))/(Dfd(1)-Dnd(1))/(1+Pndfd(i,n));
        else
            aerBsc355_klett_df2(i,n) = 0;
        end
        aerBsc355_klett_nd2(i,n) = aerBsc355_klett_nddf2(i,n)-aerBsc355_klett_df2(i,n);
        aerBsc355_klett_d2(i,n)  = aerBsc355_klett_dc2(i,n)+aerBsc355_klett_df2(i,n);
    end

end
%% klett 532
for i=1:size(aerBsc532_klett,1) % klett 532
    for n=1:size(aerBsc532_klett,2) % every height 
        if isnan(aerBsc532_klett(i,n)) || isnan(pdr532_klett(i,n)) || (isnan(aerBsc532_klett(i,n)) && isnan(pdr532_klett(i,n)))
            aerBsc532_klett_d2(i,n)        = NaN;
            aerBsc532_klett_dc2(i,n)       = NaN;
            aerBsc532_klett_df2(i,n)       = NaN;
            aerBsc532_klett_nddf2(i,n)     = NaN;
            aerBsc532_klett_nd2(i,n)       = NaN;
            err_aerBsc532_klett_d2(i,n)    = NaN;
            err_aerBsc532_klett_dc2(i,n)   = NaN;
            err_aerBsc532_klett_df2(i,n)   = NaN;
            err_aerBsc532_klett_nddf2(i,n) = NaN;
            err_aerBsc532_klett_nd2(i,n)   = NaN;
        else
            if pdr532_klett(i,n)<dndfd_e(2,n)
                aerBsc532_klett_dc2(i,n) = 0;
            elseif pdr532_klett(i,n)>Dcd(2)
                aerBsc532_klett_dc2(i,n) = aerBsc532_klett(i,n);
            else
                    aerBsc532_klett_dc2(i,n) = aerBsc532_klett(i,n)*(pdr532_klett(i,n)-dndfd_e(2,n))*(1+Dcd(2))/(Dcd(2)-dndfd_e(2,n))/(1+pdr532_klett(i,n));
            end

            aerBsc532_klett_nddf2(i,n) = aerBsc532_klett(i,n)-aerBsc532_klett_dc2(i,n);
        end
        if pdr532_raman(i,n)<=dndfd_e(2,n)                
            Pndfd(i,n) = pdr532_raman(i,n);
        else
            Pndfd(i,n) = dndfd_e(2,n);
        end
    end


    for n=1:size(aerBsc532_klett,2)
        if Pndfd(i,n)>=Dnd(2)
            aerBsc532_klett_df2(i,n) = aerBsc532_klett_nddf2(i,n)*(Pndfd(i,n)-Dnd(2))*(1+Dfd(2))/(Dfd(2)-Dnd(2))/(1+Pndfd(i,n));
        else
            aerBsc532_klett_df2(i,n) = 0;
        end
        aerBsc532_klett_nd2(i,n) = aerBsc532_klett_nddf2(i,n)-aerBsc532_klett_df2(i,n);
        aerBsc532_klett_d2(i,n)  = aerBsc532_klett_dc2(i,n)+aerBsc532_klett_df2(i,n);
    end

end
%% klett 1064
for i=1:size(aerBsc1064_klett,1)
    for n=1:size(aerBsc1064_klett,2) % every height 
        if isnan(aerBsc1064_klett(i,n)) || isnan(pdr1064_klett(i,n)) || (isnan(aerBsc1064_klett(i,n)) && isnan(pdr1064_klett(i,n)))
            aerBsc1064_klett_d2(i,n)        = NaN;
            aerBsc1064_klett_dc2(i,n)       = NaN;
            aerBsc1064_klett_df2(i,n)       = NaN;
            aerBsc1064_klett_nddf2(i,n)     = NaN;
            aerBsc1064_klett_nd2(i,n)       = NaN;
            err_aerBsc1064_klett_d2(i,n)    = NaN;
            err_aerBsc1064_klett_dc2(i,n)   = NaN;
            err_aerBsc1064_klett_df2(i,n)   = NaN;
            err_aerBsc1064_klett_nddf2(i,n) = NaN;
            err_aerBsc1064_klett_nd2(i,n)   = NaN;
        else
            if pdr1064_klett(i,n)<dndfd_e(3,n)
                aerBsc1064_klett_dc2(i,n) = 0;
            elseif pdr1064_klett(i,n)>Dcd(3)
                aerBsc1064_klett_dc2(i,n) = aerBsc1064_klett(i,n);
            else
                    aerBsc1064_klett_dc2(i,n) = aerBsc1064_klett(i,n)*(pdr1064_klett(i,n)-dndfd_e(3,n))*(1+Dcd(3))/(Dcd(3)-dndfd_e(3,n))/(1+pdr1064_klett(i,n));
            end

            aerBsc1064_klett_nddf2(i,n) = aerBsc1064_klett(i,n)-aerBsc1064_klett_dc2(i,n);
        end
        if pdr532_raman(i,n)<=dndfd_e(3,n)                
            Pndfd(i,n) = pdr532_raman(i,n); 
        else
            Pndfd(i,n) = dndfd_e(3,n);
        end
    end

    for n=1:size(aerBsc1064_klett,2)
        if Pndfd(i,n)>=Dnd(3)
            aerBsc1064_klett_df2(i,n) = aerBsc1064_klett_nddf2(i,n)*(Pndfd(i,n)-Dnd(3))*(1+Dfd(3))/(Dfd(3)-Dnd(3))/(1+Pndfd(i,n));
        else
            aerBsc1064_klett_df2(i,n) = 0;
        end
        aerBsc1064_klett_nd2(i,n) = aerBsc1064_klett_nddf2(i,n)-aerBsc1064_klett_df2(i,n);
        aerBsc1064_klett_d2(i,n)  = aerBsc1064_klett_dc2(i,n)+aerBsc1064_klett_df2(i,n);
    end

end
%% raman 355
for i=1:size(aerBsc355_raman,1) 
    for n=1:size(aerBsc355_raman,2) % every height 
        if isnan(aerBsc355_raman(i,n)) || isnan(pdr355_raman(i,n)) || (isnan(aerBsc355_raman(i,n)) && isnan(pdr355_raman(i,n)))
            aerBsc355_raman_d2(i,n)        = NaN;
            aerBsc355_raman_dc2(i,n)       = NaN;
            aerBsc355_raman_df2(i,n)       = NaN;
            aerBsc355_raman_nddf2(i,n)     = NaN;
            aerBsc355_raman_nd2(i,n)       = NaN;
            err_aerBsc355_raman_d2(i,n)    = NaN;
            err_aerBsc355_raman_dc2(i,n)   = NaN;
            err_aerBsc355_raman_df2(i,n)   = NaN;
            err_aerBsc355_raman_nddf2(i,n) = NaN;
            err_aerBsc355_raman_nd2(i,n)   = NaN;
        else
            if pdr355_raman(i,n)<dndfd_e(1,n)
                aerBsc355_raman_dc2(i,n) = 0;
            elseif pdr355_raman(i,n)>Dcd(1)
                aerBsc355_raman_dc2(i,n) = aerBsc355_raman(i,n);
            else
                    aerBsc355_raman_dc2(i,n) = aerBsc355_raman(i,n)*(pdr355_raman(i,n)-dndfd_e(1,n))*(1+Dcd(1))/(Dcd(1)-dndfd_e(1,n))/(1+pdr355_raman(i,n));
            end
                
            aerBsc355_raman_nddf2(i,n) = aerBsc355_raman(i,n)-aerBsc355_raman_dc2(i,n);
        end
        if pdr532_raman(i,n)<=dndfd_e(1,n)                
            Pndfd(i,n) = pdr532_raman(i,n); 
        else
            Pndfd(i,n) = dndfd_e(1,n);
        end
    end
        
    for n=1:size(aerBsc355_raman,2)
        if Pndfd(i,n)>=Dnd(1)
            aerBsc355_raman_df2(i,n) = aerBsc355_raman_nddf2(i,n)*(Pndfd(i,n)-Dnd(1))*(1+Dfd(1))/(Dfd(1)-Dnd(1))/(1+Pndfd(i,n));
        else
            aerBsc355_raman_df2(i,n) = 0;
        end
        aerBsc355_raman_nd2(i,n) = aerBsc355_raman_nddf2(i,n)-aerBsc355_raman_df2(i,n);
        aerBsc355_raman_d2(i,n)  = aerBsc355_raman_dc2(i,n)+aerBsc355_raman_df2(i,n);
    end
   
end
%% raman 532
for i=1:size(aerBsc532_raman,1) % raman 532 - number of profiles = 6
    for n=1:size(aerBsc532_raman,2) % every height = 4000
        if isnan(aerBsc532_raman(i,n)) || isnan(pdr532_raman(i,n)) || (isnan(aerBsc532_raman(i,n)) && isnan(pdr532_raman(i,n)))
            aerBsc532_raman_d2(i,n)        = NaN;
            aerBsc532_raman_dc2(i,n)       = NaN;
            aerBsc532_raman_df2(i,n)       = NaN;
            aerBsc532_raman_nddf2(i,n)     = NaN;
            aerBsc532_raman_nd2(i,n)       = NaN;
            err_aerBsc532_raman_d2(i,n)    = NaN;
            err_aerBsc532_raman_dc2(i,n)   = NaN;
            err_aerBsc532_raman_df2(i,n)   = NaN;
            err_aerBsc532_raman_nddf2(i,n) = NaN;
            err_aerBsc532_raman_nd2(i,n)   = NaN;
        else
            if pdr532_raman(i,n)<dndfd_e(2,n)
                aerBsc532_raman_dc2(i,n) = 0;
            elseif pdr532_raman(i,n)>Dcd(2)
                aerBsc532_raman_dc2(i,n) = aerBsc532_raman(i,n);
            else
                aerBsc532_raman_dc2(i,n) = aerBsc532_raman(i,n)*(pdr532_raman(i,n)-dndfd_e(2,n))*(1+Dcd(2))/(Dcd(2)-dndfd_e(2,n))/(1+pdr532_raman(i,n));
            end
                
            aerBsc532_raman_nddf2(i,n) = aerBsc532_raman(i,n)-aerBsc532_raman_dc2(i,n);
        
        if pdr532_raman(i,n)<=dndfd_e(2,n)                
            Pndfd(i,n) = pdr532_raman(i,n); 
        else
            Pndfd(i,n) = dndfd_e(2,n);
        end
        end
    end
    
    for n=1:size(aerBsc532_raman,2)
        if Pndfd(i,n)>=Dnd(2)
            aerBsc532_raman_df2(i,n) = aerBsc532_raman_nddf2(i,n)*(Pndfd(i,n)-Dnd(2))*(1+Dfd(2))/(Dfd(2)-Dnd(2))/(1+Pndfd(i,n));
        else
            aerBsc532_raman_df2(i,n) = 0;
        end
        aerBsc532_raman_nd2(i,n) = aerBsc532_raman_nddf2(i,n)-aerBsc532_raman_df2(i,n);
        aerBsc532_raman_d2(i,n)  = aerBsc532_raman_dc2(i,n)+aerBsc532_raman_df2(i,n);
    end
   
end
%% raman 1064
for i=1:size(aerBsc1064_raman,1)
    for n=1:size(aerBsc1064_raman,2) % every height 
        if isnan(aerBsc1064_raman(i,n)) || isnan(pdr1064_raman(i,n)) || (isnan(aerBsc1064_raman(i,n)) && isnan(pdr1064_raman(i,n)))
            aerBsc1064_raman_d2(i,n)        = NaN;
            aerBsc1064_raman_dc2(i,n)       = NaN;
            aerBsc1064_raman_df2(i,n)       = NaN;
            aerBsc1064_raman_nddf2(i,n)     = NaN;
            aerBsc1064_raman_nd2(i,n)       = NaN;
            err_aerBsc1064_raman_d2(i,n)    = NaN;
            err_aerBsc1064_raman_dc2(i,n)   = NaN;
            err_aerBsc1064_raman_df2(i,n)   = NaN;
            err_aerBsc1064_raman_nddf2(i,n) = NaN;
            err_aerBsc1064_raman_nd2(i,n)   = NaN;
        else
            if pdr1064_raman(i,n)<dndfd_e(3,n)
                aerBsc1064_raman_dc2(i,n) = 0;
            elseif pdr1064_raman(i,n)>Dcd(3)
                aerBsc1064_raman_dc2(i,n) = aerBsc1064_raman(i,n);
            else
                    aerBsc1064_raman_dc2(i,n) = aerBsc1064_raman(i,n)*(pdr1064_raman(i,n)-dndfd_e(3,n))*(1+Dcd(3))/(Dcd(3)-dndfd_e(3,n))/(1+pdr1064_raman(i,n));
            end
                
            aerBsc1064_raman_nddf2(i,n) = aerBsc1064_raman(i,n)-aerBsc1064_raman_dc2(i,n);
        end
        if pdr532_raman(i,n)<=dndfd_e(3,n)                
            Pndfd(i,n) = pdr532_raman(i,n);
        else
            Pndfd(i,n) = dndfd_e(3,n);
        end
    end
   
    for n=1:size(aerBsc1064_raman,2)
        if Pndfd(i,n)>=Dnd(3)
            aerBsc1064_raman_df2(i,n) = aerBsc1064_raman_nddf2(i,n)*(Pndfd(i,n)-Dnd(3))*(1+Dfd(3))/(Dfd(3)-Dnd(3))/(1+Pndfd(i,n));
        else
            aerBsc1064_raman_df2(i,n) = 0;
        end
        aerBsc1064_raman_nd2(i,n) = aerBsc1064_raman_nddf2(i,n)-aerBsc1064_raman_df2(i,n);
        aerBsc1064_raman_d2(i,n)  = aerBsc1064_raman_dc2(i,n)+aerBsc1064_raman_df2(i,n);
    end
   
end

% output
%% 355 klett
POLIPHON2.aerBsc355_klett_d2 = aerBsc355_klett_d2;
POLIPHON2.aerBsc355_klett_dc2 = aerBsc355_klett_dc2;
POLIPHON2.aerBsc355_klett_df2 = aerBsc355_klett_df2;
POLIPHON2.aerBsc355_klett_nddf2 = aerBsc355_klett_nddf2;
POLIPHON2.aerBsc355_klett_nd2 = aerBsc355_klett_nd2;
POLIPHON2.err_aerBsc355_klett_d2 = err_aerBsc355_klett_d2;
POLIPHON2.err_aerBsc355_klett_dc2 = err_aerBsc355_klett_dc2;
POLIPHON2.err_aerBsc355_klett_df2 = err_aerBsc355_klett_df2;
POLIPHON2.err_aerBsc355_klett_nddf2 = err_aerBsc355_klett_nddf2;
POLIPHON2.err_aerBsc355_klett_nd2 = err_aerBsc355_klett_nd2;
%% 532 klett
POLIPHON2.aerBsc532_klett_d2 = aerBsc532_klett_d2;
POLIPHON2.aerBsc532_klett_dc2 = aerBsc532_klett_dc2;
POLIPHON2.aerBsc532_klett_df2 = aerBsc532_klett_df2;
POLIPHON2.aerBsc532_klett_nddf2 = aerBsc532_klett_nddf2;
POLIPHON2.aerBsc532_klett_nd2 = aerBsc532_klett_nd2;
POLIPHON2.err_aerBsc532_klett_d2 = err_aerBsc532_klett_d2;
POLIPHON2.err_aerBsc532_klett_dc2 = err_aerBsc532_klett_dc2;
POLIPHON2.err_aerBsc532_klett_df2 = err_aerBsc532_klett_df2;
POLIPHON2.err_aerBsc532_klett_nddf2 = err_aerBsc532_klett_nddf2;
POLIPHON2.err_aerBsc532_klett_nd2 = err_aerBsc532_klett_nd2;
%% 1064 klett
POLIPHON2.aerBsc1064_klett_d2 = aerBsc1064_klett_d2;
POLIPHON2.aerBsc1064_klett_dc2 = aerBsc1064_klett_dc2;
POLIPHON2.aerBsc1064_klett_df2 = aerBsc1064_klett_df2;
POLIPHON2.aerBsc1064_klett_nddf2 = aerBsc1064_klett_nddf2;
POLIPHON2.aerBsc1064_klett_nd2 = aerBsc1064_klett_nd2;
POLIPHON2.err_aerBsc1064_klett_d2 = err_aerBsc1064_klett_d2;
POLIPHON2.err_aerBsc1064_klett_dc2 = err_aerBsc1064_klett_dc2;
POLIPHON2.err_aerBsc1064_klett_df2 = err_aerBsc1064_klett_df2;
POLIPHON2.err_aerBsc1064_klett_nddf2 = err_aerBsc1064_klett_nddf2;
POLIPHON2.err_aerBsc1064_klett_nd2 = err_aerBsc1064_klett_nd2;
%% 355 raman
POLIPHON2.aerBsc355_raman_d2 = aerBsc355_raman_d2;
POLIPHON2.aerBsc355_raman_dc2 = aerBsc355_raman_dc2;
POLIPHON2.aerBsc355_raman_df2 = aerBsc355_raman_df2;
POLIPHON2.aerBsc355_raman_nddf2 = aerBsc355_raman_nddf2;
POLIPHON2.aerBsc355_raman_nd2 = aerBsc355_raman_nd2;
POLIPHON2.err_aerBsc355_raman_d2 = err_aerBsc355_raman_d2;
POLIPHON2.err_aerBsc355_raman_dc2 = err_aerBsc355_raman_dc2;
POLIPHON2.err_aerBsc355_raman_df2 = err_aerBsc355_raman_df2;
POLIPHON2.err_aerBsc355_raman_nddf2 = err_aerBsc355_raman_nddf2;
POLIPHON2.err_aerBsc355_raman_nd2 = err_aerBsc355_raman_nd2;
%% 532 raman
POLIPHON2.aerBsc532_raman_d2 = aerBsc532_raman_d2;
POLIPHON2.aerBsc532_raman_dc2 = aerBsc532_raman_dc2;
POLIPHON2.aerBsc532_raman_df2 = aerBsc532_raman_df2;
POLIPHON2.aerBsc532_raman_nddf2 = aerBsc532_raman_nddf2;
POLIPHON2.aerBsc532_raman_nd2 = aerBsc532_raman_nd2;
POLIPHON2.err_aerBsc532_raman_d2 = err_aerBsc532_raman_d2;
POLIPHON2.err_aerBsc532_raman_dc2 = err_aerBsc532_raman_dc2;
POLIPHON2.err_aerBsc532_raman_df2 = err_aerBsc532_raman_df2;
POLIPHON2.err_aerBsc532_raman_nddf2 = err_aerBsc532_raman_nddf2;
POLIPHON2.err_aerBsc532_raman_nd2 = err_aerBsc532_raman_nd2;
%% 1064 raman
POLIPHON2.aerBsc1064_raman_d2 = aerBsc1064_raman_d2;
POLIPHON2.aerBsc1064_raman_dc2 = aerBsc1064_raman_dc2;
POLIPHON2.aerBsc1064_raman_df2 = aerBsc1064_raman_df2;
POLIPHON2.aerBsc1064_raman_nddf2 = aerBsc1064_raman_nddf2;
POLIPHON2.aerBsc1064_raman_nd2 = aerBsc1064_raman_nd2;
POLIPHON2.err_aerBsc1064_raman_d2 = err_aerBsc1064_raman_d2;
POLIPHON2.err_aerBsc1064_raman_dc2 = err_aerBsc1064_raman_dc2;
POLIPHON2.err_aerBsc1064_raman_df2 = err_aerBsc1064_raman_df2;
POLIPHON2.err_aerBsc1064_raman_nddf2 = err_aerBsc1064_raman_nddf2;
POLIPHON2.err_aerBsc1064_raman_nd2 = err_aerBsc1064_raman_nd2;
%% code for new conversion factors from Ansmann et al. 2026  
% after BERTHA script from Moritz
dcd=[0.30,0.35,0.39];   %depol coarse dust for 355, 532,1064 nm
dfd=[0.21,0.16,0.09];   %depol fine dust for 355, 532,1064 nm
dnd=[0.05,0.05,0.05];   %depol non dust for 355, 532,1064 nm
% MASS CONVERSION ---------------------------------------------------------
cv_d_mean = [0.653, 0.73, 0.823]; %"mean dust extinction-to-volume concentration conversion factor"
cvf_d_mean = [0.124, 0.209, 0.92]; %"mean dust extinction-to-volume concentration (fine mode fraction) conversion factor"
cvc_d_mean = [0.962, 0.891, 0.805]; %"mean dust extinction-to-volume concentration (coarse mode fraction) conversion factor" !careful here with the last entry
vcndm =[0.75,0.75,0.75]; %volume conversion factor non-dust marine for 355,532,1064 nm
% = cv_m_mean = [0.068, 0.085, 0.11]; %"mean marine extinction-to-volume concentration conversion factor" ??
vcnds =[0.18,0.18,0.18];%volume conversion factor non-dust smoke for 355,532,1064 nm
lrd=[55,55,55];         %Lidar ratio dust for 355,532,1064 nm
lrndm=[20,20,20];       %Lidar ratio non-dust marine for 355,532,1064 nm
lrnds=[80,80,80];       %Lidar ratio non-dust smoke for 355,532,1064 nm
lrbb = [80, 80, 80];    %Lidar ratio biomass burning smoke for 355,532,1064 nm 
lrvs = [80, 80, 80];    % Lidar ratio volcanic sulfate for 355, 532, 1064 nm
rhod=2.6;               %density dust
rhondm=1.2;             %density non dust marine
rhonds=1.55;            %density non dust smoke
rhobb = 1.55;           % Density biomass burning
rhovs = 1.55;           % Density volcanic sulfate

%% NUMBER AND SURFACE AREA CONVERSION (Mamouri and Ansmann 2016/ 2026) [355, 532, 1064]
%% note:  
% converision factors from surface area and volume concentration doesn't need to be divided by 1.33 (as before), but can be used as they are 
% extinction exponents are not used anymore (set to 1 here)
% for continental, AE1.6-2.0 is used here (not AE1.1-1.5)
% for now: the lidar ratio, density, enhancement factors, extinction
% coefficients and mass concentration from smoke are used for bb and vs! 

% GLOBAL MEAN CONVERSION FACTORS ARE USED HERE!

%% new variable names:
% c100d = c100_d_mean;
% c250d = c250_d_mean;
% c100m = c50_m_mean;
% c500m = c250_m_mean;
% c60c = c50_c_1620_mean;
% c290c = c250_c_1620_mean;
% csd = cs_d_mean;
% csm = cs_m_mean;
% csc = cs_c_1620_mean
%% not used anymore, 1s for simplicity:
chid = [1, 1, 1]; %extinction exponent for dust MEAN
chic = [1, 1, 1]; %extinction exponent for continental aerosol MEAN
chim = [1, 1, 1]; %extinction exponent for marine aerosol on Barbados
chibb = [1, 1, 1]; %extinction exponent for biomass burning smoke MEAN
chivs = [1, 1, 1]; %extinction exponent for vulcanic sulfate MEAN
%% new conversion factors from Ansmann et al. 2026 (all_types_mean_poliphon_conversion_factors_Ansmann_2026_v20260223.nc):

% dust:
%c60_d_mean = [9.04, 10.8, 11.8]; % "mean dust extinction-to-number concentration (r>60 nm) conversion factor"
c100_d_mean = [1.74, 1.92, 2.18]; %"mean dust extinction-to-number concentration (r>100 nm) conversion factor"
c250_d_mean = [0.144, 0.16, 0.182]; %"mean dust extinction-to-number concentration (r>250 nm) conversion factor"
cs_d_mean = [2.11, 2.34, 2.75];  %"mean dust extinction-to-surface area concentration conversion factor"
%cs100_d_mean = [1.46, 1.61, 1.83]; %"mean dust extinction-to-surface area concentration (r>100 nm) conversion factor"

% continental:
c50_c_1620_mean = [8.15, 16.65, 47.22]; %"mean continental pollution extinction-to-number concentration (r>50 nm,dry) conversion factor (AE1.6-2.0)"
c250_c_1620_mean = [0.0419, 0.0821, 0.253]; %"mean continental pollution extinction-to-number concentration (r>250 nm,dry) conversion factor (AE1.6-2.0)"
%cv_c_1620_mean = [0.104, 0.193, 0.62]; %"mean continental pollution extinction-to-volume concentration conversion factor (AE1.6-2.0)"
cs_c_1620_mean = [1.22, 2.34, 7.31]; %"mean continental pollution extinction-to-surface area concentration conversion factor (AE1.6-2.0)"
% c50_c_1115_mean = [7.56, 13.7, 30.52]; %"mean continental pollution extinction-to-number concentration (r>50 nm,dry) conversion factor (AE1.1-1.5)"
% c250_c_1115_mean = [0.0556, 0.1, 0.224]; %"mean continental pollution extinction-to-number concentration (r>250 nm,dry) conversion factor (AE1.1-1.5)"
% cv_c_1115_mean = [0.13, 0.22, 0.538]; %"mean continental pollution extinction-to-volume concentration conversion factor (AE1.1-1.5)"
%cs_c_1115_mean = [1.16, 1.99, 4.79]; %"mean continental pollution extinction-to-surface area concentration conversion factor (AE1.1-1.5)"

% marine:
c50_m_mean = [2.74, 3.49, 4.49]; %"mean marine extinction-to-number concentration (r>50 nm,dry) conversion factor"
c250_m_mean = [0.0487, 0.0621, 0.0797]; %"mean marine extinction-to-number concentration (r>250 nm,dry) conversion factor"
cs_m_mean = [0.468, 0.58, 0.75];    %"mean marine extinction-to-surface area concentration conversion factor"

% biomass burning smoke
c50_bbt_mean = [8.5, 15.35, 65.22]; %"mean tropospheric biomass burning smoke extinction-to-number concentration (r>50 nm,dry) conversion factor"
c250_bbt_mean = [0.0973, 0.326, 0.718]; %"mean tropospheric biomass burning smoke extinction-to-number concentration (r>250 nm,dry) conversion factor"
cs_bbt_mean = [1.69, 3.0, 12.81]; %"mean tropospheric biomass burning smoke extinction-to-surface area concentration conversion factor"
cv_bbt_mean = [0.091, 0.161, 0.674]; %"mean tropospheric biomass burning smoke extinction-to-volume concentration conversion factor"
c50_bbsf_mean = [6.37, 10.87, 36.58]; %"mean fresh statospheric biomass burning smoke extinction-to-number concentration (r>50 nm,dry) conversion factor"
c250_bbsf_mean = [0.12, 0.187, 0.726]; %"mean fresh statospheric biomass burning smoke extinction-to-number concentration (r>250 nm,dry) conversion factor"
cs_bbsf_mean = [1.45, 2.36, 7.2]; %"mean fresh statospheric biomass burning smoke extinction-to-surface area concentration conversion factor"
cv_bbsf_mean = [0.087, 0.133, 0.519]; %"fresh statospheric biomass burning smoke extinction-to-volume concentration conversion factor"
c50_bbsa_mean = [6.37, 7.33, 18.53]; %"mean aged statospheric biomass burning smoke extinction-to-number concentration (r>50 nm,dry) conversion factor"
c250_bbsa_mean = [0.306, 0.39, 0.912]; %"mean aged statospheric biomass burning smoke extinction-to-number concentration (r>250 nm,dry) conversion factor"
cs_bbsa_mean = [1.45, 1.98, 5.14]; %"mean aged statospheric biomass burning smoke extinction-to-surface area concentration conversion factor"
cv_bbsa_mean = [0.098, 0.126, 0.361]; %"mean aged statospheric biomass burning smoke extinction-to-volume concentration conversion factor"

% vulcanic sulfate fresh (stratospheric)
c50_vsf_mean = [4.3, 4.74, 10.79]; %"mean fresh stratospheric volcanic sulfate extinction-to-number concentration (r>50 nm,dry) conversion factor"
c250_vsf_mean = [0.411, 0.504, 1.055]; %"mean fresh stratospheric volcanic sulfate extinction-to-number concentration (r>250 nm,dry) conversion factor"
cs_vsf_mean = [1.34, 1.55, 2.52]; %"mean fresh stratospheric volcanic sulfate extinction-to-surface area concentration conversion factor"
cv_vsf_mean = [0.13, 0.158, 0.318]; %"mean fresh stratospheric volcanic sulfate extinction-to-volume concentration conversion factor"

% volcanic sulfate aged (stratospheric)
c50_vsa_mean = [nan, 5.38, 13.88]; %"mean aged stratospheric volcanic sulfate extinction-to-number concentration (r>50 nm,dry) conversion factor"
c250_vsa_mean = [nan, 0.485, 1.322]; %"mean aged stratospheric volcanic sulfate extinction-to-number concentration (r>250 nm,dry) conversion factor"
cs_vsa_mean = [nan, 1.7, 4.41]; %"mean aged stratospheric volcanic sulfate extinction-to-surface area concentration conversion factor"
cv_vsa_mean = [nan, 0.147, 0.38]; %"mean aged stratospheric volcanic sulfate extinction-to-volume concentration conversion factor"

% vulcanic sulfate (tropospheric)
c50_vst_mean = [6.58, 9.61, 19.31]; % "mean tropospheric volcanic sulfate extinction-to-number concentration (r>50 nm,dry) conversion factor"
c250_vst_mean = [0.174, 0.279, 0.676]; % "mean tropospheric volcanic sulfate extinction-to-number concentration (r>250 nm,dry) conversion factor"
cs_vst_mean = [1.28, 1.87, 3.8]; % "mean tropospheric volcanic sulfate extinction-to-surface area concentration conversion factor"
cv_vst_mean = [0.087, 0.129, 0.293]; % "mean tropospheric volcanic sulfate extinction-to-volume concentration conversion factor"

%% enhancement factors and backscatter coeffs
fssd=1.0;               % enhancement factor for dust for different super saturations (ss=0.15% -> f=1; ss=0.25% -> f=1.35; ss=0.4% -> f=1.7)
fssc=1.0;               % enhancement factor for continental aerosol for different super saturations (till now, it is the same for every aerosol type)
fssm=1.0;               % enhancement factor for marine aerosol for different super saturations (till now, it is the same for every aerosol type)
fssbb = 1.0;               % Enhancement factor biomass burning
fssvs = 1.0;               % Enhancement factor volcanic sulfate

% %backscatter coeffs
% %Bb=[aerBsc355_klett,aerBsc532_klett,aerBsc1064_klett] %if klett
% Bb=[aerBsc355_raman, aerBsc532_raman, aerBsc1064_raman]; %if raman
% % depol ratios
% %Pb=[pdr355_klett,pdr532_klett,pdr1064_klett] % if klett
% Pb=[pdr355_raman, pdr532_raman, pdr1064_raman]; % if raman

%% method 1 = raman; 2 = klett
POLIPHON2 = struct();
for method = 1:2
    if method == 1
        Bb = [aerBsc355_raman(1,:).', aerBsc532_raman(1,:).', aerBsc1064_raman(1,:).'];
        Bd1 = [aerBsc355_raman_d2(1,:).', aerBsc532_raman_d2(1,:).', aerBsc1064_raman_d2(1,:).'];
        Bnd1 =[aerBsc355_raman_nd2(1,:).', aerBsc532_raman_nd2(1,:).', aerBsc1064_raman_nd2(1,:).'];

        Bcd_profile = [aerBsc355_raman_dc2(1,:).', aerBsc532_raman_dc2(1,:).', aerBsc1064_raman_dc2(1,:).'];
        Bfd_profile = [aerBsc355_raman_df2(1,:).', aerBsc532_raman_df2(1,:).', aerBsc1064_raman_df2(1,:).'];
        Bnd2_profile = [aerBsc355_raman_nd2(1,:).', aerBsc532_raman_nd2(1,:).', aerBsc1064_raman_nd2(1,:).'];
    elseif method == 2
        Bb = [aerBsc355_klett(1,:).', aerBsc532_klett(1,:).', aerBsc1064_klett(1,:).'];
        Bd1 = [aerBsc355_klett_d2(1,:).', aerBsc532_klett_d2(1,:).', aerBsc1064_klett_d2(1,:).'];
        Bnd1 =[aerBsc355_klett_nd2(1,:).', aerBsc532_klett_nd2(1,:).', aerBsc1064_klett_nd2(1,:).'];

        Bcd_profile = [aerBsc355_klett_dc2(1,:).', aerBsc532_klett_dc2(1,:).', aerBsc1064_klett_dc2(1,:).'];
        Bfd_profile = [aerBsc355_klett_df2(1,:).', aerBsc532_klett_df2(1,:).', aerBsc1064_klett_df2(1,:).'];
        Bnd2_profile = [aerBsc355_klett_nd2(1,:).', aerBsc532_klett_nd2(1,:).', aerBsc1064_klett_nd2(1,:).'];
    else
        disp('NO VALID METHOD')
    end

    %% Convert backscatter from m^-1 sr^-1 to Mm^-1 sr^-1 
    Bb = Bb * 1e6;
    Bd1 = Bd1 * 1e6;
    Bnd1 = Bnd1 * 1e6;
    Bcd_profile = Bcd_profile * 1e6;
    Bfd_profile = Bfd_profile * 1e6;
    Bnd2_profile = Bnd2_profile * 1e6;
 
    
    %% from here on copy of moritz´ bertha script
    
        % EXTINCTION and MASS CONVERSION----------------------------------------------------------
        % cv_d_mean=[0.64,0.64,0.64];    %volume conversion factor dust for 355,532,1064 nm
        % cvc_d_mean=[0.79,0.79,0.79];   %volume conversion factor coarse dust for 355,532,1064 nm
        % cvf_d_mean=[0.21,0.21,0.21];   %volume conversion factor fine dust for 355,532,1064 nm
        % lrd=[55,55,55];          %Lidar ratio dust for 355,532,1064 nm
        % rhod=2.6;                %Dichte dust
        
        Ad=(1:3);       %extinction coefficient for dust
        Acd=(1:3);      %extinction coefficient for coarse dust
        Afd=(1:3);      %extinction coefficient for fine dust
        Andm1=(1:3);    %extinction coefficient for non-dust marine
        Ands1=(1:3);    %extinction coefficient for non-dust smoke
        Ad2=(1:3);      %extinction coefficient for dust 2 step
        Andm2=(1:3);    %...
        Ands2=(1:3);
        Abb = zeros(size(Bb));     % Extinction coefficient for biomass burning (tropospheric)
        Avsf = zeros(size(Bb));    % Extinction coefficient for volcanic sulfate (fresh)
        Avsa = zeros(size(Bb));    % Extinction coefficient for volcanic sulfate (aged)
        Avst = zeros(size(Bb));     % % Extinction coefficient for volcanic sulfate (topospheric)
        
        Md=(1:3);       %mass concentration for dust
        Mcd=(1:3);      %...
        Mfd=(1:3);
        Mndm1=(1:3);
        Mnds1=(1:3);
        Mndm2=(1:3);
        Mnds2=(1:3);
        Mbb = zeros(size(Bb));     % Mass concentration for biomass burning
        Mvsf = zeros(size(Bb));    % Mass concentration for volcanic sulfate (fresh)
        Mvsa = zeros(size(Bb));    % Mass concentration for volcanic sulfate (aged)
        Mvst = zeros(size(Bb));     % Mass concentration for volcanic sulfate (tropospheric)
        rel_fine_total_mass_conc=(1:3);
        rel_fine_total_ext=(1:3);
    
        for i=1:3
            for n=1:size(Bb,1)
                Ad(n,i)=lrd(i)*Bd1(n,i);
                Acd(n,i)=lrd(i)*Bcd_profile(n,i);
                Afd(n,i)=lrd(i)*Bfd_profile(n,i);
                Ad2(n,i)=Acd(n,i)+Afd(n,i);
                Andm1(n,i)=lrndm(i)*Bnd1(n,i);
                Ands1(n,i)=lrnds(i)*Bnd1(n,i);
                Andm2(n,i)=lrndm(i)*Bnd2_profile(n,i);
                Ands2(n,i)=lrnds(i)*Bnd2_profile(n,i);
                Abb(n,i) = lrbb(i) * Bnd1(n,i); % bb
                Avsf(n,i) = lrvs(i) * Bnd1(n,i); % vs fresh
                Avsa(n,i) = lrvs(i) * Bnd1(n,i); % vs aged
                Avst(n, i) = lrvs(i) * Bnd1(n, i); % vs tropospheric
                Md(n,i)=rhod*cv_d_mean(i)*lrd(i)*Bd1(n,i);
                Mcd(n,i)=rhod*cvc_d_mean(i)*lrd(i)*Bcd_profile(n,i);
                Mfd(n,i)=rhod*cvf_d_mean(i)*lrd(i)*Bfd_profile(n,i);
                Mndm1(n,i)=rhondm*vcndm(i)*lrndm(i)*Bnd1(n,i);
                Mnds1(n,i)=rhonds*vcnds(i)*lrnds(i)*Bnd1(n,i);
                Mndm2(n,i)=rhondm*vcndm(i)*lrndm(i)*Bnd2_profile(n,i);
                Mnds2(n,i)=rhonds*vcnds(i)*lrnds(i)*Bnd2_profile(n,i);
                Md2(n,i)=Mfd(n,i)+Mcd(n,i);
                Mbb(n,i) = rhobb * cv_bbt_mean(i) * lrbb(i) * Bnd1(n,i); % bb
                Mvsf(n,i) = rhovs * cv_vsf_mean(i) * lrvs(i) * Bnd1(n,i); % vs fresh
                Mvsa(n,i) = rhovs * cv_vsa_mean(i) * lrvs(i) * Bnd1(n,i); % vs aged
                Mvst(n, i) = rhovs * cv_vst_mean(i) * lrvs(i) * Bnd1(n,i); % vs tropospheric
                rel_fine_total_mass_conc(n,i)=Mfd(n,i)/Md2(n,i);
                rel_fine_total_ext(n,i)=Afd(n,i)/Ad2(n,i);
                
                if Abb(n,i) < 0.0; Abb(n,i) = 0; end % for handling NaN values
                if Avsf(n,i) < 0.0; Avsf(n,i) = 0; end % for handling NaN values
                if Avsa(n,i) < 0.0 || isnan(Avsa(n,i)); Avsa(n,i) = 0; end % for handling NaN values
                if Avst(n,i) < 0.0; Avst(n,i) = 0; end
                if Ad(n,i) < 0.0
                    Ad(n,i)=0; 
                end
                if Andm1(n,i) < 0.0
                    Andm1(n,i)=0; 
                end     
                if Ands1(n,i) < 0.0
                    Ands1(n,i)=0; 
                end   
                if Ad2(n,i) < 0.0
                    Ad2(n,i)=0;
                end
                if Andm2(n,i) < 0.0
                    Andm2(n,i)=0; 
                end     
                if Ands2(n,i) < 0.0
                    Ands2(n,i)=0; 
                end  
            end
        end
    
        % INTEGRATED/COLUMN MASS CONCENTRATION (g m^-2) up to 5km height ----------------
        % integrated mass from 1-step Abbroach
        % int_mass_d1=(1:3);
        % int_mass_cd=(1:3);
        % int_mass_fd=(1:3);
        % int_mass_d2=(1:3);
    
        c = 1;
        s = 1:c;
        for i=1:3
            int_mass_d1(s,i)=0;
            int_mass_cd(s,i)=0;
            int_mass_fd(s,i)=0;
            int_mass_d2(s,i)=0;
            for n=1:657
                int_mass_d1(s,i)=int_mass_d1(s,i)+Md(n,i)*7.5*1.E-06;
                int_mass_cd(s,i)=int_mass_cd(s,i)+Mcd(n,i)*7.5*1.E-06;
                int_mass_fd(s,i)=int_mass_fd(s,i)+Mfd(n,i)*7.5*1.E-06;
                int_mass_d2(s,i)=int_mass_d2(s,i)+(Mcd(n,i)+Mfd(n,i))*7.5*1.E-06;
            end
        end
    
    
        %% /////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////
        %-------CCN-&-INP-CALCULATIONS-----------------------------------------------
        %\\\\\\\\\\\\\\\\\\//////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\
        %Profiles of number and surface area concentration for different
        %aerosoltypes, depending on height (n) and wavelength (i)
        n_100_d=(1:3);        %number concentration of dust aerosol > 100nm
        n_50_c=(1:3);         %number concentration of continental aerosol > 50nm
        n_50_m=(1:3);         %number concentration of marine aerosol > 50nm
        n_250_d=(1:3);        %number concentration of dust aerosol > 250nm
        n_250_c=(1:3);        %number concentration of continental aerosol > 250nm
        n_250_m=(1:3);        %number concentration of marine aerosol > 250nm
        n_50_bb = (1:3);      %number concentration of biomass burning smoke aerosol > 50nm
        n_50_vsf = (1:3);     %number concentration of fresh vulcanic sulfate aerosol > 50nm
        n_50_vsa = (1:3);     %number concentration of aged vulcanic sulfate aerosol > 50nm
        n_50_vst = (1:3);     %number concentration of tropospheric vulcanic sulfate aerosol > 50nm
        n_250_bb = (1:3);     %number concentration of biomass burning smoke aerosol > 250nm
        n_250_vsf = (1:3);    %number concentration of fresh vulcanic sulfate aerosol > 250nm
        n_250_vsa = (1:3);    %number concentration of aged vulcanic sulfate aerosol > 250nm
        n_250_vst = (1:3);    %number concentration of tropospheric vulcanic sulfate aerosol > 250nm
        Sd=(1:3);           %surface area concentration of dust aerosol 
        Sc=(1:3);           %surface area concentration of continental aerosol   
        Sm=(1:3);           %surface area concentration of marine aerosol  
        Sbb = (1:3);        %surface area concentration of burning biomass aerosol 
        Svsf = (1:3);       %surface area concentration of fresh vulcanic sulfate aerosol 
        Svsa = (1:3);       %surface area concentration of aged vulcanic sulfate aerosol
        Svst = (1:3);       %surface area concentration of tropospheric vulcanic sulfate aerosol
        
        CCNd=(1:3);         %number concentration of CCN from dust
        CCNc=(1:3);         %number concentration of CCN from continental aerosol
        CCNm=(1:3);         %number concentration of CCN from marine
        CCN=(1:3);          %total number concentration of CCN 
        CCNbb = (1:3);      %total number concentration of CCN from biomass burning smoke
        CCNvsf = (1:3);     %total number concentration of CCN from fresh vulcanic sulfate
        CCNvsa = (1:3);     %total number concentration of CCN from aged vulcanic sulfate
        CCNvst = (1:3);     %total number concentration of CCN from tropospheric vulcanic sulfate
        
    for i=1:3 
    %    i=2;        %only 532
        for n=1:size(Bb,1)
            n_100_d(n,i)=c100_d_mean(i)*Ad(n,i)^chid(i);     % 1-step dust extinction is used   
            n_50_c(n,i)=c50_c_1620_mean(i)*Ands1(n,i)^chic(i);         %no continental aerosol on Barbados, extinction coef. for smoke used here, which is not correct. Conversion factors for smoke needed. Further on only sepatration between marine and dust for Barbados.
            n_50_m(n,i)=c50_m_mean(i)*Andm1(n,i)^chim(i);    % 1-step non-dust marine extinction used 
            n_250_d(n,i)=c250_d_mean(i)*Ad(n,i);      
            n_250_c(n,i)=c250_c_1620_mean(i)*Ands1(n,i);         
            n_250_m(n,i)=c250_m_mean(i)*Andm1(n,i);  
            n_50_bb(n,i) = c50_bbt_mean(i) * Abb(n,i)^chibb(i);
            n_250_bb(n,i) = c250_bbt_mean(i) * Abb(n,i);
            n_50_vsf(n,i) = c50_vsf_mean(i) * Avsf(n,i)^chivs(i);
            n_250_vsf(n,i) = c250_vsf_mean(i) * Avsf(n,i);
            %n_50_vsa(n,i) = c50_vsa_mean(i) * Avsa(n,i)^chivs(i);
            %n_250_vsa(n,i) = c250_vsa_mean(i) * Avsa(n,i);
            n_50_vst(n,i) = c50_vst_mean(i) * Avst(n,i)^chivs(i);
            n_250_vst(n,i) = c250_vst_mean(i) * Avst(n,i);
            Sd(n,i)=cs_d_mean(i)*10^(-12)*Ad(n,i);         %factor 10^-12 Mm m^2 cm^-3 from units in head of Table 3 (M&A2016)
            Sc(n,i)=cs_c_1620_mean(i)*10^(-12)*Ands1(n,i);          % cs_c_1620_mean is used (not cs_c_1115_mean) 
            Sm(n,i)=cs_m_mean(i)*10^(-12)*Andm1(n,i);
            Sbb(n,i) = cs_bbt_mean(i) * 10^(-12) * Abb(n,i);
            Svsf(n,i) = cs_vsf_mean(i) * 10^(-12) * Avsf(n,i);
            Svst(n,i) = cs_vst_mean(i) * 10^(-12) * Avst(n,i);
            %Svsa(n,i) = cs_vsa_mean(i) * 10^(-12) * Avsa(n,i);
            CCNd(n,i)=fssd*n_100_d(n,i);
            CCNc(n,i)=fssc*n_50_c(n,i);
            CCNm(n,i)=fssm*n_50_m(n,i);
            CCN(n,i)=CCNd(n,i)+CCNm(n,i);       %continental is not considered here, only dust and non-dust-marine, because there is no separation of the non-dust contribution between continental and marine, the calculation take the total non-dust eigther as marine or as smoke
            CCNbb(n,i) = fssbb * n_50_bb(n,i);
            CCNvsf(n,i) = fssvs * n_50_vsf(n,i);
            CCNvst(n,i) = fssvs * n_50_vst(n,i);
            %CCNvsa(n,i) = fssvs * n_50_vsa(n,i);
            % % cf for aged vulcanic sulfate for 355 is nan (will crash when
            % multiplying with extinction coeff), therefore:
            if ~isnan(c50_vsa_mean(i))  
                n_50_vsa(n,i) = c50_vsa_mean(i) * Avsa(n,i)^chivs(i);
                n_250_vsa(n,i) = c250_vsa_mean(i) * Avsa(n,i);
                Svsa(n,i) = cs_vsa_mean(i) * 10^(-12) * Avsa(n,i);
                CCNvsa(n,i) = fssvs * n_50_vsa(n,i);
            else
                n_50_vsa(n,i) = 0; n_250_vsa(n,i) = 0; Svsa(n,i) = 0; CCNvsa(n,i) = 0;
            end
            if n_250_d(n,i) < 0.0
               n_250_d(n,i)=0; 
            end
            if n_250_c(n,i) < 0.0
               n_250_c(n,i)=0; 
            end
            if n_250_m(n,i) < 0.0
               n_250_m(n,i)=0; 
            end
            if Sd(n,i) < 0.0
               Sd(n,i)=0; 
            if n_250_bb(n,i) < 0.0
               n_250_bb(n,i) = 0; 
            end
            if Sbb(n,i) < 0.0 
               Sbb(n,i) = 0; 
            end
            if n_250_vsf(n,i) < 0.0 
               n_250_vsf(n,i) = 0; 
            end
            if Svsf(n,i) < 0.0 
               Svsf(n,i) = 0; 
            end
            if n_250_vst(n,i) < 0.0 
               n_250_vst(n,i) = 0; 
            end
            if n_250_vsa(n,i) < 0.0
               n_250_vsa(n,i) = 0; 
            end
            if Svsa(n,i) < 0.0
               Svsa(n,i) = 0; 
            end
           end
        end
    end
        
    %INP-Calculations after DeMott 2010 -> continental, DeMott2015 
    % -> Dust  for ambient conditions (T, p) _amb
    %for dust after Monika Niemand 2012 and Isabelle Steinke 2015
           INPc_d10_amb=zeros(size(Bb));       %profile INP concentration of continental aerosol 
           INPm_d10_amb=zeros(size(Bb));      %profile INP concentration of marine aerosol 
           %Dust parametrizations
           INPd_d10_amb=zeros(size(Bb));       %profile INP concentration of dust, using the general DeMott 2010 parametrization 
           INPd_d15_amb=zeros(size(Bb));       %profile INP concentration of dust, using the dust specific DeMott 2015 parametrization
           INPd_n12_amb=zeros(size(Bb));       %profile INP concentration of dust, using the dust specific Niemand 2012 parametrization
           INPd_s15_amb=zeros(size(Bb));       %profile INP concentration of dust, using the dust specific Steinke 2015 parametrization
           INPbb_d10_amb = zeros(size(Bb));  %profile INP concentration of biomass burning smoke, using the general DeMott 2010 parametrization
           INPvsf_d10_amb = zeros(size(Bb)); %profile INP concentration of fresh vulcanic sulfate, using the general DeMott 2010 parametrization
           INPvst_d10_amb = zeros(size(Bb)); %profile INP concentration of tropospheric vulcanic sulfate, using the general DeMott 2010 parametrization
           INPvsa_d10_amb = zeros(size(Bb)); %profile INP concentration of aged vulcanic sulfate, using the general DeMott 2010 parametrization
           % only d10 for bb, vsf and vsa?
          
    
    
    Temp = temperature(1,:).';
    Pres = pressure(1,:).';
    Hs = NaN(size(Temp));
    
    Sonde=[Hs,Temp,Pres];
    % Sonde(n,2) = data.temperature
    % Sonde(n,3) = data.pressure
    
    for i=1:3
    %    i=2;        %only 532
       for n=1:size(Bb,1)
           if Sonde(n,2)>273.16
               INPc_d10_amb(n,i)=0.0;
               INPm_d10_amb(n,i)=0.0;
               INPd_d10_amb(n,i)=0.0;          
               INPd_d15_amb(n,i)=0.0;
               INPd_n12_amb(n,i)=0.0;
               INPd_s15_amb(n,i)=0.0;
               INPbb_d10_amb(n,i) = 0.0;
               INPvsf_d10_amb(n,i) = 0.0;
               INPvsa_d10_amb(n,i) = 0.0;
               INPvst_d10_amb(n,i) = 0.0;
           else
               INPd_d10_amb(n,i)=(273.16*Sonde(n,3)/Sonde(n,2)/1013)*0.0000594*(273.16-Sonde(n,2))^3.33*n_250_d(n,i)^(0.0265*(273.16-Sonde(n,2))+0.0033);
               INPc_d10_amb(n,i)=(273.16*Sonde(n,3)/Sonde(n,2)/1013)*0.0000594*(273.16-Sonde(n,2))^3.33*n_250_c(n,i)^(0.0265*(273.16-Sonde(n,2))+0.0033);
               INPm_d10_amb(n,i)=(273.16*Sonde(n,3)/Sonde(n,2)/1013)*0.0000594*(273.16-Sonde(n,2))^3.33*n_250_m(n,i)^(0.0265*(273.16-Sonde(n,2))+0.0033)/350;   %same parametrization as continental but with n_250_m as input and divided by 350 (DeMott2015b)
               INPd_d15_amb(n,i)=(273.16*Sonde(n,3)/Sonde(n,2)/1013)*3*n_250_d(n,i)^1.25*exp(0.46*(273.16-Sonde(n,2))-11.6);     
               INPd_n12_amb(n,i)=1000*Sd(n,i)*exp(-0.517*(Sonde(n,2)-273.16)+8.934);
               INPd_s15_amb(n,i)=1000*Sd(n,i)*1.88e5*exp(0.2659*(-(Sonde(n,2)-273.16)+(1.15-1)*100));
               INPbb_d10_amb(n,i) = (273.16*Sonde(n,3)/Sonde(n,2)/1013) * 0.0000594 * (273.16-Sonde(n,2))^3.33 * n_250_bb(n,i)^(0.0265*(273.16-Sonde(n,2))+0.0033);
               INPvsf_d10_amb(n,i) = (273.16*Sonde(n,3)/Sonde(n,2)/1013) * 0.0000594 * (273.16-Sonde(n,2))^3.33 * n_250_vsf(n,i)^(0.0265*(273.16-Sonde(n,2))+0.0033);
               INPvsa_d10_amb(n,i) = (273.16*Sonde(n,3)/Sonde(n,2)/1013) * 0.0000594 * (273.16-Sonde(n,2))^3.33 * n_250_vsa(n,i)^(0.0265*(273.16-Sonde(n,2))+0.0033);
               INPvst_d10_amb(n,i) = (273.16*Sonde(n,3)/Sonde(n,2)/1013) * 0.0000594 * (273.16-Sonde(n,2))^3.33 * n_250_vst(n,i)^(0.0265*(273.16-Sonde(n,2))+0.0033);
           end
       end    
    end
     
    %INP calculations for fixed temperatures t , -15°, -20° C ...
    INPd_d10=zeros(size(Bb,1), 3, 7); % maybe use zeros(size(Bb,1), 3, 7); instead of zeros(2,2,2); ?
    INPc_d10=zeros(size(Bb,1), 3, 7);
    INPm_d10=zeros(size(Bb,1), 3, 7);
    INPd_d15=zeros(size(Bb,1), 3, 7);
    INPd_n12=zeros(size(Bb,1), 3, 7);
    INPd_s15=zeros(size(Bb,1), 3, 7);
    INPbb_d10 = zeros(size(Bb,1), 3, 7);
    INPvsf_d10 = zeros(size(Bb,1), 3, 7);
    INPvsa_d10 = zeros(size(Bb,1), 3, 7);
    INPvst_d10 = zeros(size(Bb,1), 3, 7);
    for t=1:7
        INtemp=t*(-5);
        for i=1:3
            for n=1:size(Bb,1)
               INPd_d10(n,i,t)=0.0000594*(-INtemp)^3.33*n_250_d(n,i)^(0.0265*(-INtemp)+0.0033);
               INPc_d10(n,i,t)=0.0000594*(-INtemp)^3.33*n_250_c(n,i)^(0.0265*(-INtemp)+0.0033);
               INPm_d10(n,i,t)=0.0000594*(-INtemp)^3.33*n_250_m(n,i)^(0.0265*(-INtemp)+0.0033)/350;   %same parametrization as continental but with n_250_m as input and divided by 350 (DeMott2015b)
               INPd_d15(n,i,t)=3*n_250_d(n,i)^1.25*exp(0.46*(-INtemp)-11.6);     
               INPd_n12(n,i,t)=1000*Sd(n,i)*exp(-0.517*(INtemp)+8.934);
               INPd_s15(n,i,t)=1000*Sd(n,i)*1.88e5*exp(0.2659*(-(INtemp)+(1.15-1)*100));
               INPbb_d10(n,i,t) = 0.0000594*(-INtemp)^3.33 * n_250_bb(n,i)^(0.0265*(-INtemp)+0.0033);
               INPvsf_d10(n,i,t) = 0.0000594*(-INtemp)^3.33 * n_250_vsf(n,i)^(0.0265*(-INtemp)+0.0033);
               INPvsa_d10(n,i,t) = 0.0000594*(-INtemp)^3.33 * n_250_vsa(n,i)^(0.0265*(-INtemp)+0.0033);
               INPvst_d10(n,i,t) = 0.0000594*(-INtemp)^3.33 * n_250_vst(n,i)^(0.0265*(-INtemp)+0.0033);
            end
        end
    end
    
    % For marine areosol
    % 
    % McCluskey et al. 2018ab
    % def n_s_m(Tz):  %m^-2
    %      "calculates ice nucleation actvie site density [m^-2] of marine aerosol as a fct of temperature. input: temperature profile Tz [K]"
    %      n_s_m=np.zeros(len(Tz))
    %      a=-0.545
    %      b=1.0125
    %      for i in range(0,len(Tz),1):
    %          if (Tz[i]>237.16 and Tz[i]<261.16): % validity range
    %              n_s_m[i]=np.exp( a * ( Tz[i]-273.16 ) + b)  %m^-2
    %          else:
    %              n_s_m[i]=np.nan
    
    %     return n_s_m
    
    %% Uncertainties from Ansmann et al. 2026 (not published 27.04.2026)
    % Lidar observation
    unc_pbc = 0.1; % Uncertainty of Particle backscatter coefficient: 10%
    unc_pec = 0.2; % Uncertainty of Particle extinction coefficient: 20%
    % Primary retrieval products
    unc_pnc50 = 0.5; % Uncertarinty of Particle number concentration (r>50 nm): 50%
    unc_pnc100 = 0.5; % Uncertarinty of Particle number concentration (r>100 nm): 50%
    unc_pnc250 = 0.3; % Uncertarinty of Particle number concentration (r>250 nm): 50%
    unc_psc = 0.3; % Uncertainty of Particle surface concentration: 30%
    unc_pvc = 0.3; % Uncertainty of Particle volume concentration: 30%
    % Products for environmental and cloud studies
    unc_pmc = 0.3; % Uncertainty of Partice mass concentration: 30%
    unc_CCNcmbb = 0.5; % Uncertainty for CCN concentration of continental, marine alnd biomass burning smoke: 50%
    unc_CCNd = 0.5; % Uncertainty for CCN concentration of dust: 50%
    % unc_INPd = ?; % Uncertainty for INP concentration of dust (d15,IF,n_250_,d,dry): factor 2
    % unc_INPc = ?; % Uncertainty for INP concentration of continental (d10,IF,n_250_,c,dry): factor 2
    % unc_INPd = ?; % Uncertainty for INP concentration of dust (U17,DIN,sd,dry): factor 2
    % unc_INPdbb = ?; % Uncertainty for INP concentration of dust and biomass burning smoke (KA13,ABIFM,s_,dry): factor 2
    % unc_INPdbb = ?; % Uncertainty for INP concentration of dust and biomass burning smoke (W12,DIN,s_,dry): factor 2
    % unc_INPvs = ?; % Uncertainty for INP concentration of vulcanic sulfate (K00,HOM,v_vs,dry): factor 2
    
    %% ERROR CALCULATION -------------------------------------------------------
    
    % error_mass_dust = let empty = NaN
    % Sonde = temp/ press
    
    % ERROR CALCULATION -------------------------------------------------------
    
        error_mass_dust_height = NaN;
        error_mass_coarse_dust_height = NaN;
        error_mass_smoke_height = NaN;
        error_mass_marine_height = NaN;
        error_mass_bb_height = NaN;
        error_mass_vs_height = NaN;
    
        % according to error heights which are set above error values are only
        % written in the predefined heights, rest is filled with NaN --> for plots
        % in Grapher
        for i=1:3
            for n=1:size(Bb,1)
                % Dust Errors
                for k=1:size(error_mass_dust_height,2)
                    if error_mass_dust_height(k)==n
                        error_Md(n,i)         = unc_pmc * Md(n,i);
                        error_Mcd_temp(n,i)   = unc_pmc * Mcd(n,i);
                        error_Mfd(n,i)        = unc_pmc * Mfd(n,i);
                        error_Ad(n,i)         = unc_pec * Ad(n,i);
                        error_Afd(n,i)        = unc_pec * Afd(n,i);
                        error_Ad2(n,i)        = unc_pec * Ad2(n,i);
                        error_Md2(n,i)        = error_Mfd(n,i) + error_Mcd_temp(n,i);
                        break;
                    else
                        error_Md(n,i)         = NaN;
                        error_Mcd_temp(n,i)   = NaN;
                        error_Mfd(n,i)        = NaN;
                        error_Ad(n,i)         = NaN;
                        error_Afd(n,i)        = NaN;
                        error_Ad2(n,i)        = NaN;
                        error_Md2(n,i)        = NaN; 
                    end
                end
                
                % Coarse Dust Errors
                for k=1:size(error_mass_coarse_dust_height,2)
                    if error_mass_coarse_dust_height(k)==n
                        error_Mcd(n,i) = unc_pmc * Mcd(n,i);
                        error_Acd(n,i) = unc_pec * Ad(n,i); 
                        break;
                    else
                        error_Mcd(n,i) = NaN;
                        error_Acd(n,i) = NaN;
                    end
                end
                
                % Smoke Errors
                for k=1:size(error_mass_smoke_height,2)
                    if error_mass_smoke_height(k)==n
                        error_Mnds1(n,i) = unc_pmc * Mnds1(n,i);
                        error_Mnds2(n,i) = unc_pmc * Mnds2(n,i);
                        error_Ands1(n,i) = unc_pec * Ands1(n,i);
                        error_Ands2(n,i) = unc_pec * Ands2(n,i);
                        break;
                    else
                        error_Mnds1(n,i) = NaN;
                        error_Mnds2(n,i) = NaN;
                        error_Ands1(n,i) = NaN;
                        error_Ands2(n,i) = NaN;
                    end
                end
                
                % Marine Errors
                for k=1:size(error_mass_marine_height,2)
                    if error_mass_marine_height(k)==n
                        error_Mndm1(n,i) = unc_pmc * Mndm1(n,i);
                        error_Mndm2(n,i) = unc_pmc * Mndm2(n,i);
                        error_Andm1(n,i) = unc_pec * Andm1(n,i);
                        error_Andm2(n,i) = unc_pec * Andm2(n,i);
                        break;
                    else
                        error_Mndm1(n,i) = NaN;
                        error_Mndm2(n,i) = NaN;
                        error_Andm1(n,i) = NaN;
                        error_Andm2(n,i) = NaN;
                    end
                end
                
                % Biomass Burning Errors
                for k=1:size(error_mass_bb_height,2)
                    if error_mass_bb_height(k)==n
                        error_Mbb(n,i) = unc_pmc * Mbb(n,i);
                        error_Abb(n,i) = unc_pec * Abb(n,i);
                        break;
                    else
                        error_Mbb(n,i) = NaN;
                        error_Abb(n,i) = NaN;
                    end
                end
                
                % Volcanic Sulfate Errors
                for k=1:size(error_mass_vs_height,2)
                    if error_mass_vs_height(k)==n
                        error_Mvsf(n,i) = unc_pmc * Mvsf(n,i);
                        error_Mvsa(n,i) = unc_pmc * Mvsa(n,i);
                        error_Mvst(n,i) = unc_pmc * Mvst(n,i);
    
                        error_Avsf(n,i) = unc_pec * Avsf(n,i);
                        error_Avsa(n,i) = unc_pec * Avsa(n,i);
                        error_Avst(n,i) = unc_pec * Avst(n,i);
                        break;
                    else
                        error_Mvsf(n,i) = NaN;
                        error_Mvsa(n,i) = NaN;
                        error_Mvst(n,i) = NaN;
    
                        error_Avsf(n,i) = NaN;
                        error_Avsa(n,i) = NaN;
                        error_Avst(n,i) = NaN;
                    end
                end
            end
        end
    
    
    % only for extinction and mass?
    % possible: Particle backscatter coefficient, Particle number
    % concentration (r>50  and r>100), particle number
    % concentration/surface/volume (r>250), CCN and INPO concentrations
    
    
    
    %% output
    
    
    
    if method == 1 % raman
        % 1-step
        POLIPHON2.aerBsc355_raman_d1 = aerBsc355_raman_d1;
        POLIPHON2.aerBsc355_raman_nd1 = aerBsc355_raman_nd1;
        POLIPHON2.aerBsc532_raman_d1 = aerBsc532_raman_d1;
        POLIPHON2.aerBsc532_raman_nd1 = aerBsc532_raman_nd1;
        POLIPHON2.aerBsc1064_raman_d1 = aerBsc1064_raman_d1;
        POLIPHON2.aerBsc1064_raman_nd1 = aerBsc1064_raman_nd1;
        POLIPHON2.err_aerBsc355_raman_d1 = err_aerBsc355_raman_d1;
        POLIPHON2.err_aerBsc355_raman_nd1 = err_aerBsc355_raman_nd1;
        POLIPHON2.err_aerBsc532_raman_d1 = err_aerBsc532_raman_d1;
        POLIPHON2.err_aerBsc532_raman_nd1 = err_aerBsc532_raman_nd1;
        POLIPHON2.err_aerBsc1064_raman_d1 = err_aerBsc1064_raman_d1;
        POLIPHON2.err_aerBsc1064_raman_nd1 = err_aerBsc1064_raman_nd1;
        
        % 2-step
        POLIPHON2.aerBsc355_raman_d2 = aerBsc355_raman_d2;
        POLIPHON2.aerBsc355_raman_nd2 = aerBsc355_raman_nd2;
        POLIPHON2.aerBsc355_raman_dc2 = aerBsc355_raman_dc2;
        POLIPHON2.aerBsc355_raman_df2 = aerBsc355_raman_df2;
        %POLIPHON2.aerBsc355_raman_nddf2 = aerBsc355_raman_nnddf2;
        
        POLIPHON2.aerBsc532_raman_d2 = aerBsc532_raman_d2;
        POLIPHON2.aerBsc532_raman_nd2 = aerBsc532_raman_nd2;
        POLIPHON2.aerBsc532_raman_dc2 = aerBsc532_raman_dc2;
        POLIPHON2.aerBsc532_raman_df2 = aerBsc532_raman_df2;
        %POLIPHON2.aerBsc532_raman_nddf2 = aerBsc532_raman_nnddf2;
        
        POLIPHON2.aerBsc1064_raman_d2 = aerBsc1064_raman_d2;
        POLIPHON2.aerBsc1064_raman_nd2 = aerBsc1064_raman_nd2;
        POLIPHON2.aerBsc1064_raman_dc2 = aerBsc1064_raman_dc2;
        POLIPHON2.aerBsc1064_raman_df2 = aerBsc1064_raman_df2;
        %POLIPHON2.aerBsc1064_raman_nddf2 = aerBsc1064_raman_nnddf2;
    
        % err
        POLIPHON2.err_aerBsc355_raman_d2 = err_aerBsc355_raman_d2;
        POLIPHON2.err_aerBsc355_raman_nd2 = err_aerBsc355_raman_nd2;
        POLIPHON2.err_aerBsc355_raman_dc2 = err_aerBsc355_raman_dc2;
        POLIPHON2.err_aerBsc355_raman_df2 = err_aerBsc355_raman_df2;

        POLIPHON2.err_aerBsc532_raman_d2 = err_aerBsc532_raman_d2;
        POLIPHON2.err_aerBsc532_raman_nd2 = err_aerBsc532_raman_nd2;
        POLIPHON2.err_aerBsc532_raman_dc2 = err_aerBsc532_raman_dc2;
        POLIPHON2.err_aerBsc532_raman_df2 = err_aerBsc532_raman_df2;

        POLIPHON2.err_aerBsc1064_raman_d2 = err_aerBsc1064_raman_d2;
        POLIPHON2.err_aerBsc1064_raman_nd2 = err_aerBsc1064_raman_nd2;
        POLIPHON2.err_aerBsc1064_raman_dc2 = err_aerBsc1064_raman_dc2;
        POLIPHON2.err_aerBsc1064_raman_df2 = err_aerBsc1064_raman_df2;

        % extinction coeffs
        POLIPHON2.ext_d_raman_355    = Ad(:, 1);        % Dust 355
        POLIPHON2.ext_d_raman_532    = Ad(:, 2);        % Dust 532
        POLIPHON2.ext_d_raman_1064   = Ad(:, 3);        % Dust 1064
        
        POLIPHON2.ext_cd_raman_355   = Acd(:, 1);       % Coarse Dust 355
        POLIPHON2.ext_cd_raman_532   = Acd(:, 2);       % Coarse Dust 532
        POLIPHON2.ext_cd_raman_1064  = Acd(:, 3);       % Coarse Dust 1064
        
        POLIPHON2.ext_fd_raman_355   = Afd(:, 1);       % Fine Dust 355
        POLIPHON2.ext_fd_raman_532   = Afd(:, 2);       % Fine Dust 532
        POLIPHON2.ext_fd_raman_1064  = Afd(:, 3);       % Fine Dust 1064
        
        POLIPHON2.ext_ndm_raman_355  = Andm1(:, 1);     % Non-Dust Marine 355
        POLIPHON2.ext_ndm_raman_532  = Andm1(:, 2);     % Non-Dust Marine 532
        POLIPHON2.ext_ndm_raman_1064 = Andm1(:, 3);     % Non-Dust Marine 1064
        
        POLIPHON2.ext_nds_raman_355  = Ands1(:, 1);     % Non-Dust Smoke 355
        POLIPHON2.ext_nds_raman_532  = Ands1(:, 2);     % Non-Dust Smoke 532
        POLIPHON2.ext_nds_raman_1064 = Ands1(:, 3);     % Non-Dust Smoke 1064
        
        POLIPHON2.ext_bb_raman_355   = Abb(:, 1);       % Biomass Burning 355
        POLIPHON2.ext_bb_raman_532   = Abb(:, 2);       % Biomass Burning 532
        POLIPHON2.ext_bb_raman_1064  = Abb(:, 3);       % Biomass Burning 1064
        
        POLIPHON2.ext_vsf_raman_355  = Avsf(:, 1);      % Volcanic Sulfate Fresh 355
        POLIPHON2.ext_vsf_raman_532  = Avsf(:, 2);      % Volcanic Sulfate Fresh 532
        POLIPHON2.ext_vsf_raman_1064 = Avsf(:, 3);      % Volcanic Sulfate Fresh 1064
        
        POLIPHON2.ext_vsa_raman_355  = Avsa(:, 1);      % Volcanic Sulfate Aged 355
        POLIPHON2.ext_vsa_raman_532  = Avsa(:, 2);      % Volcanic Sulfate Aged 532
        POLIPHON2.ext_vsa_raman_1064 = Avsa(:, 3);      % Volcanic Sulfate Aged 1064
        
        POLIPHON2.ext_vst_raman_355  = Avst(:, 1);      % Volcanic Sulfate Tropospheric 355
        POLIPHON2.ext_vst_raman_532  = Avst(:, 2);      % Volcanic Sulfate Tropospheric 532
        POLIPHON2.ext_vst_raman_1064 = Avst(:, 3);      % Volcanic Sulfate Tropospheric 1064
        
        % mass concentrations
        POLIPHON2.m_d_raman_355   = Md(:, 1);
        POLIPHON2.m_d_raman_532   = Md(:, 2);
        POLIPHON2.m_d_raman_1064  = Md(:, 3);
        
        POLIPHON2.m_cd_raman_355  = Mcd(:, 1);
        POLIPHON2.m_cd_raman_532  = Mcd(:, 2);
        POLIPHON2.m_cd_raman_1064 = Mcd(:, 3);
        
        POLIPHON2.m_fd_raman_355  = Mfd(:, 1);
        POLIPHON2.m_fd_raman_532  = Mfd(:, 2);
        POLIPHON2.m_fd_raman_1064 = Mfd(:, 3);
        
        POLIPHON2.m_ndm_raman_355 = Mndm1(:, 1);
        POLIPHON2.m_ndm_raman_532 = Mndm1(:, 2);
        POLIPHON2.m_ndm_raman_1064= Mndm1(:, 3);
        
        POLIPHON2.m_nds_raman_355 = Mnds1(:, 1);
        POLIPHON2.m_nds_raman_532 = Mnds1(:, 2);
        POLIPHON2.m_nds_raman_1064= Mnds1(:, 3);
        
        POLIPHON2.m_bb_raman_355  = Mbb(:, 1);
        POLIPHON2.m_bb_raman_532  = Mbb(:, 2);
        POLIPHON2.m_bb_raman_1064 = Mbb(:, 3);
        
        POLIPHON2.m_vsf_raman_355 = Mvsf(:, 1);
        POLIPHON2.m_vsf_raman_532 = Mvsf(:, 2);
        POLIPHON2.m_vsf_raman_1064= Mvsf(:, 3);
        
        POLIPHON2.m_vsa_raman_355 = Mvsa(:, 1);
        POLIPHON2.m_vsa_raman_532 = Mvsa(:, 2);
        POLIPHON2.m_vsa_raman_1064= Mvsa(:, 3);
        
        POLIPHON2.m_vst_raman_355 = Mvst(:, 1);
        POLIPHON2.m_vst_raman_532 = Mvst(:, 2);
        POLIPHON2.m_vst_raman_1064= Mvst(:, 3);
        
        % number concentrations
        POLIPHON2.n_100_d_raman_355   = n_100_d(:, 1);
        POLIPHON2.n_100_d_raman_532   = n_100_d(:, 2);
        POLIPHON2.n_100_d_raman_1064  = n_100_d(:, 3);
        
        POLIPHON2.n_250_d_raman_355   = n_250_d(:, 1);
        POLIPHON2.n_250_d_raman_532   = n_250_d(:, 2);
        POLIPHON2.n_250_d_raman_1064  = n_250_d(:, 3);
        
        POLIPHON2.n_50_c_raman_355    = n_50_c(:, 1);
        POLIPHON2.n_50_c_raman_532    = n_50_c(:, 2);
        POLIPHON2.n_50_c_raman_1064   = n_50_c(:, 3);
        
        POLIPHON2.n_250_c_raman_355   = n_250_c(:, 1);
        POLIPHON2.n_250_c_raman_532   = n_250_c(:, 2);
        POLIPHON2.n_250_c_raman_1064  = n_250_c(:, 3);
        
        POLIPHON2.n_50_m_raman_355    = n_50_m(:, 1);
        POLIPHON2.n_50_m_raman_532    = n_50_m(:, 2);
        POLIPHON2.n_50_m_raman_1064   = n_50_m(:, 3);
        
        POLIPHON2.n_250_m_raman_355   = n_250_m(:, 1);
        POLIPHON2.n_250_m_raman_532   = n_250_m(:, 2);
        POLIPHON2.n_250_m_raman_1064  = n_250_m(:, 3);
        
        POLIPHON2.n_50_bb_raman_355   = n_50_bb(:, 1);
        POLIPHON2.n_50_bb_raman_532   = n_50_bb(:, 2);
        POLIPHON2.n_50_bb_raman_1064  = n_50_bb(:, 3);
        
        POLIPHON2.n_250_bb_raman_355  = n_250_bb(:, 1);
        POLIPHON2.n_250_bb_raman_532  = n_250_bb(:, 2);
        POLIPHON2.n_250_bb_raman_1064 = n_250_bb(:, 3);
        
        POLIPHON2.n_50_vsf_raman_355  = n_50_vsf(:, 1);
        POLIPHON2.n_50_vsf_raman_532  = n_50_vsf(:, 2);
        POLIPHON2.n_50_vsf_raman_1064 = n_50_vsf(:, 3);
        
        POLIPHON2.n_250_vsf_raman_355 = n_250_vsf(:, 1);
        POLIPHON2.n_250_vsf_raman_532 = n_250_vsf(:, 2);
        POLIPHON2.n_250_vsf_raman_1064= n_250_vsf(:, 3);
        
        POLIPHON2.n_50_vsa_raman_355  = n_50_vsa(:, 1);
        POLIPHON2.n_50_vsa_raman_532  = n_50_vsa(:, 2);
        POLIPHON2.n_50_vsa_raman_1064 = n_50_vsa(:, 3);
        
        POLIPHON2.n_250_vsa_raman_355 = n_250_vsa(:, 1);
        POLIPHON2.n_250_vsa_raman_532 = n_250_vsa(:, 2);
        POLIPHON2.n_250_vsa_raman_1064= n_250_vsa(:, 3);
        
        POLIPHON2.n_50_vst_raman_355  = n_50_vst(:, 1);
        POLIPHON2.n_50_vst_raman_532  = n_50_vst(:, 2);
        POLIPHON2.n_50_vst_raman_1064 = n_50_vst(:, 3);
        
        POLIPHON2.n_250_vst_raman_355 = n_250_vst(:, 1);
        POLIPHON2.n_250_vst_raman_532 = n_250_vst(:, 2);
        POLIPHON2.n_250_vst_raman_1064= n_250_vst(:, 3);
        
        % surface area concentrations
        POLIPHON2.sa_d_raman_355   = Sd(:, 1);
        POLIPHON2.sa_d_raman_532   = Sd(:, 2);
        POLIPHON2.sa_d_raman_1064  = Sd(:, 3);
        
        POLIPHON2.sa_c_raman_355   = Sc(:, 1);
        POLIPHON2.sa_c_raman_532   = Sc(:, 2);
        POLIPHON2.sa_c_raman_1064  = Sc(:, 3);
        
        POLIPHON2.sa_m_raman_355   = Sm(:, 1);
        POLIPHON2.sa_m_raman_532   = Sm(:, 2);
        POLIPHON2.sa_m_raman_1064  = Sm(:, 3);
        
        POLIPHON2.sa_bb_raman_355  = Sbb(:, 1);
        POLIPHON2.sa_bb_raman_532  = Sbb(:, 2);
        POLIPHON2.sa_bb_raman_1064 = Sbb(:, 3);
        
        POLIPHON2.sa_vsf_raman_355 = Svsf(:, 1);
        POLIPHON2.sa_vsf_raman_532 = Svsf(:, 2);
        POLIPHON2.sa_vsf_raman_1064= Svsf(:, 3);
        
        POLIPHON2.sa_vsa_raman_355 = Svsa(:, 1);
        POLIPHON2.sa_vsa_raman_532 = Svsa(:, 2);
        POLIPHON2.sa_vsa_raman_1064= Svsa(:, 3);
        
        POLIPHON2.sa_vst_raman_355 = Svst(:, 1);
        POLIPHON2.sa_vst_raman_532 = Svst(:, 2);
        POLIPHON2.sa_vst_raman_1064= Svst(:, 3);
        
        % err
        % extinction err
        POLIPHON2.err_ext_d_raman_355   = error_Ad(:, 1);
        POLIPHON2.err_ext_d_raman_532   = error_Ad(:, 2);
        POLIPHON2.err_ext_d_raman_1064  = error_Ad(:, 3);
        
        POLIPHON2.err_ext_cd_raman_355  = error_Acd(:, 1);
        POLIPHON2.err_ext_cd_raman_532  = error_Acd(:, 2);
        POLIPHON2.err_ext_cd_raman_1064 = error_Acd(:, 3);
        
        POLIPHON2.err_ext_fd_raman_355  = error_Afd(:, 1);
        POLIPHON2.err_ext_fd_raman_532  = error_Afd(:, 2);
        POLIPHON2.err_ext_fd_raman_1064 = error_Afd(:, 3);
        
        POLIPHON2.err_ext_ndm_raman_355 = error_Andm1(:, 1);
        POLIPHON2.err_ext_ndm_raman_532 = error_Andm1(:, 2);
        POLIPHON2.err_ext_ndm_raman_1064= error_Andm1(:, 3);
        
        POLIPHON2.err_ext_nds_raman_355 = error_Ands1(:, 1);
        POLIPHON2.err_ext_nds_raman_532 = error_Ands1(:, 2);
        POLIPHON2.err_ext_nds_raman_1064= error_Ands1(:, 3);
        
        POLIPHON2.err_ext_bb_raman_355  = error_Abb(:, 1);
        POLIPHON2.err_ext_bb_raman_532  = error_Abb(:, 2);
        POLIPHON2.err_ext_bb_raman_1064 = error_Abb(:, 3);
        
        POLIPHON2.err_ext_vsf_raman_355 = error_Avsf(:, 1);
        POLIPHON2.err_ext_vsf_raman_532 = error_Avsf(:, 2);
        POLIPHON2.err_ext_vsf_raman_1064= error_Avsf(:, 3);
        
        POLIPHON2.err_ext_vsa_raman_355 = error_Avsa(:, 1);
        POLIPHON2.err_ext_vsa_raman_532 = error_Avsa(:, 2);
        POLIPHON2.err_ext_vsa_raman_1064= error_Avsa(:, 3);
        
        POLIPHON2.err_ext_vst_raman_355 = error_Avst(:, 1);
        POLIPHON2.err_ext_vst_raman_532 = error_Avst(:, 2);
        POLIPHON2.err_ext_vst_raman_1064= error_Avst(:, 3);
        
        % mass err
        POLIPHON2.err_m_d_raman_355   = error_Md(:, 1);
        POLIPHON2.err_m_d_raman_532   = error_Md(:, 2);
        POLIPHON2.err_m_d_raman_1064  = error_Md(:, 3);
        
        POLIPHON2.err_m_cd_raman_355  = error_Mcd(:, 1);
        POLIPHON2.err_m_cd_raman_532  = error_Mcd(:, 2);
        POLIPHON2.err_m_cd_raman_1064 = error_Mcd(:, 3);
        
        POLIPHON2.err_m_fd_raman_355  = error_Mfd(:, 1);
        POLIPHON2.err_m_fd_raman_532  = error_Mfd(:, 2);
        POLIPHON2.err_m_fd_raman_1064 = error_Mfd(:, 3);
        
        POLIPHON2.err_m_ndm_raman_355 = error_Mndm1(:, 1);
        POLIPHON2.err_m_ndm_raman_532 = error_Mndm1(:, 2);
        POLIPHON2.err_m_ndm_raman_1064= error_Mndm1(:, 3);
        
        POLIPHON2.err_m_nds_raman_355 = error_Mnds1(:, 1);
        POLIPHON2.err_m_nds_raman_532 = error_Mnds1(:, 2);
        POLIPHON2.err_m_nds_raman_1064= error_Mnds1(:, 3);
        
        POLIPHON2.err_m_bb_raman_355  = error_Mbb(:, 1);
        POLIPHON2.err_m_bb_raman_532  = error_Mbb(:, 2);
        POLIPHON2.err_m_bb_raman_1064 = error_Mbb(:, 3);
        
        POLIPHON2.err_m_vsf_raman_355 = error_Mvsf(:, 1);
        POLIPHON2.err_m_vsf_raman_532 = error_Mvsf(:, 2);
        POLIPHON2.err_m_vsf_raman_1064= error_Mvsf(:, 3);
        
        POLIPHON2.err_m_vsa_raman_355 = error_Mvsa(:, 1);
        POLIPHON2.err_m_vsa_raman_532 = error_Mvsa(:, 2);
        POLIPHON2.err_m_vsa_raman_1064= error_Mvsa(:, 3);
        
        POLIPHON2.err_m_vst_raman_355 = error_Mvst(:, 1);
        POLIPHON2.err_m_vst_raman_532 = error_Mvst(:, 2);
        POLIPHON2.err_m_vst_raman_1064= error_Mvst(:, 3);
    
        % CCN
        POLIPHON2.n_ccn_raman_355    = CCN(:, 1); 
        POLIPHON2.n_ccn_raman_532    = CCN(:, 2); 
        POLIPHON2.n_ccn_raman_1064   = CCN(:, 3); 
        
        POLIPHON2.n_ccn_d_raman_355   = CCNd(:, 1); 
        POLIPHON2.n_ccn_d_raman_532   = CCNd(:, 2); 
        POLIPHON2.n_ccn_d_raman_1064  = CCNd(:, 3); 
        
        POLIPHON2.n_ccn_c_raman_355   = CCNc(:, 1); 
        POLIPHON2.n_ccn_c_raman_532   = CCNc(:, 2); 
        POLIPHON2.n_ccn_c_raman_1064  = CCNc(:, 3); 
        
        POLIPHON2.n_ccn_m_raman_355   = CCNm(:, 1); 
        POLIPHON2.n_ccn_m_raman_532   = CCNm(:, 2); 
        POLIPHON2.n_ccn_m_raman_1064  = CCNm(:, 3); 
        
        POLIPHON2.n_ccn_bb_raman_355  = CCNbb(:, 1); 
        POLIPHON2.n_ccn_bb_raman_532  = CCNbb(:, 2); 
        POLIPHON2.n_ccn_bb_raman_1064 = CCNbb(:, 3); 
        
        POLIPHON2.n_ccn_vsf_raman_355 = CCNvsf(:, 1);
        POLIPHON2.n_ccn_vsf_raman_532 = CCNvsf(:, 2);
        POLIPHON2.n_ccn_vsf_raman_1064= CCNvsf(:, 3);
        
        POLIPHON2.n_ccn_vst_raman_355 = CCNvst(:, 1); 
        POLIPHON2.n_ccn_vst_raman_532 = CCNvst(:, 2); 
        POLIPHON2.n_ccn_vst_raman_1064= CCNvst(:, 3); 
        
        POLIPHON2.n_ccn_vsa_raman_355 = CCNvsa(:, 1);
        POLIPHON2.n_ccn_vsa_raman_532 = CCNvsa(:, 2);
        POLIPHON2.n_ccn_vsa_raman_1064= CCNvsa(:, 3);
        
        % % INP calculations after:
        % d10 = DeMott 2010
        % d15 = DeMott 2015
        % n12 = Niemand 2012
        % s15 = Steinke 2015
        
        % dust INP raman
        POLIPHON2.n_inp_d_d10_amb_raman_355 = INPd_d10_amb(:, 1); 
        POLIPHON2.n_inp_d_d10_amb_raman_532 = INPd_d10_amb(:, 2); 
        POLIPHON2.n_inp_d_d10_amb_raman_1064= INPd_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_d_d15_amb_raman_355 = INPd_d15_amb(:, 1); 
        POLIPHON2.n_inp_d_d15_amb_raman_532 = INPd_d15_amb(:, 2); 
        POLIPHON2.n_inp_d_d15_amb_raman_1064= INPd_d15_amb(:, 3); 
        
        POLIPHON2.n_inp_d_n12_amb_raman_355 = INPd_n12_amb(:, 1); 
        POLIPHON2.n_inp_d_n12_amb_raman_532 = INPd_n12_amb(:, 2); 
        POLIPHON2.n_inp_d_n12_amb_raman_1064= INPd_n12_amb(:, 3); 
        
        POLIPHON2.n_inp_d_s15_amb_raman_355 = INPd_s15_amb(:, 1); 
        POLIPHON2.n_inp_d_s15_amb_raman_532 = INPd_s15_amb(:, 2); 
        POLIPHON2.n_inp_d_s15_amb_raman_1064= INPd_s15_amb(:, 3); 
        
        POLIPHON2.n_inp_d_d10_raman_355     = INPd_d10(:, 1); 
        POLIPHON2.n_inp_d_d10_raman_532     = INPd_d10(:, 2); 
        POLIPHON2.n_inp_d_d10_raman_1064    = INPd_d10(:, 3); 
        
        POLIPHON2.n_inp_d_d15_raman_355     = INPd_d15(:, 1); 
        POLIPHON2.n_inp_d_d15_raman_532     = INPd_d15(:, 2); 
        POLIPHON2.n_inp_d_d15_raman_1064    = INPd_d15(:, 3); 
        
        POLIPHON2.n_inp_d_n12_raman_355     = INPd_n12(:, 1); 
        POLIPHON2.n_inp_d_n12_raman_532     = INPd_n12(:, 2); 
        POLIPHON2.n_inp_d_n12_raman_1064    = INPd_n12(:, 3); 
        
        POLIPHON2.n_inp_d_s15_raman_355     = INPd_s15(:, 1); 
        POLIPHON2.n_inp_d_s15_raman_532     = INPd_s15(:, 2); 
        POLIPHON2.n_inp_d_s15_raman_1064    = INPd_s15(:, 3); 
        
        POLIPHON2.n_inp_c_d10_amb_raman_355 = INPc_d10_amb(:, 1); 
        POLIPHON2.n_inp_c_d10_amb_raman_532 = INPc_d10_amb(:, 2); 
        POLIPHON2.n_inp_c_d10_amb_raman_1064= INPc_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_c_d10_raman_355     = INPc_d10(:, 1); 
        POLIPHON2.n_inp_c_d10_raman_532     = INPc_d10(:, 2); 
        POLIPHON2.n_inp_c_d10_raman_1064    = INPc_d10(:, 3); 
        
        POLIPHON2.n_inp_m_d10_amb_raman_355 = INPm_d10_amb(:, 1); 
        POLIPHON2.n_inp_m_d10_amb_raman_532 = INPm_d10_amb(:, 2); 
        POLIPHON2.n_inp_m_d10_amb_raman_1064= INPm_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_m_d10_raman_355     = INPm_d10(:, 1); 
        POLIPHON2.n_inp_m_d10_raman_532     = INPm_d10(:, 2); 
        POLIPHON2.n_inp_m_d10_raman_1064    = INPm_d10(:, 3); 
        
        POLIPHON2.n_inp_bb_d10_amb_raman_355 = INPbb_d10_amb(:, 1); 
        POLIPHON2.n_inp_bb_d10_amb_raman_532 = INPbb_d10_amb(:, 2); 
        POLIPHON2.n_inp_bb_d10_amb_raman_1064= INPbb_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_bb_d10_raman_355     = INPbb_d10(:, 1); 
        POLIPHON2.n_inp_bb_d10_raman_532     = INPbb_d10(:, 2); 
        POLIPHON2.n_inp_bb_d10_raman_1064    = INPbb_d10(:, 3); 
        
        POLIPHON2.n_inp_vsf_d10_amb_raman_355 = INPvsf_d10_amb(:, 1); 
        POLIPHON2.n_inp_vsf_d10_amb_raman_532 = INPvsf_d10_amb(:, 2); 
        POLIPHON2.n_inp_vsf_d10_amb_raman_1064= INPvsf_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_vsf_d10_raman_355     = INPvsf_d10(:, 1); 
        POLIPHON2.n_inp_vsf_d10_raman_532     = INPvsf_d10(:, 2); 
        POLIPHON2.n_inp_vsf_d10_raman_1064    = INPvsf_d10(:, 3); 
        
        POLIPHON2.n_inp_vsa_d10_amb_raman_355 = INPvsa_d10_amb(:, 1); 
        POLIPHON2.n_inp_vsa_d10_amb_raman_532 = INPvsa_d10_amb(:, 2); 
        POLIPHON2.n_inp_vsa_d10_amb_raman_1064= INPvsa_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_vsa_d10_raman_355     = INPvsa_d10(:, 1); 
        POLIPHON2.n_inp_vsa_d10_raman_532     = INPvsa_d10(:, 2); 
        POLIPHON2.n_inp_vsa_d10_raman_1064    = INPvsa_d10(:, 3); 
        
        POLIPHON2.n_inp_vst_d10_amb_raman_355 = INPvst_d10_amb(:, 1); 
        POLIPHON2.n_inp_vst_d10_amb_raman_532 = INPvst_d10_amb(:, 2); 
        POLIPHON2.n_inp_vst_d10_amb_raman_1064= INPvst_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_vst_d10_raman_355     = INPvst_d10(:, 1); 
        POLIPHON2.n_inp_vst_d10_raman_532     = INPvst_d10(:, 2); 
        POLIPHON2.n_inp_vst_d10_raman_1064    = INPvst_d10(:, 3);
    
    elseif method == 2 % klett
        % 1-step
        POLIPHON2.aerBsc355_klett_d1 = aerBsc355_klett_d1;
        POLIPHON2.aerBsc355_klett_nd1 = aerBsc355_klett_nd1;
        POLIPHON2.aerBsc532_klett_d1 = aerBsc532_klett_d1;
        POLIPHON2.aerBsc532_klett_nd1 = aerBsc532_klett_nd1;
        POLIPHON2.aerBsc1064_klett_d1 = aerBsc1064_klett_d1;
        POLIPHON2.aerBsc1064_klett_nd1 = aerBsc1064_klett_nd1;
        POLIPHON2.err_aerBsc355_klett_d1 = err_aerBsc355_klett_d1;
        POLIPHON2.err_aerBsc355_klett_nd1 = err_aerBsc355_klett_nd1;
        POLIPHON2.err_aerBsc532_klett_d1 = err_aerBsc532_klett_d1;
        POLIPHON2.err_aerBsc532_klett_nd1 = err_aerBsc532_klett_nd1;
        POLIPHON2.err_aerBsc1064_klett_d1 = err_aerBsc1064_klett_d1;
        POLIPHON2.err_aerBsc1064_klett_nd1 = err_aerBsc1064_klett_nd1;
    
        % 2 step

        POLIPHON2.aerBsc355_klett_d2 = aerBsc355_klett_d2;
        POLIPHON2.aerBsc355_klett_nd2 = aerBsc355_klett_nd2;
        POLIPHON2.aerBsc355_klett_dc2 = aerBsc355_klett_dc2;
        POLIPHON2.aerBsc355_klett_df2 = aerBsc355_klett_df2;
        %POLIPHON2.aerBsc355_klett_nddf2 = aerBsc355_klett_nnddf2;
        
        POLIPHON2.aerBsc532_klett_d2 = aerBsc532_klett_d2;
        POLIPHON2.aerBsc532_klett_nd2 = aerBsc532_klett_nd2;
        POLIPHON2.aerBsc532_klett_dc2 = aerBsc532_klett_dc2;
        POLIPHON2.aerBsc532_klett_df2 = aerBsc532_klett_df2;
        %POLIPHON2.aerBsc532_klett_nddf2 = aerBsc532_klett_nnddf2;
        
        POLIPHON2.aerBsc1064_klett_d2 = aerBsc1064_klett_d2;
        POLIPHON2.aerBsc1064_klett_nd2 = aerBsc1064_klett_nd2;
        POLIPHON2.aerBsc1064_klett_dc2 = aerBsc1064_klett_dc2;
        POLIPHON2.aerBsc1064_klett_df2 = aerBsc1064_klett_df2;
        %POLIPHON2.aerBsc1064_klett_nddf2 = aerBsc1064_klett_nnddf2;
    
        POLIPHON2.err_aerBsc355_klett_d2 = err_aerBsc355_klett_d2;
        POLIPHON2.err_aerBsc355_klett_nd2 = err_aerBsc355_klett_nd2;
        POLIPHON2.err_aerBsc355_klett_dc2 = err_aerBsc355_klett_dc2;
        POLIPHON2.err_aerBsc355_klett_df2 = err_aerBsc355_klett_df2;
    
        POLIPHON2.err_aerBsc532_klett_d2 = err_aerBsc532_klett_d2;
        POLIPHON2.err_aerBsc532_klett_nd2 = err_aerBsc532_klett_nd2;
        POLIPHON2.err_aerBsc532_klett_dc2 = err_aerBsc532_klett_dc2;
        POLIPHON2.err_aerBsc532_klett_df2 = err_aerBsc532_klett_df2;
    
        POLIPHON2.err_aerBsc1064_klett_d2 = err_aerBsc1064_klett_d2;
        POLIPHON2.err_aerBsc1064_klett_nd2 = err_aerBsc1064_klett_nd2;
        POLIPHON2.err_aerBsc1064_klett_dc2 = err_aerBsc1064_klett_dc2;
        POLIPHON2.err_aerBsc1064_klett_df2 = err_aerBsc1064_klett_df2;
    
        % err
        POLIPHON2.err_aerBsc355_klett_d2 = err_aerBsc355_klett_d2;
        POLIPHON2.err_aerBsc355_klett_nd2 = err_aerBsc355_klett_nd2;
        POLIPHON2.err_aerBsc355_klett_dc2 = err_aerBsc355_klett_dc2;
        POLIPHON2.err_aerBsc355_klett_df2 = err_aerBsc355_klett_df2;

        POLIPHON2.err_aerBsc532_klett_d2 = err_aerBsc532_klett_d2;
        POLIPHON2.err_aerBsc532_klett_nd2 = err_aerBsc532_klett_nd2;
        POLIPHON2.err_aerBsc532_klett_dc2 = err_aerBsc532_klett_dc2;
        POLIPHON2.err_aerBsc532_klett_df2 = err_aerBsc532_klett_df2;

        POLIPHON2.err_aerBsc1064_klett_d2 = err_aerBsc1064_klett_d2;
        POLIPHON2.err_aerBsc1064_klett_nd2 = err_aerBsc1064_klett_nd2;
        POLIPHON2.err_aerBsc1064_klett_dc2 = err_aerBsc1064_klett_dc2;
        POLIPHON2.err_aerBsc1064_klett_df2 = err_aerBsc1064_klett_df2;
    
        % extinction coeffs
        POLIPHON2.ext_d_klett_355    = Ad(:, 1);        % Dust 355
        POLIPHON2.ext_d_klett_532    = Ad(:, 2);        % Dust 532
        POLIPHON2.ext_d_klett_1064   = Ad(:, 3);        % Dust 1064
        
        POLIPHON2.ext_cd_klett_355   = Acd(:, 1);       % Coarse Dust 355
        POLIPHON2.ext_cd_klett_532   = Acd(:, 2);       % Coarse Dust 532
        POLIPHON2.ext_cd_klett_1064  = Acd(:, 3);       % Coarse Dust 1064
        
        POLIPHON2.ext_fd_klett_355   = Afd(:, 1);       % Fine Dust 355
        POLIPHON2.ext_fd_klett_532   = Afd(:, 2);       % Fine Dust 532
        POLIPHON2.ext_fd_klett_1064  = Afd(:, 3);       % Fine Dust 1064
        
        POLIPHON2.ext_ndm_klett_355  = Andm1(:, 1);     % Non-Dust Marine 355
        POLIPHON2.ext_ndm_klett_532  = Andm1(:, 2);     % Non-Dust Marine 532
        POLIPHON2.ext_ndm_klett_1064 = Andm1(:, 3);     % Non-Dust Marine 1064
        
        POLIPHON2.ext_nds_klett_355  = Ands1(:, 1);     % Non-Dust Smoke 355
        POLIPHON2.ext_nds_klett_532  = Ands1(:, 2);     % Non-Dust Smoke 532
        POLIPHON2.ext_nds_klett_1064 = Ands1(:, 3);     % Non-Dust Smoke 1064
        
        POLIPHON2.ext_bb_klett_355   = Abb(:, 1);       % Biomass Burning 355
        POLIPHON2.ext_bb_klett_532   = Abb(:, 2);       % Biomass Burning 532
        POLIPHON2.ext_bb_klett_1064  = Abb(:, 3);       % Biomass Burning 1064
        
        POLIPHON2.ext_vsf_klett_355  = Avsf(:, 1);      % Volcanic Sulfate Fresh 355
        POLIPHON2.ext_vsf_klett_532  = Avsf(:, 2);      % Volcanic Sulfate Fresh 532
        POLIPHON2.ext_vsf_klett_1064 = Avsf(:, 3);      % Volcanic Sulfate Fresh 1064
        
        POLIPHON2.ext_vsa_klett_355  = Avsa(:, 1);      % Volcanic Sulfate Aged 355
        POLIPHON2.ext_vsa_klett_532  = Avsa(:, 2);      % Volcanic Sulfate Aged 532
        POLIPHON2.ext_vsa_klett_1064 = Avsa(:, 3);      % Volcanic Sulfate Aged 1064
        
        POLIPHON2.ext_vst_klett_355  = Avst(:, 1);      % Volcanic Sulfate Tropospheric 355
        POLIPHON2.ext_vst_klett_532  = Avst(:, 2);      % Volcanic Sulfate Tropospheric 532
        POLIPHON2.ext_vst_klett_1064 = Avst(:, 3);      % Volcanic Sulfate Tropospheric 1064
        
        % mass concentrations
        POLIPHON2.m_d_klett_355   = Md(:, 1);
        POLIPHON2.m_d_klett_532   = Md(:, 2);
        POLIPHON2.m_d_klett_1064  = Md(:, 3);
        
        POLIPHON2.m_cd_klett_355  = Mcd(:, 1);
        POLIPHON2.m_cd_klett_532  = Mcd(:, 2);
        POLIPHON2.m_cd_klett_1064 = Mcd(:, 3);
        
        POLIPHON2.m_fd_klett_355  = Mfd(:, 1);
        POLIPHON2.m_fd_klett_532  = Mfd(:, 2);
        POLIPHON2.m_fd_klett_1064 = Mfd(:, 3);
        
        POLIPHON2.m_ndm_klett_355 = Mndm1(:, 1);
        POLIPHON2.m_ndm_klett_532 = Mndm1(:, 2);
        POLIPHON2.m_ndm_klett_1064= Mndm1(:, 3);
        
        POLIPHON2.m_nds_klett_355 = Mnds1(:, 1);
        POLIPHON2.m_nds_klett_532 = Mnds1(:, 2);
        POLIPHON2.m_nds_klett_1064= Mnds1(:, 3);
        
        POLIPHON2.m_bb_klett_355  = Mbb(:, 1);
        POLIPHON2.m_bb_klett_532  = Mbb(:, 2);
        POLIPHON2.m_bb_klett_1064 = Mbb(:, 3);
        
        POLIPHON2.m_vsf_klett_355 = Mvsf(:, 1);
        POLIPHON2.m_vsf_klett_532 = Mvsf(:, 2);
        POLIPHON2.m_vsf_klett_1064= Mvsf(:, 3);
        
        POLIPHON2.m_vsa_klett_355 = Mvsa(:, 1);
        POLIPHON2.m_vsa_klett_532 = Mvsa(:, 2);
        POLIPHON2.m_vsa_klett_1064= Mvsa(:, 3);
        
        POLIPHON2.m_vst_klett_355 = Mvst(:, 1);
        POLIPHON2.m_vst_klett_532 = Mvst(:, 2);
        POLIPHON2.m_vst_klett_1064= Mvst(:, 3);
        
        % number concentrations
        POLIPHON2.n_100_d_klett_355   = n_100_d(:, 1);
        POLIPHON2.n_100_d_klett_532   = n_100_d(:, 2);
        POLIPHON2.n_100_d_klett_1064  = n_100_d(:, 3);
        
        POLIPHON2.n_250_d_klett_355   = n_250_d(:, 1);
        POLIPHON2.n_250_d_klett_532   = n_250_d(:, 2);
        POLIPHON2.n_250_d_klett_1064  = n_250_d(:, 3);
        
        POLIPHON2.n_50_c_klett_355    = n_50_c(:, 1);
        POLIPHON2.n_50_c_klett_532    = n_50_c(:, 2);
        POLIPHON2.n_50_c_klett_1064   = n_50_c(:, 3);
        
        POLIPHON2.n_250_c_klett_355   = n_250_c(:, 1);
        POLIPHON2.n_250_c_klett_532   = n_250_c(:, 2);
        POLIPHON2.n_250_c_klett_1064  = n_250_c(:, 3);
        
        POLIPHON2.n_50_m_klett_355    = n_50_m(:, 1);
        POLIPHON2.n_50_m_klett_532    = n_50_m(:, 2);
        POLIPHON2.n_50_m_klett_1064   = n_50_m(:, 3);
        
        POLIPHON2.n_250_m_klett_355   = n_250_m(:, 1);
        POLIPHON2.n_250_m_klett_532   = n_250_m(:, 2);
        POLIPHON2.n_250_m_klett_1064  = n_250_m(:, 3);
        
        POLIPHON2.n_50_bb_klett_355   = n_50_bb(:, 1);
        POLIPHON2.n_50_bb_klett_532   = n_50_bb(:, 2);
        POLIPHON2.n_50_bb_klett_1064  = n_50_bb(:, 3);
        
        POLIPHON2.n_250_bb_klett_355  = n_250_bb(:, 1);
        POLIPHON2.n_250_bb_klett_532  = n_250_bb(:, 2);
        POLIPHON2.n_250_bb_klett_1064 = n_250_bb(:, 3);
        
        POLIPHON2.n_50_vsf_klett_355  = n_50_vsf(:, 1);
        POLIPHON2.n_50_vsf_klett_532  = n_50_vsf(:, 2);
        POLIPHON2.n_50_vsf_klett_1064 = n_50_vsf(:, 3);
        
        POLIPHON2.n_250_vsf_klett_355 = n_250_vsf(:, 1);
        POLIPHON2.n_250_vsf_klett_532 = n_250_vsf(:, 2);
        POLIPHON2.n_250_vsf_klett_1064= n_250_vsf(:, 3);
        
        POLIPHON2.n_50_vsa_klett_355  = n_50_vsa(:, 1);
        POLIPHON2.n_50_vsa_klett_532  = n_50_vsa(:, 2);
        POLIPHON2.n_50_vsa_klett_1064 = n_50_vsa(:, 3);
        
        POLIPHON2.n_250_vsa_klett_355 = n_250_vsa(:, 1);
        POLIPHON2.n_250_vsa_klett_532 = n_250_vsa(:, 2);
        POLIPHON2.n_250_vsa_klett_1064= n_250_vsa(:, 3);
        
        POLIPHON2.n_50_vst_klett_355  = n_50_vst(:, 1);
        POLIPHON2.n_50_vst_klett_532  = n_50_vst(:, 2);
        POLIPHON2.n_50_vst_klett_1064 = n_50_vst(:, 3);
        
        POLIPHON2.n_250_vst_klett_355 = n_250_vst(:, 1);
        POLIPHON2.n_250_vst_klett_532 = n_250_vst(:, 2);
        POLIPHON2.n_250_vst_klett_1064= n_250_vst(:, 3);
        
        % surface area concentrations
        POLIPHON2.sa_d_klett_355   = Sd(:, 1);
        POLIPHON2.sa_d_klett_532   = Sd(:, 2);
        POLIPHON2.sa_d_klett_1064  = Sd(:, 3);
        
        POLIPHON2.sa_c_klett_355   = Sc(:, 1);
        POLIPHON2.sa_c_klett_532   = Sc(:, 2);
        POLIPHON2.sa_c_klett_1064  = Sc(:, 3);
        
        POLIPHON2.sa_m_klett_355   = Sm(:, 1);
        POLIPHON2.sa_m_klett_532   = Sm(:, 2);
        POLIPHON2.sa_m_klett_1064  = Sm(:, 3);
        
        POLIPHON2.sa_bb_klett_355  = Sbb(:, 1);
        POLIPHON2.sa_bb_klett_532  = Sbb(:, 2);
        POLIPHON2.sa_bb_klett_1064 = Sbb(:, 3);
        
        POLIPHON2.sa_vsf_klett_355 = Svsf(:, 1);
        POLIPHON2.sa_vsf_klett_532 = Svsf(:, 2);
        POLIPHON2.sa_vsf_klett_1064= Svsf(:, 3);
        
        POLIPHON2.sa_vsa_klett_355 = Svsa(:, 1);
        POLIPHON2.sa_vsa_klett_532 = Svsa(:, 2);
        POLIPHON2.sa_vsa_klett_1064= Svsa(:, 3);
        
        POLIPHON2.sa_vst_klett_355 = Svst(:, 1);
        POLIPHON2.sa_vst_klett_532 = Svst(:, 2);
        POLIPHON2.sa_vst_klett_1064= Svst(:, 3);
        
        % err
        % extinction err
        POLIPHON2.err_ext_d_klett_355   = error_Ad(:, 1);
        POLIPHON2.err_ext_d_klett_532   = error_Ad(:, 2);
        POLIPHON2.err_ext_d_klett_1064  = error_Ad(:, 3);
        
        POLIPHON2.err_ext_cd_klett_355  = error_Acd(:, 1);
        POLIPHON2.err_ext_cd_klett_532  = error_Acd(:, 2);
        POLIPHON2.err_ext_cd_klett_1064 = error_Acd(:, 3);
        
        POLIPHON2.err_ext_fd_klett_355  = error_Afd(:, 1);
        POLIPHON2.err_ext_fd_klett_532  = error_Afd(:, 2);
        POLIPHON2.err_ext_fd_klett_1064 = error_Afd(:, 3);
        
        POLIPHON2.err_ext_ndm_klett_355 = error_Andm1(:, 1);
        POLIPHON2.err_ext_ndm_klett_532 = error_Andm1(:, 2);
        POLIPHON2.err_ext_ndm_klett_1064= error_Andm1(:, 3);
        
        POLIPHON2.err_ext_nds_klett_355 = error_Ands1(:, 1);
        POLIPHON2.err_ext_nds_klett_532 = error_Ands1(:, 2);
        POLIPHON2.err_ext_nds_klett_1064= error_Ands1(:, 3);
        
        POLIPHON2.err_ext_bb_klett_355  = error_Abb(:, 1);
        POLIPHON2.err_ext_bb_klett_532  = error_Abb(:, 2);
        POLIPHON2.err_ext_bb_klett_1064 = error_Abb(:, 3);
        
        POLIPHON2.err_ext_vsf_klett_355 = error_Avsf(:, 1);
        POLIPHON2.err_ext_vsf_klett_532 = error_Avsf(:, 2);
        POLIPHON2.err_ext_vsf_klett_1064= error_Avsf(:, 3);
        
        POLIPHON2.err_ext_vsa_klett_355 = error_Avsa(:, 1);
        POLIPHON2.err_ext_vsa_klett_532 = error_Avsa(:, 2);
        POLIPHON2.err_ext_vsa_klett_1064= error_Avsa(:, 3);
        
        POLIPHON2.err_ext_vst_klett_355 = error_Avst(:, 1);
        POLIPHON2.err_ext_vst_klett_532 = error_Avst(:, 2);
        POLIPHON2.err_ext_vst_klett_1064= error_Avst(:, 3);
        
        % mass err
        POLIPHON2.err_m_d_klett_355   = error_Md(:, 1);
        POLIPHON2.err_m_d_klett_532   = error_Md(:, 2);
        POLIPHON2.err_m_d_klett_1064  = error_Md(:, 3);
        
        POLIPHON2.err_m_cd_klett_355  = error_Mcd(:, 1);
        POLIPHON2.err_m_cd_klett_532  = error_Mcd(:, 2);
        POLIPHON2.err_m_cd_klett_1064 = error_Mcd(:, 3);
        
        POLIPHON2.err_m_fd_klett_355  = error_Mfd(:, 1);
        POLIPHON2.err_m_fd_klett_532  = error_Mfd(:, 2);
        POLIPHON2.err_m_fd_klett_1064 = error_Mfd(:, 3);
        
        POLIPHON2.err_m_ndm_klett_355 = error_Mndm1(:, 1);
        POLIPHON2.err_m_ndm_klett_532 = error_Mndm1(:, 2);
        POLIPHON2.err_m_ndm_klett_1064= error_Mndm1(:, 3);
        
        POLIPHON2.err_m_nds_klett_355 = error_Mnds1(:, 1);
        POLIPHON2.err_m_nds_klett_532 = error_Mnds1(:, 2);
        POLIPHON2.err_m_nds_klett_1064= error_Mnds1(:, 3);
        
        POLIPHON2.err_m_bb_klett_355  = error_Mbb(:, 1);
        POLIPHON2.err_m_bb_klett_532  = error_Mbb(:, 2);
        POLIPHON2.err_m_bb_klett_1064 = error_Mbb(:, 3);
        
        POLIPHON2.err_m_vsf_klett_355 = error_Mvsf(:, 1);
        POLIPHON2.err_m_vsf_klett_532 = error_Mvsf(:, 2);
        POLIPHON2.err_m_vsf_klett_1064= error_Mvsf(:, 3);
        
        POLIPHON2.err_m_vsa_klett_355 = error_Mvsa(:, 1);
        POLIPHON2.err_m_vsa_klett_532 = error_Mvsa(:, 2);
        POLIPHON2.err_m_vsa_klett_1064= error_Mvsa(:, 3);
        
        POLIPHON2.err_m_vst_klett_355 = error_Mvst(:, 1);
        POLIPHON2.err_m_vst_klett_532 = error_Mvst(:, 2);
        POLIPHON2.err_m_vst_klett_1064= error_Mvst(:, 3);
    
        % CCN
        POLIPHON2.n_ccn_klett_355    = CCN(:, 1); 
        POLIPHON2.n_ccn_klett_532    = CCN(:, 2); 
        POLIPHON2.n_ccn_klett_1064   = CCN(:, 3); 
        
        POLIPHON2.n_ccn_d_klett_355   = CCNd(:, 1); 
        POLIPHON2.n_ccn_d_klett_532   = CCNd(:, 2); 
        POLIPHON2.n_ccn_d_klett_1064  = CCNd(:, 3); 
        
        POLIPHON2.n_ccn_c_klett_355   = CCNc(:, 1); 
        POLIPHON2.n_ccn_c_klett_532   = CCNc(:, 2); 
        POLIPHON2.n_ccn_c_klett_1064  = CCNc(:, 3); 
        
        POLIPHON2.n_ccn_m_klett_355   = CCNm(:, 1); 
        POLIPHON2.n_ccn_m_klett_532   = CCNm(:, 2); 
        POLIPHON2.n_ccn_m_klett_1064  = CCNm(:, 3); 
        
        POLIPHON2.n_ccn_bb_klett_355  = CCNbb(:, 1); 
        POLIPHON2.n_ccn_bb_klett_532  = CCNbb(:, 2); 
        POLIPHON2.n_ccn_bb_klett_1064 = CCNbb(:, 3); 
        
        POLIPHON2.n_ccn_vsf_klett_355 = CCNvsf(:, 1);
        POLIPHON2.n_ccn_vsf_klett_532 = CCNvsf(:, 2);
        POLIPHON2.n_ccn_vsf_klett_1064= CCNvsf(:, 3);
        
        POLIPHON2.n_ccn_vst_klett_355 = CCNvst(:, 1); 
        POLIPHON2.n_ccn_vst_klett_532 = CCNvst(:, 2); 
        POLIPHON2.n_ccn_vst_klett_1064= CCNvst(:, 3); 
        
        POLIPHON2.n_ccn_vsa_klett_355 = CCNvsa(:, 1);
        POLIPHON2.n_ccn_vsa_klett_532 = CCNvsa(:, 2);
        POLIPHON2.n_ccn_vsa_klett_1064= CCNvsa(:, 3);
        
        % % INP calculations after:
        % d10 = DeMott 2010
        % d15 = DeMott 2015
        % n12 = Niemand 2012
        % s15 = Steinke 2015
        
        % dust INP klett
        POLIPHON2.n_inp_d_d10_amb_klett_355 = INPd_d10_amb(:, 1); 
        POLIPHON2.n_inp_d_d10_amb_klett_532 = INPd_d10_amb(:, 2); 
        POLIPHON2.n_inp_d_d10_amb_klett_1064= INPd_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_d_d15_amb_klett_355 = INPd_d15_amb(:, 1); 
        POLIPHON2.n_inp_d_d15_amb_klett_532 = INPd_d15_amb(:, 2); 
        POLIPHON2.n_inp_d_d15_amb_klett_1064= INPd_d15_amb(:, 3); 
        
        POLIPHON2.n_inp_d_n12_amb_klett_355 = INPd_n12_amb(:, 1); 
        POLIPHON2.n_inp_d_n12_amb_klett_532 = INPd_n12_amb(:, 2); 
        POLIPHON2.n_inp_d_n12_amb_klett_1064= INPd_n12_amb(:, 3); 
        
        POLIPHON2.n_inp_d_s15_amb_klett_355 = INPd_s15_amb(:, 1); 
        POLIPHON2.n_inp_d_s15_amb_klett_532 = INPd_s15_amb(:, 2); 
        POLIPHON2.n_inp_d_s15_amb_klett_1064= INPd_s15_amb(:, 3); 
        
        POLIPHON2.n_inp_d_d10_klett_355     = INPd_d10(:, 1); 
        POLIPHON2.n_inp_d_d10_klett_532     = INPd_d10(:, 2); 
        POLIPHON2.n_inp_d_d10_klett_1064    = INPd_d10(:, 3); 
        
        POLIPHON2.n_inp_d_d15_klett_355     = INPd_d15(:, 1); 
        POLIPHON2.n_inp_d_d15_klett_532     = INPd_d15(:, 2); 
        POLIPHON2.n_inp_d_d15_klett_1064    = INPd_d15(:, 3); 
        
        POLIPHON2.n_inp_d_n12_klett_355     = INPd_n12(:, 1); 
        POLIPHON2.n_inp_d_n12_klett_532     = INPd_n12(:, 2); 
        POLIPHON2.n_inp_d_n12_klett_1064    = INPd_n12(:, 3); 
        
        POLIPHON2.n_inp_d_s15_klett_355     = INPd_s15(:, 1); 
        POLIPHON2.n_inp_d_s15_klett_532     = INPd_s15(:, 2); 
        POLIPHON2.n_inp_d_s15_klett_1064    = INPd_s15(:, 3); 
        
        POLIPHON2.n_inp_c_d10_amb_klett_355 = INPc_d10_amb(:, 1); 
        POLIPHON2.n_inp_c_d10_amb_klett_532 = INPc_d10_amb(:, 2); 
        POLIPHON2.n_inp_c_d10_amb_klett_1064= INPc_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_c_d10_klett_355     = INPc_d10(:, 1); 
        POLIPHON2.n_inp_c_d10_klett_532     = INPc_d10(:, 2); 
        POLIPHON2.n_inp_c_d10_klett_1064    = INPc_d10(:, 3); 
        
        POLIPHON2.n_inp_m_d10_amb_klett_355 = INPm_d10_amb(:, 1); 
        POLIPHON2.n_inp_m_d10_amb_klett_532 = INPm_d10_amb(:, 2); 
        POLIPHON2.n_inp_m_d10_amb_klett_1064= INPm_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_m_d10_klett_355     = INPm_d10(:, 1); 
        POLIPHON2.n_inp_m_d10_klett_532     = INPm_d10(:, 2); 
        POLIPHON2.n_inp_m_d10_klett_1064    = INPm_d10(:, 3); 
        
        POLIPHON2.n_inp_bb_d10_amb_klett_355 = INPbb_d10_amb(:, 1); 
        POLIPHON2.n_inp_bb_d10_amb_klett_532 = INPbb_d10_amb(:, 2); 
        POLIPHON2.n_inp_bb_d10_amb_klett_1064= INPbb_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_bb_d10_klett_355     = INPbb_d10(:, 1); 
        POLIPHON2.n_inp_bb_d10_klett_532     = INPbb_d10(:, 2); 
        POLIPHON2.n_inp_bb_d10_klett_1064    = INPbb_d10(:, 3); 
        
        POLIPHON2.n_inp_vsf_d10_amb_klett_355 = INPvsf_d10_amb(:, 1); 
        POLIPHON2.n_inp_vsf_d10_amb_klett_532 = INPvsf_d10_amb(:, 2); 
        POLIPHON2.n_inp_vsf_d10_amb_klett_1064= INPvsf_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_vsf_d10_klett_355     = INPvsf_d10(:, 1); 
        POLIPHON2.n_inp_vsf_d10_klett_532     = INPvsf_d10(:, 2); 
        POLIPHON2.n_inp_vsf_d10_klett_1064    = INPvsf_d10(:, 3); 
        
        POLIPHON2.n_inp_vsa_d10_amb_klett_355 = INPvsa_d10_amb(:, 1); 
        POLIPHON2.n_inp_vsa_d10_amb_klett_532 = INPvsa_d10_amb(:, 2); 
        POLIPHON2.n_inp_vsa_d10_amb_klett_1064= INPvsa_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_vsa_d10_klett_355     = INPvsa_d10(:, 1); 
        POLIPHON2.n_inp_vsa_d10_klett_532     = INPvsa_d10(:, 2); 
        POLIPHON2.n_inp_vsa_d10_klett_1064    = INPvsa_d10(:, 3); 
        
        POLIPHON2.n_inp_vst_d10_amb_klett_355 = INPvst_d10_amb(:, 1); 
        POLIPHON2.n_inp_vst_d10_amb_klett_532 = INPvst_d10_amb(:, 2); 
        POLIPHON2.n_inp_vst_d10_amb_klett_1064= INPvst_d10_amb(:, 3); 
        
        POLIPHON2.n_inp_vst_d10_klett_355     = INPvst_d10(:, 1); 
        POLIPHON2.n_inp_vst_d10_klett_532     = INPvst_d10(:, 2); 
        POLIPHON2.n_inp_vst_d10_klett_1064    = INPvst_d10(:, 3);
    end
end
% TODO:

% some plots for verification
% group variables
   % INP
   % CCN
   % for each aerosol type (ext, mass, sa, .. for raman and klett)
   % 2-step output

