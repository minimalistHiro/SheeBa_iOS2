//
//  NotConfirmEmailView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/07.
//

import SwiftUI

struct NotConfirmEmailView: View {
    
    @FocusState var focus: Bool
    @ObservedObject var vm: ViewModel
    let didCompleteLoginProcess: () -> ()
    @State private var isShowPassword = false           // パスワード表示有無
    @State private var isShowConfirmationSignOutAlert = false           // サインアウト確認アラート
    @State private var isShowConfirmationWithdrawalAlert = false        // 退会確認アラート
    
    // DB
    @State private var email: String = ""               // メールアドレス
    @State private var password: String = ""            // パスワード
    
    init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
        self.vm = .init(didCompleteLoginProcess: didCompleteLoginProcess)
    }
    
    // ボタンの有効性
    var disabled: Bool {
        email.isEmpty || password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("メールアドレス、パスワードを入力し、「メール送信」ボタンを押してメールアドレス認証を完了してください。")
                    .lineSpacing(10)
                    .font(.callout)
                    .dynamicTypeSize(.medium)
                    .padding(.horizontal)
                
                Spacer()
                
                InputText.InputTextField(focus: $focus, editText: $email, titleText: "メールアドレス", textType: .email)
                
                InputText.InputPasswordTextField(focus: $focus, editText: $password, titleText: "パスワード", isShowPassword: $isShowPassword)
                
                Spacer()
                
                Button {
                    vm.handleSignInWithEmailVerification(email: email, password: password)
                } label: {
                    CustomCapsule(text: "メール送信", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                }
                .disabled(disabled)
                
                Spacer()
                
                Spacer()
                
//                Button {
//                    isShowConfirmationWithdrawalAlert = true
//                } label: {
//                    Text("データ削除")
//                        .foregroundStyle(.red)
//                }
                
//                Spacer()
                Spacer()
            }
            // タップでキーボードを閉じるようにするため
            .contentShape(Rectangle())
            .onTapGesture {
                focus = false
            }
            .navigationTitle("メールアドレス認証")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
            .navigationDestination(isPresented: $vm.isNavigateConfirmEmailView) {
                ConfirmEmailView(email: $email, password: $password, didCompleteLoginProcess: didCompleteLoginProcess)
            }
            .background(Color.sheebaYellow)
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
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
                            message: "データを削除しますか？",
                            buttonText: "データ削除",
                            didAction: {
            handleWithdrawal()
            //            DispatchQueue.main.async {
            //                isShowConfirmationWithdrawalAlert = false
            //            }
//                        isShowSuccessWithdrawalAlert = true
        })
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
        
        // 画像削除
        vm.deleteImage(withPath: uid)
        
        isShowConfirmationWithdrawalAlert = false
    }
    
    // MARK: - サインアウト
    /// - Parameters: なし
    /// - Returns: なし
    private func handleSignOut() {
        try? FirebaseManager.shared.auth.signOut()
    }
}

#Preview {
    NotConfirmEmailView(didCompleteLoginProcess: {})
}
