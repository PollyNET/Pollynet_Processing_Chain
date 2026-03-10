function [POLIPHON2] = poliphon_two(aerBsc355_klett, pdr355_klett, ...
          aerBsc532_klett, pdr532_klett, aerBsc1064_klett, pdr1064_klett,...
          aerBsc355_raman, pdr355_raman, aerBsc532_raman, pdr532_raman,...
          aerBsc1064_raman, pdr1064_raman) %aerBsc532_raman_d1
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


% preallocate the variables 
sz        = size(aerBsc532_raman);
Pndfd     = NaN(sz);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
step = size(aerBsc355_klett,2);
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



