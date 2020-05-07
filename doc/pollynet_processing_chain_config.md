# pollynet_processing_chain_config

This file was used to configure the `Pollynet_Processing_Chain` to find data, link the polly processing functions and save results. This file needs to be setup based on your local environment.

|Variable|Description|Type|Example|
|:------:|:----------|:--:|:-----:|
|fileinfo_new|file for recording extracted polly files|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\todo_filelist\\fileinfo_new.txt"|
|doneListFile|filename for saving the figure details|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\done_filelist.txt"|
|pollynet_history_of_places_new|file for saving the pollynet campaign information|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\todo_filelist\\pollynet_history_of_places_new.txt"|
|polly_config_folder|folder for saving polly configuration files|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\config"|
|log_folder|folder for saving log files, which contain the executing information|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\results\\log"|
|gdas1_folder|base directory for saving gdas1 data|string|"C:\\Users\\zhenping\\Documents\\Data\\GDAS"|
|defaultsFile_folder|folder for saving polly default files|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\lib\\pollyDefaults"|
|results_folder|folder for saving the output results|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\results"|
|pic_folder|folder for saving the output figures|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots"|
|pollynet_config_history_file|file to link the polly data with polly configuration and processing program|string|"C:\\Users\\zhenping\\Desktop\\Picasso\\config\\pollynet_processing_config_history.txt"|
|figDPI|dpi for the generated figures|integer|80|
|minDataSize|minimum size requirement for the polly data to activate the processing program|integer|1000000|
|institute|institute where you want to write into the results with netCDF files|string|"Ground-based Remote Sensing Group (TROPOS)"|
|homepage|homepage of the pollynet website, which will be written to the results with netCDF files|string|"http://polly.rsd.tropos.de"|
|contact|contact for dealing all the feedback of bugs and questions|string|"Zhenping Yin <zhenping@tropos.de>"|
|visualizationMode|interpreter for data visualization (MATLAB support has not been finished yet)|string|"python"|
|pyBinDir|python binary directory, which holds the python interpreter. If you set the **visualizationMode** to python, this variable needs to be set accordingly.|string|"C:\\Users\\zhenping\\Software"|
|flagDeleteData|flag to control whether to delete the extracted polly data files after the processing||false|
|flagEnableResultsOutput|flag to control whether to ouput the results with netCDF files|logical|true|
|flagEnableCaliResultsOutput|flag to control whether to save the lidar calibration results to the ASCII files|logical|true|
|flagEnableDataVisualization|flag to control whether to generate the figures, which would take most of the time for the data processing|logical|true|
|flagDebugOutput|flag to control whether to save the matlab workspace for debugging|logical|false|
|flagReduceMATLABToolboxDependence|flag to control whether to turn off the MATLAB toolbox to use the replaced functions in the `include` folder|logical|false|
|flagSendNotificationEmail|flag to control whether to email the processing results. (Trial)|logical|false|