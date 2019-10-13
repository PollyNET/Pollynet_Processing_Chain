import sys
import os
from datetime import datetime, timedelta
import numpy as np
import scipy.io as spio
from matplotlib.dates import DateFormatter, DayLocator, HourLocator, \
                             MinuteLocator, date2num
from matplotlib.colors import ListedColormap
import matplotlib.pyplot as plt
import matplotlib
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


def pollyxt_noa_display_monitor(tmpFile, saveFolder):
    '''
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
    pollyxt_noa_display_monitor(tmpFile)

    History
    -------
    2019-01-10. First edition by Zhenping
    '''

    if not os.path.exists(tmpFile):
        print('{filename} does not exists.'.format(filename=tmpFile))
        return

    # read matlab .mat data
    try:
        mat = spio.loadmat(tmpFile, struct_as_record=True)
        figDPI = mat['figDPI'][0][0]
        time = mat['monitorStatus']['time'][0][0]
        mTime = mat['mTime'][0][:]
        AD = mat['monitorStatus']['AD'][0][0]
        EN = mat['monitorStatus']['EN'][0][0]
        HT = mat['monitorStatus']['HT'][0][0]
        WT = mat['monitorStatus']['WT'][0][0]
        shutter2 = mat['monitorStatus']['LS'][0][0]
        counts = mat['monitorStatus']['counts'][0][0]
        ExtPyro = mat['monitorStatus']['ExtPyro'][0][0]
        Temp1064 = mat['monitorStatus']['Temp1064'][0][0]
        Temp1 = mat['monitorStatus']['Temp1'][0][0]
        Temp2 = mat['monitorStatus']['Temp2'][0][0]
        OutsideT = mat['monitorStatus']['OutsideT'][0][0]
        OutsideRH = mat['monitorStatus']['OutsideRH'][0][0]
        roof = mat['monitorStatus']['roof'][0][0]
        rain = mat['monitorStatus']['rain'][0][0]
        shutter = mat['monitorStatus']['shutter'][0][0]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
    except Exception as e:
        print(e)
        print('Failed reading %s' % (tmpFile))
        return

    # filter out the invalid values
    HT = np.ma.masked_greater(HT, 990)
    WT = np.ma.masked_greater(WT, 990)
    ExtPyro = np.ma.masked_outside(ExtPyro, 0, 300)
    Temp1064 = np.ma.masked_outside(Temp1064, -50, 990)
    Temp1 = np.ma.masked_outside(Temp1, -40, 990)
    Temp2 = np.ma.masked_outside(Temp2, -40, 990)
    OutsideT = np.ma.masked_outside(OutsideT, -40, 990)
    OutsideRH = np.ma.masked_outside(OutsideRH, -10, 120)
    roof = np.ma.masked_greater(roof, 10)
    rain = np.ma.masked_greater(rain, 10)
    shutter = np.ma.masked_greater(shutter, 10)
    shutter2 = np.ma.masked_greater(shutter2, 10)
    AD = np.ma.masked_outside(AD, 0, 990)
    EN = np.ma.masked_outside(EN, 0, 990)

    flags = np.transpose(np.ma.hstack((rain, roof, shutter, shutter2)))

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # visualization (credits to Martin's python program)
    fig, (ax1, ax2, ax3, ax4, ax5) = plt.subplots(
        5, figsize=(15, 14), sharex=True,
        gridspec_kw={'height_ratios': [1, 1, 1.6, 1, 0.6]}
        )

    if AD.size != 0:
        if AD[0][0] <= 990:
            ax1.plot(time, AD)
            ax1.set_ylim([100, 250])
            ax1.set_ylabel("AD [a.u.]", fontsize=15)
        else:
            ax1.plot(time, EN)
            # ax1.set_ylim([420, 550])
            ax1.set_ylabel("EN [mJ]", fontsize=15)
    else:
        ax1.plot(time, EN)
        # ax1.set_ylim([420, 550])
        ax1.set_ylabel("EN [mJ]", fontsize=15)

    ax1.set_title(
        'Housekeeping data for {polly} at {site}'.format(
            polly=pollyVersion,
            site=location
            ),
        fontsize=17
        )

    ax2.plot(time, ExtPyro, marker='.', color='#8000ff')
    # ax2.set_ylim([1, 37])
    ax2.set_xlim([mTime[0], mTime[-1]])
    ax2.set_ylabel("ExtPyro [mJ]", fontsize=15)
    ax2.grid(True)

    ax3.plot(time, HT, color='#8080ff', label='Laser Head')
    ax3.plot(time, Temp1, color='#ff8000', label='Temp1')
    ax3.plot(time, Temp2, color='#008000', label='Temp2')
    ax3.plot(time, WT, color='#808080', label='Water T')
    ax3.plot(time, OutsideT, color='#800080', label='Outside T')
    ax3.set_xlim([mTime[0], mTime[-1]])
    ax3.set_ylim([0, 40])
    ax3.grid(True)
    ax3.set_ylabel(r'Temperature [$^\circ C$]', fontsize=15)
    ax3.yaxis.set_minor_locator(matplotlib.ticker.MultipleLocator(1))
    if len(time):
        ax3.legend(loc='upper left')

    ax4.plot(time, Temp1064, color='darkred')
    # ax4.set_ylim([-38, -20])
    ax4.grid(True)
    ax4.set_ylabel(r'Temp 1064 [$^\circ C$]', fontsize=15)
    ax4.set_xlim([mTime[0], mTime[-1]])

    if len(time):
        cmap = ListedColormap(
            ['navajowhite', 'coral', 'skyblue', 'm', 'mediumaquamarine']
            )
        pcmesh = ax5.pcolormesh(
            np.transpose(time), np.arange(flags.shape[0] + 1), flags,
            cmap=cmap, vmin=-0.5, vmax=4.5
            )
        cb_ax = fig.add_axes([0.84, 0.155, 0.12, 0.016])
        cbar = fig.colorbar(
            pcmesh,
            cax=cb_ax,
            ticks=[0, 1, 2, 3, 4],
            orientation='horizontal'
            )
        cbar.ax.tick_params(
            labeltop=True,
            direction='in',
            labelbottom=False,
            bottom=False,
            top=True,
            labelsize=12,
            pad=0.00
            )

    ax5.set_ylim([0, flags.shape[0]])
    ax5.set_yticks([0.5, 1.5, 2.5, 3.5])
    ax5.set_yticklabels(['rain', 'roof', 'SH ext', 'SH'])
    [ax5.axhline(p, color='white', linewidth=3) for p in np.arange(0, 6)]
    ax5.set_xticks(xtick.tolist())
    ax5.set_xticklabels(celltolist(xticklabel))
    ax5.set_xlim([mTime[0], mTime[-1]])

    for ax in (ax1, ax2, ax3, ax4, ax5):
        ax.tick_params(
            axis='both', which='major', labelsize=15,
            right=True, top=True, width=2, length=5
            )
        ax.tick_params(
            axis='both', which='minor', width=1.5,
            length=3.5, right=True, top=True
            )

    ax5.set_xlabel('UTC', fontsize=15)
    fig.text(
        0.05, 0.01,
        datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"),
        fontsize=17
        )
    fig.text(
        0.8, 0.01,
        'Version: {version}'.format(version=version),
        fontsize=17
        )
    if counts.size != 0:
        fig.text(
            0.1, 0.90,
            'SC begin {:.1f}Mio'.format(counts[0][0]/1e6),
            fontsize=17
            )
        fig.text(
            0.85, 0.90,
            'end {:.1f}Mio'.format(counts[0][-1]/1e6),
            fontsize=17
            )

    plt.tight_layout()
    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFilename}_monitor.png'.format(
                dataFilename=rmext(dataFilename)
                )
            ),
        dpi=figDPI
        )

    plt.close()


def main():
    pollyxt_noa_display_monitor(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\' +
        'POLLYXT_noa\\20180517'
        )


if __name__ == '__main__':
    # main()
    pollyxt_noa_display_monitor(sys.argv[1], sys.argv[2])
