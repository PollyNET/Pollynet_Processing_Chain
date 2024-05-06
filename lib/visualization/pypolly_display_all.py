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
import pypolly_readout as readout
import pypolly_readout_profiles as readout_profiles
import pypolly_display_profiles as display_profiles
import pypolly_display_ATT_BETA as display_ATT
import pypolly_display_VDR as display_VDR
import pypolly_display_WV as display_WV
import pypolly_display_quasi_results as display_QR
import pypolly_display_target_classification as display_TC
import pypolly_display_overlap as display_OL
import statistics
from pathlib import Path
from statistics import mode

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
                       choices=['all','attbsc','voldepol','target_class','wvmr_rh','quasi_results','profiles','NR_profiles','OC_profiles','overlap'],
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
    
    
    if 'profiles' in args.retrieval:
        ## plotting profiles
        ## profile_translator
        profile_translator = {}
        profilename_ls = ['Bsc_Klett','Bsc_Raman','Bsc_RR','DepRatio_Klett','DepRatio_Raman','Ext_Raman','Ext_RR','LR_Raman','LR_RR','WVMR','RH','Meteor_T','Meteor_P']
#        profile_dict_key_ls = ['method','misc', 'var_name_ls','var_err_name_ls','scaling_factor','xlim_name','ylim_name','x_label','plot_filename']

        profile_dict_value = {}
#        profile_dict_value['WVMR'] = [['WVMR'], 'WVMR', 'WVMR_rel_error', 'xLim_Profi_WVMR', 'yLim_Profi_WV_RH', 'Water Vapor Mixing Ratio [$g*kg^{-1}$]', 'WVMR']
#        profile_dict_value['aerBsc_klett_355'] = ['aerBsc_klett_355', 'uncertainty_aerBsc_klett_355','xLim_Profi_Bsc','yLim_Profi_Bsc','Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]','Bsc_Klett']
#        profile_dict_value['aerBsc_klett_1064'] = ['aerBsc_klett_1064', 'uncertainty_aerBsc_klett_1064','xLim_Profi_Bsc','yLim_Profi_Bsc','Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]','Bsc_Klett']

        for profilename in profilename_ls:
            profile_translator[profilename] = {}
            #for n,key in enumerate(profile_dict_key_ls):
            #    profile_translator[profilename][key] = profile_dict_value[profilename][n]

        ## Bsc_Klett
        profile_translator['Bsc_Klett']['method'] = 'Klett'
        profile_translator['Bsc_Klett']['misc'] = ''
        profile_translator['Bsc_Klett']['var_name_ls'] = ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064']                        
        profile_translator['Bsc_Klett']['var_err_name_ls'] = ['uncertainty_aerBsc_klett_355','uncertainty_aerBsc_klett_532','uncertainty_aerBsc_klett_1064']
        profile_translator['Bsc_Klett']['var_color_ls'] = ['blue','green','red']
        profile_translator['Bsc_Klett']['var_style_ls'] = ['-','-','-']
        profile_translator['Bsc_Klett']['scaling_factor'] = 10**6
        profile_translator['Bsc_Klett']['xlim_name'] = 'xLim_Profi_Bsc'
        profile_translator['Bsc_Klett']['ylim_name'] = 'yLim_Profi_Bsc'
        profile_translator['Bsc_Klett']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
        profile_translator['Bsc_Klett']['plot_filename'] = 'Bsc_Klett'

        ## Bsc_Raman
        profile_translator['Bsc_Raman']['method'] = 'Raman'
        profile_translator['Bsc_Raman']['misc'] = ''
        profile_translator['Bsc_Raman']['var_name_ls'] = ['aerBsc_raman_355','aerBsc_raman_532','aerBsc_raman_1064']                        
        profile_translator['Bsc_Raman']['var_err_name_ls'] = ['uncertainty_aerBsc_raman_355','uncertainty_aerBsc_raman_532','uncertainty_aerBsc_raman_1064']
        profile_translator['Bsc_Raman']['var_color_ls'] = ['blue','green','red']
        profile_translator['Bsc_Raman']['var_style_ls'] = ['-','-','-']
        profile_translator['Bsc_Raman']['scaling_factor'] = 10**6
        profile_translator['Bsc_Raman']['xlim_name'] = 'xLim_Profi_Bsc'
        profile_translator['Bsc_Raman']['ylim_name'] = 'yLim_Profi_Bsc'
        profile_translator['Bsc_Raman']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
        profile_translator['Bsc_Raman']['plot_filename'] = 'Bsc_Raman'

        ## Bsc_RR
        profile_translator['Bsc_RR']['method'] = 'RR'
        profile_translator['Bsc_RR']['misc'] = ''
        profile_translator['Bsc_RR']['var_name_ls'] = ['aerBsc_RR_355','aerBsc_RR_532','aerBsc_RR_1064']                        
        profile_translator['Bsc_RR']['var_err_name_ls'] = ['uncertainty_aerBsc_RR_355','uncertainty_aerBsc_RR_532','uncertainty_aerBsc_RR_1064']
        profile_translator['Bsc_RR']['var_color_ls'] = ['blue','green','red']
        profile_translator['Bsc_RR']['var_style_ls'] = ['-','-','-']
        profile_translator['Bsc_RR']['scaling_factor'] = 10**6
        profile_translator['Bsc_RR']['xlim_name'] = 'xLim_Profi_Bsc'
        profile_translator['Bsc_RR']['ylim_name'] = 'yLim_Profi_Bsc'
        profile_translator['Bsc_RR']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
        profile_translator['Bsc_RR']['plot_filename'] = 'Bsc_RR'

        ## DepRatio_Klett
        profile_translator['DepRatio_Klett']['method'] = 'Klett'
        profile_translator['DepRatio_Klett']['misc'] = ''
        profile_translator['DepRatio_Klett']['var_name_ls'] = ['volDepol_klett_355','volDepol_klett_532','volDepol_klett_1064',\
                                                               'parDepol_klett_355','parDepol_klett_532','parDepol_klett_1064']                        
        profile_translator['DepRatio_Klett']['var_err_name_ls'] = ['']
        profile_translator['DepRatio_Klett']['var_color_ls'] = ['blue','green','red','blue','green','red']
        profile_translator['DepRatio_Klett']['var_style_ls'] = ['-','-','-','--','--','--']
        profile_translator['DepRatio_Klett']['scaling_factor'] = 1
        profile_translator['DepRatio_Klett']['xlim_name'] = 'zLim_VolDepol_1064'
        profile_translator['DepRatio_Klett']['ylim_name'] = 'yLim_Profi_DR'
        profile_translator['DepRatio_Klett']['x_label'] = 'Depolarization Ratio'
        profile_translator['DepRatio_Klett']['plot_filename'] = 'DepRatio_Klett'

        ## DepRatio_Raman
        profile_translator['DepRatio_Raman']['method'] = 'Raman'
        profile_translator['DepRatio_Raman']['misc'] = ''
        profile_translator['DepRatio_Raman']['var_name_ls'] = ['volDepol_raman_355','volDepol_raman_532','volDepol_raman_1064',\
                                                               'parDepol_raman_355','parDepol_raman_532','parDepol_raman_1064']
        profile_translator['DepRatio_Raman']['var_err_name_ls'] = ['']
        profile_translator['DepRatio_Raman']['var_color_ls'] = ['blue','green','red','blue','green','red']
        profile_translator['DepRatio_Raman']['var_style_ls'] = ['-','-','-','--','--','--']
        profile_translator['DepRatio_Raman']['scaling_factor'] = 1
        profile_translator['DepRatio_Raman']['xlim_name'] = 'zLim_VolDepol_1064'
        profile_translator['DepRatio_Raman']['ylim_name'] = 'yLim_Profi_DR'
        profile_translator['DepRatio_Raman']['x_label'] = 'Depolarization Ratio'
        profile_translator['DepRatio_Raman']['plot_filename'] = 'DepRatio_Raman'

        ## Ext_Raman
        profile_translator['Ext_Raman']['method'] = 'Raman'
        profile_translator['Ext_Raman']['misc'] = ''
        profile_translator['Ext_Raman']['var_name_ls'] = ['aerExt_raman_355','aerExt_raman_532','aerExt_raman_1064']                        
        profile_translator['Ext_Raman']['var_err_name_ls'] = ['uncertainty_aerExt_raman_355','uncertainty_aerExt_raman_532','uncertainty_aerExt_raman_1064']
        profile_translator['Ext_Raman']['var_color_ls'] = ['blue','green','red']
        profile_translator['Ext_Raman']['var_style_ls'] = ['-','-','-']
        profile_translator['Ext_Raman']['scaling_factor'] = 10**6
        profile_translator['Ext_Raman']['xlim_name'] = 'xLim_Profi_Ext'
        profile_translator['Ext_Raman']['ylim_name'] = 'yLim_Profi_Ext'
        profile_translator['Ext_Raman']['x_label'] = 'Extinction Coefficient [$Mm^{-1}$]'
        profile_translator['Ext_Raman']['plot_filename'] = 'Ext_Raman'

        ## Ext_RR
        profile_translator['Ext_RR']['method'] = 'RR'
        profile_translator['Ext_RR']['misc'] = ''
        profile_translator['Ext_RR']['var_name_ls'] = ['aerExt_RR_355','aerExt_RR_532','aerExt_RR_1064']                        
        profile_translator['Ext_RR']['var_err_name_ls'] = ['uncertainty_aerExt_RR_355','uncertainty_aerExt_RR_532','uncertainty_aerExt_RR_1064']
        profile_translator['Ext_RR']['var_color_ls'] = ['blue','green','red']
        profile_translator['Ext_RR']['var_style_ls'] = ['-','-','-']
        profile_translator['Ext_RR']['scaling_factor'] = 10**6
        profile_translator['Ext_RR']['xlim_name'] = 'xLim_Profi_Ext'
        profile_translator['Ext_RR']['ylim_name'] = 'yLim_Profi_Ext'
        profile_translator['Ext_RR']['x_label'] = 'Extinction Coefficient [$Mm^{-1}$]'
        profile_translator['Ext_RR']['plot_filename'] = 'Ext_RR'

        ## LR_Raman
        profile_translator['LR_Raman']['method'] = 'Raman'
        profile_translator['LR_Raman']['misc'] = ''
        profile_translator['LR_Raman']['var_name_ls'] = ['aerLR_raman_355','aerLR_raman_532','aerLR_raman_1064']                        
        profile_translator['LR_Raman']['var_err_name_ls'] = ['uncertainty_aerLR_raman_355','uncertainty_aerLR_raman_532','uncertainty_aerLR_raman_1064']
        profile_translator['LR_Raman']['var_color_ls'] = ['blue','green','red']
        profile_translator['LR_Raman']['var_style_ls'] = ['-','-','-']
        profile_translator['LR_Raman']['scaling_factor'] = 1
        profile_translator['LR_Raman']['xlim_name'] = 'xLim_Profi_LR'
        profile_translator['LR_Raman']['ylim_name'] = 'yLim_Profi_LR'
        profile_translator['LR_Raman']['x_label'] = 'Lidar Ratio [$Sr$]'
        profile_translator['LR_Raman']['plot_filename'] = 'LR_Raman'

        ## LR_RR
        profile_translator['LR_RR']['method'] = 'RR'
        profile_translator['LR_RR']['misc'] = ''
        profile_translator['LR_RR']['var_name_ls'] = ['aerLR_RR_355','aerLR_RR_532','aerLR_RR_1064']                        
        profile_translator['LR_RR']['var_err_name_ls'] = ['uncertainty_aerLR_RR_355','uncertainty_aerLR_RR_532','uncertainty_aerLR_RR_1064']
        profile_translator['LR_RR']['var_color_ls'] = ['blue','green','red']
        profile_translator['LR_RR']['var_style_ls'] = ['-','-','-']
        profile_translator['LR_RR']['scaling_factor'] = 1
        profile_translator['LR_RR']['xlim_name'] = 'xLim_Profi_LR'
        profile_translator['LR_RR']['ylim_name'] = 'yLim_Profi_LR'
        profile_translator['LR_RR']['x_label'] = 'Lidar Ratio [$Sr$]'
        profile_translator['LR_RR']['plot_filename'] = 'LR_RR'

        ## WVMR
        profile_translator['WVMR']['method'] = '-'                        
        profile_translator['WVMR']['misc'] = 'wvconst.\ncalibrated.'
        profile_translator['WVMR']['var_name_ls'] = ['WVMR']                        
        profile_translator['WVMR']['var_err_name_ls'] = ['WVMR_rel_error']
        profile_translator['WVMR']['var_color_ls'] = ['blue']
        profile_translator['WVMR']['var_style_ls'] = ['-']
        profile_translator['WVMR']['scaling_factor'] = 1
        profile_translator['WVMR']['xlim_name'] = 'xLim_Profi_WVMR'
        profile_translator['WVMR']['ylim_name'] = 'yLim_Profi_WV_RH'
        profile_translator['WVMR']['x_label'] = 'Water Vapor Mixing Ratio [$g*kg^{-1}$]'
        profile_translator['WVMR']['plot_filename'] = 'WVMR'

        ## RH
        profile_translator['RH']['method'] = '-'                        
        profile_translator['RH']['misc'] = 'wvconst.\ncalibrated.'
        profile_translator['RH']['var_name_ls'] = ['RH']                        
        profile_translator['RH']['var_err_name_ls'] = ['RH_rel_error']
        profile_translator['RH']['var_color_ls'] = ['blue']
        profile_translator['RH']['var_style_ls'] = ['-']
        profile_translator['RH']['scaling_factor'] = 1
        profile_translator['RH']['xlim_name'] = 'xLim_Profi_RH'
        profile_translator['RH']['ylim_name'] = 'yLim_Profi_WV_RH'
        profile_translator['RH']['x_label'] = 'Relative Humidity [%]'
        profile_translator['RH']['plot_filename'] = 'RH'

        ## Meteor_T 
        profile_translator['Meteor_T']['method'] = '-'                        
        profile_translator['Meteor_T']['misc'] = ''
        profile_translator['Meteor_T']['var_name_ls'] = ['temperature']                        
        profile_translator['Meteor_T']['var_err_name_ls'] = ['']
        profile_translator['Meteor_T']['var_color_ls'] = ['blue']
        profile_translator['Meteor_T']['var_style_ls'] = ['-']
        profile_translator['Meteor_T']['scaling_factor'] = 1
        profile_translator['Meteor_T']['xlim_name'] = None
        profile_translator['Meteor_T']['ylim_name'] = None
        profile_translator['Meteor_T']['x_label'] = 'Temperature [°C]'
        profile_translator['Meteor_T']['plot_filename'] = 'Meteor_T'

        ## Meteor_P 
        profile_translator['Meteor_P']['method'] = '-'                        
        profile_translator['Meteor_P']['misc'] = ''
        profile_translator['Meteor_P']['var_name_ls'] = ['pressure']                        
        profile_translator['Meteor_P']['var_err_name_ls'] = ['']
        profile_translator['Meteor_P']['var_color_ls'] = ['blue']
        profile_translator['Meteor_P']['var_style_ls'] = ['-']
        profile_translator['Meteor_P']['scaling_factor'] = 1
        profile_translator['Meteor_P']['xlim_name'] = None
        profile_translator['Meteor_P']['ylim_name'] = None
        profile_translator['Meteor_P']['x_label'] = 'Pressure [hPa]'
        profile_translator['Meteor_P']['plot_filename'] = 'Meteor_P'


        try:
            nc_profiles = readout.get_nc_filename(date, device, inputfolder, param='profiles')
            print(f'plotting profiles to {outputfolder}')
            for profile in nc_profiles:
                nc_dict_profile = readout.read_nc_file(profile)
                starttime=datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%H:%M')
                endtime=datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%H:%M')
                print(f"profile: {starttime} - {endtime}")
                for profilename in profile_translator.keys():
                    print(f"{profilename}")
                    display_profiles.pollyDisplay_profile(nc_dict_profile,profile_translator,profilename,config_dict,polly_conf_dict,outputfolder)
        except Exception as e:
             print("An error occurred:", e)

    
    if 'NR_profiles' in args.retrieval:
        ## plotting profiles
        ## profile_translator
        profile_translator = {}
        profilename_ls = ['Bsc_Klett_NR','Bsc_Raman_NR','Ext_Raman_NR','LR_Raman_NR']
#        profile_dict_key_ls = ['method','misc', 'var_name_ls','var_err_name_ls','scaling_factor','xlim_name','ylim_name','x_label','plot_filename']

        profile_dict_value = {}
#        profile_dict_value['WVMR'] = [['WVMR'], 'WVMR', 'WVMR_rel_error', 'xLim_Profi_WVMR', 'yLim_Profi_WV_RH', 'Water Vapor Mixing Ratio [$g*kg^{-1}$]', 'WVMR']
#        profile_dict_value['aerBsc_klett_355'] = ['aerBsc_klett_355', 'uncertainty_aerBsc_klett_355','xLim_Profi_Bsc','yLim_Profi_Bsc','Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]','Bsc_Klett']
#        profile_dict_value['aerBsc_klett_1064'] = ['aerBsc_klett_1064', 'uncertainty_aerBsc_klett_1064','xLim_Profi_Bsc','yLim_Profi_Bsc','Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]','Bsc_Klett']

        for profilename in profilename_ls:
            profile_translator[profilename] = {}
            #for n,key in enumerate(profile_dict_key_ls):
            #    profile_translator[profilename][key] = profile_dict_value[profilename][n]

        ## Bsc_Klett
        profile_translator['Bsc_Klett_NR']['method'] = 'Klett'
        profile_translator['Bsc_Klett_NR']['misc'] = ''
        profile_translator['Bsc_Klett_NR']['var_name_ls'] = ['aerBsc_klett_355','aerBsc_klett_532']                        
        profile_translator['Bsc_Klett_NR']['var_err_name_ls'] = ['uncertainty_aerBsc_klett_355','uncertainty_aerBsc_klett_532']
        profile_translator['Bsc_Klett_NR']['var_color_ls'] = ['blue','green']
        profile_translator['Bsc_Klett_NR']['var_style_ls'] = ['-','-']
        profile_translator['Bsc_Klett_NR']['scaling_factor'] = 10**6
        profile_translator['Bsc_Klett_NR']['xlim_name'] = 'xLim_Profi_NR_Bsc'
        profile_translator['Bsc_Klett_NR']['ylim_name'] = 'yLim_Profi_Bsc'
        profile_translator['Bsc_Klett_NR']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
        profile_translator['Bsc_Klett_NR']['plot_filename'] = 'Bsc_Klett_NR'

        ## Bsc_Raman
        profile_translator['Bsc_Raman_NR']['method'] = 'Raman'
        profile_translator['Bsc_Raman_NR']['misc'] = ''
        profile_translator['Bsc_Raman_NR']['var_name_ls'] = ['aerBsc_raman_355','aerBsc_raman_532']                        
        profile_translator['Bsc_Raman_NR']['var_err_name_ls'] = ['uncertainty_aerBsc_raman_355','uncertainty_aerBsc_raman_532']
        profile_translator['Bsc_Raman_NR']['var_color_ls'] = ['blue','green']
        profile_translator['Bsc_Raman_NR']['var_style_ls'] = ['-','-']
        profile_translator['Bsc_Raman_NR']['scaling_factor'] = 10**6
        profile_translator['Bsc_Raman_NR']['xlim_name'] = 'xLim_Profi_NR_Bsc'
        profile_translator['Bsc_Raman_NR']['ylim_name'] = 'yLim_Profi_Bsc'
        profile_translator['Bsc_Raman_NR']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
        profile_translator['Bsc_Raman_NR']['plot_filename'] = 'Bsc_Raman_NR'

        ## Ext_Raman
        profile_translator['Ext_Raman_NR']['method'] = 'Raman'
        profile_translator['Ext_Raman_NR']['misc'] = ''
        profile_translator['Ext_Raman_NR']['var_name_ls'] = ['aerExt_raman_355','aerExt_raman_532']                        
        profile_translator['Ext_Raman_NR']['var_err_name_ls'] = ['uncertainty_aerExt_raman_355','uncertainty_aerExt_raman_532']
        profile_translator['Ext_Raman_NR']['var_color_ls'] = ['blue','green']
        profile_translator['Ext_Raman_NR']['var_style_ls'] = ['-','-']
        profile_translator['Ext_Raman_NR']['scaling_factor'] = 10**6
        profile_translator['Ext_Raman_NR']['xlim_name'] = 'xLim_Profi_NR_Ext'
        profile_translator['Ext_Raman_NR']['ylim_name'] = 'yLim_Profi_Ext'
        profile_translator['Ext_Raman_NR']['x_label'] = 'Extinction Coefficient [$Mm^{-1}$]'
        profile_translator['Ext_Raman_NR']['plot_filename'] = 'Ext_Raman_NR'

        ## LR_Raman
        profile_translator['LR_Raman_NR']['method'] = 'Raman'
        profile_translator['LR_Raman_NR']['misc'] = ''
        profile_translator['LR_Raman_NR']['var_name_ls'] = ['aerLR_raman_355','aerLR_raman_532']                        
        profile_translator['LR_Raman_NR']['var_err_name_ls'] = ['uncertainty_aerLR_raman_355','uncertainty_aerLR_raman_532']
        profile_translator['LR_Raman_NR']['var_color_ls'] = ['blue','green']
        profile_translator['LR_Raman_NR']['var_style_ls'] = ['-','-']
        profile_translator['LR_Raman_NR']['scaling_factor'] = 1
        profile_translator['LR_Raman_NR']['xlim_name'] = 'xLim_Profi_LR'
        profile_translator['LR_Raman_NR']['ylim_name'] = 'yLim_Profi_LR'
        profile_translator['LR_Raman_NR']['x_label'] = 'Lidar Ratio [$Sr$]'
        profile_translator['LR_Raman_NR']['plot_filename'] = 'LR_Raman_NR'


        try:
            nc_profiles = readout.get_nc_filename(date, device, inputfolder, param='NR_profiles')
            print(f'plotting NR profiles to {outputfolder}')
            for profile in nc_profiles:
                nc_dict_profile = readout.read_nc_file(profile)
                starttime=datetime.utcfromtimestamp(int(nc_dict_profile['start_time'])).strftime('%H:%M')
                endtime=datetime.utcfromtimestamp(int(nc_dict_profile['end_time'])).strftime('%H:%M')
                print(f"NR profile: {starttime} - {endtime}")
                for profilename in profile_translator.keys():
                    print(f"{profilename}")
                    display_profiles.pollyDisplay_profile(nc_dict_profile,profile_translator,profilename,config_dict,polly_conf_dict,outputfolder)
        except Exception as e:
             print("An error occurred:", e)


#    if ('all' in args.retrieval) or ('overlap' in args.retrieval):
#        ## plotting overlap 
#        nc_files = readout.get_nc_filename(date, device, inputfolder, param='overlap')
#        for data_file in nc_files:
#            nc_dict = readout.read_nc_overlap(data_file)
#            print('plotting overlap:')
#            display_OL.pollyDisplay_Overlap(nc_dict, config_dict, polly_conf_dict, outputfolder)


    ## measure computing time
    elapsed_time = time.process_time() - t0
#    print(elapsed_time)
    print('finished plotting!')
if __name__ == '__main__':
    main()

