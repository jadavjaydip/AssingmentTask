//
//  CustomTextFiledView.swift
//  AssignmentTask
//
//  Created by j on 18/09/36.
//

import Foundation
import SwiftUI

struct CustomTextFiledView: View {
    @State var placeholder: String = ""
    @Binding var text: String
    var body: some View {
        TextField(placeholder, text: $text)
            .frame(height: 50)
            .padding(.leading, 5)
            .background(
                RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
    }
}
