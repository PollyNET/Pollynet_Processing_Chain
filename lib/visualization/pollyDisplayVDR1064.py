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


def pollyDisplayVDR1064(tmpFile, saveFolder):
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
    pollyDisplayVDR1064(tmpFile, saveFolder)

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
            partnerLabel = mat['partnerLabel'][0]
        else:
            partnerLabel = ''
        mTime = mat['mTime'][0][:]
        height = mat['height'][0][:]
        depCalMask = mat['depCalMask'][0][:]
        fogMask = mat['fogMask'][0][:]
        vdr1064 = mat['vdr1064'][:]
        polCaliEta1064 = mat['polCaliEta1064'][:][0]
        pollyVersion = mat['CampaignConfig']['name'][0][0][0]
        location = mat['CampaignConfig']['location'][0][0][0]
        version = mat['PicassoConfig']['PicassoVersion'][0][0][0]
        fontname = mat['PicassoConfig']['fontname'][0][0][0]
        dataFilename = mat['PollyDataInfo']['pollyDataFile'][0][0][0]
        yLim_FR_DR = mat['yLim_FR_DR'][:][0]
        Voldepol1064ColorRange = mat['Voldepol1064ColorRange'][:][0]
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
    Time, Height = np.meshgrid(mTime, height)
    depCalMask = np.tile(depCalMask, (vdr1064.shape[0], 1))
    fogMask = np.tile(fogMask, (vdr1064.shape[0], 1))

    # define the colormap
    cmap = load_colormap(name=colormap_basic)

    # display voldepol 1064
    # filter out the invalid values
    vdr1064 = np.ma.masked_where(depCalMask != 0, vdr1064)
    vdr1064 = np.ma.masked_where(fogMask == 1, vdr1064)
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, vdr1064,
        vmin=Voldepol1064ColorRange[0],
        vmax=Voldepol1064ColorRange[1],
        cmap=cmap, rasterized=True, shading='nearest')
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_ylim([yLim_FR_DR[0], yLim_FR_DR[1]])
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Volume Depolarization Ratio at {wave}nm'.format(wave=1064) +
        ' from {instrument} at {location}'.format(
            instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(
        0, 0.41, 0.05), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=12, pad=5)
    cbar.ax.set_title('', fontsize=12)

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
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=7, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    fig.text(
        0.05, 0.02, '{0}\n$\eta$: {1:6.2f}'.format(
            datenum_to_datetime(mTime[0]).strftime("%Y-%m-%d"),
            polCaliEta1064[0]), fontsize=12)
    fig.text(0.2, 0.04, 'Version: {version}'.format(
        version=version), fontsize=14)
    fig.savefig(
        os.path.join(
            saveFolder, '{dataFilename}_VDR_1064.{imgFmt}'.format(
                dataFilename=rmext(os.path.basename(dataFilename)),
                imgFmt=imgFormat)), dpi=figDPI)
    plt.close()


def main():
    pollyDisplayVDR1064(
        'D:\\coding\\matlab\\pollynet_Processing_Chain\\',
        'C:\\Users\\zpyin\\Desktop')


if __name__ == '__main__':
    # main()
    pollyDisplayVDR1064(sys.argv[1], sys.argv[2])
