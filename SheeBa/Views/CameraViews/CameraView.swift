//
//  CameraView.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2024/01/01.
//

import SwiftUI

struct CameraView: View {
    
    @Environment(\.dismiss) var dismiss
    let sounds = Sounds()
    @ObservedObject var vm = ViewModel()
    @State private var isShowSendPayView = false        // SendPayViewの表示有無
    @State private var isShowGetPointView = false       // GetPointViewの表示有無
    @State private var isSameStoreScanError = false     // 同日同店舗スキャンエラー
    @State private var isQrCodeScanError = false        // QRコード読み取りエラー
    @State private var isEventStoreScanError = false    // イベント店舗読み取りエラー
    @State private var isShowSignOutAlert = false       // 強制サインアウトアラート
    
    @State private var resultUID = ""                 // 送金相手UID
    @State private var getPoint = ""                    // 取得ポイント
    
    @Binding var isUserCurrentryLoggedOut: Bool
    
    var body: some View {
        NavigationStack {
            if let isStore = vm.currentUser?.isStore, isStore {
                Text("店舗アカウントのため、\nカメラの読み取りは不可能です。")
            } else {
                QRCodeScannerView(codeTypes: [.qr], completion: handleScan)
                    .overlay {
//                        if vm.isQrCodeScanError {
//                            ZStack {
//                                Color(.red)
//                                    .opacity(0.5)
//                                VStack {
//                                    Image(systemName: "multiply")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 90, height: 90)
//                                        .foregroundStyle(.white)
//                                        .opacity(0.6)
//                                        .padding(.bottom)
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .padding(.horizontal)
//                                        .frame(width: UIScreen.main.bounds.width, height: 40)
//                                        .foregroundStyle(.black)
//                                        .opacity(0.7)
//                                        .overlay {
//                                            Text(isSameStoreScanError ? "このQRコードは後日0時に有効になります。" : "誤ったQRコードがスキャンされました")
//                                                .foregroundStyle(.white)
//                                        }
//                                }
//                            }
//                        } else {
                            Rectangle()
                                .stroke(style:
                                            StrokeStyle(
                                                lineWidth: 7,
                                                lineCap: .round,
                                                lineJoin: .round,
                                                miterLimit: 50,
                                                dash: [100, 100],
                                                dashPhase: 50
                                            ))
                                .frame(width: 200, height: 200)
                                .foregroundStyle(.white)
//                        }
                    }
                    .navigationDestination(isPresented: $isShowGetPointView) {
                        GetPointView(store: vm.store, getPoint: getPoint, isSameStoreScanError: $isSameStoreScanError, isQrCodeScanError: $isQrCodeScanError, isEventStoreScanError: $isEventStoreScanError)
                    }
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
                }
            } else {
                isUserCurrentryLoggedOut = true
            }
        }
//        .onChange(of: isQrCodeScanError) { _ in
//            // 1.5秒後にQRコード読みよりエラーをfalseにする。
//            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
//                vm.isQrCodeScanError = false
//                isSameStoreScanError = false
//            }
//        }
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
//        .fullScreenCover(isPresented: $isUserCurrentryLoggedOut) {
//            EntryView {
//                isUserCurrentryLoggedOut = false
//                vm.fetchCurrentUser()
//                vm.fetchRecentMessages()
//                vm.fetchFriends()
//                vm.fetchStorePoints()
//            }
//        }
        .fullScreenCover(isPresented: $isShowSendPayView) {
            SendPayView(didCompleteSendPayProcess: { sendPayText in
                isShowSendPayView.toggle()
                vm.handleSend(toId: resultUID, chatText: "", lastText: sendPayText, isSendPay: true)
                dismiss()
            }, chatUser: vm.chatUser)
        }
//        .fullScreenCover(isPresented: $vm.isNavigateNotConfirmEmailView) {
//            NotConfirmEmailView {
//                vm.isNavigateNotConfirmEmailView = false
//            }
//        }
    }
    
    // MARK: - QRコード読み取り処理
    /// - Parameters:
    ///   - result: QRコード読み取り結果
    /// - Returns: なし
    private func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            let fetchedUid = result.string
            self.resultUID = fetchedUid
            
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                vm.handleError(String.failureFetchUID, error: nil)
                return
            }
            
            // 同アカウントのQRコードを読み取ってしまった場合、エラーを発動。
            if uid == self.resultUID {
                isQrCodeScanError = true
                self.isShowGetPointView = true
                return
            }
            
            // URLを読み取ったら、スキャンエラーを表示する
            if self.resultUID.contains("http") {
                isQrCodeScanError = true
                self.isShowGetPointView = true
                return
            }
            
//            vm.fetchUser(uid: chatUserUID)
//            vm.fetchStorePoint(document1: uid, document2: self.chatUserUID)
            
            if self.resultUID.count == 28 {
                // ユーザー情報を取得
                FirebaseManager.shared.firestore
                    .collection(FirebaseConstants.users)
                    .document(resultUID)
                    .getDocument { snapshot, error in
                        vm.handleNetworkError(error: error, errorMessage: String.failureFetchUser)
                        
                        // ユーザー情報を取得できなかった場合、QRコードスキャンエラー
                        guard let data = snapshot?.data() else {
                            isQrCodeScanError = true
                            self.isShowGetPointView = true
                            return
                        }
                        vm.chatUser = .init(data: data)
                        
                        guard let chatUser = vm.chatUser else {
                            vm.handleError(String.failureFetchUser, error: nil)
                            return
                        }
                        
                        // 元店舗QRを読み取った場合、エラーを検出
                        if chatUser.isStore {
                            isQrCodeScanError = true
                            self.isShowGetPointView = true
                            return
                        } else {
                            self.isShowSendPayView = true
                            return
                        }
                        
                        // 店舗ポイント情報を取得
//                        FirebaseManager.shared.firestore
//                            .collection(FirebaseConstants.storePoints)
//                            .document(uid)
//                            .collection(FirebaseConstants.user)
//                            .document(resultUID)
//                            .getDocument { snapshot, error in
//                                guard let chatUser = vm.chatUser else {
//                                    vm.handleError(String.failureFetchUser, error: nil)
//                                    return
//                                }
                                
                                // 店舗ポイント情報が以前に一度も取得していなかった場合
//                                guard let data = snapshot?.data() else {
//                                    if chatUser.isStore {
//                                        // スキャンが可能であるか否か
//                                        if chatUser.isEnableScan {
//                                            // 店舗ポイントアカウントの場合、ポイントを獲得
//                                            handleGetPointFromStore(chatUser: chatUser)
//                                            self.isShowGetPointView = true
//                                            return
//                                        } else {
//                                            isQrCodeScanError = true
//                                            self.isShowGetPointView = true
//                                            return
//                                        }
//                                    } else {
                                        // 店舗ポイントアカウント以外の場合、送ポイント画面を表示
//                                        self.isShowSendPayView = true
//                                        return
//                                    }
//                                }
//                                vm.storePoint = .init(data: data)
//                                divideScanProcess(chatUser: chatUser)
//                            }
                    }
            } else if self.resultUID.count == 30 {
                // 店舗を取得
                FirebaseManager.shared.firestore
                    .collection(FirebaseConstants.stores)
                    .document(resultUID)
                    .getDocument { snapshot, error in
                        vm.handleNetworkError(error: error, errorMessage: String.failureFetchStores)
                        
                        // ユーザー情報を取得できなかった場合、QRコードスキャンエラー
                        guard let data = snapshot?.data() else {
                            isQrCodeScanError = true
                            self.isShowGetPointView = true
                            return
                        }
                        vm.store = .init(data: data)
                        
                        // 店舗ポイント情報を取得
                        FirebaseManager.shared.firestore
                            .collection(FirebaseConstants.storePoints)
                            .document(uid)
                            .collection(FirebaseConstants.user)
                            .document(resultUID)
                            .getDocument { snapshot, error in
                                guard let store = vm.store else {
                                    vm.handleError(String.failureFetchUser, error: nil)
                                    return
                                }
                                
                                // 店舗ポイント情報が以前に一度も取得していなかった場合
                                guard let data = snapshot?.data() else {
                                    // スキャンが可能であるか否か
                                    if store.isEnableScan {
                                        // 店舗ポイントアカウントの場合、ポイントを獲得
                                        handleGetPointFromStore(store: store)
                                        self.isShowGetPointView = true
                                        return
                                    } else {
                                        isQrCodeScanError = true
                                        self.isShowGetPointView = true
                                        return
                                    }
                                }
                                vm.storePoint = .init(data: data)
                                divideScanProcess(store: store)
                            }
                    }
            } else {
                // 読み取った文字列が28文字でも、30文字でもなかった場合、エラー。
                isQrCodeScanError = true
                self.isShowGetPointView = true
                return
            }
        case .failure(let error):
            isQrCodeScanError = true
            self.isShowGetPointView = true
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - QRコード読み取り結果を場合分けする。
    /// - Parameters:
    ///   - chatUser: 取得ユーザー情報
    /// - Returns: なし
//    private func divideScanProcess(chatUser: ChatUser) {
//        // 店舗ポイントアカウントの場合
//        if chatUser.isStore {
//            // スキャンが可能であるか否か
//            if chatUser.isEnableScan {
//                // 店舗ポイント情報がある場合は場合分け、ない場合はポイントを獲得する。
//                if let storePoint = vm.storePoint {
//                    // 店舗QRコードが同日に2度以上のスキャンでない場合
//                    if storePoint.date != vm.dateFormat(Date()) {
//                        handleGetPointFromStore(chatUser: chatUser)
//                        self.isShowGetPointView = true
//                    } else {
//                        isSameStoreScanError = true
//                        self.isShowGetPointView = true
//                    }
//                } else {
//                    handleGetPointFromStore(chatUser: chatUser)
//                    self.isShowGetPointView = true
//                }
//            } else {
//                isQrCodeScanError = true
//                self.isShowGetPointView = true
//                return
//            }
//        } else {
//            // 店舗ポイントアカウント以外の場合、送ポイント画面を表示
//            self.isShowSendPayView = true
//        }
//    }
    
    // MARK: - QRコード読み取り結果を場合分けする。
    /// - Parameters:
    ///   - store: 取得店舗
    /// - Returns: なし
    private func divideScanProcess(store: Stores) {
        // スキャンが可能であるか否か
        if store.isEnableScan {
            // 店舗ポイント情報がある場合は場合分け、ない場合はポイントを獲得する。
            if let storePoint = vm.storePoint {
                // 店舗QRコードが同日に2度以上のスキャンでない場合
                if storePoint.date != vm.dateFormat(Date()) {
                    // イベント店舗の場合は、同日2度以上のスキャンでない場合でもエラー
                    if store.isEvent {
                        isEventStoreScanError = true
                        self.isShowGetPointView = true
                    } else {
                        handleGetPointFromStore(store: store)
                        self.isShowGetPointView = true
                    }
                } else {
                    // イベント店舗と通常店舗のエラー文を変える
                    if store.isEvent {
                        isEventStoreScanError = true
                        self.isShowGetPointView = true
                    } else {
                        isSameStoreScanError = true
                        self.isShowGetPointView = true
                    }
                }
            } else {
                handleGetPointFromStore(store: store)
                self.isShowGetPointView = true
            }
        } else {
            isQrCodeScanError = true
            self.isShowGetPointView = true
            return
        }
    }
    
    // MARK: - 店舗からポイント取得処理
    /// - Parameters:
    ///   - store: 取得店舗
    /// - Returns: なし
    private func handleGetPointFromStore(store: Stores) {
        
        let index: Int = Int.random(in: 1 ... 10)
        
        // メェーの音を鳴らす
        if index == 1 {
            sounds.playSoundSheep2()
        } else {
            sounds.playSoundSheep1()
        }
        
        guard let currentUser = vm.currentUser else { return }
        getPoint = String(store.getPoint)
        
        guard let currentUserMoney = Int(currentUser.money),
              let intGetPoint = Int(getPoint) else {
            vm.handleError("送金エラーが発生しました。", error: nil)
            return
        }
        
        // 残高に取得ポイントを足す
        let calculatedCurrentUserMoney = currentUserMoney + intGetPoint
        
        // 自身のユーザー情報を更新
        let userData = [FirebaseConstants.money: String(calculatedCurrentUserMoney),]
        vm.updateUser(document: currentUser.uid, data: userData)
        
        // 店舗ポイント情報を更新
        let storePointData = [
            FirebaseConstants.uid: store.uid,
            FirebaseConstants.email: "",
            FirebaseConstants.profileImageUrl: store.profileImageUrl,
            FirebaseConstants.getPoint: getPoint,
            FirebaseConstants.username: store.storename,
            FirebaseConstants.isEvent: store.isEvent,
            FirebaseConstants.date: vm.dateFormat(Date()),
        ] as [String : Any]
        vm.persistStorePoint(document1: currentUser.uid, document2: store.uid, data: storePointData)
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
    CameraView(isUserCurrentryLoggedOut: .constant(false))
}
