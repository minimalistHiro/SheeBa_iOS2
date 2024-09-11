//
//  ViewModel.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/12/02.
//

import SwiftUI
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseAnalytics

final class ViewModel: ObservableObject {
    
    @Published var currentUser: ChatUser?                       // 現在のユーザー
    @Published var chatUser: ChatUser?                          // トーク相手ユーザー
    @Published var allUsersOtherThanSelf = [ChatUser]()         // 全ユーザー(自分以外)
    @Published var allUsersContainSelf = [ChatUser]()           // 全ユーザー(自分含める)
    @Published var recentMessages = [RecentMessage]()           // 全最新メッセージ
    @Published var chatMessages = [ChatMessage]()               // 全メッセージ
    @Published var friend: Friend?                              // 特定の友達情報
    @Published var friends = [Friend]()                         // 全友達情報
    @Published var storePoint: StorePoint?                      // 特定の店舗ポイント情報
    @Published var storePoints = [StorePoint]()                 // 全店舗ポイント情報
    @Published var alertNotification: AlertNotification?        // 速報
    @Published var notifications = [NotificationModel]()        // 全お知らせ
    @Published var advertisements = [Advertisement]()           // 全広告
    
    @Published var errorMessage = ""                            // エラーメッセージ
    @Published var isShowError = false                          // エラー表示有無
    @Published var alertMessage = ""                            // アラートメッセージ
    @Published var isShowAlert = false                          // アラート表示有無
    
    @Published var isScroll = false                             // メッセージスクロール用変数
    @Published var onIndicator = false                          // インジケーターが進行中か否か
    @Published var isNavigateConfirmEmailView = false           // メールアドレス認証画面の表示有無
    @Published var isNavigateNotConfirmEmailView = false        // メールアドレス未認証画面の表示有無
    @Published var isShowNotConfirmEmailError = false           // メールアドレス未認証エラー
    let didCompleteLoginProcess: () -> ()
    
    init(){
        self.didCompleteLoginProcess = {}
        
    }
    
    init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
    }
    
    // MARK: - Fetch
    
    /// 現在ユーザー情報を取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchCurrentUser() {
        onIndicator = true
        
        guard let user = FirebaseManager.shared.auth.currentUser else {
            self.handleError(String.failureFetchUID, error: nil)
            return
        }
        
        //        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
        //            self.handleError(String.failureFetchUID, error: nil)
        //            return
        //        }
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(user.uid)
            .getDocument { snapshot, error in
                self.handleNetworkError(error: error, errorMessage: String.failureFetchUser)
                
                guard let data = snapshot?.data() else {
                    self.handleError(String.notFoundData, error: nil)
                    return
                }
                
                self.currentUser = .init(data: data)
                
                guard let currentUser = self.currentUser else {
                    self.handleError(String.failureFetchUser, error: nil)
                    return
                }
                
                // メールアドレス未認証の場合のエラー
                //                if !currentUser.isConfirmEmail && !currentUser.isStore {
                //                    self.isShowNotConfirmEmailError = true
                //                    try? FirebaseManager.shared.auth.signOut()
                //                }
                // メールアドレス未認証の場合のエラー
                if !user.isEmailVerified && !currentUser.isStore {
                    self.isShowNotConfirmEmailError = true
                    try? FirebaseManager.shared.auth.signOut()
                    return
                }
                
                // 初回特典アラート表示
                if !currentUser.isFirstLogin && !currentUser.isStore {
                    self.handleAlert("初回登録特典として\n\(Setting.newRegistrationBenefits)ptプレゼント！")
                    let data = [FirebaseConstants.isFirstLogin: true,]
                    self.updateUser(document: currentUser.uid, data: data)
                }
                
                self.onIndicator = false
                //                print("[CurrentUser]\n \(String(describing: self.currentUser))\n")
            }
    }
    
    /// UIDに一致するユーザー情報を取得
    /// - Parameters:
    ///   - uid: トーク相手のUID
    /// - Returns: なし
    func fetchUser(uid: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .getDocument { snapshot, error in
                self.handleNetworkError(error: error, errorMessage: String.failureFetchUser)
                
                guard let data = snapshot?.data() else {
                    self.handleError(String.notFoundData, error: nil)
                    return
                }
                self.chatUser = .init(data: data)
                //                print("[ChatUser]\n \(String(describing: self.chatUser))\n")
            }
    }
    
    /// 全ユーザーを取得（自分以外）
    /// - Parameters: なし
    /// - Returns: なし
    func fetchAllUsersOtherThanSelf() {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    self.handleNetworkError(error: error, errorMessage: String.failureFetchAllUser)
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    
                    // 追加するユーザーが自分以外、且つ店舗ユーザーでない場合のみ、追加する。
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid && !user.isStore {
                        self.allUsersOtherThanSelf.append(.init(data: data))
                    }
                })
            }
    }
    
    /// 全ユーザーを取得（自分を含める）
    /// - Parameters: なし
    /// - Returns: なし
    func fetchAllUsersContainSelf() {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    self.handleNetworkError(error: error, errorMessage: String.failureFetchAllUser)
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    
                    // 追加するユーザーが店舗ユーザーでない場合のみ、追加する。
                    if !user.isStore {
                        self.allUsersContainSelf.append(.init(data: data))
                    }
                })
            }
    }
    
    /// 最新メッセージを取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        self.recentMessages.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.message)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    print("最新メッセージの取得に失敗しました。")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do {
                        let rm = try change.document.data(as: RecentMessage.self)
                        self.recentMessages.insert(rm, at: 0)
                    } catch {
                        self.handleError(String.notFoundData, error: nil)
                        return
                    }
                })
                //                print("[RecentMessage]\n \(String(describing: self.recentMessages))\n")
            }
    }
    
    /// メッセージを取得
    /// - Parameters:
    ///   - toId: トーク相手のUID
    /// - Returns: なし
    func fetchMessages(toId: String) {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        chatMessages.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    print("メッセージの取得に失敗しました。")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let cm = try change.document.data(as: ChatMessage.self)
                            self.chatMessages.append(cm)
                        } catch {
                            self.handleError(String.notFoundData, error: nil)
                            return
                        }
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isScroll.toggle()
                }
                //                print("[Message]\n \(String(describing: self.chatMessages))\n")
                //                print("[Message] \n")
            }
    }
    
    /// UIDに一致する友達情報を取得
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func fetchFriend(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .getDocument { snapshot, error in
                self.handleNetworkError(error: error, errorMessage: "このユーザーはあなたと縁を切りました。")
                
                guard let data = snapshot?.data() else {
                    self.handleError("このユーザーはあなたと縁を切りました。", error: nil)
                    return
                }
                self.friend = .init(data: data)
                //                print("[Friend]\n \(String(describing: self.friend))\n")
            }
    }
    
    /// 友達情報を取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchFriends() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        self.friends.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(uid)
            .collection(FirebaseConstants.user)
            .order(by: FirebaseConstants.username)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    print("友達情報の取得に失敗しました。")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        do {
                            let fr = try change.document.data(as: Friend.self)
                            self.friends.append(fr)
                        } catch {
                            self.handleError(String.notFoundData, error: nil)
                            return
                        }
                    }
                })
                //                print("[Friend]\n \(String(describing: self.friends))\n")
            }
    }
    
    /// UIDに一致する店舗ポイント情報を取得
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func fetchStorePoint(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.storePoints)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data() else {
                    print(String.notFoundData)
                    return
                }
                self.storePoint = .init(data: data)
            }
    }
    
    /// 全店舗ポイント情報を取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchStorePoints() {
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
                            self.storePoints.append(sp)
                        } catch {
                            self.handleError(String.notFoundData, error: nil)
                            return
                        }
                    }
                })
            }
    }
    
    /// 全アラートを取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchAlerts() {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.alerts)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    print("全アラートの取得に失敗しました。")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let alert = AlertNotification(data: data)
                    
                    self.alertNotification = alert
                })
            }
    }
    
    /// 全お知らせを取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchNotifications() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        self.notifications.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.notifications)
            .document(uid)
            .collection(FirebaseConstants.notification)
            .order(by: FirebaseConstants.timestamp, descending: true)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    print("全お知らせの取得に失敗しました。")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    self.notifications.append(.init(data: data))
                })
            }
    }
    
    /// 全広告を取得
    /// - Parameters: なし
    /// - Returns: なし
    func fetchAdvertisements() {
        self.advertisements.removeAll()
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.advertisements)
            .order(by: FirebaseConstants.timestamp, descending: true)
            .getDocuments { documentsSnapshot, error in
                if error != nil {
                    print("全広告の取得に失敗しました。")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    self.advertisements.append(.init(data: data))
                })
            }
    }
    
    // MARK: - Handle
    
    /// 新規作成
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    ///   - password2: パスワード（確認用）
    ///   - username: ユーザー名
    ///   - age: 年齢
    ///   - address: 住所
    ///   - image: トップ画像
    ///   - isStoreOwner: 店舗オーナー
    /// - Returns: なし
    func createNewAccount(email: String, password: String, password2: String, username: String, age: String, address: String, image: UIImage?, isStoreOwner: Bool) {
        onIndicator = true
        // メールアドレス、パスワードどちらかが空白の場合、エラーを出す。
        if email.isEmpty || password.isEmpty {
            self.handleError(String.emptyEmailOrPassword, error: nil)
            return
        }
        
        // 2つのパスワードが一致しない場合、エラーを出す。
        if password != password2 {
            self.handleError(String.mismatchPassword, error: nil)
            return
        }
        // パスワードの文字数が足りない時にエラーを発動。
        //        if password.count < Setting.minPasswordOfDigits {
        //            self.isShowPasswordOfDigitsError = true
        //            return
        //        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.handleError(String.invalidEmail, error: error)
                    return
                case .weakPassword:
                    self.handleError(String.weakPassword, error: error)
                    return
                case .emailAlreadyInUse:
                    self.handleError(String.emailAlreadyInUse, error: error)
                    return
                case .networkError:
                    self.handleError(String.networkError, error: error)
                    return
                default:
                    self.handleError("\(errorCode)", error: error)
                    return
                }
            }
            
            if image == nil {
                self.persistUser(email: email, username: username, age: age, address: address, profileImageUrl: nil, isStoreOwner: isStoreOwner)
            } else {
                self.persistImage(email: email, username: username, age: age, address: address, image: image, isStoreOwner: isStoreOwner)
            }
            
            self.onIndicator = false
            self.handleEmailVerification()
        }
    }
    
    /// メール送信処理
    /// - Parameters: なし
    /// - Returns: なし
    func handleEmailVerification() {
        guard let user = FirebaseManager.shared.auth.currentUser else {
            self.handleError(String.failureFetchUser, error: nil)
            return
        }
        // メール送信処理
        user.sendEmailVerification { error in
            self.handleNetworkError(error: error, errorMessage: String.failureSendEmail)
            return
        }
        self.isNavigateConfirmEmailView = true
    }
    
    /// サインイン
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    /// - Returns: なし
    func handleSignIn(email: String, password: String) {
        onIndicator = true
        // メールアドレス、パスワードどちらかが空白の場合、エラーを出す。
        if email.isEmpty || password.isEmpty {
            self.handleError(String.emptyEmailOrPassword, error: nil)
            return
        }
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.handleError(String.invalidEmail, error: error)
                    return
                case .userNotFound:
                    self.handleError(String.userNotFound, error: error)
                    return
                case .wrongPassword:
                    self.handleError(String.userNotFound, error: error)
                    return
                case .userDisabled:
                    self.handleError(String.userDisabled, error: error)
                    return
                case .networkError:
                    self.handleError(String.networkError, error: error)
                    return
                case .invalidCredential:
                    self.handleError(String.userNotFound, error: error)
                    return
                default:
                    self.handleError("\(errorCode)", error: error)
                    return
                }
            }
            
            self.onIndicator = false
            self.didCompleteLoginProcess()
        }
    }
    
    /// サインイン（メールアドレス認証含む）
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    /// - Returns: なし
    func handleSignInWithConfirmEmail(email: String, password: String) {
        onIndicator = true
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.handleError(String.invalidEmail, error: error)
                    return
                case .userNotFound, .wrongPassword:
                    self.handleError(String.userNotFound, error: error)
                    return
                case .userDisabled:
                    self.handleError(String.userDisabled, error: error)
                    return
                case .networkError:
                    self.handleError(String.networkError, error: error)
                    return
                case .invalidCredential:
                    self.handleError(String.userNotFound, error: error)
                    return
                default:
                    self.handleError("\(errorCode)", error: error)
                    return
                }
            }
            
            guard let user = result?.user else {
                self.handleError(String.failureFetchUser, error: nil)
                return
            }
            
            // メールアドレス認証済みかの確認
            if !user.isEmailVerified {
                self.handleError("メールアドレスの認証が完了していません。\nメールを再送する場合は、お手数ですが一度お戻りになり（メールアドレスのリンクを無効にする）再度お試しください。", error: error)
                try? FirebaseManager.shared.auth.signOut()
                return
            }
            
            // メールアドレス認証済み処理
//            let data = [FirebaseConstants.isConfirmEmail: true,]
//            self.updateUser(document: user.uid, data: data)
            
            self.onIndicator = false
            self.didCompleteLoginProcess()
        }
    }
    
    /// サインイン（メール送信含む）
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    /// - Returns: なし
    func handleSignInWithEmailVerification(email: String, password: String) {
        onIndicator = true
        
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
                switch errorCode {
                case .invalidEmail:
                    self.handleError(String.invalidEmail, error: error)
                    return
                case .userNotFound, .wrongPassword:
                    self.handleError(String.userNotFound, error: error)
                    return
                case .userDisabled:
                    self.handleError(String.userDisabled, error: error)
                    return
                case .networkError:
                    self.handleError(String.networkError, error: error)
                    return
                case .invalidCredential:
                    self.handleError(String.userNotFound, error: error)
                    return
                default:
                    self.handleError("\(errorCode)", error: error)
                    return
                }
            }
            
            guard let user = result?.user else {
                self.handleError(String.failureFetchUser, error: nil)
                return
            }
            
            // メール送信処理
            user.sendEmailVerification { error in
                if error == nil {
                    self.isNavigateConfirmEmailView = true
                    self.onIndicator = false
                }
                self.handleNetworkError(error: error, errorMessage: String.failureSendEmail)
                return
            }
        }
    }
    
    /// テキスト送信処理
    /// - Parameters:
    ///   - toId: 受信者UID
    ///   - chatText: ユーザーの入力テキスト
    ///   - lastText: 一時保存用最新メッセージ
    ///   - isSendPay: 送金の有無
    /// - Returns: なし
    func handleSend(toId: String, chatText: String, lastText: String, isSendPay: Bool) {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let messageData = [FirebaseConstants.fromId: fromId,
                           FirebaseConstants.toId: toId,
                           FirebaseConstants.text: (isSendPay ? lastText : chatText),
                           FirebaseConstants.isSendPay: isSendPay,
                           FirebaseConstants.timestamp:
                            Timestamp()] as [String : Any]
        
        // 自身のメッセージデータを保存
        let messageDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        messageDocument.setData(messageData) { error in
            if error != nil {
                self.handleError("メッセージの保存に失敗しました。", error: error)
                return
            }
        }
        
        // トーク相手のメッセージデータを保存
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if error != nil {
                self.handleError("メッセージの保存に失敗しました。", error: error)
                return
            }
        }
        
        // 自身の最新メッセージデータを保存
        guard let chatUser = chatUser else { return }
        persistRecentMessage(user: chatUser, isSelf: true, fromId: fromId, toId: toId, text: isSendPay ? lastText : chatText, isSendPay: isSendPay)
        
        // トーク相手の最新メッセージデータを保存
        guard let currentUser = currentUser else { return }
        persistRecentMessage(user: currentUser, isSelf: false, fromId: fromId, toId: toId, text: isSendPay ? lastText : chatText, isSendPay: isSendPay)
    }
    
    /// ネットワークエラー処理
    /// - Parameters:
    ///   - error: エラー
    ///   - errorMessage: エラーメッセージ
    /// - Returns: なし
    func handleNetworkError(error: Error?, errorMessage: String) {
        if let error = error as NSError?, let errorCode = AuthErrorCode.Code(rawValue: error.code) {
            switch errorCode {
            case .networkError:
                self.handleError(String.networkError, error: error)
                return
            default:
                self.handleError(errorMessage, error: error)
                return
            }
        }
    }
    
    /// エラー処理
    /// - Parameters:
    ///   - errorMessage: エラーメッセージ
    ///   - error: エラー
    /// - Returns: なし
    func handleError(_ errorMessage: String, error: Error?) {
        self.onIndicator = false
        self.errorMessage = errorMessage
        self.isShowError = true
        // エラーメッセージ
        if let error = error {
            print("Error: \(error.localizedDescription)")
        } else {
            print("Error: \(errorMessage)")
        }
    }
    
    /// アラート
    /// - Parameters:
    ///   - message: メッセージ
    /// - Returns: なし
    func handleAlert(_ message: String) {
        self.onIndicator = false
        self.alertMessage = message
        self.isShowAlert = true
    }
    
    // MARK: - Persist
    
    /// ユーザー情報を保存
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - username: ユーザー名
    ///   - age: 年代
    ///   - address: 住所
    ///   - profileImageUrl: 画像URL
    ///   - isStoreOwner: 店舗オーナー
    /// - Returns: なし
    func persistUser(email: String, username: String, age: String, address: String, profileImageUrl: URL?, isStoreOwner: Bool) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.uid : uid,
                        FirebaseConstants.email: email,
                        FirebaseConstants.profileImageUrl: profileImageUrl?.absoluteString ?? "",
                        FirebaseConstants.money: Setting.newRegistrationBenefits,
                        FirebaseConstants.username: username == "" ? email : username,
                        FirebaseConstants.age: age,
                        FirebaseConstants.address: address,
//                        FirebaseConstants.isConfirmEmail: false,
                        FirebaseConstants.isFirstLogin: false,
                        FirebaseConstants.isStore: false,
                        FirebaseConstants.isStoreOwner: isStoreOwner,
                        FirebaseConstants.isOwner: false,
                        FirebaseConstants.os: "iOS",
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(uid)
            .setData(userData) { error in
                if error != nil {
                    // Authを削除
                    self.deleteAuth()
                    // 画像が保存済みであれば画像を削除
                    if let profileImageUrl {
                        self.deleteImage(withPath: profileImageUrl.absoluteString)
                    }
                    self.handleError("ユーザー情報の保存に失敗しました。", error: error)
                    return
                }
            }
    }
    
    /// 画像を保存
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - username: ユーザー名
    ///   - age: 年代
    ///   - address: 住所
    ///   - image: トップ画像
    ///   - isStoreOwner: 店舗オーナー
    /// - Returns: なし
    func persistImage(email: String, username: String, age: String, address: String, image: UIImage?, isStoreOwner: Bool) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil) { _, error in
            if error != nil {
                self.deleteAuth()
                self.handleError("画像の保存に失敗しました。", error: error)
                return
            }
            // Firestore Databaseに保存するためにURLをダウンロードする。
            ref.downloadURL { url, error in
                if error != nil {
                    self.deleteAuth()
                    self.handleError("画像URLの取得に失敗しました。", error: error)
                    return
                }
                guard let url = url else { return }
                self.persistUser(email: email, username: username, age: age, address: address, profileImageUrl: url, isStoreOwner: isStoreOwner)
            }
        }
    }
    
    /// 最新メッセージを保存
    /// - Parameters:
    ///   - user: トーク相手のデータ
    ///   - isSelf: 自身のデータか否か
    ///   - fromId: 送信者UID
    ///   - toId: 受信者UID
    ///   - text: テキスト
    ///   - isSendPay: 送金の有無
    /// - Returns: なし
    private func persistRecentMessage(user: ChatUser, isSelf: Bool, fromId: String, toId: String, text: String, isSendPay: Bool) {
        let document: DocumentReference
        
        // 自身のデータか、トーク相手のデータかでドキュメントを変える。
        if isSelf {
            document = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.recentMessages)
                .document(fromId)
                .collection(FirebaseConstants.message)
                .document(toId)
        } else {
            document = FirebaseManager.shared.firestore
                .collection(FirebaseConstants.recentMessages)
                .document(toId)
                .collection(FirebaseConstants.message)
                .document(fromId)
        }
        
        let data = [
            FirebaseConstants.email: user.email,
            FirebaseConstants.text: text,
            FirebaseConstants.fromId: fromId,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: user.profileImageUrl,
            FirebaseConstants.isSendPay: isSendPay,
            FirebaseConstants.username: user.username,
            FirebaseConstants.timestamp: Timestamp(),
        ] as [String : Any]
        
        document.setData(data) { error in
            if error != nil {
                self.handleError("最新メッセージの保存に失敗しました。", error: error)
                return
            }
        }
    }
    
    /// 友達情報を保存
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func persistFriend(document1: String, document2: String, data: [String: Any]) {
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
        
        document.setData(data) { error in
            if error != nil {
                self.handleError("友達の保存に失敗しました。", error: error)
                return
            }
        }
    }
    
    /// 店舗ポイント情報を保存
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func persistStorePoint(document1: String, document2: String,  data: [String: Any]) {
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.storePoints)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
        
        document.setData(data) { error in
            if error != nil {
                self.handleError("店舗ポイント情報の保存に失敗しました。", error: error)
                return
            }
        }
    }
    
    /// お知らせを保存
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func persistNotification(document1: String, document2: String, data: [String: Any]) {
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.notifications)
            .document(document1)
            .collection(FirebaseConstants.notification)
            .document(document2)
        
        document.setData(data) { error in
            if error != nil {
                self.handleError("お知らせの保存に失敗しました。", error: error)
                return
            }
        }
    }
    
    /// 広告を保存
    /// - Parameters:
    ///   - document: ドキュメント
    ///   - data: データ
    /// - Returns: なし
    func persistAdvertisement(document: String, data: [String: Any]) {
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.advertisements)
            .document(document)
        
        document.setData(data) { error in
            if error != nil {
                self.handleError("広告の保存に失敗しました。", error: error)
                return
            }
        }
    }
    
    // MARK: - Update
    
    /// ユーザー情報を更新
    /// - Parameters:
    ///   - document: ドキュメント
    ///   - data: データ
    /// - Returns: なし
    func updateUser(document: String, data: [String: Any]) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(document)
            .updateData(data as [AnyHashable : Any]) { error in
                self.handleNetworkError(error: error, errorMessage: "ユーザー情報の更新に失敗しました。")
            }
    }
    
    /// 最新メッセージを更新
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func updateRecentMessage(document1: String, document2: String, data: [String: Any]) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(document1)
            .collection(FirebaseConstants.message)
            .document(document2)
            .updateData(data as [AnyHashable : Any]) { error in
                self.handleNetworkError(error: error, errorMessage: "最新メッセージの更新に失敗しました。")
            }
    }
    
    /// 友達情報を更新
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func updateFriend(document1: String, document2: String, data: [String: Any]) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .updateData(data as [AnyHashable : Any]) { error in
                self.handleNetworkError(error: error, errorMessage: "ユーザー情報の更新に失敗しました。")
            }
    }
    
    /// お知らせを更新
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    ///   - data: データ
    /// - Returns: なし
    func updateNotification(document1: String, document2: String, data: [String: Any]) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.notifications)
            .document(document1)
            .collection(FirebaseConstants.notification)
            .document(document2)
            .updateData(data as [AnyHashable : Any]) { error in
                self.handleNetworkError(error: error, errorMessage: "お知らせの更新に失敗しました。")
            }
    }
    
    /// パスワードを更新
    /// - Parameters:
    ///   - password: パスワード
    /// - Returns: なし
    func updatePassword(password: String) {
        FirebaseManager.shared.auth.currentUser?.updatePassword(to: password) { error in
            self.handleNetworkError(error: error, errorMessage: "パスワードの更新に失敗しました。")
        }
    }
    
    // MARK: - Delete
    
    /// ユーザー情報を削除
    /// - Parameters:
    ///   - document: ドキュメント
    /// - Returns: なし
    func deleteUser(document: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.users)
            .document(document)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteUser)
            }
    }
    
    /// メッセージを削除
    /// - Parameters:
    ///   - document: ドキュメント
    ///   - collection: コレクション
    /// - Returns: なし
    func deleteMessage(document: String, collection: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(document)
            .collection(collection)
            .getDocuments { snapshot, error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteMessage)
                
                for document in snapshot!.documents {
                    document.reference.delete { error in
                        if error != nil {
                            self.handleError(String.failureDeleteData, error: error)
                            return
                        }
                    }
                }
            }
    }
    
    /// 最新メッセージを削除
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func deleteRecentMessage(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(document1)
            .collection(FirebaseConstants.message)
            .document(document2)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteRecentMessage)
            }
    }
    
    /// 友達情報を削除
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func deleteFriend(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.friends)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteFriend)
            }
    }
    
    /// 店舗ポイント情報を削除
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func deleteStorePoint(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.storePoints)
            .document(document1)
            .collection(FirebaseConstants.user)
            .document(document2)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteStorePoint)
            }
    }
    
    /// お知らせを削除
    /// - Parameters:
    ///   - document1: ドキュメント1
    ///   - document2: ドキュメント2
    /// - Returns: なし
    func deleteNotification(document1: String, document2: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.notifications)
            .document(document1)
            .collection(FirebaseConstants.notification)
            .document(document2)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteNotification)
            }
    }
    
    /// 広告を削除
    /// - Parameters:
    ///   - document: ドキュメント
    /// - Returns: なし
    func deleteAdvertisement(document: String) {
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.advertisements)
            .document(document)
            .delete { error in
                self.handleNetworkError(error: error, errorMessage: String.failureDeleteAdvertisement)
            }
    }
    
    /// 画像を削除
    /// - Parameters:
    ///   - withPath: 削除するパス
    /// - Returns: なし
    func deleteImage(withPath: String) {
        if let stringImage = currentUser?.profileImageUrl {
            // 画像が設定されていない場合、この処理をスキップする。
            if stringImage != "" {
                let ref = FirebaseManager.shared.storage.reference(withPath: withPath)
                ref.delete { error in
                    self.handleNetworkError(error: error, errorMessage: String.failureDeleteImage)
                }
            }
        }
    }
    
    /// 認証情報削除
    /// - Parameters: なし
    /// - Returns: なし
    func deleteAuth() {
        FirebaseManager.shared.auth.currentUser?.delete { error in
            self.handleNetworkError(error: error, errorMessage: String.failureDeleteAuth)
        }
    }
    
    /// サインイン失敗時のデータ削除
    /// - Parameters: なし
    /// - Returns: なし
    //    func deleteData() {
    //        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
    //        // ユーザー情報削除
    //        deleteUser(document: uid)
    //        // 画像削除
    //        deleteImage(withPath: uid)
    //        // 認証情報削除
    //        deleteAuth()
    //    }
    
    // MARK: - Other
    
    /// QRコードを生成する
    /// - Parameters:
    ///   - inputText: QRコードの生成に使用するテキスト
    /// - Returns: QRコード画像
    func generateQRCode(inputText: String) -> UIImage? {
        
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }
        
        let inputData = inputText.data(using: .utf8)
        qrFilter.setValue(inputData, forKey: "inputMessage")
        // 誤り訂正レベルをHに指定
        qrFilter.setValue("L", forKey: "inputCorrectionLevel")
        
        guard let ciImage = qrFilter.outputImage else { return nil }
        
        // CIImageは小さい為、任意のサイズに拡大。
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCiImage = ciImage.transformed(by: sizeTransform)
        
        // CIImageだとSwiftUIのImageでは表示されない為、CGImageに変換。
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledCiImage,
                                                  from: scaledCiImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    
    /// Date型を日付のみ取り出す
    /// - Parameters:
    ///   - date: 変換する日付
    /// - Returns: 日付のみのDate
    func dateFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Date型を時刻のみ取り出す
    /// - Parameters:
    ///   - date: 変換する日付
    /// - Returns: 時刻のみのDate
    func hourFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
