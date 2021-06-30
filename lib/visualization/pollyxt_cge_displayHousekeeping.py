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


def pollyxt_cge_displayHousekeeping(tmpFile, saveFolder):
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
    pollyxt_cge_displayHousekeeping(tmpFile)

    History
    -------
    2019-01-10. First edition by Zhenping
    '''

    if not os.path.exists(tmpFile):
        print('{filename} does not exists.'.format(filename=tmpFile))
        return

    # read data
    try:
        mat = spio.loadmat(tmpFile, struct_as_record=True)
        figDPI = mat['figDPI'][0][0]
        flagWatermarkOn = mat['flagWatermarkOn'][0][0]
        if mat['partnerLabel'].size:
            partnerLabel = mat['partnerLabel'][0]
        else:
            partnerLabel = ''
        time = mat['monitorStatus']['time'][0][0]
        mTime = mat['mTime'][0][:]
        AD = mat['monitorStatus']['AD'][0][0]
        EN = mat['monitorStatus']['EN'][0][0]
        HT = mat['monitorStatus']['HT'][0][0]
        WT = mat['monitorStatus']['WT'][0][0]
        shutter2 = mat['monitorStatus']['LS'][0][0]
        counts = mat['monitorStatus']['counts'][0][0]
        HV1064 = mat['monitorStatus']['HV1064'][0][0]
        Temp1 = mat['monitorStatus']['Temp1'][0][0]
        Temp2 = mat['monitorStatus']['Temp2'][0][0]
        pollyVersion = mat['CampaignConfig']['name'][0][0][0]
        location = mat['CampaignConfig']['location'][0][0][0]
        version = mat['PicassoConfig']['PicassoVersion'][0][0][0]
        fontname = mat['PicassoConfig']['fontname'][0][0][0]
        dataFilename = mat['PollyDataInfo']['pollyDataFile'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
        imgFormat = mat['imgFormat'][:][0]
    except Exception as e:
        print(e)
        print('Failed reading %s' % (tmpFile))
        return

    # filter out the invalid values
    HT = np.ma.masked_greater(HT, 990)
    WT = np.ma.masked_greater(WT, 990)
    HV1064 = np.ma.masked_less(HV1064, 0)
    Temp1 = np.ma.masked_outside(Temp1, -40, 990)
    Temp2 = np.ma.masked_outside(Temp2, -40, 990)
    shutter2 = np.ma.masked_greater(shutter2, 10)
    AD = np.ma.masked_outside(AD, 0, 990)
    EN = np.ma.masked_outside(EN, 0, 990)

    flags = np.transpose(np.ma.hstack((shutter2, shutter2)))

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # visualization (credits to Martin's python program)
    fig, (ax1, ax2, ax3, ax4) = plt.subplots(
        4, figsize=(15, 11),
        sharex=True, gridspec_kw={
            'height_ratios': [1, 1, 1.6, 0.2],
            'hspace': 0.10,
            'left': 0.09, 'right': 0.97, 'top': 0.97, 'bottom': 0.06})

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

    ax1.set_title('Housekeeping data for {polly} at {site}'.format(
        polly=pollyVersion, site=location), fontsize=17)

    ax2.plot(time, HV1064, marker='.', color='#8000ff')
    # ax2.set_ylim([1, 37])
    ax2.set_xlim([mTime[0], mTime[-1]])
    ax2.set_ylabel("HV1064 [V]", fontsize=15)
    ax2.grid(True)

    ax3.plot(time, HT, color='#8080ff', label='Laser Head')
    ax3.plot(time, Temp1, color='#ff8000', label='Temp1')
    ax3.plot(time, Temp2, color='#008000', label='Temp2')
    ax3.plot(time, WT, color='#808080', label='Water T')
    ax3.set_xlim([mTime[0], mTime[-1]])
    ax3.set_ylim([0, 40])
    ax3.grid(True)
    ax3.set_ylabel(r'Temperature [$^\circ C$]', fontsize=15)
    ax3.yaxis.set_minor_locator(matplotlib.ticker.MultipleLocator(1))
    if len(time):
        ax3.legend(loc='upper left')

    if len(time):
        cmap = ListedColormap(
            ['navajowhite', 'coral', 'skyblue', 'm', 'mediumaquamarine'])
        pcmesh = ax4.pcolormesh(
            np.transpose(time), np.arange(2), flags,
            cmap=cmap, vmin=-0.5, vmax=1.5, shading='auto')
        cb_ax = fig.add_axes([0.84, 0.11, 0.12, 0.016])
        cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=[
                            0, 1, 2, 3, 4], orientation='horizontal')
        cbar.ax.tick_params(labeltop=True, direction='in', labelbottom=False,
                            bottom=False, top=True, labelsize=12, pad=0.00)

    ax4.set_ylim([0, 1])
    ax4.set_yticks([0.5])
    ax4.set_yticklabels(['SH'])
    ax4.set_xticks(xtick.tolist())
    ax4.set_xticklabels(celltolist(xticklabel))
    ax4.set_xlim([mTime[0], mTime[-1]])

    for ax in (ax1, ax2, ax3, ax4):
        ax.tick_params(axis='both', which='major', labelsize=15,
                       right=True, top=True, width=2, length=5)
        ax.tick_params(axis='both', which='minor', width=1.5,
                       length=3.5, right=True, top=True)

    ax4.set_xlabel('UTC', fontsize=15)
    fig.text(0.05, 0.01, datenum_to_datetime(
        mTime[0]).strftime("%Y-%m-%d"), fontsize=17)
    fig.text(0.17, 0.01, 'Version: {version}'.format(
        version=version), fontsize=17)
    if counts.size != 0:
        fig.text(0.1, 0.90, 'SC begin {:.1f}Mio'.format(
            counts[0][0]/1e6), fontsize=17)
        fig.text(0.85, 0.90, 'end {:.1f}Mio'.format(
            counts[0][-1]/1e6), fontsize=17)

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.63, 0, 0.08, 0.04], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.72, 0.003, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=15, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.84, 0.003,
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=10, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    # plt.tight_layout()
    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFilename}_monitor.{imgFmt}'.format(
                dataFilename=rmext(os.path.basename(dataFilename)),
                imgFmt=imgFormat)),
        dpi=figDPI)

    plt.close()


def main():
    pollyxt_cge_displayHousekeeping(
        # 'D:\\coding\\matlab\\pollynet_Processing_Chain\\tmp',
        'C:\\Users\\zhenping\\Desktop')


if __name__ == '__main__':
    # main()
    pollyxt_cge_displayHousekeeping(sys.argv[1], sys.argv[2])
