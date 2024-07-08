//
//  PredictionServices.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/27/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import Foundation
import CoreML

struct PredictionServices {
    static func predictHeatStrain(inputFeatures: [String : Any]) -> Double? {
        
        // Create the model object from the .mlmodel file!
        let modelConfiguration = MLModelConfiguration()
        guard let model = try? DPM_Heat_Strain_Model(configuration: modelConfiguration) else {
            print("🔥 AHS - Failed to load model")
            return nil
        }
        
        // Extract feature values from the inputFeatures dictionary
            guard let PPG_Mean = inputFeatures["PPG_Mean"] as? Double,
                  let PPG_var = inputFeatures["PPG_var"] as? Double,
                  let PPG_median = inputFeatures["PPG_median"] as? Double,
                  let PPG_min = inputFeatures["PPG_min"] as? Double,
                  let PPG_max_min_diff = inputFeatures["PPG_max_min_diff"] as? Double,
                  let PPG_amplitude = inputFeatures["PPG_amplitude"] as? Double,
                  let PPG_baseline_shift = inputFeatures["PPG_baseline_shift"] as? Double,
                  let PPG_rss = inputFeatures["PPG_rss"] as? Double,
                  let EDL_Mean = inputFeatures["EDL_Mean"] as? Double,
                  let EDL_var = inputFeatures["EDL_var"] as? Double,
                  let EDL_std = inputFeatures["EDL_std"] as? Double,
                  let EDL_median = inputFeatures["EDL_median"] as? Double,
                  let EDR_Mean = inputFeatures["EDR_Mean"] as? Double,
                  let EDR_var = inputFeatures["EDR_var"] as? Double,
                  let EDR_std = inputFeatures["EDR_std"] as? Double,
                  let EDR_median = inputFeatures["EDR_median"] as? Double,
                  let Temp_Mean = inputFeatures["Temp_Mean"] as? Double,
                  let Temp_Var = inputFeatures["Temp_Var"] as? Double else {
                print("🔥 AHS - Invalid or missing feature values")
                return nil
            }
        
        // Create the model input!
        let modelInput = DPM_Heat_Strain_ModelInput(PPG_Mean: PPG_Mean,
                                                    PPG_var: PPG_var,
                                                    PPG_median: PPG_median,
                                                    PPG_min: PPG_min,
                                                    PPG_max_min_diff: PPG_max_min_diff,
                                                    PPG_amplitude: PPG_amplitude,
                                                    PPG_baseline_shift: PPG_baseline_shift,
                                                    PPG_rss: PPG_rss,
                                                    EDL_Mean: EDL_Mean,
                                                    EDL_var: EDL_var,
                                                    EDL_std: EDL_std,
                                                    EDL_median: EDL_median,
                                                    EDR_Mean: EDR_Mean,
                                                    EDR_var: EDR_var,
                                                    EDR_std: EDR_std,
                                                    EDR_median: EDR_median,
                                                    Temp_Mean: Temp_Mean,
                                                    Temp_Var: Temp_Var
        )
            
        // Perform the prediction
        do {
            let prediction = try model.prediction(input: modelInput)
            print("🔥 AHS - Prediction: PREDICTED PSI VALUE IS \(prediction.PSI)")
            return prediction.PSI
        } catch {
            print("🔥 AHS - Prediction error: \(error)")
            return nil
        }
    }
}
