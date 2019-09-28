function [] = convert_temp_2_laserlogbook(fileinfo_new, pollyList, pollyTempDirs)
%convert_temp_2_laserlogbook convert the polly temps file to laserlogbook file.
%   Example:
%       [] = convert_temp_2_laserlogbook(fileinfo_new, pollyList, pollyTempDirs)
%   Inputs:
%       fileinfo_new: char
%           absolute path of the fileinfo_new
%       pollyList: cell
%           python list whose temps file needs to be converted.
%       pollyTempDirs: cell
%           the respective temps folder.
%   Outputs:
%       
%   References:
%       example of polly temps file:
% Status sum: 1 -> roof closed, 2 -> no rain
% ==============================================================================
%           Time, UTC	 T1064	  pyro	    T1	   RH1	    T2	   RH2	  Tout	 RHout	 Status	  Dout
% 23.09.2019 00:00:01	 -31.3	  44.3	  25.0	  27.2	  24.4	  28.8	  18.5	  37.6	     7	     7
% 23.09.2019 00:00:05	 -31.2	  44.2	  25.0	  27.2	  24.5	  29.0	  18.5	  37.9	     7	     7
% 23.09.2019 00:00:10	 -31.3	  43.9	  25.0	  27.4	  24.6	  28.7	  18.6	  37.6	     7	     7
%
%       example of polly laserlogbook file:
% 2019-09-21 18:00:49SC,29233803	WT,28.6	HT,35	EO,8024	LS,310,1,0400	ER,OK,0400	EN,435	ExtPyro: 17.800 mJ	Temp1064: -30.5 C, Temp1: 30.1 C, Temp2: 31.4 C, OutsideRH: 60.7 %, OutsideT: 28.8 C, roof: 0, rain: 2, shutter: 4
% 2019-09-21 18:01:56SC,29235134	WT,28.6	HT,35	EO,8024	LS,310,1,0400	ER,OK,0400	EN,442	ExtPyro: 18.295 mJ	Temp1064: -30.5 C, Temp1: 30.0 C, Temp2: 31.2 C, OutsideRH: 60.3 %, OutsideT: 28.9 C, roof: 0, rain: 2, shutter: 4
%
%   History:
%       2019-09-28. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if exist(fileinfo_new, 'file') ~= 2
    error('%s file does not exist.', fileinfo_new);
end

if length(pollyList) ~= length(pollyTempDirs)
    error('pollyList and pollyTempDirs are not compatible.');
end

%% parsing the fileinfo_new
taskInfo = read_fileinfo_new(fileinfo_new);

for iTask = 1:length(taskInfo.zipFile)
    pollyVersion = taskInfo.pollyVersion{iTask};
    pollyDataFile = taskInfo.zipFile{iTask};
    pollyLaserlogbookFile = sprintf('%s.laserlogbook.txt.', taskInfo.dataFilename{iTask});

    switch lower(pollyVersion)
    case 'pollyxt_tjk'
        pollyDataFileFormat = '(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})_\w*_(?<hour>\d{2})_(?<minute>\d{2})_(?<second>\d{2})\w*.nc';
        pollyTempDir = pollyTempDirs{ismember(lower(pollyList), 'pollyxt_tjk')};

        %% find the polly temps file
        measTime = polly_parsetime(pollyDataFile, pollyDataFileFormat);
        pollyTempsFile = fullfile(pollyTempDir, sprintf('%s_temps.txt', datestr(measTime, 'yyyymmdd')));
        
        %% read the polly temps file
        laserlogData = polly_read_temps(pollyTempsFile);

        %% create a fake laserlogbook file
        write_laserlogbook(pollyLaserlogbookFile, laserlogData, 'w');
    end
end

end