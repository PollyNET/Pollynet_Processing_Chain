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

def pollyxt_dwd_display_lidarconst(tmpFile, saveFolder):
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
    pollyxt_dwd_display_lidarconst(tmpFile)

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
        thisTime = np.concatenate(mat['thisTime'][:])
        time = mat['time'][0][:]
        LC355_klett = mat['LC355_klett'][:]
        LC355_raman = mat['LC355_raman'][:]
        LC355_aeronet = mat['LC355_aeronet'][:]
        LC532_klett = mat['LC532_klett'][:]
        LC532_raman = mat['LC532_raman'][:]
        LC532_aeronet = mat['LC532_aeronet'][:]
        LC1064_klett = mat['LC1064_klett'][:]
        LC1064_raman = mat['LC1064_raman'][:]
        LC1064_aeronet = mat['LC1064_aeronet'][:]
        yLim355 = mat['yLim355'][0][:]
        yLim532 = mat['yLim532'][0][:]
        yLim1064 = mat['yLim1064'][0][:]
        pollyVersion = mat['taskInfo']['pollyVersion'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
    except Exception as e:
        print('%s has been destroyed' % (tmpFile))
        return

    # display lidar constants at 355mn
    fig = plt.figure(figsize=[9, 5])
    ax = fig.add_axes([0.1, 0.15, 0.85, 0.75])
    p1, = ax.plot(thisTime, LC355_klett, color='#008040', linestyle='--', marker='^', markersize=10, mfc='#008040', mec='#000000', label='Klett Method')
    p2, = ax.plot(thisTime, LC355_raman, color='#400080', linestyle='--', marker='o', markersize=10, mfc='#400080', mec='#000000', label='Raman Method')
    p3, = ax.plot(thisTime, LC355_aeronet, color='#804000', linestyle='--', marker='*', markersize=10, mfc='#800040', mec='#000000', label='Constrained-AOD Method')
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('C', fontweight='semibold', fontsize=14)
    l = ax.legend(handles=[p1, p2, p3], loc='upper right', fontsize=10)

    ax.set_ylim(yLim355.tolist())
    ax.set_xticks(xtick.tolist())
    ax.set_xlim([time[0], time[-1]])
    ax.set_xticklabels(celltolist(xticklabel))
    ax.grid(True)

    ax.set_title('Lidar constants {wave}nm Far-Range for {instrument} at {location}'.format(wave=355, instrument=pollyVersion, location=location), fontweight='bold', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_LC_355.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

    # display lidar constants at 532mn
    fig = plt.figure(figsize=[9, 5])
    ax = fig.add_axes([0.1, 0.15, 0.85, 0.75])
    p1, = ax.plot(thisTime, LC532_klett, color='#008040', linestyle='--', marker='^', markersize=10, mfc='#008040', mec='#000000', label='Klett Method')
    p2, = ax.plot(thisTime, LC532_raman, color='#400080', linestyle='--', marker='o', markersize=10, mfc='#400080', mec='#000000', label='Raman Method')
    p3, = ax.plot(thisTime, LC532_aeronet, color='#804000', linestyle='--', marker='*', markersize=10, mfc='#800040', mec='#000000', label='Constrained-AOD Method')
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('C', fontweight='semibold', fontsize=14)
    l = ax.legend(handles=[p1, p2, p3], loc='upper right', fontsize=10)

    ax.set_ylim(yLim532.tolist())
    ax.set_xticks(xtick.tolist())
    ax.set_xlim([time[0], time[-1]])
    ax.set_xticklabels(celltolist(xticklabel))
    ax.grid(True)

    ax.set_title('Lidar constants {wave}nm Far-Range for {instrument} at {location}'.format(wave=532, instrument=pollyVersion, location=location), fontweight='bold', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_LC_532.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()
    
    # display lidar constants at 1064mn
    fig = plt.figure(figsize=[9, 5])
    ax = fig.add_axes([0.1, 0.15, 0.85, 0.75])
    p1, = ax.plot(thisTime, LC1064_klett, color='#008040', linestyle='--', marker='^', markersize=10, mfc='#008040', mec='#000000', label='Klett Method')
    p2, = ax.plot(thisTime, LC1064_raman, color='#400080', linestyle='--', marker='o', markersize=10, mfc='#400080', mec='#000000', label='Raman Method')
    p3, = ax.plot(thisTime, LC1064_aeronet, color='#804000', linestyle='--', marker='*', markersize=10, mfc='#800040', mec='#000000', label='Constrained-AOD Method')
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=14)
    ax.set_ylabel('C', fontweight='semibold', fontsize=14)
    l = ax.legend(handles=[p1, p2, p3], loc='upper right', fontsize=10)

    ax.set_ylim(yLim1064.tolist())
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.grid(True)

    ax.set_title
    ax.set_title('Lidar constants {wave}nm Far-Range for {instrument} at {location}'.format(wave=1064, instrument=pollyVersion, location=location), fontweight='bold', fontsize=12)

    fig.text(0.05, 0.04, datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_LC_1064.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

def main():
    pollyxt_dwd_display_lidarconst('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\POLLYXT_DWD\\20180517')

if __name__ == '__main__':
    # main()
    pollyxt_dwd_display_lidarconst(sys.argv[1], sys.argv[2])