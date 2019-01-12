import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from matplotlib.dates import DateFormatter, DayLocator, HourLocator, MinuteLocator, date2num
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
from matplotlib import use
use('Agg')
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

def pollyxt_fmi_display_depolcali(tmpFile, saveFolder):
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
    pollyxt_fmi_display_depolcali(tmpFile)

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
        sig_t_p = np.transpose(np.concatenate(mat['sig_t_p']))
        sig_t_m = np.transpose(np.concatenate(mat['sig_t_m']))
        sig_x_p = np.transpose(np.concatenate(mat['sig_x_p']))
        sig_x_m = np.transpose(np.concatenate(mat['sig_x_m']))
        wavelength = mat['wavelength'][0][0]
        time = np.concatenate(mat['time'])
        height = np.concatenate(mat['height'])
        caliHIndxRange = np.concatenate(mat['caliHIndxRange'])
        indx_45m = np.concatenate(mat['indx_45m'])
        indx_45p = np.concatenate(mat['indx_45p'])
        dplus = np.transpose(np.concatenate(mat['dplus']))
        dminus = np.transpose(np.concatenate(mat['dminus']))
        segmentLen = np.concatenate(mat['segmentLen'])
        indx = np.concatenate(mat['indx'])
        mean_dplus_tmp = np.concatenate(mat['mean_dplus_tmp'])
        std_dplus_tmp = np.concatenate(mat['std_dplus_tmp'])
        mean_dminus_tmp = np.concatenate(mat['mean_dminus_tmp'])
        std_dminus_tmp = np.concatenate(mat['std_dminus_tmp'])
        TRt = np.concatenate(mat['TR_t'])
        TRx = np.concatenate(mat['TR_x'])
        segIndx = np.concatenate(mat['segIndx'])
        thisCaliTime = np.concatenate(mat['thisCaliTime'])
        pollyVersion = mat['taskInfo']['pollyVersion'][0][0][0]
        location = mat['campaignInfo']['location'][0][0][0]
        version = mat['processInfo']['programVersion'][0][0][0]
    except Exception as e:
        print('%s has been destroyed' % (tmpFile))
        return

    # display
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(8, 8), sharey=True, gridspec_kw={'width_ratios': [1, 1]})

    # display signal
    p1, = ax1.semilogx(sig_t_p, height, color='#E75A17', linestyle='-', label=r'$Sig_{+45^\circ}$')
    p2, = ax1.semilogx(sig_t_m, height, color='#1770E7', linestyle='-', label=r'$Sig_{-45^\circ}$')
    p3, = ax1.semilogx(sig_x_p, height, color='#E75A17', linestyle='--', label=r'$Sig_{+45^\circ}$')
    p4, = ax1.semilogx(sig_x_m, height, color='#1770E7', linestyle='--', label=r'$Sig_{-45^\circ}$')
    ax1.set_ylim([height[caliHIndxRange[0] - 1], height[caliHIndxRange[1] - 1]])
    ax1.set_xlim([1, 1e4])
    ax1.set_ylabel('Height (m)')
    ax1.set_xlabel('Signal (a.u.)')
    ax1.yaxis.set_major_locator(MultipleLocator(200))
    ax1.yaxis.set_minor_locator(MultipleLocator(50))
    start = datenum_to_datetime(time[indx_45p[0] - 1])
    end = datenum_to_datetime(time[indx_45m[-1] + 1])
    fig.text(0.5, 0.98, 'Depolarization Calibration for {wave}nm at {start}-{end}'.format(wave=wavelength, start=start.strftime('%H:%M'), end=end.strftime('%H:%M')), horizontalalignment='center', fontweight='bold', fontsize=14)
    l = ax1.legend(handles=[p1, p2, p3, p4], loc='upper right', fontsize=10)

    p1, = ax2.plot(dplus, height[(caliHIndxRange[0] - 1):(caliHIndxRange[1])], color='#E75A17', label=r'$Ratio_{+45^\circ}$')
    p2, = ax2.plot(dminus, height[(caliHIndxRange[0] - 1):(caliHIndxRange[1])], color='#1770E7', label=r'$Ratio_{-45^\circ}$')
    p3, = ax2.plot([0, 1e10], [height[indx + caliHIndxRange[0] - 2], height[indx + caliHIndxRange[1] - 1]], linestyle='--', color='#000000')
    p4, = ax2.plot([0, 1e10], [height[indx + segmentLen + caliHIndxRange[0] - 2], height[indx + segmentLen + caliHIndxRange[1] - 1]], linestyle='--', color='#000000')
    ax2.set_xlim([0, 50])
    ax2.set_xlabel('Ratio')
    l = ax2.legend(handles=[p1, p2], loc='upper right', fontsize=10)
    ax2.text(0.2, 0.7, '$mean_{dplus}=%5.2f, std_{dplus}=%5.3f$\n$mean_{dminus}=%5.2f, std_{dminus}=%5.3f$\n$K=%6.4f, std_K=%6.4f$' % (mean_dplus_tmp[segIndx - 1], std_dplus_tmp[segIndx - 1], mean_dminus_tmp[segIndx - 1], std_dminus_tmp[segIndx - 1], (1 + TRt)/(1 + TRx)*np.sqrt(mean_dplus_tmp[segIndx-1]*mean_dminus_tmp[segIndx - 1]), (1 + TRt)/(1 + TRx) / np.sqrt(mean_dplus_tmp[segIndx - 1] * mean_dminus_tmp[segIndx - 1]) * 0.5 * (mean_dplus_tmp[segIndx - 1] * std_dminus_tmp[segIndx - 1] + mean_dminus_tmp[segIndx - 1] * std_dplus_tmp[segIndx - 1])), fontsize=9, transform=ax2.transAxes)

    fig.text(0.9, - 0.1, '{location}\n{instrument}\nVersion {version}'.format(location=location, instrument=pollyVersion, version=version), fontweight='bold', fontsize=10)

    plt.tight_layout()
    caliTime = datenum_to_datetime(thisCaliTime[0])
    plt.savefig(os.path.join(saveFolder, '{start}_DepolCali_{wave}.png'.format(start=caliTime.strftime('%Y%m%d-%H%M'), wave=wavelength)), dpi=150)
    plt.close()
 
def main():
    pollyxt_fmi_display_depolcali('C:\\Users\\zhenping\\Desktop\\Picasso\\tmp\\tmp.mat', 'C:\\Users\\zhenping\\Desktop\\Picasso\\recent_plots\\POLLYXT_FMI\\20180517')

if __name__ == '__main__':
    # main()
    pollyxt_fmi_display_depolcali(sys.argv[1], sys.argv[2])