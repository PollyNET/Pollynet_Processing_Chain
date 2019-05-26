import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.dates import DateFormatter, DayLocator, HourLocator, MinuteLocator, date2num
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
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

def polly_1v2_display_retrieving(tmpFile, saveFolder):
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
    polly_1v2_display_retrieving(tmpFile)

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
        startIndx = mat['startIndx'][:][0][0]
        endIndx = mat['endIndx'][:][0][0]
        rcs532 = mat['rcs532'][:][0]
        height = mat['height'][:][0]
        time = mat['time'][:][0]
        molRCS532 = mat['molRCS532'][:][0]
        refHIndx532 = mat['refHIndx532'][:][0]
        aerBsc_532_klett = mat['aerBsc_532_klett'][:][0]
        aerBsc_532_raman = mat['aerBsc_532_raman'][:][0]
        aerBsc_532_RR = mat['aerBsc_532_RR'][:][0]
        aerExt_532_klett = mat['aerExt_532_klett'][:][0]
        aerExt_532_raman = mat['aerExt_532_raman'][:][0]
        aerExt_532_RR = mat['aerExt_532_RR'][:][0]
        LR532_raman = mat['LR532_raman'][:][0]
        LR532_RR = mat['LR532_RR'][:][0]
        voldepol532_klett = mat['voldepol532_klett'][:][0]
        voldepol532_raman = mat['voldepol532_raman'][:][0]
        pardepol532_klett = mat['pardepol532_klett'][:][0]
        pardepolStd532_klett = mat['pardepolStd532_klett'][:][0]
        pardepol532_raman = mat['pardepol532_raman'][:][0]
        pardepolStd532_raman = mat['pardepolStd532_raman'][:][0]
        meteorSource = mat['meteorSource'][:][0]
        temperature = mat['temperature'][:][0]
        pressure = mat['pressure'][:][0]
        pollyVersion = mat['campaignInfo']['name'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
        rcsLim = mat['rcsLim'][:][0]
        aerBscLim = mat['aerBscLim'][:][0]
        aerExtLim = mat['aerExtLim'][:][0]
        aerLRLim = mat['aerLRLim'][:][0]

    except Exception as e:
        print('%s has been destroyed' % (tmpFile))
        return

    # display signal
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.semilogx(rcs532 / 1e6, height, color='#80ff00', linestyle='-', label='FR 532 nm', zorder=2)
    p2, = ax.semilogx(molRCS532 / 1e6, height, color='#00b300', linestyle='--', label='mol 532 nm', zorder=5)

    p3, = ax.plot([1], [1], color='#000000', linestyle='-', label='Reference Height')
    if not np.isnan(refHIndx532[0]):
        ax.semilogx(rcs532[refHIndx532[0]:refHIndx532[1]] / 1e6, height[refHIndx532[0]:refHIndx532[1]], color='#000000', zorder=8)

    ax.set_xlabel('Range-Corrected Signal [$MHz*m^2 (10^6)$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1, p2, p3], loc='upper right', fontsize=10)

    ax.set_ylim([0, 15000])
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim(rcsLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.05, 0.04, 'Version: {version}'.format(version=version), fontsize=12)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_SIG.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display backscatter with klett method
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(aerBsc_532_klett * 1e6, height, color='#00b300', linestyle='-', label='532 nm', zorder=2)

    ax.set_xlabel('Backscatter Coefficient [$Mm^{-1}*Sr^{-1}$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1], loc='upper right', fontsize=10)

    ax.set_ylim([0, 15000])
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim(aerBscLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='Klett'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_Bsc_Klett.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display backscatter with raman method
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(aerBsc_532_raman * 1e6, height, color='#00b300', linestyle='-', label='532 nm', zorder=2)

    ax.set_xlabel('Backscatter Coefficient [$Mm^{-1}*Sr^{-1}$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1], loc='upper right', fontsize=10)

    ax.set_ylim([0, 15000])
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim(aerBscLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='Raman'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_Bsc_Raman.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display backscatter with raman method (RR signal)
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(aerBsc_532_RR * 1e6, height, color='#00b300', linestyle='-', label='532 nm', zorder=2)

    ax.set_xlabel('Backscatter Coefficient [$Mm^{-1}*Sr^{-1}$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1], loc='upper right', fontsize=10)

    ax.set_ylim([0, 15000])
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim(aerBscLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='RR'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_Bsc_RR.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display extinction with klett method
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(aerExt_532_klett * 1e6, height, color='#00b300', linestyle='-', label='532 nm', zorder=2)

    ax.set_xlabel('Extinction Coefficient [$Mm^{-1}$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1], loc='upper right', fontsize=10)

    ax.set_ylim([0, 5000])
    ax.yaxis.set_major_locator(MultipleLocator(1000))
    ax.yaxis.set_minor_locator(MultipleLocator(200))
    ax.set_xlim(aerExtLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='Klett'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_Ext_Klett.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display extinction with raman method
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(aerExt_532_raman * 1e6, height, color='#00b300', linestyle='-', label='532 nm', zorder=2)

    ax.set_xlabel('Extinction Coefficient [$Mm^{-1}$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1], loc='upper right', fontsize=10)

    ax.set_ylim([0, 5000])
    ax.yaxis.set_major_locator(MultipleLocator(1000))
    ax.set_xlim(aerExtLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='Raman'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_Ext_Raman.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display extinction with raman method (RR signal)
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(aerExt_532_RR * 1e6, height, color='#00b300', linestyle='-', label='532 nm', zorder=2)

    ax.set_xlabel('Extinction Coefficient [$Mm^{-1}$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1], loc='upper right', fontsize=10)

    ax.set_ylim([0, 5000])
    ax.set_xlim(aerExtLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='RR'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_Ext_RR.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display LR with raman method
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(LR532_raman, height, color='#00b300', linestyle='-', label='532 nm', zorder=2)

    ax.set_xlabel('Lidar Ratio [$Sr$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1], loc='upper right', fontsize=10)

    ax.set_ylim([0, 5000])
    ax.yaxis.set_major_locator(MultipleLocator(1000))
    ax.yaxis.set_minor_locator(MultipleLocator(200))
    ax.set_xlim(aerLRLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='Raman'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_LR_Raman.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display LR with raman method (RR signal)
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(LR532_RR, height, color='#00b300', linestyle='-', label='532 nm', zorder=2)

    ax.set_xlabel('Lidar Ratio [$Sr$]', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1], loc='upper right', fontsize=10)

    ax.set_ylim([0, 5000])
    ax.yaxis.set_major_locator(MultipleLocator(1000))
    ax.yaxis.set_minor_locator(MultipleLocator(200))
    ax.set_xlim(aerLRLim.tolist())
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='RR'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_LR_RR.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display depol ratio with klett method
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(voldepol532_klett, height, color='#80ff00', linestyle='-', label='$\delta_{vol, 532}$', zorder=2)
    p2, = ax.plot(pardepol532_klett, height, color='#008040', linestyle='--', label='$\delta_{par, 532}$', zorder=3)

    ax.set_xlabel('Depolarization Ratio', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1, p2], loc='upper right', fontsize=10)

    ax.set_ylim([0, 15000])
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim([-0.01, 0.4])
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='Klett'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_DepRatio_Klett.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display depol ratio with raman method
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(voldepol532_raman, height, color='#80ff00', linestyle='-', label='$\delta_{vol, 532}$', zorder=2)
    p2, = ax.plot(pardepol532_raman, height, color='#008040', linestyle='--', label='$\delta_{par, 532}$', zorder=3)

    ax.set_xlabel('Depolarization Ratio', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    l = ax.legend(handles=[p1, p2], loc='upper right', fontsize=10)

    ax.set_ylim([0, 15000])
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim([-0.01, 0.4])
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('{instrument} at {location}\n[Averaged] {starttime}-{endtime}'.format(instrument=pollyVersion, location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nMethod: {method}'.format(version=version, method='Raman'), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_DepRatio_Raman.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display meteorological paramters
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(temperature, height, color='#ff0000', linestyle='-', zorder=2)

    ax.set_xlabel('Temperature ($^\circ C$)', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)

    ax.set_ylim([0, 15000])
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim([-100, 50])
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('Meteorological Parameters at {location}\n {starttime}-{endtime}'.format(location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nFrom: {source}'.format(version=version, source=meteorSource), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_Meteor_T.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

    # display meteorological paramters
    fig = plt.figure(figsize=[4.5, 8])
    ax = fig.add_axes([0.20, 0.15, 0.75, 0.75])
    p1, = ax.plot(pressure, height, color='#ff0000', linestyle='-', zorder=2)

    ax.set_xlabel('Pressure ($hPa$)', fontweight='semibold', fontsize=12)
    ax.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)

    ax.set_ylim([0, 15000])
    ax.yaxis.set_major_locator(MultipleLocator(2500))
    ax.yaxis.set_minor_locator(MultipleLocator(500))
    ax.set_xlim([0, 1000])
    ax.grid(True)

    starttime = time[startIndx - 1]
    endtime = time[endIndx - 1]
    ax.set_title('Meteorological Parameters at {location}\n {starttime}-{endtime}'.format(location=location, starttime=datenum_to_datetime(starttime).strftime('%Y%m%d %H:%M'), endtime=datenum_to_datetime(endtime).strftime('%H:%M')), fontweight='bold', fontsize=12)

    fig.text(0.7, 0.03, 'Version: {version}\nFrom: {source}'.format(version=version, source=meteorSource), fontsize=10)

    fig.savefig(os.path.join(saveFolder, '{dataFilename}_{starttime}_{endtime}_Meteor_P.png'.format(dataFilename=rmext(dataFilename), starttime=datenum_to_datetime(starttime).strftime('%H%M'), endtime=datenum_to_datetime(endtime).strftime('%H%M'))), dpi=figDPI)
    plt.close()

def main():
    polly_1v2_display_retrieving('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\POLLY_1V2\\20180517')

if __name__ == '__main__':
    # main()
    polly_1v2_display_retrieving(sys.argv[1], sys.argv[2])