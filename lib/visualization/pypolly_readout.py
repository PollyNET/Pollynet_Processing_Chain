import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, LogNorm
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
from matplotlib.dates import DateFormatter, \
                             DayLocator, HourLocator, MinuteLocator, date2num
import os
import re
import sys
import scipy.io as spio
import numpy as np
from datetime import datetime, timedelta, timezone
import matplotlib
from netCDF4 import Dataset
import json
from pathlib import Path
from statistics import mode
import pandas as pd
import sqlite3

# load colormap
dirname = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(dirname)
try:
    from python_colormap import *
except Exception as e:
    raise ImportError('python_colormap module is necessary.')

# generating figure without X server
plt.switch_backend('Agg')


def input_folder(configfile):
    f = open (configfile, "r")
    config_json = json.loads(f.read())
    inputfolder = config_json['results_folder']
    f.close()
    return inputfolder

def get_nc_filename(date, device, inputfolder, param=""):
    '''
    param: str
        att-param with possible values: "att_bsc", "NR_att_bsc", "OC_att_bsc", "vol_depol", "WVMR_RH", "quasi_results",
        "quasi_results_V2" "target_classification", "target_classification_V2", "profiles", "OC_profiles",
        "NR_profiles", "cloudinfo","POLIPHON_1"
    '''

#    inputfolder = input_folder(configfile)
    YYYY = date[0:4]
    MM = date[4:6]
    DD = date[6:8]
    #inputfolder = f"{inputfolder}/{device}/{YYYY}/{MM}/{DD}"
    inputfolder = Path(inputfolder,device,YYYY,MM,DD)

    path_exist = Path(inputfolder)

    if path_exist.exists() == True:
        print(inputfolder)
        
        file_searchpattern = f"{YYYY}_{MM}_{DD}_*[0-9]_{param}.nc"

        res_file = Path(r'{}'.format(inputfolder)).glob('{}'.format(file_searchpattern))
        ## convert type path to type string
        res_file = [ str(res) for res in res_file ]
        if len(res_file) < 1:
            print('no files found!')
            sys.exit()
        else:
            print(res_file)
            return(res_file)
    else:
        print(f'folder {inputfolder} does not exist!')


def fill_time_gaps_of_matrix(time, ATT_BETA, quality_mask):
    """
    Description
    -----------
    Locate gaps in time-dimension and fill gaps in ATT_BSC_Matrix for 24h plots.

    Parameters
    ----------
    time: list
        time values in unixtime.
    ATT_BETA: array-like
        the ATT_BETA matrix.
    quality_mask: array-like
        the quality_matrix corresponding to the ATT_BETA matrix
        

    Usage
    -----
    fill_time_gaps_of_matrix(time, ATT_BETA, quality_mask)

    History
    -------
    2022-09-01. First edition by Andi
    """

    ## get time-differences between profiles
    diff_time = [ time[d+1]-time[d] for d in range(len(time)-1) ]

    ## get profile_length (in most cases 30 seconds)
    occurence_count = mode(diff_time) ## get most frequently element
    profile_length = int(np.round(occurence_count))
    
    ## get gaps, if time-gap is bigger than 2 x profile_length
    gap_finder = np.where(np.array(diff_time) > 2*profile_length)
    fill_size = 0
    fill_size_all = 0
    fill_value = ATT_BETA.fill_value

    ## Set masked values (bad signal) to 0, to differntiate between bad signals and measurement-gaps
    ATT_BETA = np.ma.masked_where(ATT_BETA.mask, ATT_BETA, 0)
    
    for gap in gap_finder[0]:
        fill_size_all = fill_size_all + fill_size
        gap = gap + fill_size_all
        time_gap = diff_time[gap-fill_size_all]
        profiles_num = int(np.round(time_gap/profile_length))
        matrix_left_att = ATT_BETA[:gap+1]
        matrix_right_att = ATT_BETA[gap:]
        matrix_left_mask = quality_mask[:gap+1]
        matrix_right_mask = quality_mask[gap:]
        fill_size =  profiles_num
        matrix_left_att = np.pad(matrix_left_att,((0,fill_size),(0,0)), 'constant', constant_values=fill_value)
        matrix_left_mask = np.pad(matrix_left_mask,((0,fill_size),(0,0)), 'constant', constant_values=-1)
        
        ATT_BETA = np.append(matrix_left_att, matrix_right_att,axis=0)
        quality_mask = np.append(matrix_left_mask, matrix_right_mask,axis=0)

    ## get date and convert to datetime object
    date_00 = datetime.fromtimestamp(int(time[0])).strftime('%Y%m%d') # convert Unix-timestamp to datestring
    date_00 = datetime.strptime(str(date_00), '%Y%m%d').replace(tzinfo=timezone.utc) # convert to datetime object of UTC-time 
    date_00 = date_00.timestamp() # convert to unix-timestamp-object

    ## check start unix-time
    start_diff = abs(time[0]-date_00)
    if start_diff < (profile_length * 2):
        fill_size_start = 0
    else:
        fill_size_start = int(np.round(start_diff/profile_length))
        ATT_BETA = np.pad(ATT_BETA,((fill_size_start,0),(0,0)), 'constant', constant_values=fill_value)
        quality_mask = np.pad(quality_mask,((fill_size_start,0),(0,0)), 'constant', constant_values=-1)
    ## check end unix-time
    end_diff = abs(time[-1] - (date_00+24*60*60))
    if end_diff < (profile_length * 2):
        fill_size_end = 0
    else:
        fill_size_end =  int(np.round(end_diff/profile_length))
        ATT_BETA = np.pad(ATT_BETA,((0,fill_size_end),(0,0)), 'constant', constant_values=fill_value)
        quality_mask = np.pad(quality_mask,((0,fill_size_end),(0,0)), 'constant', constant_values=-1)

    return ATT_BETA, quality_mask



####
####
####

def set_x_lims(flagPlotLastProfilesOnly,mdate,last_timestamp)->list:
    ## set x-lim to 24h or only to last available timestamp
    if flagPlotLastProfilesOnly == True:
        ## Convert Unix timestamp string to a datetime object
        mtime_end = datetime.utcfromtimestamp(int(last_timestamp))
        mtime_end = mtime_end.timestamp()
        ## set x_lims from 0 to end of mtime of file by creating a list of datetime.datetime objects using map.
        x_lims = list(map(datetime.fromtimestamp, [mdate, mtime_end]))
    else:
        ## set x_lims for 24hours by creating a list of datetime.datetime objects using map.
        x_lims = list(map(datetime.fromtimestamp, [mdate, mdate+24*60*60]))
    return x_lims


def trimm_matrix_to_last_timestamp(flagPlotLastProfilesOnly,matrix,mdate,profile_length,last_timestamp):
    ## trimm matrix to last available timestamp if neccessary
    if flagPlotLastProfilesOnly == True:
        ## Convert Unix timestamp string to a datetime object
        mtime_end = datetime.utcfromtimestamp(int(last_timestamp))
        mtime_end = mtime_end.timestamp()
        last_hours = (mdate+24*60*60 - mtime_end)/3600
        n = int(3600/profile_length*last_hours) - 1 ## '-1' to be sure not to cut last profile
        matrix = matrix[:-n] ## trimm last n=(3600s/profile_length*last_hours)
                                 ## time-slices to correctly fit to imshow-plot
                                 ## profile_length = mshots/laser_rep_rate = mostly 30s
    else:
        pass
    return matrix



def read_nc_file(nc_filename,):

    nc_dict={}
    if not os.path.exists(nc_filename):
        print('{filename} does not exist.'.format(filename=nc_filename))
        return
    else:
        pass

    ## open nc-file as dataset
    nc_file_ds = Dataset(nc_filename, "r")
    
    ## get global attributes from nc-file
    global_attr = {}
    for nc_attr in nc_file_ds.ncattrs():
        att_value = nc_file_ds.getncattr(nc_attr)
        global_attr[nc_attr] = att_value

    var_ls = []
    for var in nc_file_ds.variables:
        var_ls.append(var)

    ## get variable attributes from nc-file
    for v_count,var_name in enumerate(var_ls):
        for var_att in nc_file_ds.variables[var_name].ncattrs():
            var_att_value = nc_file_ds.variables[var_name].getncattr(var_att)
            nc_dict[f'{var_name}___{var_att}'] = var_att_value


    ## fill dict with variable-values
    for v_count,var_name in enumerate(var_ls):
        nc_dict[var_name] = nc_file_ds[var_name][:]


    ## fill dict with non-variable-value-params (e.g. global attributes)
    nc_dict['PollyVersion'] = global_attr['source']
    nc_dict['location'] = global_attr['location']
    nc_dict['PicassoVersion'] = global_attr['version']
    nc_dict['PollyDataFileFolder'] = nc_filename
    nc_dict['PollyDataFile'] = Path(nc_filename).parts[-1]
    m_date = re.split(r'_',nc_dict['PollyDataFile'])
    nc_dict['m_date'] = f'{m_date[0]}-{m_date[1]}-{m_date[2]}'
#    nc_dict['m_date'] = datetime.fromtimestamp(nc_file_ds['time'][0]).strftime("%Y-%m-%d")

    nc_file_ds.close()
    return nc_dict


####
####
####


def calc_ANGEXP(nc_dict):
    ## AE_beta_lambda1_lambda2(z) = - np.log(beta1(z)/beta2(z))/np.log(lambda1/lambda2) = np.log(beta1(z)/beta2(z))/np.log(lambda2/lambda1)
    ## AE_part.ext_lambda1_lambda2(z) = AE_beta_lambda1_lambda2(z) + AE_LR_lambda1_lambda2(z) = np.log(extinction1(z)/extinction2(z)/np.log(lambda2/lambda1)
    ## with AngstromExp for the Lidar Ratio LR: AE_LR_lambda1_lambda2(z) = - np.log(LR1(z)/LR2(z))/np.log(lambda1/lambda2)
    ## lambda1 < lambda2


    def compute_valid_log(X,Y):
        ## simple way
        #ratio = X/Y
        #ratio[ratio < 0] = np.nan
        #log_ratio = np.log(ratio)

        ## pythonic way
        # Compute X / Y while avoiding division by zero
        with np.errstate(divide='ignore', invalid='ignore'):
            ratio = np.ma.divide(X, Y)

        # Mask out invalid values in the ratio (e.g., non-positive values)
        invalid_mask = (ratio <= 0) | ratio.mask
        ratio = np.ma.masked_array(ratio, mask=invalid_mask)

        # Compute the natural logarithm of the valid values
        log_ratio = np.ma.log(ratio)
        return log_ratio

    ##using smoothing window function
    def smoothed_data(data,window_size):
        window = np.ones(int(window_size))/float(window_size)
        smoothed_data = np.convolve(data,window,'same')
        return smoothed_data

    window_size = 25

    log_klett_355_532 = compute_valid_log(smoothed_data(data=nc_dict['aerBsc_klett_355'],window_size=window_size),smoothed_data(data=nc_dict['aerBsc_klett_532'],window_size=window_size))
    if 'aerBsc_klett_1064' in nc_dict.keys():
        log_klett_532_1064 = compute_valid_log(smoothed_data(data=nc_dict['aerBsc_klett_532'],window_size=window_size),smoothed_data(data=nc_dict['aerBsc_klett_1064'],window_size=window_size))
    log_raman_355_532 = compute_valid_log(smoothed_data(data=nc_dict['aerBsc_raman_355'],window_size=window_size),smoothed_data(data=nc_dict['aerBsc_raman_532'],window_size=window_size))
    if 'aerBsc_raman_1064' in nc_dict.keys():
        log_raman_532_1064 = compute_valid_log(smoothed_data(data=nc_dict['aerBsc_raman_532'],window_size=window_size),smoothed_data(data=nc_dict['aerBsc_raman_1064'],window_size=window_size))
    log_LR_355_532 = compute_valid_log(smoothed_data(data=nc_dict['aerLR_raman_355'],window_size=window_size),smoothed_data(data=nc_dict['aerLR_raman_532'],window_size=window_size))
    log_Ext_raman_355_532 = compute_valid_log(smoothed_data(data=nc_dict['aerExt_raman_355'],window_size=window_size),smoothed_data(data=nc_dict['aerExt_raman_532'],window_size=window_size))

#    log_klett_355_532 = compute_valid_log(nc_dict['aerBsc_klett_355'],nc_dict['aerBsc_klett_532'])
#    log_klett_532_1064 = compute_valid_log(nc_dict['aerBsc_klett_532'],nc_dict['aerBsc_klett_1064'])
#    log_raman_355_532 = compute_valid_log(nc_dict['aerBsc_raman_355'],nc_dict['aerBsc_raman_532'])
#    log_raman_532_1064 = compute_valid_log(nc_dict['aerBsc_raman_532'],nc_dict['aerBsc_raman_1064'])
#    log_LR_355_532 = compute_valid_log(nc_dict['aerLR_raman_355'],nc_dict['aerLR_raman_532'])
#    log_Ext_raman_355_532 = compute_valid_log(nc_dict['aerExt_raman_355'],nc_dict['aerExt_raman_532'])

    AE_beta_355_532_Klett = log_klett_355_532/np.log(532/355)
    if 'aerBsc_klett_1064' in nc_dict.keys():
        AE_beta_532_1064_Klett = log_klett_532_1064/np.log(1064/532)
    AE_beta_355_532_Raman = log_raman_355_532/np.log(532/355)
    if 'aerBsc_raman_1064' in nc_dict.keys():
        AE_beta_532_1064_Raman = log_raman_532_1064/np.log(1064/532)
    AE_LR_355_532_Raman = log_LR_355_532/np.log(532/355)
    #AE_parExt_355_532_Raman = AE_beta_355_532_Raman + AE_LR_355_532_Raman
    AE_parExt_355_532_Raman = log_Ext_raman_355_532/np.log(532/355)


    nc_dict['AE_beta_355_532_Klett'] = AE_beta_355_532_Klett
    nc_dict['AE_beta_355_532_Raman'] = AE_beta_355_532_Raman
    if 'aerBsc_klett_1064' in nc_dict.keys():
        nc_dict['AE_beta_532_1064_Klett'] = AE_beta_532_1064_Klett
    if 'aerBsc_raman_1064' in nc_dict.keys():
        nc_dict['AE_beta_532_1064_Raman'] = AE_beta_532_1064_Raman
    nc_dict['AE_LR_355_532_Raman'] = AE_LR_355_532_Raman
    nc_dict['AE_parExt_355_532_Raman'] = AE_parExt_355_532_Raman

#    nc_dict['AE_beta_355_532_Klett'] = smoothed_data(data=AE_beta_355_532_Klett,window_size=window_size)
#    nc_dict['AE_beta_355_532_Raman'] = smoothed_data(data=AE_beta_355_532_Raman,window_size=window_size)
#    nc_dict['AE_beta_532_1064_Klett'] = smoothed_data(data=AE_beta_532_1064_Klett,window_size=window_size)
#    nc_dict['AE_beta_532_1064_Raman'] = smoothed_data(data=AE_beta_532_1064_Raman,window_size=window_size)
#    nc_dict['AE_LR_355_532_Raman'] = smoothed_data(data=AE_LR_355_532_Raman,window_size=window_size)
#    nc_dict['AE_parExt_355_532_Raman'] = smoothed_data(data=AE_parExt_355_532_Raman,window_size=window_size)
    return nc_dict


def write2donefilelist_dict(donefilelist_dict='',
                            lidar='',
                            location='',
                            starttime='',
                            stoptime='',
                            last_update='',
                            wavelength='',
                            filename='',
                            level='',
                            info='',
                            nc_zip_file='',
                            nc_zip_file_size='',
                            active='',
                            GDAS='',
                            GDAS_timestamp='',
                            lidar_ratio='',
                            software_version='',
                            product_type='',
                            product_starttime='',
                            product_stoptime=''
                            ):

    filenamepath_cropped = Path(filename).parent.parts
    filenamepath_cropped = Path(*filenamepath_cropped[-5:])


    ## initialize dict
    donefilelist_dict[filename] = {}

    donefilelist_dict[filename]['lidar'] = lidar
    donefilelist_dict[filename]['location'] = location
    donefilelist_dict[filename]['starttime'] = starttime
    donefilelist_dict[filename]['stoptime'] = stoptime
    donefilelist_dict[filename]['last_update'] = last_update
    donefilelist_dict[filename]['lambda'] = wavelength
    donefilelist_dict[filename]['image'] = f'{str(filenamepath_cropped)}/{str(Path(filename).name)}' #experimental/arielle/2019/11/08/2019_11_08_Fri_ARI_00_00_03_SAT_FR_532.png
    donefilelist_dict[filename]['level'] = level
    donefilelist_dict[filename]['info'] = info
    donefilelist_dict[filename]['nc_zip_file'] = nc_zip_file
    donefilelist_dict[filename]['nc_zip_file_size'] = nc_zip_file_size
    donefilelist_dict[filename]['active'] = active
    donefilelist_dict[filename]['GDAS'] = GDAS
    donefilelist_dict[filename]['GDAS_timestamp'] = GDAS_timestamp
    donefilelist_dict[filename]['lidar_ratio'] = lidar_ratio
    donefilelist_dict[filename]['software_version'] = software_version
    donefilelist_dict[filename]['product_type'] = product_type
    donefilelist_dict[filename]['product_starttime'] = product_starttime
    donefilelist_dict[filename]['product_stoptime'] = product_stoptime

    return donefilelist_dict

def write2donefile(picassoconfigfile_dict,donefilelist_dict):

    donefile = picassoconfigfile_dict['doneListFile']

    with open(donefile, 'a') as file:
        for key in donefilelist_dict.keys():
            for keyname in donefilelist_dict[key]:
                file.write(f'{keyname}={donefilelist_dict[key][keyname]}\n')
            file.write(f'------\n')
    
    return None


def connect_to_sql_db(db_path,table_name,timestamp,wavelength,method,telescope):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    YYYY = timestamp[0:4]
    MM = timestamp[4:6]
    DD = timestamp[6:8]
    formatted_timestamp = f'{YYYY}-{MM}-{DD}'

    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    cursor.execute(f"PRAGMA table_info({table_name});")

    query = f"""
              SELECT * 
              FROM {table_name}
              WHERE cali_start_time LIKE ? AND wavelength = ? AND cali_method LIKE ? AND telescope LIKE ?
              """
    df = pd.read_sql_query(query, conn, params=(f'%{formatted_timestamp}%',wavelength,f'%{method}%',f'%{telescope}%'))
#    cursor.execute(query, (f'%{formatted_timestamp}%',wavelength,f'%{method}%',f'%{telescope}%'))


#    values = cursor.fetchall()
#    for value in values:
#        print(value)

    conn.close()

    return df

def read_from_logbookFile(logbookFile_path):
    df = pd.read_csv(logbookFile_path, sep=';', header=0, index_col=None)
    print(df)
    return df



