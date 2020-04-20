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


def polly_first_display_lidarconst(tmpFile, saveFolder):
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
    polly_first_display_lidarconst(tmpFile)

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
        thisTime = np.concatenate(mat['thisTime'][:])
        time = mat['time'][0][:]
        LC532_klett = mat['LC532_klett'][:]
        LC532_raman = mat['LC532_raman'][:]
        LC532_aeronet = mat['LC532_aeronet'][:]
        LC607_raman = mat['LC607_raman'][:]
        yLim532 = mat['yLim532'][0][:]
        yLim607 = mat['yLim607'][0][:]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
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
    # display lidar constants at 532mn
    fig = plt.figure(figsize=[9, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    p1, = ax.plot(
        thisTime, LC532_klett,
        color='#008040', linestyle='--', marker='^',
        markersize=10, mfc='#008040', mec='#000000', label='Klett Method'
        )
    p2, = ax.plot(
        thisTime, LC532_raman,
        color='#400080', linestyle='--', marker='o',
        markersize=10, mfc='#400080', mec='#000000', label='Raman Method'
        )
    p3, = ax.plot(
        thisTime, LC532_aeronet,
        color='#804000', linestyle='--', marker='*',
        markersize=10, mfc='#800040', mec='#000000',
        label='Constrained-AOD Method'
        )
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('C', fontsize=15)
    ax.legend(handles=[p1, p2, p3], loc='upper right', fontsize=12)

    ax.set_ylim(yLim532.tolist())
    ax.set_xticks(xtick.tolist())
    ax.set_xlim([time[0], time[-1]])
    ax.set_xticklabels(celltolist(xticklabel))
    ax.grid(True)
    ax.tick_params(
        axis='both', which='major',
        labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(
        axis='both', which='minor',
        width=1.5, length=3.5, right=True, top=True)

    ax.set_title(
        'Lidar constants ' +
        '{wave}nm Far-Range for {instrument} at {location}'.format(
            wave=532, instrument=pollyVersion, location=location
            ), fontsize=15)

    fig.text(
        0.05, 0.02,
        datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
        fontsize=12
        )
    fig.text(
        0.8, 0.02,
        'Version: {version}'.format(version=version), fontsize=12
        )

    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFilename}_LC_532.{imgFmt}'.format(
                dataFilename=rmext(dataFilename),
                imgFmt=imgFormat)),
            dpi=figDPI
            )
    plt.close()

    # display lidar constants at 607mn
    fig = plt.figure(figsize=[9, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    p1, = ax.plot(
        thisTime, LC607_raman,
        color='#400080', linestyle='--', marker='o',
        markersize=10, mfc='#400080', mec='#000000', label='Raman Method')
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('C', fontsize=15)
    ax.legend(handles=[p1], loc='upper right', fontsize=12)

    ax.set_ylim(yLim607.tolist())
    ax.set_xticks(xtick.tolist())
    ax.set_xlim([time[0], time[-1]])
    ax.set_xticklabels(celltolist(xticklabel))
    ax.grid(True)
    ax.tick_params(
        axis='both', which='major',
        labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(
        axis='both', which='minor',
        width=1.5, length=3.5, right=True, top=True)

    ax.set_title(
        'Lidar constants ' +
        '{wave}nm Far-Range for {instrument} at {location}'.format(
            wave=607, instrument=pollyVersion, location=location), fontsize=15)

    fig.text(
        0.05, 0.02,
        datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(
        0.8, 0.02,
        'Version: {version}'.format(version=version), fontsize=15)

    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFilename}_LC_607.{imgFmt}'.format(
                dataFilename=rmext(dataFilename),
                imgFmt=imgFormat)), dpi=figDPI)
    plt.close()


def main():
    polly_first_display_lidarconst(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop')


if __name__ == '__main__':
    # main()
    polly_first_display_lidarconst(sys.argv[1], sys.argv[2])
