import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, LogNorm
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
from matplotlib.dates import DateFormatter, \
                             DayLocator, HourLocator, MinuteLocator, date2num
#import matplotlib.dates as dates
import os
import re
import sys
import time
import scipy.io as spio
import numpy as np
import json
from datetime import datetime, timedelta
import matplotlib
import pandas as pd
import argparse
import statistics
from pathlib import Path
from statistics import mode
import pypolly_readout as readout
import pypolly_readout_profiles as readout_profiles
import pypolly_display_profiles as display_profiles
import pypolly_display_ATT_BETA as display_ATT
import pypolly_display_VDR as display_VDR
import pypolly_display_WV as display_WV
import pypolly_display_quasi_results as display_QR
import pypolly_display_target_classification as display_TC
import pypolly_display_overlap as display_OL
import pypolly_profile_translator as p_translator

# load colormap
dirname = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
print(dirname)
sys.path.append(dirname)
try:
    from python_colormap import *
except Exception as e:
    raise ImportError('python_colormap module is necessary.')

# generating figure without X server
plt.switch_backend('Agg')

my_parser = argparse.ArgumentParser(description='Plotting all diagrams from level1-nc-file.')

## Add the arguments
my_parser.add_argument('--date', dest='timestamp', metavar='timestamp',
                       type=str,
                       help='the date of measurement (level1 nc-file): YYYYMMDD.')
my_parser.add_argument('--device', dest='device', metavar='device',
                       type=str,
                       help='the polly device (level1 nc-file).')
#my_parser.add_argument('--display_config_file', dest='display_config_file', metavar='config_file',
#                       default="./config/display_config.json",
#                       type=str,
#                       help='the json-type config-file')
my_parser.add_argument('--picasso_config_file', dest='picasso_config_file', metavar='picasso_config_file',
#                       default="./config/display_config.json",
                       type=str,
                       help='the json-type picasso config-file')
my_parser.add_argument('--polly_config_file', dest='polly_config_file', metavar='polly_config_file',
                       type=str,
                       help='the json-type polly-config-file for the specific device at specific time, originally grepped from the xlsx-file. if this parameter is set, no grep from xlsx file will be performed.')
my_parser.add_argument('--outdir', dest='outdir', metavar='outputdir',
                       default="none",
                       type=str,
                       help='the output folder to put the png files to.')
my_parser.add_argument('--retrieval', dest='retrieval', metavar='retrieval parameter',
                       default=['all'],
                       choices=['all','attbsc','voldepol','target_class','wvmr_rh','quasi_results','profiles','overlap'],
                       nargs='+',
                       type=str,
                       help='the retrievals to be plotted; default: "all".')

# init parser
args = my_parser.parse_args()

def read_excel_config_file(excel_file, timestamp, device):
    excel_file_ds = pd.read_excel(f'{excel_file}', engine='openpyxl')
    print(excel_file)
    ## search for timerange for given timestamp
    after_start_date = excel_file_ds['Starttime of config'] <= timestamp
    before_end_date = excel_file_ds['Stoptime of config'] >= timestamp
    between_two_dates = after_start_date & before_end_date
    filtered_result = excel_file_ds.loc[between_two_dates]
#    print(filtered_result)
    ## get config-file for timeperiod and instrument
#    config_array = excel_file_ds.loc[(excel_file_ds['Instrument'] == 'arielle') & (excel_file_ds['Starttime of config'] == '20200204 00:00:00')]
    config_array = filtered_result.loc[(filtered_result['Instrument'] == device)]
    polly_local_config_file = str(config_array['Config file'].to_string(index=False)).strip() ## get rid of whtiespaces
#    print(polly_local_config_file)
    return polly_local_config_file

def display_config(display_configfile):
    disp = open (display_configfile, "r")
    #display_config_json = json.loads(disp.read())
    display_config_json = json.load(disp)
    configfile = display_config_json['polly_config']
    polly_global_config = display_config_json['polly_global_config']
    polly_local_config = display_config_json['polly_local_config']
    disp.close()
    return configfile, polly_global_config, polly_local_config

def read_config(configfile):
    print(configfile)
    f = open (configfile, "r")
    config_json = json.load(f)
    configfile_dict={}
    f.close()
    return config_json#configfile_dict

def read_global_conf(polly_global_config):
    print(polly_global_config)
    f = open (polly_global_config, "r")
    config_json = json.load(f)
    f.close()
    return config_json#globalconfig_dict

def read_local_conf(polly_local_config):
    print(polly_local_config)
    f = open (polly_local_config, "r")
    config_json = json.load(f)
    f.close()
    return config_json


def main():

    ## measure computing time
    t0 = time.process_time()

#    display_configfile = args.display_config_file
    picasso_config_file = args.picasso_config_file
    config_dict = read_config(picasso_config_file)
    excel_config_file = config_dict['pollynet_config_link_file']
    polly_config_folder = config_dict['polly_config_folder']
    if args.polly_config_file:
        polly_local_config = args.polly_config_file
    else:
        polly_local_config = read_excel_config_file(excel_config_file, timestamp=args.timestamp, device=args.device)

    #polly_local_config = f'{polly_config_folder}/{polly_local_config}'
    polly_local_config = Path(polly_config_folder,polly_local_config)

    pollyglobal = config_dict['polly_global_config']
    
    
    globalconf_dict = read_global_conf(pollyglobal)
    localconf_dict = read_local_conf(polly_local_config)
    polly_conf_dict = globalconf_dict.copy()

    ## use local polly config settings, instead of global ones:
    for key in globalconf_dict:
        if key in localconf_dict:
            polly_conf_dict[key] = localconf_dict[key]


    date = args.timestamp
    device = args.device

### be careful to choose correct input/output folders !!!
    inputfolder = config_dict['results_folder']
    outputfolder = args.outdir
    if outputfolder == 'none':
        outputfolder = '.'
    else:
        YYYY = date[0:4]
        MM = date[4:6]
        DD = date[6:8]
#        outputfolder = f"{args.outdir}/{device}/{YYYY}/{MM}/{DD}"
        outputfolder = Path(args.outdir,device,YYYY,MM,DD)
        #creating a new directory if not existing
        Path(outputfolder).mkdir(parents=True, exist_ok=True)
        #outputfolder = config_dict['pic_folder']
### be careful to choose correct input/output folders !!!

    print('retrievals to plot: '+ str(args.retrieval))

    if ('all' in args.retrieval) or ('cloudinfo' in args.retrieval):
        ## plotting ATT_BETA_FR plots + cloudinfo
        try:
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='att_bsc')
            for data_file in nc_files:
                nc_dict = readout.read_nc_file(data_file)
                print('plotting ATT_BETA_1064nm + cloudinfo:')
                display_ATT.pollyDisplayATT_BSC_cloudinfo(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=1064)
        except Exception as e:
             print("An error occurred:", e)

    if ('all' in args.retrieval) or ('attbsc' in args.retrieval):
        ## plotting ATT_BETA_FR plots
        try:
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='att_bsc')
            for data_file in nc_files:
    #            nc_dict = readout.read_nc_att(data_file)
                nc_dict = readout.read_nc_file(data_file)
                print('plotting ATT_BETA_355nm:')
                display_ATT.pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=355, param='FR')
                print('plotting ATT_BETA_532nm:')
                display_ATT.pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=532, param='FR')
                print('plotting ATT_BETA_1064nm:')
                display_ATT.pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=1064, param='FR')
        except Exception as e:
             print("An error occurred:", e)
    
        ## plotting ATT_BETA_NR plots
        try:
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='NR_att_bsc')
            for data_file in nc_files:
    #            nc_dict = readout.read_nc_NR_att(data_file)
                nc_dict = readout.read_nc_file(data_file)
                print('plotting ATT_BETA_NR_355nm:')
                display_ATT.pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=355, param='NR')
                print('plotting ATT_BETA_NR_532nm:')
                display_ATT.pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=532, param='NR')
        except Exception as e:
             print("An error occurred:", e)
    
        ## plotting ATT_BETA_OC plots
        try:
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='OC_att_bsc')
            for data_file in nc_files:
    #            nc_dict = readout.read_nc_OC_att(data_file)
                nc_dict = readout.read_nc_file(data_file)
                print('plotting ATT_BETA_OC_355nm:')
                display_ATT.pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=355, param='OC')
                print('plotting ATT_BETA_OC_532nm:')
                display_ATT.pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=532, param='OC')
                print('plotting ATT_BETA_OC_1064nm:')
                display_ATT.pollyDisplayAttnBsc_new(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=1064, param='OC')
        except Exception as e:
             print("An error occurred:", e)

    if ('all' in args.retrieval) or ('voldepol' in args.retrieval):
    ## plotting VolDepol plots
        try:
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='vol_depol')
            for data_file in nc_files:
                nc_dict = readout.read_nc_VDR(data_file)
                print('plotting VDR_355nm:')
                display_VDR.pollyDisplayVDR(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=355)
                print('plotting VDR_532nm:')
                display_VDR.pollyDisplayVDR(nc_dict, config_dict, polly_conf_dict, outputfolder, wavelength=532)
        except Exception as e:
             print("An error occurred:", e)
    
    if ('all' in args.retrieval) or ('wvmr_rh' in args.retrieval):
    ## plotting WVMR_RH plots
        try:
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='WVMR_RH')
            for data_file in nc_files:
                nc_dict = readout.read_nc_WVMR_RH(data_file)
                print('plotting WVMR:')
                display_WV.pollyDisplayWVMR(nc_dict, config_dict, polly_conf_dict, outputfolder)
                print('plotting RH:')
                display_WV.pollyDisplayRH(nc_dict, config_dict, polly_conf_dict, outputfolder)
        except Exception as e:
             print("An error occurred:", e)

    if ('all' in args.retrieval) or ('target_class' in args.retrieval):
    ## plotting Target classification V1 
        try:
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='target_classification')
            for data_file in nc_files:
                nc_dict = readout.read_nc_target_classification(data_file)
                print('plotting Target classification V1:')
                display_TC.pollyDisplayTargetClass(nc_dict, config_dict, polly_conf_dict, outputfolder,c_version='V1')
        except Exception as e:
             print("An error occurred:", e)
    
    ## plotting Target classification V2 
        try:
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='target_classification_V2')
            for data_file in nc_files:
                nc_dict = readout.read_nc_target_classification(data_file)
                print('plotting Target classification V2:')
                display_TC.pollyDisplayTargetClass(nc_dict, config_dict, polly_conf_dict, outputfolder,c_version='V2')
        except Exception as e:
             print("An error occurred:", e)
    
    if ('all' in args.retrieval) or ('quasi_results' in args.retrieval):
    ## plotting Quasi results V1
        try:
            q_params_ls = ["angexp", "bsc_532", "bsc_1064", "par_depol_532"] 
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='quasi_results')
            for data_file in nc_files:
                nc_dict = readout.read_nc_quasi_results(data_file,q_version='V1')
    #            print('plotting Quasi results AngExp V1:')
                for qp in q_params_ls:
                    display_QR.pollyDisplayQR(nc_dict, config_dict, polly_conf_dict, outputfolder,q_param=qp, q_version='V1')
        except Exception as e:
             print("An error occurred:", e)
    
    ## plotting Quasi results V2
        try: 
            nc_files = readout.get_nc_filename(date, device, inputfolder, param='quasi_results_V2')
            for data_file in nc_files:
                nc_dict = readout.read_nc_quasi_results(data_file,q_version='V2')
    #            print('plotting Quasi results AngExp V2:')
                for qp in q_params_ls:
                    display_QR.pollyDisplayQR(nc_dict, config_dict, polly_conf_dict, outputfolder, q_param=qp, q_version='V2')
        except Exception as e:
             print("An error occurred:", e)
    
    
    if ('all' in args.retrieval) or ('profiles' in args.retrieval):
        ## plotting profiles
        ## using profile_translator

        profile_translator = p_translator.profile_translator_function()
        NR_profile_translator = p_translator.NR_profile_translator_function()
        OC_profile_translator = p_translator.OC_profile_translator_function()
        POLIPHON_profile_translator = p_translator.POLIPHON_profile_translator_function()

        try:
            nc_profiles = readout.get_nc_filename(date, device, inputfolder, param='profiles')
            nc_profiles_NR = readout.get_nc_filename(date, device, inputfolder, param='NR_profiles')
            nc_profiles_OC = readout.get_nc_filename(date, device, inputfolder, param='OC_profiles')
            nc_profiles_POLIPHON = readout.get_nc_filename(date, device, inputfolder, param='POLIPHON')
            print(f'plotting profiles to {outputfolder}')
            for profile in nc_profiles:
                nc_dict_profile = readout.read_nc_file(profile)
                starttime=datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%H:%M')
                endtime=datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%H:%M')
                print(f"profile: {starttime} - {endtime}")
                for profilename in profile_translator.keys():
                    print(f"{profilename}")
                    display_profiles.pollyDisplay_profile(nc_dict_profile,profile_translator,profilename,config_dict,polly_conf_dict,outputfolder)
            for NR_profile in nc_profiles_NR:
                nc_dict_profile_NR = readout.read_nc_file(NR_profile)
                starttime=datetime.utcfromtimestamp(int(nc_dict_profile_NR['start_time'])).strftime('%H:%M')
                endtime=datetime.utcfromtimestamp(int(nc_dict_profile_NR['end_time'])).strftime('%H:%M')
                print(f"NR-profile: {starttime} - {endtime}")
                for profilename in NR_profile_translator.keys():
                    print(f"{profilename}")
                    display_profiles.pollyDisplay_profile(nc_dict_profile_NR,NR_profile_translator,profilename,config_dict,polly_conf_dict,outputfolder)
            for OC_profile in nc_profiles_OC:
                nc_dict_profile_OC = readout.read_nc_file(OC_profile)
                starttime=datetime.utcfromtimestamp(int(nc_dict_profile_OC['start_time'])).strftime('%H:%M')
                endtime=datetime.utcfromtimestamp(int(nc_dict_profile_OC['end_time'])).strftime('%H:%M')
                print(f"OC-profile: {starttime} - {endtime}")
                for profilename in OC_profile_translator.keys():
                    print(f"{profilename}")
                    display_profiles.pollyDisplay_profile(nc_dict_profile_OC,OC_profile_translator,profilename,config_dict,polly_conf_dict,outputfolder)
            for POLIPHON in nc_profiles_POLIPHON:
                nc_dict_profile_POLI = readout.read_nc_file(POLIPHON)
                starttime=datetime.utcfromtimestamp(int(nc_dict_profile_POLI['start_time'])).strftime('%H:%M')
                endtime=datetime.utcfromtimestamp(int(nc_dict_profile_POLI['end_time'])).strftime('%H:%M')
                print(f"POLIPHON-profile: {starttime} - {endtime}")
                for profilename in POLIPHON_profile_translator.keys():
                    print(f"{profilename}")
                    display_profiles.pollyDisplay_profile(nc_dict_profile_POLI,POLIPHON_profile_translator,profilename,config_dict,polly_conf_dict,outputfolder)
        except Exception as e:
             print("An error occurred:", e)

    
    if ('all' in args.retrieval) or ('overlap' in args.retrieval):
        ## plotting overlap 
        nc_files = readout.get_nc_filename(date, device, inputfolder, param='overlap')
        for data_file in nc_files:
            nc_dict = readout.read_nc_overlap(data_file)
            print('plotting overlap:')
            display_OL.pollyDisplay_Overlap(nc_dict, config_dict, polly_conf_dict, outputfolder)


    ## measure computing time
    elapsed_time = time.process_time() - t0
#    print(elapsed_time)
    print('finished plotting!')
if __name__ == '__main__':
    main()

