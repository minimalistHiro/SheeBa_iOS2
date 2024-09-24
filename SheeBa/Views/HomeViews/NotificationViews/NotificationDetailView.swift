//
//  NotificationDetailView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/14.
//

import SwiftUI
import SDWebImageSwiftUI

struct NotificationDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @ObservedObject var userSetting = UserSetting()
    @State private var isShowDeleteNotificationAlert = false            // お知らせ削除アラート
    @State private var isShowDeleteSuccessAlert = false                 // お知らせ削除成功アラート
    let notification: NotificationModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(notification.title)
                    .font(.title3)
                    .bold()
                    .padding(.bottom)
                
//                Text(notification.username)
//                    .font(.headline)
//                    .padding(.horizontal)
//                    .padding(.bottom)
                
                Text("\(vm.dateFormat(notification.timestamp.dateValue())) \(vm.hourFormat(notification.timestamp.dateValue()))")
                    .padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.bottom)
                
                Text(notification.text)
                    .padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                
                Button {
                    UIApplication.shared.open(URL(string: notification.url)!)
                } label: {
                    Text(notification.url)
                        .padding(.horizontal)
                        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                        .foregroundStyle(Color.blue)
                }
                
                if notification.imageUrl != "" {
                    WebImage(url: URL(string: notification.imageUrl))
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .padding(.bottom)
                }
                
                // 下部に空白を作るため
                Text("")
                    .frame(height: 100)
            }
            .overlay {
                if let currentUser = vm.currentUser {
                    // オーナー、もしくは自身が作成した店舗オーナー
                    if currentUser.isOwner || (currentUser.isStoreOwner && notification.uid == vm.currentUser?.uid)  {
                        VStack {
                            Spacer()
                            Button {
                                isShowDeleteNotificationAlert = true
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
        }
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
                vm.fetchAllUsersContainSelf()
            }
            updateNotification()
            
            // 未読の場合、通知バッジを一つ減らす
            if !notification.isRead {
                userSetting.badgeCount -= 1
                UIApplication.shared.applicationIconBadgeNumber = userSetting.badgeCount
            }
        }
        .navigationTitle(notification.username)
        .navigationBarTitleDisplayMode(.inline)
        .asBackButton()
        .asDestructiveAlert(title: "",
                            isShowAlert: $isShowDeleteNotificationAlert,
                            message: "このお知らせを削除しますか？",
                            buttonText: "削除", didAction: {
            deleteNotification()
            isShowDeleteSuccessAlert = true
        })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowDeleteSuccessAlert,
                       message: "削除しました。", didAction: {
            dismiss()
        })
    }
    
    // MARK: - お知らせを更新
    /// - Parameters: なし
    /// - Returns: なし
    private func updateNotification() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let data = [FirebaseConstants.isRead: true,]
        vm.updateNotification(document1: uid, document2: notification.title, data: data)
    }
    
    // MARK: - お知らせを削除
    /// - Parameters: なし
    /// - Returns: なし
    private func deleteNotification() {
        // 全ユーザーのお知らせを削除
        for user in vm.allUsersContainSelf {
            vm.deleteNotification(document1: user.uid, document2: notification.title)
        }
        // 画像の削除
        vm.deleteImage(withPath: notification.title)
    }
}

#Preview {
    NotificationDetailView(notification: previewOfNotificationModel)
}
