//
//  MapView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/29.
//

import SwiftUI
import MapKit

struct PinItem: Identifiable {
    let id = UUID()
    let uid: String
    let coordinate: CLLocationCoordinate2D
    let buttonSize: CGFloat
    let imageUrl: String
}

struct MapView: View {
    
    @ObservedObject var vm = ViewModel()
    @State private var storeUsers = [ChatUser]()            // 全店舗ユーザー
    @State private var pinItems = [PinItem]()               // ピンアイテム
    @State private var region = MKCoordinateRegion()        // 座標領域
    @State private var selectedStoreUid = ""                //選択された店舗UID
//    @State private var userTrackingMode: MapUserTrackingMode = .none
    @State private var isShowStoreInfo = false              // 店舗情報表示有無
    let defaultButtonSize: CGFloat = 70                    // 縮小時の店舗ボタンサイズ
    @State private var buttonSize: CGFloat = 70            // 店舗ボタンサイズ
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: .none,
                annotationItems:
                    //                    [
                //                    PinItem(coordinate: .init(latitude: 35.83054, longitude: 139.69210), buttonSize: defaultButtonSize),       // ココシバ
                //                    PinItem(coordinate: .init(latitude: 35.83071, longitude: 139.69208), buttonSize: defaultButtonSize),       // 平川インテリア
                //                ]
                pinItems
                ,
                annotationContent: { item in
                MapAnnotation(
                    coordinate: item.coordinate,
                    anchorPoint: CGPoint(x: 0.5, y: 1)
                ) {
                    Button {
                        isShowStoreInfo = true
                        selectedStoreUid = item.uid
                        vm.fetchUser(uid: item.uid)
                    } label: {
                        MapPin(rect: CGRect(
                            x: 0,
                            y: 0,
                            width: (isShowStoreInfo && item.uid == selectedStoreUid) ? item.buttonSize * 2 : item.buttonSize,
                            height: (isShowStoreInfo && item.uid == selectedStoreUid) ? item.buttonSize * 2 : item.buttonSize),
                               image: item.imageUrl)
                        .frame(width: (isShowStoreInfo && item.uid == selectedStoreUid) ? item.buttonSize * 2 : item.buttonSize,
                               height: (isShowStoreInfo && item.uid == selectedStoreUid) ? item.buttonSize * 2 : item.buttonSize)
                        .shadow(radius: 4)
                    }
                }
            })
            
            // 店舗詳細画面
            VStack {
                Spacer()
                
                if isShowStoreInfo {
                    Rectangle()
                        .foregroundColor(Color.white)
                        .frame(width: 300, height: 200)
                        .cornerRadius(20)
                        .shadow(radius: 5, x: 0, y: 0)
                        .overlay {
                            VStack {
                                // クローズボタン
                                HStack {
                                    Spacer()
                                    Button {
                                        isShowStoreInfo = false
                                    } label: {
                                        Circle()
                                            .frame(width: 30, height: 20)
                                            .foregroundStyle(Color.white)
                                            .overlay {
                                                Image(systemName: "multiply")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                                    .bold()
                                                    .foregroundColor(.black)
                                            }
                                    }
                                    .padding(.top)
                                    .padding(.trailing)
                                }
                                
                                HStack {
                                    Spacer()
                                    
                                    // トップ画像
                                    if let image = vm.chatUser?.profileImageUrl, image != ""  {
                                        Icon.CustomWebImage(imageSize: .medium, image: image)
                                    } else {
                                        Icon.CustomCircle(imageSize: .medium)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(vm.chatUser?.username ?? "芝店舗")
                                        .font(.headline)
                                        .bold()
                                        .dynamicTypeSize(.medium)
                                        .padding()
                                    
                                    Spacer()
                                }
                                Spacer()
                                
                                // 詳細ボタン
                                NavigationLink {
                                    StoreDetailView(store: vm.chatUser)
                                } label: {
                                    CustomCapsule(text: "詳細を見る",
                                                  imageSystemName: nil,
                                                  foregroundColor: Color.black,
                                                  textColor: Color.white,
                                                  isStroke: false)
                                }
                                .padding(.bottom)
                            }
                        }
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            setRegion(coordinate: CLLocationCoordinate2D(latitude: Setting.mapLatitude, longitude: Setting.mapLongitude))
            DispatchQueue.main.async {
                fetchAllStoreUsers()
            }
        }
    }
            
//        .onChange(of: isShowStoreInfo) { value in
//            value ? (buttonSize = defaultButtonSize * 2) : (buttonSize = defaultButtonSize * 1)
//        }
    
    // MARK: - 引数で取得した緯度経度を使って動的に表示領域の中心位置と、縮尺を決める。
    /// - Parameters:
    ///   - coordinate: 中心座標初期値
    /// - Returns: なし
    private func setRegion(coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(center: coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        )
    }
    
    // MARK: - 全店舗ユーザーを取得
    /// - Parameters: なし
    /// - Returns: なし
    private func fetchAllStoreUsers() {
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
                    
                    // 追加するユーザーが店舗で且つ、SheeBa対応店舗の場合のみ追加する。
                    if user.isStore, user.isEnableScan{
                        storeUsers.append(.init(data: data))
                    }
                })
                storeUsers.sort(by: {$0.no < $1.no})
                fetchPinItems()
            }
    }
    
    // MARK: - 全店舗のピン情報を取得
    /// - Parameters: なし
    /// - Returns: なし
    private func fetchPinItems() {
        pinItems.removeAll()
        
        for storeUser in storeUsers {
            if storeUser.pointX != "" || storeUser.pointY != "" {
                // 取得に失敗した場合、蕨駅の座標を取得。取得したY座標は、中心位置調整のため少しずらす。
                pinItems.append(PinItem(uid: storeUser.uid,
                                        coordinate:
                        .init(latitude: Double(storeUser.pointY) ?? 139.69033,
                              longitude: Double(storeUser.pointX) ?? 35.82809),
                                        buttonSize: defaultButtonSize,
                                        imageUrl: storeUser.profileImageUrl))
            }
        }
    }
}

#Preview {
    MapView()
}
