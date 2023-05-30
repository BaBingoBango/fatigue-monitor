//
//  DeviceView.swift
//  E4tester
//
//  Created by Seung-Gu Lee on 5/18/23.
//  Copyright © 2023 Felipe Castro. All rights reserved.
//

import SwiftUI

/// Contains UI to connect, disconnect, and view E4 devices.
struct DeviceView: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 32)
            Text("Devices")
                .font(.system(size: 32, weight: .bold))
                .padding(.bottom, -4)
            Text("Connect to your E4 wristband here.")
                .frame(maxWidth: 360)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height:  16)
            
            // Instructions
            VStack {
                Spacer()
                    .frame(height: 10)
                
                Image(DarkMode.isDarkMode() ? "E4_wristband_gc_b" : "E4_wristband_wc_b")
                    .resizable()
                    .frame(width: 340, height: 170)
                
                Spacer()
                    .frame(width: 340, height: 1)
                    .background(Color(white: 0.5))
                    .padding(.top, 4)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Connect:")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 242/255, green: 146/255, blue: 0/255))
                        Text("Press and hold button (2s) until the front LED flashes blue.")
                            .font(.system(size: 14))
                    }
                    .frame(width: 160)
                    
                    VStack(alignment: .leading) {
                        Text("Turn off:")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 242/255, green: 146/255, blue: 0/255))
                        Text("Press and hold button (2s) until both the front LED and the PPG sensor lights turn off.")
                            .font(.system(size: 14))
                    }
                    .frame(width: 160)
                    
                }
                .frame(width: 360, height: 110)
                .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 1.0))
                
                Spacer()
                    .frame(height: 10)
            }
            .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 1.0))
            .frame(width: 360, height: 315)
            .cornerRadius(24)
//            .border(.green) // debug
            
            
            Link(destination: URL(string: "https://eu32.salesforce.com/sfc/p/#5J000001QPsT/a/5J000000p2rz/7eFMC1dLiJPyeTNeTgkxHFOFcdN77YXxiHijMSHsz6E")!) {
                HStack {
                    Image(systemName: "book.fill")
                        .imageScale(.medium)
                    Text("User Manual")
                }
                
            }
            .padding(.top, 8)
            
            
            Spacer()
                .frame(width: 380, height: 1)
                .background(Color(white: 0.5))
                .padding([.vertical], 8)
            
            Text("Devices powered on will show up here.")
                .font(.system(size: 12))
            
            // Devices
            SwiftUIViewController()
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 10))
            
        }
        
    }
}


// implemented to interface with UIKit
/// Ngl idk what this does, ask Hongxiao
struct SwiftUIViewController: UIViewControllerRepresentable {
    @EnvironmentObject var modelData: ModelData
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        if (modelData.user.user_id == -1) {
            print("error init")
        }
        let viewController = ViewController(delegate: context.coordinator//,
//                                            user_id: modelData.user.user_id,
//                                            max_heart_rate: modelData.user.max_heart_rate,
//                                            rest_heart_rate: modelData.user.rest_heart_rate,
//                                            hrr_cp: modelData.user.hrr_cp,
//                                            awc_tot: modelData.user.awc_tot,
//                                            k_value: modelData.user.k_value
        )
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
    
    class Coordinator: NSObject, ViewControllerDelegate {
        func updateHeartRate(_ viewController: ViewController, heartRate: Int) {
            DispatchQueue.main.async{
                self.parent.modelData.heartRate = heartRate
            }
        }
        
        func updateFatigueLevel(_ viewController: ViewController, fatigueLevel: Int) {
            DispatchQueue.main.async {
                self.parent.modelData.fatigueLevel = fatigueLevel
            }
        }
        
        func updateDeviceStatus(_ viewController: ViewController, deviceConnected: Bool) {
            DispatchQueue.main.async {
                self.parent.modelData.deviceConnected = deviceConnected
            }
        }
        
        var parent: SwiftUIViewController
        
        init(_ swiftUIViewController: SwiftUIViewController) {
            parent = swiftUIViewController
        }
    }
    
}
