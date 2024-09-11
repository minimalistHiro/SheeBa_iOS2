//
//  DoubleTextAlertModifier.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/09/06.
//

import SwiftUI

struct DoubleTextAlertModifier: ViewModifier {
    
    let title: String
    @Binding var isShowAlert: Bool
    let message: String
    let buttonText1: String
    let buttonText2: String
    let didAction1: () -> ()
    let didAction2: () -> ()
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isShowAlert) {
                Button {
                    didAction1()
                } label: {
                    Text(buttonText1)
                }
                Button {
                    didAction2()
                } label: {
                    Text(buttonText2)
                }
            } message: {
                Text(message)
            }
    }
}
