function theResult = partnames(theItem, theName)

% partnames -- Part-names of an item.
%  partnames(theItem) returns the depth-first list of
%   the names of the parts of theItem, a Matlab entity.
%   Prepend each part-name with the name of theItem in
%   order to form the list of full-references that can
%   be used to reconstruct theItem.
%  partnames(theItem, 'theName') returns the part-names,
%   with 'theName' prepended to each one.  If '*', the
%   "inputname" of theItem is used.
%  partnames('demo') displays an example.
%
% Also see: parts().
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 28-May-1998 08:47:39.

if nargin < 1, help(mfilename), theItem = 'demo'; end

if isequal(theItem, 'demo')
	s = 'a{1}(2).b(3).c = pi;';
	disp([' ## ' s])
	disp([' ## ' mfilename '(a, a) ==>'])
	eval(s)
	r = partnames(a, a);
	for i = 1:length(r)
		disp([' ## ' r{i}])
	end
	return
end

result = {};

switch class(theItem)
case {'char', 'double', 'uint8'}
	result = {''};
case 'struct'
	f = fieldnames(theItem);
	for j = 1:length(f)
		x = getfield(theItem, f{j});
		s = partnames(x);
		len = prod(size(theItem));
		for k = 1:len
			r = s;
			index = '';
			if len > 1, index = ['(' int2str(k) ')']; end
			for i = 1:length(r)
				r{i} = [index '.' f{j} r{i}];
			end
			result = [result; r];
		end
	end
case 'cell'
	len = prod(size(theItem));
	for k = 1:len
		index = ['{' int2str(k) '}'];
		x = theItem{k};
		r = partnames(x);
		for i = 1:length(r)
			r{i} = [index r{i}];
		end
		result = [result; r];
	end
otherwise
	if isclass(theItem)
		result = partnames(struct(theItem));
	else
		disp([' ## ' mfilename '## Unknown class: ' class(theItem)])
	end
end

% Prepend the item name.

if nargin > 1
	if ~ischar(theName), theName = inputname(2); end
	if isequal(theName, '*'), theName = inputname(1); end
	if isempty(theName), theName = 'ans'; end
	for i = 1:length(result)
		result{i} = [theName result{i}];
	end
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
