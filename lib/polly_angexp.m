function [angexp, angexpStd] = Polly_angexp(param1, param1_std, param2, param2_std, wavelength1, wavelength2, smoothWindow)
    %POLLY_ANGEXP calculate the angstroem exponent and std.
    %	Example:
    %		[angexp, angexpStd] = Polly_angexp(param1, param1_std, param2, 
    %		param2_std, wavelength1, wavelength2)
    %	Inputs:
    %		param1, param1_std, param2, param2_std, wavelength1, wavelength2
    %	Outputs:
    %		angexp, angexpStd
    %	History:
    %		2018-11-20. First edition by Zhenping.
    %	Contact:
    %		zhenping@tropos.de
    
    if ~ exist('smoothWindow', 'var')
        smoothWindow = 17;
    end
    
    param1(param1 <= 0) = NaN;
    param2(param2 <= 0) = NaN;
    
    ratio = transpose(smoothWin(param1, smoothWindow) ./ smoothWin(param2, smoothWindow));
    
    angexp = log(ratio) ./ log(wavelength2 ./ wavelength1);
    
    k = 1 ./ log(wavelength2 ./ wavelength1);
    angexpStd = sqrt((k./param1).^2 .* param1_std.^2./sqrt(smoothWindow) + (k./param2).^2 .* param2_std.^2./sqrt(smoothWindow));
    
    end