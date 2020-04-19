function [thisConfig] = loadConfigPrivate(configFile)
%loadConfigPrivate load key-value paired configuration file, and convert it into matlab struct.
%Example:
%   [thisConfig] = loadConfigPrivate(configFile)
%Inputs:
%   configFile: char
%       absolute path the configuration file. This file should only contain the key=value pair and with comments start with '#'.
%       e.g., 
%       # This is an example
%       user="Zhenping"
%       password='123'
%Outputs:
%   thisConfig: struct
%       this struct contains all the valid key-value pairs in the configuration file. The comments will be filtered and any line start with whitespace will be filtered as well. 
%History:
%   2019-09-02. Source code comes from the answer in matlab forum under the link [https://de.mathworks.com/matlabcentral/answers/16494-periodically-updated-static-text-and-reading-from-key-value-file]. Great thanks to the author Meric Ozturk.
%   2019-09-02. Modified by Zhenping.
%Contact:
%   zhenping@tropos.de

if exist(configFile, 'file') ~= 2
    error('configFile does not exist. Please check it!\n%s.', configFile);
end

fid = fopen(configFile, 'r');

% Extract key-value pairs from params file
keys = {}; 
values = {};
while ~ feof(fid)
    this_line = fgets(fid);

    % Check to see if the line is a comment or whitespace
    switch this_line(1)
        case {'#', ' ', char(10)}
            % jump the line

        otherwise
            % First token is key; second is value
            [keys{end+1}, inds] = strtok(this_line, '=');
            values{end+1} = strtok(inds, '=');

    end
end

fclose(fid);

% Remove extra padding from key-value pairs
keys = strtrim(keys); 
str_ind = cellfun(@ischar, values);
values(str_ind) = strtrim(values(str_ind));
% Remove extra ' ' around strings
data_type_ind = [];
for i = find(str_ind)
    str = values{i};
    if strcmpi(str(1), '"')
        values{i} = str(2:end-1);

        % If the value is convertible to num, convert to num
        if ~ isnan(str2double(values{i}))
            values{i} = str2double(values{i});
        end
    else
        % If the value is valid matlab commands
        data_type_ind(end+1) = i;
    end
end

% Convert data type assignments to actual data types
% This may actually be a valid use of the eval function!
for i = data_type_ind
    eval(['values{i} = ' values{i} ';']);
end

% Construct parameter struct from read key-value pairs
thisConfig = cell2struct(values, keys, 2);

end