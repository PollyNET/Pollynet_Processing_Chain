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
from datetime import datetime, timedelta
import matplotlib
import argparse
import pypolly_readout as readout
#import statistics
#from statistics import mode

# load colormap
dirname = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(dirname)
try:
    from python_colormap import *
except Exception as e:
    raise ImportError('python_colormap module is necessary.')

# generating figure without X server
plt.switch_backend('Agg')



#def pollyDisplayAttnBsc(nc_dict, config_dict, polly_conf_dict, saveFolder, wavelength, param='FR'):
#    """
#    Description
#    -----------
#    Display the AttBsc (FR/NR/OC) of wavelength [nm] channel from level1 polly nc-file.
#
#    Parameters
#    ----------
#    nc_dict: dict
#        dict wich stores the att-bsc data.
#    wavelength: int
#        the selected wavelength channel: e.g.: 355/532/1064 nm
#
#    Usage
#    -----
#    pollyDisplayAttnBsc(nc_dict, config_dict, polly_conf_dict, saveFolder, wavelength, param)
#    param can be one of the following: ['FR','NR','OC']
#
#    History
#    -------
#    2022-09-01. First edition by Andi
#    """
#    ## read from config file
#    figDPI = config_dict['figDPI']
#    flagWatermarkOn = config_dict['flagWatermarkOn']
#    fontname = config_dict['fontname']
#
#    ## read from global config file
#    if param == 'FR':
#        yLim = polly_conf_dict['yLim_att_beta']
#    elif param == 'NR':
#        yLim = polly_conf_dict['yLim_att_beta_NR']
#    elif param == 'OC':
#        yLim = polly_conf_dict['yLim_OC_att_beta']
#    zLim = polly_conf_dict[f'zLim_att_beta_{wavelength}']
#    partnerLabel = polly_conf_dict['partnerLabel']
#    colormap_basic = polly_conf_dict['colormap_basic']
#    flagLC = polly_conf_dict['flagLCCalibration']
#    imgFormat = polly_conf_dict['imgFormat']
#
#    ## read from nc file
#    ATT_BETA = nc_dict[f'ATT_BETA_{wavelength}']
#    quality_mask = nc_dict[f'quality_mask_{wavelength}']
#    height = nc_dict['height']
#    time = nc_dict['time']
#    LCUsed = np.array([nc_dict[f'LCUsed{wavelength}']])
#    pollyVersion = nc_dict['PollyVersion']
#    location = nc_dict['location']
#    version = nc_dict['PicassoVersion']
#    if param == 'FR':
#        dataFilename = re.split(r'_att_bsc',nc_dict['PollyDataFile'])[0]
#    elif param == 'NR':
#        dataFilename = re.split(r'_NR_att_bsc',nc_dict['PollyDataFile'])[0]
#    elif param == 'OC':
#        dataFilename = re.split(r'_OC_att_bsc',nc_dict['PollyDataFile'])[0]
#
#    # set the default font
#    matplotlib.rcParams['font.sans-serif'] = fontname
#    matplotlib.rcParams['font.family'] = "sans-serif"
#
#    if param == 'FR':
#        plotfile = f'{dataFilename}_ATT_BETA_{wavelength}.{imgFormat}'
#    elif param == 'NR':
#        plotfile = f'{dataFilename}_ATT_BETA_NR_{wavelength}.{imgFormat}'
#    elif param == 'OC':
#        plotfile = f'{dataFilename}_ATT_BETA_OC_{wavelength}.{imgFormat}'
#
#    ## fill time gaps in att_bsc matrix
#    ATT_BETA, quality_mask = readout.fill_time_gaps_of_matrix(time, ATT_BETA, quality_mask)
#
#    ## get date and convert to datetime object
#    date_00 = datetime.strptime(nc_dict['m_date'], '%Y-%m-%d')
#    date_00 = date_00.timestamp()
#
#    ## set x_lims for 24hours by creating a list of datetime.datetime objects using map.
#    x_lims = list(map(datetime.fromtimestamp, [date_00, date_00+24*60*60]))
#
#    ## convert these datetime.datetime objects to the correct format for matplotlib to work with.
#    x_lims = date2num(x_lims)
#
#    ## set max_height
#    y_max = yLim[1]
#    max_height = [ h/1000 for h in height if h < y_max ]
#
#    ## set plot-region for imshow
#    extent = [ x_lims[0], x_lims[-1], max_height[0], max_height[-1] ]
#
#    ## mask matrix
#    ATT_BETA = np.ma.masked_where(quality_mask> 0, ATT_BETA)
#    
#    ## slice matrix to max_height
#    ATT_BETA = ATT_BETA[:,0:len(max_height)]
#
#    ## transpose and flip for correct plotting
#    ATT_BETA= np.ma.transpose(ATT_BETA)  ## matrix has to be transposed for usage with pcolormesh!
#    ATT_BETA= np.flip(ATT_BETA,0)
#
#    # define the colormap
#    cmap = load_colormap(name=colormap_basic)
#    ## set color of nan-values
#    cmap.set_bad(color='black')
#
#    print(f"plotting {plotfile} ... ")
#    # display attenuate backscatter
#    fig = plt.figure(figsize=[12, 6])
#    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
#    pcmesh = ax.imshow(
#            ATT_BETA * 1e6,
#            cmap=cmap,
#            vmin=zLim[0],
#            vmax=zLim[1],
#            interpolation='none',
#            aspect='auto',
#            extent=extent,
#            )
#    # convert the datetime data from a float (which is the output of date2num into a nice datetime string.
#    ax.xaxis_date()
#
#    ax.set_xlabel('Time [UTC]', fontsize=15)
#    ax.set_ylabel('Height [km]', fontsize=15)
#
#    ax.xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
#    ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))
#    ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))
##    
#    ax.tick_params(
#        axis='both', which='major', labelsize=15, right=True,
#        top=True, width=2, length=5)
#    ax.tick_params(
#        axis='both', which='minor', width=1.5, length=3.5,
#        right=True, top=True)
#
#    ax.set_title(
#        'Attenuated Backscatter at {wave} nm'.format(wave = wavelength) +
#        ' {param} of {instrument} at {location}'.format(
#            param=param,
#            instrument=pollyVersion,
#            location=location),
#        fontsize=15)
#
#    cb_ax = fig.add_axes([0.92, 0.25, 0.02, 0.55])
#    cbar = fig.colorbar(
#        pcmesh,
#        cax=cb_ax,
#        ticks=np.linspace(zLim[0], zLim[1], 5),
#        orientation='vertical')
#    cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
##    cbar.ax.set_title('      $Mm^{-1}*sr^{-1}$\n', fontsize=10)
#    cbar.ax.set_title('      $\mathrm{Mm^{-1}\,sr^{-1}}$\n', fontsize=10)
#    # add watermark
#    if flagWatermarkOn:
#        rootDir = os.getcwd()
#        im_license = matplotlib.image.imread(
#            os.path.join(rootDir, 'img', 'by-sa.png'))
#
#        newax_license = fig.add_axes([0.58, 0.006, 0.14, 0.07], zorder=10)
#        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
#        newax_license.axis('off')
#
#        fig.text(0.72, 0.003, 'Preliminary\nResults.',
#                 fontweight='bold', fontsize=12, color='red',
#                 ha='left', va='bottom', alpha=0.8, zorder=10)
#
#        fig.text(
#            0.84, 0.003,
#            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
#                datetime.now().strftime('%Y'), partnerLabel),
#            fontweight='bold', fontsize=7, color='black', ha='left',
#            va='bottom', alpha=1, zorder=10)
#
#    fig.text(
#        0.05, 0.02,
#        '{0}\nLC: {1:.2e}'.format(
##            datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
#            nc_dict['m_date'],
#            LCUsed[0]), fontsize=12)
#    fig.text(
#        0.2, 0.02,
#        'Version: {version}\nCalibration: {method}'.format(
#            version=version,
#            method=flagLC),
#        fontsize=12)
#
#    fig.savefig(
#        os.path.join(
#            saveFolder,
#            plotfile),
#        dpi=figDPI)
#
#    plt.close()
#



def pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, saveFolder, wavelength, param='FR'):
    """
    Description
    -----------
    Display the AttBsc (FR/NR/OC) of wavelength [nm] channel from level1 polly nc-file.

    Parameters
    ----------
    nc_dict: dict
        dict wich stores the att-bsc data.
    wavelength: int
        the selected wavelength channel: e.g.: 355/532/1064 nm

    Usage
    -----
    pollyDisplayAttnBsc(nc_dict, config_dict, polly_conf_dict, saveFolder, wavelength, param)
    param can be one of the following: ['FR','NR','OC']

    History
    -------
    2022-09-01. First edition by Andi
    """
    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']

    ## read from global config file
    if param == 'FR':
        yLim = polly_conf_dict['yLim_att_beta']
    elif param == 'NR':
        yLim = polly_conf_dict['yLim_att_beta_NR']
    elif param == 'OC':
        yLim = polly_conf_dict['yLim_OC_att_beta']
    zLim = polly_conf_dict[f'zLim_att_beta_{wavelength}']
    partnerLabel = polly_conf_dict['partnerLabel']
    colormap_basic = polly_conf_dict['colormap_basic']
    flagLC = polly_conf_dict['flagLCCalibration']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc file
    ATT_BETA = nc_dict[f'attenuated_backscatter_{wavelength}nm']
    if param == 'FR' or param == 'NR':
        SNR = nc_dict[f'SNR_{wavelength}nm']
        quality_mask = nc_dict[f'quality_mask_{wavelength}nm']
    elif param == 'OC':
        quality_mask = np.where(ATT_BETA > 0, 0, 0)

    height = nc_dict['height']
    time = nc_dict['time']
    LCUsed = np.array([nc_dict[f'attenuated_backscatter_{wavelength}nm___Lidar_calibration_constant_used']])
    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    if param == 'FR':
        dataFilename = re.split(r'_att_bsc',nc_dict['PollyDataFile'])[0]
    elif param == 'NR':
        dataFilename = re.split(r'_NR_att_bsc',nc_dict['PollyDataFile'])[0]
    elif param == 'OC':
        dataFilename = re.split(r'_OC_att_bsc',nc_dict['PollyDataFile'])[0]

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    if param == 'FR':
        plotfile = f'{dataFilename}_ATT_BETA_{wavelength}.{imgFormat}'
        plotfile_SNR = f'{dataFilename}_ATT_BETA_{wavelength}_SNR.{imgFormat}'
    elif param == 'NR':
        plotfile = f'{dataFilename}_ATT_BETA_NR_{wavelength}.{imgFormat}'
        plotfile_SNR = f'{dataFilename}_ATT_BETA_NR_{wavelength}_SNR.{imgFormat}'
    elif param == 'OC':
        plotfile = f'{dataFilename}_ATT_BETA_OC_{wavelength}.{imgFormat}'
        plotfile_SNR = f'{dataFilename}_ATT_BETA_OC_{wavelength}_SNR.{imgFormat}'

    ## fill time gaps in att_bsc matrix
    #ATT_BETA, quality_mask_ATT = readout.fill_time_gaps_of_matrix(time, ATT_BETA, quality_mask)
    quality_mask_ATT = quality_mask
    

    ## get date and convert to datetime object
    date_00 = datetime.strptime(nc_dict['m_date'], '%Y-%m-%d')
    date_00 = date_00.timestamp()
    # Convert Unix timestamp string to a datetime object
    mtime_end = datetime.utcfromtimestamp(int(nc_dict['time'][-1]))
    mtime_end = mtime_end.timestamp()
#    mtime_end = datetime.strptime(nc_dict['time'], '%Y-%m-%d')
    ## set x_lims for 24hours by creating a list of datetime.datetime objects using map.
#    x_lims = list(map(datetime.fromtimestamp, [date_00, date_00+24*60*60]))
    x_lims = list(map(datetime.fromtimestamp, [date_00, mtime_end]))

    ## set x_lims from 0 to end of mtime (of file)

    ## convert these datetime.datetime objects to the correct format for matplotlib to work with.
    x_lims = date2num(x_lims)

    ## set max_height
    y_max = yLim[1]
    max_height = [ h/1000 for h in height if h < y_max ]

    ## set plot-region for imshow
    extent = [ x_lims[0], x_lims[-1], max_height[0], max_height[-1] ]

    ## mask matrix
    ATT_BETA = np.ma.masked_where(quality_mask_ATT < 0, ATT_BETA)
    
    ## slice matrix to max_height
    ATT_BETA = ATT_BETA[:,0:len(max_height)]

    ## transpose and flip for correct plotting
    ATT_BETA= np.ma.transpose(ATT_BETA)  ## matrix has to be transposed for usage with pcolormesh!
    ATT_BETA= np.flip(ATT_BETA,0)

    # define the colormap
    cmap = load_colormap(name=colormap_basic)
#    cmap = copy.copy(plt.cm.turbo)
#    colormap_basic = "turbo"
#    import copy
#    cmap =copy.copy(plt.cm.get_cmap(colormap_basic))
    ## set color of nan-values
    cmap.set_bad(color='white')

    print(f"plotting {plotfile} ... ")
    # display attenuate backscatter
    fig = plt.figure(figsize=[12, 6])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.imshow(
            ATT_BETA * 1e6,
            cmap=cmap,
            vmin=zLim[0],
            vmax=zLim[1],
            interpolation='none',
            aspect='auto',
            extent=extent,
            )
    # convert the datetime data from a float (which is the output of date2num into a nice datetime string.
    ax.xaxis_date()

    ax.set_xlabel('Time [UTC]', fontsize=15)
    ax.set_ylabel('Height [km]', fontsize=15)

    ax.xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
    ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))
    ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))
#    
    ax.tick_params(
        axis='both', which='major', labelsize=15, right=True,
        top=True, width=2, length=5)
    ax.tick_params(
        axis='both', which='minor', width=1.5, length=3.5,
        right=True, top=True)

    ax.set_title(
        'Attenuated Backscatter at {wave} nm'.format(wave = wavelength) +
        ' {param} of {instrument} at {location}'.format(
            param=param,
            instrument=pollyVersion,
            location=location),
        fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.25, 0.02, 0.55])
    cbar = fig.colorbar(
        pcmesh,
        cax=cb_ax,
        ticks=np.linspace(zLim[0], zLim[1], 5),
        orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
#    cbar.ax.set_title('      $Mm^{-1}*sr^{-1}$\n', fontsize=10)
    cbar.ax.set_title('      $\mathrm{Mm^{-1}\,sr^{-1}}$\n', fontsize=10)


    # add watermark
    if flagWatermarkOn:
        rootDir = os.getcwd()
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
        0.05, 0.02,
        '{0}\nLC: {1:.2e}'.format(
#            datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
            nc_dict['m_date'],
            LCUsed[0]), fontsize=12)
    fig.text(
        0.2, 0.02,
        'Version: {version}\nCalibration: {method}'.format(
            version=version,
            method=flagLC),
        fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            plotfile),
        dpi=figDPI)

    plt.close()


    ## plotting SNR
    if param == 'FR' or param == 'NR':
        ## fill time gaps in snr matrix
        SNR, quality_mask_SNR = readout.fill_time_gaps_of_matrix(time, SNR, quality_mask)

        ## mask matrix
        SNR = np.ma.masked_where(quality_mask_SNR < 0, SNR)


        ## slice matrix to max_height
        SNR = SNR[:,0:len(max_height)]

        zLim = [np.nanmin(SNR), np.nanmax(SNR)]
    
        ## transpose and flip for correct plotting
        SNR = np.ma.transpose(SNR)  ## matrix has to be transposed for usage with pcolormesh!
        SNR = np.flip(SNR,0)
        print(f"plotting {plotfile_SNR} ... ")
        # display attenuate backscatter
        fig = plt.figure(figsize=[12, 6])
        ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
        pcmesh = ax.imshow(
                SNR,
                cmap=cmap,
                vmin=zLim[0],
                vmax=zLim[1],
                interpolation='none',
                aspect='auto',
                extent=extent,
                )
        # convert the datetime data from a float (which is the output of date2num into a nice datetime string.
        ax.xaxis_date()
    
        ax.set_xlabel('Time [UTC]', fontsize=15)
        ax.set_ylabel('Height [km]', fontsize=15)
    
        ax.xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
        ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))
        ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))
    #    
        ax.tick_params(
            axis='both', which='major', labelsize=15, right=True,
            top=True, width=2, length=5)
        ax.tick_params(
            axis='both', which='minor', width=1.5, length=3.5,
            right=True, top=True)
    
        ax.set_title(
            'SNR at {wave} nm'.format(wave = wavelength) +
            ' {param} of {instrument} at {location}'.format(
                param=param,
                instrument=pollyVersion,
                location=location),
            fontsize=15)
    
        cb_ax = fig.add_axes([0.92, 0.25, 0.02, 0.55])
        cbar = fig.colorbar(
            pcmesh,
            cax=cb_ax,
            ticks=np.linspace(zLim[0], zLim[1], 5),
            orientation='vertical')
        cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
        cbar.ax.set_title('      SNR\n', fontsize=10)
    
        # add watermark
        if flagWatermarkOn:
            rootDir = os.getcwd()
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
            0.05, 0.02,
            '{0}\nLC: {1:.2e}'.format(
    #            datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
                nc_dict['m_date'],
                LCUsed[0]), fontsize=12)
        fig.text(
            0.2, 0.02,
            'Version: {version}\nCalibration: {method}'.format(
                version=version,
                method=flagLC),
            fontsize=12)
    
        fig.savefig(
            os.path.join(
                saveFolder,
                plotfile_SNR),
            dpi=figDPI)
    
        plt.close()




def pollyDisplayATT_BSC_cloudinfo(nc_dict, config_dict, polly_conf_dict, saveFolder, wavelength):
    """
    Description
    -----------
    Display the AttBsc (FR/NR/OC) of wavelength [nm] channel from level1 polly nc-file.

    Parameters
    ----------
    nc_dict: dict
        dict wich stores the att-bsc data.
    wavelength: int
        the selected wavelength channel: e.g.: 355/532/1064 nm

    Usage
    -----
    pollyDisplayAttnBsc(nc_dict, config_dict, polly_conf_dict, saveFolder, wavelength)

    History
    -------
    2022-09-01. First edition by Andi
    """
    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']

    ## read from global config file
    yLim = polly_conf_dict['yLim_att_beta']
    zLim = polly_conf_dict[f'zLim_att_beta_{wavelength}']
    partnerLabel = polly_conf_dict['partnerLabel']
    colormap_basic = polly_conf_dict['colormap_basic']
    flagLC = polly_conf_dict['flagLCCalibration']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc file
    ATT_BETA = nc_dict[f'attenuated_backscatter_{wavelength}nm']
    quality_mask = nc_dict[f'quality_mask_{wavelength}nm']

    height = nc_dict['height']
    time = nc_dict['time']
    LCUsed = np.array([nc_dict[f'attenuated_backscatter_{wavelength}nm___Lidar_calibration_constant_used']])
    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    dataFilename = re.split(r'_att_bsc',nc_dict['PollyDataFile'])[0]
    dataFilenameFolder = re.split(r'_att_bsc',nc_dict['PollyDataFileFolder'])[0]

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    plotfile = f'{dataFilename}_CLOUDINFO.{imgFormat}'

    ## read in cloudinfo-file
    cloud_file = f'{dataFilenameFolder}_cloudinfo.nc'
    print(cloud_file)
    nc_dict_cloudinfo = readout.read_nc_file(cloud_file)
    cbh_layer_list = []
    cth_layer_list = []
    for layer in nc_dict_cloudinfo['cloud_base_height'].T:
        if not layer.mask.all() and np.any(layer.data):
            cbh_layer_list.append(layer)
        else:
            pass
    for layer in nc_dict_cloudinfo['cloud_top_height'].T:
        if not layer.mask.all() and np.any(layer.data):
            cth_layer_list.append(layer)
        else:
            pass

    ## fill time gaps in att_bsc matrix
    ATT_BETA, quality_mask = readout.fill_time_gaps_of_matrix(time, ATT_BETA, quality_mask)
    

    ## get date and convert to datetime object
    date_00 = datetime.strptime(nc_dict['m_date'], '%Y-%m-%d')
    date_00 = date_00.timestamp()

    ## set x_lims for 24hours by creating a list of datetime.datetime objects using map.
    x_lims = list(map(datetime.fromtimestamp, [date_00, date_00+24*60*60]))

    ## convert these datetime.datetime objects to the correct format for matplotlib to work with.
    x_lims = date2num(x_lims)

    ## set max_height
    y_max = yLim[1]
    max_height = [ h/1000 for h in height if h < y_max ]

    ## set plot-region for imshow
    extent = [ x_lims[0], x_lims[-1], max_height[0], max_height[-1] ]

    ## mask matrix
    ATT_BETA = np.ma.masked_where(quality_mask < 0, ATT_BETA)
    
    ## slice matrix to max_height
    ATT_BETA = ATT_BETA[:,0:len(max_height)]

    ## transpose and flip for correct plotting
    ATT_BETA= np.ma.transpose(ATT_BETA)  ## matrix has to be transposed for usage with pcolormesh!
    ATT_BETA= np.flip(ATT_BETA,0)
    

    # define the colormap
    cmap = load_colormap(name=colormap_basic)
    ## set color of nan-values
    cmap.set_bad(color='white')

    print(f"plotting {plotfile} ... ")
    # display attenuate backscatter
    fig = plt.figure(figsize=[12, 6])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.imshow(
            ATT_BETA * 1e6,
            cmap=cmap,
            vmin=zLim[0],
            vmax=zLim[1],
            interpolation='none',
            aspect='auto',
            extent=extent,
            )
    # convert the datetime data from a float (which is the output of date2num into a nice datetime string.
    ax.xaxis_date()


    ax.set_xlabel('Time [UTC]', fontsize=15)
    ax.set_ylabel('Height [km]', fontsize=15)

    ax.xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
    ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))
    ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))
#    
    ax.tick_params(
        axis='both', which='major', labelsize=15, right=True,
        top=True, width=2, length=5)
    ax.tick_params(
        axis='both', which='minor', width=1.5, length=3.5,
        right=True, top=True)

    ax.set_title(
        'Cloudinfo overlay with AttBsc at {wave} nm'.format(wave = wavelength) +
        ' {param} of {instrument} at {location}'.format(
            param='FR',
            instrument=pollyVersion,
            location=location),
        fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.25, 0.02, 0.55])
    cbar = fig.colorbar(
        pcmesh,
        cax=cb_ax,
        ticks=np.linspace(zLim[0], zLim[1], 5),
        orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
    #cbar.ax.set_title('      $Mm^{-1}*sr^{-1}$\n', fontsize=10)
    cbar.ax.set_title('      $\mathrm{Mm^{-1}\,sr^{-1}}$\n', fontsize=10)

    # add cloud_info
    dt_list = [datetime.utcfromtimestamp(t) for t in time]
    lw = 5
    #ax.scatter(dt_list, data['mlh_stratf']['var'], color='#e00', marker='v', s=lw, label='MLH')
    #ax.scatter(dt_list, data['ablh_stratf']['var'], color='#666', marker='D', s=lw, label='ABLH')
    #ax.scatter(dt_list, data['cbh_stratf']['var'], color='#111', marker='o', s=lw, label='CBH')

    ax.scatter(dt_list,cbh_layer_list[0], color='#111', marker='o', s=lw, label='CBH')
    ax.scatter(dt_list,cth_layer_list[0], color='#666', marker='D', s=lw, label='CTH')
    ax.legend(loc=1)
    for layer in range(1,len(cbh_layer_list)):
        ax.scatter(dt_list,cbh_layer_list[layer], color='#111', marker='o', s=lw, label='CBH')
    for layer in range(1,len(cth_layer_list)):
        ax.scatter(dt_list,cth_layer_list[layer], color='#666', marker='D', s=lw, label='CTH')
                
                

#    ax.scatter(dt_list,nc_dict_cloudinfo['cloud_base_height'].T[0], color='#111', marker='o', s=lw, label='CBH')
#    ax.scatter(dt_list,nc_dict_cloudinfo['cloud_top_height'].T[0], color='#666', marker='D', s=lw, label='CTH')
#    ax.legend(loc=1) 

    # add watermark
    if flagWatermarkOn:
        rootDir = os.getcwd()
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
        0.05, 0.02,
        '{0}\nLC: {1:.2e}'.format(
#            datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
            nc_dict['m_date'],
            LCUsed[0]), fontsize=12)
    fig.text(
        0.2, 0.02,
        'Version: {version}\nCalibration: {method}'.format(
            version=version,
            method=flagLC),
        fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            plotfile),
        dpi=figDPI)

    plt.close()



