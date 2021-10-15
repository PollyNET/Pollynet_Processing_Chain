clc;
PicassoDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
pollyDataRootPath = '/data/level0/polly';

%% Parameter definition
picassoCfgFile = fullfile(PicassoDir, 'config', 'picasso_config.json');

%% Read Picasso Link file
PicassoCfg = loadConfig(picassoCfgFile, fullfile(PicassoDir, 'lib', 'config', 'pollynet_processing_chain_config.json'));
PicassoCampLinks = read_camp_and_config(PicassoCfg.pollynet_config_link_file);

%% Start test
for iCamp = 1:length(PicassoCampLinks.camp_starttime)

    fprintf('Finished %6.2f%%: Campaign location: %s; start time: %s\n', (iCamp - 1) / length(PicassoCampLinks.camp_starttime) * 100, PicassoCampLinks.location{iCamp}, datestr(PicassoCampLinks.camp_starttime(iCamp)));

    if isempty(PicassoCampLinks.config_file{iCamp})
        fprintf('No config file available.\n');
        continue;
    end

    thisStartTime = PicassoCampLinks.camp_starttime(iCamp);
    thisStopTime = PicassoCampLinks.camp_starttime(iCamp) + 1;
    pollyDataFolder = fullfile(pollyDataRootPath, PicassoCampLinks.instrument{iCamp});

    picassoProcHistoryData(datestr(thisStartTime, 'yyyymmdd-HHMMSS'), datestr(thisStopTime, 'yyyymmdd-HHMMSS'), pollyDataFolder, 'pollyType', PicassoCampLinks.instrument{iCamp}, 'PicassoConfigFile', picassoCfgFile, 'mode', 'w');
end