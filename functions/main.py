from firebase_functions import https_fn
from firebase_admin import initialize_app
import pandas as pd
from scipy.stats import zscore
import neurokit2 as nk
import biobss.preprocess
import json
from biobss.edatools.eda_freqdomain import eda_freq_features
from biobss.edatools.eda_statistical import eda_stat_features
from biobss.ppgtools.ppg_features import get_ppg_features
from scipy.signal import find_peaks
from scipy.fftpack import fft
import xgboost
from sklearn.model_selection import GridSearchCV, KFold
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.preprocessing import StandardScaler, OneHotEncoder
import numpy as np
import matplotlib.pyplot as plt
import warnings
import random

# Start by initializing the Firebase connection!
initialize_app()

# MARK: Metdata from the Colab notebook
metadata = {
    'BVP': {'sampling_rate': 64, 'unit': 'mV'},
    'EDA': {'sampling_rate': 4, 'unit': 'uS'},
    'EDL': {'sampling_rate': 4, 'unit': 'uS'},
    'EDR': {'sampling_rate': 4, 'unit': 'uS'},
    'TEMP': {'sampling_rate': 4, 'unit': '°C'},
    'ECG': {'sampling_rate': 1, 'unit': 'BPM'},
    'CoTemp': {'sampling_rate': 0.1, 'unit': 'OtherUnit'},
    'PSI': {'sampling_rate': 1, 'unit': 'OtherUnit'}
}

# MARK: Cleaning functions from the Colab notebook
def clean_BVP(BVP):
    BVP_series = pd.Series(BVP)
    BVP_zscored = zscore(BVP_series)
    filtered_ppg = biobss.preprocess.filter_signal(
        BVP_zscored,
        sampling_rate=metadata['BVP']['sampling_rate'],
        filter_type='bandpass',
        N=2,
        f_lower=0.5,
        f_upper=4
    )
    return filtered_ppg


def clean_EDA(EDA):
    if EDA is None or len(EDA) == 0:
        return [], []
    
    EDA_series = pd.Series(EDA)
    EDA_zscored = zscore(EDA_series)
    high = nk.eda_phasic(
        EDA_zscored.values.flatten(),
        sampling_rate=metadata['EDA']['sampling_rate'],
        method='cvxEDA'
    )
    tonic, phasic = high["EDA_Tonic"].values, high["EDA_Phasic"].values
    return tonic, phasic
    
# MARK: Feature extraction functions
def extract_features_bvp(segment):

    signal = segment

    mean_val = np.mean(signal)
    std_val = np.std(signal)
    median_val = np.median(signal)
    min = np.min(signal)
    max_min_diff = np.max(signal) - np.min(signal)

    rss = np.sqrt(np.sum(np.square(signal)))

    peaks, _ = find_peaks(signal)

    baseline = mean_val
    amplitudes = signal[peaks] - baseline
    amplitudes = np.mean(amplitudes)

    half_window = len(segment) // 2
    baseline_start_mean = np.mean(segment[:half_window])
    baseline_end_mean = np.mean(segment[half_window:])

    baseline_shift = baseline_end_mean - baseline_start_mean

    return {
        'PPG_Mean': mean_val,
        'PPG_var': std_val,
        'PPG_median': median_val,
        'PPG_min': min,
        'PPG_max_min_diff': max_min_diff,
        'PPG_amplitude': amplitudes,
        'PPG_baseline_shift': baseline_shift,
        'PPG_rss' : rss
    }

def extract_features_edl(segment):
    signal = segment

    mean_val = np.mean(signal)
    var_val = np.var(signal)
    std_val = np.std(signal)
    median_val = np.median(signal)

    return {
        'EDL_Mean': mean_val,
        'EDL_var': var_val,
        'EDL_std': std_val,
        'EDL_median': median_val,
    }

def extract_features_edr(segment):
    signal = segment

    mean_val = np.mean(signal)
    var_val = np.var(signal)
    std_val = np.std(signal)
    median_val = np.median(signal)

    return {
        'EDR_Mean': mean_val,
        'EDR_var': var_val,
        'EDR_std': std_val,
        'EDR_median': median_val,
    }

def extract_features_temp(segment):

    signal = segment

    mean_val = np.mean(signal)
    var_val = np.std(signal)
    
    signal_fft = fft(signal)
    frequencies = np.fft.fftfreq(len(signal_fft), d=0.25)  # 4Hz sampling, so 0.25s time intervals

    pos_mask = frequencies > 0
    signal_fft = signal_fft[pos_mask]
    frequencies = frequencies[pos_mask]

    magnitude = np.abs(signal_fft)

    mean_freq = np.sum(frequencies * magnitude) / np.sum(magnitude)

    cumulative_magnitude = np.cumsum(magnitude)
    median_freq = frequencies[np.searchsorted(cumulative_magnitude, cumulative_magnitude[-1] / 2)]

    return {
        'Temp_Mean': mean_val,
        'Temp_Var': var_val,
    }

# MARK: Main execution area
# This is where execution starts when the Cloud Function "process_data" is called!
@https_fn.on_request()
def process_data(req: https_fn.Request) -> https_fn.Response:
    # Get the JSON from the request!
    request_json = req.get_json(silent=True)
    if request_json is None:
        return https_fn.Response("Invalid JSON data", status=400)

    # Get the data from the JSON!
    BVP = request_json.get('BVP', None)
    EDA = request_json.get('EDA', None)
    TEMP = request_json.get('TEMP', None)
    ECG = request_json.get('ECG', None)

    data = {
        'BVP': np.array(BVP) if BVP else None,
        'EDA': np.array(EDA) if EDA else None,
        'TEMP': np.array(TEMP) if TEMP else None,
        'ECG': np.array(ECG) if ECG else None,
    }

    response_data = {}

    if data['BVP'] is not None:
        BVP_cleaned = clean_BVP(data['BVP'])
        BVP_features = extract_features_bvp(BVP_cleaned)
        response_data.update(BVP_features)

    if data['EDA'] is not None:
        EDL_cleaned, EDR_cleaned = clean_EDA(data['EDA'])
        EDL_features = extract_features_edl(np.array(EDL_cleaned))
        EDR_features = extract_features_edr(np.array(EDR_cleaned))
        response_data.update(EDL_features)
        response_data.update(EDR_features)

    if data['TEMP'] is not None:
        TEMP_cleaned = data['TEMP']  # Assuming TEMP does not need additional cleaning
        TEMP_features = extract_features_temp(np.array(TEMP_cleaned))
        response_data.update(TEMP_features)

    if data['ECG'] is not None:
        # Assuming ECG does not need additional cleaning or features extraction
        pass

    print(f"Extracted features: {response_data}")
    return https_fn.Response(json.dumps(response_data), mimetype='application/json')
