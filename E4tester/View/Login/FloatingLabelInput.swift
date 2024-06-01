//
//  FloatingLabelInput.swift
//  E4tester
//
//  Created by Waley Zheng on 7/20/22.
//  Modified by Seung-Gu Lee on 5/16/23.
//  Copyright © 2022 Felipe Castro. All rights reserved.
//

import SwiftUI

struct FloatingLabelInput: View {
    var label: String
    @Binding var text: String
    var numberPad: Bool = false
    var isSecure: Bool = false
    
    init(label: String, text: Binding<String>, numberPad: Bool, isSecure: Bool) {
        self.label = label
        self._text = text
        self.numberPad = numberPad
        self.isSecure = isSecure
    }
    
    init(label: String, text: Binding<String>) {
        self.label = label
        self._text = text
        self.numberPad = false
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(self.label)
                .foregroundColor(self.text.isEmpty ? Color.gray : Color.gray.opacity(0.5))
                .offset(x: 0,
                        y: self.text.isEmpty ? 0 : -20)
                .scaleEffect(self.text.isEmpty ? 1 : 0.6, anchor: .topLeading)
                .animation(.easeIn(duration: 0.1))
            if !isSecure {
                TextField("", text: self.$text)
                    .font(Font.headline.weight(.medium))
                    .keyboardType(numberPad ? .numberPad : .default)
                    .offset(x: 0,
                            y: self.text.isEmpty ? 0 : 3)
            } else {
                SecureField("", text: self.$text)
                    .font(Font.headline.weight(.medium))
                    .keyboardType(numberPad ? .numberPad : .default)
                    .offset(x: 0,
                            y: self.text.isEmpty ? 0 : 3)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(width: 330, height: 60)
        .background(DarkMode.isDarkMode() ? Color(white: 0.1) : .white)
        .cornerRadius(10.0)
        .shadow(color:Color.black.opacity(0.08), radius: 60)
    }
}

