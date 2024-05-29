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
import json
from pathlib import Path
import argparse
#import pypolly_readout_profiles as readout_profiles
import pypolly_readout as readout
import statistics
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
            eta355 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_355___retrieving_info'])[-1])
        else:
            eta355 = np.nan
        if 'volDepol_klett_532___retrieving_info' in nc_dict_profile.keys():
            eta532 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_532___retrieving_info'])[-1])
        else:
            eta532 = np.nan
        if 'volDepol_klett_1064___retrieving_info' in nc_dict_profile.keys():
            eta1064 = float(re.split(r'eta:',nc_dict_profile['volDepol_klett_1064___retrieving_info'])[-1])
        else:
            eta1064 = np.nan
        fig.text(
            0.32, 0.82,
            r'$\eta_{355}$: '+f'{eta355:.2f}\n'+\
            r'$\eta_{532}$: '+f'{eta532:.2f}\n'+\
            r'$\eta_{1064}$: '+f'{eta1064:.2f}',fontsize=11, backgroundcolor=[0.94, 0.95, 0.96, 0.8], alpha=1)
    if  profilename in list_for_eta_raman_plots:
        if 'volDepol_raman_355___retrieving_info' in nc_dict_profile.keys():
            eta355 = float(re.split(r'eta:',nc_dict_profile['volDepol_raman_355___retrieving_info'])[-1])
        else:
            eta355 = np.nan
        if 'volDepol_raman_532___retrieving_info' in nc_dict_profile.keys():
            eta532 = float(re.split(r'eta:',nc_dict_profile['volDepol_raman_532___retrieving_info'])[-1])
        else:
            eta532 = np.nan
        if 'volDepol_raman_1064___retrieving_info' in nc_dict_profile.keys():
            eta1064 = float(re.split(r'eta:',nc_dict_profile['volDepol_raman_1064___retrieving_info'])[-1])
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
    

