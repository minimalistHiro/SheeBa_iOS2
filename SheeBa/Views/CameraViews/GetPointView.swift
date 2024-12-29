//
//  GetPointView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/31.
//

import SwiftUI

struct GetPointView: View {
    
    @Environment(\.dismiss) var dismiss
//    let chatUser: ChatUser?
    let store: Stores?
    let getPoint: String
    @State var degree: Double = 100
    @State private var isAnimating = false
    @Binding var isSameStoreScanError: Bool
    @Binding var isQrCodeScanError: Bool
    @Binding var isEventStoreScanError: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // トップ画像
                if !isQrCodeScanError {
                    VStack {
                        if let image = store?.profileImageUrl, image != "" {
                            Icon.CustomWebImage(imageSize: .large, image: image)
                                .rotation3DEffect(.init(degrees: degree),
                                                  axis: (x: 0.0, y: 1.0, z: -0.2))
                                .animation(.interpolatingSpring(
                                    mass: 0.2, stiffness: 6, damping: 0.5, initialVelocity: 30), value: isAnimating)
                                .onAppear {
                                    self.degree = 0
                                    if !isSameStoreScanError && !isQrCodeScanError && !isEventStoreScanError {
                                        self.isAnimating = true
                                    }
                                }
                        } else {
                            Icon.CustomCircle(imageSize: .large)
                        }
                        Text(store?.storename ?? "")
                            .font(.title2)
                            .bold()
                            .dynamicTypeSize(.medium)
                            .padding()
                    }
                }
                
                Spacer()
                
                // Sheeba画像
                if isQrCodeScanError {
                    Image("Greeting")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                }
                
                if isSameStoreScanError {
                    Text("1店舗につき1日1回のみポイントが貰えます。")
                        .bold()
                        .dynamicTypeSize(.medium)
                        .padding()
                } else if isQrCodeScanError {
                    Text("誤ったQRコードがスキャンされました。")
                        .bold()
                        .dynamicTypeSize(.medium)
                        .padding()
                } else if isEventStoreScanError {
                    Text("このバッジは既に獲得済みです。")
                        .bold()
                        .dynamicTypeSize(.medium)
                        .padding()
                } else {
                    if store?.isEvent == true {
                        Text("ハロウィンスタンプ")
                            .font(.system(size: 30))
                            .bold()
                            .dynamicTypeSize(.medium)
                        Text("ゲット!")
                            .font(.system(size: 30))
                            .bold()
                            .dynamicTypeSize(.medium)
                    } else {
                        HStack {
                            Text(getPoint)
                                .font(.system(size: 70))
                                .bold()
                                .dynamicTypeSize(.medium)
                            Text("pt")
                                .font(.title)
                                .dynamicTypeSize(.medium)
                        }
                        
                        Text("ゲット!")
                            .font(.system(size: 30))
                            .bold()
                            .dynamicTypeSize(.medium)
                    }
                }
                
                Spacer()
                
                Button {
                    isSameStoreScanError = false
                    isQrCodeScanError = false
                    isEventStoreScanError = false
                    dismiss()
                } label: {
                    CustomCapsule(text: "戻る", imageSystemName: nil, foregroundColor: .black, textColor: .white, isStroke: false)
                }
                
                Spacer()
                Spacer()
            }
            .background(store?.isEvent == true ? Color.orange : Color.white)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GetPointView(store: nil, getPoint: "1", isSameStoreScanError: .constant(false), isQrCodeScanError: .constant(false), isEventStoreScanError: .constant(false))
}
