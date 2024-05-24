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
        "NR_profiles", "cloudinfo","POLIPHON"
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
        
        file_searchpattern = f"{YYYY}_{MM}_{DD}_*[0-9]_{param}*.nc"

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


#def read_nc_att(nc_filename):
#    nc_dict={}
#    if not os.path.exists(nc_filename):
#        print('{filename} does not exist.'.format(filename=nc_filename))
#        return
#    else:
#        pass
#
#    ## open nc-file as dataset
#    nc_file_ds = Dataset(nc_filename, "r")
#    
#    ## get global attributes from nc-file
#    global_attr = {}
#    for nc_attr in nc_file_ds.ncattrs():
#                # att_value=repr(input_nc_file.getncattr(nc_attr))
#        att_value = nc_file_ds.getncattr(nc_attr)
#        global_attr[nc_attr] = att_value
#    ## get variable attributes from nc-file
#    var_attr_355 = {}
#    var_attr_532 = {}
#    var_attr_1064 = {}
#    var = ["attenuated_backscatter_355nm", "attenuated_backscatter_532nm", "attenuated_backscatter_1064nm"]
#    for var_att in nc_file_ds.variables[var[0]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
#        var_attr_355[var_att] = var_att_value
#    for var_att in nc_file_ds.variables[var[1]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
#        var_attr_532[var_att] = var_att_value
#    for var_att in nc_file_ds.variables[var[2]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[2]].getncattr(var_att)
#        var_attr_1064[var_att] = var_att_value
#
#    PollyVersion = global_attr['source']
#    location = global_attr['location']
#    version = global_attr['version']
#    
#    ATT_BETA_355 = nc_file_ds[var[0]][:]
#    ATT_BETA_532 = nc_file_ds[var[1]][:]
#    ATT_BETA_1064 = nc_file_ds[var[2]][:]
#    quality_mask_355 = nc_file_ds['quality_mask_355nm'][:]
#    quality_mask_532 = nc_file_ds['quality_mask_532nm'][:]
#    quality_mask_1064 = nc_file_ds['quality_mask_1064nm'][:]
#    height = nc_file_ds['height'][:]
#    time = nc_file_ds['time'][:]
#    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
#    LCUsed355 = var_attr_355['Lidar_calibration_constant_used']
#    LCUsed532 = var_attr_532['Lidar_calibration_constant_used']
#    LCUsed1064 = var_attr_1064['Lidar_calibration_constant_used']
#    dataFilename = re.split(r'\/',nc_filename)[-1]
#   
#
#    ## fill dictionary for output
#    nc_dict['m_date'] = m_date
#    nc_dict['time'] = time
#    nc_dict['height'] = height
#    nc_dict['PollyVersion'] = PollyVersion
#    nc_dict['location'] = location
#    nc_dict['PicassoVersion'] = version
#    nc_dict['ATT_BETA_355'] = ATT_BETA_355
#    nc_dict['ATT_BETA_532'] = ATT_BETA_532
#    nc_dict['ATT_BETA_1064'] = ATT_BETA_1064
#    nc_dict['quality_mask_355'] = quality_mask_355
#    nc_dict['quality_mask_532'] = quality_mask_532
#    nc_dict['quality_mask_1064'] = quality_mask_1064
#    nc_dict['LCUsed355'] = LCUsed355
#    nc_dict['LCUsed532'] = LCUsed532
#    nc_dict['LCUsed1064'] = LCUsed1064
#    nc_dict['PollyDataFile'] = dataFilename
#
#    return nc_dict
#
#def read_nc_NR_att(nc_filename):
#    nc_dict={}
#    if not os.path.exists(nc_filename):
#        print('{filename} does not exist.'.format(filename=nc_filename))
#        return
#    else:
#        pass
#
#    ## open nc-file as dataset
#    nc_file_ds = Dataset(nc_filename, "r")
#    
#    ## get global attributes from nc-file
#    global_attr = {}
#    for nc_attr in nc_file_ds.ncattrs():
#                # att_value=repr(input_nc_file.getncattr(nc_attr))
#        att_value = nc_file_ds.getncattr(nc_attr)
#        global_attr[nc_attr] = att_value
#    ## get variable attributes from nc-file
#    var_attr_355 = {}
#    var_attr_532 = {}
#    var = ["attenuated_backscatter_355nm", "attenuated_backscatter_532nm"]
#    for var_att in nc_file_ds.variables[var[0]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
#        var_attr_355[var_att] = var_att_value
#    for var_att in nc_file_ds.variables[var[1]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
#        var_attr_532[var_att] = var_att_value
#
#    # pollyVersion = mat['CampaignConfig']['name'][0][0][0]
#    PollyVersion = global_attr['source']
#    location = global_attr['location']
#    version = global_attr['version']
#    
#    ATT_BETA_355 = nc_file_ds[var[0]][:]
#    ATT_BETA_532 = nc_file_ds[var[1]][:]
#    quality_mask_355 = nc_file_ds['quality_mask_355nm'][:]
#    quality_mask_532 = nc_file_ds['quality_mask_532nm'][:]
#    height = nc_file_ds['height'][:]
#    time = nc_file_ds['time'][:]
#    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
#    LCUsed355 = var_attr_355['Lidar_calibration_constant_used']
#    LCUsed532 = var_attr_532['Lidar_calibration_constant_used']
#    dataFilename = re.split(r'\/',nc_filename)[-1]
#   
#
#    ## fill dictionary for output
#    nc_dict['m_date'] = m_date
#    nc_dict['time'] = time
#    nc_dict['height'] = height
#    nc_dict['PollyVersion'] = PollyVersion
#    nc_dict['location'] = location
#    nc_dict['PicassoVersion'] = version
#    nc_dict['ATT_BETA_355'] = ATT_BETA_355
#    nc_dict['ATT_BETA_532'] = ATT_BETA_532
#    nc_dict['quality_mask_355'] = quality_mask_355
#    nc_dict['quality_mask_532'] = quality_mask_532
#    nc_dict['LCUsed355'] = LCUsed355
#    nc_dict['LCUsed532'] = LCUsed532
#    nc_dict['PollyDataFile'] = dataFilename
#
#    return nc_dict
#
#def read_nc_OC_att(nc_filename):
#    nc_dict={}
#    if not os.path.exists(nc_filename):
#        print('{filename} does not exist.'.format(filename=nc_filename))
#        return
#    else:
#        pass
#
#    ## open nc-file as dataset
#    nc_file_ds = Dataset(nc_filename, "r")
#    
#    ## get global attributes from nc-file
#    global_attr = {}
#    for nc_attr in nc_file_ds.ncattrs():
#                # att_value=repr(input_nc_file.getncattr(nc_attr))
#        att_value = nc_file_ds.getncattr(nc_attr)
#        global_attr[nc_attr] = att_value
#    ## get variable attributes from nc-file
#    var_attr_355 = {}
#    var_attr_532 = {}
#    var_attr_1064 = {}
#    var = ["attenuated_backscatter_355nm", "attenuated_backscatter_532nm", "attenuated_backscatter_1064nm"]
#    for var_att in nc_file_ds.variables[var[0]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
#        var_attr_355[var_att] = var_att_value
#    for var_att in nc_file_ds.variables[var[1]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
#        var_attr_532[var_att] = var_att_value
#    for var_att in nc_file_ds.variables[var[2]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[2]].getncattr(var_att)
#        var_attr_1064[var_att] = var_att_value
#
#    PollyVersion = global_attr['source']
#    location = global_attr['location']
#    version = global_attr['version']
#    
#    ATT_BETA_355 = nc_file_ds[var[0]][:]
#    ATT_BETA_532 = nc_file_ds[var[1]][:]
#    ATT_BETA_1064 = nc_file_ds[var[2]][:]
#    quality_mask_355 = np.where(ATT_BETA_355 > 0, 0, 0)
#    quality_mask_532 = np.where(ATT_BETA_532 > 0, 0, 0)
#    quality_mask_1064 = np.where(ATT_BETA_1064 > 0, 0, 0)
#    height = nc_file_ds['height'][:]
#    time = nc_file_ds['time'][:]
#    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
#    LCUsed355 = var_attr_355['Lidar_calibration_constant_used']
#    LCUsed532 = var_attr_532['Lidar_calibration_constant_used']
#    LCUsed1064 = var_attr_1064['Lidar_calibration_constant_used']
#    dataFilename = re.split(r'\/',nc_filename)[-1]
#   
#
#    ## fill dictionary for output
#    nc_dict['m_date'] = m_date
#    nc_dict['time'] = time
#    nc_dict['height'] = height
#    nc_dict['PollyVersion'] = PollyVersion
#    nc_dict['location'] = location
#    nc_dict['PicassoVersion'] = version
#    nc_dict['ATT_BETA_355'] = ATT_BETA_355
#    nc_dict['ATT_BETA_532'] = ATT_BETA_532
#    nc_dict['ATT_BETA_1064'] = ATT_BETA_1064
#    nc_dict['quality_mask_355'] = quality_mask_355
#    nc_dict['quality_mask_532'] = quality_mask_532
#    nc_dict['quality_mask_1064'] = quality_mask_1064
#    nc_dict['LCUsed355'] = LCUsed355
#    nc_dict['LCUsed532'] = LCUsed532
#    nc_dict['LCUsed1064'] = LCUsed1064
#    nc_dict['PollyDataFile'] = dataFilename
#
#    return nc_dict

def read_nc_VDR(nc_filename):
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
                # att_value=repr(input_nc_file.getncattr(nc_attr))
        att_value = nc_file_ds.getncattr(nc_attr)
        global_attr[nc_attr] = att_value
    ## get variable attributes from nc-file
    var_attr_355 = {}
    var_attr_532 = {}
    var_attr_1064 = {}
#    var_attr_dict = {}
    var = ["volume_depolarization_ratio_355nm", "volume_depolarization_ratio_532nm", "volume_depolarization_ratio_1064nm"]
    

    for var_att in nc_file_ds.variables[var[0]].ncattrs():
        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
        var_attr_355[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[1]].ncattrs():
        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
        var_attr_532[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[2]].ncattrs():
        var_att_value = nc_file_ds.variables[var[2]].getncattr(var_att)
        var_attr_1064[var_att] = var_att_value



    PollyVersion = global_attr['source']
    location = global_attr['location']
    version = global_attr['version']

    VDR_355 = nc_file_ds[var[0]][:]
    VDR_532 = nc_file_ds[var[1]][:]
    VDR_1064 = nc_file_ds[var[2]][:]
    quality_mask_355 = np.where(VDR_355 > 0, 0, 0)
    quality_mask_532 = np.where(VDR_532 > 0, 0, 0)
    quality_mask_1064 = np.where(VDR_1064 > 0, 0, 0)
    eta355 = re.split(r'eta:',var_attr_355['comment'])[1]
    eta355 = re.split(r'\)',eta355)[0].replace(" ", "")
    eta532 = re.split(r'eta:',var_attr_532['comment'])[1]
    eta532 = re.split(r'\)',eta532)[0].replace(" ", "")
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")

    #dataFilename = re.split(r'\/',nc_filename)[-1]
    dataFilename = str(Path(nc_filename).name)

    ## fill dictionary for output
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
    nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['VDR_355'] = VDR_355
    nc_dict['VDR_532'] = VDR_532
    nc_dict['VDR_1064'] = VDR_1064
    nc_dict['quality_mask_355'] = quality_mask_355
    nc_dict['quality_mask_532'] = quality_mask_532
    nc_dict['quality_mask_1064'] = quality_mask_1064
    nc_dict['eta355'] = eta355
    nc_dict['eta532'] = eta532
    nc_dict['PollyDataFile'] = dataFilename

    nc_file_ds.close()
    return nc_dict


def read_nc_WVMR_RH(nc_filename):
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
                # att_value=repr(input_nc_file.getncattr(nc_attr))
        att_value = nc_file_ds.getncattr(nc_attr)
        global_attr[nc_attr] = att_value
    ## get variable attributes from nc-file
    var_attr_WVMR = {}
    var_attr_RH = {}
    var = ["WVMR", "RH"]
    for var_att in nc_file_ds.variables[var[0]].ncattrs():
        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
        var_attr_WVMR[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[1]].ncattrs():
        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
        var_attr_RH[var_att] = var_att_value


    PollyVersion = global_attr['source']
    location = global_attr['location']
    version = global_attr['version']
    
    WVMR = nc_file_ds[var[0]][:]
    RH = nc_file_ds[var[1]][:]
    quality_mask_WVMR = nc_file_ds['QM_WVMR'][:] ## get qual-matrix from FR-nc-file
    quality_mask_RH = nc_file_ds['QM_RH'][:]
                    
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
    #dataFilename = re.split(r'\/',nc_filename)[-1]
    dataFilename = str(Path(nc_filename).name)

    ## fill dictionary for output
    nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
    nc_dict['WVMR'] = WVMR
    nc_dict['RH'] = RH
    nc_dict['quality_mask_WVMR'] = quality_mask_WVMR
    nc_dict['quality_mask_RH'] = quality_mask_RH
    nc_dict['PollyDataFile'] = dataFilename

    nc_file_ds.close()
    return nc_dict


def read_nc_quasi_results(nc_filename,q_version):
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
    ## get variable attributes from nc-file
    var_attr_quasi_angstrom = {}
    var_attr_quasi_bsc_532 = {}
    var_attr_quasi_bsc_1064 = {}
    var_attr_quasi_pardepol_532 = {}
    var = ["quasi_ang_532_1064", "quasi_bsc_532", "quasi_bsc_1064", "quasi_pardepol_532"]
    for var_att in nc_file_ds.variables[var[0]].ncattrs():
        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
        var_attr_quasi_angstrom[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[1]].ncattrs():
        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
        var_attr_quasi_bsc_532[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[2]].ncattrs():
        var_att_value = nc_file_ds.variables[var[2]].getncattr(var_att)
        var_attr_quasi_bsc_1064[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[3]].ncattrs():
        var_att_value = nc_file_ds.variables[var[3]].getncattr(var_att)
        var_attr_quasi_pardepol_532[var_att] = var_att_value


    PollyVersion = global_attr['source']
    location = global_attr['location']
    version = global_attr['version']
    
    QR_Ang = nc_file_ds[var[0]][:]
    QR_Bsc_532 = nc_file_ds[var[1]][:]
    QR_Bsc_1064 = nc_file_ds[var[2]][:]
    QR_ParDepol_532 = nc_file_ds[var[3]][:]
    quality_mask_532 = nc_file_ds['quality_mask_532'][:]
    quality_mask_1064 = nc_file_ds['quality_mask_1064'][:]
    quality_mask_voldepol = nc_file_ds['quality_mask_voldepol_532'][:]
                    
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
    if q_version == 'V1':
        QR_Bsc_532_CUsed = var_attr_quasi_bsc_532['Lidar_calibration_constant_used']
        QR_Bsc_1064_CUsed = var_attr_quasi_bsc_1064['Lidar_calibration_constant_used']
    #dataFilename = re.split(r'\/',nc_filename)[-1]
    dataFilename = str(Path(nc_filename).name)
   

    ## fill dictionary for output
    nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
    nc_dict['QR_Ang'] = QR_Ang
    nc_dict['QR_Bsc_532'] = QR_Bsc_532
    nc_dict['QR_Bsc_1064'] = QR_Bsc_1064
    nc_dict['QR_ParDepol_532'] = QR_ParDepol_532
    nc_dict['quality_mask_532'] = quality_mask_532
    nc_dict['quality_mask_1064'] = quality_mask_1064
    nc_dict['quality_mask_voldepol'] = quality_mask_voldepol
    if q_version == 'V1':
        nc_dict['QR_Bsc_532_CUsed'] = QR_Bsc_532_CUsed
        nc_dict['QR_Bsc_1064_CUsed'] = QR_Bsc_1064_CUsed
    nc_dict['PollyDataFile'] = dataFilename

    nc_file_ds.close()
    return nc_dict



def read_nc_target_classification(nc_filename):
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
                # att_value=repr(input_nc_file.getncattr(nc_attr))
        att_value = nc_file_ds.getncattr(nc_attr)
        global_attr[nc_attr] = att_value
    ## get variable attributes from nc-file
    var_attr_class = {}
    var = ["target_classification"]
    for var_att in nc_file_ds.variables[var[0]].ncattrs():
        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
        var_attr_class[var_att] = var_att_value


    PollyVersion = global_attr['source']
    location = global_attr['location']
    version = global_attr['version']
 
    TC = nc_file_ds[var[0]][:]
                    
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
    TC_def = var_attr_class['definition']
    TC_legend_key_red = var_attr_class['legend_key_red']
    TC_legend_key_green = var_attr_class['legend_key_green']
    TC_legend_key_blue = var_attr_class['legend_key_blue']

    TC_cRange = var_attr_class['plot_range']

    #dataFilename = re.split(r'\/',nc_filename)[-1]
    dataFilename = str(Path(nc_filename).name)

    ## fill dictionary for output
    nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
    nc_dict['TC'] = TC
#    nc_dict['quality_mask'] = quality_mask
    
    nc_dict['TC_def'] = TC_def
    nc_dict['TC_legend_key_red'] = TC_legend_key_red
    nc_dict['TC_legend_key_green'] = TC_legend_key_green
    nc_dict['TC_legend_key_blue'] = TC_legend_key_blue
    nc_dict['TC_cRange'] = TC_cRange
    nc_dict['PollyDataFile'] = dataFilename

    nc_file_ds.close()
    return nc_dict


def read_nc_overlap(nc_filename):
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
                # att_value=repr(input_nc_file.getncattr(nc_attr))
        att_value = nc_file_ds.getncattr(nc_attr)
        global_attr[nc_attr] = att_value
    ## get variable attributes from nc-file
    var_attr_method = {}
    var_attr_OL355 = {}
    var_attr_OL355d = {}
    var_attr_OL532 = {}
    var_attr_OL532d = {}
    var = ["method","overlap355","overlap355Defaults","overlap532","overlap532Defaults"]
    

    for var_att in nc_file_ds.variables[var[0]].ncattrs():
        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
        var_attr_method[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[1]].ncattrs():
        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
        var_attr_OL355[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[2]].ncattrs():
        var_att_value = nc_file_ds.variables[var[2]].getncattr(var_att)
        var_attr_OL355d[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[1]].ncattrs():
        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
        var_attr_OL532[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[2]].ncattrs():
        var_att_value = nc_file_ds.variables[var[2]].getncattr(var_att)
        var_attr_OL532d[var_att] = var_att_value

    PollyVersion = global_attr['source']
    location = global_attr['location']
    version = global_attr['version']

    method = nc_file_ds[var[0]][:]
    OL_355 = nc_file_ds[var[1]][:]
    OL_355d = nc_file_ds[var[2]][:]
    OL_532 = nc_file_ds[var[3]][:]
    OL_532d = nc_file_ds[var[4]][:]
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    #m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")

    #dataFilename = re.split(r'\/',nc_filename)[-1]
    dataFilename = str(Path(nc_filename).name)

    ## fill dictionary for output
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
   # nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['method'] = method
    nc_dict['OL_355'] = OL_355
    nc_dict['OL_355d'] = OL_355d
    nc_dict['OL_532'] = OL_532
    nc_dict['OL_532d'] = OL_532d
    nc_dict['PollyDataFile'] = dataFilename
    m_date = re.split(r'_',nc_dict['PollyDataFile'])
    nc_dict['m_date'] = f'{m_date[0]}-{m_date[1]}-{m_date[2]}'

    nc_file_ds.close()

    return nc_dict

def write2donefilelist_dict(donefilelist_dict,lidar,location,wavelength,product_type):
    import uuid
    uuid = uuid.uuid4()
    donefilelist_dict[uuid] = {}
    donefilelist_dict[uuid]['lidar'] = lidar
    donefilelist_dict[uuid]['location'] = location
    donefilelist_dict[uuid]['lambda'] = wavelength
    donefilelist_dict[uuid]['product_type'] = product_type

    return donefilelist_dict

def write2donefile(picassoconfigfile_dict,donefilelist_dict):

    ## Entry for donefilelist
    #
    #lidar=arielle
    #location=Arctic
    #starttime=20191108 00:00:00
    #stoptime=20191108 23:59:30
    #last_update=20191108 00:00:03
    #lambda=355
    #image=experimental/arielle/2019/11/08/2019_11_08_Fri_ARI_00_00_03_monitor.png
    #level=0
    #info=data based on laserlogbook.
    #nc_zip_file=2019_11_08_Fri_ARI_00_00_03.nc.zip
    #nc_zip_file_size=953235115
    #active=1
    #GDAS=1
    #GDAS_timestamp=20191108 12:00:00
    #lidar_ratio=50
    #software_version=3.5
    #product_type=monitor
    #product_starttime=20191108 00:00:00
    #product_stoptime=20191108 23:59:30
    #------

    donefile = picassoconfigfile_dict['doneListFile']

    with open(donefile, 'a') as file:
        for key in donefilelist_dict.keys():
            file.write(f'lidar={donefilelist_dict[key]["lidar"]}\n')
            file.write(f'location={donefilelist_dict[key]["location"]}\n')
            file.write(f'lambda={donefilelist_dict[key]["lambda"]}\n')
            file.write(f'product_type={donefilelist_dict[key]["product_type"]}\n')
            file.write(f'------\n')
    
    return None

