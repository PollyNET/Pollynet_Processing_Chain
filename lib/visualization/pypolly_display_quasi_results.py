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


def pollyDisplayQR(nc_dict,config_dict, polly_conf_dict, saveFolder, q_param, q_version):
    """
    Description
    -----------
    Display the quasi results V1 from the Angstrom exponent 532-1064 nm from level1 polly nc-file.

    Parameters
    ----------
    nc_dict: dict
        dict wich stores the QR data.

    Usage
    -----
    pollyDisplayQR_Ang(nc_dict,config_dict, polly_conf_dict, saveFolder, q_param,  q_version):
    q_param can be "angexp", "bsc_532", "bsc_1064", "par_depol_532"
    q_version can be "V1" or "V2"

    History
    -------
    2022-09-01. First edition by Andi
    """
    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']

    ## read from global config file
    yLim = polly_conf_dict['yLim_Quasi_Params']
    if q_param == "angexp" or q_param == "bsc_1064":
        zLim = polly_conf_dict['zLim_quasi_beta_1064']
    elif q_param == "bsc_532":
        zLim = polly_conf_dict['zLim_quasi_beta_532']        
    elif q_param == "par_depol_532":
        zLim = polly_conf_dict['zLim_quasi_Par_DR_532']

    partnerLabel = polly_conf_dict['partnerLabel']
    colormap_basic = polly_conf_dict['colormap_basic']
    flagLC = polly_conf_dict['flagLCCalibration']
    imgFormat = polly_conf_dict['imgFormat']

    if q_param == "angexp":
        matrix = nc_dict['QR_Ang']
        quality_mask = np.where(matrix > 0, 0, 0)
    elif q_param == "bsc_532":
        matrix = nc_dict['QR_Bsc_532']
        quality_mask = nc_dict['quality_mask_532']
    elif q_param == "bsc_1064":
        matrix = nc_dict['QR_Bsc_1064']
        quality_mask = nc_dict['quality_mask_1064']
    elif q_param == "par_depol_532":
        matrix = nc_dict['QR_ParDepol_532']
        quality_mask = nc_dict['quality_mask_voldepol']
    
    height = nc_dict['height']
    time = nc_dict['time']

    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    dataFilename = re.split(r'_quasi_results',nc_dict['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    if q_param == "angexp":
        if q_version == "V1":
            plotfile = f'{dataFilename}_Quasi_ANGEXP_532_1064.{imgFormat}'
        if q_version == "V2":
            plotfile = f'{dataFilename}_Quasi_ANGEXP_532_1064_V2.{imgFormat}'
        quasi_title = f'Quasi BSC Angstroem Exponent 532-1064 ({q_version}) of {pollyVersion} at {location}'
    if q_param == "bsc_532":
        if q_version == "V1":
            plotfile = f'{dataFilename}_Quasi_Bsc_532.{imgFormat}'
        if q_version == "V2":
            plotfile = f'{dataFilename}_Quasi_Bsc_532_V2.{imgFormat}'
        quasi_title = f'Quasi backscatter coefficient ({q_version}) at 532 nm from {pollyVersion} at {location}'
    if q_param == "bsc_1064":
        if q_version == "V1":
            plotfile = f'{dataFilename}_Quasi_Bsc_1064.{imgFormat}'
        if q_version == "V2":
            plotfile = f'{dataFilename}_Quasi_Bsc_1064_V2.{imgFormat}'
        quasi_title = f'Quasi backscatter coefficient ({q_version}) at 1064 nm from {pollyVersion} at {location}'
    if q_param == "par_depol_532":
        if q_version == "V1":
            plotfile = f'{dataFilename}_Quasi_PDR_532.{imgFormat}'
        if q_version == "V2":
            plotfile = f'{dataFilename}_Quasi_PDR_532_V2.{imgFormat}'
        quasi_title = f'Quasi particle depolarization ratio ({q_version}) at 532 nm from {pollyVersion} at {location}'

    ## fill time gaps in att_bsc matrix
    matrix, quality_mask = readout.fill_time_gaps_of_matrix(time, matrix, quality_mask)

    ## get date and convert to datetime object
    date_00 = datetime.strptime(nc_dict['m_date'], '%Y-%m-%d')
    date_00 = date_00.timestamp()

    ## set x-lim to 24h or only to last available timestamp
    x_lims = readout.set_x_lims(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],mdate=date_00,last_timestamp=nc_dict['time'][-1])

    ## convert these datetime.datetime objects to the correct format for matplotlib to work with.
    x_lims = date2num(x_lims)

    ## set max_height
    y_max = yLim[1]
    max_height = [ h/1000 for h in height if h < y_max ]

    ## set plot-region for imshow
    extent = [ x_lims[0], x_lims[-1], max_height[0], max_height[-1] ]

    ## mask matrix
    matrix = np.ma.masked_where(quality_mask < 0, matrix)
    
    ## slice matrix to max_height
    matrix = matrix[:,0:len(max_height)]

    ## trimm matrix to last available timestamp if neccessary
    matrix = readout.trimm_matrix_to_last_timestamp(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],matrix=matrix,mdate=date_00,profile_length=int(np.nanmean(np.diff(time))),last_timestamp=nc_dict['time'][-1])

    ## transpose and flip for correct plotting
    matrix = np.ma.transpose(matrix)  ## matrix has to be transposed for usage with pcolormesh!
    matrix = np.flip(matrix,0)

    # define the colormap
    cmap = load_colormap(name=colormap_basic)
    #colormap_basic = "turbo"
    #import copy
    #cmap =copy.copy(plt.cm.get_cmap(colormap_basic))
    ## set color of nan-values
    cmap.set_bad(color='white')

    print(f"plotting {plotfile} ... ")
    # display attenuate backscatter
    fig = plt.figure(figsize=[12, 6])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.imshow(
            matrix,
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

    ax.set_title(quasi_title, fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.25, 0.02, 0.55])
    cbar = fig.colorbar(
        pcmesh,
        cax=cb_ax,
        ticks=np.linspace(zLim[0], zLim[1], 5),
        orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
    cbar.ax.set_title('      \n', fontsize=10)

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


