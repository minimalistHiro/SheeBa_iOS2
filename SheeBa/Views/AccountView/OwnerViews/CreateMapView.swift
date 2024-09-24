//
//  CreateMapView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/09/24.
//

import SwiftUI
import MapKit

struct CreateMapView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = ViewModel()
    @State private var pinItems = [PinItem]()               // ピンアイテム
    @State private var region = MKCoordinateRegion()        // 座標領域
    
    @Binding var pointX: String
    @Binding var pointY: String
    
    var body: some View {
        if #available(iOS 17.0, *) {
            MapReader { reader in
                ZStack {
                    Map()
                        .onTapGesture(perform: { screenLocation in
                            guard let location = reader.convert(screenLocation, from: .local) else { return }
                            pointX = String(location.latitude)
                            pointY = String(location.longitude)
                            print("tapped point: ", location)
                        })
                    
                    VStack {
                        Spacer()
                        
                        // 店舗座標の確定
                        if pointX != "" && pointY != "" {
                            Button {
                                dismiss()
                            } label: {
                                CustomCapsule(text: "確定", imageSystemName: nil, foregroundColor: .blue, textColor: .white, isStroke: false)
                            }
                            .padding(.bottom)
                        }
                    }
                }
                .asCloseButton()
            }
            .onAppear {
                setRegion(coordinate: CLLocationCoordinate2D(latitude: Setting.mapLatitude, longitude: Setting.mapLongitude))
            }
        } else {
            Text("iOS17にアップデートしてください。")
        }
    }
    
    // MARK: - 引数で取得した緯度経度を使って動的に表示領域の中心位置と、縮尺を決める。
    /// - Parameters:
    ///   - coordinate: 中心座標初期値
    /// - Returns: なし
    private func setRegion(coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(center: coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        )
    }
}

#Preview {
    CreateMapView(pointX: .constant(""), pointY: .constant(""))
}
