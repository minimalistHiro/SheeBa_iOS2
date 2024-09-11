//
//  EntryView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/11/27.
//

import SwiftUI

struct EntryView: View {
    
    @ObservedObject var vm: ViewModel
    @State private var isShowTutorialView = false               // チュートリアル表示有無
//    @State private var isShowConfirmStoreOwnerAlert = false     // 店舗オーナー確認アラート
    let didCompleteLoginProcess: () -> ()
    
    init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sheebaYellow.ignoresSafeArea(edges: .all)
                
                VStack {
                    Spacer()
                    Spacer()
                    
                    Image(String.title)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                    
                    Spacer()
                    
                    NavigationLink {
                        SetUpUsernameView(isStoreOwner: false, didCompleteLoginProcess: self.didCompleteLoginProcess)
                    } label: {
                        CustomCapsule(text: "アカウントを作成する",
                                      imageSystemName: nil,
                                      foregroundColor: .white,
                                      textColor: .black,
                                      isStroke: true)
                    }
                    .padding(.bottom)
                    
                    NavigationLink {
                        SetUpUsernameView(isStoreOwner: true, didCompleteLoginProcess: self.didCompleteLoginProcess)
                    } label: {
                        Text("店舗オーナー専用アカウントを作成する")
                            .dynamicTypeSize(.medium)
                            .foregroundStyle(.blue)
                    }
                    .padding(.bottom)
                    
                    NavigationLink {
                        LoginView(didCompleteLoginProcess: self.didCompleteLoginProcess)
                    } label: {
                        CustomCapsule(text: "ログイン",
                                      imageSystemName: nil,
                                      foregroundColor: .black,
                                      textColor: .white,
                                      isStroke: false)
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            isShowTutorialView = true
        }
//        .asDoubleTextAlert(title: "",
//                           isShowAlert: $isShowConfirmStoreOwnerAlert,
//                           message: "一般ユーザーとしてアカウントを作成しますか？",
//                           buttonText1: "一般ユーザー", 
//                           buttonText2: "店舗オーナー",
//                           didAction1: {
//            SetUpUsernameView(didCompleteLoginProcess: self.didCompleteLoginProcess)
//            isShowConfirmStoreOwnerAlert = false
//        }, didAction2: {
//            isShowConfirmStoreOwnerAlert = false
//        })
        .fullScreenCover(isPresented: $isShowTutorialView) {
            TutorialView {
                isShowTutorialView = false
            }
        }
    }
}

#Preview {
    EntryView(didCompleteLoginProcess: {})
}
