//
//  QRCodeView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/09.
//

import SwiftUI

struct QRCodeView: View {
    
    @ObservedObject var vm = ViewModel()
    private let brightness: CGFloat = UIScreen.main.brightness      // 画面遷移前の画面輝度を保持
    @State private var qrCodeImage: UIImage?
    
    init() {
        if FirebaseManager.shared.auth.currentUser?.uid != nil {
            vm.fetchCurrentUser()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: 300, height: 400)
                    .cornerRadius(20)
                    .shadow(radius: 7, x: 0, y: 0)
                    .overlay {
                        VStack {
                            Spacer()
                            
                            HStack(spacing: 15) {
                                if let image = vm.currentUser?.profileImageUrl, image != "" {
                                    Icon.CustomWebImage(imageSize: .medium, image: image)
                                } else {
                                    Icon.CustomCircle(imageSize: .medium)
                                }
                                Text(vm.currentUser?.username ?? "")
                                    .font(.title3)
                                    .bold()
                            }
                            
                            Spacer()
                            
                            if vm.onIndicator {
                                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
                            } else {
                                if let qrCodeImage {
                                    Image(uiImage: qrCodeImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                } else {
                                    VStack {
                                        Text("データを読み込めませんでした。")
                                            .font(.callout)
                                        Button {
                                            qrCodeImage = vm.generateQRCode(inputText: vm.currentUser?.uid ?? "")
                                        } label: {
                                            Image(systemName: "arrow.clockwise")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20)
                                        }
                                    }
                                    .frame(width: 200, height: 200)
                                }
                            }
                            
                            Spacer()
                            Spacer()
                        }
                    }
                
                Spacer()
                Spacer()
                Spacer()
            }
        }
        .asBackButton()
        .onAppear {
            UIScreen.main.brightness = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.qrCodeImage = vm.generateQRCode(inputText: vm.currentUser?.uid ?? "")
            }
        }
        .onDisappear {
            UIScreen.main.brightness = brightness
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowAlert,
                       message: vm.alertMessage,
                       didAction: { vm.isShowAlert = false })
    }
}

#Preview {
    QRCodeView()
}
