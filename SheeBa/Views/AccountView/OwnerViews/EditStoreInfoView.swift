//
//  EditStoreInfoView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/20.
//

import SwiftUI

struct EditStoreInfoView: View {
    
    @FocusState var focus: Bool
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var isShowImagePicker = false            // ImagePicker表示有無
    @State private var isShowMap = false                    // Mapの表示有無
    @State private var isShowChangeSuccessAlert = false     // 変更確定アラート
    @State private var isShowConfirmDeleteAlert = false     // 削除確認アラート
    @State private var isShowActivityView = false           // アクティビティ画面表示有無
    @State private var qrCodeImage: UIImage?                // QRコード画像
    @State private var shareImage: UIImage?                 // シェア画面用画像
    @State private var rect: CGRect = .zero                 // スキャン範囲
    
    // 変更する変数
    let store: Stores
    @State private var uid = ""                             // UID
    @State private var uiImage: UIImage?                    // トップ画像
    @State private var isEnableScan = false                 // スキャンの可否
    @State private var isEvent = false                      // イベント専用か否か
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
        getPoint.isEmpty
    }
    
    // シェアボタンの有効性
    var disabledShareButton: Bool {
        qrCodeImage == nil
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
                                .overlay {
                                    Icon.CustomImageChangeCircle(imageSize: .xLarge)
                                }
                        } else {
                            if store.profileImageUrl != "" {
                                Icon.CustomWebImage(imageSize: .xLarge, image: store.profileImageUrl)
                                    .overlay {
                                        Icon.CustomImageChangeCircle(imageSize: .xLarge)
                                    }
                            } else {
                                Icon.CustomCircle(imageSize: .xLarge)
                                    .overlay {
                                        Icon.CustomImageChangeCircle(imageSize: .xLarge)
                                    }
                            }
                        }
                    }
                    
                    // UID
                    HStack {
                        Text("UID")
                        Spacer()
                        Text(store.uid)
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .frame(width: 250)
                    }
                    .padding()
                    
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: 180, height: 180)
                        .cornerRadius(20)
                        .shadow(radius: 7, x: 0, y: 0)
                        .background(RectangleGetter(rect: $rect))
                        .overlay {
                            VStack {
                                if vm.onIndicator {
                                    ScaleEffectIndicator(onIndicator: $vm.onIndicator)
                                } else {
                                    if let qrCodeImage {
                                        Image(uiImage: qrCodeImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                    } else {
                                        VStack {
                                            Text("データを読み込めませんでした。")
                                                .font(.callout)
                                            Button {
                                                qrCodeImage = vm.generateQRCode(inputText: store.uid)
                                            } label: {
                                                Image(systemName: "arrow.clockwise")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20)
                                            }
                                        }
                                        .frame(width: 150, height: 150)
                                    }
                                }
                            }
                        }
                    
                    Button {
                        let scenes = UIApplication.shared.connectedScenes
                        let windowScenes = scenes.first as? UIWindowScene
                        if let uiImage = windowScenes?.windows[0].rootViewController?.view!.getImage(rect: self.rect) {
                            self.shareImage = uiImage
                            isShowActivityView = true
                        }
                    } label: {
                        CustomCapsule(text: "QRコードを共有", imageSystemName: "square.and.arrow.up", foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                    }
                    .disabled(disabledShareButton)
                    
                    // 店舗名
                    HStack {
                        Text("店舗名")
                        Spacer()
                        TextField("店舗名", text: $storename)
                            .focused($focus)
                            .frame(width: 250)
                    }
                    .padding()
                    
                    // イベント専用店舗
                    Toggle(isOn: $isEvent, label: {
                        Text("イベント専用")
                    })
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
                            persistAndDeleteImage(image: image)
                        } else {
                            updateStoreInfo(store: store, imageUrl: nil)
                        }
                    } label: {
                        CustomCapsule(text: "変更", imageSystemName: nil, foregroundColor: disabled ? .gray : .black, textColor: .white, isStroke: false)
                    }
                    .disabled(disabled)
                    .padding(.bottom)
                    
                    Button {
                        isShowConfirmDeleteAlert = true
                    } label: {
                        CustomCapsule(text: "店舗を削除", imageSystemName: nil, foregroundColor: .red, textColor: .white, isStroke: false)
                    }
                    .padding(.bottom)
                }
            }
        }
        .onAppear {
            storename = store.storename
            no = String(store.no)
            isEnableScan = store.isEnableScan
            isEvent = store.isEvent
            getPoint = String(store.getPoint)
            genre = store.genre
            phoneNumber = store.phoneNumber
            webURL = store.webURL
            movieURL = store.movieURL
            pointX = store.pointX
            pointY = store.pointY
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.qrCodeImage = vm.generateQRCode(inputText: store.uid)
            }
        }
        .sheet(isPresented: $isShowActivityView) {
            ActivityView(activityItems: [shareImage as Any], applicationActivities: nil)
        }
        .asBackButton()
        .navigationTitle("店舗情報を変更")
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
                       isShowAlert: $isShowChangeSuccessAlert,
                       message: "変更しました。",
                       didAction: {
            isShowChangeSuccessAlert = false
            dismiss()
        })
        .asDestructiveAlert(title: "",
                            isShowAlert: $isShowConfirmDeleteAlert,
                            message: "この店舗を削除しますか？",
                            buttonText: "削除",
                            didAction: {
            deleteStore()
            dismiss()
            isShowConfirmDeleteAlert = false
        })
    }
    
    // MARK: - 店舗ユーザーの情報を更新
    /// - Parameters: なし
    /// - Returns: なし
    private func updateStoreInfo(store: Stores, imageUrl: URL?) {
        vm.onIndicator = true
        var data: [String: Any] = [:]
        
        if uiImage != nil {
            data = [
                FirebaseConstants.storename: storename,
                FirebaseConstants.no: Int(no) ?? 0,
                FirebaseConstants.genre: genre,
                FirebaseConstants.phoneNumber: phoneNumber,
                FirebaseConstants.webURL: webURL,
                FirebaseConstants.movieURL: movieURL,
                FirebaseConstants.profileImageUrl: imageUrl?.absoluteString ?? "",
                FirebaseConstants.getPoint: Int(getPoint) ?? 1,
                FirebaseConstants.isEnableScan: isEnableScan,
                FirebaseConstants.isEvent: isEvent,
                FirebaseConstants.pointX: pointX,
                FirebaseConstants.pointY: pointY,
            ]
        } else {
            data = [
                FirebaseConstants.storename: storename,
                FirebaseConstants.no: Int(no) ?? 0,
                FirebaseConstants.genre: genre,
                FirebaseConstants.phoneNumber: phoneNumber,
                FirebaseConstants.webURL: webURL,
                FirebaseConstants.movieURL: movieURL,
                FirebaseConstants.getPoint: Int(getPoint) ?? 1,
                FirebaseConstants.isEnableScan: isEnableScan,
                FirebaseConstants.isEvent: isEvent,
                FirebaseConstants.pointX: pointX,
                FirebaseConstants.pointY: pointY,
            ]
        }
        // ユーザー情報を更新
        vm.updateStore(document: store.uid, data: data)
        
        vm.onIndicator = false
        isShowChangeSuccessAlert = true
    }
    
    // MARK: - 画像を保存
    /// - Parameters:
    ///   - image: トップ画像
    /// - Returns: なし
    private func persistAndDeleteImage(image: UIImage?) {
        vm.onIndicator = true
        let path = "\(FirebaseConstants.stores)/\(store.uid)"
        
        // 画像削除
        vm.deleteImage(withPath: path)
        
        let ref = FirebaseManager.shared.storage.reference(withPath: path)
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
                updateStoreInfo(store: store, imageUrl: url)
            }
        }
    }
    
    // MARK: - 店舗を削除
    /// - Parameters: なし
    /// - Returns: なし
    private func deleteStore() {
        // 画像削除
        vm.deleteImage(withPath: "\(FirebaseConstants.stores)/\(store.uid)")
        
        // ユーザー情報削除
        vm.deleteStore(document: store.uid)
    }
}

#Preview {
    EditStoreInfoView(store: previewOfStores)
}
