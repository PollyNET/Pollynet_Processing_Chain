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
matplotlib.use('Agg')


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


def pollyxt_noa_display_depolcali(tmpFile, saveFolder):
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
    pollyxt_noa_display_depolcali(tmpFile, saveFolder)

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
        sig_t_p = np.transpose(np.concatenate(mat['sig_t_p']))
        sig_t_m = np.transpose(np.concatenate(mat['sig_t_m']))
        sig_x_p = np.transpose(np.concatenate(mat['sig_x_p']))
        sig_x_m = np.transpose(np.concatenate(mat['sig_x_m']))
        wavelength = mat['wavelength'][0][0]
        time = np.concatenate(mat['time'])
        height = np.concatenate(mat['height'])
        caliHIndxRange = np.concatenate(mat['caliHIndxRange'])
        indx_45m = np.concatenate(mat['indx_45m'])
        indx_45p = np.concatenate(mat['indx_45p'])
        dplus = np.transpose(np.concatenate(mat['dplus']))
        dminus = np.transpose(np.concatenate(mat['dminus']))
        segmentLen = np.concatenate(mat['segmentLen'])
        indx = np.concatenate(mat['indx'])
        mean_dplus_tmp = np.concatenate(mat['mean_dplus_tmp'])
        std_dplus_tmp = np.concatenate(mat['std_dplus_tmp'])
        mean_dminus_tmp = np.concatenate(mat['mean_dminus_tmp'])
        std_dminus_tmp = np.concatenate(mat['std_dminus_tmp'])
        TRt = np.concatenate(mat['TR_t'])
        TRx = np.concatenate(mat['TR_x'])
        segIndx = np.concatenate(mat['segIndx'])
        thisCaliTime = np.concatenate(mat['thisCaliTime'])
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
    except Exception as e:
        print(e)
        print('Failed reading %s' % (tmpFile))
        return

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # display
    fig, (ax1, ax2) = plt.subplots(
        1, 2,
        igsize=(8, 8),
        sharey=True,
        gridspec_kw={'width_ratios': [1, 1]}
        )

    # display signal
    p1, = ax1.semilogx(
        sig_t_p, height,
        color='#E75A17',
        linestyle='-',
        label=r'$Sig_{+45^\circ}$'
        )
    p2, = ax1.semilogx(
        sig_t_m, height,
        color='#1770E7',
        linestyle='-',
        label=r'$Sig_{-45^\circ}$'
        )
    p3, = ax1.semilogx(
        sig_x_p,
        height,
        color='#E75A17',
        linestyle='--',
        label=r'$Sig_{+45^\circ}$'
        )
    p4, = ax1.semilogx(
        sig_x_m,
        height,
        color='#1770E7',
        linestyle='--',
        label=r'$Sig_{-45^\circ}$'
        )
    ax1.set_ylim(
        [height[caliHIndxRange[0] - 1], height[caliHIndxRange[1] - 1]]
        )
    ax1.set_xlim([1, 1e4])
    ax1.set_ylabel('Height (m)', fontsize=15)
    ax1.set_xlabel('Signal (a.u.)', fontsize=15)
    ax1.yaxis.set_major_locator(MultipleLocator(200))
    ax1.yaxis.set_minor_locator(MultipleLocator(50))
    ax1.grid(True)

    start = datenum_to_datetime(time[indx_45p[0] - 1])
    end = datenum_to_datetime(time[indx_45m[-1] + 1])
    fig.text(
        0.5, 0.98,
        'Depolarization Calibration for {wave}nm at {start}-{end}'.format(
            wave=wavelength,
            start=start.strftime('%H:%M'),
            end=end.strftime('%H:%M')
            ),
        horizontalalignment='center',
        fontsize=15
        )
    ax1.legend(
        handles=[p1, p2, p3, p4],
        loc='upper right',
        fontsize=12
        )
    ax1.tick_params(
        axis='both',
        which='major',
        labelsize=15,
        width=2,
        length=5
        )
    ax1.tick_params(axis='both', which='minor', width=1.5, length=3.5)

    p1, = ax2.plot(
        dplus,
        height[(caliHIndxRange[0] - 1):(caliHIndxRange[1])],
        color='#E75A17',
        label=r'$Ratio_{+45^\circ}$'
        )
    p2, = ax2.plot(
        dminus,
        height[(caliHIndxRange[0] - 1):(caliHIndxRange[1])],
        color='#1770E7',
        label=r'$Ratio_{-45^\circ}$'
        )
    ax2.axhline(
        y=height[indx + caliHIndxRange[0] - 2],
        linestyle='--',
        color='#000000'
        )
    ax2.axhline(
        y=height[indx + segmentLen + caliHIndxRange[0] - 2],
        linestyle='--',
        color='#000000'
        )

    ax2.set_xlabel('Ratio', fontsize=15)
    ax2.legend(
        handles=[p1, p2],
        loc='upper right',
        fontsize=12
        )
    ax2.text(
        0, 0.7,
        '$mean_{dplus}={0:5.2f}, std_{dplus}={1:5.3f}$\n'.format(
            mean_dplus_tmp[segIndx - 1],
            std_dplus_tmp[segIndx - 1]
        ) + '$mean_{dminus}={0:5.2f}, std_{dminus}={1:5.3f}$\n'.format(
            mean_dminus_tmp[segIndx - 1],
            std_dminus_tmp[segIndx - 1]
        ) + '$K={0:6.4f}, std_K={1:6.4f}$'.format(
            (1 + TRt) / (1 + TRx) *
            np.sqrt(mean_dplus_tmp[segIndx-1] * mean_dminus_tmp[segIndx - 1]),
            (1 + TRt) / (1 + TRx) / np.sqrt(
                mean_dplus_tmp[segIndx - 1] *
                mean_dminus_tmp[segIndx - 1]
                ) * 0.5 *
            (mean_dplus_tmp[segIndx - 1] * std_dminus_tmp[segIndx - 1] +
             mean_dminus_tmp[segIndx - 1] * std_dplus_tmp[segIndx - 1])
            ),
        fontsize=12,
        transform=ax2.transAxes
        )
    ax2.grid(True)
    ax2.tick_params(
        axis='both', which='major', labelsize=15, width=2, length=5
        )
    ax2.tick_params(axis='both', which='minor', width=1.5, length=3.5)

    fig.text(
        0.82, 0.015, '{location}\n{instrument}\nVersion {version}'.format(
            location=location,
            instrument=pollyVersion,
            version=version
            ),
        fontsize=10
        )

    caliTime = datenum_to_datetime(thisCaliTime[0])
    plt.tight_layout()
    plt.savefig(
        os.path.join(
            saveFolder,
            '{start}_DepolCali_{wave}.png'.format(
                start=caliTime.strftime('%Y%m%d-%H%M'),
                wave=wavelength
                )
            ),
        dpi=figDPI
        )
    plt.close()


def main():
    pollyxt_noa_display_depolcali(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop'
        )


if __name__ == '__main__':
    # main()
    pollyxt_noa_display_depolcali(sys.argv[1], sys.argv[2])
