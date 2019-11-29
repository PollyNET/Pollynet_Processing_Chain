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


def pollyxt_cge_display_targetclassi_V2(tmpFile, saveFolder):
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
    pollyxt_cge_display_targetclassi_V2(tmpFile)

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
        TC_mask = mat['TC_mask'][:]
        height = mat['height'][0][:]
        time = mat['time'][0][:]
        yLim_Quasi_Params = mat['yLim_Quasi_Params'][:][0]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        xtick = mat['xtick'][0][:]
        xticklabel = mat['xtickstr']
    except Exception as e:
        print(e)
        print('Failed reading %s' % (tmpFile))
        return

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # meshgrid
    Time, Height = np.meshgrid(time, height)

    # load colormap
    dirname = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sys.path.append(dirname)
    try:
        from python_colormap import target_classification_colormap
    except Exception as e:
        raise ImportError('python_colormap module is necessary.')

    # display aerosol target classification
    fig = plt.figure(figsize=[10, 5])
    ax = fig.add_axes([0.09, 0.15, 0.67, 0.75])
    pcmesh = ax.pcolormesh(
        Time, Height, TC_mask,
        vmin=-0.5, vmax=11.5, cmap=target_classification_colormap()
        )
    ax.set_xlabel('UTC', fontsize=15)
    ax.set_ylabel('Height (m)', fontsize=15)

    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_ylim(yLim_Quasi_Params.tolist())
    ax.set_xticks(xtick.tolist())
    ax.set_xticklabels(celltolist(xticklabel))
    ax.tick_params(axis='both', which='major', labelsize=12,
                   right=True, top=True, width=2, length=5)
    ax.tick_params(axis='both', which='minor', width=1.5,
                   length=3.5, right=True, top=True)

    ax.set_title(
        'Target classifications (V2) from {instrument} at {location}'.format(
            instrument=pollyVersion, location=location
            ),
        fontsize=15
        )

    cb_ax = fig.add_axes([0.77, 0.15, 0.01, 0.75])
    cbar = fig.colorbar(pcmesh, cax=cb_ax, ticks=np.arange(
        0, 12, 1), orientation='vertical')
    cbar.ax.tick_params(direction='out', labelsize=10, pad=5)
    cbar.ax.set_yticklabels(['No signal',
                             'Clean atmosphere',
                             'Non-typed particleslow conc.',
                             'Aerosol: small',
                             'Aerosol: large, spherical',
                             'Aerosol: mix., non-spherical',
                             'Aerosol: large, non-spherical',
                             'Cloud: non-typed',
                             'Cloud: water droplets',
                             'Cloud: likely water droplets',
                             'Cloud: ice crystals',
                             'Cloud: likely ice crystals'])

    fig.text(0.05, 0.02, datenum_to_datetime(
        time[0]).strftime("%Y-%m-%d"), fontsize=12)
    fig.text(0.64, 0.02, 'Version: {version}'.format(
        version=version), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_TC_V2.png'.format(
        dataFilename=rmext(dataFilename))), dpi=figDPI)
    plt.close()


def main():
    pollyxt_cge_display_targetclassi_V2(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop'
        )


if __name__ == '__main__':
    # main()
    pollyxt_cge_display_targetclassi_V2(sys.argv[1], sys.argv[2])
