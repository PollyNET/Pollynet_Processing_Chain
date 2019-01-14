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

def arielle_display_monitor(tmpFile, saveFolder):
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
    arielle_display_monitor(tmpFile)

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
        time = mat['monitorStatus']['time'][0][0]
        mTime = mat['mTime'][0][:]
        ExtPyro = mat['monitorStatus']['ExtPyro'][0][0]
        Temp1064 = mat['monitorStatus']['Temp1064'][0][0]
        Temp1 = mat['monitorStatus']['Temp1'][0][0]
        Temp2 = mat['monitorStatus']['Temp2'][0][0]
        OutsideT = mat['monitorStatus']['OutsideT'][0][0]
        OutsideRH = mat['monitorStatus']['OutsideRH'][0][0]
        roof = mat['monitorStatus']['roof'][0][0]
        rain = mat['monitorStatus']['rain'][0][0]
        shutter = mat['monitorStatus']['shutter'][0][0]
        pollyVersion = mat['taskInfo']['pollyVersion'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
    except Exception as e:
        print('%s has been destroyed' % (tmpFile))
        return

    # filter out the invalid values
    ExtPyro = np.ma.masked_outside(ExtPyro, 0, 20)
    Temp1064 = np.ma.masked_outside(Temp1064, -50, 990)
    Temp1 = np.ma.masked_outside(Temp1, -40, 990)
    Temp2 = np.ma.masked_outside(Temp2, -40, 990)
    OutsideT = np.ma.masked_outside(OutsideT, -40, 990)
    OutsideRH = np.ma.masked_outside(OutsideRH, -10, 120)
    roof = np.ma.masked_greater(roof, 10)
    rain = np.ma.masked_greater(rain, 10)
    shutter = np.ma.masked_greater(shutter, 10)

    flags = np.transpose(np.ma.hstack((rain, roof, shutter)))
    
    # visualization
    fig, (ax1, ax2, ax3, ax4) = plt.subplots(4, figsize=(10, 10), sharex=True, gridspec_kw={'height_ratios': [1, 1.6, 1, 0.6]})

    ax1.plot(time, ExtPyro, color='#8000ff')
    ax1.set_ylim([0, 40])
    ax1.set_xlim([mTime[0], mTime[-1]])
    ax1.set_title('Housekeeping data for {polly} at {site}'.format(polly=pollyVersion, site=location), fontweight='bold', fontsize=17)
    ax1.set_ylabel("ExtPyro [mJ]", fontweight='semibold', fontsize=15)
    ax1.grid(True)

    ax2.plot(time, Temp1, color='#ff8000', label='Temp1')
    ax2.plot(time, Temp2, color='#008000', label='Temp2')
    ax2.plot(time, OutsideT, color='#800080', label='Outside T')
    ax2.set_xlim([mTime[0], mTime[-1]])
    ax2.set_ylim([-30, 50])
    ax2.grid(True)
    ax2.set_ylabel(r'Temperature [$^\circ C$]', fontweight='semibold', fontsize=15)
    if len(time):
        ax2.legend(loc='upper left')

    ax3.plot(time, Temp1064, color='#ff0080')
    ax3.set_ylim([-38, -20])
    ax3.grid(True)
    ax3.set_ylabel(r'Temp 1064 [$^\circ C$]', fontweight='semibold', fontsize=15)
    ax3.set_xlim([mTime[0], mTime[-1]])

    if len(time):
        cmap = ListedColormap(['navajowhite', 'coral', 'skyblue', 'm', 'mediumaquamarine'])
        pcmesh = ax4.pcolormesh(np.transpose(time), np.arange(flags.shape[0] + 1), flags, cmap=cmap, vmin=-0.5, vmax=4.5)
        cb_ax = fig.add_axes([0.84, 0.19, 0.12, 0.016])
        cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[0, 1, 2, 3, 4], orientation='horizontal')
        cbar.ax.tick_params(labeltop=True, direction='in', labelbottom=False, bottom=False, top=True, labelsize=9, pad=0.00)

    ax4.set_ylim([0, flags.shape[0]])
    ax4.set_yticks([0.5, 1.5, 2.5])
    ax4.set_yticklabels(['rain', 'roof', 'shutter'])
    [ax4.axhline(p, color='white', linewidth=3) for p in np.arange(0, 5)]
    ax4.set_xticks(xtick.tolist())
    ax4.set_xticklabels(celltolist(xticklabel))
    # ax4.xaxis.set_major_formatter(DateFormatter('%H:%M'))
    # ax4.xaxis.set_major_locator(HourLocator(interval=1))
    # ax4.xaxis.set_minor_locator(MinuteLocator(byminute=[0, 30, 60]))
    ax4.set_xlim([mTime[0], mTime[-1]])

    for ax in (ax1, ax2, ax3, ax4):
        ax.tick_params(axis='both', which='major', labelsize=14, right=True, top=True, width=2, length=5)
        ax.tick_params(axis='both', which='minor', width=1.5, length=3.5, right=True, top=True)

    ax4.set_xlabel('UTC', fontweight='semibold', fontsize=15)
    fig.text(0.05, 0.01, datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"), fontsize=14)
    fig.text(0.8, 0.01, 'Version: {version}'.format(version=version), fontsize=14)

    fig.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_monitor.png'.format(dataFilename=rmext(dataFilename))), dpi=150)

    plt.close()

def main():
    arielle_display_monitor('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\ARIELLE\\20180517')

if __name__ == '__main__':
    # main()
    arielle_display_monitor(sys.argv[1], sys.argv[2])