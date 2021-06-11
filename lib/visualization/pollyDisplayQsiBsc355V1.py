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


def pollyDisplayQsiBsc355V1(tmpFile, saveFolder):
    '''
    Description
    -----------
    Display quasi-retrieved products.

    Parameters
    ----------
    tmpFile: str
    the .mat file which stores the housekeeping data.

    saveFolder: str

    Usage
    -----
    pollyDisplayQsiBsc355V1(tmpFile, saveFolder)

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
        flagWatermarkOn = mat['flagWatermarkOn'][0][0]
        if mat['partnerLabel'].size:
            partnerLabel = mat['partnerLabel'][0]
        else:
            partnerLabel = ''
        quasi_bsc_355 = mat['quasi_bsc_355'][:]
        quality_mask_355 = mat['quality_mask_355'][:]
        height = mat['height'][0][:]
        time = mat['time'][0][:]
        yLim_Quasi_Params = mat['yLim_Quasi_Params'][:][0]
        quasi_beta_cRange_355 = mat['quasi_beta_cRange_355'][0][:]
        pollyVersion = mat['CampaignConfig']['name'][0][0][0]
        location = mat['CampaignConfig']['location'][0][0][0]
        version = mat['PicassoConfig']['programVersion'][0][0][0]
        fontname = mat['PicassoConfig']['fontname'][0][0][0]
        dataFilename = mat['PollyDataInfo']['dataFilename'][0][0][0]
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
    quasi_bsc_355 = np.ma.masked_where(quality_mask_355 > 0, quasi_bsc_355)

    # define the colormap
    cmap = load_colormap(name=colormap_basic)

    # display quasi backscatter at 355 nm
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.11, 0.15, 0.79, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, quasi_bsc_355 * 1e6,
        vmin=quasi_beta_cRange_355[0],
        vmax=quasi_beta_cRange_355[1],
        cmap=cmap,
        rasterized=True, shading='nearest'
        )
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(2000))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_ylim(yLim_Quasi_Params.tolist())
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Quasi backscatter coefficient at {wave}nm'.format(wave=355) +
        ' from {instrument} at {location}'.format(
            instrument=pollyVersion,
            location=location
            ),
        fontsize=15
        )

    cb_ax = fig.add_axes([0.94, 0.20, 0.02, 0.65])
    cbar = fig.colorbar(
        pcmesh, cax=cb_ax, ticks=np.linspace(
            quasi_beta_cRange_355[0],
            quasi_beta_cRange_355[1],
            5
            ),
        orientation='vertical'
        )
    cbar.ax.tick_params(direction='in', labelsize=15, pad=5)
    cbar.ax.set_title('$Mm^{-1}*sr^{-1}$', fontsize=12)

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

    fig.text(0.05, 0.02, datenum_to_datetime(
        time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.2, 0.02, 'Version: {version}'.format(
        version=version), fontsize=12)

    fig.savefig(os.path.join(
        saveFolder, '{dataFilename}_Quasi_Bsc_355.{imgFmt}'.format(
            dataFilename=rmext(dataFilename),
            imgFmt=imgFormat
        )), dpi=figDPI)
    plt.close()


def main():
    pollyDisplayQsiBsc355V1(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop'
        )


if __name__ == '__main__':
    # main()
    pollyDisplayQsiBsc355V1(sys.argv[1], sys.argv[2])
