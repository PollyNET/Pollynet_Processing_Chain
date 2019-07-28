import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.dates import DateFormatter, DayLocator, HourLocator, MinuteLocator, date2num
import os, sys
import scipy.io as spio
import numpy as np
from datetime import datetime, timedelta

def celltolist(xtickstr):
    tmp = []
    for iElement in range(0, len(xtickstr)):
        if not len(xtickstr[iElement][0]):
            tmp.append('')
        else:
            tmp.append(xtickstr[iElement][0][0])

    return tmp

def datenum_to_datetime(datenum):
    """
    Convert Matlab datenum into Python datetime.
    :param datenum: Date in datenum format
    :return:        Datetime object corresponding to datenum.
    """
    days = datenum % 1
    hours = days % 1 * 24
    minutes = hours % 1 * 60
    seconds = minutes % 1 * 60
    return datetime.fromordinal(int(datenum)) \
           + timedelta(days=int(days)) \
           + timedelta(hours=int(hours)) \
           + timedelta(minutes=int(minutes)) \
           + timedelta(seconds=round(seconds)) \
- timedelta(days=366)

def rmext(filename):
    file, _ = os.path.splitext(filename)
    return file

def pollyxt_noa_display_att_beta(tmpFile, saveFolder):
    '''
    Description
    -----------
    Display the housekeeping data from laserlogbook file.

    Parameters
    ----------
    - tmpFile: the .mat file which stores the housekeeping data.

    Return
    ------ 

    Usage
    -----
    pollyxt_noa_display_att_beta(tmpFile)

    History
    -------
    2019-01-10. First edition by Zhenping

    Copyright
    ---------
    Ground-based Remote Sensing (TROPOS)
    '''

    if not os.path.exists(tmpFile):
        print('{filename} does not exists.'.format(filename=tmpFile))
        return
    
    # read data
    try:
        mat = spio.loadmat(tmpFile, struct_as_record=True)
        figDPI = mat['figDPI'][0][0]
        ATT_BETA_355 = mat['ATT_BETA_355'][:]
        ATT_BETA_532 = mat['ATT_BETA_532'][:]
        ATT_BETA_1064 = mat['ATT_BETA_1064'][:]
        quality_mask_355 = mat['quality_mask_355'][:]
        quality_mask_532 = mat['quality_mask_532'][:]
        quality_mask_1064 = mat['quality_mask_1064'][:]
        if mat['height'].size:
            height = mat['height'][0][:]
        else:
            height = np.array([])
        if mat['time'].size:
            time = mat['time'][0][:]
        else:
            time = np.array([])
        if mat['att_beta_cRange_355'].size:
            att_beta_cRange_355 = mat['att_beta_cRange_355'][0][:]
        else:
            att_beta_cRange_355 = np.array([])
        if mat['att_beta_cRange_532'].size:
            att_beta_cRange_532 = mat['att_beta_cRange_532'][0][:]
        else:
            att_beta_cRange_532 = np.array([])
        if mat['att_beta_cRange_1064'].size:
            att_beta_cRange_1064 = mat['att_beta_cRange_1064'][0][:]
        else:
            att_beta_cRange_1064 = np.array([])
        flagLC355 = mat['flagLC355'][:][0]
        flagLC532 = mat['flagLC532'][:][0]
        flagLC1064 = mat['flagLC1064'][:][0]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
    except Exception as e:
        print('Failed reading %s' % (tmpFile))
        return

    # meshgrid
    Time, Height = np.meshgrid(time, height)
    ATT_BETA_355 = np.ma.masked_where(quality_mask_355 > 0, ATT_BETA_355)
    ATT_BETA_532 = np.ma.masked_where(quality_mask_532 > 0, ATT_BETA_532)
    ATT_BETA_1064 = np.ma.masked_where(quality_mask_1064 > 0, ATT_BETA_1064)

    # define the colormap
    cmap = plt.cm.jet
    cmap.set_bad('w', alpha=1)
    cmap.set_over('w', alpha=1)
    cmap.set_under('k', alpha=1)

    # display attenuate backscatter at 355 FR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, ATT_BETA_355 * 1e6, vmin=0, vmax=15, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Attenuated Backscatter at {wave}nm Far-Range from {instrument} at {location}'.format(wave=355, instrument=pollyVersion, location=location), fontweight='bold', fontsize=12)

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.linspace(att_beta_cRange_355[0], att_beta_cRange_355[1], 5), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('[$Mm^{-1}*Sr^{-1}$]', fontsize=8)

    fig.text(0.05, 0.04, datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.02, 'Version: {version}\nCalibration: {method}'.format(version=version, method=flagLC355), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_ATT_BETA_355.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()

    # display attenuate backscatter at 532 FR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, ATT_BETA_532 * 1e6, vmin=0, vmax=5, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Attenuated Backscatter at {wave}nm Far-Range from {instrument} at {location}'.format(wave=532, instrument=pollyVersion, location=location), fontweight='bold', fontsize=12)

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.linspace(att_beta_cRange_532[0], att_beta_cRange_532[1], 5), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('[$Mm^{-1}*Sr^{-1}$]', fontsize=8)

    fig.text(0.05, 0.04, datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.02, 'Version: {version}\nCalibration: {method}'.format(version=version, method=flagLC532), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_ATT_BETA_532.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()
    
    # display attenuate backscatter at 1064 FR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, ATT_BETA_1064 * 1e6, vmin=att_beta_cRange_1064[0], vmax=att_beta_cRange_1064[1], cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Attenuated Backscatter at {wave}nm Far-Range from {instrument} at {location}'.format(wave=1064, instrument=pollyVersion, location=location), fontweight='bold', fontsize=12)

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.linspace(att_beta_cRange_1064[0], att_beta_cRange_1064[1], 5), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('[$Mm^{-1}*Sr^{-1}$]', fontsize=8)

    fig.text(0.05, 0.04, datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.02, 'Version: {version}\nCalibration: {method}'.format(version=version, method=flagLC1064), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_ATT_BETA_1064.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()

def main():
    pollyxt_noa_display_att_beta('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\POLLYXT_NOA\\20180517')

if __name__ == '__main__':
    # main()
    pollyxt_noa_display_att_beta(sys.argv[1], sys.argv[2])