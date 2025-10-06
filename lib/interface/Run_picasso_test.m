% File is originally from Jimenez to start PPC with Inputfiles
% Modified by Nathan to run in parallel and do a partial run first to get LC values
% These methods should probably get implemented in "picassoProcTodolist.m" instead of this additional file


clc
clear all

path(path,'E:\Antarctis CCN\picasso_update\Pollynet_Processing_Chain\lib\interface')
path(path,'E:\Antarctis CCN\picasso_update\Pollynet_Processing_Chain\')
 
javaaddpath('E:\Antarctis CCN\picasso_update\Pollynet_Processing_Chain\include\sqlite-jdbc-3.30.1.jar')


initPicassoToolbox


Inputfiles={
'2023_02_27_Mon_ARI_00_00_01.nc'
'2023_02_27_Mon_ARI_06_00_01.nc'
'2023_02_27_Mon_ARI_12_00_01.nc'
'2023_02_27_Mon_ARI_18_00_01.nc'  
};


lidar_path='E:\Antarctis CCN\Datasets\2023 - Rawdata\Cases\';

% Set number of parallel workers (0 and 1 will be ignored -> program will run sequentially)
par_pool_size = 0;

if par_pool_size > 1
    pool_obj = gcp("nocreate");
    if isempty(pool_obj)
        pool_obj = parpool('local',par_pool_size);
    elseif pool_obj.NumWorkers ~= par_pool_size
        delete(gcp("nocreate"));
        pool_obj = parpool('local',par_pool_size);
    end
end

% First run to get the LC values / stops midway
if par_pool_size > 1
    % Preallocate output container
    LidarLCexport_temp = cell(1, length(Inputfiles));

    parfor i = 1:length(Inputfiles)
        javaaddpath('E:\Antarctis CCN\picasso_update\Pollynet_Processing_Chain\include\sqlite-jdbc-3.30.1.jar');

        InputFiles_lidar = fullfile(lidar_path, Inputfiles{i});  % Construct path

        lidarFileExists = isfile(InputFiles_lidar);
        borrar = 0;

        if ~lidarFileExists
            borrar = 1;
            try
                unzip(strcat(InputFiles_lidar, '.zip'), lidar_path);
            catch
                fprintf('Unable to unzip %s.zip\n', InputFiles_lidar);
                continue;
            end
        end

        try
            [report, LidarLCexport] = picassoProcV3( ...
                InputFiles_lidar, ...
                'arielle', ...
                'E:\Antarctis CCN\picasso\template_pollynet_processing_chain_overlaptest2_Neumayer.json', ...
                true, 0);

            LidarLCexport_temp{i} = LidarLCexport;

        catch ME
            fprintf('Error processing file %s: %s\n', InputFiles_lidar, ME.message);
        end

        if borrar
            try
                delete(InputFiles_lidar);
            catch
                fprintf('Could not delete %s\n', InputFiles_lidar);
            end
        end
    end
    
    LidarLCexport_all = [LidarLCexport_temp{:}];
    
else
    LidarLCexport_all=[];

    for i=1:length(Inputfiles)
        InputFiles_lidar=strcat(lidar_path,Inputfiles{i});

        if isfile(InputFiles_lidar)
            borrar=0;
        else
            borrar=1;
            try
                unzip(strcat(InputFiles_lidar,'.zip'),lidar_path)
            catch
                message='unable to unzip'
                continue
            end
        end

        [report,LidarLCexport]=picassoProcV3(InputFiles_lidar, 'arielle', 'E:\Antarctis CCN\picasso\template_pollynet_processing_chain_overlaptest2_Neumayer.json',true,0);

        LidarLCexport_all=[LidarLCexport_all LidarLCexport];

        if borrar
            delete(InputFiles_lidar)
        end
    end
end

%%
LidarLC532=nanmean(LidarLCexport_all(1,:));
LidarLC607=nanmean(LidarLCexport_all(2,:));
LidarLC532NR=nanmean(LidarLCexport_all(3,:));
LidarLC607NR=nanmean(LidarLCexport_all(4,:));
LidarLC1064=nanmean(LidarLCexport_all(5,:));

LC=[LidarLC532,LidarLC607,LidarLC532NR,LidarLC607NR, LidarLC1064];

%%
% Second run with the LC values obtained / full runthrough
if par_pool_size > 1
    LidarLCexport_temp = cell(1, length(Inputfiles));

    parfor i = 1:length(Inputfiles)
        javaaddpath('E:\Antarctis CCN\picasso\Pollynet_Processing_Chain\include\sqlite-jdbc-3.30.1.jar');

        InputFiles_lidar = fullfile(lidar_path, Inputfiles{i});

        lidarFileExists = isfile(InputFiles_lidar);
        borrar = 0;

        if ~lidarFileExists
            borrar = 1;
            try
                unzip(strcat(InputFiles_lidar, '.zip'), lidar_path);
            catch
                fprintf('Unable to unzip %s.zip\n', InputFiles_lidar);
                continue;
            end
        end

        try
            [report, LidarLCexport] = picassoProcV3( ...
                InputFiles_lidar, ...
                'arielle', ...
                'E:\Antarctis CCN\picasso\template_pollynet_processing_chain_overlaptest2_Neumayer.json', ...
                false, LC);

            LidarLCexport_temp{i} = LidarLCexport;

        catch ME
            fprintf('Error processing file %s: %s\n', InputFiles_lidar, ME.message);
        end

        if borrar
            try
                delete(InputFiles_lidar);
            catch
                fprintf('Could not delete %s\n', InputFiles_lidar);
            end
        end
    end

    % Combine all LidarLCexport structs if needed
    LidarLCexport_all = [LidarLCexport_temp{:}];
else
    for i=1:length(Inputfiles)
        InputFiles_lidar=strcat(lidar_path,Inputfiles{i});

        if isfile(InputFiles_lidar)
            borrar=0;
        else
            borrar=1;
            try
                unzip(strcat(InputFiles_lidar,'.zip'),lidar_path)
            catch
                message='unable to unzip'
                continue
            end
        end

        LC=[LidarLC532,LidarLC607,LidarLC532NR,LidarLC607NR, LidarLC1064];

        [report,temp]=picassoProcV3(InputFiles_lidar, 'arielle', 'E:\Antarctis CCN\picasso\template_pollynet_processing_chain_overlaptest2_Neumayer.json',false, LC);


        if borrar
            delete(InputFiles_lidar)
        end
    end
end


clear all
return
