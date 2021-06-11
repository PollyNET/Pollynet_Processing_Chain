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


def pollyDisplayLC355FR(tmpFile, saveFolder):
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
    pollyDisplayLC355FR(tmpFile)

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
        thisTime = np.concatenate(mat['thisTime'][:])
        time = mat['time'][0][:]
        LC355_klett = mat['LC355_klett'][:]
        LC355_raman = mat['LC355_raman'][:]
        LC355_aeronet = mat['LC355_aeronet'][:]
        yLim355 = mat['yLim355'][0][:]
        pollyVersion = mat['CampaignConfig']['name'][0][0][0]
        location = mat['CampaignConfig']['location'][0][0][0]
        version = mat['PicassoConfig']['programVersion'][0][0][0]
        fontname = mat['PicassoConfig']['fontname'][0][0][0]
        dataFilename = mat['PollyDataInfo']['dataFilename'][0][0][0]
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

    # display lidar constants at 355mn
    fig = plt.figure(figsize=[9, 5])
    ax = fig.add_axes([0.1, 0.15, 0.85, 0.72])
    p1, = ax.plot(
        thisTime, LC355_klett,
        color='#008040', linestyle='--', marker='^',
        markersize=10, mfc='#008040', mec='#000000', label='Klett Method'
        )
    p2, = ax.plot(
        thisTime, LC355_raman,
        color='#400080', linestyle='--', marker='o',
        markersize=10, mfc='#400080', mec='#000000', label='Raman Method'
        )
    p3, = ax.plot(
        thisTime, LC355_aeronet,
        color='#804000', linestyle='--', marker='*',
        markersize=10, mfc='#800040', mec='#000000',
        label='Constrained-AOD Method'
        )
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('C', fontsize=15)
    ax.legend(handles=[p1, p2, p3], loc='upper right', fontsize=12)

    ax.set_ylim(yLim355.tolist())
    minYLim355 = np.nanmin(np.concatenate((
                LC355_raman.reshape(-1),
                LC355_klett.reshape(-1),
                LC355_aeronet.reshape(-1),
                np.array(yLim355[0]).reshape(-1)), axis=0))
    maxYLim355 = np.nanmax(np.concatenate((
                LC355_raman.reshape(-1),
                LC355_klett.reshape(-1),
                LC355_aeronet.reshape(-1),
                np.array(yLim355[1]).reshape(-1)), axis=0))
    ax.set_yticks([0.8 * minYLim355, 1.2 * maxYLim355])
    ax.yaxis.set_major_locator(plt.MaxNLocator(prune='lower'))

    ax.set_xticks(xtick.tolist())
    ax.set_xlim([time[0], time[-1]])
    ax.set_xticklabels(celltolist(xticklabel))
    ax.grid(False)
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Lidar constants {wave}nm '.format(wave=355) +
        'Far-Range for {instrument} at {location}'.format(
            instrument=pollyVersion,
            location=location
            ),
        fontsize=15,
        position=[0.5, 1.05]
        )

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.58, 0.006, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.71, 0.003, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.84, 0.003,
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=7, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    fig.text(0.05, 0.06, datenum_to_datetime(
        time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.05, 0.02, 'Version: {version}'.format(
        version=version), fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFilename}_LC_355.{imgFmt}'.format(
                dataFilename=rmext(dataFilename),
                imgFmt=imgFormat)), dpi=figDPI)
    plt.close()


def main():
    pollyDisplayLC355FR(
        'D:\\coding\\matlab\\pollynet_Processing_Chain\\tmp',
        'C:\\Users\\zpyin\\Desktop'
        )


if __name__ == '__main__':
    # main()
    pollyDisplayLC355FR(sys.argv[1], sys.argv[2])
