function theResult = ncweb

% ncweb -- World Wide Web site of the NetCDF Toolbox.
%  ncweb (no argument) displays or returns the WWW
%   site for the NetCDF Toolbox.  If displayed,
%   a dialog asks whether to go there.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 28-Apr-1999 19:30:28.
% Updated    18-Sep-2002 14:37:43.

theURL = ['http://woodshole.er.usgs.gov/' ...
        'staffpages/cdenham/MexCDF/nc4ml5.html'];

if nargout > 0
	theResult = theURL;
else
	disp(['## NetCDF Toolbox Home Page:'])
	disp(['## ' theURL])
	theButton =  questdlg('Go To NetCDF Toolbox Home Page?', 'WWW', 'Yes', 'No', 'No');
	if isequal(theButton, 'Yes')
		theStatus = web(theURL);
		switch theStatus
		case 1
			disp(' ## Could not find Web Browser.')
			disp(' ## See "help web".')
		case 2
			disp(' ## Web Browser found, but could not be launched.')
			disp(' ## See "help web".')
			help('web')
		otherwise
		end
	end
end
