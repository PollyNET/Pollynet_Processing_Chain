import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
from matplotlib.dates import DateFormatter, \
                             DayLocator, HourLocator, MinuteLocator, date2num
import os
import sys
import scipy.io as spio
import numpy as np
from datetime import datetime, timedelta
import matplotlib

# load colormap
dirname = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(dirname)
try:
    from python_colormap import *
except Exception as e:
    raise ImportError('python_colormap module is necessary.')

# generating figure without X server
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


def pollyxt_display_NR_att_beta(tmpFile, saveFolder):
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
    pollyxt_display_NR_att_beta(tmpFile, saveFolder)

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
        ATT_BETA_355 = mat['ATT_BETA_355'][:]
        ATT_BETA_532 = mat['ATT_BETA_532'][:]
        if mat['height'].size:
            height = mat['height'][0][:]
        else:
            height = np.array([])
        if mat['time'].size:
            time = mat['time'][0][:]
        else:
            time = np.array([])
        att_beta_cRange_355 = mat['att_beta_cRange_355'][0][:]
        att_beta_cRange_532 = mat['att_beta_cRange_532'][0][:]
        yLim_att_beta = mat['yLim_att_beta'][:][0]
        flagLC355 = mat['flagLC355'][:][0]
        flagLC532 = mat['flagLC532'][:][0]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
        imgFormat = mat['imgFormat'][:][0]
        colormap_basic = mat['colormap_basic'][:][0]
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
    cmap = load_colormap(name=colormap_basic)

    # display attenuate backscatter at 355 NR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, ATT_BETA_355 * 1e6,
        vmin=att_beta_cRange_355[0],
        vmax=att_beta_cRange_355[1],
        cmap=cmap,
        rasterized=True, shading='nearest')
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_ylim(yLim_att_beta.tolist())
    ax.yaxis.set_major_locator(MultipleLocator(500))
    ax.yaxis.set_minor_locator(MultipleLocator(100))
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(
        axis='both', which='major', labelsize=15, right=True,
        top=True, width=2, length=5)
    ax.tick_params(
        axis='both', which='minor', width=1.5, length=3.5,
        right=True, top=True)

    ax.set_title(
        'Attenuated Backscatter at {wave}nm'.format(wave=355) +
        ' Near-Range of {instrument} at {location}'.format(
            instrument=pollyVersion,
            location=location),
        fontsize=15)

    cb_ax = fig.add_axes([0.93, 0.25, 0.02, 0.55])
    cbar = fig.colorbar(
        pcmesh,
        cax=cb_ax,
        ticks=np.linspace(att_beta_cRange_355[0], att_beta_cRange_355[1], 5),
        orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
    cbar.ax.set_title('      $Mm^{-1}*sr^{-1}$\n', fontsize=10)

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.58, 0.006, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.72, 0.003, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.84, 0.003,
            u"Copyright \u00A9 {0}\n{1}\n{2}".format(
                datetime.now().strftime('%Y'), 'TROPOS', partnerLabel),
            fontweight='bold', fontsize=10, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    fig.text(
        0.05, 0.04,
        datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
        fontsize=15)
    fig.text(
        0.2, 0.02,
        'Version: {version}\nCalibration: {method}'.format(
            version=version,
            method=flagLC355
            ),
        fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFilename}_ATT_BETA_NR_355.{imgFmt}'.format(
                dataFilename=rmext(dataFilename),
                imgFmt=imgFormat)),
        dpi=figDPI)
    plt.close()

    # display attenuate backscatter at 532 NR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, ATT_BETA_532 * 1e6,
        vmin=att_beta_cRange_532[0],
        vmax=att_beta_cRange_532[1],
        cmap=cmap,
        rasterized=True, shading='nearest')
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_ylim(yLim_att_beta.tolist())
    ax.yaxis.set_major_locator(MultipleLocator(500))
    ax.yaxis.set_minor_locator(MultipleLocator(100))
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(
        axis='both', which='major', labelsize=15, right=True, top=True,
        width=2, length=5)
    ax.tick_params(
        axis='both', which='minor', width=1.5, length=3.5,
        right=True, top=True)

    ax.set_title(
        'Attenuated Backscatter at {wave}nm'.format(wave=532) +
        ' Near-Range of {instrument} at {location}'.format(
            instrument=pollyVersion,
            location=location),
        fontsize=15)

    cb_ax = fig.add_axes([0.93, 0.25, 0.02, 0.55])
    cbar = fig.colorbar(
        pcmesh,
        cax=cb_ax,
        ticks=np.linspace(att_beta_cRange_532[0], att_beta_cRange_532[1], 5),
        orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
    cbar.ax.set_title('      $Mm^{-1}*sr^{-1}$\n', fontsize=10)

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.58, 0.006, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.72, 0.003, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.84, 0.003,
            u"Copyright \u00A9 {0}\n{1}\n{2}".format(
                datetime.now().strftime('%Y'), 'TROPOS', partnerLabel),
            fontweight='bold', fontsize=10, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    fig.text(
        0.05, 0.04,
        datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
        fontsize=15)
    fig.text(
        0.2, 0.02,
        'Version: {version}\nCalibration: {method}'.format(
            version=version,
            method=flagLC532),
        fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFilename}_ATT_BETA_NR_532.{imgFmt}'.format(
                dataFilename=rmext(dataFilename),
                imgFmt=imgFormat)),
        dpi=figDPI)
    plt.close()


def main():
    pollyxt_display_NR_att_beta(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop'
        )


if __name__ == '__main__':
    # main()
    pollyxt_display_NR_att_beta(sys.argv[1], sys.argv[2])
