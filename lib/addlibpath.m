libPath = fileparts(mfilename('fullpath'));
addpath(libPath);

%% find subdirectories in lib 
subdirs = listdir(libPath);

for iSubdir = 1:length(subdirs)
	addpath(subdirs{iSubdir});
end

disp('Finish adding lib path');