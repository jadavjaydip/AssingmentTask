//
//  FiledView.swift
//  AssignmentTask
//
//  Created by j on 18/09/36.
//

import Foundation
import SwiftUI

struct FiledView: View {
    var title: String = ""
    @Binding var text:String
    var isPasswordFiled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundColor(Color.gray)
            if !(isPasswordFiled) {
                TextField("", text: $text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .frame(height: 40)
            }else {
                SecureField("", text: $text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .frame(height: 40)
            }
            
        }
    }
}
