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


def polly_first_display_longterm_cali(tmpFile, saveFolder):
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
    polly_first_display_longterm_cali(tmpFile)

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
        if mat['LCTime532'].size:
            thisLCTime532 = mat['LCTime532'][0][:]
        else:
            thisLCTime532 = np.array([])
        if mat['LCTime607'].size:
            thisLCTime607 = mat['LCTime607'][0][:]
        else:
            thisLCTime607 = np.array([])
        LC532Status = mat['LC532Status'][0][:]
        LC532History = mat['LC532History'][0][:]
        LC607Status = mat['LC607Status'][0][:]
        LC607History = mat['LC607History'][0][:]
        if mat['logbookTime'].size:
            thisLogbookTime = mat['logbookTime'][0][:]
        else:
            thisLogbookTime = np.array([])
        if mat['flagOverlap'].size:
            flagOverlap = mat['flagOverlap'][0][:]
        else:
            flagOverlap = np.array([])
        if mat['flagWindowwipe'].size:
            flagWindowwipe = mat['flagWindowwipe'][0][:]
        else:
            flagWindowwipe = np.array([])
        if mat['flagFlashlamps'].size:
            flagFlashlamps = mat['flagFlashlamps'][0][:]
        else:
            flagFlashlamps = np.array([])
        if mat['flagPulsepower'].size:
            flagPulsepower = mat['flagPulsepower'][0][:]
        else:
            flagPulsepower = np.array([])
        if mat['flagRestart'].size:
            flagRestart = mat['flagRestart'][0][:]
        else:
            flagRestart = np.array([])
        if mat['flag_CH_NDChange'].size:
            flag_CH_NDChange = mat['flag_CH_NDChange'][:]
        else:
            flag_CH_NDChange = np.array([])
        if mat['flagCH532FR'].size:
            flagCH532FR = mat['flagCH532FR'][0][:]
        else:
            flagCH532FR = np.array([])
        if mat['flagCH607FR'].size:
            flagCH607FR = mat['flagCH607FR'][0][:]
        else:
            flagCH607FR = np.array([])
        else_time = mat['else_time'][:]
        else_label = mat['else_label']
        if mat['yLim532'].size:
            yLim532 = mat['yLim532'][0][:]
        else:
            yLim532 = np.array([])
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        dataTime = mat['taskInfo']['dataTime'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        startTime = mat['campaignInfo']['startTime'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        fontname = mat['processInfo']['fontname'][0][0][0]
        imgFormat = mat['imgFormat'][:][0]
    except Exception as e:
        print(e)
        print('Failed reading %s' % (tmpFile))
        return

    # set the default font
    matplotlib.rcParams['font.sans-serif'] = fontname
    matplotlib.rcParams['font.family'] = "sans-serif"

    # convert matlab datenum tp datetime
    startTime = datenum_to_datetime(float(startTime[0]))
    dataTime = datenum_to_datetime(float(dataTime[0]))
    LCTime532 = [datenum_to_datetime(thisTime) for thisTime in thisLCTime532]
    LCTime607 = [datenum_to_datetime(thisTime) for thisTime in thisLCTime607]
    logbookTime = [datenum_to_datetime(thisTime)
                   for thisTime in thisLogbookTime]
    elseTime = [datenum_to_datetime(thisElseTime)
                for thisElseTime in else_time]
    
    lineColor = {
        'overlap': '#f48f42',
        'windowwipe': '#ff66ff',
        'flashlamps': '#993333',
        'pulsepower': '#990099',
        'restart': '#ffff00',
        'NDChange': '#333300',
        'else': '#00ff00'
        }

    # display lidar constants at 355mn
    fig, (ax1, ax2, ax3) = plt.subplots(
        3, figsize=(10, 9), sharex=True,
        gridspec_kw={'height_ratios': [1, 1, 1], 'hspace': 0.1})
    plt.subplots_adjust(top=0.96, bottom=0.05, left=0.07, right=0.98)

    # lidar constant at 532 nm
    LCTime532 = [
        LCTime532[indx]
        for indx in np.arange(0, len(LCTime532))
        if LC532Status[indx] == 2]
    p1 = ax1.scatter(
        LCTime532, LC532History[LC532Status == 2],
        s=7, c='#0000ff', marker='o')

    for iLogbookInfo in np.arange(0, len(logbookTime)):
        if flagOverlap[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['overlap'])
        if flagPulsepower[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['pulsepower'])
        if flagWindowwipe[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['windowwipe'])
        if flagRestart[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['restart'])
        if flagFlashlamps[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['flashlamps'])
        if flag_CH_NDChange[iLogbookInfo, flagCH532FR == 1]:
            ax1.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['NDChange'])

    for elseTime in else_time:
        ax1.axvline(x=elseTime, linestyle='--', color=lineColor['else'])

    ax1.set_ylabel('LC @ 532nm')
    ax1.grid(False)
    ax1.set_title('Lidar constants for {instrument} at {location}'.format(
        instrument=pollyVersion, location=location), fontsize=20)
    ax1.set_ylim(yLim532.tolist())
    ax1.set_xlim([startTime - timedelta(days=2), dataTime + timedelta(days=2)])

    # transmission ratio at 532/607 nm
    flagRamanLC = np.logical_and(LC532Status == 2, LC607Status == 2)
    LCTimRaman = [
        LCTime607[indx]
        for indx in np.arange(0, len(LCTime607))
        if flagRamanLC[indx]]
    p1 = ax2.scatter(
        LCTimRaman, LC532History[flagRamanLC] / LC607History[flagRamanLC],
        s=7, c='#0000ff', marker='o')

    for iLogbookInfo in np.arange(0, len(logbookTime)):
        if flagOverlap[iLogbookInfo]:
            ax2.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['overlap'])
        if flagPulsepower[iLogbookInfo]:
            ax2.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['pulsepower'])
        if flagWindowwipe[iLogbookInfo]:
            ax2.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['windowwipe'])
        if flagRestart[iLogbookInfo]:
            ax2.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['restart'])
        if flagFlashlamps[iLogbookInfo]:
            ax2.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['flashlamps'])
        if flag_CH_NDChange[iLogbookInfo, flagCH532FR == 1] or \
           flag_CH_NDChange[iLogbookInfo, flagCH607FR == 1]:
            ax2.axvline(x=logbookTime[iLogbookInfo],
                        linestyle='--', color=lineColor['NDChange'])

    for elseTime in else_time:
        ax2.axvline(x=elseTime, linestyle='--', color=lineColor['else'])

    ax2.set_ylabel('Ratio 532/607')
    ax2.grid(False)
    ax2.set_ylim([0, 2])
    ax2.set_xlim([startTime - timedelta(days=2), dataTime + timedelta(days=2)])

    fig.text(0.03, 0.01, startTime.strftime("%Y"), fontsize=12)
    fig.text(0.90, 0.01, 'Version: {version}'.format(
        version=version), fontsize=12)

    fig.savefig(
        os.path.join(
            saveFolder,
            '{pollyType}_{date}_long_term_cali_results.{imgFmt}'.format(
                pollyType=pollyVersion,
                date=dataTime.strftime('%Y%m%d')
                imgFmt=imgFormat
            )), dpi=figDPI)
    plt.close()


def main():
    polly_first_display_longterm_cali(
        'C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat',
        'C:\\Users\\zhenping\\Desktop\\Picasso\\' +
        'recent_plots\\polly_first\\20181214')


if __name__ == '__main__':
    # main()
    polly_first_display_longterm_cali(sys.argv[1], sys.argv[2])
