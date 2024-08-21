# -*- coding: utf-8 -*-
"""
Created on 2021-09-13

@author: Andi Klamt
"""

import numpy as np
import netCDF4
from netCDF4 import Dataset
from pathlib import Path
import re
import os
import shutil
import datetime as dt
import sys
import xarray
#import zipfile
from zipfile import ZipFile, ZIP_DEFLATED, is_zipfile
import argparse
import platform

### start arg parsing

## Create the parser
pollyxt_parser = argparse.ArgumentParser(description='Concatenate pollyxt level0 nc-files from one day, with input variables: timestamp, input_path, output_path')

pollyxt_parser.add_argument('-t', '--timestamp', dest='timestamp', metavar='timestamp', 
                       type=str,
                       help='the date to choose: YYYYMMDD')

pollyxt_parser.add_argument('-d', '--device', dest='device', metavar='device', 
                       type=str,
                       help='set the pollyxt device')

pollyxt_parser.add_argument('-r', '--raw_folder', dest='raw_folder', metavar='level0_folder',
                       type=str,
                       default='/data/level0/polly',
                       help='the level0 folder of the polly data. default is set to /data/level0/polly')

pollyxt_parser.add_argument('-o', '--output_path', dest='output_path', metavar='output_path',
                       type=str,
                       default='./',
                       help='set the absolute output path for the resulting unzipped files and the concatenated nc-file')

pollyxt_parser.add_argument('-f', '--force', dest='force', metavar='force_merging',
                       type=str,
                       default = False,
                       help='force merging, independent of differences found in attributes')

## Execute the parse_args() method
args = pollyxt_parser.parse_args()
### end of arg parsing

timestamp=args.timestamp
#input_path=args.input_path
device=args.device
output_path = args.output_path
force = args.force
raw_folder = args.raw_folder

if force.lower() == "true":
    force = True
elif force.lower() == "false":
    force = False

# Get the operating system name
os_name = platform.system()
print(f'Operating System: {os_name}')

### start of main function to call subfunctions
def main():
#    get_input_path(timestamp,device)
#    checking_attr()
#    get_pollyxt_files()
#    checking_timestamp()

    concat_files()

    get_pollyxt_logbook_files()

    return ()
### end of main function

def get_input_path(timestamp,device,raw_folder):
    YYYY=timestamp[0:4]
    MM=timestamp[4:6]
    input_path = Path(raw_folder,device,"data_zip",f"{YYYY}{MM}")
    print(input_path)
    return input_path

### start of function concat_pollyxt_files
def get_pollyxt_files():
    '''
        This function locates multiple pollyxt level0 nc-zip files from one day measurements,
        unzipps the files to output_path
        and returns a list of files to be merged
        and the title of the new merged nc-file
    '''
    input_path = get_input_path(timestamp,device,raw_folder) 
    path_exist = Path(input_path)
    
    if path_exist.exists() == True:
        
        ## set the searchpattern for the zipped-nc-files:
        YYYY=timestamp[0:4]
        MM=timestamp[4:6]
        DD=timestamp[6:8]
        
        zip_searchpattern = str(YYYY)+'_'+str(MM)+'_'+str(DD)+'*_*[0-9].nc.zip'
        
        polly_files       = Path(r'{}'.format(input_path)).glob('{}'.format(zip_searchpattern))
        polly_zip_files_list0 = [x for x in polly_files if x.is_file()]
        
        
        ## convert type path to type string
        polly_zip_files_list = []
        for file in polly_zip_files_list0:
            polly_zip_files_list.append(str(file))
        
        if len(polly_zip_files_list) < 1:
            print('no files found!')
            sys.exit()

        # Ensure the destination directory exists
        Path(output_path).mkdir(parents=True, exist_ok=True)

        polly_files_list = []
        to_unzip_list = []
        for zip_file in polly_zip_files_list:
            ## check for size of zip-files to ensure to exclude bad measurement files with wrong timestamp e.g. 19700101
            f_size = os.path.getsize(zip_file)
            print(zip_file)
            if f_size > 500000:
                print(f_size)
                print("filesize passes")
            else:
                print(f_size)
                print("filesize too small, file will be skipped!")
                continue ## go to next file

            ## check if zipfile is a valid zip-file
            if not is_zipfile(zip_file):
                print(f"invalid zip-file: {zip_file}\nskipping file.")
                #polly_zip_files_list.remove(zip_file)
                continue
            else:
                pass

            unzipped_nc = Path(zip_file).name
            unzipped_nc = Path(unzipped_nc).stem
            unzipped_nc = Path(output_path,unzipped_nc)
            polly_files_list.append(unzipped_nc)
            path = Path(unzipped_nc)

            ## check if unzipped files already exists in outputfolder
            if path.is_file() == False:
                to_unzip_list.append(zip_file)
            if path.is_file() == True:
                os.remove(unzipped_nc)
                to_unzip_list.append(zip_file)
        
        ## unzipping
        date_pattern = str(YYYY)+'_'+str(MM)+'_'+str(DD)
        if len(to_unzip_list) > 0:
            ## if working remotly on windows, copy zipped files first, than unzip
            if os_name.lower() == 'windows':
                print("\nCopy zipped files to local drive...")
                for zip_file in to_unzip_list:
                    print(zip_file)
                    shutil.copy2(Path(zip_file), Path(output_path) / Path(zip_file).name)
                print("\nUnzipping...")
                for zip_file in Path(output_path).iterdir():
                    if zip_file.is_file() and date_pattern in zip_file.stem and zip_file.suffix == '.zip': 
                        with ZipFile(zip_file, 'r') as zip_ref:
                            print("unzipping "+str(zip_file))
                            zip_ref.extractall(output_path)
                        print("Removing .zip file...")
                        os.remove(zip_file)

            else:
                print("\nUnzipping...")
                for zip_file in to_unzip_list:
                    with ZipFile(zip_file, 'r') as zip_ref:
                        print("unzipping "+zip_file)
                        zip_ref.extractall(output_path)
       

        ## sort lists
        polly_files_list.sort()

        print("\n"+str(len(polly_files_list))+" files found:\n")
        print(polly_files_list)
        print("\n")

    else:
        print("\nNo data was found in {}. Correct path?\n".format(input_path))
        sys.exit()
    return polly_files_list

def get_pollyxt_logbook_files():
    '''
        This function locates multiple pollyxt logbook-zip files from one day measurements,
        unzipps the files to output_path
        and  merge them to one file
    '''
    input_path = get_input_path(timestamp,device,raw_folder) 
    path_exist = Path(input_path)
    
    if path_exist.exists() == True:
        
        ## set the searchpattern for the zipped-nc-files:
        YYYY=timestamp[0:4]
        MM=timestamp[4:6]
        DD=timestamp[6:8]
        
        zip_searchpattern = str(YYYY)+'_'+str(MM)+'_'+str(DD)+'*_*laserlogbook*.zip'
        
        polly_laserlog_files       = Path(r'{}'.format(input_path)).glob('{}'.format(zip_searchpattern))
        polly_laserlog_zip_files_list0 = [x for x in polly_laserlog_files if x.is_file()]
        
        
        ## convert type path to type string
        polly_laserlog_zip_files_list = []
        for file in polly_laserlog_zip_files_list0:
            polly_laserlog_zip_files_list.append(str(file))
        
        if len(polly_laserlog_zip_files_list) < 1:
            print('no laserlogbook-files found!')
            sys.exit()

        polly_laserlog_files_list = []
        to_unzip_list = []
        for zip_file in polly_laserlog_zip_files_list:
            unzipped_logtxt = Path(zip_file).name
            unzipped_logtxt = Path(unzipped_logtxt).stem
            unzipped_logtxt = Path(output_path,unzipped_logtxt)
            polly_laserlog_files_list.append(unzipped_logtxt)
            path = Path(unzipped_logtxt)

            to_unzip_list.append(zip_file)

        
        ## unzipping
        if len(to_unzip_list) > 0:
            for zip_file in to_unzip_list:
                with ZipFile(zip_file, 'r') as zip_ref:
                    print("unzipping "+zip_file)
                    zip_ref.extractall(output_path)
    
        ## sort lists
        polly_laserlog_files_list.sort()

        print("\n"+str(len(polly_laserlog_files_list))+" laserlogfiles found:\n")
        print(polly_laserlog_files_list)
        print("\n")

        ## concat the txt files
        result_file = Path(output_path,"result.txt")
        with open(result_file, "wb") as outfile:
            for logf in polly_laserlog_files_list:
                with open(logf, "rb") as infile:
                    outfile.write(infile.read())
                ## delete every single logbook-file from unzipped-folder
                os.remove(logf)

        laserlog_filename = polly_laserlog_files_list[0]
        laserlog_filename = Path(laserlog_filename).name
        laserlog_filename_left = re.split(r'_[0-9][0-9]_[0-9][0-9]_[0-9][0-9]\.nc',laserlog_filename)[0]
        laserlog_filename = f'{laserlog_filename_left}_00_00_01.nc.laserlogbook.txt'
        destination_file = Path(output_path,laserlog_filename)
        
        # Open the source file in binary mode and read its content
        with open(result_file, 'rb') as source:
            # Open the destination file in binary mode and write the content
            with open(destination_file, 'wb') as destination:
                destination.write(source.read())

        os.remove(result_file)
    else:
        print("\nNo laserlogbook was found in {}. Correct path?\n".format(input_path))
    
    return ()


def add_to_list(element, from_list, to_list):
    if from_list[element] in to_list:
        pass
    else:
        to_list.append(from_list[element])

def checking_vars():
    ## select only those nc-files where the values of some specific variables haven't changed
    vars_of_interest = [
                        'measurement_height_resolution',
                        'laser_rep_rate',
                        'laser_power',
#                        'laser_flashlamp',
                        'location_height',
                        'neutral_density_filter',
#                        'location_coordinates',
                        'pm_voltage',
                        'pinhole',
                        'polstate',
                        'telescope',
                        'deadtime_polynomial',
                        'discr_level',
                        'if_center',
                        'if_fwhm',
                        'zenithangle'
                        ]

    polly_files_list = get_pollyxt_files()
    if len(polly_files_list) == 1:
        return polly_files_list

    polly_file_ds_ls = []
    for files in polly_files_list:
        polly_file_ds = Dataset(files,"r")
        polly_file_ds_ls.append(polly_file_ds)

    selected_var_nc_ls=[]
    diff_var=0
    print('\n')
    print('checking differences in selected variables ...')
    for ds in range(0,len(polly_file_ds_ls)-1):
#        print('\n')
#        print(polly_files_list[ds] + '   vs.   ' + polly_files_list[ds+1])
        for var in vars_of_interest:
            if var in polly_file_ds_ls[ds].variables.keys(): ## check if var is available within the polly-datastructure (depending on polly-system)
                var_value_1=str(polly_file_ds_ls[ds].variables[var][:])
                var_value_2=str(polly_file_ds_ls[ds+1].variables[var][:])
    #            print(var + ": " + var_value_1)
    #            print(var + ": " + var_value_2)
                if var_value_1 == var_value_2 and diff_var==0:
                    # print('no difference found ...')
                    add_to_list(ds,polly_files_list,selected_var_nc_ls)
                elif var_value_1 != var_value_2 and diff_var==0:
                    print('difference found in var:')
                    print(var)
                    #print(var + ": " + var_value_1)
                    #print(var + ": " + var_value_2)
                    diff_var=1
                    add_to_list(ds,polly_files_list,selected_var_nc_ls) if force == True else None
                elif var_value_1 == var_value_2 and diff_var!=0:
                    add_to_list(ds,polly_files_list,selected_var_nc_ls) if force == True else None 
                elif var_value_1 != var_value_2 and diff_var!=0:
                    diff_var=diff_var+1
                    print('difference found!')
                    add_to_list(ds,polly_files_list,selected_var_nc_ls) if force == True else None
        polly_file_ds_ls[ds].close()
                
    if diff_var==0:
        add_to_list(-1,polly_files_list,selected_var_nc_ls)
        print('\nno differences found in selected variables!\n')
    elif diff_var!=0:
#        add_to_list(-1,polly_files_list,selected_var_nc_ls) if force == True else None
        ## if force==true, merge, but if force==false: the whole day will not be in list anymore
        if force == True:
            add_to_list(-1,polly_files_list,selected_var_nc_ls)
            print('\ndifferences found in selected variables! But will be force-merged.\n')
        else:
            print('\ndifferences found in selected variables! Selected Date will be skipped.\n')
            for el in polly_files_list:
                os.remove(el)
            sys.exit()

    return selected_var_nc_ls
        
    
def checking_attr():
    ## select only those nc-files where the global attributes and the var-attributes haven't changed
    selected_var_nc_ls = checking_vars()
    if len(selected_var_nc_ls) == 1:
        return selected_var_nc_ls

    polly_file_ds_ls = []
    for files in selected_var_nc_ls:
        print(files)
        polly_file_ds = Dataset(files,"r")
        polly_file_ds_ls.append(polly_file_ds)
    
    selected_att_nc_ls = []
    diff_att=0
    diff_var_att=0
    print('\n')
    print('checking differences in attributes ...')
    for ds in range(0,len(polly_file_ds_ls)-1):
        ## get global attributes as a list of strings
#        print(selected_var_nc_ls[ds] + '   vs.   ' + selected_var_nc_ls[ds+1])
#        print('\nglobal attributes:')
        for nc_attr in polly_file_ds_ls[0].ncattrs():
            # att_value=repr(input_nc_file.getncattr(nc_attr))
            att_value_1=polly_file_ds_ls[ds].getncattr(nc_attr)
            att_value_2=polly_file_ds_ls[ds+1].getncattr(nc_attr)
#            print(nc_attr)
#            print("   " + att_value_1)
#            print("   " + att_value_2)
            if att_value_1 == att_value_2 and diff_att==0:
                add_to_list(ds,selected_var_nc_ls,selected_att_nc_ls)
            elif att_value_1 != att_value_2 and diff_att==0:
                print('difference found!')
                print(nc_attr)
                print("   " + att_value_1)
                print("   " + att_value_2)
                diff_att=1
                add_to_list(ds,selected_var_nc_ls,selected_att_nc_ls) if force == True else None
            elif att_value_1 == att_value_2 and diff_att!=0:
                add_to_list(ds,selected_var_nc_ls,selected_att_nc_ls) if force == True else None
            elif att_value_1 != att_value_2 and diff_att!=0:
                print('difference found!')
                add_to_list(ds,selected_var_nc_ls,selected_att_nc_ls) if force == True else None
        
#        print("\nvariable attributes:")
        for var in polly_file_ds_ls[0].variables.keys():
#            print(var)
            for var_att in polly_file_ds_ls[0].variables[var].ncattrs():
                var_att_value_1 = polly_file_ds_ls[ds].variables[var].getncattr(var_att)
                var_att_value_2 = polly_file_ds_ls[ds+1].variables[var].getncattr(var_att)
#                print("   " + var_att)
#                print("      " + var_att_value_1)
#                print("      " + var_att_value_2)
                if var_att_value_1 == var_att_value_2 and diff_var_att==0:
                    pass
                elif var_att_value_1 != var_att_value_2 and diff_var_att==0:
                    print('difference found!')
                    print("   " + var_att)
                    print("      " + var_att_value_1)
                    print("      " + var_att_value_2)
                    diff_var_att=1
                elif var_att_value_1 == var_att_value_2 and diff_var_att!=0:
                    pass
                elif var_att_value_1 != var_att_value_2 and diff_var_att!=0:
                    print('difference found!')

    for ds in range(0,len(polly_file_ds_ls)-1):
        polly_file_ds_ls[ds].close()

                
    if diff_att==0:
        add_to_list(-1,selected_var_nc_ls,selected_att_nc_ls)
        print('\nno differences found in global attributes!\n')
    elif diff_att!=0:
#        add_to_list(-1,selected_var_nc_ls,selected_att_nc_ls) if force == True else None

        ## if force==true, merge, but if force==false: the whole day will not be in list anymore
        if force == True:
            add_to_list(-1,selected_var_nc_ls,selected_att_nc_ls)
            print('\ndifferences found in global attributes! But will be force-merged.\n')
        else:
            print('\ndifferences found in global attributes! Selected Date will be skipped.\n')
            for el in polly_files_list:
                os.remove(el)
            sys.exit()

    if diff_var_att==0:
        print('\nno differences found in variable attributes!\n')
#	elif diff_var_att != 0:
#        ## if force==true, merge, but if force==false: the whole day will not be in list anymore
#        if force == True:
#            add_to_list(-1,selected_var_nc_ls,selected_att_nc_ls)
#        	print('\ndifferences found in variable attributes! But will be force-merged.\n')
#        else:
#        	print('\ndifferences found in variable attributes! Selected Date will be skipped.\n')
#	        sys.exit()
		

    print(selected_att_nc_ls)
    return selected_att_nc_ls

def checking_timestamp():
    selected_timestamp_nc_ls = checking_attr()
#    if len(selected_timestamp_nc_ls) == 1:
#        return selected_timestamp_nc_ls
    selected_cor_timestamp_nc_ls = []
    polly_file_ds_ls = []
    print('checking for correct timestamps...')
    for files in selected_timestamp_nc_ls:
        polly_file_ds = Dataset(files,"r")
        polly_file_ds_ls.append(polly_file_ds)

    for elementNR,ds in enumerate(polly_file_ds_ls):
    #    print(selected_timestamp_nc_ls[elementNR])
        timestamp_ds = ds.variables['measurement_time'][:]
        if 19700101 in timestamp_ds.T[0]:
            print(f'The file: {selected_timestamp_nc_ls[elementNR]} contains incorrect timestamps!')
            print('Trying to correct timestamps...')
            ## get correct timestamp_ds from filename
            timestamp_filename = selected_timestamp_nc_ls[elementNR]
            timestamp_filename = timestamp_filename.stem
            timestamp_filename = re.split(r'_',str(timestamp_filename))[-3:]
            ## del. nc-file
            #os.remove(selected_timestamp_nc_ls[elementNR]) ### remove unzipped nc-file with incorrect timestamps
            ## calc. the deltaT between measurementdatapoints
            laser_rep_rate = float(ds.variables['laser_rep_rate'][0])
            measurement_shots = ds.variables['measurement_shots'][:]
            measurement_shots_nonzero = [elem for row in measurement_shots for elem in row if elem > 0]
            exit
            if len(measurement_shots_nonzero) == 0:
                print('length of measurement_shots_nonzero equals 0. file will be removed from merging list.')
                ds.close()
                continue
            else:
                measurement_shots_average = sum(measurement_shots_nonzero) / len(measurement_shots_nonzero)
                deltaT = measurement_shots_average / laser_rep_rate
                deltaT = int(round(deltaT,0)) ## unit in seconds
                ## calc. the correct seconds of day for this dataset
                start_seconds = int(timestamp_filename[0])*3600 + int(timestamp_filename[1])*60 + int(timestamp_filename[2])
                ## length of measurement_list
                len_measurement_list = len(timestamp_ds)
                ## create new measurement_time list
                seconds_ls = []
                t = start_seconds
                for i in range(1, len_measurement_list+1):
                    seconds_ls.append(t)
                    t = t + deltaT
                ## check if seconds_ls does not contain seonds of day larger than 86400 ## TODO
                ## if so, remove file from list and del. file ## TODO
                t_check = any(value > 86400 for value in seconds_ls)
                #t_check = False ## do not skip files which are longer than 24h, seconds_ls > 86400
                if t_check == True:
                    print('seconds of day exceeds 86400. file will be removed from merging list.')
                    ds.close()
                    continue
                else:
                    seconds_iter = iter(seconds_ls)
                    new_measurement_time_list = [[int(timestamp), next(seconds_iter)] for i in range(1, len_measurement_list+1)]
        
                    ## create a new netCDF4 file to write the dataset
                    new_dataset = Dataset(f'{selected_timestamp_nc_ls[elementNR]}_dummy', mode='w')
                    print(f'{selected_timestamp_nc_ls[elementNR]}_dummy')
        
                    ## copy the entire dataset to the new file
                    new_dataset.setncatts(ds.__dict__)
                    for name, dim in ds.dimensions.items():
                        new_dataset.createDimension(name, len(dim) if not dim.isunlimited() else None)
                    
                    for name, var in ds.variables.items():
                        new_var = new_dataset.createVariable(name, var.dtype, var.dimensions)
                        if name == 'measurement_time':
                            new_var[:] = new_measurement_time_list
                        else:
                            new_var[:] = var[:]
                    
        
                    ds.close()
                    new_dataset.close()
                    os.remove(selected_timestamp_nc_ls[elementNR]) ### remove unzipped nc-file with incorrect timestamps
                    os.rename(f'{selected_timestamp_nc_ls[elementNR]}_dummy',selected_timestamp_nc_ls[elementNR])
                    print('timestamps corrected.')
                    selected_cor_timestamp_nc_ls.append(selected_timestamp_nc_ls[elementNR])
        else:
            print(f'The file: {selected_timestamp_nc_ls[elementNR]} passes timestamp check.')
            selected_cor_timestamp_nc_ls.append(selected_timestamp_nc_ls[elementNR])

        if ds.isopen():
            ds.close()


    print('\nthe following '+str(len(selected_cor_timestamp_nc_ls))+' files can be merged:')
    print(selected_cor_timestamp_nc_ls)
    return selected_cor_timestamp_nc_ls


def concat_files():
    ## merge selected files
    
#    concat='concat'
    
    sel_polly_files_list = checking_timestamp()

    if len(sel_polly_files_list) == 0:
        print('no files found for this day. no merging.')
        return ()
    polly_files_no_path = Path(sel_polly_files_list[0]).name
    filestring_left = str(re.split(r'_[0-9][0-9]_[0-9][0-9]_[0-9][0-9]', polly_files_no_path)[0])
    filestring_dummy = f"{filestring_left}_00_00_01_dummy.nc"       
    filestring = f"{filestring_left}_00_00_01.nc"       

    if len(sel_polly_files_list) == 1:
        print("\nOnly one file found. Nothing to merge!\n")
        os.rename(sel_polly_files_list[0],Path(output_path,filestring))
        return ()
    else:
#        sel_polly_files_list = [ str(el) for el in sel_polly_files_list]
        ## parameters for controlling the merging process
        compat='override' ## Values of variable "laser_flashlamp" often changes, but those files will be merged anyway. This option picks the value from first dataset.
        coords='minimal'
        
        ds = xarray.open_mfdataset(sel_polly_files_list,combine = 'nested', data_vars="minimal", concat_dim="time", compat=compat, coords=coords)
        ## save to a single nc-file
        print(f"\nmerged nc-file '{filestring}' will be stored to '{output_path}'")
        print("\nwriting merged file ...")

        ## adding compression-level encoding
        def write_netcdf(ds: xarray.Dataset, out_file: Path) -> None:
            enc = {}

            for k in ds.data_vars:
                if ds[k].ndim < 2:
                    continue

                enc[k] = {
                    "zlib": True,
                    "complevel": 1,
#                    "fletcher32": True,
#                    "chunksizes": tuple(map(lambda x: x//2, ds[k].shape))
                }

            ds.to_netcdf(out_file, format="NETCDF4", engine="netcdf4", encoding=enc)

        write_netcdf(ds=ds,out_file=Path(output_path,filestring_dummy))

        ds.close()

    print("\ndeleting individual .nc files ...")
    for el in sel_polly_files_list:
        print(el)
        os.remove(el)
    destination_file = Path(output_path,filestring)
    if os.path.exists(destination_file):
        os.remove(destination_file)  # Remove the existing destination file
    os.rename(Path(output_path,filestring_dummy),destination_file)
    print('done!')
    return ()


### call of main function
main()


### EOF ###
