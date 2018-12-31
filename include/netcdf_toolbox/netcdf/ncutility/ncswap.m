function ncswap(theSrc, theDst, theDim1, theDim2)

% ncswap -- Swap order of dimensions.
%  ncswap('theSrc', 'theDst', 'theDim1', 'theDim2') swaps
%   the order of 'theDim1' and 'theDim2' dimensions in all
%   participating variables of 'theSrc' file.  The result
%   is placed in 'theDst' file (new file of different name).
%  ncswap (no arguments) invokes dialogs to get the calling
%   arguments.  The routine continually asks for input until
%   a dialog's "Cancel" button is pressed.
%
% N.B. This routine needs to be upgraded to be more mindful
%  of "record" variables.  See line #112.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 28-Jan-1998 17:19:31.

if nargin < 1, help(mfilename), end

oldPath = pwd;

while (1)
    if nargin < 1
        [theFile, thePath] = uigetfile('*.*', 'Select NetCDF File');
        if ~any(theFile), break, end
        theSrc = [thePath theFile];
        cd(thePath)
    end
    if nargin < 2
        theSuggested = [theFile '.swap.nc'];
        [theFile, thePath] = uiputfile(theSuggested, 'Save As NetCDF File:');
        if ~any(theFile), break, end
        theDst = [thePath theFile];
        cd(thePath)
    end
    f = netcdf(theSrc, 'nowrite');
    if isempty(f), break, end
    g = netcdf(theDst, 'clobber');
    if isempty(g), close(f), break, end
    okay = 1;
    if nargin < 4
        d = ncnames(dim(f));
        thePrompt = {'Pick Two Dimensions', 'Dimensions', 'Swap'};
        theName = 'Swap Dimensions';
        theMode = 'unique';
        okay = 0;
        while ~okay
            s = listpick(d, thePrompt, theName, theMode);
            if length(s) == 0
                break
            elseif length(s) == 2
                okay = 1;
                theDim1 = s{1};
                theDim2 = s{2};
            end
            thePrompt{1} = 'Pick EXACTLY Two Dimensions';
        end
    end
    if ~okay, close(g), close(f), break, end
    g < dim(f);   % Copy dimensions.
    g < att(f);   % Copy global attributes.
    v = var(f);   % Work on variables.
    w = cell(size(v));
    for k = 1:length(v)   % Define the variables.
        theDims = dim(v{k});
        i1 = 0;
        i2 = 0;
        for i = 1:length(theDims)
            if isequal(name(theDims{i}), theDim1)
                i1 = i;
            end
            if isequal(name(theDims{i}), theDim2)
                i2 = i;
            end
        end
        if i1 > 0 & i2 > 0
            temp = theDims{i1};
            theDims{i1} = theDims{i2};
            theDims{i2} = temp;
        end
        w{k} = ncvar(name(v{k}), datatype(v{k}), ncnames(theDims), g);
        a = att(v{k});   % Copy variable attributes.
        for i = 1:length(a), w{k} < a{i}; end
    end
    for k = 1:length(v)   % Fill the variables.
        theDims = dim(v{k});
        i1 = 0;
        i2 = 0;
        for i = 1:length(theDims)
            if isequal(name(theDims{i}), theDim1)
                i1 = i;
            end
            if isequal(name(theDims{i}), theDim2)
                i2 = i;
            end
        end
        order = 1:length(theDims);
        while length(order) < 2
            order = [order length(order)+1];
        end
        if i1 > 0 & i2 > 0
            temp = order(i1);
            order(i1) = order(i2);
            order(i2) = temp;
        end
        now_filling = name(w{k});
% Record-variables hate the next line.  Needs improvement.
        w{k}(:) = permute(v{k}(:), order);   % Permute and stash.
    end
    close(g)
    close(f)
    if nargin > 1, break, end
end

eval(['cd ' oldPath])
