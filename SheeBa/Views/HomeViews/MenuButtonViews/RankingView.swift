//
//  RankingView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/06.
//

import SwiftUI

struct RankingView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var users = [ChatUser]()             // 全ユーザー
    @State private var rankMoneyUsers = [ChatUser]()    // ランキング表示ユーザー
    @State private var ranking = Setting.rankingCount   // ランキング数
    @State private var isShowResetPointAlert = false    // 全ユーザーポイントリセットアラート表示有無
    @State private var isShowSuccessResetPoint = false  // 全ユーザーポイントリセット成功アラート表示有無
    let currentUser: ChatUser?                          // 現在のユーザー
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(rankMoneyUsers, id: \.self) { user in
                        CardView(user: user)
                    }
                    
                    // 全ユーザーリセットボタン
                    if let currentUser = vm.currentUser, currentUser.isOwner {
                        Button {
                            isShowResetPointAlert = true
                        } label: {
                            Text("全ユーザーのポイントをリセットする")
                                .foregroundStyle(Color.red)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("ランキング")
        .overlay {
            ScaleEffectIndicator(onIndicator: $vm.onIndicator)
        }
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
                fetchAllUsersOrderByMoney()
            }
        }
        .asBackButton()
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.alertMessage,
                       didAction: { vm.isShowError = false })
        .asDestructiveAlert(title: "全ユーザーのポイントをリセットしますか？",
                            isShowAlert: $isShowResetPointAlert,
                            message: "一度この操作をすると、後で取り戻すことができません。",
                            buttonText: "リセット",
                            didAction: {
            resetAllUserPoints()
            isShowSuccessResetPoint = true
        })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowSuccessResetPoint,
                       message: "リセットが完了しました。",
                       didAction: {
            isShowSuccessResetPoint = false
            dismiss()
        })
    }
    
    // MARK: - cardView
    struct CardView: View {
        
        let user: ChatUser
        
        var body: some View {
            ZStack {
                Rectangle()
                    .cornerRadius(20)
                    .padding(.horizontal, 30)
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .foregroundStyle(Color.white)
                    .shadow(radius: 7, x: 0, y: 0)
                    .overlay {
                        VStack {
                            Spacer()
                            
                            HStack {
                                Text("\(user.ranking)位：")
                                    .font(.title3)
                                    .dynamicTypeSize(.medium)
                                    .padding(.leading)
                                Text(user.username)
                                    .font(.title3)
                                    .bold()
                                    .dynamicTypeSize(.medium)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                            }
                            
                            HStack {
                                Spacer()
                                
                                // トップ画像
                                if user.profileImageUrl != "" {
                                    Icon.CustomWebImage(imageSize: .large, image: user.profileImageUrl)
                                } else {
                                    Icon.CustomCircle(imageSize: .large)
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Text(user.money)
                                        .font(.system(size: 40))
                                        .bold()
                                        .dynamicTypeSize(.medium)
                                        .padding(.horizontal)
                                    Text("pt")
                                        .font(.title3)
                                        .dynamicTypeSize(.medium)
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.top, 20)
            }
        }
    }
    
    // MARK: - 全ユーザーをポイントが高い順に並べて取得
    /// - Parameters: なし
    /// - Returns: なし
    private func fetchAllUsersOrderByMoney() {
        // オーナーアカウントの場合、ランキング表示数を変える。
        if let currentUser = currentUser, currentUser.isOwner {
            ranking = Setting.ownerRankingCount
        }
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .order(by: FirebaseConstants.money, descending: true)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    vm.handleNetworkError(error: error, errorMessage: String.failureFetchAllUser)
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    users.append(.init(data: data))
                })
                
                // ポイントが高い順に並び替える。
                let sortUsers = users.sorted(by: { user1, user2 in
                    if let money1 = Int(user1.money), let money2 = Int(user2.money) {
                        return money1 > money2
                    }
                    return false
                })
                
                var previousMoney = 0               // 一つ上位のポイント数
                var count = 0                       // 順位
                
                // 上位5位までのユーザーを取得する。
                for user in sortUsers {
                    // オーナー、店舗オーナーはランキングから除く
                    if let money = Int(user.money), !user.isOwner && !user.isStoreOwner {
                        // 表示順位以内であれば、ランキングに加える
                        if count < ranking  {
                            // ポイント数に変更があったら、順位を一つ変えるためカウント数を一つ加える。
                            if money != previousMoney {
                                count += 1
                            }
                            // データを追加する。
                            let data = [
                                FirebaseConstants.username: user.username,
                                FirebaseConstants.profileImageUrl: user.profileImageUrl,
                                FirebaseConstants.money: user.money,
                                FirebaseConstants.rankign: "\(count)"
                            ] as [String : Any]
                            rankMoneyUsers.append(.init(data: data))
                            
                            previousMoney = money
                        }
                    }
                }
        }
    }
    
    // MARK: - 全ユーザーのポイントをリセット
    /// - Parameters: なし
    /// - Returns: なし
    private func resetAllUserPoints() {
        vm.onIndicator = true
        
        let data = [FirebaseConstants.money: "20",]
        
        for user in users {
            // 店舗アカウント、オーナーアカウント以外の全ユーザーの更新をする。
            if !user.isStore && !user.isOwner && !user.isStoreOwner {
                vm.updateUser(document: user.uid, data: data)
            }
        }
        
        vm.onIndicator = false
    }
}

#Preview {
    RankingView(currentUser: nil)
}
