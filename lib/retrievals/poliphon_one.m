function [POLIPHON1] = poliphon_one(aerBsc355_klett, pdr355_klett, ...
          aerBsc532_klett, pdr532_klett, aerBsc1064_klett, pdr1064_klett,...
          aerBsc355_raman, pdr355_raman, aerBsc532_raman, pdr532_raman,...
          aerBsc1064_raman, pdr1064_raman)
% POLIPHON_ONE applies the one-step POLIPHON methodology as described in 
% Mamouri and Ansmann, 2014
%
% INPUTS:
% Dd: particle linear depolarization ratio for dust at 355, 532, 1064 nm
% Dnd: particle linear depolarization ratio for non-dust at 355, 532, 1064 nm
% Backscatter coefficient (355, 532, 1064 nm - Raman/Klett)
% Particle linear depolarization ratio (355, 532, 1064 nm - Raman/Klett)
% 
% OUTPUTS:
% Dust backscatter coefficient (355, 532, 1064 nm - Raman/Klett)
% Non-dust backscatter coefficient (355, 532, 1064 nm - Raman/Klett)
% Error estimates (as in Moritz's code)
% 
% HISTORY:
%    - 2023-06-14: first edition by Athena A. Floutsi 
%
% .. Authors: - floutsi@tropos.de

Dd = [0.23, 0.31, 0.25];
Dnd = [0.05, 0.05, 0.05];

for k = 1:size(aerBsc355_klett,1)        
    for i = 1:size(aerBsc355_klett,2)
        if isnan(aerBsc355_klett(k,i)) || isnan(pdr355_klett(k,i)) || (isnan(aerBsc355_klett(k,i)) && isnan(pdr355_klett(k,i)))
           aerBsc355_klett_d1(k,i) = NaN;
           aerBsc355_klett_nd1(k,i) = NaN;
           err_aerBsc355_klett_d1(k,i) = NaN;
           err_aerBsc355_klett_nd1(k,i) = NaN;
        else
            if pdr355_klett(k,i) < Dnd(1)
                aerBsc355_klett_d1(k,i) = 0;
                aerBsc355_klett_nd1(k,i) = aerBsc355_klett(k,i);
                err_aerBsc355_klett_d1(k,i) = 0.15*aerBsc355_klett_d1(k,i);
                err_aerBsc355_klett_nd1(k,i) = 0.15*aerBsc355_klett_nd1(k,i);
            elseif pdr355_klett(k,i) > Dd(1)
                aerBsc355_klett_d1(k,i) = aerBsc355_klett(k,i);
                aerBsc355_klett_nd1(k,i) = 0;
                err_aerBsc355_klett_d1(k,i) = 0.15*aerBsc355_klett_d1(k,i);
                err_aerBsc355_klett_nd1(k,i) = 0.15*aerBsc355_klett_nd1(k,i);
            else
                aerBsc355_klett_d1(k,i) = aerBsc355_klett(k,i)*(((pdr355_klett(k,i)-Dnd(1))*(1+Dd(1)))/((Dd(1)-Dnd(1))*(1+pdr355_klett(k,i))));
                aerBsc355_klett_nd1(k,i) = aerBsc355_klett(k,i) - aerBsc355_klett_d1(k,i);
                err_aerBsc355_klett_d1(k,i) = 0.15*aerBsc355_klett_d1(k,i);
                err_aerBsc355_klett_nd1(k,i) = 0.15*aerBsc355_klett_nd1(k,i);
            end
        end
    end
end

for k = 1:size(aerBsc532_klett,1)
    for i = 1:size(aerBsc532_klett,2)
        if isnan(aerBsc532_klett(k,i)) || isnan(pdr532_klett(k,i)) || (isnan(aerBsc532_klett(k,i)) && isnan(pdr532_klett(k,i)))
            aerBsc355_klett_d1(k,i) = NaN;
            aerBsc355_klett_nd1(k,i) = NaN;
            err_aerBsc355_klett_d1(k,i) = NaN;
            err_aerBsc355_klett_nd1(k,i) = NaN;
        else
            if pdr532_klett(k,i) < Dnd(2)
                aerBsc532_klett_d1(k,i) = 0;
                aerBsc532_klett_nd1(k,i) = aerBsc532_klett(k,i);
                err_aerBsc532_klett_d1(k,i) = 0.15*aerBsc532_klett_d1(k,i);
                err_aerBsc532_klett_nd1(k,i) = 0.15*aerBsc532_klett_nd1(k,i);
            elseif pdr532_klett(k,i) > Dd(2)
                aerBsc532_klett_d1(k,i) = aerBsc532_klett(k,i);
                aerBsc532_klett_nd1(k,i) = 0;
                err_aerBsc532_klett_d1(k,i) = 0.15*aerBsc532_klett_d1(k,i);
                err_aerBsc532_klett_nd1(k,i) = 0.15*aerBsc532_klett_nd1(k,i);
            else
                aerBsc532_klett_d1(k,i) = aerBsc532_klett(k,i)*(((pdr532_klett(k,i)-Dnd(2))*(1+Dd(2)))/((Dd(2)-Dnd(2))*(1+pdr532_klett(k,i))));
                aerBsc532_klett_nd1(k,i) = aerBsc532_klett(k,i) - aerBsc532_klett_d1(k,i);
                err_aerBsc532_klett_d1(k,i) = 0.15*aerBsc532_klett_d1(k,i);
                err_aerBsc532_klett_nd1(k,i) = 0.15*aerBsc532_klett_nd1(k,i);
            end
        end
    end
end

for k = 1:size(aerBsc1064_klett,1) 
    for i = 1:size(aerBsc1064_klett,2) 
        if isnan(aerBsc1064_klett(k,i)) || isnan(pdr1064_klett(k,i)) || (isnan(aerBsc1064_klett(k,i)) && isnan(pdr1064_klett(k,i)))
            aerBsc1064_klett_d1(k,i) = NaN;
            aerBsc1064_klett_nd1(k,i) = NaN;
            err_aerBsc1064_klett_d1(k,i) = NaN;
            err_aerBsc1064_klett_nd1(k,i) = NaN;
        else
            if pdr1064_klett(k,i) < Dnd(3)
                aerBsc1064_klett_d1(k,i) = 0;
                aerBsc1064_klett_nd1(k,i) = aerBsc1064_klett(k,i);
                err_aerBsc1064_klett_d1(k,i) = 0.15*aerBsc1064_klett_d1(k,i);
                err_aerBsc1064_klett_nd1(k,i) = 0.15*aerBsc1064_klett_nd1(k,i);
            elseif pdr1064_klett(k,i) > Dd(3)
                aerBsc1064_klett_d1(k,i) = aerBsc1064_klett(k,i);
                aerBsc1064_klett_nd1(k,i) = 0;
                err_aerBsc1064_klett_d1(k,i) = 0.15*aerBsc1064_klett_d1(k,i);
                err_aerBsc1064_klett_nd1(k,i) = 0.15*aerBsc1064_klett_nd1(k,i);
            else
                aerBsc1064_klett_d1(k,i) = aerBsc1064_klett(k,i)*(((pdr1064_klett(k,i)-Dnd(3))*(1+Dd(3)))/((Dd(3)-Dnd(3))*(1+pdr1064_klett(k,i))));
                aerBsc1064_klett_nd1(k,i) = aerBsc1064_klett(k,i) - aerBsc1064_klett_d1(k,i);
                err_aerBsc1064_klett_d1(k,i) = 0.15*aerBsc1064_klett_d1(k,i);
                err_aerBsc1064_klett_nd1(k,i) = 0.15*aerBsc1064_klett_nd1(k,i);
            end
        end
    end
end

for k = 1:size(aerBsc355_raman,1) 
    for i = 1:size(aerBsc355_raman,2) 
        if isnan(aerBsc355_raman(k,i)) || isnan(pdr355_raman(k,i)) || (isnan(aerBsc355_raman(k,i)) && isnan(pdr355_raman(k,i)))
            aerBsc355_raman_d1(k,i) = NaN;
            aerBsc355_raman_nd1(k,i) = NaN;
            err_aerBsc355_raman_d1(k,i) = NaN;
            err_aerBsc355_raman_nd1(k,i) = NaN;
        else
            if pdr355_raman(k,i) < Dnd(1)
                aerBsc355_raman_d1(k,i) = 0;
                aerBsc355_raman_nd1(k,i) = aerBsc355_raman(k,i);
                err_aerBsc355_raman_d1(k,i) = 0.15*aerBsc355_raman_d1(k,i);
                err_aerBsc355_raman_nd1(k,i) = 0.15*aerBsc355_raman_nd1(k,i);
            elseif pdr355_raman(k,i) > Dd(1)
                aerBsc355_raman_d1(k,i) = aerBsc355_raman(k,i);
                aerBsc355_raman_nd1(k,i) = 0;
                err_aerBsc355_raman_d1(k,i) = 0.15*aerBsc355_raman_d1(k,i);
                err_aerBsc355_raman_nd1(k,i) = 0.15*aerBsc355_raman_nd1(k,i);
            else
                aerBsc355_raman_d1(k,i) = aerBsc355_raman(k,i)*(((pdr355_raman(k,i)-Dnd(1))*(1+Dd(1)))/((Dd(1)-Dnd(1))*(1+pdr355_raman(k,i))));
                aerBsc355_raman_nd1(k,i) = aerBsc355_raman(k,i) - aerBsc355_raman_d1(k,i);
                err_aerBsc355_raman_d1(k,i) = 0.15*aerBsc355_raman_d1(k,i);
                err_aerBsc355_raman_nd1(k,i) = 0.15*aerBsc355_raman_nd1(k,i);
            end
        end
    end
end

for k = 1:size(aerBsc532_raman,1)
    for i = 1:size(aerBsc532_raman,2)
        if isnan(aerBsc532_raman(k,i)) || isnan(pdr532_raman(k,i)) || (isnan(aerBsc532_raman(k,i)) && isnan(pdr532_raman(k,i)))
            aerBsc532_raman_d1(k,i) = NaN;
            aerBsc532_raman_nd1(k,i) = NaN;
            err_aerBsc532_raman_d1(k,i) = NaN;
            err_aerBsc532_raman_nd1(k,i) = NaN;
        else
            if pdr532_raman(k,i) < Dnd(2)
                aerBsc532_raman_d1(k,i) = 0;
                aerBsc532_raman_nd1(k,i) = aerBsc532_raman(k,i);
                err_aerBsc532_raman_d1(k,i) = 0.15*aerBsc532_raman_d1(k,i);
                err_aerBsc532_raman_nd1(k,i) = 0.15*aerBsc532_raman_nd1(k,i);
            elseif pdr532_raman(k,i) > Dd(2)
                aerBsc532_raman_d1(k,i) = aerBsc532_raman(k,i);
                aerBsc532_raman_nd1(k,i) = 0;
                err_aerBsc532_raman_d1(k,i) = 0.15*aerBsc532_raman_d1(k,i);
                err_aerBsc532_raman_nd1(k,i) = 0.15*aerBsc532_raman_nd1(k,i);
            else
                aerBsc532_raman_d1(k,i) = aerBsc532_raman(k,i)*(((pdr532_raman(k,i)-Dnd(2))*(1+Dd(2)))/((Dd(2)-Dnd(2))*(1+pdr532_raman(k,i))));
                aerBsc532_raman_nd1(k,i) = aerBsc532_raman(k,i) - aerBsc532_raman_d1(k,i);
                err_aerBsc532_raman_d1(k,i) = 0.15*aerBsc532_raman_d1(k,i);
                err_aerBsc532_raman_nd1(k,i) = 0.15*aerBsc532_raman_nd1(k,i);
            end
        end
    end
end

for k = 1:size(aerBsc1064_raman,1) 
    for i = 1:size(aerBsc1064_raman,2) 
        if isnan(aerBsc1064_raman(k,i)) || isnan(pdr1064_raman(k,i)) || (isnan(aerBsc1064_raman(k,i)) && isnan(pdr1064_raman(k,i)))
            aerBsc1064_raman_d1(k,i) = NaN;
            aerBsc1064_raman_nd1(k,i) = NaN;
            err_aerBsc1064_raman_d1(k,i) = NaN;
            err_aerBsc1064_raman_nd1(k,i) = NaN;
        else
            if pdr1064_raman(k,i) < Dnd(3)
                aerBsc1064_raman_d1(k,i) = 0;
                aerBsc1064_raman_nd1(k,i) = aerBsc1064_raman(k,i);
                err_aerBsc1064_raman_d1(k,i) = 0.15*aerBsc1064_raman_d1(k,i);
                err_aerBsc1064_raman_nd1(k,i) = 0.15*aerBsc1064_raman_nd1(k,i);
            elseif pdr1064_raman(k,i) > Dd(3)
                aerBsc1064_raman_d1(k,i) = aerBsc1064_raman(k,i);
                aerBsc1064_raman_nd1(k,i) = 0;
                err_aerBsc1064_raman_d1(k,i) = 0.15*aerBsc1064_raman_d1(k,i);
                err_aerBsc1064_raman_nd1(k,i) = 0.15*aerBsc1064_raman_nd1(k,i);
            else
                aerBsc1064_raman_d1(k,i) = aerBsc1064_raman(k,i)*(((pdr1064_raman(k,i)-Dnd(3))*(1+Dd(3)))/((Dd(3)-Dnd(3))*(1+pdr1064_raman(k,i))));
                aerBsc1064_raman_nd1(k,i) = aerBsc1064_raman(k,i) - aerBsc1064_raman_d1(k,i);
                err_aerBsc1064_raman_d1(k,i) = 0.15*aerBsc1064_raman_d1(k,i);
                err_aerBsc1064_raman_nd1(k,i) = 0.15*aerBsc1064_raman_nd1(k,i);
            end
        end
    end
end

POLIPHON1 = struct();
POLIPHON1.aerBsc355_klett_d1 = aerBsc355_klett_d1;
POLIPHON1.aerBsc355_klett_nd1 = aerBsc355_klett_nd1;
POLIPHON1.aerBsc532_klett_d1 = aerBsc532_klett_d1;
POLIPHON1.aerBsc532_klett_nd1 = aerBsc532_klett_nd1;
POLIPHON1.aerBsc1064_klett_d1 = aerBsc1064_klett_d1;
POLIPHON1.aerBsc1064_klett_nd1 = aerBsc1064_klett_nd1;
POLIPHON1.aerBsc355_raman_d1 = aerBsc355_raman_d1;
POLIPHON1.aerBsc355_raman_nd1 = aerBsc355_raman_nd1;
POLIPHON1.aerBsc532_raman_d1 = aerBsc532_raman_d1;
POLIPHON1.aerBsc532_raman_nd1 = aerBsc532_raman_nd1;
POLIPHON1.aerBsc1064_raman_d1 = aerBsc1064_raman_d1;
POLIPHON1.aerBsc1064_raman_nd1 = aerBsc1064_raman_nd1;
POLIPHON1.err_aerBsc355_klett_d1 = err_aerBsc355_klett_d1;
POLIPHON1.err_aerBsc355_klett_nd1 = err_aerBsc355_klett_nd1;
POLIPHON1.err_aerBsc532_klett_d1 = err_aerBsc532_klett_d1;
POLIPHON1.err_aerBsc532_klett_nd1 = err_aerBsc532_klett_nd1;
POLIPHON1.err_aerBsc1064_klett_d1 = err_aerBsc1064_klett_d1;
POLIPHON1.err_aerBsc1064_klett_nd1 = err_aerBsc1064_klett_nd1;
POLIPHON1.err_aerBsc355_raman_d1 = err_aerBsc355_raman_d1;
POLIPHON1.err_aerBsc355_raman_nd1 = err_aerBsc355_raman_nd1;
POLIPHON1.err_aerBsc532_raman_d1 = err_aerBsc532_raman_d1;
POLIPHON1.err_aerBsc532_raman_nd1 = err_aerBsc532_raman_nd1;
POLIPHON1.err_aerBsc1064_raman_d1 = err_aerBsc1064_raman_d1;
POLIPHON1.err_aerBsc1064_raman_nd1 = err_aerBsc1064_raman_nd1;

end

