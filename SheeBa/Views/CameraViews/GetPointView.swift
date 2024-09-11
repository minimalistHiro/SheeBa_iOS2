//
//  GetPointView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/31.
//

import SwiftUI

struct GetPointView: View {
    
    @Environment(\.dismiss) var dismiss
    let chatUser: ChatUser?
    let getPoint: String
    @Binding var isSameStoreScanError: Bool
    @Binding var isQrCodeScanError: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // トップ画像
                if !isQrCodeScanError {
                    VStack {
                        if let image = chatUser?.profileImageUrl, image != "" {
                            Icon.CustomWebImage(imageSize: .large, image: image)
                        } else {
                            Icon.CustomCircle(imageSize: .large)
                        }
                        Text(chatUser?.username ?? "")
                            .font(.title2)
                            .bold()
                            .dynamicTypeSize(.medium)
                            .padding()
                    }
                }
                
                Spacer()
                
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
                
                Spacer()
                
                Button {
                    isSameStoreScanError = false
                    isQrCodeScanError = false
                    dismiss()
                } label: {
                    CustomCapsule(text: "戻る", imageSystemName: nil, foregroundColor: .black, textColor: .white, isStroke: false)
                }
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GetPointView(chatUser: nil, getPoint: "1", isSameStoreScanError: .constant(false), isQrCodeScanError: .constant(false))
}
