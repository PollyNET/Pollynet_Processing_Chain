# -*- coding: utf-8 -*-
"""
Created on Fri Feb 16 13:33:13 2024

@author: TSICHLA
"""

import numpy as np


def signaltonoise(a, axis=0, ddof=0):
    a = np.asanyarray(a)
    m = a.mean(axis)
    sd = a.std(axis=axis, ddof=ddof)
    return np.where(sd == 0, 0, m/sd)


def optimum_norm_region(nf_signal, ff_signal, overlap, corr_coef_threshold, snr_nf_threshold):
    """
    Parameters
    ----------
    nf_signal: vector
       The Near Field signal.
    ff_signal: vector
       The Far Field signal.
    overlap: integer 
       lower bin to start looking for the gluing window
    corr_coef_threshold: float
       minimum correlation coefficient that the signals must have to choose gluing window
    snr_nf_threshold: float
       minimum signal to noise ratio that the near field signals must have to choose gluing window
       
    Returns
    -------
    norm_region: integer list
       Two integers that define: the first the base of the window and the second the window interval addition to the minimum window.
    """
    iterations = 26 
    minimum_window = 20
    gluing_window = 21


    corr_coef = np.zeros((iterations, gluing_window))
    snr_nf = np.zeros((iterations, gluing_window))
    snr_ff = np.zeros((iterations, gluing_window))
    for i in range (0,iterations):
        for j in range (0,gluing_window):           
            corr_coef[i][j] = np.corrcoef(nf_signal[overlap+i:overlap+i+minimum_window+j], ff_signal[overlap+i:overlap+i+minimum_window+j])[(0,1)]       #14 window antistoixei se 100 m
            snr_nf[i][j] = signaltonoise(nf_signal[overlap+i:overlap+i+minimum_window+j], axis=0, ddof=0)
            snr_ff[i][j] = signaltonoise(ff_signal[overlap+i:overlap+i+minimum_window+j], axis=0, ddof=0)
    max_corr_coef = np.amax(corr_coef)
    
    
    if max_corr_coef!=max_corr_coef:
        next_max_corr_coef = np.nan
        next_max_corr_coef_position = ([0],[0])
        snr_nf_value = np.nan
    else:
        max_corr_coef_position = np.where(corr_coef==max_corr_coef)
        snr_nf_initial = snr_nf[max_corr_coef_position[0][0]][max_corr_coef_position[1][0]]
    
    ##############next biggest correlation coefficient
        next_max_corr_coef = max_corr_coef
        next_max_corr_coef_position = max_corr_coef_position
        snr_nf_value = snr_nf_initial
    
        while snr_nf_value<snr_nf_threshold:
            indexes = np.where (corr_coef<next_max_corr_coef)
            if not (indexes[0].any() or indexes[1].any()):
                if np.max(corr_coef[indexes])<corr_coef_threshold: 
                    snr_nf_threshold -= 0.05
                    snr_nf_value = snr_nf_initial
                    next_max_corr_coef = max_corr_coef
                    next_max_corr_coef_position = max_corr_coef_position
                else:
                    next_max_corr_coef = max_corr_coef - np.min(max_corr_coef - corr_coef[indexes])
                    next_max_corr_coef_position = np.where(corr_coef==next_max_corr_coef)
                    snr_nf_value = snr_nf[next_max_corr_coef_position[0][0]][next_max_corr_coef_position[1][0]]
            else:
                break
        
        
    return  next_max_corr_coef_position

def test_func(nf_signal,overlap):
    print(type(nf_signal))

def gluing_window_parameters(nf_signal, ff_signal, overlap, corr_coef_threshold, snr_nf_threshold):
    """
    Calculates the gluing window and the normalization factor of near field to the far field in that window
    
    Parameters
    ----------
    nf_signal: vector
       The Near Field signal.
    ff_signal: vector
       The Far Field signal.
    overlap: integer 
       lower bin to start looking for the gluing window
    corr_coef_threshold: float
       minimum correlation coefficient that the signals must have to choose gluing window
    snr_nf_threshold: float
       minimum signal to noise ratio that the near field signals must have to choose gluing window
       
    Returns
    -------
    bin_low: integer 
       the base bin of the window
    bin_high: integer
       the upper bin of the window
    mean_norm_factor: float
       the normalization factor
    """
    
    # Determine the ideal gluing region.
    next_max_corr_coef_position = optimum_norm_region(nf_signal, ff_signal, overlap, corr_coef_threshold, snr_nf_threshold)
    minimum_window = 20

    bin_low = overlap + next_max_corr_coef_position[0][0] 
    bin_high = overlap + next_max_corr_coef_position[0][0] + minimum_window + next_max_corr_coef_position[1][0]
    
    mean_norm_factor = np.mean(ff_signal[bin_low:bin_high]) / np.mean(nf_signal[bin_low:bin_high])
    

    return bin_low, bin_high, mean_norm_factor  


def signal_gluing(nf_signal, ff_signal, mean_norm_factor, bin_low, bin_high):
    """
    Glue the adjusted Near Field signal with the Far Field signal, after 
    performing a weighted averaging for a specified vertical region.
    
    Parameters
    ----------
    nf_signal: vector
       The Near Field signal.
    ff_signal: vector
       The Far Field signal.
    bin_low: integer 
       the base bin of the window
    bin_high: integer
       the upper bin of the window
    mean_norm_factor: float
       the normalization factor
    
    Returns
    -------
    glued_signal: vector
       The glued signals.
    """
                
    nf_adjusted_signal = nf_signal * mean_norm_factor

    # Create "weight" vectors for the averaging.
    nf_weight = np.linspace(1, 0, (bin_high-bin_low)) 
    ff_weight = 1 - nf_weight
        
    #### Weights based on sigmoid function
#    x = np.arange(0,(bin_high-bin_low), 1)
#    ff_weight = (1+np.tanh((x-(12)/6))/2)/np.nanmax(1+np.tanh((x-(12)/6))/2)
#    nf_weight = 1 - ff_weight
    
    averaging_weights = np.column_stack((nf_weight, ff_weight))
    
    # Assign variables according to the selected vertical range for the NF-FF comparison.
    nf = nf_adjusted_signal[bin_low : bin_high] 
    ff = ff_signal[bin_low : bin_high]
    
    # Calculate weighted average.
    average_signal = np.average(np.column_stack((nf, ff)), axis=1, weights=averaging_weights)    

    # Glue the signals.
    glued_signal = np.concatenate((nf_adjusted_signal[:bin_low], average_signal, ff_signal[bin_high:]), axis=0)

    return glued_signal  


def signal_gluing_function_for_matlab(nf_signal, ff_signal):
    """
    Calculates the gluing window and the normalization factor of near field to the far field in that window
    
    Parameters
    ----------
    nf_signal: vector
       The Near Field signal.
    ff_signal: vector
       The Far Field signal.
    
    Returns
    -------
    glued_signal: vector
       The glued signals.
    """

    corr_coef_threshold = 0.75
    snr_nf_threshold = 5
    overlap = 80
    
    nf_signal = np.array(nf_signal)
    ff_signal = np.array(ff_signal)
    overlap = int(overlap)
                
    bin_low, bin_high, mean_norm_factor = gluing_window_parameters(nf_signal, ff_signal, overlap, corr_coef_threshold, snr_nf_threshold)

    glued_signal = signal_gluing(nf_signal, ff_signal, mean_norm_factor, bin_low, bin_high)

    return glued_signal

