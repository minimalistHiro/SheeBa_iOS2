//
//  StoreDetailView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/04/07.
//

import SwiftUI

struct StoreDetailView: View {
    
    @ObservedObject var vm = ViewModel()
    let store: ChatUser?
    
    var body: some View {
        NavigationStack {
            List {
                // トップ画像
                HStack {
                    Spacer()
                    if let image = store?.profileImageUrl, image != ""  {
                        Icon.CustomWebImage(imageSize: .large, image: image)
                    } else {
                        Icon.CustomCircle(imageSize: .large)
                    }
                    Spacer()
                }
                .padding()
                .listRowSeparator(.hidden)
                
                // 店舗名
                HStack {
                    Spacer()
                    Text(store?.username ?? "芝店舗")
                        .foregroundStyle(Color.black)
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                
                // 電話番号
                HStack {
                    Text("ジャンル")
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    Text(store?.genre ?? "-")
                }
                
                // 電話番号
                HStack {
                    Text("電話番号")
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    if let phoneNumber = store?.phoneNumber, phoneNumber != "" {
                        Button {
                            UIApplication.shared.open(URL(string: "tel://" + phoneNumber)!)
                        } label: {
                            Text(phoneNumber)
                                .foregroundStyle(Color.blue)
                        }
                    }
                }
                
                // Webサイト
                HStack {
                    Text("Webサイト")
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    if let webURL = store?.webURL, webURL != "" {
                        Button {
                            UIApplication.shared.open(URL(string: webURL)!)
                        } label: {
                            Text(webURL)
                                .foregroundStyle(Color.blue)
                        }
                    }
                }
                
                // 紹介動画
                HStack {
                    Text("紹介動画")
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    if let movieURL = store?.movieURL, movieURL != "" {
                        Button {
                            UIApplication.shared.open(URL(string: movieURL)!)
                        } label: {
                            Text(movieURL)
                                .foregroundStyle(Color.blue)
                        }
                    }
                }
            }
            .padding(.horizontal, 7)
            .listStyle(.inset)
            .environment(\.defaultMinListRowHeight, 60)
        }
        .navigationTitle(store?.username ?? "謎の店舗")
        .asBackButton()
    }
}

#Preview {
    StoreDetailView(store: nil)
}
