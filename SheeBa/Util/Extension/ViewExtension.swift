//
//  ViewExtension.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/15.
//

import SwiftUI

extension View {
    func asBackButton() -> some View {
        modifier(BackButtonModifier())
    }
    
    func asCloseButton() -> some View {
        modifier(CloseButtonModifier())
    }
    
    func asAlertBackButton(didAction: @escaping () -> ()) -> some View {
        modifier(AlertBackButtonModifier(didAction: didAction))
    }
    
    func asSingleAlert(title: String, isShowAlert: Binding<Bool>, message: String, didAction: @escaping () -> ()) -> some View {
        modifier(SingleAlertModifier(title: title, isShowAlert: isShowAlert, message: message, didAction: didAction))
    }
    
    func asDoubleAlert(title: String, isShowAlert: Binding<Bool>, message: String, buttonText: String, didAction: @escaping () -> ()) -> some View {
        modifier(DoubleAlertModifier(title: title, isShowAlert: isShowAlert, message: message, buttonText: buttonText, didAction: didAction))
    }
    
    func asDoubleTextAlert(title: String, isShowAlert: Binding<Bool>, message: String, buttonText1: String, buttonText2: String, didAction1: @escaping () -> (), didAction2: @escaping () -> ()) -> some View {
        modifier(DoubleTextAlertModifier(title: title, isShowAlert: isShowAlert, message: message, buttonText1: buttonText1, buttonText2: buttonText2, didAction1: didAction1, didAction2: didAction2))
    }
    
    func asDestructiveAlert(title: String, isShowAlert: Binding<Bool>, message: String, buttonText: String, didAction: @escaping () -> ()) -> some View {
        modifier(DestructiveAlertModifier(title: title, isShowAlert: isShowAlert, message: message, buttonText: buttonText, didAction: didAction))
    }
    
    func asTripleAlert(title: String, isShowAlert: Binding<Bool>, message: String, buttonText: String, destructiveButtonText: String, didAction: @escaping () -> (), didDestructiveAction: @escaping () -> ()) -> some View {
        modifier(TripleAlertModifier(title: title, isShowAlert: isShowAlert, message: message, buttonText: buttonText, destructiveButtonText: destructiveButtonText, didAction: didAction, didDestructiveAction: didDestructiveAction))
    }
}
