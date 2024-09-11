//
//  EditStoreInfoView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/20.
//

import SwiftUI

struct StoreInfoListView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var storeUsers = [ChatUser]()                // 全店舗ユーザー
    @State private var isShowUpdateStoreCategory = false        // 指定の項目を追加するアラートの表示有無
    @State private var isShowSuccessUpdateStoreCategory = false // 指定の項目の追加完了アラートの表示有無
//    @State private var editUser: ChatUser?                      // 編集するユーザー
//    @State private var isEnableScan = false                     // スキャンの可否
//    @State private var isShowChangeIsEnableScanAlert = false    // スキャンの可否変更確認アラート
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(storeUsers) { user in
                    NavigationLink {
                        EditStoreInfoView(user: user)
                    } label: {
                        HStack {
                            Text(user.username)
                                .foregroundStyle(user.isEnableScan ? .blue : .gray)
                            
                            Spacer()
                            
                            Text(String(user.getPoint))
                                .font(.title3)
                                .bold()
                            Text("pt")
                                .padding(.trailing)
                        }
                    }
                    
                }
                
                Button {
                    isShowUpdateStoreCategory = true
                } label: {
                    Text("指定の項目を追加する（Developer専用）")
                        .foregroundStyle(Color.red)
                }
            }
            .padding(.leading, 10)
            .listStyle(.inset)
            .environment(\.defaultMinListRowHeight, 60)
        }
        .overlay {
            ScaleEffectIndicator(onIndicator: $vm.onIndicator)
        }
        .navigationTitle("店舗管理")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchAllStoreUsers()
        }
        .asBackButton()
//        .asSingleAlert(title: "",
//                       isShowAlert: $isShowChangeIsEnableScanAlert,
//                       message: "スキャンの可否を更新しますか？",
//                       didAction: {
//            isEnableScan.toggle()
//            if let user = editUser {
//                updateStoreUserIsEnableScan(user: user)
//            }
//            isShowChangeIsEnableScanAlert = false
        //        })
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
        .asDestructiveAlert(title: "",
                            isShowAlert: $isShowUpdateStoreCategory,
                            message: "指定の項目を追加してもよろしいですか？",
                            buttonText: "追加",
                            didAction: {
            updateStoreUserCategory()
        })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowSuccessUpdateStoreCategory,
                       message: "追加が完了しました。",
                       didAction: { isShowSuccessUpdateStoreCategory = false })
    }
    
    // MARK: - 全店舗ユーザーを取得
    /// - Parameters: なし
    /// - Returns: なし
    private func fetchAllStoreUsers() {
        vm.onIndicator = true
        storeUsers.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    vm.handleNetworkError(error: error, errorMessage: String.failureFetchAllUser)
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    
                    // 追加するユーザーが店舗の場合のみ追加する。
                    if user.isStore {
                        storeUsers.append(.init(data: data))
                    }
                })
                storeUsers.sort(by: {$0.no < $1.no})
                vm.onIndicator = false
            }
    }
    
    // MARK: - 店舗ユーザーの項目を追加する
    /// - Parameters: なし
    /// - Returns: なし
    private func updateStoreUserCategory() {
        vm.onIndicator = true
        
        // 追加したい項目に変更すること
        let data = ["":"",]
        
        // ユーザー情報を更新
        for storeUser in storeUsers {
            vm.updateUser(document: storeUser.uid, data: data)
        }
        
        vm.onIndicator = false
        isShowUpdateStoreCategory = false
        isShowSuccessUpdateStoreCategory = true
    }
}

#Preview {
    StoreInfoListView()
}
