//
//  NotificationView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/11.
//

import SwiftUI

struct NotificationListView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var isShowDialog = false                     // ダイアログの表示有無
    @State private var dialogNotificationTitle = ""             // ダイアログに表示するお知らせのタイトル
    
    init() {
        vm.fetchNotifications()
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.notifications, id: \.self) { notification in
                    NavigationLink {
                        NotificationDetailView(notification: notification)
                    } label: {
                        ZStack(alignment: .leading) {
                            HStack(spacing: 16) {
                                if (notification.profileImageUrl != "") {
                                    Icon.CustomWebImage(imageSize: .medium, image: notification.profileImageUrl)
                                } else {
                                    Icon.CustomCircle(imageSize: .medium)
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(notification.title)
                                    
                                    Text(notification.username)
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                }
                                //                                .onLongPressGesture {
                                //                                    // オーナーアカウントのみダイアログを表示
                                //                                    if let currentUser = vm.currentUser, currentUser.isOwner {
                                //                                        dialogNotificationTitle = notification.title
                                //                                        isShowDialog = true
                                //                                    }
                                //                                }
                                
                            }
                            // 未読の場合、赤い印
                            if !notification.isRead {
                                HStack {
                                    Spacer()
                                    Circle()
                                        .frame(width: 15, height: 15)
                                        .foregroundStyle(.red)
                                        .padding(.trailing, 10)
                                }
                            }
                        }
                    }
                }
//                if let currentUser = vm.currentUser, currentUser.isOwner, currentUser.isStoreOwner {
//                    NavigationLink {
//                        CreateNotificationView()
//                    } label: {
//                        Text("+ お知らせを作成")
//                            .bold()
//                            .foregroundStyle(.blue)
//                    }
//                }
                Spacer()
                    .listRowSeparator(.hidden)
            }
            .listStyle(.inset)
            .environment(\.defaultMinListRowHeight, 60)
            .navigationTitle("お知らせ")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
        }
        .asBackButton()
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
//                vm.fetchNotifications()
            }
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.alertMessage,
                       didAction: { vm.isShowError = false })
    }
}

#Preview {
    NotificationListView()
}
