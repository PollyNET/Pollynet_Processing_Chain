def profile_dict_keys():
    profile_dict_key_ls = ['method','misc', 'var_name_ls','var_err_name_ls','var_color_ls','var_style_ls','scaling_factor','xlim_name','ylim_name','x_label','plot_filename']
    return profile_dict_key_ls

def profile_translator_function():
    ## profile_translator
    
    profilename_ls = ['Bsc_Klett','Bsc_Raman','Bsc_RR','DepRatio_Klett','DepRatio_Raman','Ext_Raman','Ext_RR','LR_Raman','LR_RR','WVMR','RH','Meteor_T','Meteor_P','AE_Klett','AE_Raman']

    profile_dict_key_ls = profile_dict_keys()

    ## initiate dict
    profile_translator = {}
    for profilename in profilename_ls:
        profile_translator[profilename] = {}
        for n,key in enumerate(profile_dict_key_ls):
            profile_translator[profilename][key] = ''

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

    ## AE_Klett
    profile_translator['AE_Klett']['method'] = 'Klett' 
    profile_translator['AE_Klett']['misc'] = ''
    profile_translator['AE_Klett']['var_name_ls'] = ['AE_beta_355_532_Klett','AE_beta_532_1064_Klett']                        
    profile_translator['AE_Klett']['var_err_name_ls'] = ['']
    profile_translator['AE_Klett']['var_color_ls'] = ['orange','magenta']
    profile_translator['AE_Klett']['var_style_ls'] = ['-','-']
    profile_translator['AE_Klett']['scaling_factor'] = 1
    profile_translator['AE_Klett']['xlim_name'] = 'xLim_Profi_AE'
    profile_translator['AE_Klett']['ylim_name'] = 'yLim_Profi_LR'
    profile_translator['AE_Klett']['x_label'] = 'Angstroem Exponent'
    profile_translator['AE_Klett']['plot_filename'] = 'AE_Klett'

    ## AE_Raman
    profile_translator['AE_Raman']['method'] = 'Raman' 
    profile_translator['AE_Raman']['misc'] = ''
    profile_translator['AE_Raman']['var_name_ls'] = ['AE_beta_355_532_Raman','AE_beta_532_1064_Raman','AE_parExt_355_532_Raman']                        
    profile_translator['AE_Raman']['var_err_name_ls'] = ['']
    profile_translator['AE_Raman']['var_color_ls'] = ['orange','magenta','black']
    profile_translator['AE_Raman']['var_style_ls'] = ['-','-','-']
    profile_translator['AE_Raman']['scaling_factor'] = 1
    profile_translator['AE_Raman']['xlim_name'] = 'xLim_Profi_AE'
    profile_translator['AE_Raman']['ylim_name'] = 'yLim_Profi_LR'
    profile_translator['AE_Raman']['x_label'] = 'Angstroem Exponent'
    profile_translator['AE_Raman']['plot_filename'] = 'AE_Raman'

    return profile_translator

def NR_profile_translator_function():
    ## NR_profile_translator
    
    profilename_ls = ['Bsc_Klett_NR','Bsc_Raman_NR','Ext_Raman_NR','LR_Raman_NR','AE_Klett_NR','AE_Raman_NR']
    profile_dict_key_ls = profile_dict_keys()
    
    ## initiate dict
    profile_translator = {}
    for profilename in profilename_ls:
        profile_translator[profilename] = {}
        for n,key in enumerate(profile_dict_key_ls):
            profile_translator[profilename][key] = ''

    ## Bsc_Klett_NR
    profile_translator['Bsc_Klett_NR']['method'] = 'Klett'
    profile_translator['Bsc_Klett_NR']['misc'] = ''
    profile_translator['Bsc_Klett_NR']['var_name_ls'] = ['aerBsc_klett_355','aerBsc_klett_532']                        
    profile_translator['Bsc_Klett_NR']['var_err_name_ls'] = ['uncertainty_aerBsc_klett_355','uncertainty_aerBsc_klett_532']
    profile_translator['Bsc_Klett_NR']['var_color_ls'] = ['blue','green']
    profile_translator['Bsc_Klett_NR']['var_style_ls'] = ['-','-']
    profile_translator['Bsc_Klett_NR']['scaling_factor'] = 10**6
    profile_translator['Bsc_Klett_NR']['xlim_name'] = 'xLim_Profi_NR_Bsc'
    profile_translator['Bsc_Klett_NR']['ylim_name'] = 'yLim_att_beta_NR'
    profile_translator['Bsc_Klett_NR']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
    profile_translator['Bsc_Klett_NR']['plot_filename'] = 'Bsc_Klett_NR'

    ## Bsc_Raman_NR
    profile_translator['Bsc_Raman_NR']['method'] = 'Raman'
    profile_translator['Bsc_Raman_NR']['misc'] = ''
    profile_translator['Bsc_Raman_NR']['var_name_ls'] = ['aerBsc_raman_355','aerBsc_raman_532']                        
    profile_translator['Bsc_Raman_NR']['var_err_name_ls'] = ['uncertainty_aerBsc_raman_355','uncertainty_aerBsc_raman_532']
    profile_translator['Bsc_Raman_NR']['var_color_ls'] = ['blue','green']
    profile_translator['Bsc_Raman_NR']['var_style_ls'] = ['-','-']
    profile_translator['Bsc_Raman_NR']['scaling_factor'] = 10**6
    profile_translator['Bsc_Raman_NR']['xlim_name'] = 'xLim_Profi_NR_Bsc'
    profile_translator['Bsc_Raman_NR']['ylim_name'] = 'yLim_att_beta_NR'
    profile_translator['Bsc_Raman_NR']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
    profile_translator['Bsc_Raman_NR']['plot_filename'] = 'Bsc_Raman_NR'

    ## Ext_Raman_NR
    profile_translator['Ext_Raman_NR']['method'] = 'Raman'
    profile_translator['Ext_Raman_NR']['misc'] = ''
    profile_translator['Ext_Raman_NR']['var_name_ls'] = ['aerExt_raman_355','aerExt_raman_532']                        
    profile_translator['Ext_Raman_NR']['var_err_name_ls'] = ['uncertainty_aerExt_raman_355','uncertainty_aerExt_raman_532']
    profile_translator['Ext_Raman_NR']['var_color_ls'] = ['blue','green']
    profile_translator['Ext_Raman_NR']['var_style_ls'] = ['-','-']
    profile_translator['Ext_Raman_NR']['scaling_factor'] = 10**6
    profile_translator['Ext_Raman_NR']['xlim_name'] = 'xLim_Profi_NR_Ext'
    profile_translator['Ext_Raman_NR']['ylim_name'] = 'yLim_NR_RCS'
    profile_translator['Ext_Raman_NR']['x_label'] = 'Extinction Coefficient [$Mm^{-1}$]'
    profile_translator['Ext_Raman_NR']['plot_filename'] = 'Ext_Raman_NR'

    ## LR_Raman_NR
    profile_translator['LR_Raman_NR']['method'] = 'Raman'
    profile_translator['LR_Raman_NR']['misc'] = ''
    profile_translator['LR_Raman_NR']['var_name_ls'] = ['aerLR_raman_355','aerLR_raman_532']                        
    profile_translator['LR_Raman_NR']['var_err_name_ls'] = ['uncertainty_aerLR_raman_355','uncertainty_aerLR_raman_532']
    profile_translator['LR_Raman_NR']['var_color_ls'] = ['blue','green']
    profile_translator['LR_Raman_NR']['var_style_ls'] = ['-','-']
    profile_translator['LR_Raman_NR']['scaling_factor'] = 1
    profile_translator['LR_Raman_NR']['xlim_name'] = 'xLim_Profi_LR'
    profile_translator['LR_Raman_NR']['ylim_name'] = 'yLim_NR_RCS'
    profile_translator['LR_Raman_NR']['x_label'] = 'Lidar Ratio [$Sr$]'
    profile_translator['LR_Raman_NR']['plot_filename'] = 'LR_Raman_NR'

    ## AE_Klett_NR
    profile_translator['AE_Klett_NR']['method'] = 'Klett' 
    profile_translator['AE_Klett_NR']['misc'] = ''
    profile_translator['AE_Klett_NR']['var_name_ls'] = ['AE_beta_355_532_Klett']                        
    profile_translator['AE_Klett_NR']['var_err_name_ls'] = ['']
    profile_translator['AE_Klett_NR']['var_color_ls'] = ['orange']
    profile_translator['AE_Klett_NR']['var_style_ls'] = ['-']
    profile_translator['AE_Klett_NR']['scaling_factor'] = 1
    profile_translator['AE_Klett_NR']['xlim_name'] = 'xLim_Profi_AE'
    profile_translator['AE_Klett_NR']['ylim_name'] = 'yLim_NR_RCS'
    profile_translator['AE_Klett_NR']['x_label'] = 'Angstroem Exponent'
    profile_translator['AE_Klett_NR']['plot_filename'] = 'AE_Klett_NR'

    ## AE_Raman_NR
    profile_translator['AE_Raman_NR']['method'] = 'Raman' 
    profile_translator['AE_Raman_NR']['misc'] = ''
    profile_translator['AE_Raman_NR']['var_name_ls'] = ['AE_beta_355_532_Raman','AE_parExt_355_532_Raman'] 
    profile_translator['AE_Raman_NR']['var_err_name_ls'] = ['']
    profile_translator['AE_Raman_NR']['var_color_ls'] = ['orange','black']
    profile_translator['AE_Raman_NR']['var_style_ls'] = ['-','-']
    profile_translator['AE_Raman_NR']['scaling_factor'] = 1
    profile_translator['AE_Raman_NR']['xlim_name'] = 'xLim_Profi_AE'
    profile_translator['AE_Raman_NR']['ylim_name'] = 'yLim_NR_RCS'
    profile_translator['AE_Raman_NR']['x_label'] = 'Angstroem Exponent'
    profile_translator['AE_Raman_NR']['plot_filename'] = 'AE_Raman_NR'

    return profile_translator

def OC_profile_translator_function():
    ## OC_profile_translator
    
    profilename_ls = ['Bsc_Klett_OC','Bsc_Raman_OC','DepRatio_Klett_OC','DepRatio_Raman_OC','Ext_Raman_OC','LR_Raman_OC','AE_Klett_OC','AE_Raman_OC']

    profile_dict_key_ls = profile_dict_keys()

    ## initiate dict
    profile_translator = {}
    for profilename in profilename_ls:
        profile_translator[profilename] = {}
        for n,key in enumerate(profile_dict_key_ls):
            profile_translator[profilename][key] = ''
    
    ## Bsc_Klett_OC
    profile_translator['Bsc_Klett_OC']['method'] = 'Klett'
    profile_translator['Bsc_Klett_OC']['misc'] = ''
    profile_translator['Bsc_Klett_OC']['var_name_ls'] = ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064']                        
    profile_translator['Bsc_Klett_OC']['var_err_name_ls'] = ['uncertainty_aerBsc_klett_355','uncertainty_aerBsc_klett_532','uncertainty_aerBsc_klett_1064']
    profile_translator['Bsc_Klett_OC']['var_color_ls'] = ['blue','green','red']
    profile_translator['Bsc_Klett_OC']['var_style_ls'] = ['-','-','-']
    profile_translator['Bsc_Klett_OC']['scaling_factor'] = 10**6
    profile_translator['Bsc_Klett_OC']['xlim_name'] = 'xLim_Profi_Bsc'
    profile_translator['Bsc_Klett_OC']['ylim_name'] = 'yLim_Profi_Bsc'
    profile_translator['Bsc_Klett_OC']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
    profile_translator['Bsc_Klett_OC']['plot_filename'] = 'OC_Bsc_Klett'

    ## Bsc_Raman_OC
    profile_translator['Bsc_Raman_OC']['method'] = 'Raman'
    profile_translator['Bsc_Raman_OC']['misc'] = ''
    profile_translator['Bsc_Raman_OC']['var_name_ls'] = ['aerBsc_raman_355','aerBsc_raman_532','aerBsc_raman_1064']                        
    profile_translator['Bsc_Raman_OC']['var_err_name_ls'] = ['uncertainty_aerBsc_raman_355','uncertainty_aerBsc_raman_532','uncertainty_aerBsc_raman_1064']
    profile_translator['Bsc_Raman_OC']['var_color_ls'] = ['blue','green','red']
    profile_translator['Bsc_Raman_OC']['var_style_ls'] = ['-','-','-']
    profile_translator['Bsc_Raman_OC']['scaling_factor'] = 10**6
    profile_translator['Bsc_Raman_OC']['xlim_name'] = 'xLim_Profi_Bsc'
    profile_translator['Bsc_Raman_OC']['ylim_name'] = 'yLim_Profi_Bsc'
    profile_translator['Bsc_Raman_OC']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
    profile_translator['Bsc_Raman_OC']['plot_filename'] = 'OC_Bsc_Raman'

    ## DepRatio_Klett_OC
    profile_translator['DepRatio_Klett_OC']['method'] = 'Klett'
    profile_translator['DepRatio_Klett_OC']['misc'] = ''
    profile_translator['DepRatio_Klett_OC']['var_name_ls'] = ['volDepol_klett_355','volDepol_klett_532',\
                                                              'parDepol_klett_355','parDepol_klett_532']                        
    profile_translator['DepRatio_Klett_OC']['var_err_name_ls'] = ['']
    profile_translator['DepRatio_Klett_OC']['var_color_ls'] = ['blue','green','blue','green']
    profile_translator['DepRatio_Klett_OC']['var_style_ls'] = ['-','-','--','--']
    profile_translator['DepRatio_Klett_OC']['scaling_factor'] = 1
    profile_translator['DepRatio_Klett_OC']['xlim_name'] = 'zLim_VolDepol_1064'
    profile_translator['DepRatio_Klett_OC']['ylim_name'] = 'yLim_Profi_DR'
    profile_translator['DepRatio_Klett_OC']['x_label'] = 'Depolarization Ratio'
    profile_translator['DepRatio_Klett_OC']['plot_filename'] = 'OC_DepRatio_Klett'

    ## DepRatio_Raman_OC
    profile_translator['DepRatio_Raman_OC']['method'] = 'Raman'
    profile_translator['DepRatio_Raman_OC']['misc'] = ''
    profile_translator['DepRatio_Raman_OC']['var_name_ls'] = ['volDepol_raman_355','volDepol_raman_532',\
                                                              'parDepol_raman_355','parDepol_raman_532']
    profile_translator['DepRatio_Raman_OC']['var_err_name_ls'] = ['']
    profile_translator['DepRatio_Raman_OC']['var_color_ls'] = ['blue','green','blue','green']
    profile_translator['DepRatio_Raman_OC']['var_style_ls'] = ['-','-','--','--']
    profile_translator['DepRatio_Raman_OC']['scaling_factor'] = 1
    profile_translator['DepRatio_Raman_OC']['xlim_name'] = 'zLim_VolDepol_1064'
    profile_translator['DepRatio_Raman_OC']['ylim_name'] = 'yLim_Profi_DR'
    profile_translator['DepRatio_Raman_OC']['x_label'] = 'Depolarization Ratio'
    profile_translator['DepRatio_Raman_OC']['plot_filename'] = 'OC_DepRatio_Raman'

    ## Ext_Raman_OC
    profile_translator['Ext_Raman_OC']['method'] = 'Raman'
    profile_translator['Ext_Raman_OC']['misc'] = ''
    profile_translator['Ext_Raman_OC']['var_name_ls'] = ['aerExt_raman_355','aerExt_raman_532','aerExt_raman_1064']                        
    profile_translator['Ext_Raman_OC']['var_err_name_ls'] = ['uncertainty_aerExt_raman_355','uncertainty_aerExt_raman_532','uncertainty_aerExt_raman_1064']
    profile_translator['Ext_Raman_OC']['var_color_ls'] = ['blue','green','red']
    profile_translator['Ext_Raman_OC']['var_style_ls'] = ['-','-','-']
    profile_translator['Ext_Raman_OC']['scaling_factor'] = 10**6
    profile_translator['Ext_Raman_OC']['xlim_name'] = 'xLim_Profi_Ext'
    profile_translator['Ext_Raman_OC']['ylim_name'] = 'yLim_Profi_Ext'
    profile_translator['Ext_Raman_OC']['x_label'] = 'Extinction Coefficient [$Mm^{-1}$]'
    profile_translator['Ext_Raman_OC']['plot_filename'] = 'OC_Ext_Raman'

    ## LR_Raman_OC
    profile_translator['LR_Raman_OC']['method'] = 'Raman'
    profile_translator['LR_Raman_OC']['misc'] = ''
    profile_translator['LR_Raman_OC']['var_name_ls'] = ['aerLR_raman_355','aerLR_raman_532','aerLR_raman_1064']                        
    profile_translator['LR_Raman_OC']['var_err_name_ls'] = ['uncertainty_aerLR_raman_355','uncertainty_aerLR_raman_532','uncertainty_aerLR_raman_1064']
    profile_translator['LR_Raman_OC']['var_color_ls'] = ['blue','green','red']
    profile_translator['LR_Raman_OC']['var_style_ls'] = ['-','-','-']
    profile_translator['LR_Raman_OC']['scaling_factor'] = 1
    profile_translator['LR_Raman_OC']['xlim_name'] = 'xLim_Profi_LR'
    profile_translator['LR_Raman_OC']['ylim_name'] = 'yLim_Profi_LR'
    profile_translator['LR_Raman_OC']['x_label'] = 'Lidar Ratio [$Sr$]'
    profile_translator['LR_Raman_OC']['plot_filename'] = 'OC_LR_Raman'

    ## AE_Klett_OC
    profile_translator['AE_Klett_OC']['method'] = 'Klett' 
    profile_translator['AE_Klett_OC']['misc'] = ''
    profile_translator['AE_Klett_OC']['var_name_ls'] = ['AE_beta_355_532_Klett','AE_beta_532_1064_Klett']                        
    profile_translator['AE_Klett_OC']['var_err_name_ls'] = ['']
    profile_translator['AE_Klett_OC']['var_color_ls'] = ['orange','magenta']
    profile_translator['AE_Klett_OC']['var_style_ls'] = ['-','-']
    profile_translator['AE_Klett_OC']['scaling_factor'] = 1
    profile_translator['AE_Klett_OC']['xlim_name'] = 'xLim_Profi_AE'
    profile_translator['AE_Klett_OC']['ylim_name'] = 'yLim_Profi_LR'
    profile_translator['AE_Klett_OC']['x_label'] = 'Angstroem Exponent'
    profile_translator['AE_Klett_OC']['plot_filename'] = 'AE_Klett_OC'

    ## AE_Raman_OC
    profile_translator['AE_Raman_OC']['method'] = 'Raman' 
    profile_translator['AE_Raman_OC']['misc'] = ''
    profile_translator['AE_Raman_OC']['var_name_ls'] = ['AE_beta_355_532_Raman','AE_beta_532_1064_Raman','AE_parExt_355_532_Raman']                        
    profile_translator['AE_Raman_OC']['var_err_name_ls'] = ['']
    profile_translator['AE_Raman_OC']['var_color_ls'] = ['orange','magenta','black']
    profile_translator['AE_Raman_OC']['var_style_ls'] = ['-','-','-']
    profile_translator['AE_Raman_OC']['scaling_factor'] = 1
    profile_translator['AE_Raman_OC']['xlim_name'] = 'xLim_Profi_AE'
    profile_translator['AE_Raman_OC']['ylim_name'] = 'yLim_Profi_LR'
    profile_translator['AE_Raman_OC']['x_label'] = 'Angstroem Exponent'
    profile_translator['AE_Raman_OC']['plot_filename'] = 'AE_Raman_OC'

    return profile_translator


def POLIPHON_profile_translator_function():
    ## POLIPHON_profile_translator
    
    profilename_ls = ['POLIPHON_Bsc_Klett','POLIPHON_Bsc_Raman']

    profile_dict_key_ls = profile_dict_keys()

    ## initiate dict
    profile_translator = {}
    for profilename in profilename_ls:
        profile_translator[profilename] = {}
        for n,key in enumerate(profile_dict_key_ls):
            profile_translator[profilename][key] = ''

    ## Bsc_Klett
    profile_translator['POLIPHON_Bsc_Klett']['method'] = 'Klett'
    profile_translator['POLIPHON_Bsc_Klett']['misc'] = ''
    profile_translator['POLIPHON_Bsc_Klett']['var_name_ls'] = ['aerBsc_klett_355','aerBsc_klett_532','aerBsc_klett_1064','aerBsc355_klett_d1','aerBsc532_klett_d1','aerBsc1064_klett_d1','aerBsc355_klett_nd1','aerBsc532_klett_nd1','aerBsc1064_klett_nd1']                        
    profile_translator['POLIPHON_Bsc_Klett']['var_err_name_ls'] = ['uncertainty_aerBsc_klett_355','uncertainty_aerBsc_klett_532','uncertainty_aerBsc_klett_1064']
    profile_translator['POLIPHON_Bsc_Klett']['var_color_ls'] = ['blue','green','red','blue','green','red','blue','green','red']
    profile_translator['POLIPHON_Bsc_Klett']['var_style_ls'] = ['-','-','-','--','--','--','dotted','dotted','dotted']
    profile_translator['POLIPHON_Bsc_Klett']['scaling_factor'] = 10**6
    profile_translator['POLIPHON_Bsc_Klett']['xlim_name'] = 'xLim_beta_532_Poliphon'
    profile_translator['POLIPHON_Bsc_Klett']['ylim_name'] = 'yLim_beta_532_Poliphon'
    profile_translator['POLIPHON_Bsc_Klett']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
    profile_translator['POLIPHON_Bsc_Klett']['plot_filename'] = 'Bsc_Klett_POLIPHON_1'

    ## Bsc_Raman
    profile_translator['POLIPHON_Bsc_Raman']['method'] = 'Raman'
    profile_translator['POLIPHON_Bsc_Raman']['misc'] = ''
    profile_translator['POLIPHON_Bsc_Raman']['var_name_ls'] = ['aerBsc_raman_355','aerBsc_raman_532','aerBsc_raman_1064','aerBsc355_raman_d1','aerBsc532_raman_d1','aerBsc1064_raman_d1','aerBsc355_raman_nd1','aerBsc532_raman_nd1','aerBsc1064_raman_nd1']
    profile_translator['POLIPHON_Bsc_Raman']['var_err_name_ls'] = ['uncertainty_aerBsc_raman_355','uncertainty_aerBsc_raman_532','err_poliphon_aerBsc532_raman_d1','err_poliphon_aerBsc532_raman_nd1']
    profile_translator['POLIPHON_Bsc_Raman']['var_color_ls'] = ['blue','green','red','blue','green','red','blue','green','red']
    profile_translator['POLIPHON_Bsc_Raman']['var_style_ls'] = ['-','-','-','--','--','--','dotted','dotted','dotted']
    profile_translator['POLIPHON_Bsc_Raman']['scaling_factor'] = 10**6
    profile_translator['POLIPHON_Bsc_Raman']['xlim_name'] = 'xLim_beta_532_Poliphon'
    profile_translator['POLIPHON_Bsc_Raman']['ylim_name'] = 'yLim_beta_532_Poliphon'
    profile_translator['POLIPHON_Bsc_Raman']['x_label'] = 'Backscatter Coefficient [$Mm^{-1}*sr^{-1}$]'
    profile_translator['POLIPHON_Bsc_Raman']['plot_filename'] = 'Bsc_Raman_POLIPHON_1'

    return profile_translator

