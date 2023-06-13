import SwiftUI

/// Single-select dropdown with in-line prompt text of width 320.
///
/// ### Example
/// ```
/// @State private var ddValue: Int = 1
/// SimpleDropdown(label: "Item 1",
///                 optionTexts: ["No", "Yes"],
///                 optionValues: [0, 1],
///                 value: $ddValue)
/// ```
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Apr 13, 2023
///
struct SimpleDropdown: View {

    /// Label text to be shown on top of the dropdown menu.
    var label: String
    
    /// Array of strings to be shown in the dropdown menu.
    var optionTexts: [String]
    
    /// Array of integers representing the value of each option
    var optionValues: [Int]
    
    /// Binding value; pass by reference. Default value must be between 1 (inclusive) and the number of items in `optionText` (inclusive).
    @Binding var value: Int

    /// Width of dropdown menu box. Default: 320
    let width: CGFloat = 360
    
    /// Height of dropdown menu box. Default: 80
    let height: CGFloat = 60

    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 24)
            Text(label)
                .frame(width: 110, alignment: .leading)
            Picker(label, selection: $value) {
                ForEach(optionTexts.indices) { index in
                    Text(optionTexts[index]).tag(optionValues[index])
                }
            }
            .frame(width: width-154, alignment: .trailing)
            Spacer()
                .frame(width: 20)
        }
        .frame(width: width, height: height)
        .background(DarkMode.isDarkMode() ? Color(white: 0.1) : Color(white: 0.9))
        .cornerRadius(12)
        .padding(.top, -4)
        .padding(.bottom, 4)
        
    }
}

