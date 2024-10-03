//
//  TodaysGetPointView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/07.
//

import SwiftUI

struct TodaysGetPointView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var storePoints = [StorePoint]()         // 自分が取得した店舗ポイント情報
    @State private var stores = [Stores]()                  // 全店舗
//    @State private var storeUsers = [ChatUser]()            // 全店舗ユーザー
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    Rectangle()
                        .cornerRadius(20)
                        .padding(.horizontal, 30)
                        .frame(width: UIScreen.main.bounds.width, height: 150)
                        .foregroundStyle(Color.sheebaDarkGreen)
                        .overlay {
                            VStack {
                                Text("本日")
                                    .font(.system(size: 20))
                                    .bold()
                                    .dynamicTypeSize(.medium)
                                    .foregroundStyle(Color.white)
                                    .padding(.bottom, 10)
                                Text("\(countGetStorePointToday()) / \(stores.count) 店舗獲得")
                                    .font(.system(size: 30))
                                    .bold()
                                    .dynamicTypeSize(.medium)
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .padding()
                    ForEach(stores, id: \.self) { store in
                        CardView(storePoints: storePoints, store: store, isGetPoint: isGetStorePointToday(store: store))
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("本日の獲得ポイント一覧")
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
                fetchStorePoints()
            }
        }
        .asBackButton()
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.alertMessage,
                       didAction: { vm.isShowError = false })
    }
    
    // MARK: - cardView
    struct CardView: View {
        
        @ObservedObject var vm = ViewModel()
        let storePoints: [StorePoint]
        let store: Stores
//        let user: ChatUser
        let isGetPoint: Bool
        
        var body: some View {
            NavigationLink {
                StoreDetailView(store: store)
            } label: {
                ZStack {
                    Rectangle()
                        .cornerRadius(20)
                        .padding(.horizontal, 30)
                        .frame(width: UIScreen.main.bounds.width, height: 100)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 7, x: 0, y: 0)
                        .overlay {
                            VStack {
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    
                                    if isGetPoint {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25)
                                            .padding(.trailing, 10)
                                            .foregroundStyle(Color.blue)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25)
                                            .padding(.trailing, 10)
                                            .foregroundStyle(Color.white)
                                    }
                                    
                                    // トップ画像
                                    if store.profileImageUrl != "" {
                                        Icon.CustomWebImage(imageSize: .medium, image: store.profileImageUrl)
                                            .opacity(isGetPoint ? 1 : 0.4)
                                    } else {
                                        Icon.CustomCircle(imageSize: .medium)
                                            .opacity(isGetPoint ? 1 : 0.4)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(store.storename)
                                        .font(.title3)
                                        .bold()
                                        .dynamicTypeSize(.medium)
                                        .foregroundStyle(isGetPoint ? .black : .gray)
                                        .frame(width: 150)
                                        .padding(.bottom, 5)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.top, 15)
                }
            }
        }
    }
    
    // MARK: - 店舗ポイント情報を取得
    /// - Parameters: なし
    /// - Returns: なし
    private func fetchStorePoints() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        self.storePoints.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.storePoints)
            .document(uid)
            .collection(FirebaseConstants.user)
            .order(by: FirebaseConstants.username)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    print("店舗ポイント情報の取得に失敗しました。")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let sp = try change.document.data(as: StorePoint.self)
                            storePoints.append(sp)
                        } catch {
                            vm.handleError(String.notFoundData, error: nil)
                            return
                        }
                    }
                })
                fetchAllStoreUsers()
            }
    }
    
    // MARK: - 全店舗ユーザーを取得
    /// - Parameters: なし
    /// - Returns: なし
    private func fetchAllStoreUsers() {
        stores.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.stores)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    vm.handleNetworkError(error: error, errorMessage: String.failureFetchAllUser)
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let store = Stores(data: data)
                    
                    // スキャン可能の場合で且つ、イベント店舗以外の場合のみ追加する。
                    if store.isEnableScan && !store.isEvent {
                        stores.append(.init(data: data))
                    }
                })
                stores.sort(by: {$0.no < $1.no})
            }
    }
    
    // MARK: - 店舗ポイント情報が本日取得済みか否かを判断
    /// - Parameters:
    ///   - store: 店舗
    /// - Returns: 全店舗ユーザーの中に今日取得した店舗ポイント情報を確保していた場合True、そうでない場合false。
    private func isGetStorePointToday(store: Stores) -> Bool {
        for storePoint in storePoints {
            // 全店舗ユーザーの中に今日取得した店舗ポイント情報を確保していた場合True。
            if store.uid == storePoint.uid && storePoint.date == vm.dateFormat(Date()) {
                return true
            }
        }
        return false
    }
    
    // MARK: - 本日取得済みの店舗ポイント情報数をカウント
    /// - Parameters: なし
    /// - Returns: 本日取得済みの店舗ポイント情報数
    private func countGetStorePointToday() -> Int {
        var count: Int = 0
        
        for storePoint in storePoints {
            // 全店舗ユーザーの中に今日取得した店舗ポイント情報を確保していた場合True。
            if storePoint.date == vm.dateFormat(Date()) {
                count += 1
            }
        }
        return count
    }
}

#Preview {
    TodaysGetPointView()
}
