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
from datetime import datetime, timedelta
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
        att-param with possible values: "att_bsc", "NR_att_bsc", "OC_att_bsc", "vol_depol", "WVMR_RH", "quasi_results", "quasi_results_V2" "target_classification", "target_classification_V2", "profiles", "OC_profiles", "NR_profiles", "cloudinfo"
    '''

#    inputfolder = input_folder(configfile)
    YYYY = date[0:4]
    MM = date[4:6]
    DD = date[6:8]
    inputfolder = f"{inputfolder}/{device}/{YYYY}/{MM}/{DD}"

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
#    print(profile_length)
#    print(np.nanmax(diff_time))
#    print(np.nanmin(diff_time))
    
    gap_finder = np.where(np.array(diff_time) > 2*profile_length)
    fill_size = 0
    fill_size_all = 0
    
    for gap in gap_finder[0]:
        fill_size_all = fill_size_all + fill_size
        gap = gap + fill_size_all
        time_gap = diff_time[gap-fill_size_all]
        profiles_num = int(np.round(time_gap/profile_length))
#        print(gap)
#        print(time_gap)
#        print(profiles_num)
        matrix_left_att = ATT_BETA[:gap+1]
        matrix_right_att = ATT_BETA[gap:]
#        print(matrix_left_att.shape)
#        print(len(matrix_left_att[0]))
        matrix_left_mask = quality_mask[:gap+1]
        matrix_right_mask = quality_mask[gap:]
        fill_size =  profiles_num
        matrix_left_att = np.pad(matrix_left_att,((0,fill_size),(0,0)), 'constant', constant_values=(np.NaN))
        matrix_left_mask = np.pad(matrix_left_mask,((0,fill_size),(0,0)), 'constant', constant_values=(np.NaN))
#        print(matrix_left_att.shape)
        
        ATT_BETA = np.append(matrix_left_att, matrix_right_att,axis=0)
        quality_mask = np.append(matrix_left_mask, matrix_right_mask,axis=0)

    ## get date and convert to datetime object
    date_00 = datetime.fromtimestamp(int(time[0])).strftime('%Y%m%d') # convert Unix-timestamp to datestring
    date_00 = datetime.strptime(str(date_00), '%Y%m%d') # convert to datetime object
    date_00 = date_00.timestamp()

    ## check start unix-time
    start_diff = abs(time[0]-date_00)
    if start_diff < (profile_length * 2):
#        print('OK')
        fill_size_start = 0
    else:
#        print('NOT OK')
        fill_size_start = int(np.round(start_diff/profile_length))
#        print(fill_size_start)
        ATT_BETA = np.pad(ATT_BETA,((fill_size_start,0),(0,0)), 'constant', constant_values=(np.NaN))
        quality_mask = np.pad(quality_mask,((fill_size_start,0),(0,0)), 'constant', constant_values=(np.NaN))

    ## check end unix-time
    end_diff = abs(time[-1] - (date_00+24*60*60))
    if end_diff < (profile_length * 2):
        fill_size_end = 0
    else:
        fill_size_end =  int(np.round(end_diff/profile_length))
#        print(fill_size_end)
        ATT_BETA = np.pad(ATT_BETA,((0,fill_size_end),(0,0)), 'constant', constant_values=(np.NaN))
        quality_mask = np.pad(quality_mask,((0,fill_size_end),(0,0)), 'constant', constant_values=(np.NaN))

    return ATT_BETA, quality_mask



####
####
####


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

#    var_values = {}
#    qual_mask = {}
#    for v_count,var_name in enumerate(var):
#        var_values[var_name] = nc_file_ds[var[v_count]][:]
#        qual_mask[var_name] = np.where(var_values[var_name] > 0, 0, 0)
#        nc_dict[var_name] = nc_file_ds[var[v_count]][:]
#        nc_dict[f'qual_mask_{var_name}'] = np.where(var_values[var_name] > 0, 0, 0)
#        for var_att in nc_file_ds.variables[var_name].ncattrs():
#            var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
#            var_attr_dict[f'{var_name}_{var_att}'] = var_att_value
#            if param != 'vol_depol':
#                nc_dict[f'LCUsed_{var_name}'] = var_attr_dict[f'{var_name}_{var_att}']['Lidar_calibration_constant_used']

   

    ## fill dict with non-variable-value-params (e.g. global attributes)
    nc_dict['PollyVersion'] = global_attr['source']
    nc_dict['location'] = global_attr['location']
    nc_dict['PicassoVersion'] = global_attr['version']
    nc_dict['m_date'] = datetime.fromtimestamp(nc_file_ds['time'][0]).strftime("%Y-%m-%d")
    nc_dict['PollyDataFileFolder'] = nc_filename
    nc_dict['PollyDataFile'] = re.split(r'\/',nc_filename)[-1]

    return nc_dict


####
####
####



def read_nc_att(nc_filename):
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
    var = ["attenuated_backscatter_355nm", "attenuated_backscatter_532nm", "attenuated_backscatter_1064nm"]
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
    
    ATT_BETA_355 = nc_file_ds[var[0]][:]
    ATT_BETA_532 = nc_file_ds[var[1]][:]
    ATT_BETA_1064 = nc_file_ds[var[2]][:]
    quality_mask_355 = nc_file_ds['quality_mask_355nm'][:]
    quality_mask_532 = nc_file_ds['quality_mask_532nm'][:]
    quality_mask_1064 = nc_file_ds['quality_mask_1064nm'][:]
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
    LCUsed355 = var_attr_355['Lidar_calibration_constant_used']
    LCUsed532 = var_attr_532['Lidar_calibration_constant_used']
    LCUsed1064 = var_attr_1064['Lidar_calibration_constant_used']
    dataFilename = re.split(r'\/',nc_filename)[-1]
   

    ## fill dictionary for output
    nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
    nc_dict['ATT_BETA_355'] = ATT_BETA_355
    nc_dict['ATT_BETA_532'] = ATT_BETA_532
    nc_dict['ATT_BETA_1064'] = ATT_BETA_1064
    nc_dict['quality_mask_355'] = quality_mask_355
    nc_dict['quality_mask_532'] = quality_mask_532
    nc_dict['quality_mask_1064'] = quality_mask_1064
    nc_dict['LCUsed355'] = LCUsed355
    nc_dict['LCUsed532'] = LCUsed532
    nc_dict['LCUsed1064'] = LCUsed1064
    nc_dict['PollyDataFile'] = dataFilename

    return nc_dict

def read_nc_NR_att(nc_filename):
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
    var = ["attenuated_backscatter_355nm", "attenuated_backscatter_532nm"]
    for var_att in nc_file_ds.variables[var[0]].ncattrs():
        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
        var_attr_355[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[1]].ncattrs():
        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
        var_attr_532[var_att] = var_att_value

    # pollyVersion = mat['CampaignConfig']['name'][0][0][0]
    PollyVersion = global_attr['source']
    location = global_attr['location']
    version = global_attr['version']
    
    ATT_BETA_355 = nc_file_ds[var[0]][:]
    ATT_BETA_532 = nc_file_ds[var[1]][:]
    quality_mask_355 = nc_file_ds['quality_mask_355nm'][:]
    quality_mask_532 = nc_file_ds['quality_mask_532nm'][:]
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
    LCUsed355 = var_attr_355['Lidar_calibration_constant_used']
    LCUsed532 = var_attr_532['Lidar_calibration_constant_used']
    dataFilename = re.split(r'\/',nc_filename)[-1]
   

    ## fill dictionary for output
    nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
    nc_dict['ATT_BETA_355'] = ATT_BETA_355
    nc_dict['ATT_BETA_532'] = ATT_BETA_532
    nc_dict['quality_mask_355'] = quality_mask_355
    nc_dict['quality_mask_532'] = quality_mask_532
    nc_dict['LCUsed355'] = LCUsed355
    nc_dict['LCUsed532'] = LCUsed532
    nc_dict['PollyDataFile'] = dataFilename

    return nc_dict

def read_nc_OC_att(nc_filename):
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
    var = ["attenuated_backscatter_355nm", "attenuated_backscatter_532nm", "attenuated_backscatter_1064nm"]
    for var_att in nc_file_ds.variables[var[0]].ncattrs():
        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
        var_attr_355[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[1]].ncattrs():
        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
        var_attr_532[var_att] = var_att_value
    for var_att in nc_file_ds.variables[var[2]].ncattrs():
        var_att_value = nc_file_ds.variables[var[2]].getncattr(var_att)
        var_attr_1064[var_att] = var_att_value

    # pollyVersion = mat['CampaignConfig']['name'][0][0][0]
    PollyVersion = global_attr['source']
    location = global_attr['location']
    version = global_attr['version']
    
    ATT_BETA_355 = nc_file_ds[var[0]][:]
    ATT_BETA_532 = nc_file_ds[var[1]][:]
    ATT_BETA_1064 = nc_file_ds[var[2]][:]
    quality_mask_355 = np.where(ATT_BETA_355 > 0, 0, 0)
    quality_mask_532 = np.where(ATT_BETA_532 > 0, 0, 0)
    quality_mask_1064 = np.where(ATT_BETA_1064 > 0, 0, 0)
#    quality_mask_355 = np.empty([len(ATT_BETA_355),len(ATT_BETA_355[0])])
#    quality_mask_532 = np.empty([len(ATT_BETA_532),len(ATT_BETA_532[0])])
#    quality_mask_1064 = np.empty([len(ATT_BETA_1064),len(ATT_BETA_1064[0])])
#    quality_mask_355 = read_nc_att(get_nc_filename(date, device, inputfolder, param='att_bsc'))['quality_mask_355'][:] ## get qual-matrix from FR-nc-file
#    quality_mask_532 = read_nc_att(get_nc_filename(date, device, inputfolder, param='att_bsc'))['quality_mask_532'][:]
#    quality_mask_1064 = read_nc_att(get_nc_filename(date, device, inputfolder, param='att_bsc'))['quality_mask_1064'][:]
#    quality_mask_355 = nc_file_ds['quality_mask_355nm'][:]
#    quality_mask_532 = nc_file_ds['quality_mask_532nm'][:]
#    quality_mask_1064 = nc_file_ds['quality_mask_1064nm'][:]
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
    LCUsed355 = var_attr_355['Lidar_calibration_constant_used']
    LCUsed532 = var_attr_532['Lidar_calibration_constant_used']
    LCUsed1064 = var_attr_1064['Lidar_calibration_constant_used']
    dataFilename = re.split(r'\/',nc_filename)[-1]
   

    ## fill dictionary for output
    nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
    nc_dict['ATT_BETA_355'] = ATT_BETA_355
    nc_dict['ATT_BETA_532'] = ATT_BETA_532
    nc_dict['ATT_BETA_1064'] = ATT_BETA_1064
    nc_dict['quality_mask_355'] = quality_mask_355
    nc_dict['quality_mask_532'] = quality_mask_532
    nc_dict['quality_mask_1064'] = quality_mask_1064
    nc_dict['LCUsed355'] = LCUsed355
    nc_dict['LCUsed532'] = LCUsed532
    nc_dict['LCUsed1064'] = LCUsed1064
    nc_dict['PollyDataFile'] = dataFilename

    return nc_dict

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
    
#    for v_count,var_name in enumerate(var):
#        for var_att in nc_file_ds.variables[var_name].ncattrs():
#            var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
#            var_attr_dict[f'{var_name}_{var_att}'] = var_att_value

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

#    var_values = {}
#    qual_mask = {}
#    for v_count,var_name in enumerate(var):
#        var_values[var_name] = nc_file_ds[var[v_count]][:]
#        qual_mask[var_name] = np.where(var_values[var_name] > 0, 0, 0)
#        nc_dict[var_name] = nc_file_ds[var[v_count]][:]
#        nc_dict[f'qual_mask_{var_name}'] = np.where(var_values[var_name] > 0, 0, 0)
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
#    quality_mask_355 = np.empty([len(VDR_355),len(VDR_355[0])])
#    quality_mask_532 = np.empty([len(VDR_532),len(VDR_532[0])])
#    quality_mask_1064 = np.empty([len(VDR_1064),len(VDR_1064[0])])
#    quality_mask_355 = read_nc_att(get_nc_filename(date, device, inputfolder, param='att_bsc'))['quality_mask_355'][:] ## get qual-matrix from FR-nc-file
#    quality_mask_532 = read_nc_att(get_nc_filename(date, device, inputfolder, param='att_bsc'))['quality_mask_532'][:]
#    quality_mask_1064 = read_nc_att(get_nc_filename(date, device, inputfolder, param='att_bsc'))['quality_mask_1064'][:]
#    quality_mask_355 = nc_file_ds['quality_mask_355nm'][:]
#    quality_mask_532 = nc_file_ds['quality_mask_532nm'][:]
#    quality_mask_1064 = nc_file_ds['quality_mask_1064nm'][:]
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")

    dataFilename = re.split(r'\/',nc_filename)[-1]

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
    dataFilename = re.split(r'\/',nc_filename)[-1]

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
    dataFilename = re.split(r'\/',nc_filename)[-1]
   

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

    dataFilename = re.split(r'\/',nc_filename)[-1]

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

    return nc_dict

#
#def read_nc_classification_V2(date, device, configfile):
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
#    var_attr_class = {}
#    var = ["target_classification"]
#    for var_att in nc_file_ds.variables[var[0]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
#        var_attr_class[var_att] = var_att_value
#
#
#    ## read data from configfiles
#    f = open (configfile, "r")
##    p = open (pollyconfigs, "r")
##    d = open (pollydefaults, "r")
#    g = open (pollyglobal, "r")
#    config_json = json.loads(f.read())
##    pollyconfigs_json = json.loads(p.read())
##    pollydefaults_json = json.loads(d.read())
#    pollyglobal_json = json.loads(g.read())
#
#    figDPI = config_json['figDPI']
#    flagWatermarkOn = config_json['flagWatermarkOn']
#   # partnerLabel = pollyconfigs_json['partnerLabel']
#    partnerLabel = ""
#    # pollyVersion = mat['CampaignConfig']['name'][0][0][0]
#    PollyVersion = global_attr['source']
#    location = global_attr['location']
#    version = global_attr['version']
#    fontname = config_json['fontname']
#    
#    TC = nc_file_ds[var[0]][:]
##    quality_mask = nc_file_ds['quality_mask_532'][:]
##   depCalMask = mat['depCalMask'][0][:]
##   fogMask = mat['fogMask'][0][:]
#                    
#    height = nc_file_ds['height'][:]
#    time = nc_file_ds['time'][:]
#    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")
#    TC_def = var_attr_class['definition']
#    TC_legend_key_red = var_attr_class['legend_key_red']
#    TC_legend_key_green = var_attr_class['legend_key_green']
#    TC_legend_key_blue = var_attr_class['legend_key_blue']
#
##    QR_Bsc_532_CUsed = var_attr_quasi_bsc_532['Lidar_calibration_constant_used']
##    QR_Bsc_1064_CUsed = var_attr_quasi_bsc_1064['Lidar_calibration_constant_used']
##    LCUsed1064 = var_attr_1064['Lidar_calibration_constant_used']
##    QR_Bsc_1064_cRange = var_attr_quasi_bsc_1064['plot_range'] * 1e6
#    TC_cRange = var_attr_class['plot_range']
#
##    yLim_WV = pollyglobal_json['yLim_att_beta']
#    yLim = [0, 15000]
##    flagLC355 = pollyglobal_json['flagLCCalibration']
##    flagLC532 = pollyglobal_json['flagLCCalibration']
##    flagLC1064 = pollyglobal_json['flagLCCalibration']
#    dataFilename = re.split(r'\/',nc_filename)[-1]
#    imgFormat = pollyglobal_json['imgFormat']
#    colormap_basic = pollyglobal_json['colormap_basic']
#   
#    ## close json-files
#    f.close()
#    g.close()
#
#    ## fill dictionary for output
#    nc_dict['m_date'] = m_date
#    nc_dict['time'] = time
#    nc_dict['height'] = height
#    nc_dict['figDPI'] = figDPI
#    nc_dict['flagWatermarkOn'] = flagWatermarkOn
#    nc_dict['partnerLabel'] = partnerLabel
#    nc_dict['PollyVersion'] = PollyVersion
#    nc_dict['location'] = location
#    nc_dict['PicassoVersion'] = version
#    nc_dict['fontname'] = fontname
#    nc_dict['TC'] = TC
##    nc_dict['quality_mask'] = quality_mask
#    
#    nc_dict['TC_def'] = TC_def
#    nc_dict['TC_legend_key_red'] = TC_legend_key_red
#    nc_dict['TC_legend_key_green'] = TC_legend_key_green
#    nc_dict['TC_legend_key_blue'] = TC_legend_key_blue
##    nc_dict['QR_Bsc_532_CUsed'] = QR_Bsc_532_CUsed
##    nc_dict['LCUsed1064'] = LCUsed1064
#    nc_dict['TC_cRange'] = TC_cRange
#    nc_dict['yLim'] = yLim
##    nc_dict['flagLC355'] = flagLC355
##    nc_dict['flagLC532'] = flagLC532
##    nc_dict['flagLC1064'] = flagLC1064
#    nc_dict['PollyDataFile'] = dataFilename
#    nc_dict['imgFormat'] = imgFormat
#    nc_dict['colormap_basic'] = colormap_basic
#
#    return nc_dict
#


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
    
#    for v_count,var_name in enumerate(var):
#        for var_att in nc_file_ds.variables[var_name].ncattrs():
#            var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
#            var_attr_dict[f'{var_name}_{var_att}'] = var_att_value

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

#    var_values = {}
#    qual_mask = {}
#    for v_count,var_name in enumerate(var):
#        var_values[var_name] = nc_file_ds[var[v_count]][:]
#        qual_mask[var_name] = np.where(var_values[var_name] > 0, 0, 0)
#        nc_dict[var_name] = nc_file_ds[var[v_count]][:]
#        nc_dict[f'qual_mask_{var_name}'] = np.where(var_values[var_name] > 0, 0, 0)
    method = nc_file_ds[var[0]][:]
    OL_355 = nc_file_ds[var[1]][:]
    OL_355d = nc_file_ds[var[2]][:]
    OL_532 = nc_file_ds[var[3]][:]
    OL_532d = nc_file_ds[var[4]][:]
    height = nc_file_ds['height'][:]
    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(time[0]).strftime("%Y-%m-%d")

    dataFilename = re.split(r'\/',nc_filename)[-1]

    ## fill dictionary for output
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
    nc_dict['m_date'] = m_date
    nc_dict['time'] = time
    nc_dict['height'] = height
    nc_dict['method'] = method
    nc_dict['OL_355'] = OL_355
    nc_dict['OL_355d'] = OL_355d
    nc_dict['OL_532'] = OL_532
    nc_dict['OL_532d'] = OL_532d
    nc_dict['PollyDataFile'] = dataFilename

    return nc_dict


