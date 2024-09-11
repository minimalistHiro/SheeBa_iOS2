//
//  HomeView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    
    @ObservedObject var vm = ViewModel()
    @ObservedObject var userSetting = UserSetting()
    @State private var isShowQRCodeView = false             // QRCodeView表示有無
    @State private var isShowSignOutAlert = false           // 強制サインアウトアラート
    @State private var isContainNotReadNotification = false // 未読のお知らせの有無
    
    @Binding var isUserCurrentryLoggedOut: Bool
    
//    init(isUserCurrentryLoggedOut: Binding<Bool>) {
//        self._isUserCurrentryLoggedOut = isUserCurrentryLoggedOut
//        if let isStore = vm.currentUser?.isStore, isStore {
//            self.isStore = true
//        }
//        vm.isUserCurrentryLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
//    }
    
    var body: some View {
        NavigationStack {
            if let isStore = vm.currentUser?.isStore, isStore {
                StoreQRCodeView(isUserCurrentryLoggedOut: $isUserCurrentryLoggedOut)
            } else {
                ScrollView {
                    LazyVStack {
                        titleView
                        if let _ = vm.alertNotification {
                            notificationView
                        }
                        cardView
                            .padding(.top, 10)
                        menuButtons
                            .padding(.top, 10)
                        // TODO: - 第2弾
//                        advertisements
                    }
                }
                // TODO: - 第2弾
                //                .overlay {
                //                    qrCodeButton
                //                }
            }
        }
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                if let isStore = vm.currentUser?.isStore, isStore {
                    // 何も取得しない
                } else {
                    vm.fetchCurrentUser()
                    vm.fetchRecentMessages()
                    vm.fetchFriends()
                    vm.fetchStorePoints()
                    vm.fetchAlerts()
                    fetchNotificationsAndSearchNotRead()
                    vm.fetchAdvertisements()
                }
            } else {
                isUserCurrentryLoggedOut = true
            }
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowAlert,
                       message: vm.alertMessage,
                       didAction: { vm.isShowAlert = false })
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
            isShowSignOutAlert = false
            handleSignOut()
        })
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowNotConfirmEmailError,
                       message: "メールアドレスの認証を完了してください",
                       didAction: {
            DispatchQueue.main.async {
                vm.isNavigateNotConfirmEmailView = true
            }
        })
        .fullScreenCover(isPresented: $isUserCurrentryLoggedOut) {
            EntryView {
                isUserCurrentryLoggedOut = false
                vm.fetchCurrentUser()
                vm.fetchRecentMessages()
                vm.fetchFriends()
                vm.fetchStorePoints()
                fetchNotificationsAndSearchNotRead()
            }
        }
        // TODO: - fullScrrenCover同士がバッティングするとうまく表示されない。
//        .fullScreenCover(isPresented: $isShowQRCodeView) {
//            QRCodeView()
//        }
        .fullScreenCover(isPresented: $vm.isNavigateNotConfirmEmailView) {
            NotConfirmEmailView {
                vm.isNavigateNotConfirmEmailView = false
            }
        }
    }
    
    // MARK: - notificationView
    private var notificationView: some View {
        Rectangle()
            .frame(height: 40)
            .foregroundStyle(Color.blue)
            .overlay {
                VStack {
                    Text(vm.alertNotification?.title ?? "")
                        .foregroundStyle(Color.white)
                        .font(.caption)
                        .bold()
                    Text(vm.alertNotification?.text ?? "")
                        .foregroundStyle(Color.white)
                        .font(.caption)
                }
            }
    }
    
    // MARK: - titleView
    private var titleView: some View {
        HStack {
            Image(String.clearTitle)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .padding(.horizontal)
                .padding(.top, 10)
            
            Spacer()
            
            NavigationLink {
                NotificationListView()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundStyle(.black)
                    .padding()
                    
                    if isContainNotReadNotification {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(.red)
                            .padding(.trailing, 10)
                            .padding(.top, 10)
                    }
                }
            }
        }
    }
    
    // MARK: - cardView
    private var cardView: some View {
        Rectangle()
            .foregroundColor(Color.sheebaYellow)
            .frame(width: 300, height: 200)
            .cornerRadius(20)
            .shadow(radius: 7, x: 0, y: 0)
            .overlay {
                VStack {
                    Spacer()
                    Text("獲得ポイント")
                    Spacer()
                    HStack {
                        Spacer()
                        
                        if userSetting.isShowPoint {
                            Spacer()
                            
                            if vm.onIndicator {
                                Indicator(onIndicator: $vm.onIndicator)
                                    .scaleEffect(2)
                            } else {
                                Text(String(vm.currentUser?.money ?? "Error"))
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                if let _ = vm.currentUser?.money {
                                    Text("pt")
                                        .bold()
                                }
                            }
                            
                            Spacer()
                            
                            if !vm.onIndicator {
                                Button {
                                    vm.fetchCurrentUser()
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15)
                                        .foregroundStyle(.black)
                                }
                            }
                            
                        } else {
                            Text("******")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                        }
                        
                        Spacer()
                    }
                    Spacer()
                    Spacer()
                }
            }
            .padding(.horizontal)
    }
    
    // MARK: - buttons
    private var menuButtons: some View {
        ZStack {
            Rectangle()
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .foregroundColor(Color.sheebaDarkGreen)
                .frame(width: UIScreen.main.bounds.width, height: 70)
            
            HStack {
                // QRコードボタン
//                if let currentUser = vm.currentUser, currentUser.isOwner {
                    NavigationLink {
                        QRCodeView()
                    } label: {
                        MenuButton(imageSystemName: "qrcode", text: "QRコード")
                    }
                    .foregroundColor(.white)
//                }
                
                // TODO: - 第二弾
                // 送るボタン
                NavigationLink {
                    MoneyTransferView()
                } label: {
                    MenuButton(imageSystemName: "yensign.circle", text: "送る")
                }
                .foregroundColor(.white)
                
                // ランキングボタン
                NavigationLink {
                    RankingView(currentUser: vm.currentUser ?? nil)
                } label: {
                    MenuButton(imageSystemName: "trophy", text: "ランキング")
                }
                .foregroundColor(.white)
                
                // 本日の獲得ボタン
                NavigationLink {
                    TodaysGetPointView()
                } label: {
                    MenuButton(imageSystemName: "storefront", text: "本日の獲得")
                }
                .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - advertisements
//    private var advertisements: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(vm.advertisements, id: \.self) { advertisement in
//                    NavigationLink {
//                        AdvertisementDetailView(advertisement: advertisement)
//                    } label: {
//                        if advertisement.imageUrl != "" {
//                            WebImage(url: URL(string: advertisement.imageUrl))
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 150, height: 150)
//                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 7, height: 7)))
//                        } else {
//                            RoundedRectangle(cornerSize: CGSize(width: 7, height: 7))
//                                .frame(width: 150, height: 150)
//                                .foregroundStyle(Color(String.chatLogBackground))
//                                .overlay {
//                                    Image(systemName: "photo")
//                                        .font(.system(size: 30))
//                                        .foregroundColor(.black)
//                                }
//                        }
//                    }
//                }
//                if let currentUser = vm.currentUser, currentUser.isOwner {
//                    NavigationLink {
//                        CreateAdvertisementView()
//                    } label: {
//                        RoundedRectangle(cornerSize: CGSize(width: 7, height: 7))
//                            .frame(width: 150, height: 150)
//                            .foregroundStyle(Color.white)
//                            .overlay {
//                                Image(systemName: "plus")
//                                    .font(.system(size: 30))
//                                    .bold()
//                            }
//                    }
//                }
//            }
//        }
//        .padding()
//    }
    
    // MARK: - qrCodeButton
    private var qrCodeButton: some View {
        VStack {
            Spacer()
            Button {
                isShowQRCodeView = true
            } label: {
                CustomCapsule(text: "QRコードで送る",
                              imageSystemName: "qrcode",
                              foregroundColor: .black,
                              textColor: .white,
                              isStroke: false)
            }
        }
        .padding(.bottom)
    }
    
    // MARK: - MenuButton
    struct MenuButton: View {
        let imageSystemName: String
        let text: String
        
        var body: some View {
            VStack {
                Image(systemName: imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .padding(.bottom, 2)
                Text(text)
                    .font(.caption2)
                    .bold()
            }
            .padding()
        }
    }
    
    // MARK: - 全お知らせを取得して未読の有無を確認
    /// - Parameters: なし
    /// - Returns: なし
    func fetchNotificationsAndSearchNotRead() {
        isContainNotReadNotification = false
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.notifications)
            .document(uid)
            .collection(FirebaseConstants.notification)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    print("全お知らせの取得に失敗しました。")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let notification = NotificationModel(data: data)
                    
                    // 未読があった場合
                    if !notification.isRead {
                        
                        isContainNotReadNotification = true
                    }
                })
            }
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
    HomeView(isUserCurrentryLoggedOut: .constant(false))
}
