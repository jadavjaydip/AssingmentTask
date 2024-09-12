//
//  OTPView.swift
//  AssignmentTask
//
//  Created by j on 18/09/36.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
public struct OtpView:View {
    
    private var activeIndicatorColor: Color
    private var inactiveIndicatorColor: Color
    private let doSomething: (String) -> Void
    private let length: Int
    
    @Binding private var otpText: String
    @FocusState private var isKeyboardShowing: Bool
    
    public init(otpText: Binding<String>,activeIndicatorColor:Color,inactiveIndicatorColor:Color, length:Int, doSomething: @escaping (String) -> Void) {
        self._otpText = otpText
        self.activeIndicatorColor = activeIndicatorColor
        self.inactiveIndicatorColor = inactiveIndicatorColor
        self.length = length
        self.doSomething = doSomething
    }
    public var body: some View {
        HStack(spacing: 0){
            ForEach(0...length-1, id: \.self) { index in
                OTPTextBox(index)
            }
        }.background(content: {
            SecureField("", text: $otpText.limit(6))
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($isKeyboardShowing)
                .onChange(of: otpText, perform: { newValue in
                    if newValue.count == length {
                        isKeyboardShowing = false
                        doSomething(newValue)
                    }
                })
                .onAppear {
                    DispatchQueue.main.async {
                        isKeyboardShowing = true
                    }
                }
        })
        .contentShape(Rectangle())
        .onTapGesture {
            isKeyboardShowing = true
        }
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack{
            if otpText.count > index {
                let startIndex = otpText.startIndex
                let charIndex = otpText.index(startIndex, offsetBy: index)
                let charToString = String(otpText[charIndex])
                Text(charToString)
            } else {
                Text(" ")
            }
        }
        .frame(width: 45, height: 45)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke((isKeyboardShowing && otpText.count == index) ? activeIndicatorColor : inactiveIndicatorColor, lineWidth: 1)
        )
        .padding(5)
    }
}

@available(iOS 13.0, *)
extension Binding where Value == String {
    func limit(_ length: Int)->Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}
