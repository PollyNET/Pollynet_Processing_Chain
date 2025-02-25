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
import matplotlib.colors as colors
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

    if not nc_dict_profile :
        return

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
    filtered_sql_df = dataframe[dataframe['cali_start_time'].dt.date == pd.to_datetime(nc_dict['m_date']).date()]
    methods_orig = list(filtered_sql_df['cali_method'])
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
        filtered_df = filtered_sql_df[filtered_sql_df['cali_method'].str.contains(method, na=False)]
#        print(filtered_df[['cali_start_time','cali_stop_time','liconst','wavelength','cali_method','telescope']])

        p1 = ax.scatter(filtered_df['cali_start_time'],filtered_df['liconst'],\
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
    
    
def pollyDisplay_longtermcalibration(nc_dict,logbook_dataframe,LC_sql_dataframe,ETA_sql_dataframe,profile_calib_translator,profilename,config_dict,polly_conf_dict,outdir,donefilelist_dict):
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

    mdate = datetime.strptime(nc_dict['m_date'], '%Y-%m-%d')
    # Calculate the date 6 months ago
    six_months_ago = mdate - timedelta(days=6*30)  # Roughly 6 months

    filtered_LC_sql_df={}
    filtered_ETA_sql_df={}
    for w in LC_sql_dataframe.keys():
        filtered_LC_sql_df[w] = LC_sql_dataframe[w][(LC_sql_dataframe[w]['cali_start_time'] >= six_months_ago) & (LC_sql_dataframe[w]['cali_start_time'] <= mdate)]
    for w in ETA_sql_dataframe.keys():
        filtered_ETA_sql_df[w] = ETA_sql_dataframe[w][(ETA_sql_dataframe[w]['cali_start_time'] >= six_months_ago) & (ETA_sql_dataframe[w]['cali_start_time'] <= mdate)]

    filtered_logbook_df = logbook_dataframe[(logbook_dataframe['time'] >= six_months_ago) & (logbook_dataframe['time'] <= mdate)]
#    filtered_LC_sql_df = LC_sql_dataframe[(LC_sql_dataframe['cali_start_time'] >= six_months_ago) & (LC_sql_dataframe['cali_start_time'] <= mdate)]

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
    fig, ax = plt.subplots(nrows=6, ncols=1, figsize=(12, 18))
    #ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    for n,w in enumerate(LC_sql_dataframe.keys()):
        for index, row in filtered_logbook_df.iterrows():
            for change in changes:
                if change in row['changes']:
                    color = color_map.get(change)
                    ax[n].axvline(x=row['time'], color=color, linestyle='-', linewidth=2)
            if len(row['ndfilters']) > 2:
                ax[n].axvline(x=row['time'], color='black', linestyle='-', linewidth=2)
    
        p2 = ax[n].scatter(filtered_LC_sql_df[w]['cali_start_time'],filtered_LC_sql_df[w]['liconst'],\
            marker='o',\
            color='blue',\
            s=2,\
            zorder=2)

        ax[n].set_xlim([six_months_ago, mdate])
        ax[n].set_ylabel(w, fontsize=15)

    for n,w in enumerate(ETA_sql_dataframe.keys()):
        for index, row in filtered_logbook_df.iterrows():
            for change in changes:
                if change in row['changes']:
                    color = color_map.get(change)
                    ax[3+n].axvline(x=row['time'], color=color, linestyle='-', linewidth=2)
            if len(row['ndfilters']) > 2:
                ax[3+n].axvline(x=row['time'], color='black', linestyle='-', linewidth=2)
    
        p2 = ax[3+n].scatter(filtered_ETA_sql_df[w]['cali_start_time'],filtered_ETA_sql_df[w]['depol_const'],\
            marker='o',\
            color='blue',\
            s=2,\
            zorder=2)

        ax[3+n].set_xlim([six_months_ago, mdate])
        ax[3+n].set_ylabel(w, fontsize=15)

    legend_elements = [ Patch(facecolor=color_map[change],label=change) for change in color_map.keys() ]
#    legend_elements.append(Patch(facecolor='blue',label='LC'))
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
            f'Version: {version}',fontsize=12)

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = six_months_ago.strftime("%Y%m%d %H:%M:%S"),
                                    stoptime = mdate.strftime("%Y%m%d %H:%M:%S"),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = 355,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"LC and logbook entries",
                                    nc_zip_file = polly_conf_dict['calibrationDB'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = 'long_term_monitor',
                                    product_starttime = six_months_ago.strftime("%Y%m%d %H:%M:%S"), 
                                    product_stoptime = mdate.strftime("%Y%m%d %H:%M:%S")
                                    )


def pollyDisplay_HKD(laserlogbook_df,nc_dict,config_dict,polly_conf_dict,outdir,donefilelist_dict):
#def pollyDisplay_calibration_constants(nc_dict,dataframe,profile_calib_translator,profilename,config_dict,polly_conf_dict,outdir,donefilelist_dict):
    """
    Description
    -----------
    Display the HouseKeepingData from the laserlogbook file.

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
    if laserlogbook_df.empty:
        return None
    else:    
        pass

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']


    partnerLabel = polly_conf_dict['partnerLabel']
    imgFormat = polly_conf_dict['imgFormat']


    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    saveFolder = outdir
    dataFilename = re.split(r'_overlap',nc_dict['PollyDataFile'])[0]
    plotfile = f"{dataFilename}_monitor.{imgFormat}"
    saveFilename = os.path.join(saveFolder,plotfile)
    ## filter out wrong values
    laserlogbook_df['ExtPyro'] = laserlogbook_df['ExtPyro'].mask(laserlogbook_df['ExtPyro'] < 0, np.nan)
    laserlogbook_df['TEMPERATURE'] = laserlogbook_df['TEMPERATURE'].mask(laserlogbook_df['TEMPERATURE'] < -80, np.nan)
    laserlogbook_df['Temp1'] = laserlogbook_df['Temp1'].mask(laserlogbook_df['Temp1'] < -80, np.nan)
    laserlogbook_df['Temp2'] = laserlogbook_df['Temp2'].mask(laserlogbook_df['Temp2'] < -80, np.nan)
    laserlogbook_df['OutsideT'] = laserlogbook_df['OutsideT'].mask(laserlogbook_df['OutsideT'] < -80, np.nan)
    laserlogbook_df['Temp1064'] = laserlogbook_df['Temp1064'].mask(laserlogbook_df['Temp1064'] < -120, np.nan)

    nrows = 5
    fig, ax = plt.subplots(nrows=nrows, ncols=1, figsize=(12, 18))

    for r in range(0,nrows):
        ax[r].set_xticklabels([])

    ax[0].plot(laserlogbook_df['TIMESTAMP'], laserlogbook_df['ENERGY_VALUE_1'], linestyle='-', color='cornflowerblue')
    ax[0].set_ylabel('Energy [mJ]', fontsize=15)

    ax[1].plot(laserlogbook_df['TIMESTAMP'], laserlogbook_df['ExtPyro'], linestyle='-', color='purple')
    ax[1].set_ylabel('ExtPyro [mJ]', fontsize=15)

    ax[2].plot(laserlogbook_df['TIMESTAMP'], laserlogbook_df['TEMPERATURE'], linestyle='-', color='cyan',label='TEMPERATURE')
    ax[2].plot(laserlogbook_df['TIMESTAMP'], laserlogbook_df['Temp1'], linestyle='-', color='orange',label='Temp1')
    ax[2].plot(laserlogbook_df['TIMESTAMP'], laserlogbook_df['Temp2'], linestyle='-', color='green',label='Temp2')
    ax[2].plot(laserlogbook_df['TIMESTAMP'], laserlogbook_df['OutsideT'], linestyle='-', color='violet',label='OutsideT')
    ax[2].legend(loc='upper right')
    ax[2].set_ylabel('Temperature [°C]', fontsize=15)

    ax[3].plot(laserlogbook_df['TIMESTAMP'], laserlogbook_df['Temp1064'], linestyle='-', color='firebrick')
    ax[3].set_ylabel('Temp1064 [°C]', fontsize=15)

    date_00 = datetime.strptime(nc_dict['m_date'], '%Y-%m-%d')
    date_00 = date_00.timestamp()
    x_lims = list(map(datetime.fromtimestamp, [date_00, date_00+24*60*60]))
    x_lims = date2num(x_lims)
    ax[-1].set_xlim(x_lims[0],x_lims[-1])

    laserlogbook_df['rain'] = laserlogbook_df['rain'].astype(int)
    laserlogbook_df['roof'] = laserlogbook_df['roof'].astype(int)
    laserlogbook_df['shutter'] = laserlogbook_df['shutter'].astype(int)
    states_params = ['rain','roof','shutter']
    state_colormap = ['navajowhite', 'coral', 'skyblue', 'm', 'mediumaquamarine']
    cmap = colors.ListedColormap(state_colormap)
    matrix = laserlogbook_df[states_params].values

    pcmesh = ax[4].pcolormesh(
            laserlogbook_df['TIMESTAMP'], np.arange(len(states_params)) +0.5, matrix.T,
            cmap=cmap, vmin=-0.5, vmax=4.5,shading='nearest')
    cb_ax = fig.add_axes([0.84, 0.08, 0.12, 0.016])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[
                            0, 1, 2, 3, 4], orientation='horizontal')
    cbar.ax.tick_params(labeltop=True, direction='in', labelbottom=False,
                            bottom=False, top=True, labelsize=12, pad=0.00)
    ax[4].set_yticks([0.5, 1.5, 2.5])
    [ax[4].axhline(p, color='white', linewidth=3) for p in np.arange(0, len(states_params))]

    #ax[4].set_yticks(list(range(0,len(states_params))))
    select_label_list = states_params
    ax[4].set_yticklabels(select_label_list)
    for tick in ax[4].get_yticklabels():
        tick.set_verticalalignment("bottom")

    ax[-1].set_xlabel('Time [UTC]', fontsize=15)

    ax[-1].xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
    ax[-1].xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))

    ax[-1].xaxis.set_major_formatter(DateFormatter('%H:%M'))


    fig.suptitle(f'Laserlogbook monitoring of {pollyVersion} at {location}', fontsize=16, fontweight='bold', y=0.9)


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
                                    wavelength = 355,
                                    filename = saveFilename,
                                    level = 0,
                                    info = "data based on laserlogbook.",
                                    nc_zip_file = polly_conf_dict['calibrationDB'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = 'monitor',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['end_time'])).strftime('%Y%m%d %H:%M:%S')
                                    )


def pollyDisplay_profile_summary(nc_dict_profile,nc_dict_profile_NR,config_dict,polly_conf_dict,outdir,method,ymax,donefilelist_dict):
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

    if not nc_dict_profile :
        return

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']


    partnerLabel = polly_conf_dict['partnerLabel']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc-file
    starttime = nc_dict_profile['start_time']
    endtime = nc_dict_profile['end_time']
#    var_err_ls = [ nc_dict_profile[parameter_err] for parameter_err in profile_translator[profilename]['var_err_name_ls'] ]
    height_FR = nc_dict_profile['height']
#    LCUsed = np.array([nc_dict_profile[f'LCUsed{wavelength}']])

#    flagLC = nc_dict_profile[f'flagLC{wavelength}']
    pollyVersion = nc_dict_profile['PollyVersion']
    location = nc_dict_profile['location']
    version = nc_dict_profile['PicassoVersion']
    dataFilename = re.split(r'_profiles',nc_dict_profile['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"


    if ymax == 'high_range':
        y_max_FR = polly_conf_dict['yLim_all_profiles_high_range']
        ymax_prod_type = ymax
        xmax_depol = [0,0.6]
    elif ymax == 'low_range':
        y_max_FR = polly_conf_dict['yLim_all_profiles_low_range']
        ymax_prod_type = ymax
        xmax_depol = polly_conf_dict['zLim_VolDepol_1064']
    else:
        y_max_FR = polly_conf_dict['yLim_all_profiles_high_range']
        ymax_prod_type = 'high_range'
        xmax_depol = [0,0.6]

    plotfile = f"{dataFilename}_profile_summary_{method}_{ymax_prod_type}.{imgFormat}"
    saveFolder = outdir
    saveFilename = os.path.join(saveFolder,plotfile)

    y_max_NR = 5000
    cols = 6
    if len(nc_dict_profile_NR) > 0:
        height_NR = nc_dict_profile_NR['height']
        h_index = np.where(height_NR > 5000)[0][0]
        height_NR_shortened = height_NR[0:h_index]

        if method == 'raman':
        
            param_dict = {
                          "backscatter":
                                        {"FR": ['aerBsc_raman_355','aerBsc_raman_532','aerBsc_raman_1064'],
                                         "NR":['aerBsc_raman_355','aerBsc_raman_532']
                                        },
                          "extinction": {"FR": ['aerExt_raman_355','aerExt_raman_532','aerExt_raman_1064'],
                                         "NR": ['aerExt_raman_355','aerExt_raman_532']
                                        },
                          "lidarratio": {"FR": ['aerLR_raman_355','aerLR_raman_532','aerLR_raman_1064'],
                                         "NR": ['aerLR_raman_355','aerLR_raman_532']
                                        },
                          "angstroem": {"FR": ['AE_beta_355_532_Raman','AE_beta_532_1064_Raman','AE_parExt_355_532_Raman'],
                                        "NR": []
                                       },
                          "depolarization": {"FR": ['parDepol_raman_355','parDepol_raman_532','parDepol_raman_1064'],
                                             "NR": []
                                            },
                          "wvmr": {"FR": ['WVMR'],
                                   "NR": []
                                  }
            }

        elif method == 'klett':

            param_dict = {
                          "backscatter":
                                        {"FR": ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064'],
                                         "NR":['aerBsc_klett_355','aerBsc_klett_532']
                                        },
                          "extinction": {"FR": ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064'],
                                         "NR": []
                                        },
                          "lidarratio": {"FR": [],
                                         "NR": []
                                        },
                          "angstroem": {"FR": [],
                                        "NR": []
                                       },
                          "depolarization": {"FR": ['parDepol_klett_355','parDepol_klett_532','parDepol_klett_1064'],
                                             "NR": []
                                            },
                          "wvmr": {"FR": ['WVMR'],
                                   "NR": []
                                  }
            }
    else:

        if method == 'raman':
            param_dict = {
                          "backscatter":
                                        {"FR": ['aerBsc_raman_355','aerBsc_raman_532','aerBsc_raman_1064'],
                                         "NR": []
                                        },
                          "extinction": {"FR": ['aerExt_raman_355','aerExt_raman_532','aerExt_raman_1064'],
                                         "NR": []
                                        },
                          "lidarratio": {"FR": ['aerLR_raman_355','aerLR_raman_532','aerLR_raman_1064'],
                                         "NR": []
                                        },
                          "angstroem": {"FR": ['AE_beta_355_532_Raman','AE_beta_532_1064_Raman','AE_parExt_355_532_Raman'],
                                        "NR": []
                                       },
                          "depolarization": {"FR": ['parDepol_raman_355','parDepol_raman_532','parDepol_raman_1064'],
                                             "NR": []
                                            },
                          "wvmr": {"FR": ['WVMR','RH'],
                                   "NR": []
                                  }
            }

        elif method == 'klett':
            param_dict = {
                          "backscatter":
                                        {"FR": ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064'],
                                         "NR": []
                                        },
                          "extinction": {"FR": ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064'],
                                         "NR": []
                                        },
                          "lidarratio": {"FR": [],
                                         "NR": []
                                        },
                          "angstroem": {"FR": [],
                                        "NR": []
                                       },
                          "depolarization": {"FR": ['parDepol_klett_355','parDepol_klett_532','parDepol_klett_1064'],
                                             "NR": []
                                            },
                          "wvmr": {"FR": ['WVMR','RH'],
                                   "NR": []
                                  }
            }

    fixed_LR = 1
    fixed_LR_ls = []
    def plotting_procedure(col,param_dict,parameter,xlabel,xlim=[0,1],ylim=[0,1],scaling_factor=1):

        ax[col].set_xlabel(xlabel, fontsize=axes_fontsize)
        ax[col].grid(True)
        ax[col].tick_params(axis='both', which='major', labelsize=15,
                       right=True, top=True, width=2, length=5)
        ax[col].tick_params(axis='both', which='minor', width=1.5,
                       length=3.5, right=True, top=True)

        for n,p in enumerate(param_dict[parameter]["FR"]):
            if p == None:
                continue
            label=f'{p}_FR'
            if parameter == 'angstroem':
                    color_ls = ['orange','magenta','black']
            else:
                    color_ls = ['blue','green','red']

            line_style = '-'

            if parameter == 'wvmr':
#                ax2 = ax[col].secondary_xaxis('top')
                ax2 = ax[col].twiny()
                ax2.set_xlabel('Rel.Humidity [%]', fontsize=axes_fontsize)
                ax2.set_xlim(0,100)
                ax2.tick_params(axis='both', which='major', labelsize=15,
                       right=True, top=True, width=2, length=5)
                ax2.tick_params(axis='both', which='minor', width=1.5,
                       length=3.5, right=True, top=True)
                p_FR = ax[col].plot(nc_dict_profile['WVMR']*scaling_factor, height_FR/1000,\
                    linestyle=line_style,\
                    color=color_ls[n],\
                    zorder=2,\
                    alpha=1,\
                    label='WVMR')
                p_RH = ax2.plot(nc_dict_profile['RH']*scaling_factor, height_FR/1000,\
                    linestyle=line_style,\
                    #color=color_ls[n],\
                    color='green',
                    zorder=2,\
                    alpha=1,\
                    label='RH')
                ax2.legend(fontsize=14, loc='upper right', bbox_to_anchor=(0.9, 0.95))
            else:
                if parameter == 'extinction' and method == 'klett':
                    label = f'{p} x LR'
                    try:
                        fixed_LR = nc_dict_profile[f'{p}___retrieving_info']
                        fixed_LR = re.split(r'Fixed lidar ratio:',fixed_LR)[-1]
                        fixed_LR = float(re.split(r'\[Sr\]',fixed_LR)[0])
                        fixed_LR_ls.append(fixed_LR)
                    except:
                         fixed_LR = 50
                else:
                    fixed_LR = 1
                p_FR = ax[col].plot(nc_dict_profile[p]*scaling_factor*fixed_LR, height_FR/1000,\
                    linestyle=line_style,\
                    color=color_ls[n],\
                    zorder=2,\
                    label=label)


        for n,p in enumerate(param_dict[parameter]["NR"]):
            if p == None:
                continue
            color_ls = ['cyan','lime']

            line_style = '-'
            nc_dict_profile_NR_shortened = nc_dict_profile_NR[p][0:h_index]
            label = f'{p}_NR'
            p_NR = ax[col].plot(nc_dict_profile_NR_shortened*scaling_factor, height_NR_shortened/1000,\
                linestyle=line_style,\
                color=color_ls[n],\
                zorder=1,\
                alpha=0.5,\
                label=label)
        ax[col].set_xlim(xlim[0],xlim[1])
        ax[col].set_ylim(ylim[0],ylim[1]/1000)
        ax[col].legend(loc='upper right',fontsize=14)
    
    fig, ax = plt.subplots(1,cols, figsize=(25, 17))


    axes_fontsize = 18


    ## ref.Height
    if np.any(nc_dict_profile['reference_height_355'].mask):
        refH355_0 = np.nan
        refH355_1 = np.nan
    else:
        refH355_0 = nc_dict_profile['reference_height_355'][0]/1000
        refH355_1 = nc_dict_profile['reference_height_355'][1]/1000
    if np.any(nc_dict_profile['reference_height_532'].mask):
        refH532_0 = np.nan
        refH532_1 = np.nan
    else:
        refH532_0 = nc_dict_profile['reference_height_532'][0]/1000
        refH532_1 = nc_dict_profile['reference_height_532'][1]/1000
    if np.any(nc_dict_profile['reference_height_1064'].mask):
        refH1064_0 = np.nan
        refH1064_1 = np.nan
    else:
        refH1064_0 = nc_dict_profile['reference_height_1064'][0]/1000
        refH1064_1 = nc_dict_profile['reference_height_1064'][1]/1000
    fig.text(
        0.1, 0.02,
        'ref.H_355: '+f'{refH355_0:.2f}-{refH355_1:.2f} km\n'+\
        'ref.H_532: '+f'{refH532_0:.2f}-{refH532_1:.2f} km\n'+\
        'ref.H_1064: '+f'{refH1064_0:.2f}-{refH1064_1:.2f} km',fontsize=14, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)

    ## eta
    try:
        eta355 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_355___retrieving_info'])[-1])
    except:
        eta355 = np.nan
    try:
        eta532 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_532___retrieving_info'])[-1])
    except:
        eta532 = np.nan
    try:
        eta1064 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_1064___retrieving_info'])[-1])
    except:
        eta1064 = np.nan
    ax[4].text(
        0.2, 0.8,
        r'$\eta_{355}$: '+f'{eta355:.2f}\n'+\
        r'$\eta_{532}$: '+f'{eta532:.2f}\n'+\
        r'$\eta_{1064}$: '+f'{eta1064:.2f}',fontsize=14, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1,transform=ax[4].transAxes)

    ## water-vapor calib-constant
    try:
        wv_calib = float(nc_dict_profile['WVMR___wv_calibration_constant_used'])
    except:
        wv_calib  = np.nan
    fig.text(
        0.85, 0.05,
        f'WV-calib.const.: {wv_calib:.1f}',fontsize=14, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)



    plotting_procedure(col=0,param_dict=param_dict,parameter="backscatter",xlabel="Backsc. coeff. [Msr$^{-1}$ m$^{-1}$]",xlim = polly_conf_dict['xLim_Profi_Bsc'],ylim=y_max_FR,scaling_factor=10**6)
    
    plotting_procedure(col=1,param_dict=param_dict,parameter="extinction",xlabel="Extinct. coeff. [Mm$^{-1}$]",xlim = polly_conf_dict['xLim_Profi_Ext'],ylim=y_max_FR,scaling_factor=10**6)
    
    plotting_procedure(col=2,param_dict=param_dict,parameter="lidarratio",xlabel="Lidar ratio [Sr]",xlim = polly_conf_dict['xLim_Profi_LR'],ylim=y_max_FR)
    
    plotting_procedure(col=3,param_dict=param_dict,parameter="angstroem",xlabel="$\AA$ngström Exp.",xlim = polly_conf_dict['xLim_Profi_AE'],ylim=y_max_FR)

    plotting_procedure(col=4,param_dict=param_dict,parameter="depolarization",xlabel="Depol. ratio",xlim = xmax_depol,ylim=y_max_FR)
    plotting_procedure(col=5,param_dict=param_dict,parameter="wvmr",xlabel="WVMR [$g*kg^{-1}$]",xlim = polly_conf_dict['xLim_Profi_WVMR'],ylim=y_max_FR)
    
    ## Ext.Klett (with fixed LidarRatio)
    if method == 'klett' and len(fixed_LR_ls) > 0:
        ax[1].text(
            0.6, 0.85,
            r'LR$_{355}$: '+f'{fixed_LR_ls[0]:.2f}\n'+\
            r'LR$_{532}$: '+f'{fixed_LR_ls[1]:.2f}\n'+\
            r'LR$_{1064}$: '+f'{fixed_LR_ls[2]:.2f}',fontsize=11, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1,transform=ax[1].transAxes)


    plt.tight_layout(rect=[0.05, 0.07, 0.98, 0.95])
        
    ax[0].set_ylabel("Height [km]",fontsize=18)

    method_upper = str(method).capitalize()
    fig.suptitle(
        'Summary of {method_upper} profile plots for {instrument} at {location} {starttime}-{endtime}'.format(
            method_upper=method_upper,
            instrument=pollyVersion,
            location=location,
            starttime=datetime.utcfromtimestamp(int(starttime)).strftime('%Y%m%d %H:%M'),
            endtime=datetime.utcfromtimestamp(int(endtime)).strftime('%H:%M'),
#            starttime=starttime.strftime('%Y%m%d %H:%M'),
#            endtime=endtime.strftime('%H:%M')
            ),
        fontsize=20
        )

#    plt.legend(loc='upper right')

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
            fontweight='bold', fontsize=10, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    
    fig.savefig(saveFilename, dpi=figDPI)
    
    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict_profile['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = 355,
                                    filename = saveFilename,
                                    level = 0,
                                    info = "overview of all relevant polly profile-products",
                                    nc_zip_file = nc_dict_profile['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'Profile_summary_{method}_{ymax_prod_type}',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%Y%m%d %H:%M:%S')
                                    )


def pollyDisplay_profile_summary_QC(nc_dict_profile,config_dict,polly_conf_dict,outdir,ymax,donefilelist_dict):
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

    if not nc_dict_profile :
        return

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']


    partnerLabel = polly_conf_dict['partnerLabel']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc-file
    starttime = nc_dict_profile['start_time']
    endtime = nc_dict_profile['end_time']
#    var_err_ls = [ nc_dict_profile[parameter_err] for parameter_err in profile_translator[profilename]['var_err_name_ls'] ]
    height_FR = nc_dict_profile['height']
#    LCUsed = np.array([nc_dict_profile[f'LCUsed{wavelength}']])

#    flagLC = nc_dict_profile[f'flagLC{wavelength}']
    pollyVersion = nc_dict_profile['PollyVersion']
    location = nc_dict_profile['location']
    version = nc_dict_profile['PicassoVersion']
    dataFilename = re.split(r'_profiles',nc_dict_profile['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"


    if ymax == 'high_range':
        y_max_FR = polly_conf_dict['yLim_all_profiles_high_range']
        ymax_prod_type = ymax
        xmax_depol = [0,0.6]
    elif ymax == 'low_range':
        y_max_FR = polly_conf_dict['yLim_all_profiles_low_range']
        ymax_prod_type = ymax
        xmax_depol = polly_conf_dict['zLim_VolDepol_1064']
    else:
        y_max_FR = polly_conf_dict['yLim_all_profiles_high_range']
        ymax_prod_type = 'high_range'
        xmax_depol = [0,0.6]

    plotfile = f"{dataFilename}_profile_summary_QC_{ymax_prod_type}.{imgFormat}"
    saveFolder = outdir
    saveFilename = os.path.join(saveFolder,plotfile)

    cols = 6
#    height_NR = nc_dict_profile_NR['height']
#    h_index = np.where(height_NR > 5000)[0][0]
#    height_NR_shortened = height_NR[0:h_index]

    param_dict = {
                  "backscatter":
                                {"Klett": ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064'],
                                 "Raman":['aerBsc_raman_355','aerBsc_raman_532','aerBsc_raman_1064']
                                },
                  "extinction": {"Klett": ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064'],
                                 "Raman": ['aerExt_raman_355','aerExt_raman_532','aerExt_raman_1064']
                                },
                  "lidarratio": {"Klett": [],
                                 "Raman": ['aerLR_raman_355','aerLR_raman_532','aerLR_raman_1064']
                                },
                  "angstroem": {"Klett": [],
                                "Raman": ['AE_beta_355_532_Raman','AE_beta_532_1064_Raman','AE_parExt_355_532_Raman']
                               },
                  "depolarization": {"Klett": ['parDepol_klett_355','parDepol_klett_532','parDepol_klett_1064'],
                                     "Raman": ['parDepol_raman_355','parDepol_raman_532','parDepol_raman_1064']
                                    },
                  "wvmr": {"Klett": [],
                           "Raman": ['WVMR']
                          }
    }


    fixed_LR_ls = []

    def plotting_procedure_QC(col,param_dict,parameter,xlabel,xlim=[0,1],ylim=[0,1],scaling_factor=1):
        fixed_LR = 1

        ax[col].set_xlabel(xlabel, fontsize=axes_fontsize)
        ax[col].grid(True)
        ax[col].tick_params(axis='both', which='major', labelsize=15,
                       right=True, top=True, width=2, length=5)
        ax[col].tick_params(axis='both', which='minor', width=1.5,
                       length=3.5, right=True, top=True)

        for n,p in enumerate(param_dict[parameter]["Raman"]):
            label = p
            if parameter == 'angstroem':
                    color_ls = ['orange','magenta','black']
            else:
                    color_ls = ['blue','green','red']

            line_style = '-'

            if parameter == 'wvmr':
#                ax2 = ax[col].secondary_xaxis('top')
                ax2 = ax[col].twiny()
                ax2.set_xlabel('Rel.Humidity [%]', fontsize=axes_fontsize)
                ax2.set_xlim(0,100)
                ax2.tick_params(axis='both', which='major', labelsize=15,
                       right=True, top=True, width=2, length=5)
                ax2.tick_params(axis='both', which='minor', width=1.5,
                       length=3.5, right=True, top=True)
                p_Raman = ax[col].plot(nc_dict_profile['WVMR']*scaling_factor, height_FR/1000,\
                    linestyle=line_style,\
                    color=color_ls[n],\
                    zorder=2,\
                    alpha=1,\
                    label='WVMR')
                p_RH = ax2.plot(nc_dict_profile['RH']*scaling_factor, height_FR/1000,\
                    linestyle=line_style,\
                    #color=color_ls[n],\
                    color='green',
                    zorder=2,\
                    alpha=1,\
                    label='RH')
                ax2.legend(fontsize=14, loc='upper right', bbox_to_anchor=(0.9, 0.95))
            else:
                p_Raman = ax[col].plot(nc_dict_profile[p]*scaling_factor*fixed_LR, height_FR/1000,\
                    linestyle=line_style,\
                    color=color_ls[n],\
                    zorder=2,\
                    label=label)


        for n,p in enumerate(param_dict[parameter]["Klett"]):
            color_ls = ['cyan','lime','salmon']
            label = p
            line_style = '-'

            if parameter == 'extinction':
                label = f'{p} x LR'
                try:
                    fixed_LR = nc_dict_profile[f'{p}___retrieving_info']
                    fixed_LR = re.split(r'Fixed lidar ratio:',fixed_LR)[-1]
                    fixed_LR = float(re.split(r'\[Sr\]',fixed_LR)[0])
                    fixed_LR_ls.append(fixed_LR)
                except:
                     fixed_LR = 50
            else:
                fixed_LR = 1

            p_Klett = ax[col].plot(nc_dict_profile[p]*scaling_factor*fixed_LR, height_FR/1000,\
                linestyle=line_style,\
                color=color_ls[n],\
                zorder=1,\
                label=label)
        ax[col].set_xlim(xlim[0],xlim[1])
        ax[col].set_ylim(ylim[0],ylim[1]/1000)
        ax[col].legend(loc='upper right',fontsize=14)


    fig, ax = plt.subplots(1,cols, figsize=(25, 17))

    axes_fontsize = 18

    ## ref.Height
    if np.any(nc_dict_profile['reference_height_355'].mask):
        refH355_0 = np.nan
        refH355_1 = np.nan
    else:
        refH355_0 = nc_dict_profile['reference_height_355'][0]/1000
        refH355_1 = nc_dict_profile['reference_height_355'][1]/1000
    if np.any(nc_dict_profile['reference_height_532'].mask):
        refH532_0 = np.nan
        refH532_1 = np.nan
    else:
        refH532_0 = nc_dict_profile['reference_height_532'][0]/1000
        refH532_1 = nc_dict_profile['reference_height_532'][1]/1000
    if np.any(nc_dict_profile['reference_height_1064'].mask):
        refH1064_0 = np.nan
        refH1064_1 = np.nan
    else:
        refH1064_0 = nc_dict_profile['reference_height_1064'][0]/1000
        refH1064_1 = nc_dict_profile['reference_height_1064'][1]/1000
    fig.text(
        0.1, 0.02,
        'ref.H_355: '+f'{refH355_0:.2f}-{refH355_1:.2f} km\n'+\
        'ref.H_532: '+f'{refH532_0:.2f}-{refH532_1:.2f} km\n'+\
        'ref.H_1064: '+f'{refH1064_0:.2f}-{refH1064_1:.2f} km',fontsize=14, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)

    ## eta
    try:
        eta355 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_355___retrieving_info'])[-1])
    except:
        eta355 = np.nan
    try:
        eta532 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_532___retrieving_info'])[-1])
    except:
        eta532 = np.nan
    try:
        eta1064 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_1064___retrieving_info'])[-1])
    except:
        eta1064 = np.nan
    ax[4].text(
        0.45, 0.75,
        r'$\eta_{355}$: '+f'{eta355:.2f}\n'+\
        r'$\eta_{532}$: '+f'{eta532:.2f}\n'+\
        r'$\eta_{1064}$: '+f'{eta1064:.2f}',fontsize=14, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1,transform=ax[4].transAxes)

    ## water-vapor calib-constant
    try:
        wv_calib = float(nc_dict_profile['WVMR___wv_calibration_constant_used'])
    except:
        wv_calib  = np.nan
    fig.text(
        0.85, 0.05,
        f'WV-calib.const.: {wv_calib:.1f}',fontsize=14, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)



    plotting_procedure_QC(col=0,param_dict=param_dict,parameter="backscatter",xlabel="Backsc. coeff. [Msr$^{-1}$ m$^{-1}$]",xlim = polly_conf_dict['xLim_Profi_Bsc'],ylim=y_max_FR,scaling_factor=10**6)
    
    plotting_procedure_QC(col=1,param_dict=param_dict,parameter="extinction",xlabel="Extinct. coeff. [Mm$^{-1}$]",xlim = polly_conf_dict['xLim_Profi_Ext'],ylim=y_max_FR,scaling_factor=10**6)
    
    plotting_procedure_QC(col=2,param_dict=param_dict,parameter="lidarratio",xlabel="Lidar ratio [Sr]",xlim = polly_conf_dict['xLim_Profi_LR'],ylim=y_max_FR)
    
    plotting_procedure_QC(col=3,param_dict=param_dict,parameter="angstroem",xlabel="$\AA$ngström Exp.",xlim = polly_conf_dict['xLim_Profi_AE'],ylim=y_max_FR)

    plotting_procedure_QC(col=4,param_dict=param_dict,parameter="depolarization",xlabel="Depol. ratio",xlim = xmax_depol,ylim=y_max_FR)
    plotting_procedure_QC(col=5,param_dict=param_dict,parameter="wvmr",xlabel="WVMR [$g*kg^{-1}$]",xlim = polly_conf_dict['xLim_Profi_WVMR'],ylim=y_max_FR)
    
    if len(fixed_LR_ls) > 0:
        ax[1].text(
            0.6, 0.85,
            r'LR$_{355}$: '+f'{fixed_LR_ls[0]:.2f}\n'+\
            r'LR$_{532}$: '+f'{fixed_LR_ls[1]:.2f}\n'+\
            r'LR$_{1064}$: '+f'{fixed_LR_ls[2]:.2f}',fontsize=11, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1,transform=ax[1].transAxes)


    plt.tight_layout(rect=[0.05, 0.07, 0.98, 0.95])
        
    ax[0].set_ylabel("Height [km]",fontsize=18)

    fig.suptitle(
        'Summary of QC profile plots for {instrument} at {location} {starttime}-{endtime}'.format(
            instrument=pollyVersion,
            location=location,
            starttime=datetime.utcfromtimestamp(int(starttime)).strftime('%Y%m%d %H:%M'),
            endtime=datetime.utcfromtimestamp(int(endtime)).strftime('%H:%M'),
#            starttime=starttime.strftime('%Y%m%d %H:%M'),
#            endtime=endtime.strftime('%H:%M')
            ),
        fontsize=20
        )

#    plt.legend(loc='upper right')

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        #rootDir = os.getcwd()
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.33, 0.006, 0.08, 0.04], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.5, 0.01, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.75, 0.01,
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=10, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    
    fig.savefig(saveFilename, dpi=figDPI)
    
    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict_profile['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = 355,
                                    filename = saveFilename,
                                    level = 0,
                                    info = "overview of all relevant polly profile-products",
                                    nc_zip_file = nc_dict_profile['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'Profile_summary_QC_{ymax_prod_type}',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%Y%m%d %H:%M:%S')
                                    )



def pollyDisplay_profile_summary_meteo(nc_dict_profile,config_dict,polly_conf_dict,outdir,ymax,donefilelist_dict):
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

    if not nc_dict_profile :
        return

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']


    partnerLabel = polly_conf_dict['partnerLabel']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc-file
    starttime = nc_dict_profile['start_time']
    endtime = nc_dict_profile['end_time']
#    var_err_ls = [ nc_dict_profile[parameter_err] for parameter_err in profile_translator[profilename]['var_err_name_ls'] ]
    height_FR = nc_dict_profile['height']

    pollyVersion = nc_dict_profile['PollyVersion']
    location = nc_dict_profile['location']
    version = nc_dict_profile['PicassoVersion']
    dataFilename = re.split(r'_profiles',nc_dict_profile['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"


    if ymax == 'high_range':
        y_max_FR = polly_conf_dict['yLim_all_profiles_high_range']
        ymax_prod_type = ymax
    elif ymax == 'low_range':
        y_max_FR = polly_conf_dict['yLim_all_profiles_low_range']
        ymax_prod_type = ymax
    else:
        y_max_FR = polly_conf_dict['yLim_all_profiles_high_range']
        ymax_prod_type = 'high_range'

    plotfile = f"{dataFilename}_profile_summary_meteo_pTRH_{ymax_prod_type}.{imgFormat}"
    saveFolder = outdir
    saveFilename = os.path.join(saveFolder,plotfile)

    cols = 3

    param_dict = {
                  "pressure":
                                {"FR": ['pressure'],
                                 "NR": []
                                },
                  "temperature": {"FR": ['temperature'],
                                 "NR": []
                                },
                  "RH": {"FR": [],
                                 "NR": []
                                },
                }

    def plotting_procedure(col,param_dict,parameter,xlabel,xlim=[0,1],ylim=[0,1],scaling_factor=1):

        ax[col].set_xlabel(xlabel, fontsize=axes_fontsize)
        ax[col].grid(True)
        ax[col].tick_params(axis='both', which='major', labelsize=18,
                       right=True, top=True, width=2, length=5)
        ax[col].tick_params(axis='both', which='minor', width=1.5,
                       length=3.5, right=True, top=True)

        for n,p in enumerate(param_dict[parameter]["FR"]):
            if p == None:
                continue
            label=f'model {p}'
            if parameter == 'pressure':
                    color_ls = ['blue']
            elif parameter == 'temperature':
                    color_ls = ['red']
            elif parameter == 'RH':
                    color_ls = ['green']

            line_style = '-'

#            if parameter == 'RH':
#                ax.set_xlabel('Rel.Humidity [%]', fontsize=axes_fontsize)
#                ax.set_xlim(0,100)
#                ax.tick_params(axis='both', which='major', labelsize=15,
#                       right=True, top=True, width=2, length=5)
#                ax.tick_params(axis='both', which='minor', width=1.5,
#                       length=3.5, right=True, top=True)
#                p_RH = ax.plot(nc_dict_profile['RH']*scaling_factor, height_FR/1000,\
#                    linestyle=line_style,\
#                    #color=color_ls[n],\
#                    color='green',
#                    zorder=2,\
#                    alpha=1,\
#                    label='RH')
#                ax.legend(fontsize=14, loc='upper right', bbox_to_anchor=(0.9, 0.95))
#            else:
#                p_FR = ax[col].plot(nc_dict_profile[p]*scaling_factor*fixed_LR, height_FR/1000,\
#                    linestyle=line_style,\
#                    color=color_ls[n],\
#                    zorder=2,\
#                    label=label)
            p_FR = ax[col].plot(nc_dict_profile[p]*scaling_factor, height_FR/1000,\
                linestyle=line_style,\
                color=color_ls[n],\
                zorder=2,\
                label=label)


        ax[col].set_xlim(xlim[0],xlim[1])
        ax[col].set_ylim(ylim[0],ylim[1]/1000)
        ax[col].legend(loc='upper right',fontsize=16)
    
    fig, ax = plt.subplots(1,cols, figsize=(25, 17))

    axes_fontsize = 20

#    ## water-vapor calib-constant
#    try:
#        wv_calib = float(nc_dict_profile['WVMR___wv_calibration_constant_used'])
#    except:
#        wv_calib  = np.nan
#    fig.text(
#        0.85, 0.05,
#        f'WV-calib.const.: {wv_calib:.1f}',fontsize=14, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)



    plotting_procedure(col=0,param_dict=param_dict,parameter="pressure",xlabel="Pressure [hPa]",xlim = [0,1000],ylim=y_max_FR,scaling_factor=1)
    
    plotting_procedure(col=1,param_dict=param_dict,parameter="temperature",xlabel="Temperature [°C]",xlim = [-60,40],ylim=y_max_FR,scaling_factor=1)
    
    plotting_procedure(col=2,param_dict=param_dict,parameter="RH",xlabel="Rel. Humidity [%]",xlim = [0,100],ylim=y_max_FR)
    
    

    plt.tight_layout(rect=[0.05, 0.07, 0.98, 0.95])
        
    ax[0].set_ylabel("Height [km]",fontsize=20)

    fig.suptitle(
        'Summary of meteorological profile plots for {instrument} at {location} {starttime}-{endtime}'.format(
            instrument=pollyVersion,
            location=location,
            starttime=datetime.utcfromtimestamp(int(starttime)).strftime('%Y%m%d %H:%M'),
            endtime=datetime.utcfromtimestamp(int(endtime)).strftime('%H:%M'),
#            starttime=starttime.strftime('%Y%m%d %H:%M'),
#            endtime=endtime.strftime('%H:%M')
            ),
        fontsize=22
        )


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
            fontweight='bold', fontsize=10, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    
    fig.savefig(saveFilename, dpi=figDPI)
    
    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict_profile['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = 355,
                                    filename = saveFilename,
                                    level = 0,
                                    info = "overview of meteorological parameters for profiles",
                                    nc_zip_file = nc_dict_profile['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'Profile_summary_meteo_pTRH',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%Y%m%d %H:%M:%S')
                                    )


