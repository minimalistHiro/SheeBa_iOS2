//
//  StoreDetailView.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/04/07.
//

import SwiftUI

struct StoreDetailView: View {
    
    @ObservedObject var vm = ViewModel()
    let store: Stores?
    
    var body: some View {
        NavigationStack {
            ScrollView {
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
                    Text(store?.storename ?? "芝店舗")
                        .foregroundStyle(Color.black)
                        .font(.title3)
                        .bold()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                
                // 紹介テキスト
                Text(store?.profile ?? "")
                    .padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                    .font(.callout)
                    .listRowSeparator(.hidden)
                    .padding(.bottom)
                
                // WEBサイト
                if let webURL = store?.webURL, webURL != "" {
                    Button {
                        UIApplication.shared.open(URL(string: webURL)!)
                    } label: {
                        Text(webURL)
                            .foregroundStyle(Color.blue)
                    }
                    .listRowSeparator(.hidden)
                    .padding(.bottom)
                }
                
                // 電話番号
                if let phoneNumber = store?.phoneNumber, phoneNumber != "" {
                    Button {
                        UIApplication.shared.open(URL(string: "tel://" + phoneNumber)!)
                    } label: {
                        CustomCapsule(text: "電話をかける", imageSystemName: "phone", foregroundColor: Color.red, textColor: Color.white, isStroke: false)
                    }
                    .listRowSeparator(.hidden)
                    .padding(.bottom)
                }
                
                HStack {
                    Spacer()
                    // Xアイコン
                    if let xURL = store?.xURL, xURL != "" {
                        if let image = UIImage(named: "x")  {
                            Button {
                                UIApplication.shared.open(URL(string: xURL)!)
                            } label: {
                                Icon.CustomImage(imageSize: .medium, image: image)
                            }
                        } else {
                            Icon.CustomCircle(imageSize: .large)
                        }
                    }
                    Spacer()
                    // Instagramアイコン
                    if let instagramURL = store?.instagramURL, instagramURL != "" {
                        if let image = UIImage(named: "instagram")  {
                            Button {
                                UIApplication.shared.open(URL(string: instagramURL)!)
                            } label: {
                                Icon.CustomImage(imageSize: .medium, image: image)
                            }
                        } else {
                            Icon.CustomCircle(imageSize: .large)
                        }
                    }
                    Spacer()
                    // facebookアイコン
                    if let facebookURL = store?.facebookURL, facebookURL != "" {
                        if let image = UIImage(named: "facebook")  {
                            Button {
                                UIApplication.shared.open(URL(string: facebookURL)!)
                            } label: {
                                Icon.CustomImage(imageSize: .medium, image: image)
                            }
                        } else {
                            Icon.CustomCircle(imageSize: .large)
                        }
                    }
                    Spacer()
                }
                .padding(.bottom)
                .listRowSeparator(.hidden)
                
                // ジャンル
                CustomListText(label: "ジャンル", text: store?.genre ?? "-")
                CustomListRectangle()
                
                // 住所
                CustomListText(label: "住所", text: store?.address ?? "-")
                CustomListRectangle()
                
                // 紹介動画
                HStack {
                    Text("紹介動画")
                        .foregroundStyle(Color.black)
                        .opacity(0.5)
                        .font(.callout)
                        .padding(.trailing, 30)
                    
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
                .padding()
            }
            .padding(.horizontal, 7)
            .listStyle(.inset)
            .environment(\.defaultMinListRowHeight, 60)
        }
        .navigationTitle(store?.storename ?? "謎の店舗")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // CustomListText
    struct CustomListText: View {
        
        let label: String
        let text: String
        
        var body: some View {
            HStack {
                Text(label)
                    .foregroundStyle(Color.black)
                    .opacity(0.5)
                    .font(.callout)
                    .padding(.trailing, 30)
                
                Spacer()
                
                Text(text)
            }
            .padding()
        }
    }
    
    // CustomListRectangle
    struct CustomListRectangle: View {
        var body: some View {
            Rectangle()
                .foregroundColor(Color.black.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal)
        }
    }
}

#Preview {
    StoreDetailView(store: nil)
}
