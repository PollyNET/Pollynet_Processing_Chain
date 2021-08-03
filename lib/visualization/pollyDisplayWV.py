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


def pollyDisplayWV(tmpFile, saveFolder):
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
    pollyDisplayWV(tmpFile)

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
        WVMR = mat['WVMR'][:]
        RH = mat['RH'][:]
        lowSNRMask = mat['lowSNRMask'][:]
        height = mat['height'][0][:]
        time = mat['time'][0][:]
        flagCalibrated = mat['flagCalibrated'][:][0]
        wvconstUsed = mat['wvconstUsed'][:][0][0]
        meteorSource = mat['meteorSource'][:][0][0][0]
        pollyVersion = mat['CampaignConfig']['name'][0][0][0]
        location = mat['CampaignConfig']['location'][0][0][0]
        version = mat['PicassoConfig']['PicassoVersion'][0][0][0]
        fontname = mat['PicassoConfig']['fontname'][0][0][0]
        dataFilename = mat['PollyDataInfo']['pollyDataFile'][0][0][0]
        yLim_WV_RH = mat['yLim_WV_RH'][:][0]
        xLim_Profi_WV_RH = mat['xLim_Profi_WV_RH'][:][0]
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
    WVMR = np.ma.masked_where(lowSNRMask != 0, WVMR)
    RH = np.ma.masked_where(lowSNRMask != 0, RH)

    # define the colormap
    cmap = load_colormap(name=colormap_basic)

    # display WVMR
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, WVMR,
        vmin=xLim_Profi_WV_RH[0],
        vmax=xLim_Profi_WV_RH[1],
        cmap=cmap,
        rasterized=True, shading='nearest'
        )
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_ylim(yLim_WV_RH.tolist())
    ax.yaxis.set_major_locator(MultipleLocator(2000))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Water vapor mixing ratio from {instrument} at {location}'.format(
            instrument=pollyVersion, location=location
            ),
        fontsize=15
        )

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.linspace(
        xLim_Profi_WV_RH[0], xLim_Profi_WV_RH[1], 5), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=10)
    cbar.ax.set_title('      [$g*kg^{-1}$]', fontsize=10)

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

    fig.text(0.01, 0.02,
             '{0}    WVconst: {1:6.2f}\nMeteor Data: {2:s}'.format(
                datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
                wvconstUsed, meteorSource),
             fontsize=12)
    fig.text(0.33, 0.02, 'Version: {version}\nCalibration: {status}'.format(
        version=version, status=flagCalibrated), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_WVMR.{imgFmt}'.format(
        dataFilename=rmext(os.path.basename(dataFilename)),
        imgFmt=imgFormat)), dpi=figDPI)
    plt.close()

    # display RH
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.1, 0.15, 0.8, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, RH, vmin=0, vmax=100, cmap=cmap,
        rasterized=True, shading='nearest')
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.set_ylim(yLim_WV_RH.tolist())
    ax.yaxis.set_major_locator(MultipleLocator(2000))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title('Relative humidity from {instrument} at {location}'.format(
        instrument=pollyVersion, location=location), fontsize=15)

    cb_ax = fig.add_axes([0.92, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(
        0, 100.1, 20), orientation='vertical')
    cbar.ax.tick_params(direction='in', labelsize=15, pad=10)
    cbar.ax.set_title('[$\%$]', fontsize=10)

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

    fig.text(0.01, 0.02,
             '{0}    WVconst: {1:6.2f}\nMeteor Data: {2:s}'.format(
                datenum_to_datetime(time[0]).strftime("%Y-%m-%d"),
                wvconstUsed, meteorSource),
             fontsize=12)
    fig.text(0.33, 0.02, 'Version: {version}\nCalibration: {status}'.format(
        version=version, status=flagCalibrated), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_RH.{imgFmt}'.format(
        dataFilename=rmext(os.path.basename(dataFilename)),
        imgFmt=imgFormat)), dpi=figDPI)
    plt.close()


def main():
    pollyDisplayWV(
        'D:\\coding\\matlab\\pollynet_Processing_Chain\\tmp',
        'C:\\Users\\zhenping\\Desktop'
        )


if __name__ == '__main__':
    # main()
    pollyDisplayWV(sys.argv[1], sys.argv[2])
