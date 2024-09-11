//
//  AdvertisementDetailView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct AdvertisementDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var isShowDeleteAdvertisementAlert = false           //  広告削除アラート
    @State private var isShowDeleteSuccessAlert = false                 // 広告削除成功アラート
    let advertisement: Advertisement
    
    var body: some View {
        NavigationStack {
            ScrollView {
//                Text(adverti.title)
//                    .font(.title3)
//                    .bold()
//                    .padding(.bottom)
//                Text("\(vm.dateFormat(notification.timestamp)) \(vm.hourFormat(notification.timestamp))")
//                    .font(.caption)
//                    .foregroundStyle(.gray)
//                    .padding(.bottom)
                if advertisement.imageUrl != "" {
                    WebImage(url: URL(string: advertisement.imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 200)
                        .clipShape(Rectangle())
                        .padding()
                        .padding(.bottom)
                }
                
                Text(advertisement.text)
                    .padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                
                Button {
                    UIApplication.shared.open(URL(string: advertisement.url)!)
                } label: {
                    Text(advertisement.url)
                        .padding(.horizontal)
                        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                        .foregroundStyle(Color.blue)
                }
                
                // 下部に空白を作るため
                Text("")
                    .frame(height: 100)
            }
            .overlay {
                if let currentUser = vm.currentUser, currentUser.isOwner {
                    VStack {
                        Spacer()
                        Button {
                            isShowDeleteAdvertisementAlert = true
                        } label: {
                            CustomCapsule(text: "削除",
                                          imageSystemName: nil,
                                          foregroundColor: .red,
                                          textColor: .white,
                                          isStroke: false)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
            }
        }
        .navigationTitle(advertisement.title)
        .navigationBarTitleDisplayMode(.inline)
        .asBackButton()
        .asDestructiveAlert(title: "",
                            isShowAlert: $isShowDeleteAdvertisementAlert,
                            message: "この広告を削除しますか？",
                            buttonText: "削除", didAction: {
            deleteAdvertisement()
            isShowDeleteSuccessAlert = true
        })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowDeleteSuccessAlert,
                       message: "削除しました。", didAction: {
            dismiss()
        })
    }
    
    // MARK: - 広告を削除
    /// - Parameters: なし
    /// - Returns: なし
    private func deleteAdvertisement() {
        // 広告を削除
        vm.deleteAdvertisement(document: advertisement.title)
        // 画像の削除
        vm.deleteImage(withPath: advertisement.title)
    }
}

#Preview {
    AdvertisementDetailView(advertisement: previewOfAdvertisement)
}
