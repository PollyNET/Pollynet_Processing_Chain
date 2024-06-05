import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, LogNorm
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
from matplotlib.dates import DateFormatter, \
                             DayLocator, HourLocator, MinuteLocator, date2num
#import matplotlib.dates as dates
import os
import re
import sys
import time
import scipy.io as spio
import numpy as np
from datetime import datetime, timedelta, timezone
import matplotlib
from matplotlib.patches import Patch
import json
from pathlib import Path
import argparse
#import pypolly_readout_profiles as readout_profiles
import pypolly_readout as readout
import statistics
import pandas as pd
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



def pollyDisplay_profile(nc_dict_profile,profile_translator,profilename,config_dict,polly_conf_dict,outdir,donefilelist_dict):
    """
    Description
    -----------
    Display the water vapor mixing ratio WVMR from level1 polly nc-file.

    Parameters
    ----------
    nc_dict_profile: dict
        dict wich stores the WV data.

    Usage
    -----
    pollyDisplayWVMR_profile(nc_dict_profile,config_dict,polly_conf_dict)

    History
    -------
    2022-09-01. First edition by Andi
    """

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']

    ## read from global config file
    if profile_translator[profilename]['xlim_name'] != None:
        xLim = polly_conf_dict[profile_translator[profilename]['xlim_name']]
    else:
        xLim = None
    if profile_translator[profilename]['ylim_name'] != None:
        yLim = polly_conf_dict[profile_translator[profilename]['ylim_name']]
    else:
        yLim = None

    partnerLabel = polly_conf_dict['partnerLabel']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc-file
    starttime = nc_dict_profile['start_time']
    endtime = nc_dict_profile['end_time']
    var_ls = [ nc_dict_profile[parameter] for parameter in profile_translator[profilename]['var_name_ls'] ]
#    var_err_ls = [ nc_dict_profile[parameter_err] for parameter_err in profile_translator[profilename]['var_err_name_ls'] ]
    height = nc_dict_profile['height']
#    LCUsed = np.array([nc_dict_profile[f'LCUsed{wavelength}']])

#    flagLC = nc_dict_profile[f'flagLC{wavelength}']
    pollyVersion = nc_dict_profile['PollyVersion']
    location = nc_dict_profile['location']
    version = nc_dict_profile['PicassoVersion']
    if '_NR' in profilename:
        dataFilename = re.split(r'_NR_profiles',nc_dict_profile['PollyDataFile'])[0]
    elif '_OC' in profilename:
        dataFilename = re.split(r'_OC_profiles',nc_dict_profile['PollyDataFile'])[0]
    elif 'POLIPHON' in profilename:
        dataFilename = re.split(r'_POLIPHON',nc_dict_profile['PollyDataFile'])[0]
    else:
        dataFilename = re.split(r'_profiles',nc_dict_profile['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    saveFolder = outdir
    plotfile = f"{dataFilename}_{profile_translator[profilename]['plot_filename']}.{imgFormat}"
    saveFilename = os.path.join(saveFolder,plotfile)

    # display WVMR-profile
    fig = plt.figure(figsize=[6, 9])
    ax = fig.add_axes([0.21, 0.15, 0.74, 0.75])
#    p1, = ax.plot(WVMR_rel_error, height, color='#2492ff', linestyle='-', zorder=2)
#    p1 = ax.plot(WVMR, height, color='#2492ff', linestyle='-', zorder=2)
    fixed_LR = 1
    fixed_LR_ls = []
    for element in range(len(var_ls)):
        if profilename == 'Ext_Klett':
            param = profile_translator[profilename]["var_name_ls"][element]
            fixed_LR = nc_dict_profile[f'{param}___retrieving_info']
            fixed_LR = re.split(r'Fixed lidar ratio:',fixed_LR)[-1]
            fixed_LR = float(re.split(r'\[Sr\]',fixed_LR)[0])
            fixed_LR_ls.append(fixed_LR)
            
        p1 = ax.plot(var_ls[element]*profile_translator[profilename]['scaling_factor']*fixed_LR, height/1000,\
            linestyle=profile_translator[profilename]['var_style_ls'][element],\
            color=profile_translator[profilename]['var_color_ls'][element] ,\
            zorder=2,\
            label=profile_translator[profilename]['var_name_ls'][element])
        #p1 = ax.errorbar(profile_translator[profilename]['var_name_ls'][element], height, xerr=abs(profile_translator[profilename]['var_err_name_ls'][element]), color='#2492ff', linestyle='-', zorder=2)

#    ax.set_xlabel('Water Vapor Mixing Ratio ($g*kg^{-1}$)', fontsize=15)
    ax.set_xlabel(profile_translator[profilename]['x_label'], fontsize=15)
    ax.set_ylabel('Height [km]', fontsize=15)

    if xLim != None:
        ax.set_xlim(xLim)
    if yLim != None:
        ax.set_ylim(yLim[0]/1000,yLim[1]/1000)
    #ax.yaxis.set_major_locator(MultipleLocator(1500))
    #ax.yaxis.set_minor_locator(MultipleLocator(500))
#    ax.set_xlim(xLim_Profi_WV_RH.tolist())
    ax.grid(True)
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

#    starttime = time[startInd - 1]
#    endtime = time[endInd - 1]
    ax.set_title(
        '{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(
            instrument=pollyVersion,
            location=location,
            starttime=datetime.utcfromtimestamp(int(starttime)).strftime('%Y%m%d %H:%M'),
            endtime=datetime.utcfromtimestamp(int(endtime)).strftime('%H:%M'),
#            starttime=starttime.strftime('%Y%m%d %H:%M'),
#            endtime=endtime.strftime('%H:%M')
            ),
        fontsize=14
        )

    plt.legend(loc='upper right')

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        #rootDir = os.getcwd()
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.33, 0.006, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.5, 0.01, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.75, 0.01,
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=7, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

#    fig.text(
#        0.05, 0.02,
#        '{0}'.format(
##            datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
#            args.timestamp),
#            fontsize=12)
    fig.text(
        0.01, 0.01,
        f'Version: {version}\nMethod: {profile_translator[profilename]["method"]}\n{profile_translator[profilename]["misc"]}',fontsize=12)

    list_for_refheight_plots = ['Bsc_Klett','Bsc_Raman','Bsc_RR','Bsc_Klett_NR','Bsc_Raman_NR','Bsc_Klett_OC','Bsc_Raman_OC']
    if profilename in list_for_refheight_plots:
        if 'reference_height_355' in nc_dict_profile.keys():
            refHBase355 = np.nan if nc_dict_profile['reference_height_355'][0] is np.ma.masked else float(nc_dict_profile['reference_height_355'][0]/1000)
            refHTop355 = np.nan if nc_dict_profile['reference_height_355'][1] is np.ma.masked else float(nc_dict_profile['reference_height_355'][1]/1000)
        else:
            refHBase355 = np.nan
            refHTop355 = np.nan
        if 'reference_height_532' in nc_dict_profile.keys():
            refHBase532 = np.nan if nc_dict_profile['reference_height_532'][0] is np.ma.masked else float(nc_dict_profile['reference_height_532'][0]/1000)
            refHTop532 = np.nan if nc_dict_profile['reference_height_532'][1] is np.ma.masked else float(nc_dict_profile['reference_height_532'][1]/1000)
        else:
            refHBase532 = np.nan
            refHTop532 = np.nan
        if 'reference_height_1064' in nc_dict_profile.keys():
            refHBase1064 = np.nan if nc_dict_profile['reference_height_1064'][0] is np.ma.masked else float(nc_dict_profile['reference_height_1064'][0]/1000)
            refHTop1064 = np.nan if nc_dict_profile['reference_height_1064'][1] is np.ma.masked else float(nc_dict_profile['reference_height_1064'][1]/1000)
        else:
            refHBase1064 = np.nan
            refHTop1064 = np.nan
        #print(refHBase355,refHTop355,refHBase532,refHTop532,refHBase1064,refHTop1064)
        fig.text(
            0.32, 0.82,
            f'refH355: {refHBase355:.1f}-{refHTop355:.1f} km\n\
refH532: {refHBase532:.1f}-{refHTop532:.1f} km\n\
refH1064: {refHBase1064:.1f}-{refHTop1064:.1f} km',
            fontsize=11, backgroundcolor=[0.94, 0.95, 0.96, 0.4], alpha=1)

    list_for_eta_klett_plots = ['DepRatio_Klett','DepRatio_Klett_OC']
    list_for_eta_raman_plots = ['DepRatio_Raman','DepRatio_Raman_OC']
    if  profilename in list_for_eta_klett_plots:
        if 'volDepol_klett_355___retrieving_info' in nc_dict_profile.keys():
            try:
                eta355 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_355___retrieving_info'])[-1])
            except:
                eta355 = np.nan
        else:
            eta355 = np.nan
        if 'volDepol_klett_532___retrieving_info' in nc_dict_profile.keys():
            try:
                eta532 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_532___retrieving_info'])[-1])
            except:
                eta532 = np.nan
        else:
            eta532 = np.nan
        if 'volDepol_klett_1064___retrieving_info' in nc_dict_profile.keys():
            try:
                eta1064 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_1064___retrieving_info'])[-1])
            except:
                eta1064 = np.nan
        else:
            eta1064 = np.nan
        fig.text(
            0.32, 0.82,
            r'$\eta_{355}$: '+f'{eta355:.2f}\n'+\
            r'$\eta_{532}$: '+f'{eta532:.2f}\n'+\
            r'$\eta_{1064}$: '+f'{eta1064:.2f}',fontsize=11, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)
    if  profilename in list_for_eta_raman_plots:
        if 'volDepol_raman_355___retrieving_info' in nc_dict_profile.keys():
            try:
                eta355 = float(re.split(r'eta:',nc_dict_profile['volDepol_raman_355___retrieving_info'])[-1])
            except:
                eta355 = np.nan
        else:
            eta355 = np.nan
        if 'volDepol_raman_532___retrieving_info' in nc_dict_profile.keys():
            try:
                eta532 = float(re.split(r'eta:',nc_dict_profile['volDepol_raman_532___retrieving_info'])[-1])
            except:
                eta532 = np.nan
        else:
            eta532 = np.nan
        if 'volDepol_raman_1064___retrieving_info' in nc_dict_profile.keys():
            try:
                eta1064 = float(re.split(r'eta:',nc_dict_profile['volDepol_raman_1064___retrieving_info'])[-1])
            except:
                eta1064 = np.nan
        else:
            eta1064 = np.nan
        fig.text(
            0.32, 0.82,
            r'$\eta_{355}$: '+f'{eta355:.2f}\n'+\
            r'$\eta_{532}$: '+f'{eta532:.2f}\n'+\
            r'$\eta_{1064}$: '+f'{eta1064:.2f}',fontsize=11, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)

    if profilename == 'Ext_Klett':
        fig.text(
            0.32, 0.82,
            r'LR$_{355}$: '+f'{fixed_LR_ls[0]:.2f}\n'+\
            r'LR$_{532}$: '+f'{fixed_LR_ls[1]:.2f}\n'+\
            r'LR$_{1064}$: '+f'{fixed_LR_ls[2]:.2f}',fontsize=11, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    if profile_translator[profilename]['product_type'] != '':
        readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                        lidar = pollyVersion,
                                        location = nc_dict_profile['location'],
                                        starttime = datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                        stoptime = datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%Y%m%d %H:%M:%S'),
                                        last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                        wavelength = 355,
                                        filename = saveFilename,
                                        level = 0,
                                        info = f"profile from {profile_translator[profilename]['product_type']}",
                                        nc_zip_file = nc_dict_profile['PollyDataFile'],
                                        nc_zip_file_size = 9000000,
                                        active = 1,
                                        GDAS = 0,
                                        GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d')} 12:00:00",
                                        lidar_ratio = 50,
                                        software_version = version,
                                        product_type = profile_translator[profilename]['product_type'],
                                        product_starttime = datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                        product_stoptime = datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%Y%m%d %H:%M:%S')
                                        )
    
def pollyDisplay_calibration_constants(nc_dict,dataframe,profile_calib_translator,profilename,config_dict,polly_conf_dict,outdir,donefilelist_dict):
    """
    Description
    -----------
    Display the calibration constans, such as LC.calib, WV.calib, Depol.calib. from sqlite3.db-file.

    Parameters
    ----------
    nc_dict: dict
        dict wich stores the WV data.

    Usage
    -----
    pollyDisplayWVMR_profile(nc_dict,config_dict,polly_conf_dict)

    History
    -------
    2022-09-01. First edition by Andi
    """

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']

    ## read from global config file
    if profile_calib_translator[profilename]['xlim_name'] != None:
        xLim = polly_conf_dict[profile_calib_translator[profilename]['xlim_name']]
    else:
        xLim = None
    if profile_calib_translator[profilename]['ylim_name'] != None:
        yLim = polly_conf_dict[profile_calib_translator[profilename]['ylim_name']]
    else:
        yLim = None

    partnerLabel = polly_conf_dict['partnerLabel']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc-file
#    starttime = nc_dict_profile['start_time']
#    endtime = nc_dict_profile['end_time']
    methods_orig = list(dataframe['cali_method'])
    # Remove duplicates while preserving order using list comprehension
    seen = set()
    methods = [item for item in methods_orig if item not in seen and not seen.add(item)]

    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    saveFolder = outdir
    dataFilename = re.split(r'_overlap',nc_dict['PollyDataFile'])[0]
    plotfile = f"{dataFilename}_{profile_calib_translator[profilename]['plot_filename']}.{imgFormat}"
    saveFilename = os.path.join(saveFolder,plotfile)

    fig = plt.figure(figsize=[12, 6])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])

    for element,method in enumerate(methods):
        filtered_df = dataframe[dataframe['cali_method'].str.contains(method, na=False)]

        p1 = ax.scatter(pd.to_datetime(filtered_df['cali_start_time']),filtered_df['liconst'],\
            marker=profile_calib_translator[profilename]['var_style_ls'][element],\
            color=profile_calib_translator[profilename]['var_color_ls'][element] ,\
            zorder=2,\
            label=method)
#        p2 = ax.plot(pd.to_datetime(filtered_df['cali_start_time']),filtered_df['liconst'],\
#            linestyle='--',\
#            color=profile_calib_translator[profilename]['var_color_ls'][element] ,\
#            zorder=2)
    date_00 = datetime.strptime(nc_dict['m_date'], '%Y-%m-%d')
    date_00 = date_00.timestamp()
    x_lims = list(map(datetime.fromtimestamp, [date_00, date_00+24*60*60]))
    x_lims = date2num(x_lims)
    ax.set_xlim(x_lims[0],x_lims[-1])

    ax.set_xlabel(profile_calib_translator[profilename]['x_label'], fontsize=15)
    ax.set_ylabel(profile_calib_translator[profilename]['y_label'], fontsize=15)

    ax.xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
    ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))

    ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))

    ax.grid(True)
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        '{profilename} {instrument} at {location}'.format(
            profilename=profilename,
            instrument=pollyVersion,
            location=location
            ),
        fontsize=14
        )

    plt.legend(loc='upper right')

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.58, 0.006, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.72, 0.003, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.84, 0.003,
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=7, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

        fig.text(
            0.2, 0.02,
            f'{nc_dict["m_date"]}\nVersion: {version}',fontsize=12)
    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['end_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = list(dataframe['wavelength'])[0],
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"Lidar calibration constant from {profile_calib_translator[profilename]['product_type']}",
                                    nc_zip_file = polly_conf_dict['calibrationDB'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = profile_calib_translator[profilename]['product_type'],
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['end_time'])).strftime('%Y%m%d %H:%M:%S')
                                    )
    
    
def pollyDisplay_longtermcalibration(nc_dict,logbook_dataframe,sql_dataframe,profile_calib_translator,profilename,config_dict,polly_conf_dict,outdir,donefilelist_dict):
    """
    Description
    -----------
    Display the calibration constans, such as LC.calib, WV.calib, Depol.calib. from sqlite3.db-file.

    Parameters
    ----------
    nc_dict: dict
        dict wich stores the WV data.

    Usage
    -----
    pollyDisplayWVMR_profile(nc_dict,config_dict,polly_conf_dict)

    History
    -------
    2022-09-01. First edition by Andi
    """

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']

#    ## read from global config file
#    if profile_calib_translator[profilename]['xlim_name'] != None:
#        xLim = polly_conf_dict[profile_calib_translator[profilename]['xlim_name']]
#    else:
#        xLim = None
#    if profile_calib_translator[profilename]['ylim_name'] != None:
#        yLim = polly_conf_dict[profile_calib_translator[profilename]['ylim_name']]
#    else:
#        yLim = None

    partnerLabel = polly_conf_dict['partnerLabel']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc-file
#    starttime = nc_dict_profile['start_time']
#    endtime = nc_dict_profile['end_time']
#    methods_orig = list(dataframe['cali_method'])
    # Remove duplicates while preserving order using list comprehension
#    seen = set()
#    methods = [item for item in methods_orig if item not in seen and not seen.add(item)]

    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    saveFolder = outdir
#    dataFilename = re.split(r'_overlap',nc_dict['PollyDataFile'])[0]
    YYYY = nc_dict['m_date'][0:4]
    MM = nc_dict['m_date'][5:7]
    DD = nc_dict['m_date'][8:10]
    newdate = f'{YYYY}{MM}{DD}'
    plotfile = f"{pollyVersion}_{newdate}_long_term_cali_results.{imgFormat}"
    saveFilename = os.path.join(saveFolder,plotfile)

    today = datetime.now()
    # Calculate the date 6 months ago
    six_months_ago = today - timedelta(days=6*30)  # Roughly 6 months

    filtered_sql_df={}
    for w in sql_dataframe.keys():
        sql_dataframe[w]['cali_start_time'] = pd.to_datetime(sql_dataframe[w]['cali_start_time'])
        filtered_sql_df[w] = sql_dataframe[w][(sql_dataframe[w]['cali_start_time'] >= six_months_ago) & (sql_dataframe[w]['cali_start_time'] <= today)]

    filtered_logbook_df = logbook_dataframe[(logbook_dataframe['time'] >= six_months_ago) & (logbook_dataframe['time'] <= today)]
#    filtered_sql_df = sql_dataframe[(sql_dataframe['cali_start_time'] >= six_months_ago) & (sql_dataframe['cali_start_time'] <= today)]

    changes = ['overlap','pulsepower','restarted','windowwipe','flashlamps']
    color_map = {
        'overlap': 'orange',
        'pulsepower': 'cyan',
        'restarted': 'green',
        'windowwipe': 'magenta',
        'flashlamps': 'red',
        'NDfilters': 'black'
    }

    #fig = plt.figure(figsize=[12, 6])
    fig, ax = plt.subplots(nrows=3, ncols=1, figsize=(12, 18))
    #ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    for n,w in enumerate(sql_dataframe.keys()):
        for index, row in filtered_logbook_df.iterrows():
            for change in changes:
                if change in row['changes']:
                    color = color_map.get(change)
                    ax[n].axvline(x=row['time'], color=color, linestyle='-', linewidth=2)
            if len(row['ndfilters']) > 2:
                ax[n].axvline(x=row['time'], color='black', linestyle='-', linewidth=2)
    
        p2 = ax[n].scatter(filtered_sql_df[w]['cali_start_time'],filtered_sql_df[w]['liconst'],\
            marker='o',\
            color='blue',\
            zorder=2)

        ax[n].set_xlim([six_months_ago, today])
        ax[n].set_ylabel(w, fontsize=15)

    legend_elements = [ Patch(facecolor=color_map[change],label=change) for change in color_map.keys() ]
    legend_elements.append(Patch(facecolor='blue',label='LC'))
    plt.legend(handles=legend_elements, title='legend', loc='upper right')

    ax[-1].set_xlabel('Date', fontsize=15)
    fig.suptitle(f'Longterm monitoring of Lidar Calibration Constants and {pollyVersion} logbook', fontsize=16, fontweight='bold', y=0.9)



#    ax.xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
#    ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))

#    ax[-1].xaxis.set_major_formatter(DateFormatter('%m-%d'))

    #ax.grid(True)
    #ax.tick_params(axis='both', which='major', labelsize=15,
    #               right=True, top=True, width=2, length=5)
    #ax.tick_params(axis='both', which='minor', width=1.5,
    #               length=3.5, right=True, top=True)

    #fig.set_title(f'long term monitoring for {pollyVersion} at {location}',fontsize=14)


    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.58, 0.006, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.72, 0.003, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.84, 0.003,
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=7, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

        fig.text(
            0.2, 0.02,
            f'{nc_dict["m_date"][0:4]}\nVersion: {version}',fontsize=12)

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

#    ## write2donefilelist
#    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
#                                    lidar = pollyVersion,
#                                    location = nc_dict['location'],
#                                    starttime = datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d %H:%M:%S'),
#                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['end_time'])).strftime('%Y%m%d %H:%M:%S'),
#                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
#                                    wavelength = list(dataframe['wavelength'])[0],
#                                    filename = saveFilename,
#                                    level = 0,
#                                    info = f"Lidar calibration constant from {profile_calib_translator[profilename]['product_type']}",
#                                    nc_zip_file = polly_conf_dict['calibrationDB'],
#                                    nc_zip_file_size = 9000000,
#                                    active = 1,
#                                    GDAS = 0,
#                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d')} 12:00:00",
#                                    lidar_ratio = 50,
#                                    software_version = version,
#                                    product_type = profile_calib_translator[profilename]['product_type'],
#                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d %H:%M:%S'),
#                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['end_time'])).strftime('%Y%m%d %H:%M:%S')
#                                    )
    

