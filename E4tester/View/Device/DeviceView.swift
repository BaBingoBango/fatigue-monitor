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
            Text("Press and hold the button on the E4 wristband until the light flashes blue.")
                .frame(maxWidth: 360)
                .multilineTextAlignment(.center)
            Spacer()
                .frame(height:  16)
            
            SwiftUIViewController()
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 0 , trailing: 10))
            
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
        
        var parent: SwiftUIViewController
        
        init(_ swiftUIViewController: SwiftUIViewController) {
            parent = swiftUIViewController
        }
    }
    
}
