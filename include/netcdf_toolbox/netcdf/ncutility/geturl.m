function theResult = geturl(theURL, theFilename)

% geturl -- Get a URL.
%  geturl('theURL', 'theFilename') calls Netscape to get
%   'theURL', saving it to 'theFilename'.  If a wildcard
%   filename is provided, the "uiputfile" dialog is invoked.
%   If no path is given, the current directory is used.
%   If no filename is given, or if it is '', the file is
%   opened in an active Netscape window.  This routine
%   does not wait for the completion of the download.
%
%  Note to users: The path to Netscape must be hardwired
%   into the "geturl.mac" AppleScript, a text file that
%   can be modified with the Matlab editor.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 10-Sep-1997 16:28:22.
% Updated    28-Mar-2000 14:38:07.

if nargout > 0, theResult = []; end

if nargin < 1
   help(mfilename)
   return
end

if ~any(findstr(computer, 'MAC')) & 0
   disp([' ## No action taken: "' mfilename '" requires Macintosh computer.'])
   return
end

if nargin < 2, theFilename = ''; end

if ~isempty(theFilename) & any(theFilename == '*')
	theFilename = 'unnamed';
   [theFile, thePath] = uiputfile(theFilename, 'Save File As');
  if any(theFile)
	  if thePath(end) ~= filesep
		  thePath(end+1) = filesep;
		 end
     theFilename = [thePath theFile];
     disp([' ## Saving to "' theFilename '"'])
  else
     disp(' ## No action taken.')
     return
  end 
end

if ~isempty(theFilename)
   if ~any(theFilename == filesep)
		thePWD = pwd;
		if thePWD(end) ~= filesep
			thePWD(end+1) = filesep;
		end
      theFilename = [thePWD theFilename];
   end
end

% Be sure the following is hardwired into "geturl.mac".
%  Passing it in as an argument does not work (so far).

theApplication = 'priapus:WWW:Internet:Netscape:Netscape';

% Quote the arguments.

theAppleScript = 'geturl.mac';

result = 0;

if isunix
	result = feval('wget', theURL, theFilename);
elseif any(findstr(lower(computer), 'pcwin'))
	disp(' ## "geturl" requires Macintosh or Unix presently.')
elseif any(findstr(lower(computer), 'mac'))
	theURL = ['"' theURL '"'];
	theFilename = ['"' theFilename '"'];
	theApplication = ['"' theApplication '"'];   % Not used.
	result = feval('applescript', theAppleScript, ...
						'theURL', theURL, ...
						'theFilename', theFilename);
	result = 1;
end

result = any(result);
	
% Display status, if any.

if ~isempty(result) & 0
	disp([' ## ' mfilename ' status: ' int2str(result)])
end

result = logical(isempty(result));

if nargout > 0, theResult = result; end
