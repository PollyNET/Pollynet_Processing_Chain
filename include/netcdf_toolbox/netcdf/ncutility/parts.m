function [theResult, theNames] = parts(theItem, theName)

% parts -- Values and names of the parts of an item.
%  parts(theItem) returns the values of the parts of
%   theItem, in the form of a list.
%  [theValues, theNames] = parts(...) also returns the
%   list of corresponding part-names.
%  [theValues, theNames] = parts(theItem, 'theName') also
%   prepends 'theName' to each of the part-names.
%  parts('demo') displays an example.
%
% Also see: partnames().
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 28-May-1998 09:40:37.

if nargin < 1, help(mfilename), theItem = 'demo'; end

if isequal(theItem, 'demo')
	s = 'a{1}(2).b(3).c = pi;';
	disp([' ## ' s])
	disp([' ## ' mfilename '(a, a) ==>'])
	eval(s)
	[theValues, theNames] = parts(a, a);
	for i = 1:length(theValues)
		disp([' ## ' mat2str(theNames{i}) ' ==> ' mat2str(theValues{i})])
	end
	return
end

theNames = partnames(theItem, '*');
result = cell(size(theNames));

for i = 1:length(theNames)
	result{i} = eval(theNames{i}, '''no-assigned-value''');
end

if nargout > 1
	if nargin < 2
		theNames = partnames(theItem);
	else
		if ~ischar(theName), theName = inputname(2); end
		if isequal(theName, '*'), theName = inputname(1); end
		if isempty(theName), theName = 'ans'; end
		theNames = partnames(theItem, theName);
	end
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
