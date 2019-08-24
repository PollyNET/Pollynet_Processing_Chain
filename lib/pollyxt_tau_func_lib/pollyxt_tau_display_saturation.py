import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
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

def pollyxt_tau_display_saturation(tmpFile, saveFolder):
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
    pollyxt_tau_display_saturation(tmpFile)

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
        mTime = mat['time'][0][:]
        height = mat['height'][0][:]
        SAT_FR_355 = mat['SAT_FR_355'][:]
        SAT_FR_532 = mat['SAT_FR_532'][:]
        SAT_FR_1064 = mat['SAT_FR_1064'][:]
        SAT_NR_355 = mat['SAT_NR_355'][:]
        SAT_NR_532 = mat['SAT_NR_532'][:]
        SAT_FR_407 = mat['SAT_FR_407'][:]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
    except Exception as e:
        print('Failed reading %s' % (tmpFile))
        return

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # meshgrid
    Time, Height = np.meshgrid(mTime, height)

    # load colormap
    dirname = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sys.path.append(dirname)
    try:
        from python_colormap import signal_status_colormap
    except Exception as e:
        raise ImportError('python_colormap module is necessary.')

    # display status of 355 FR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.74, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, SAT_FR_355, vmin=-0.5, vmax=2.5, cmap=signal_status_colormap())
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax.set_title('Signal Status at {wave}nm Far-Range from {instrument} at {location}'.format(wave=355, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.865, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[0, 1, 2], orientation='vertical')
    cbar.ax.tick_params(direction='in', pad=5)
    cbar.ax.set_title('', fontsize=9)
    cbar.ax.set_yticklabels(['Good Signal', 'Saturated', 'Low SNR'])
    cbar.ax.tick_params(axis='both', which='major', labelsize=12, right=True, top=True, width=2, length=5)
    cbar.ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=14)

    
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_SAT_FR_355.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()

    # display status of 532 FR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.74, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, SAT_FR_532, vmin=-0.5, vmax=2.5, cmap=signal_status_colormap())
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax.set_title('Signal Status at {wave}nm Far-Range from {instrument} at {location}'.format(wave=532, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.865, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[0, 1, 2], orientation='vertical')
    cbar.ax.tick_params(direction='in', pad=5)
    cbar.ax.set_title('', fontsize=9)
    cbar.ax.set_yticklabels(['Good Signal', 'Saturated', 'Low SNR'])
    cbar.ax.tick_params(axis='both', which='major', labelsize=12, right=True, top=True, width=2, length=5)
    cbar.ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=14)

    
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_SAT_FR_532.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()
    
    # display status of 1064 FR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.74, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, SAT_FR_1064, vmin=-0.5, vmax=2.5, cmap=signal_status_colormap())
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax.set_title('Signal Status at {wave}nm Far-Range from {instrument} at {location}'.format(wave=1064, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.865, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[0, 1, 2], orientation='vertical')
    cbar.ax.tick_params(direction='in', pad=5)
    cbar.ax.set_title('', fontsize=9)
    cbar.ax.set_yticklabels(['Good Signal', 'Saturated', 'Low SNR'])
    cbar.ax.tick_params(axis='both', which='major', labelsize=12, right=True, top=True, width=2, length=5)
    cbar.ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=14)

    
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_SAT_FR_1064.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()
    
    # display status of 355 NR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.74, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, SAT_NR_355, vmin=-0.5, vmax=2.5, cmap=signal_status_colormap())
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax.set_title('Signal Status at {wave}nm Near-Range from {instrument} at {location}'.format(wave=355, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.865, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[0, 1, 2], orientation='vertical')
    cbar.ax.tick_params(direction='in', pad=5)
    cbar.ax.set_title('', fontsize=9)
    cbar.ax.set_yticklabels(['Good Signal', 'Saturated', 'Low SNR'])
    cbar.ax.tick_params(axis='both', which='major', labelsize=12, right=True, top=True, width=2, length=5)
    cbar.ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=14)

    
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_SAT_NR_355.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()
    
    # display status of 532 NR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.74, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, SAT_NR_532, vmin=-0.5, vmax=2.5, cmap=signal_status_colormap())
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax.set_title('Signal Status at {wave}nm Near-Range from {instrument} at {location}'.format(wave=532, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.865, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[0, 1, 2], orientation='vertical')
    cbar.ax.tick_params(direction='in', pad=5)
    cbar.ax.set_title('', fontsize=9)
    cbar.ax.set_yticklabels(['Good Signal', 'Saturated', 'Low SNR'])
    cbar.ax.tick_params(axis='both', which='major', labelsize=12, right=True, top=True, width=2, length=5)
    cbar.ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=14)

    
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_SAT_NR_532.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()

    # display status of 407
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.74, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, SAT_FR_407, vmin=-0.5, vmax=2.5, cmap=signal_status_colormap())
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_yticks([0, 2500, 5000, 7500, 10000, 12500, 15000])
    ax.set_ylim([0, 15000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax.set_title('Signal Status at {wave}nm Far-Range from {instrument} at {location}'.format(wave=407, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.865, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[0, 1, 2], orientation='vertical')
    cbar.ax.tick_params(direction='in', pad=5)
    cbar.ax.set_title('', fontsize=9)
    cbar.ax.set_yticklabels(['Good Signal', 'Saturated', 'Low SNR'])
    cbar.ax.tick_params(axis='both', which='major', labelsize=12, right=True, top=True, width=2, length=5)
    cbar.ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    fig.text(0.05, 0.04, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=15)
    fig.text(0.8, 0.04, 'Version: {version}'.format(version=version), fontsize=14)

    
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_SAT_FR_407.png'.format(dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()


def main():
    pollyxt_tau_display_saturation('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop')

if __name__ == '__main__':
    # main()
    pollyxt_tau_display_saturation(sys.argv[1], sys.argv[2])