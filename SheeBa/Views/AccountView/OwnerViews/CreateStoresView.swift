//
//  CreateStoresView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/09/17.
//

import SwiftUI

import SwiftUI

struct CreateStoresView: View {
    
    @FocusState var focus: Bool
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var isShowImagePicker = false            // ImagePicker表示有無
    @State private var isShowMap = false                    // Mapの表示有無
    @State private var isShowCreateSuccessAlert = false     // 作成完了アラート
    
    // 変更する変数
    @State private var uid = ""                             // UID
    @State private var uiImage: UIImage?                    // トップ画像
    @State private var isEnableScan = false                 // スキャンの可否
//    @State private var profileImageUrl = ""                 // プロフィール画像
    @State private var storename = ""                       // 店舗名
    @State private var no = "0"                             // 店舗番号
    @State private var getPoint = "0"                       // 獲得ポイント
    @State private var genre = ""                           // ジャンル
    @State private var phoneNumber = ""                     // 電話番号
    @State private var webURL = ""                          // Webサイト
    @State private var movieURL = ""                        // 紹介動画
    @State private var pointX = ""                          // X座標
    @State private var pointY = ""                          // Y座標
    
    // ボタンの有効性
    var disabled: Bool {
        uid.isEmpty || no.isEmpty || getPoint.isEmpty || genre.isEmpty || pointX.isEmpty || pointY.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Button {
                        isShowImagePicker.toggle()
                    } label: {
                        if let uiImage = uiImage {
                            Icon.CustomImage(imageSize: .xLarge, image: uiImage)
                        } else {
                            Icon.CustomCircle(imageSize: .xLarge)
                        }
                    }
                    
                    // UID
                    HStack {
                        Text("UID")
                        Spacer()
                        Text(uid)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .frame(width: 250)
                    }
                    .padding()
                    
                    // 店舗名
                    HStack {
                        Text("店舗名")
                        Spacer()
                        TextField("店舗名", text: $storename)
                            .focused($focus)
                            .frame(width: 250)
                    }
                    .padding()
                    
                    // 店舗番号
                    HStack {
                        Text("店舗番号")
                        Spacer()
                        TextField("店舗番号", text: $no)
                            .keyboardType(.numberPad)
                            .focused($focus)
                            .frame(width: 20)
                    }
                    .padding()
                    
                    // スキャンの可否
                    Toggle(isOn: $isEnableScan, label: {
                        Text("スキャンの可否")
                    })
                    .padding()
                    
                    // 獲得ポイント数
                    HStack {
                        Text("獲得ポイント数")
                        Spacer()
                        TextField("獲得ポイント数", text: $getPoint)
                            .keyboardType(.numberPad)
                            .focused($focus)
                            .frame(width: 20)
                    }
                    .padding()
                    
//                    TextField("獲得ポイント", text: $getPoint)
//                        .keyboardType(.numberPad)
//                        .focused($focus)
//                        .frame(width: 20)
//                        .padding()
                    
                    // ジャンル
//                    HStack {
//                        Text("ジャンル")
//                        Spacer()
//                        TextField("ジャンル", text: $genre)
//                            .focused($focus)
//                            .frame(width: 100)
//                    }
                    InputText.InputPicker(editText: $genre, titleText: "ジャンル", explanationText: "店舗ジャンルを選択してください", pickers: genres)
                        .frame(width: 300)
                    
                    // 電話番号
                    HStack {
                        Text("電話番号")
                        Spacer()
                        TextField("電話番号", text: $phoneNumber)
                            .focused($focus)
                            .frame(width: 150)
                    }
                    .padding()
                    
                    // Webサイト
                    HStack {
                        Text("Webサイト")
                        Spacer()
                        TextField("Webサイト", text: $webURL)
                            .focused($focus)
                            .frame(width: 150)
                    }
                    .padding()
                    
                    // 紹介動画
                    HStack {
                        Text("紹介動画")
                        Spacer()
                        TextField("紹介動画", text: $movieURL)
                            .focused($focus)
                            .frame(width: 150)
                    }
                    .padding()
                    
                    // 店舗座標の確定
                    Button {
                        isShowMap = true
                    } label: {
                        CustomCapsule(text: "店舗位置を設定", imageSystemName: nil, foregroundColor: .black, textColor: .white, isStroke: false)
                    }
                    .padding(.bottom)
                    
                    // X座標
                    HStack {
                        Text("X座標")
                        Spacer()
                        Text(pointX)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .frame(width: 250)
                    }
                    .padding()
                    
                    // Y座標
                    HStack {
                        Text("Y座標")
                        Spacer()
                        Text(pointY)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .frame(width: 250)
                    }
                    .padding()
                    
                    Button {
                        if let image = uiImage {
                            persistImage(image: image)
                        } else {
                            persistStore(imageUrl: nil)
                        }
                    } label: {
                        CustomCapsule(text: "作成", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                    }
                    .disabled(disabled)
                    .padding(.bottom)
                }
            }
        }
        .onAppear {
            uid = generator(30)
        }
        .asBackButton()
        .navigationTitle("新規店舗を作成")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowImagePicker) {
            ImagePicker(selectedImage: $uiImage)
        }
        .fullScreenCover(isPresented: $isShowMap) {
            CreateMapView(pointX: $pointX, pointY: $pointY)
        }
        .asSingleAlert(title: "",
                       isShowAlert: $vm.isShowError,
                       message: vm.errorMessage,
                       didAction: { vm.isShowError = false })
        .asSingleAlert(title: "",
                       isShowAlert: $isShowCreateSuccessAlert,
                       message: "作成しました。",
                       didAction: {
            isShowCreateSuccessAlert = false
            dismiss()
        })
    }
    
    // MARK: - ランダムな文字列を作成
    /// - Parameters: なし
    /// - Returns: なし
    func generator(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 0 ..< length {
            randomString += String(letters.randomElement()!)
        }
        return randomString
    }
    
    // MARK: - 店舗を保存
    /// - Parameters:
    ///   - imageUrl: 画像URL
    /// - Returns: なし
    private func persistStore(imageUrl: URL?) {
        vm.onIndicator = true
        
        let data = [
            FirebaseConstants.uid: uid,
            FirebaseConstants.storename: storename,
            FirebaseConstants.no: no,
            FirebaseConstants.genre: genre,
            FirebaseConstants.phoneNumber: phoneNumber,
            FirebaseConstants.webURL: webURL,
            FirebaseConstants.movieURL: movieURL,
            FirebaseConstants.profileImageUrl: imageUrl?.absoluteString ?? "",
            FirebaseConstants.getPoint: Int(getPoint) ?? 1,
            FirebaseConstants.isEnableScan: isEnableScan,
            FirebaseConstants.pointX: pointX,
            FirebaseConstants.pointY: pointY,
        ] as [String : Any]
        
        vm.persistStore(document: uid, data: data)
        
        vm.onIndicator = false
        self.isShowCreateSuccessAlert = true
    }
    
    // MARK: - 画像を保存
    /// - Parameters:
    ///   - image: トップ画像
    /// - Returns: なし
    private func persistImage(image: UIImage?) {
        vm.onIndicator = true
        
        let ref = FirebaseManager.shared.storage.reference(withPath: "\(FirebaseConstants.stores)/\(uid)")
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
                persistStore(imageUrl: url)
            }
        }
    }
}

#Preview {
    CreateStoresView()
}
