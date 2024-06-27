from firebase_functions import https_fn
from firebase_admin import initialize_app
import pandas as pd
from scipy.stats import zscore
import neurokit2 as nk
import biobss.preprocess
import json

initialize_app()

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


def clean_TEMP(TEMP):
    if TEMP is None or len(TEMP) == 0:
        return []
    
    return TEMP


@https_fn.on_request()
def process_data(req: https_fn.Request) -> https_fn.Response:
    
    # Get the JSON from the request!
    request_json = req.get_json(silent=True)
    if request_json is None:
        return https_fn.Response("Invalid JSON data", status=400)
    
    # Get the data from the JSON!
    BVP = request_json.get('BVP', None)
    EDL = request_json.get('EDL', None)
    EDA = request_json.get('EDA', None)
    
    response_data = {}
    
    # Clean each
    if BVP is not None:
        BVP_cleaned = clean_BVP(BVP)
        response_data['BVP_cleaned'] = BVP_cleaned.tolist()
        
    if EDA is not None:
        EDL_cleaned, EDR_cleaned = clean_EDA(EDA)
        response_data['EDA_cleaned'] = {'tonic': EDL_cleaned.tolist(), 'phasic': EDR_cleaned.tolist()}
        
    return https_fn.Response(json.dumps(response_data), mimetype='application/json')