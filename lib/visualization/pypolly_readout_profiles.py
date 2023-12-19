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

# load colormap
dirname = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(dirname)
try:
    from python_colormap import *
except Exception as e:
    raise ImportError('python_colormap module is necessary.')

# generating figure without X server
plt.switch_backend('Agg')


def read_nc_profile(nc_filename):
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

#    ## get variable attributes from nc-file
#    var_attr_WVMR = {}
#    var_attr_WVMR_rel_error = {}
#    var = ["WVMR", "WVMR_rel_error"]
#    for var_att in nc_file_ds.variables[var[0]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[0]].getncattr(var_att)
#        var_attr_WVMR[var_att] = var_att_value
#    for var_att in nc_file_ds.variables[var[1]].ncattrs():
#        var_att_value = nc_file_ds.variables[var[1]].getncattr(var_att)
#        var_attr_WVMR_rel_error[var_att] = var_att_value

#    WVMR = nc_file_ds[var[0]][:]
#    WVMR_rel_error = nc_file_ds[var[1]][:]

    var_ls = []
    for var in nc_file_ds.variables:
        var_ls.append(var)

    ## get variable attributes from nc-file
    var_attr_dict = {}
    for v_count,var_name in enumerate(var_ls):
        for var_att in nc_file_ds.variables[var_name].ncattrs():
            var_att_value = nc_file_ds.variables[var_name].getncattr(var_att)
            var_attr_dict[f'{var_name}_{var_att}'] = var_att_value


    ## fill dict with variable-values
    for v_count,var_name in enumerate(var_ls):
        nc_dict[var_name] = nc_file_ds[var_name][:]


    PollyVersion = global_attr['source']
    location = global_attr['location']
    version = global_attr['version']

    start_time = nc_file_ds['start_time'][:]
    end_time = nc_file_ds['end_time'][:]
                    
    height = nc_file_ds['height'][:]
#    time = nc_file_ds['time'][:]
    m_date = datetime.fromtimestamp(start_time[0]).strftime("%Y-%m-%d")
    dataFilename = re.split(r'\/',nc_filename)[-1]
   
    ## fill dictionary for output
    nc_dict['m_date'] = m_date
    nc_dict['start_time'] = start_time
    nc_dict['end_time'] = end_time
    nc_dict['height'] = height
    nc_dict['PollyVersion'] = PollyVersion
    nc_dict['location'] = location
    nc_dict['PicassoVersion'] = version
#    nc_dict['WVMR'] = WVMR
#    nc_dict['WVMR_rel_error'] =WVMR_rel_error
    nc_dict['PollyDataFile'] = dataFilename
    print(nc_dict)
    return nc_dict



