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


def pollyDisplayPoliphon(tmpFile, saveFolder):
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
    pollyDisplayRH(tmpFile, saveFolder)

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
        height = mat['height'][:][0]/1000
        time = mat['time'][:][0]
        aerBsc_532_raman = mat['aerBsc_532_raman'][:][0]*1000000
        poliphon_R532d1 = mat['poliphon_aerBsc532_raman_d1'][:][0]*1000000
        poliphon_R532nd1 = mat['poliphon_aerBsc532_raman_nd1'][:][0]*1000000
        err_poliphon_R532d1 = mat['err_poliphon_aerBsc532_raman_d1'][:][0]*1000000
        err_poliphon_R532nd1 = mat['err_poliphon_aerBsc532_raman_nd1'][:][0]*1000000
        meteorSource = mat['meteorSource'][:][0]
        temperature = mat['temperature'][:][0]
        pressure = mat['pressure'][:][0]
        pollyVersion = mat['CampaignConfig']['name'][0][0][0]
        location = mat['CampaignConfig']['location'][0][0][0]
        version = mat['PicassoConfig']['PicassoVersion'][0][0][0]
        fontname = mat['PicassoConfig']['fontname'][0][0][0]
        dataFilename = mat['PollyDataInfo']['pollyDataFile'][0][0][0]
        yLim_Profi_Bsc = mat['yLim_Profi_Bsc'][:][0]/1000
        zLim_att_beta_355 = mat['zLim_att_beta_355'][:][0]
        imgFormat = mat['imgFormat'][:][0]

    except Exception as e:
        print(e)
        print('Failed reading %s' % (tmpFile))
        return

#    exit()

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # display POLIPHON
    fig = plt.figure(figsize=[5, 8])
    ax = fig.add_axes([0.21, 0.15, 0.74, 0.75])
    p0, = ax.plot(aerBsc_532_raman, height, color='#333', linestyle='-',
                  label='532nm_raman_total', zorder=2)
    p1, = ax.plot(poliphon_R532d1, height, color='orange', linestyle='-',
                  label='532nm_raman_dust', zorder=2)

    p2, = ax.plot(poliphon_R532nd1, height, color='darkolivegreen',
                  linestyle='-', label='532nm_raman_non-dust', zorder=2)

    ax.fill_betweenx(height, poliphon_R532d1-err_poliphon_R532d1, poliphon_R532d1+err_poliphon_R532d1, color = 'orange', alpha= 0.1)
    ax.fill_betweenx(height, poliphon_R532nd1-err_poliphon_R532nd1, poliphon_R532nd1+err_poliphon_R532nd1, color = 'darkolivegreen', alpha= 0.1)

    ax.set_xlabel('Backscatter coeff. [Mm$^{-1}$ sr$^{-1}$]', fontsize=15)
    ax.set_ylabel('Height (km)', fontsize=15)
    ax.legend(handles=[p0, p1, p2], loc='upper right', fontsize=13)

#    ax.set_xlim([0, 100])
    ax.set_xlim(zLim_att_beta_355.tolist())
    ax.set_ylim(yLim_Profi_Bsc.tolist())
    ax.yaxis.set_major_locator(MultipleLocator(5))
    ax.yaxis.set_minor_locator(MultipleLocator(1))

    ax.grid(True)
    ax.tick_params(axis='both', which='major', labelsize=15,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    starttime = time[startInd - 1]
    endtime = time[endInd - 1]
    ax.set_title(
        '{instrument} at {location}\nPOLIPHON {starttime}-{endtime}'.format(
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

    fig.text(
        0.02, 0.01,
        'Version: {0}'.format(
            version), fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            '{dataFile}_{starttime}_{endtime}_POLIPHON_step1_Raman.{imgFmt}'.format(
                dataFile=rmext(os.path.basename(dataFilename)),
                starttime=datenum_to_datetime(starttime).strftime('%H%M'),
                endtime=datenum_to_datetime(endtime).strftime('%H%M'),
                imgFmt=imgFormat)
                ),
        dpi=figDPI
        )
    plt.close()


def main():
    pollyDisplayPoliphon(
        '/pollyhome/Bildermacher2/experimental/akl/Pollynet_Processing_Chain/tmp/tp679b142b_11af_402b_8e77_cbabe2d8214d.mat',
        '/pollyhome/Bildermacher2/experimental/akl/')


if __name__ == '__main__':
#    main()
    pollyDisplayPoliphon(sys.argv[1], sys.argv[2])
    
