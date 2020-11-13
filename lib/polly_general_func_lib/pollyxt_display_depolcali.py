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


def pollyxt_display_depolcali(tmpFile, saveFolder):
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
    pollyxt_display_depolcali(tmpFile, saveFolder)

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
        flagWatermarkOn = mat['flagWatermarkOn'][0][0]
        if mat['partnerLabel'].size:
            partnerLabel = mat['partnerLabel'][0][0]
        else:
            partnerLabel = ''
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
        thisCaliTime = np.concatenate(mat['caliTime'])
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
        imgFormat = mat['imgFormat'][:][0]
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
        figsize=(8, 8),
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
        '$mean_{dplus}=%5.2f, std_{dplus}=%5.3f$\n' %
        (mean_dplus_tmp[segIndx - 1], std_dplus_tmp[segIndx - 1]) +
        '$mean_{dminus}=%5.2f, std_{dminus}=%5.3f$\n' %
        (mean_dminus_tmp[segIndx - 1], std_dminus_tmp[segIndx - 1]) +
        '$K=%6.4f, std_K=%6.4f$' %
        ((1 + TRt) / (1 + TRx) *
            np.sqrt(mean_dplus_tmp[segIndx-1] * mean_dminus_tmp[segIndx - 1]),
         (1 + TRt) / (1 + TRx) / np.sqrt(
         mean_dplus_tmp[segIndx - 1] * mean_dminus_tmp[segIndx - 1]) * 0.5 *
         (mean_dplus_tmp[segIndx - 1] * std_dminus_tmp[segIndx - 1] +
         mean_dminus_tmp[segIndx - 1] * std_dplus_tmp[segIndx - 1])),
        fontsize=12,
        transform=ax2.transAxes
        )
    ax2.grid(True)
    ax2.tick_params(
        axis='both', which='major', labelsize=15, width=2, length=5
        )
    ax2.tick_params(axis='both', which='minor', width=1.5, length=3.5)

    fig.text(
        0.02, 0.003, '{location}\n{instrument}\nVersion {version}'.format(
            location=location,
            instrument=pollyVersion,
            version=version
            ),
        fontsize=10
        )

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.43, 0.006, 0.1, 0.05], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.55, 0.005, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.82, 0.003,
            u"Copyright \u00A9 {0}\n{1}\n{2}".format(
                datetime.now().strftime('%Y'), 'TROPOS', partnerLabel),
            fontweight='bold', fontsize=10, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    caliTime = datenum_to_datetime(thisCaliTime[0])
    plt.tight_layout()
    plt.savefig(
        os.path.join(
            saveFolder,
            '{start}_DepolCali_{wave}.{imgFmt}'.format(
                start=caliTime.strftime('%Y%m%d-%H%M'),
                wave=wavelength,
                imgFmt=imgFormat
                )
            ),
        dpi=figDPI
        )
    plt.close()


def main():
    pollyxt_display_depolcali(
        'D:\\coding\\matlab\\pollynet_Processing_Chain\\tmp\\',
        'C:\\Users\\zpyin\\Desktop')


if __name__ == '__main__':
    # main()
    pollyxt_display_depolcali(sys.argv[1], sys.argv[2])
