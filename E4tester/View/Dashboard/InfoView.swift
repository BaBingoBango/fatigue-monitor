//
//  InfoView.swift
//  E4tester
//
//  Created by Waley Zheng on 7/13/22.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    @EnvironmentObject var modelData: ModelData
    
    func fatigueLevelDisplay(fatigueLevel: Int) -> String {
        if (fatigueLevel > 100) {
            return "100"
        }
        return String(fatigueLevel)
    }
    
    var body: some View {
        HStack{
            ZStack{
                
                Circle()
                    .fill(DarkMode.isDarkMode() ? Color(white: 0.05) : .white)
                    .shadow(radius: 3)
                
                HStack{
                    Text(self.modelData.heartRate == 0 ? "--" : "\(self.modelData.heartRate)")
//                    Text("50")
                        .font(.system(size: 70, weight: .heavy))
                        .scaledToFill()
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .frame(width: 80, height: 55, alignment: .trailing)
                        .offset(x: 4, y: 0)
                    
                    VStack{
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("BPM")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                //            .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                //                .padding()
                //            .frame(width: 150, height: 200)
                //            .background(Circle().fill(Color.white).shadow(radius: 3))
            }
            .padding([.leading], 10)
            
            
            
            ZStack{
                
                Circle()
                    .fill(DarkMode.isDarkMode() ? Color(white: 0.05) : .white)
                    .shadow(radius: 3)
                
                VStack (spacing: 0){
                    HStack(alignment: .bottom, spacing: 3){
//                        Text("10")
                        Text(self.modelData.fatigueLevel < 0 ? "--" : self.fatigueLevelDisplay(fatigueLevel: self.modelData.fatigueLevel))
                            .font(.system(size: 60, weight: .heavy))
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .frame(width: 80, height: 55, alignment: .trailing)
                            .offset(x: 4, y: 0)
                        Text("%")
                            .font(.system(size: 20, weight: .semibold))
                            .offset(x: 0, y: -3)
                        
                    }
                    Text("Fatigue Level")
                        .font(.system(size: 15, weight: .semibold))
                    
                }
                //            .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                //                .padding()
                //            .frame(width: 150, height: 200)
                //            .background(Circle().fill(Color.white).shadow(radius: 3))
            }
            .padding([.trailing], 10)
            
            //            VStack{
            //                Text("\(self.modelData.fatigueLevel)%")
            //                    .font(.system(size: 50, weight: .heavy))
            //                Text("Fatigue Level")
            //                    .font(.system(size: 15))
            //            }
            //            .font(.system(size: 50, weight: .heavy))
            //            //            .fixedSize(horizontal: false, vertical: true)
            //            .multilineTextAlignment(.center)
            //            .padding()
            //            //            .frame(width: 200, height: 200)
            //            .background(Circle().fill(Color.white).shadow(radius: 3))
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
            .environmentObject(ModelData())
    }
}
