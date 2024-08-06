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



def pollyDisplayAttnBsc(nc_dict, config_dict, polly_conf_dict, saveFolder, wavelength, param,donefilelist_dict):
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
        prod_type = ''
    elif param == 'NR':
        plotfile = f'{dataFilename}_ATT_BETA_NR_{wavelength}.{imgFormat}'
        plotfile_SNR = f'{dataFilename}_ATT_BETA_NR_{wavelength}_SNR.{imgFormat}'
        prod_type = '_NR'
    elif param == 'OC':
        plotfile = f'{dataFilename}_ATT_BETA_OC_{wavelength}.{imgFormat}'
        plotfile_SNR = f'{dataFilename}_ATT_BETA_OC_{wavelength}_SNR.{imgFormat}'
        prod_type = '_OC'

    saveFilename = os.path.join(saveFolder,plotfile)
    saveFilename_SNR = os.path.join(saveFolder,plotfile_SNR)


    ## fill time gaps in att_bsc matrix
    ATT_BETA, quality_mask_ATT = readout.fill_time_gaps_of_matrix(time, ATT_BETA, quality_mask)
    

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
    ATT_BETA = np.ma.masked_where(quality_mask_ATT < 0, ATT_BETA)
    
    ## slice matrix to max_height
    ATT_BETA = ATT_BETA[:,0:len(max_height)]

    ## trimm matrix to last available timestamp if neccessary
    ATT_BETA = readout.trimm_matrix_to_last_timestamp(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],matrix=ATT_BETA,mdate=date_00,profile_length=int(np.nanmean(np.diff(time))),last_timestamp=nc_dict['time'][-1])

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
    if config_dict['flagPlotLastProfilesOnly'] == True:
        ax.xaxis.set_major_locator(HourLocator(interval=2))
    else:
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
        #rootDir = os.getcwd()
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

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = wavelength,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"ATT_BETA plots for {param}",
                                    nc_zip_file = nc_dict['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'ATT_BETA_{wavelength}{prod_type}',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                    )
    

    ## plotting SNR
    if param == 'FR' or param == 'NR':
        ## fill time gaps in snr matrix
        SNR, quality_mask_SNR = readout.fill_time_gaps_of_matrix(time, SNR, quality_mask)

        ## mask matrix
        SNR = np.ma.masked_where(quality_mask_SNR < 0, SNR)


        ## slice matrix to max_height
        SNR = SNR[:,0:len(max_height)]

        ## trimm matrix to last available timestamp if neccessary
        SNR = readout.trimm_matrix_to_last_timestamp(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],matrix=SNR,mdate=date_00,profile_length=int(np.nanmean(np.diff(time))),last_timestamp=nc_dict['time'][-1])
	
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
        if config_dict['flagPlotLastProfilesOnly'] == True:
            ax.xaxis.set_major_locator(HourLocator(interval=2))
        else:
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
        #    rootDir = os.getcwd()
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
    
        fig.savefig(saveFilename_SNR,dpi=figDPI)
    
        plt.close()

        ## write2donefilelist
        readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                        lidar = pollyVersion,
                                        location = nc_dict['location'],
                                        starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                        stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                        last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                        wavelength = wavelength,
                                        filename = saveFilename_SNR,
                                        level = 0,
                                        info = f"ATT_BETA plots for {param}",
                                        nc_zip_file = nc_dict['PollyDataFile'],
                                        nc_zip_file_size = 9000000,
                                        active = 1,
                                        GDAS = 0,
                                        GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                        lidar_ratio = 50,
                                        software_version = version,
                                        product_type = f'SNR_{param}_{wavelength}',
                                        product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                        product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                        )



def pollyDisplayATT_BSC_cloudinfo(nc_dict, config_dict, polly_conf_dict, saveFolder, wavelength,donefilelist_dict):
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
    flagPlotLastProfilesOnly = config_dict['flagPlotLastProfilesOnly']

    ## read from global config file
    #yLim = polly_conf_dict['yLim_att_beta']
    yLim = polly_conf_dict['yLim_cloudinfo']
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
    saveFilename = os.path.join(saveFolder,plotfile)

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
    ATT_BETA = np.ma.masked_where(quality_mask < 0, ATT_BETA)
    
    ## slice matrix to max_height
    ATT_BETA = ATT_BETA[:,0:len(max_height)]

    ## trimm matrix to last available timestamp if neccessary
    ATT_BETA = readout.trimm_matrix_to_last_timestamp(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],matrix=ATT_BETA,mdate=date_00,profile_length=int(np.nanmean(np.diff(time))),last_timestamp=nc_dict['time'][-1])

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

    ax.scatter(dt_list,cbh_layer_list[0]/1000, color='#111', marker='o', s=lw, label='CBH')
    ax.scatter(dt_list,cth_layer_list[0]/1000, color='#666', marker='D', s=lw, label='CTH')
    ax.set_ylim(yLim[0]/1000,yLim[1]/1000)
    ax.legend(loc=1)
    for layer in range(1,len(cbh_layer_list)):
        ax.scatter(dt_list,cbh_layer_list[layer]/1000, color='#111', marker='o', s=lw, label='CBH')
    for layer in range(1,len(cth_layer_list)):
        ax.scatter(dt_list,cth_layer_list[layer]/1000, color='#666', marker='D', s=lw, label='CTH')
                
                

#    ax.scatter(dt_list,nc_dict_cloudinfo['cloud_base_height'].T[0], color='#111', marker='o', s=lw, label='CBH')
#    ax.scatter(dt_list,nc_dict_cloudinfo['cloud_top_height'].T[0], color='#666', marker='D', s=lw, label='CTH')
#    ax.legend(loc=1) 

    # add watermark
    if flagWatermarkOn:
        #rootDir = os.getcwd()
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

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = wavelength,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"ATT_BETA + Cloudinfo plots for {wavelength}",
                                    nc_zip_file = nc_dict['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'CLOUDINFO_{wavelength}',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                    )
    

def pollyDisplayVDR(nc_dict,config_dict,polly_conf_dict,saveFolder, wavelength,donefilelist_dict):
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


    VDR = nc_dict[f'volume_depolarization_ratio_{wavelength}nm'] 
    quality_mask = np.where(VDR > 0, 0, 0)
    eta = re.split(r'eta:',nc_dict[f'volume_depolarization_ratio_{wavelength}nm___comment'])[1]
    eta = float(re.split(r'\)',eta)[0])
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
    saveFilename = os.path.join(saveFolder,plotfile)

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
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        #rootDir = os.getcwd()
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

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = wavelength,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"VolDepol plots for {wavelength}",
                                    nc_zip_file = nc_dict['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'VDR_{wavelength}',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                    )


def pollyDisplayWVMR(nc_dict,config_dict,polly_conf_dict,saveFolder,donefilelist_dict):
    """
    Description
    -----------
    Display the water vapor mixing ratio WVMR from level1 polly nc-file.

    Parameters
    ----------
    nc_dict: dict
        dict wich stores the WV data.

    Usage
    -----
    pollyDisplayWVMR(nc_dict,config_dict,polly_conf_dict)
    History
    -------
    2022-09-01. First edition by Andi
    """

    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']


    ## read from global config file
    yLim = polly_conf_dict['yLim_WV_RH']
    zLim = polly_conf_dict['xLim_Profi_WVMR']
    partnerLabel = polly_conf_dict['partnerLabel']
    colormap_basic = polly_conf_dict['colormap_basic']
    imgFormat = polly_conf_dict['imgFormat']

    ## read from nc-file
    WVMR = nc_dict['WVMR']
    quality_mask = nc_dict['QM_WVMR']
    height = nc_dict['height']
    time = nc_dict['time']

    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    dataFilename = re.split(r'_WVMR_RH',nc_dict['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    plotfile = f'{dataFilename}_WVMR.{imgFormat}'
    saveFilename = os.path.join(saveFolder,plotfile)

    ## fill time gaps in att_bsc matrix
    WVMR, quality_mask = readout.fill_time_gaps_of_matrix(time, WVMR, quality_mask)

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
    WVMR = np.ma.masked_where(quality_mask< 0, WVMR)
    
    ## slice matrix to max_height
    WVMR = WVMR[:,0:len(max_height)]

    ## trimm matrix to last available timestamp if neccessary
    WVMR = readout.trimm_matrix_to_last_timestamp(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],matrix=WVMR,mdate=date_00,profile_length=int(np.nanmean(np.diff(time))),last_timestamp=nc_dict['time'][-1])

    ## transpose and flip for correct plotting
    WVMR= np.ma.transpose(WVMR)  ## matrix has to be transposed for usage with pcolormesh!
    WVMR= np.flip(WVMR,0)

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
            WVMR,
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
        'Water vapour mixing ratio of {instrument} at {location}'.format(
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
    cbar.ax.set_title('      [$\mathrm{g\, kg^{-1}}$]\n', fontsize=10)

    # add watermark
    if flagWatermarkOn:
        #rootDir = os.getcwd()
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

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = 407,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"WaterVaporMixingRatio plots with WV calibration constant {nc_dict['WVMR___wv_calibration_constant_used']}",
                                    nc_zip_file = nc_dict['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'WVMR',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                    )



def pollyDisplayRH(nc_dict,config_dict,polly_conf_dict,saveFolder,donefilelist_dict):
    """
    Description
    -----------
    Display the relative humidity RH from level1 polly nc-file.

    Parameters
    ----------
    nc_dict: dict
        dict wich stores the WV data.

    Usage
    -----
    pollyDisplayRH(nc_dict,config_dict,polly_conf_dict)

    History
    -------
    2022-09-01. First edition by Andi
    """
    ## read from config file
    figDPI = config_dict['figDPI']
    flagWatermarkOn = config_dict['flagWatermarkOn']
    fontname = config_dict['fontname']


    ## read from global config file
    yLim = polly_conf_dict['yLim_WV_RH']
    zLim = [0,100]
    partnerLabel = polly_conf_dict['partnerLabel']
    colormap_basic = polly_conf_dict['colormap_basic']
    imgFormat = polly_conf_dict['imgFormat']

    RH = nc_dict['RH']
    quality_mask = nc_dict['QM_RH']
    height = nc_dict['height']
    time = nc_dict['time']

    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    dataFilename = re.split(r'_WVMR_RH',nc_dict['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    plotfile = f'{dataFilename}_RH.{imgFormat}'
    saveFilename = os.path.join(saveFolder,plotfile)

    ## fill time gaps in att_bsc matrix
    RH, quality_mask = readout.fill_time_gaps_of_matrix(time, RH, quality_mask)

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
    RH = np.ma.masked_where(quality_mask< 0, RH)
    
    ## slice matrix to max_height
    RH = RH[:,0:len(max_height)]

    ## trimm matrix to last available timestamp if neccessary
    RH = readout.trimm_matrix_to_last_timestamp(flagPlotLastProfilesOnly=config_dict['flagPlotLastProfilesOnly'],matrix=RH,mdate=date_00,profile_length=int(np.nanmean(np.diff(time))),last_timestamp=nc_dict['time'][-1])

    ## transpose and flip for correct plotting
    RH = np.ma.transpose(RH)  ## matrix has to be transposed for usage with pcolormesh!
    RH = np.flip(RH,0)

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
            RH,
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
        'Relative humidity of {instrument} at {location}'.format(
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
    cbar.ax.set_title('      [$\mathrm{\%}$]\n', fontsize=10)

    # add watermark
    if flagWatermarkOn:
        #rootDir = os.getcwd()
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

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = 407,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"Rel.Humidity plots with WV calibration constant {nc_dict['WVMR___wv_calibration_constant_used']}",
                                    nc_zip_file = nc_dict['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = 'RH',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                    )


def pollyDisplayTargetClass(nc_dict,config_dict, polly_conf_dict, saveFolder, c_version, donefilelist_dict):
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

    matrix = nc_dict['target_classification']
    quality_mask = np.where(matrix > 0, 0, 0)
    height = nc_dict['height']
    time = nc_dict['time']
    cRange = nc_dict['target_classification___plot_range'] ## equals zLim and the number of classes in the target classification
    TC_def = nc_dict['target_classification___definition']
    classes = re.split(r'\\n',TC_def)
    classes_list = []
    for i in range(int(cRange[1])+1):
        T_class = re.split(r'[0-9]: ', classes[i])[1] 
        classes_list.append(re.split(r'\\', T_class)[0])

    TC_legend_key_red = nc_dict['target_classification___legend_key_red']
    TC_legend_key_green = nc_dict['target_classification___legend_key_green']
    TC_legend_key_blue = nc_dict['target_classification___legend_key_blue']

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
        prodtype = ""
    if c_version == "V2":
        plotfile = f'{dataFilename}_TC_V2.{imgFormat}'
        prodtype = "_v2"
    saveFilename = os.path.join(saveFolder,plotfile)

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
#    cmap = load_colormap(name=colormap_basic)
    ## set color of nan-values
    #cmap.set_bad(color='black')
    cmap.set_bad(color='white')

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
    if config_dict['flagPlotLastProfilesOnly'] == True:
        ax.xaxis.set_major_locator(HourLocator(interval=2))
    else:
        ax.xaxis.set_major_locator(HourLocator(byhour = [4,8,12,16,20,24]))

    ax.xaxis.set_major_formatter(DateFormatter('%H:%M'))

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
        #rootDir = os.getcwd()  
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

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = 355,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"Lidar Target Categorization {c_version}",
                                    nc_zip_file = nc_dict['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'TC{prodtype}',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                    )


def pollyDisplayQR(nc_dict,config_dict, polly_conf_dict, saveFolder, q_param, q_version,donefilelist_dict):
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
        matrix = nc_dict['quasi_ang_532_1064']
        quality_mask = np.where(matrix > 0, 0, 0)
    elif q_param == "bsc_532":
        matrix = nc_dict['quasi_bsc_532']
        quality_mask = nc_dict['quality_mask_532']
    elif q_param == "bsc_1064":
        matrix = nc_dict['quasi_bsc_1064']
        quality_mask = nc_dict['quality_mask_1064']
    elif q_param == "par_depol_532":
        matrix = nc_dict['quasi_pardepol_532']
        #quality_mask = nc_dict['quality_mask_voldepol']
        quality_mask = nc_dict['quality_mask_voldepol_532']
    
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
        prodtype = "Quasi_ANGEXP_532_1064"
        wavelength = 532
        if q_version == "V1":
            plotfile = f'{dataFilename}_Quasi_ANGEXP_532_1064.{imgFormat}'
        if q_version == "V2":
            plotfile = f'{dataFilename}_Quasi_ANGEXP_532_1064_V2.{imgFormat}'
        quasi_title = f'Quasi BSC Angstroem Exponent 532-1064 ({q_version}) of {pollyVersion} at {location}'
    if q_param == "bsc_532":
        prodtype = "Quasi_Bsc_532"
        wavelength = 532
        if q_version == "V1":
            plotfile = f'{dataFilename}_Quasi_Bsc_532.{imgFormat}'
        if q_version == "V2":
            plotfile = f'{dataFilename}_Quasi_Bsc_532_V2.{imgFormat}'
        quasi_title = f'Quasi backscatter coefficient ({q_version}) at 532 nm from {pollyVersion} at {location}'
    if q_param == "bsc_1064":
        prodtype = "Quasi_Bsc_1064"
        wavelength = 1064
        if q_version == "V1":
            plotfile = f'{dataFilename}_Quasi_Bsc_1064.{imgFormat}'
        if q_version == "V2":
            plotfile = f'{dataFilename}_Quasi_Bsc_1064_V2.{imgFormat}'
        quasi_title = f'Quasi backscatter coefficient ({q_version}) at 1064 nm from {pollyVersion} at {location}'
    if q_param == "par_depol_532":
        prodtype = "Quasi_PDR_532"
        wavelength = 532
        if q_version == "V1":
            plotfile = f'{dataFilename}_Quasi_PDR_532.{imgFormat}'
        if q_version == "V2":
            plotfile = f'{dataFilename}_Quasi_PDR_532_V2.{imgFormat}'
        quasi_title = f'Quasi particle depolarization ratio ({q_version}) at 532 nm from {pollyVersion} at {location}'

    saveFilename = os.path.join(saveFolder,plotfile)

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
        #rootDir = os.getcwd() 
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

    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = wavelength,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"{prodtype} {q_version}",
                                    nc_zip_file = nc_dict['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = f'{prodtype}',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                    )


def pollyDisplay_Overlap(nc_dict,config_dict,polly_conf_dict,outdir,donefilelist_dict):
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
    #overlap355 = nc_dict['OL_355'].reshape(-1)
    #overlap355Defaults = nc_dict['OL_355'].reshape(-1)
    #overlap532 = nc_dict['OL_532'].reshape(-1)
    #overlap532Defaults = nc_dict['OL_532d'].reshape(-1)
    overlap355 = nc_dict['overlap355'].reshape(-1)
    overlap355Defaults = nc_dict['overlap355Defaults'].reshape(-1)
    overlap532 = nc_dict['overlap532'].reshape(-1)
    overlap532Defaults = nc_dict['overlap532Defaults'].reshape(-1)
    overlap355Raman = nc_dict['overlap355Raman'].reshape(-1)
    overlap532Raman = nc_dict['overlap532Raman'].reshape(-1)
    height = nc_dict['height']/1000

    pollyVersion = nc_dict['PollyVersion']
    location = nc_dict['location']
    version = nc_dict['PicassoVersion']
    dataFilename = re.split(r'_overlap',nc_dict['PollyDataFile'])[0]
    # set the default font
    matplotlib.rcParams['font.family'] = "sans-serif"

    saveFolder = outdir
    plotfile = f'{dataFilename}_overlap.{imgFormat}'
    saveFilename = os.path.join(saveFolder,plotfile)


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
    p5, = ax.plot(overlap355Raman, height, color='#2affff',
                   linestyle='-', label=r'overlap 355 FR Raman')
    p6, = ax.plot(overlap532Raman, height, color='#d4d42a',
                   linestyle='-', label=r'overlap 532 FR Raman')

    ax.set_xlabel('Overlap', fontsize=15)
    ax.set_ylabel('Height (km)', fontsize=15)

#    ax.set_ylim(yLim)
    ax.set_ylim(yLim[0]/1000,yLim[1]/1000)
    ax.yaxis.set_major_locator(MultipleLocator(0.5))
    ax.yaxis.set_minor_locator(MultipleLocator(0.1))
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

    plt.legend(loc='upper right')

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
#        rootDir = os.getcwd()
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.58, 0.006, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.05, 0.01, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.72, 0.003,
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=7, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)
#        fig.text(
#            0.84, 0.003,
#            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
#                datetime.now().strftime('%Y'), partnerLabel),
#            fontweight='bold', fontsize=7, color='black', ha='left',
#            va='bottom', alpha=1, zorder=10)

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
    fig.savefig(saveFilename,dpi=figDPI)

    plt.close()

    ## write2donefilelist
    readout.write2donefilelist_dict(donefilelist_dict = donefilelist_dict,
                                    lidar = pollyVersion,
                                    location = nc_dict['location'],
                                    starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S'),
                                    last_update = datetime.now(timezone.utc).strftime("%Y%m%d %H:%M:%S"),
                                    wavelength = 407,
                                    filename = saveFilename,
                                    level = 0,
                                    info = f"overlap function",
                                    nc_zip_file = nc_dict['PollyDataFile'],
                                    nc_zip_file_size = 9000000,
                                    active = 1,
                                    GDAS = 0,
                                    GDAS_timestamp = f"{datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d')} 12:00:00",
                                    lidar_ratio = 50,
                                    software_version = version,
                                    product_type = 'overlap',
                                    product_starttime = datetime.utcfromtimestamp(int(nc_dict['time'][0])).strftime('%Y%m%d %H:%M:%S'),
                                    product_stoptime = datetime.utcfromtimestamp(int(nc_dict['time'][-1])).strftime('%Y%m%d %H:%M:%S')
                                    )


