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

def arielle_display_WV(tmpFile, saveFolder):
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
    arielle_display_WV(tmpFile)

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
        WVMR = mat['WVMR'][:]
        RH = mat['RH'][:]
        lowSNRMask = mat['lowSNRMask'][:]
        height = mat['height'][0][:]
        time = mat['time'][0][:]
        flagCalibrated = mat['flagCalibrated'][:][0]
        meteorSource = mat['meteorSource'][:][0]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        WVMRColorRange = mat['WVMRColorRange'][:][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
    except Exception as e:
        print('Failed reading %s' % (tmpFile))
        return

    # meshgrid
    Time, Height = np.meshgrid(time, height)
    WVMR = np.ma.masked_where(lowSNRMask != 0, WVMR)
    RH = np.ma.masked_where(lowSNRMask != 0, RH)

    # define the colormap
    cmap = plt.cm.jet
    cmap.set_bad('w', alpha=1)
    cmap.set_over('w', alpha=1)
    cmap.set_under('k', alpha=1)

    # display WVMR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, WVMR, vmin=WVMRColorRange[0], vmax=WVMRColorRange[1], cmap=cmap)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(1000))
    ax.yaxis.set_minor_locator(MultipleLocator(200))    
    ax.set_ylim([0, 8000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax.set_title('Water vapor mixing ratio from {instrument} at {location}'.format(instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.linspace(WVMRColorRange[0], WVMRColorRange[1], 5), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=10)
    cbar.ax.set_title('[$g*kg^{-1}$]', fontsize=10)

    fig.text(0.05, 0.02, '{time}\nMeteor Data: {meteorSource}'.format(time=datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), meteorSource=meteorSource), fontsize=15)
    fig.text(0.8, 0.02, 'Version: {version}\nCalibration: {status}'.format(version=version, status=flagCalibrated), fontsize=15)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_WVMR.png'.format(dataFilename=rmext(dataFilename))), bbox_inches='tight', dpi=figDPI)
    plt.close()

    # display RH
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, RH, vmin=0, vmax=100, cmap=cmap)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(1000))
    ax.yaxis.set_minor_locator(MultipleLocator(200))    
    ax.set_ylim([0, 8000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15, right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax.set_title('Relative humidity from {instrument} at {location}'.format(instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.15, 0.02, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 100.1, 20), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=10)
    cbar.ax.set_title('[$\%$]', fontsize=10)

    fig.text(0.05, 0.02, '{time}\nMeteor Data: {meteorSource}'.format(time=datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), meteorSource=meteorSource), fontsize=15)
    fig.text(0.8, 0.02, 'Version: {version}\nCalibration: {status}'.format(version=version, status=flagCalibrated), fontsize=15)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_RH.png'.format(dataFilename=rmext(dataFilename))), bbox_inches='tight', dpi=figDPI)
    plt.close()

def main():
    arielle_display_WV('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop')

if __name__ == '__main__':
    # main()
    arielle_display_WV(sys.argv[1], sys.argv[2])