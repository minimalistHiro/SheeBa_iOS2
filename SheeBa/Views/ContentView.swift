//
//  ContentView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var selectedTab = 1                      // 選択されたタブ
    @State private var notificationBadgeCount = 0           // お知らせ通知バッジカウント
    @State private var isUserCurrentryLoggedOut = false     // ユーザーのログインの有無
    
    init() {
        isUserCurrentryLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
//        if FirebaseManager.shared.auth.currentUser?.uid != nil {
//            vm.fetchCurrentUser()
//            vm.fetchRecentMessages()
//        }
        // バッジ
//        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (granted, err) in
//        }
//        
//        let application = UIApplication.shared
//        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                HomeView(isUserCurrentryLoggedOut: $isUserCurrentryLoggedOut)
                    .tabItem {
                        Label("ホーム", systemImage: "house")
                    }
                    .tag(1)
                MapView()
                    .tabItem {
                        Label("マップ", systemImage: "map")
                    }
                    .tag(2)
                CameraView(isUserCurrentryLoggedOut: $isUserCurrentryLoggedOut)
                    .tag(3)
                MapView()
                    .tabItem {
                        Label("マップ", systemImage: "map")
                    }
                    .tag(4)
                AccountView(isUserCurrentryLoggedOut: $isUserCurrentryLoggedOut)
                    .tabItem {
                        Label("アカウント", systemImage: "person.fill")
                    }
                    .tag(5)
            }
            .padding(.bottom, 5)
            .overlay {
                VStack {
                    Spacer()
                    Button {
                        selectedTab = 3
                    } label: {
                        Circle()
                            .frame(width: 60)
                            .overlay {
                                VStack {
                                    Image(systemName: "qrcode.viewfinder")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25)
                                        .dynamicTypeSize(.medium)
                                    Text("スキャン")
                                        .font(.caption2)
                                        .bold()
                                        .dynamicTypeSize(.medium)
                                }
                                .foregroundStyle(.white)
                            }
                    }
                    .padding(.bottom, 7)
                }
            }
        }
        .tint(Color.sheebaDarkGreen)
    }
}

#Preview {
    ContentView()
}
