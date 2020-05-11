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


def polly_first_display_att_beta(tmpFile, saveFolder):
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
    polly_first_display_att_beta(tmpFile)

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
        ATT_BETA_532 = mat['ATT_BETA_532'][:]
        if mat['height'].size:
            height = mat['height'][0][:]
        else:
            height = np.array([])
        if mat['time'].size:
            time = mat['time'][0][:]
        else:
            time = np.array([])
        att_beta_cRange_532 = mat['att_beta_cRange_532'][0][:]
        yLim_att_beta = mat['yLim_att_beta'][:][0]
        flagLC532 = mat['flagLC532'][:][0]
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

    # meshgrid
    Time, Height = np.meshgrid(time, height)

    # define the colormap
    cmap = plt.cm.jet
    cmap.set_bad('k', alpha=1)
    cmap.set_over('w', alpha=1)
    cmap.set_under('k', alpha=1)

    # display attenuate backscatter at 532 FR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, ATT_BETA_532 * 1e6,
        vmin=att_beta_cRange_532[0], vmax=att_beta_cRange_532[1], cmap=cmap,
        rasterized=True)
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_ylim(yLim_att_beta.tolist())
    ax.yaxis.set_major_locator(MultipleLocator(2000))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(
        axis='both', which='major', labelsize=15,
        right=True, top=True, width=2, length=5
        )
    ax.tick_params(
        axis='both', which='minor',
        width=1.5, length=3.5, right=True, top=True
        )

    ax.set_title(
        'Attenuated Backscatter at ' +
        '{wave}nm Far-Range from {instrument} at {location}'.format(
            wave=532, instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.93, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(
        pcmesh, cax=cb_ax,
        ticks=np.linspace(att_beta_cRange_532[0], att_beta_cRange_532[1], 5),
        orientation='vertical'
        )
    cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
    cbar.ax.set_title('$Mm^{-1}*sr^{-1}$', fontsize=10)

    fig.text(
        0.05, 0.04,
        datenum_to_datetime(time[0]).strftime("%Y-%m-%d"), fontsize=15
        )
    fig.text(
        0.8, 0.02,
        'Version: {version}\nCalibration: {method}'.format(
            version=version, method=flagLC532
            ),
        fontsize=12
        )

    fig.savefig(
        os.path.join(
            saveFolder, '{dataFilename}_ATT_BETA_532.{imgFmt}'.format(
                dataFilename=rmext(dataFilename),
                imgFmt=imgFormat
                )
            ),
        dpi=figDPI
        )
    plt.close()


def main():
    polly_first_display_att_beta(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop'
        )


if __name__ == '__main__':
    # main()
    polly_first_display_att_beta(sys.argv[1], sys.argv[2])
