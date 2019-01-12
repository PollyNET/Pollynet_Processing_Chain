import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.dates import DateFormatter, DayLocator, HourLocator, MinuteLocator, date2num
from matplotlib import use
use('Agg')
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

def pollyxt_uw_display_rcs(tmpFile, saveFolder):
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
    pollyxt_uw_display_rcs(tmpFile)

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
        mTime = mat['mTime'][0][:]
        height = mat['height'][0][:]
        depCalMask = mat['depCalMask'][0][:]
        fogMask = mat['fogMask'][0][:]
        RCS_FR_355 = mat['RCS_FR_355'][:]
        RCS_FR_532 = mat['RCS_FR_532'][:]
        RCS_FR_1064 = mat['RCS_FR_1064'][:]
        RCS_NR_355 = mat['RCS_NR_355'][:]
        RCS_NR_532 = mat['RCS_NR_532'][:]
        volDepol_355 = mat['volDepol_355'][:]
        volDepol_532 = mat['volDepol_532'][:]
        pollyVersion = mat['taskInfo']['pollyVersion'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
    except Exception as e:
        print('%s has been destroyed' % (tmpFile))
        return

    # meshgrid
    Time, Height = np.meshgrid(mTime, height)
    depCalMask = np.tile(depCalMask, (RCS_FR_1064.shape[0], 1))
    fogMask = np.tile(fogMask, (RCS_FR_1064.shape[0], 1))

    # define the colormap
    cmap = plt.cm.jet
    cmap.set_bad('w', alpha=1)
    cmap.set_over('w', alpha=1)
    cmap.set_under('k', alpha=1)

    # display 355 FR
    # filter out the invalid values
    RCS_FR_355 = np.ma.masked_where(depCalMask != 0, RCS_FR_355)
    RCS_FR_355 = np.ma.masked_where(fogMask == 1, RCS_FR_355)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, RCS_FR_355/1e7, vmin=1e-3, vmax=2, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=14)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Range-Corrected Signal at {wave}nm Far-Range from {instrument} at {location}'.format(wave=355, instrument=pollyVersion, location=location))

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 2.1, 0.2), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=9)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    plt.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_RCS_FR_355.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

    # display 532 FR
    # filter out the invalid values
    RCS_FR_532 = np.ma.masked_where(depCalMask != 0, RCS_FR_532)
    RCS_FR_532 = np.ma.masked_where(fogMask == 1, RCS_FR_532)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, RCS_FR_532/1e7, vmin=1e-3, vmax=2, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=14)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Range-Corrected Signal at {wave}nm Far-Range from {instrument} at {location}'.format(wave=532, instrument=pollyVersion, location=location))

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 2.1, 0.2), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=9)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    plt.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_RCS_FR_532.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

    # display 1064 FR
    # filter out the invalid values
    RCS_FR_1064 = np.ma.masked_where(depCalMask != 0, RCS_FR_1064)
    RCS_FR_1064 = np.ma.masked_where(fogMask == 1, RCS_FR_1064)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, RCS_FR_1064/1e7, vmin=1e-3, vmax=2, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=14)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Range-Corrected Signal at {wave}nm Far-Range from {instrument} at {location}'.format(wave=1064, instrument=pollyVersion, location=location))

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 2.1, 0.2), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=9)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    plt.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_RCS_FR_1064.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

    # display 355 NR
    # filter out the invalid values
    RCS_NR_355 = np.ma.masked_where(depCalMask != 0, RCS_NR_355)
    RCS_NR_355 = np.ma.masked_where(fogMask == 1, RCS_NR_355)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, RCS_NR_355/1e6, vmin=1e-3, vmax=2, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=14)

    ax.set_yticks([0, 500, 1000, 1500, 2000, 2500, 3000])
    ax.set_ylim([0, 3000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Range-Corrected Signal at {wave}nm Near-Range from {instrument} at {location}'.format(wave=355, instrument=pollyVersion, location=location))

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 2.1, 0.2), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=9)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    plt.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_RCS_NR_355.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

    # display 532 NR
    # filter out the invalid values
    RCS_NR_532 = np.ma.masked_where(depCalMask != 0, RCS_NR_532)
    RCS_NR_532 = np.ma.masked_where(fogMask == 1, RCS_NR_532)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, RCS_NR_532/1e6, vmin=1e-3, vmax=2, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=14)

    ax.set_yticks([0, 500, 1000, 1500, 2000, 2500, 3000])
    ax.set_ylim([0, 3000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Range-Corrected Signal at {wave}nm Near-Range from {instrument} at {location}'.format(wave=532, instrument=pollyVersion, location=location))

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 2.1, 0.2), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=9)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    plt.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_RCS_NR_532.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

    # display voldepol 532 
    # filter out the invalid values
    volDepol_532 = np.ma.masked_where(depCalMask != 0, volDepol_532)
    volDepol_532 = np.ma.masked_where(fogMask == 1, volDepol_532)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, volDepol_532, vmin=0.0, vmax=0.4, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=14)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Volume Depolarization Ratio at {wave}nm from {instrument} at {location}'.format(wave=532, instrument=pollyVersion, location=location))

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 0.41, 0.05), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('', fontsize=9)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    plt.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_VDR_532.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

    # display voldepol 355
    # filter out the invalid values
    volDepol_355 = np.ma.masked_where(depCalMask != 0, volDepol_355)
    volDepol_355 = np.ma.masked_where(fogMask == 1, volDepol_355)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, volDepol_355, vmin=0.0, vmax=0.4, cmap=cmap)
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=14)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Volume Depolarization Ratio at {wave}nm from {instrument} at {location}'.format(wave=355, instrument=pollyVersion, location=location))

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 0.41, 0.05), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=10, pad=5)
    cbar.ax.set_title('', fontsize=9)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    plt.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_VDR_355.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

def main():
    pollyxt_uw_display_rcs('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\POLLYXT_UW\\20180517')

if __name__ == '__main__':
    # main()
    pollyxt_uw_display_rcs(sys.argv[1], sys.argv[2])