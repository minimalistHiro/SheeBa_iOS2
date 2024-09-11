//
//  AccountView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import SwiftUI
import SDWebImageSwiftUI

struct AccountView: View {
    
    @ObservedObject var vm = ViewModel()
    @ObservedObject var userSetting = UserSetting()
    @State private var externalLink: ExternalLink = .officialSite
    @State private var isShowOpenExternalLinkAlert = false              // 外部リンク表示確認アラート
    @State private var isShowConfirmationSignOutAlert = false           // サインアウト確認アラート
    @State private var isShowConfirmationWithdrawalAlert = false        // 退会確認アラート
    @State private var isShowSuccessWithdrawalAlert = false             // 退会成功アラート
    @State private var isShowSignOutAlert = false                       // 強制サインアウトアラート
    
    @Binding var isUserCurrentryLoggedOut: Bool
    
    enum ExternalLink {
        case officialSite
        case privacyPolicy
    }
//    init() {
//        vm.isUserCurrentryLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
//        if FirebaseManager.shared.auth.currentUser?.uid != nil {
//            vm.fetchCurrentUser()
//            vm.fetchRecentMessages()
//            vm.fetchFriends()
//        }
//    }
    
    var body: some View {
        NavigationStack {
//            HStack {
                Spacer()
                Spacer()
                
                Rectangle()
                    .foregroundColor(Color.sheebaYellow)
                    .frame(width: 300, height: 200)
                    .cornerRadius(20)
                    .shadow(radius: 7, x: 0, y: 0)
                    .overlay {
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                // トップ画像
                                NavigationLink {
                                    UpdateImageView()
                                } label: {
                                    if let image = vm.currentUser?.profileImageUrl, image != "" {
                                        Icon.CustomWebImage(imageSize: .large, image: image)
                                            .overlay {
                                                Icon.CustomImageChangeCircle(imageSize: .large)
                                            }
    //                                        .padding(.top, 20)
                                    } else {
                                        Icon.CustomCircle(imageSize: .large)
                                            .overlay {
                                                Icon.CustomImageChangeCircle(imageSize: .large)
                                            }
    //                                        .padding(.top, 20)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(vm.currentUser?.username ?? "しば太郎")
                                    .font(.title3)
                                    .bold()
                                    .dynamicTypeSize(.medium)
                                    .padding()
                                
                                Spacer()
                            }
                            Spacer()
                            
                            Text("しばID : " + (vm.currentUser?.id ?? ""))
                                .font(.caption)
                                .dynamicTypeSize(.medium)
                            
                            Spacer()
                        }
                    }
            Text("設定")
                .font(.callout)
                .bold()
                .dynamicTypeSize(.medium)
                .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                .padding(.leading, 50)
                .padding(.top)
            
            List {
                if let currentUser = vm.currentUser, currentUser.isOwner || currentUser.isStoreOwner {
                    // 店舗お知らせを作成
                    NavigationLink {
                        CreateNotificationView()
                    } label: {
                        HStack {
                            Text("店舗お知らせを作成")
                                .foregroundStyle(.blue)
                                .dynamicTypeSize(.medium)
                            Spacer()
                        }
                    }
                }
                
                // ユーザー名を変更
                NavigationLink {
                    UpdateUsernameView(username: vm.currentUser?.username ?? "")
                } label: {
                    HStack {
                        Text("ユーザー名を変更")
                            .foregroundStyle(.black)
                        Spacer()
                        Text(vm.currentUser?.username ?? "")
                            .foregroundStyle(.gray)
                            .font(.caption2)
                    }
                }
                
                if let currentUser = vm.currentUser, currentUser.isOwner {
                    // ユーザー属性分析
                    NavigationLink {
                        UserAttributeView()
                    } label: {
                        HStack {
                            Text("ユーザー属性分析")
                                .dynamicTypeSize(.medium)
                            Spacer()
                        }
                    }
                }
                
                if let currentUser = vm.currentUser, currentUser.isOwner {
                    // 店舗管理
                    NavigationLink {
                        StoreInfoListView()
                    } label: {
                        HStack {
                            Text("店舗管理")
                                .dynamicTypeSize(.medium)
                            Spacer()
                        }
                    }
                }
                
                // 残高表示
                Toggle(isOn: $userSetting.isShowPoint, label: {
                    Text("ポイントを表示する")
                })
                
                // 公式サイト
                Button {
                    externalLink = .officialSite
                    isShowOpenExternalLinkAlert = true
                } label: {
                    Text("公式サイト")
                        .foregroundColor(.black)
                }
                
                // プライバシーポリシー
                Button {
                    externalLink = .privacyPolicy
                    isShowOpenExternalLinkAlert = true
                } label: {
                    Text("プライバシーポリシー")
                        .foregroundColor(.black)
                }
                
                // ログアウト
                Button {
                    isShowConfirmationSignOutAlert = true
                } label: {
                    Text("ログアウト")
                        .foregroundColor(.red)
                }
                
                // 退会
                Button {
                    isShowConfirmationWithdrawalAlert = true
                } label: {
                    Text("退会する")
                        .foregroundColor(.red)
                }
            }
            .padding(.leading, 10)
            .listStyle(.inset)
            .environment(\.defaultMinListRowHeight, 60)
        }
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
                vm.fetchFriends()
                vm.fetchNotifications()
                vm.fetchStorePoints()
            } else {
                isUserCurrentryLoggedOut = true
            }
        }
        .asDoubleAlert(title: "",
                       isShowAlert: $isShowOpenExternalLinkAlert,
                       message: String.jumpToExternalLink,
                       buttonText: "はい",
                       didAction: {
            DispatchQueue.main.async {
                isShowOpenExternalLinkAlert = false
            }
            switch externalLink {
            case .officialSite:
                UIApplication.shared.open(URL(string: Setting.officialSiteURL)!)
            case .privacyPolicy:
                UIApplication.shared.open(URL(string: Setting.privacyPolicyURL)!)
            }
        })
        .asDestructiveAlert(title: "",
                            isShowAlert: $isShowConfirmationSignOutAlert,
                            message: "ログアウトしますか？",
                            buttonText: "ログアウト",
                            didAction: {
            DispatchQueue.main.async {
                isShowConfirmationSignOutAlert = false
            }
            handleSignOut()
        })
        .asDestructiveAlert(title: "",
                            isShowAlert: $isShowConfirmationWithdrawalAlert,
                            message: "退会しますか？",
                            buttonText: "退会",
                            didAction: {
            handleWithdrawal()
            //            DispatchQueue.main.async {
            //                isShowConfirmationWithdrawalAlert = false
            //            }
//                        isShowSuccessWithdrawalAlert = true
        })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowSuccessWithdrawalAlert,
                       message: "ご利用ありがとうございました。",
                       didAction: {
            DispatchQueue.main.async {
                isShowSuccessWithdrawalAlert = false
            }
            handleSignOut()
        })
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: {
            DispatchQueue.main.async {
                vm.isShowError = false
            }
            isShowSignOutAlert = true
        })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowSignOutAlert,
                       message: "エラーが発生したためログアウトします。",
                       didAction: {
            DispatchQueue.main.async {
                isShowSignOutAlert = false
            }
            handleSignOut()
        })
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowNotConfirmEmailError,
                       message: "メールアドレスの認証を完了してください",
                       didAction: {
            vm.isNavigateNotConfirmEmailView = true
        })
        .fullScreenCover(isPresented: $isUserCurrentryLoggedOut) {
            EntryView {
                isUserCurrentryLoggedOut = false
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
                vm.fetchFriends()
                vm.fetchStorePoints()
            }
        }
        .fullScreenCover(isPresented: $vm.isNavigateNotConfirmEmailView) {
            NotConfirmEmailView {
                vm.isNavigateNotConfirmEmailView = false
            }
        }
    }
    
    // MARK: - 退会処理
    /// - Parameters: なし
    /// - Returns: なし
    private func handleWithdrawal() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        // 認証情報削除
        vm.deleteAuth()
        
        // ユーザー情報削除
        vm.deleteUser(document: uid)
        
        // メッセージを削除
        for recentMessage in vm.recentMessages {
            vm.deleteMessage(document: uid, collection: FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId)
        }
        
        // 最新メッセージを削除
        for recentMessage in vm.recentMessages {
            vm.deleteRecentMessage(document1: uid, document2: FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId)
        }
        
        // 友達を削除
        for friend in vm.friends {
            vm.deleteFriend(document1: uid, document2: friend.uid)
        }
        
        // 店舗ポイント情報を削除
        for storePoint in vm.storePoints {
            vm.deleteStorePoint(document1: uid, document2: storePoint.uid)
        }
        
        // お知らせを削除
        for notification in vm.notifications {
            vm.deleteNotification(document1: uid, document2: notification.title)
        }
        
        // 画像削除
        vm.deleteImage(withPath: uid)
        
        isShowConfirmationWithdrawalAlert = false
        isShowSuccessWithdrawalAlert = true
    }
    
    // MARK: - サインアウト
    /// - Parameters: なし
    /// - Returns: なし
    private func handleSignOut() {
        isUserCurrentryLoggedOut = true
        try? FirebaseManager.shared.auth.signOut()
    }
}

#Preview {
    AccountView(isUserCurrentryLoggedOut: .constant(false))
}
