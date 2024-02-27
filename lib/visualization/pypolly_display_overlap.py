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
import json
from pathlib import Path
import argparse
import pypolly_readout_profiles as readout_profiles
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



def pollyDisplay_Overlap(nc_dict,config_dict,polly_conf_dict,outdir):
    """
    Description
    -----------
    Display the overlap functions from level1 polly nc-file.

    Parameters
    ----------
    nc_dict_profile: dict
        dict wich stores the overlap data.

    Usage
    -----
    pollyDisplay_Overlap(nc_dict,config_dict,polly_conf_dict)

    History
    -------
    2022-09-01. First edition by Andi
    """

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']

    ## read from global config file
    xLim = [-0.1, 1.1]
    yLim = polly_conf_dict['yLim_att_beta_NR']
    partnerLabel = polly_conf_dict['partnerLabel']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc-file
    overlap355 = nc_dict['OL_355'].reshape(-1)
    overlap355Defaults = nc_dict['OL_355'].reshape(-1)
    overlap532 = nc_dict['OL_532'].reshape(-1)
    overlap532Defaults = nc_dict['OL_532d'].reshape(-1)
    height = nc_dict['height']

    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    dataFilename = re.split(r'_overlap',nc_dict['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.family'] = "sans-serif"

    saveFolder = outdir
    plotfile = f'{dataFilename}_overlap.{imgFormat}'

    # display WVMR-profile
    fig = plt.figure(figsize=[5, 8])
    ax = fig.add_axes([0.21, 0.15, 0.74, 0.75])

    # display signal
    p1, = ax.plot(overlap355, height, color='#1544E9',
                   linestyle='-', label=r'overlap 355 FR')
    p2, = ax.plot(overlap532, height, color='#58B13F',
                   linestyle='-', label=r'overlap 532 FR')
    p3, = ax.plot(overlap355Defaults, height, color='#1544E9',
                   linestyle='--', label=r'default overlap 355 FR')
    p4, = ax.plot(overlap532Defaults, height, color='#58B13F',
                   linestyle='--', label=r'default overlap 532 FR')

    ax.set_xlabel('Overlap', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_ylim(yLim)
    ax.yaxis.set_major_locator(MultipleLocator(500))
    ax.yaxis.set_minor_locator(MultipleLocator(100))
    ax.set_xlim(xLim)
    ax.grid(True)
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

#    starttime = time[startInd - 1]
#    endtime = time[endInd - 1]
    ax.set_title(
        'Overlap for {instrument} at {location}\n[Averaged] {date}'.format(
            instrument=pollyVersion,
            location=location,
            date=nc_dict['m_date'],
#            starttime=datetime.utcfromtimestamp(int(starttime)).strftime('%Y%m%d %H:%M'),
#            endtime=datetime.utcfromtimestamp(int(endtime)).strftime('%H:%M'),
#            starttime=starttime.strftime('%Y%m%d %H:%M'),
#            endtime=endtime.strftime('%H:%M')
            ),
        fontsize=14
        )


    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        rootDir = os.getcwd()
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.58, 0.006, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.05, 0.01, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.84, 0.01,
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
        0.3, 0.02,
        'Version: {version}'.format(
            version=version),
        fontsize=12)
    print(f"plotting {plotfile} ... ")
    fig.savefig(
        os.path.join(
            saveFolder,
            plotfile),
        dpi=figDPI)

    plt.close()


