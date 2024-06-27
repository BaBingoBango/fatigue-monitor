//
//  PredictionServices.swift
//  E4tester
//
//  Created by Ethan Marshall on 6/27/24.
//  Copyright © 2024 Felipe Castro. All rights reserved.
//

import Foundation
import CoreML

//func predictHeatStrain() {
//    
//    // Create the model object from the .mlmodel file!
//    let modelConfiguration = MLModelConfiguration()
//    guard let model = try? DPM_Heat_Strain_Model(configuration: modelConfiguration) else {
//        // TODO: handle prediction error
//    }
//    
//    let modelInput = DPM_Heat_Strain_ModelInput(PPG_Mean: <#T##Double#>,
//                                                PPG_var: <#T##Double#>,
//                                                PPG_median: <#T##Double#>,
//                                                PPG_min: <#T##Double#>,
//                                                PPG_max_min_diff: <#T##Double#>,
//                                                PPG_amplitude: <#T##Double#>,
//                                                PPG_baseline_shift: <#T##Double#>,
//                                                PPG_rss: <#T##Double#>,
//                                                EDL_Mean: <#T##Double#>,
//                                                EDL_var: <#T##Double#>,
//                                                EDL_std: <#T##Double#>,
//                                                EDL_median: <#T##Double#>,
//                                                EDR_Mean: <#T##Double#>,
//                                                EDR_var: <#T##Double#>,
//                                                EDR_std: <#T##Double#>,
//                                                EDR_median: <#T##Double#>,
//                                                Temp_Mean: <#T##Double#>,
//                                                Temp_Var: <#T##Double#>
//    )
//}
