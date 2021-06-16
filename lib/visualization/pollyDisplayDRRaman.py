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


def pollyDisplayDRRaman(tmpFile, saveFolder):
    """
    Description
    -----------
    Display the profiles of aerosol optical properties and meteorological data.

    Parameters
    ----------
    tmpFile: str
    the .mat file which stores the data.

    saveFolder: str

    Usage
    -----
    pollyDisplayDRRaman(tmpFile, saveFolder)

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
        startInd = mat['startInd'][:][0][0]
        endInd = mat['endInd'][:][0][0]
        height = mat['height'][:][0]
        time = mat['time'][:][0]
        vdr355_raman = mat['vdr355_raman'][:][0]
        vdr532_raman = mat['vdr532_raman'][:][0]
        pdr355_raman = mat['pdr355_raman'][:][0]
        pdr532_raman = mat['pdr532_raman'][:][0]
        meteorSource = mat['meteorSource'][:][0]
        temperature = mat['temperature'][:][0]
        pressure = mat['pressure'][:][0]
        pollyVersion = mat['CampaignConfig']['name'][0][0][0]
        location = mat['CampaignConfig']['location'][0][0][0]
        version = mat['PicassoConfig']['PicassoVersion'][0][0][0]
        fontname = mat['PicassoConfig']['fontname'][0][0][0]
        dataFilename = mat['PollyDataInfo']['pollyDataFile'][0][0][0]
        yLim_Profi_DR = mat['yLim_Profi_DR'][:][0]
        imgFormat = mat['imgFormat'][:][0]

    except Exception as e:
        print(e)
        print('Failed reading %s' % (tmpFile))
        return

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # display depol ratio with raman method
    fig = plt.figure(figsize=[5, 8])
    ax = fig.add_axes([0.21, 0.15, 0.74, 0.75])
    p1, = ax.plot(vdr355_raman, height, color='#2492ff',
                  linestyle='-', label='$\delta_{vol, 355}$', zorder=2)
    p2, = ax.plot(vdr532_raman, height, color='#80ff00',
                  linestyle='-', label='$\delta_{vol, 532}$', zorder=2)
    p3, = ax.plot(pdr355_raman, height, color='#0000ff',
                  linestyle='--', label='$\delta_{par, 355}$', zorder=3)
    p4, = ax.plot(pdr532_raman, height, color='#008040',
                  linestyle='--', label='$\delta_{par, 532}$', zorder=3)

    ax.set_xlabel('Depolarization Ratio', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)
    ax.legend(handles=[p1, p2, p3, p4], loc='upper right', fontsize=15)

    ax.set_ylim(yLim_Profi_DR.tolist())
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim([-0.01, 0.4])
    ax.grid(True)
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    starttime = time[startInd - 1]
    endtime = time[endInd - 1]
    ax.set_title(
        '{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(
            instrument=pollyVersion,
            location=location,
            starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'),
            endtime=datenum_to_datetime(endtime).strftime('%H:%M')
            ),
        fontsize=15
        )

    # add watermark
    if flagWatermarkOn:
        rootDir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        im_license = matplotlib.image.imread(
            os.path.join(rootDir, 'img', 'by-sa.png'))

        newax_license = fig.add_axes([0.3, 0.002, 0.14, 0.07], zorder=10)
        newax_license.imshow(im_license, alpha=0.8, aspect='equal')
        newax_license.axis('off')

        fig.text(0.46, 0.012, 'Preliminary\nResults.',
                 fontweight='bold', fontsize=12, color='red',
                 ha='left', va='bottom', alpha=0.8, zorder=10)

        fig.text(
            0.69, 0.003,
            u"\u00A9 {1} {0}.\nCC BY SA 4.0 License.".format(
                datetime.now().strftime('%Y'), partnerLabel),
            fontweight='bold', fontsize=7, color='black', ha='left',
            va='bottom', alpha=1, zorder=10)

    fig.text(0.02, 0.01, 'Version: {version}\nMethod: {method}'.format(
        version=version, method='Raman'), fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFile}_{starttime}_{endtime}_DepRatio_Raman.{imgFmt}'.format(
                dataFile=rmext(os.path.basename(dataFilename)),
                starttime=datenum_to_datetime(starttime).strftime('%H%M'),
                endtime=datenum_to_datetime(endtime).strftime('%H%M'),
                imgFmt=imgFormat)
                ),
        dpi=figDPI
        )
    plt.close()


def main():
    pollyDisplayDRRaman(
        'D:\\coding\\matlab\\pollynet_Processing_Chain\\tmp\\',
        'C:\\Users\\zpyin\\Desktop')


if __name__ == '__main__':
    # main()
    pollyDisplayDRRaman(sys.argv[1], sys.argv[2])
