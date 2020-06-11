import os
import sys
import scipy.io as spio
import numpy as np
from datetime import datetime, timedelta
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
from matplotlib.colors import ListedColormap
from matplotlib.dates import DateFormatter, DayLocator, HourLocator, \
    MinuteLocator, date2num
plt.switch_backend('Agg')


def celltolist(xtickstr):
    """
    convert list of list to list of string.

    Examples
    --------

    [['2010-10-11'], [], ['2011-10-12]] =>
    ['2010-10-11], '', '2011-10-12']
    """

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

    Parameters
    ----------
    Date: float

    Returns
    -------
    dtObj: datetime object

    """
    days = datenum % 1
    hours = days % 1 * 24
    minutes = hours % 1 * 60
    seconds = minutes % 1 * 60

    dtObj = datetime.fromordinal(int(datenum)) + \
        timedelta(days=int(days)) + \
        timedelta(hours=int(hours)) + \
        timedelta(minutes=int(minutes)) + \
        timedelta(seconds=round(seconds)) - timedelta(days=366)

    return dtObj


def rmext(filename):
    """
    remove the file extension.

    Parameters
    ----------
    filename: str
    """

    file, _ = os.path.splitext(filename)
    return file


def pollyxt_ift_display_rcs(tmpFile, saveFolder):
    """
    Description
    -----------
    Display the housekeeping data from laserlogbook file.

    Parameters
    ----------
    tmpFile: str
    the .mat file which stores the housekeeping data.

    saveFolder: str

    Usage
    -----
    pollyxt_ift_display_rcs(tmpFile, saveFolder)

    History
    -------
    2019-01-10. First edition by Zhenping
    """

    if not os.path.exists(tmpFile):
        print('{filename} does not exists.'.format(filename=tmpFile))
        return

    # read matlab .mat data
    try:
        mat = spio.loadmat(tmpFile, struct_as_record=True)
        figDPI = mat['figDPI'][0][0]
        mTime = mat['mTime'][0][:]
        height = mat['height'][0][:]
        depCalMask = mat['depCalMask'][0][:]
        fogMask = mat['fogMask'][0][:]
        RCS_FR_355 = mat['RCS_FR_355'][:]
        RCS_FR_532 = mat['RCS_FR_532'][:]
        RCS_FR_1064 = mat['RCS_FR_1064'][:]
        RCS_NR_532 = mat['RCS_NR_532'][:]
        RCS_NR_355 = mat['RCS_NR_355'][:]
        volDepol_532 = mat['volDepol_532'][:]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        yLim_FR_RCS = mat['yLim_FR_RCS'][:][0]
        yLim_NR_RCS = mat['yLim_NR_RCS'][:][0]
        yLim_FR_DR = mat['yLim_FR_DR'][:][0]
        RCS355FRColorRange = mat['RCS355FRColorRange'][:][0]
        RCS532FRColorRange = mat['RCS532FRColorRange'][:][0]
        RCS1064FRColorRange = mat['RCS1064FRColorRange'][:][0]
        RCS355NRColorRange = mat['RCS355NRColorRange'][:][0]
        RCS532NRColorRange = mat['RCS532NRColorRange'][:][0]
        Voldepol532ColorRange = mat['Voldepol532ColorRange'][:][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
        imgFormat = mat['imgFormat'][:][0]
    except Exception as e:
        print(e)
        print('Failed reading %s' % (tmpFile))
        return

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # meshgrid
    Time, Height = np.meshgrid(mTime, height)
    depCalMask = np.tile(depCalMask, (RCS_FR_1064.shape[0], 1))
    fogMask = np.tile(fogMask, (RCS_FR_1064.shape[0], 1))

    # define the colormap
    cmap = plt.cm.jet
    cmap.set_bad('k', alpha=1)
    cmap.set_over('w', alpha=1)
    cmap.set_under('k', alpha=1)

    # display 355 FR
    # filter out the invalid values
    RCS_FR_355 = np.ma.masked_where(depCalMask != 0, RCS_FR_355)
    RCS_FR_355 = np.ma.masked_where(fogMask == 1, RCS_FR_355)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, RCS_FR_355/1e6,
        vmin=RCS355FRColorRange[0], vmax=RCS355FRColorRange[1], cmap=cmap,
        rasterized=True)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_ylim([yLim_FR_RCS[0], yLim_FR_RCS[1]])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Range-Corrected Signal at ' +
        '{wave}nm Far-Range from {instrument} at {location}'.format(
            wave=355, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(
        pcmesh, cax=cb_ax, orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=12, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(
        mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(
        version=version), fontsize=14)

    fig.savefig(
        os.path.join(
            saveFolder, '{dataFilename}_RCS_FR_355.{imgFormat}'.format(
                dataFilename=rmext(dataFilename),
                imgFormat=imgFormat)), dpi=figDPI)
    plt.close()

    # display 532 FR
    # filter out the invalid values
    RCS_FR_532 = np.ma.masked_where(depCalMask != 0, RCS_FR_532)
    RCS_FR_532 = np.ma.masked_where(fogMask == 1, RCS_FR_532)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, RCS_FR_532/1e6,
        vmin=RCS532FRColorRange[0], vmax=RCS532FRColorRange[1], cmap=cmap,
        rasterized=True)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_ylim([yLim_FR_RCS[0], yLim_FR_RCS[1]])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Range-Corrected Signal at ' +
        '{wave}nm Far-Range from {instrument} at {location}'.format(
            wave=532, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(
        pcmesh, cax=cb_ax, orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=12, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(
        mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(
        version=version), fontsize=14)

    fig.savefig(
        os.path.join(
            saveFolder, '{dataFilename}_RCS_FR_532.{imgFormat}'.format(
                dataFilename=rmext(dataFilename),
                imgFormat=imgFormat)), dpi=figDPI)
    plt.close()

    # display 1064 FR
    # filter out the invalid values
    RCS_FR_1064 = np.ma.masked_where(depCalMask != 0, RCS_FR_1064)
    RCS_FR_1064 = np.ma.masked_where(fogMask == 1, RCS_FR_1064)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, RCS_FR_1064/1e6,
        vmin=RCS1064FRColorRange[0], vmax=RCS1064FRColorRange[1], cmap=cmap,
        rasterized=True)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_ylim([yLim_FR_RCS[0], yLim_FR_RCS[1]])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Range-Corrected Signal at ' +
        '{wave}nm Far-Range from {instrument} at {location}'.format(
            wave=1064,
            instrument=pollyVersion,
            location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(
        pcmesh, cax=cb_ax, orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=12, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(
        mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(
        version=version), fontsize=14)

    fig.savefig(
        os.path.join(
            saveFolder, '{dataFilename}_RCS_FR_1064.{imgFormat}'.format(
                dataFilename=rmext(dataFilename),
                imgFormat=imgFormat)), dpi=figDPI)
    plt.close()

    # display 355 NR
    # filter out the invalid values
    RCS_NR_355 = np.ma.masked_where(depCalMask != 0, RCS_NR_355)
    RCS_NR_355 = np.ma.masked_where(fogMask == 1, RCS_NR_355)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, RCS_NR_355/1e6,
        vmin=RCS355NRColorRange[0], vmax=RCS355NRColorRange[1], cmap=cmap,
        rasterized=True)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(1000))
    ax.yaxis.set_minor_locator(MultipleLocator(200))
    ax.set_ylim([yLim_NR_RCS[0], yLim_NR_RCS[1]])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Range-Corrected Signal at ' +
        '{wave}nm Near-Range from {instrument} at {location}'.format(
            wave=355, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(
        pcmesh, cax=cb_ax, orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=12, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(
        mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(
        version=version), fontsize=14)

    fig.savefig(
        os.path.join(
            saveFolder, '{dataFilename}_RCS_NR_355.{imgFormat}'.format(
                dataFilename=rmext(dataFilename),
                imgFormat=imgFormat)), dpi=figDPI)
    plt.close()

    # display 532 NR
    # filter out the invalid values
    RCS_NR_532 = np.ma.masked_where(depCalMask != 0, RCS_NR_532)
    RCS_NR_532 = np.ma.masked_where(fogMask == 1, RCS_NR_532)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, RCS_NR_532/1e6,
        vmin=RCS532NRColorRange[0], vmax=RCS532NRColorRange[1], cmap=cmap,
        rasterized=True)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(1000))
    ax.yaxis.set_minor_locator(MultipleLocator(200))
    ax.set_ylim([yLim_NR_RCS[0], yLim_NR_RCS[1]])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Range-Corrected Signal at ' +
        '{wave}nm Near-Range from {instrument} at {location}'.format(
            wave=532, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(
        pcmesh, cax=cb_ax, orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=12, pad=5)
    cbar.ax.set_title('[a.u.]', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(
        mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(
        version=version), fontsize=14)

    fig.savefig(
        os.path.join(
            saveFolder, '{dataFilename}_RCS_NR_532.{imgFormat}'.format(
                dataFilename=rmext(dataFilename),
                imgFormat=imgFormat)), dpi=figDPI)
    plt.close()

    # display voldepol 532
    # filter out the invalid values
    volDepol_532 = np.ma.masked_where(depCalMask != 0, volDepol_532)
    volDepol_532 = np.ma.masked_where(fogMask == 1, volDepol_532)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, volDepol_532,
        vmin=Voldepol532ColorRange[0],
        vmax=Voldepol532ColorRange[1],
        cmap=cmap,
        rasterized=True)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_ylim([yLim_FR_DR[0], yLim_FR_DR[1]])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Volume Depolarization Ratio at ' +
        '{wave}nm from {instrument} at {location}'.format(
            wave=532, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(
        pcmesh, cax=cb_ax, ticks=np.arange(
            0, 0.41, 0.05), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=12, pad=5)
    cbar.ax.set_title('', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(
        mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(
        version=version), fontsize=14)

    fig.savefig(
        os.path.join(
            saveFolder, '{dataFilename}_VDR_532.{imgFormat}'.format(
                dataFilename=rmext(dataFilename),
                imgFormat=imgFormat)), dpi=figDPI)
    plt.close()


def main():
    pollyxt_ift_display_rcs(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop')


if __name__ == '__main__':
    # main()
    pollyxt_ift_display_rcs(sys.argv[1], sys.argv[2])
