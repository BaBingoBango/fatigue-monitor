//
//  DashboardView.swift
//  E4tester
//
//  Created by Waley Zheng on 6/29/22.
//  Modified by Seung-Gu Lee on 5/16/23.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var modelData: ModelData
    
    @AppStorage("userFirstName") var userFirstName: String = ""
    
    // timer for periodic crew info retrieval
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack {
            ScrollView{
                VStack(alignment: .leading) {
                    if (modelData.user.user_id != -1) {
                        SwiftUIViewController()
                            .frame(height: 40)
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 0 , trailing: 10))
                        //                        .border(.green)
                    }
                    
                    Text("Daily Summary")
                        .font(.system(size: 20, weight: .bold))
                        .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    
                    HStack{
                        Image(systemName: "hand.wave.fill")
                        Text("Hello, \(userFirstName)")
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .padding([.horizontal], 20)
                    
                    InfoView()
                        .frame(height: 200)
                        .background(DarkMode.isDarkMode() ? Color.black : Color.white)
                        .cornerRadius(15)
                        .padding([.horizontal], 20)
                    
                    // My crew
                    HStack{
                        Image(systemName: "person.2.fill")
                        Text("My Crew")
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .padding([.horizontal], 20)
                    
                    CrewView()
                        .padding([.horizontal], 20)
                    //                CollapsibleView()
                    //                    .onReceive(Timer.publish(every: 5, tolerance: 5, on: .main, in: .default)) { (_) in
                        .onReceive(timer) { _ in
                            print("update crew")
                            Task {
                                await modelData.updateCrew()
                            }
                        }
                        .onAppear {
                            print("init crew")
                            Task {
                                await modelData.updateCrew()
                            }
                        }
                }
            }
            
//            // user isn't signed in -> prompt sign-in
//            if !modelData.nameEntered {
//                Spacer()
//                    .frame(width: 400)
//                    .background(Color.black)
//                    .opacity(0.8)
//
//                VStack {
//                    Text("Please sign in")
//                }
//            }
        }
        
        
//        .background(Color("BackgroundColorGray").ignoresSafeArea())
    }
}

// implemented to interface with UIKit
struct SwiftUIViewController: UIViewControllerRepresentable {
    @EnvironmentObject var modelData: ModelData
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        if (modelData.user.user_id == -1) {
            print("error init")
        }
        let viewController = ViewController(delegate: context.coordinator,
                                            user_id: modelData.user.user_id,
                                            max_heart_rate: modelData.user.max_heart_rate,
                                            rest_heart_rate: modelData.user.rest_heart_rate,
                                            hrr_cp: modelData.user.hrr_cp,
                                            awc_tot: modelData.user.awc_tot,
                                            k_value: modelData.user.k_value
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

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(ModelData())
    }
}
