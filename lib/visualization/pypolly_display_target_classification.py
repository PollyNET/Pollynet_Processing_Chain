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


def pollyDisplayTargetClass(nc_dict,config_dict, polly_conf_dict, saveFolder, c_version):
    """
    Description
    -----------
    Display the quasi results V1/V2 from the Angstrom exponent 532-1064 nm from level1 polly nc-file.

    Parameters
    ----------
    nc_dict_QR: dict
        dict wich stores the QR data.

    Usage
    -----
    pollyDisplayQRV1_Ang(nc_dict)
    c_version = "V1" or "V2"

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
    partnerLabel = polly_conf_dict['partnerLabel']
    colormap_basic = polly_conf_dict['colormap_basic']
    imgFormat = polly_conf_dict['imgFormat']

#    figDPI = nc_dict['figDPI']
#    flagWatermarkOn = nc_dict['flagWatermarkOn']
#    partnerLabel = nc_dict['partnerLabel']
    matrix = nc_dict['TC']
    quality_mask = np.where(matrix > 0, 0, 0)
    height = nc_dict['height']
    time = nc_dict['time']
    cRange = nc_dict['TC_cRange'] ## equals zLim and the number of classes in the target classification
    TC_def = nc_dict['TC_def']
    classes = re.split(r'\\n',TC_def)
    classes_list = []
    for i in range(int(cRange[1])+1):
        T_class = re.split(r'[0-9]: ', classes[i])[1] 
        classes_list.append(re.split(r'\\', T_class)[0])

    TC_legend_key_red = nc_dict['TC_legend_key_red']
    TC_legend_key_green = nc_dict['TC_legend_key_green']
    TC_legend_key_blue = nc_dict['TC_legend_key_blue']

    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    dataFilename = re.split(r'_target_classification',nc_dict['PollyDataFile'])[0]
    ## generate colorlist for the different classes
    TC_color_matrix = []
    for i in range(int(cRange[1])+1):
        TC_color_matrix.append([TC_legend_key_red[i],TC_legend_key_green[i],TC_legend_key_blue[i]])

#    cmap = matplotlib.colors.ListedColormap(['#DAFFFF','#6CFFEC','#209FF3','#BF9AFF','#E5E5E5', '#464AB9','#FFA500',
#                              '#C7FA3A', '#CEBC89','#E64A23','#B43757'])
    cmap = matplotlib.colors.ListedColormap(TC_color_matrix)

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

#    saveFolder = args.outdir
    if c_version == "V1":
        plotfile = f'{dataFilename}_TC.{imgFormat}'
    if c_version == "V2":
        plotfile = f'{dataFilename}_TC_V2.{imgFormat}'

    ## fill time gaps in att_bsc matrix
    matrix, quality_mask = readout.fill_time_gaps_of_matrix(time, matrix, quality_mask)

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
    matrix = np.ma.masked_where(quality_mask > 0, matrix)
    
    ## slice matrix to max_height
    matrix = matrix[:,0:len(max_height)]

    ## transpose and flip for correct plotting
    matrix = np.ma.transpose(matrix)  ## matrix has to be transposed for usage with pcolormesh!
    matrix = np.flip(matrix,0)

    # define the colormap
#    cmap = load_colormap(name=colormap_basic)
    ## set color of nan-values
    cmap.set_bad(color='black')

    print(f"plotting {plotfile} ... ")
    # display attenuate backscatter
    fig = plt.figure(figsize=[12, 6])
#    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    ax = fig.add_axes([0.09, 0.15, 0.67, 0.75])

    pcmesh = ax.imshow(
            matrix,
            cmap=cmap,
            vmin=cRange[0]-0.5,
            vmax=cRange[1]+0.5,
            interpolation='none',
            aspect='auto',
            extent=extent,
            )
    # convert the datetime data from a float (which is the output of date2num into a nice datetime string.
    ax.xaxis_date()

    ax.set_xlabel('Time [UTC]', fontsize=15)
    ax.set_ylabel('Height [km]', fontsize=15)

    ax.xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
#    ax.xaxis.set_major_locator(HourLocator(interval=2))    # every 4 hours
    ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))
    ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))
#    
    ax.tick_params(
        axis='both', which='major', labelsize=12, right=True,
        top=True, width=2, length=5)
    ax.tick_params(
        axis='both', which='minor', width=1.5, length=3.5,
        right=True, top=True)

    ax.set_title(
        'Target classifications ({V}) of {instrument} at {location}'.format(
            V=c_version,
            instrument=pollyVersion,
            location=location),
        fontsize=15)

    #cb_ax = fig.add_axes([0.92, 0.25, 0.02, 0.55])
    cb_ax = fig.add_axes([0.77, 0.15, 0.01, 0.75])
    cbar = fig.colorbar(
        pcmesh,
        cax=cb_ax,
        ticks=np.arange(cRange[0], cRange[1]+1, 1),
        orientation='vertical')
    cbar.ax.set_yticklabels(classes_list)
    cbar.ax.tick_params(direction='out', labelsize=9, pad=5)
#    cbar.ax.set_title('      \n', fontsize=10)
    # create legend of classes
#    plt.legend([matplotlib.patches.Patch(color=cmap(j)) for j in range(int(cRange[1])+1)], [cl for cl in classes_list])

    # add watermark
    if flagWatermarkOn:
        rootDir = os.getcwd()  
#        rootDir = os.path.dirname(
#            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
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
        '{0}'.format(
#            datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
            nc_dict['m_date']),
            fontsize=12)
    fig.text(
        0.2, 0.02,
        'Version: {version}'.format(
            version=version),
        fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            plotfile),
        dpi=figDPI)

    plt.close()


#
#def pollyDisplayTargetClassV2(nc_dict):
#    """
#    Description
#    -----------
#    Display the quasi results V2 from the Angstrom exponent 532-1064 nm from level1 polly nc-file.
#
#    Parameters
#    ----------
#    nc_dict_QR: dict
#        dict wich stores the QR data.
#
#    Usage
#    -----
#    pollyDisplayQRV1_Ang(nc_dict)
#
#    History
#    -------
#    2022-09-01. First edition by Andi
#    """
#
#    figDPI = nc_dict['figDPI']
#    flagWatermarkOn = nc_dict['flagWatermarkOn']
#    partnerLabel = nc_dict['partnerLabel']
#    matrix = nc_dict['TC']
##    quality_mask = nc_dict['quality_mask_QR_Ang']
##    quality_mask = matrix
#    quality_mask = np.where(matrix > 0, 0, 0)
#    height = nc_dict['height']
#    time = nc_dict['time']
##    LCUsed = np.array([nc_dict[f'LCUsed{wavelength}']])
#    cRange = nc_dict['TC_cRange']
#
#    yLim = nc_dict['yLim']
##    flagLC = nc_dict[f'flagLC{wavelength}']
#    TC_def = nc_dict['TC_def']
#    classes = re.split(r'\\n',TC_def)
#    classes_list = []
#    for i in range(int(cRange[1])+1):
#        T_class = re.split(r'[0-9]: ', classes[i])[1] 
#        classes_list.append(re.split(r'\\', T_class)[0])
#
#    TC_legend_key_red = nc_dict['TC_legend_key_red']
#    TC_legend_key_green = nc_dict['TC_legend_key_green']
#    TC_legend_key_blue = nc_dict['TC_legend_key_blue']
#
#    pollyVersion = nc_dict['PollyVersion']
#    location = nc_dict['location']
#    version = nc_dict['PicassoVersion']
#    fontname = nc_dict['fontname']
#    dataFilename = re.split(r'_target_classification',nc_dict['PollyDataFile'])[0]
#    imgFormat = nc_dict['imgFormat']
#    colormap_basic = nc_dict['colormap_basic']
#    ## generate colorlist for the different classes
#    TC_color_matrix = []
#    for i in range(int(cRange[1])+1):
#        TC_color_matrix.append([TC_legend_key_red[i],TC_legend_key_green[i],TC_legend_key_blue[i]])
#
##    cmap = matplotlib.colors.ListedColormap(['#DAFFFF','#6CFFEC','#209FF3','#BF9AFF','#E5E5E5', '#464AB9','#FFA500',
##                              '#C7FA3A', '#CEBC89','#E64A23','#B43757'])
#    cmap = matplotlib.colors.ListedColormap(TC_color_matrix)
#
#    # set the default font
#    matplotlib.rcParams['font.sans-serif'] = fontname
#    matplotlib.rcParams['font.family'] = "sans-serif"
#
##    saveFolder = args.outdir
#    plotfile = f'{dataFilename}_TC_V2.{imgFormat}'
#
#    ## fill time gaps in att_bsc matrix
#    matrix, quality_mask = readout.fill_time_gaps_of_matrix(time, matrix, quality_mask)
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
#    max_height = [ h for h in height if h < y_max ]
#
#    ## set plot-region for imshow
#    extent = [ x_lims[0], x_lims[-1], max_height[0], max_height[-1] ]
#
#    ## mask matrix
#    matrix = np.ma.masked_where(quality_mask > 0, matrix)
#    
#    ## slice matrix to max_height
#    matrix = matrix[:,0:len(max_height)]
#
#    ## transpose and flip for correct plotting
#    matrix = np.ma.transpose(matrix)  ## matrix has to be transposed for usage with pcolormesh!
#    matrix = np.flip(matrix,0)
#
#    # define the colormap
##    cmap = load_colormap(name=colormap_basic)
#    ## set color of nan-values
#    cmap.set_bad(color='black')
#
#    print(f"plotting {plotfile} ... ")
#    # display attenuate backscatter
#    fig = plt.figure(figsize=[10, 5])
##    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
#    ax = fig.add_axes([0.09, 0.15, 0.67, 0.75])
#
#    pcmesh = ax.imshow(
#            matrix,
#            cmap=cmap,
#            vmin=cRange[0]-0.5,
#            vmax=cRange[1]+0.5,
#            interpolation='none',
#            aspect='auto',
#            extent=extent,
#            )
#    # convert the datetime data from a float (which is the output of date2num into a nice datetime string.
#    ax.xaxis_date()
#
#    ax.set_xlabel('UTC', fontsize=15)
#    ax.set_ylabel('Height (m)', fontsize=15)
#
#    ax.xaxis.set_minor_locator(HourLocator(interval=1))    # every hour
##    ax.xaxis.set_major_locator(HourLocator(interval=2))    # every 4 hours
#    ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))
#    ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))
##    
#    ax.tick_params(
#        axis='both', which='major', labelsize=12, right=True,
#        top=True, width=2, length=5)
#    ax.tick_params(
#        axis='both', which='minor', width=1.5, length=3.5,
#        right=True, top=True)
#
#    ax.set_title(
#        'Target classifications (V2) of {instrument} at {location}'.format(
#            instrument=pollyVersion,
#            location=location),
#        fontsize=15)
#
#    #cb_ax = fig.add_axes([0.92, 0.25, 0.02, 0.55])
#    cb_ax = fig.add_axes([0.77, 0.15, 0.01, 0.75])
#    cbar = fig.colorbar(
#        pcmesh,
#        cax=cb_ax,
#        ticks=np.arange(cRange[0], cRange[1]+1, 1),
#        orientation='vertical')
#    cbar.ax.set_yticklabels(classes_list)
#    cbar.ax.tick_params(direction='out', labelsize=9, pad=5)
##    cbar.ax.set_title('      \n', fontsize=10)
#    # create legend of classes
##    plt.legend([matplotlib.patches.Patch(color=cmap(j)) for j in range(int(cRange[1])+1)], [cl for cl in classes_list])
#
#    # add watermark
#    if flagWatermarkOn:
#        rootDir = os.path.dirname(
#            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
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
#        '{0}'.format(
##            datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
#            nc_dict['m_date']),
#            fontsize=12)
#    fig.text(
#        0.2, 0.02,
#        'Version: {version}'.format(
#            version=version),
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

