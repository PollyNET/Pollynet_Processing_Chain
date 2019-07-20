import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.dates import DateFormatter, DayLocator, HourLocator, MinuteLocator, date2num
import os, sys
import scipy.io as spio
import numpy as np
from datetime import datetime, timedelta

def celltolist(xtickstr):
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
    :param datenum: Date in datenum format
    :return:        Datetime object corresponding to datenum.
    """
    days = datenum % 1
    hours = days % 1 * 24
    minutes = hours % 1 * 60
    seconds = minutes % 1 * 60
    return datetime.fromordinal(int(datenum)) \
           + timedelta(days=int(days)) \
           + timedelta(hours=int(hours)) \
           + timedelta(minutes=int(minutes)) \
           + timedelta(seconds=round(seconds)) \
           - timedelta(days=366)

def rmext(filename):
    file, _ = os.path.splitext(filename)
    return file

def polly_1v2_display_longterm_cali(tmpFile, saveFolder):
    '''
    Description
    -----------
    Display the housekeeping data from laserlogbook file.

    Parameters
    ----------
    - tmpFile: the .mat file which stores the housekeeping data.

    Return
    ------ 

    Usage
    -----
    polly_1v2_display_longterm_cali(tmpFile)

    History
    -------
    2019-01-10. First edition by Zhenping

    Copyright
    ---------
    Ground-based Remote Sensing (TROPOS)
    '''

    if not os.path.exists(tmpFile):
        print('{filename} does not exists.'.format(filename=tmpFile))
        return
    
    # read data
    try:
        mat = spio.loadmat(tmpFile, struct_as_record=True)
        figDPI = mat['figDPI'][0][0]
        thisLCTime = mat['LCTime'][0][:]
        LC532Status = mat['LC532Status'][:]
        LC532History = mat['LC532History'][:]
        thisLogbookTime = mat['logbookTime'][0][:]
        flagOverlap = mat['flagOverlap'][0][:]
        flagWindowwipe = mat['flagWindowwipe'][0][:]
        flagFlashlamps = mat['flagFlashlamps'][0][:]
        flagPulsepower = mat['flagPulsepower'][0][:]
        flagRestart = mat['flagRestart'][0][:]
        flag_CH_NDChange = mat['flag_CH_NDChange'][:]
        flagCH532FR = mat['flagCH532FR'][0][:]
        flagCH532FR_X = mat['flagCH532FR_X'][0][:]
        else_time = mat['else_time'][:]
        else_label = mat['else_label']
        yLim532 = mat['yLim532'][0][:]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        dataTime = mat['taskInfo']['dataTime'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        startTime = mat['campaignInfo']['startTime'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
    except Exception as e:
        print('%s has been destroyed' % (tmpFile))
        return

    # convert matlab datenum tp datetime 
    startTime = datenum_to_datetime(float(startTime[0]))
    dataTime = datenum_to_datetime(float(dataTime[0]))
    LCTime = [datenum_to_datetime(thisTime) for thisTime in thisLCTime]
    logbookTime = [datenum_to_datetime(thisTime) for thisTime in thisLogbookTime]
    elseTime = [datenum_to_datetime(thisElseTime) for thisElseTime in else_time]

    lineColor = {'overlap': '#f48f42', 'windowwipe': '#ff66ff', 'flashlamps': '#993333', 'pulsepower': '#990099', 'restart': '#ffff00', 'NDChange': '#333300', 'else': '#00ff00'}

    # display lidar constants at 355mn
    fig, (ax1) = plt.subplots(1, figsize=(2,18), sharex=True, gridspec_kw={'height_ratios': [1], 'hspace': 0.1})
    plt.subplots_adjust(top=0.96, bottom=0.05, left=0.07, right=0.98)

    # lidar constant at 532 nm
    p1 = ax1.scatter([LCTime[indx] for indx in np.arange(0, len(LCTime)) if LC532Status[indx] == 2], LC532History[LC532Status == 2], s=7, c='#0000ff', marker='o')

    for iLogbookInfo in np.arange(0, len(logbookTime)):
        if flagOverlap[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo], linestyle='--', color=lineColor['overlap'])
        if flagPulsepower[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo], linestyle='--', color=lineColor['pulsepower'])
        if flagWindowwipe[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo], linestyle='--', color=lineColor['windowwipe'])
        if flagRestart[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo], linestyle='--', color=lineColor['restart'])
        if flagFlashlamps[iLogbookInfo]:
            ax1.axvline(x=logbookTime[iLogbookInfo], linestyle='--', color=lineColor['flashlamps'])
        if flag_CH_NDChange[iLogbookInfo, flagCH532FR == 1]:
            ax1.axvline(x=logbookTime[iLogbookInfo], linestyle='--', color=lineColor['NDChange'])
 
    for elseTime in else_time:
        ax1.axvline(x=elseTime, linestyle='--', color=lineColor['else'])      

    ax1.set_ylabel('LC @ 532nm')
    ax1.grid(False)
    ax1.set_ylim(yLim532.tolist())
    ax1.set_xlim([startTime - timedelta(days=2), dataTime + timedelta(days=2)])

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_long_term_cali_results.png'.format(dataFilename=dataTime.strftime('%Y%m%d'))), dpi=figDPI)
    plt.close()

def main():
    polly_1v2_display_longterm_cali('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\polly_1v2\\20181214')

if __name__ == '__main__':
    # main()
    polly_1v2_display_longterm_cali(sys.argv[1], sys.argv[2])