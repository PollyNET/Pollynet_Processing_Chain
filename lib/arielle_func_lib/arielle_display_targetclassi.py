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

def arielle_display_targetclassi(tmpFile, saveFolder):
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
    arielle_display_targetclassi(tmpFile)

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
        TC_mask = mat['TC_mask'][:]
        height = mat['height'][0][:]
        time = mat['time'][0][:]
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
    Time, Height = np.meshgrid(time, height)

    # load colormap
    dirname = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sys.path.append(dirname)
    try:
        from python_colormap import target_classification_colormap
    except Exception as e:
        raise ImportError('python_colormap module is necessary.')

    # display quasi backscatter at 532 nm
    fig = plt.figure(figsize=[12, 5])
    ax = fig.add_axes([0.1, 0.15, 0.6, 0.75])
    pcmesh = ax.pcolormesh(Time, Height, TC_mask, vmin=-0.5, vmax=11.5, cmap=target_classification_colormap())
    ax.set_xlabel('UTC', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)

    ax.set_yticks(np.arange(0, 12001, 2000).tolist())
    ax.set_ylim([0, 12000])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))

    ax.set_title('Target classifications from {instrument} at {location}'.format(instrument=pollyVersion, location=location), fontweight='bold', fontsize=14)

    cb_ax = fig.add_axes([0.72, 0.15, 0.015, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(0, 12, 1), orientation='vertical')
    cbar.ax.tick_params(direction='out', labelsize=7, pad=5)
    cbar.ax.set_yticklabels(['No signal',
                 'Clean atmosphere',
                 'Non-typed particles/low conc.',
                 'Aerosol: small',
                 'Aerosol: large, spherical',
                 'Aerosol: mixture, partly non-spherical',
                 'Aerosol: large, non-spherical',
                 'Cloud: non-typed',
                 'Cloud: water droplets',
                 'Cloud: likely water droplets',
                 'Cloud: ice crystals',
                 'Cloud: likely ice crystals'], fontsize=10)

    fig.text(0.05, 0.04, datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.64, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_TC.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()

def main():
    arielle_display_targetclassi('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\ARIELLE\\20180517')

if __name__ == '__main__':
    # main()
    arielle_display_targetclassi(sys.argv[1], sys.argv[2])