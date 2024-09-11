//
//  CreateNotificationView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/12.
//

import SwiftUI
import FirebaseFirestore
import UserNotifications

struct CreateNotificationView: View {
    
    @FocusState var focus: Bool
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @ObservedObject var userSetting = UserSetting()
    @State private var title = ""                           // タイトル
    @State private var text = ""                            // テキスト
    @State private var url = ""                             // URL
    @State private var image: UIImage?                      // 画像
    @State private var isShowImagePicker = false            // ImagePicker表示有無
    @State private var isShowCreateNotification = false     // お知らせ作成アラート
    
    // View
    let imageFrameWidth: CGFloat = 100                      // 画像幅
    let imageFrameHeight: CGFloat = 100                     // 画像高さ
    let imageCornerSize: CGFloat = 5                        // コーナーサイズ
    let imageStroke: CGFloat = 3                            // 枠の太さ
    
    // ボタンの有効性
    var disabled: Bool {
        title.isEmpty || text.isEmpty
    }
    
    var body: some View {
        NavigationStack {
//            ScrollView {
                VStack {
                    Spacer()
                    
                    InputText.InputTextField(focus: $focus, editText: $title, titleText: "タイトル", textType: .other)
                    
                    InputText.InputTextField(focus: $focus, editText: $url, titleText: "URL", textType: .url)
                    
                    Spacer()
                    
                    TextEditor(text: $text)
                        .frame(width: 300, height: 150)
                        .border(.black)
                        .focused($focus.projectedValue)
                    
                    Spacer()
                    
                    // 画像
                    Button {
                        isShowImagePicker.toggle()
                    } label: {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageFrameWidth, height: imageFrameHeight)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: imageCornerSize, height: imageCornerSize)))
                                .overlay {
                                    RoundedRectangle(cornerSize: CGSize(width: imageCornerSize, height: imageCornerSize))
                                        .stroke(.black, lineWidth: imageStroke)
                                        .frame(width: imageFrameWidth, height: imageFrameHeight)
                                }
//                                .padding()
                        } else {
                            RoundedRectangle(cornerSize: CGSize(width: imageCornerSize, height: imageCornerSize))
                                .stroke(.black , lineWidth: imageStroke)
                                .frame(width: imageFrameWidth, height: imageFrameHeight)
                                .overlay {
                                    RoundedRectangle(cornerSize: CGSize(width: imageCornerSize, height: imageCornerSize))
                                        .frame(width: imageFrameWidth - 3, height: imageFrameHeight - 3)
                                        .foregroundStyle(Color.chatLogBackground)
                                }
                                .overlay {
                                    Text("画像を選択してください")
                                }
//                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        if image == nil {
                            persistNotifications(imageUrl: nil)
                        } else {
                            persistImage(image: image)
                        }
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]){
                            (granted, error) in
                            if granted {
                                //通知が許可されている場合の処理
                                makeNotification(title: title, body: text)
                            } else {
                                //通知が拒否されている場合、1秒後に表示を戻す
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    print("通知を送れませんでした。")
                                }
                            }
                        }
                    } label: {
                        CustomCapsule(text: "送信", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                    }
                    .disabled(disabled)
                    
                    Spacer()
                }
//            }
            // タップでキーボードを閉じるようにするため
            .contentShape(Rectangle())
            .onTapGesture {
                focus = false
            }
            .overlay {
                ScaleEffectIndicator(onIndicator: $vm.onIndicator)
            }
            .background(Color.sheebaYellow)
        }
        .navigationTitle("お知らせを作成")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if FirebaseManager.shared.auth.currentUser?.uid != nil {
                vm.fetchCurrentUser()
                vm.fetchAllUsersContainSelf()
            }
        }
        .fullScreenCover(isPresented: $isShowImagePicker) {
            ImagePicker(selectedImage: $image)
        }
        .asSingleAlert(title: "",
                       isShowAlert: $isShowCreateNotification,
                       message: "送信しました。",
                       didAction: {
            isShowCreateNotification = false
            dismiss()
        })
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
        .asBackButton()
    }
    
    // MARK: - お知らせを全ユーザーに保存
    /// - Parameters:
    ///   - imageUrl: 画像URL
    /// - Returns: なし
    private func persistNotifications(imageUrl: URL?) {
        vm.onIndicator = true
        
        let data = [
            FirebaseConstants.title: title,
            FirebaseConstants.text: text,
            FirebaseConstants.isRead: false,
            FirebaseConstants.url: url,
            FirebaseConstants.imageUrl: imageUrl?.absoluteString ?? "",
            FirebaseConstants.timestamp: Timestamp(),
        ] as [String : Any]
        
        for user in vm.allUsersContainSelf {
            vm.persistNotification(document1: user.uid, document2: title, data: data)
        }
        
        vm.onIndicator = false
        self.isShowCreateNotification = true
    }
    
    // MARK: - 画像を保存
    /// - Parameters:
    ///   - image: 画像
    /// - Returns: なし
    func persistImage(image: UIImage?) {
        let ref = FirebaseManager.shared.storage.reference(withPath: title)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        
        ref.putData(imageData, metadata: nil) { _, error in
            if error != nil {
                vm.handleError("画像の保存に失敗しました。", error: error)
                return
            }
            // Firestore Databaseに保存するためにURLをダウンロードする。
            ref.downloadURL { url, error in
                if error != nil {
                    vm.handleError("画像URLの取得に失敗しました。", error: error)
                    return
                }
                guard let url = url else { return }
                persistNotifications(imageUrl: url)
            }
        }
    }
    
    // MARK: - 通知を作成
    /// - Parameters:
    ///   - title: タイトル
    ///   - body: 通知テキスト
    /// - Returns: なし
    private func makeNotification(title: String, body: String) {
        //通知タイミングを指定
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
//        var badge = NSNu
        //通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        userSetting.badgeCount = content.badge as! Int
        
        //通知リクエストを作成
        let request = UNNotificationRequest(identifier: title, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

#Preview {
    CreateNotificationView()
}
