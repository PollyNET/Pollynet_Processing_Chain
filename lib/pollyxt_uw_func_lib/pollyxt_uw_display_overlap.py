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

def parse_polly_filename(pollyFile):
    import re

    psFmt = r"^(\d{4})_(\d{2})_(\d{2}).*_(\d{2})_(\d{2})_(\d{2}).*"
    items = re.search(psFmt, pollyFile)

    return datetime(int(items[1]), int(items[2]), int(items[3]), int(items[4]), int(items[5]), int(items[6]))

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

def pollyxt_uw_display_depolcali(tmpFile, saveFolder):
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
    pollyxt_uw_display_depolcali(tmpFile)

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
        overlap355 = np.concatenate(mat['overlap355'])
        overlap532 = np.concatenate(mat['overlap532'])
        overlap355Defaults = np.concatenate(mat['overlap355Defaults'])
        overlap532Defaults = np.concatenate(mat['overlap532Defaults'])
        sig355FR = np.concatenate(mat['sig355FR'])
        sig355NR = np.concatenate(mat['sig355NR'])
        sig532FR = np.concatenate(mat['sig532FR'])
        sig532NR = np.concatenate(mat['sig532NR'])
        sig355Gl = np.concatenate(mat['sig355Gl'])
        sig532Gl = np.concatenate(mat['sig532Gl'])
        sigRatio355 = np.concatenate(mat['sigRatio355'])
        sigRatio532 = np.concatenate(mat['sigRatio532'])
        normRange355 = np.concatenate(mat['normRange355'])
        normRange532 = np.concatenate(mat['normRange532'])
        height = np.concatenate(mat['height'])
        pollyVersion = mat['taskInfo']['pollyVersion'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
        dataFilename = mat['taskInfo']['dataFilename'][0][0][0]
    except Exception as e:
        print('%s has been destroyed' % (tmpFile))
        return

    # display
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(8, 8), sharey=True, gridspec_kw={'width_ratios': [1, 1]})

    # display signal
    p1, = ax1.plot(overlap355, height, color='#1544E9', linestyle='-', label=r'overlap 355 FR')
    p2, = ax1.plot(overlap532, height, color='#58B13F', linestyle='-', label=r'overlap 532 FR')
    p3, = ax1.plot(overlap355Defaults, height, color='#1544E9', linestyle='--', label=r'default overlap 355 FR')
    p4, = ax1.plot(overlap532Defaults, height, color='#58B13F', linestyle='--', label=r'default overlap 532 FR')
    ax1.set_ylim([0, 3000])
    ax1.set_xlim([-0.05, 1.1])
    ax1.set_ylabel('Height (m)', fontweight='semibold', fontsize=12)
    ax1.set_xlabel('Overlap', fontweight='semibold', fontsize=12)
    ax1.grid(True)
    ax1.yaxis.set_major_locator(MultipleLocator(500))
    ax1.yaxis.set_minor_locator(MultipleLocator(100))
    start = parse_polly_filename(dataFilename)
    fig.text(0.5, 0.98, 'Overlap for {instrument} at {location}, {time}'.format(instrument=pollyVersion, location=location, time=start.strftime('%Y%m%d %H:%M')), horizontalalignment='center', fontweight='bold', fontsize=14)
    l = ax1.legend(handles=[p1, p2, p3, p4], loc='upper left', fontsize=10)

    sig355FR = np.ma.masked_where(sig355FR <= 0, sig355FR)
    sig355NR = np.ma.masked_where(sig355NR <= 0, sig355NR)
    sig355Gl = np.ma.masked_where(sig355Gl <= 0, sig355Gl)
    sig532FR = np.ma.masked_where(sig532FR <= 0, sig532FR)
    sig532NR = np.ma.masked_where(sig532NR <= 0, sig532NR)
    sig532Gl = np.ma.masked_where(sig532Gl <= 0, sig532Gl)
    p1, = ax2.semilogx(sig355FR, height, color='#1544E9', linestyle='-.', label=r'FR 355')
    p2, = ax2.semilogx(sig355NR, height, color='#1544E9', linestyle=':', label=r'NR 355')
    p3, = ax2.semilogx(sig355Gl, height, color='#1544E9', linestyle='-', label=r'FR Glued 355')
    p4, = ax2.semilogx(sig532FR, height, color='#58B13F', linestyle='-.', label=r'FR 532')
    p5, = ax2.semilogx(sig532NR, height, color='#58B13F', linestyle=':', label=r'NR 532')
    p6, = ax2.semilogx(sig532Gl, height, color='#58B13F', linestyle='-', label=r'FR Glued 532')

    if normRange355.size != 0:
        ax2.plot([1e-10, 1e10], [height[normRange355[0] - 1], height[normRange355[0] - 1]], linestyle='--', color='#1544E9')
        ax2.plot([1e-10, 1e10], [height[normRange355[-1] - 1], height[normRange355[-1] - 1]], linestyle='--', color='#1544E9')
    if normRange532.size != 0:
        ax2.plot([1e-10, 1e10], [height[normRange532[0] - 1], height[normRange532[0] - 1]], linestyle='--', color='#58B13F')
        ax2.plot([1e-10, 1e10], [height[normRange532[-1] - 1], height[normRange532[-1] - 1]], linestyle='--', color='#58B13F')
    
    ax2.set_xlim([1e-2, 1e3])
    ax2.set_xlabel('Signal [MHz]', fontweight='semibold', fontsize=12)
    ax2.grid(True)
    l = ax2.legend(handles=[p1, p2, p3, p4, p5, p6], loc='upper right', fontsize=10)

    fig.text(0.85, 0.02, 'Version {version}'.format(version=version), fontsize=10)

    fig.tight_layout()
    fig.savefig(os.path.join(saveFolder, '{dataFilename}_overlap.png'.format(dataFilename=rmext(dataFilename))), dpi=150)
    plt.close()
 
    plt.close()

def main():
    pollyxt_uw_display_depolcali('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\POLLYXT_UW\\20180517')

if __name__ == '__main__':
    # main()
    pollyxt_uw_display_depolcali(sys.argv[1], sys.argv[2])