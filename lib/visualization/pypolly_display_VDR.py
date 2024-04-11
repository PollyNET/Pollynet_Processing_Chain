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


def pollyDisplayVDR(nc_dict,config_dict,polly_conf_dict,saveFolder, wavelength):
    """
    Description
    -----------
    Display the AttBsc of wavelength [nm] channel from level1 polly nc-file.

    Parameters
    ----------
    nc_dict: dict
        dict wich stores the att-bsc data.
    wavelength: int
        the selected wavelength channel: e.g.: 355/532/1064 nm

    Usage
    -----
    pollyDisplayAttnBsc(nc_dict,config_dict,polly_conf_dict,saveFolder, wavelength)

    History
    -------
    2022-09-01. First edition by Andi
    """
    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']

    ## read from polly config file
    yLim = polly_conf_dict['yLim_att_beta']
    zLim = polly_conf_dict[f'zLim_VolDepol_{wavelength}']
    partnerLabel = polly_conf_dict['partnerLabel']
    colormap_basic = polly_conf_dict['colormap_basic']
    flagLC = polly_conf_dict['flagLCCalibration']
    imgFormat = polly_conf_dict['imgFormat']


    VDR = nc_dict[f'VDR_{wavelength}'] 
    quality_mask = nc_dict[f'quality_mask_{wavelength}']
    eta = nc_dict[f'eta{wavelength}']
    height = nc_dict['height']
    time = nc_dict['time']
    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    dataFilename = re.split(r'_vol_depol',nc_dict['PollyDataFile'])[0]

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

#    saveFolder = args.outdir
    plotfile = f'{dataFilename}_VDR_{wavelength}.{imgFormat}'

    ## fill time gaps in att_bsc matrix
    VDR, quality_mask = readout.fill_time_gaps_of_matrix(time, VDR, quality_mask)

    ## get date and convert to datetime object
    date_00 = datetime.strptime(nc_dict['m_date'], '%Y-%m-%d')
    date_00 = date_00.timestamp()

    ## set x-lim to 24h or only to last available timestamp
    x_lims = readout.set_x_lims(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],mdate=date_00,last_timestamp=nc_dict['time'][-1])

    ## convert these datetime.datetime objects to the correct format for matplotlib to work with.
    x_lims = date2num(x_lims)

    ## set max_height
    y_max = yLim[1]
#    y_max = 0.3
    max_height = [ h/1000 for h in height if h < y_max ]

    ## set plot-region for imshow
    extent = [ x_lims[0], x_lims[-1], max_height[0], max_height[-1] ]

    ## mask matrix
    VDR = np.ma.masked_where(quality_mask < 0, VDR)
    
    ## slice matrix to max_height
    VDR = VDR[:,0:len(max_height)]

    ## trimm matrix to last available timestamp if neccessary
    VDR = readout.trimm_matrix_to_last_timestamp(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],matrix=VDR,mdate=date_00,profile_length=int(np.nanmean(np.diff(time))),last_timestamp=nc_dict['time'][-1])

    ## transpose and flip for correct plotting
    VDR= np.ma.transpose(VDR)  ## matrix has to be transposed for usage with pcolormesh!
    VDR= np.flip(VDR,0)

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
            VDR,# * 1e6,
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
    if config_dict['flagPlotLastProfilesOnly'] == True:
        ax.xaxis.set_major_locator(HourLocator(interval=2))
    else:
        ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))

    ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))

  
    ax.tick_params(
        axis='both', which='major', labelsize=15, right=True,
        top=True, width=2, length=5)
    ax.tick_params(
        axis='both', which='minor', width=1.5, length=3.5,
        right=True, top=True)

    ax.set_title(
        'Volume Depolarization Ratio at {wave} nm'.format(wave = wavelength) +
        ' of {instrument} at {location}'.format(
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
        '{0}\n$\eta$: {1}'.format(
            nc_dict['m_date'],eta),
            fontsize=12)
#    fig.text(
#        0.05, 0.02,
#        '{0}\nLC: {1:.2e}'.format(
##            datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
#            nc_dict['m_date'],
#            LCUsed[0]), fontsize=12)
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

