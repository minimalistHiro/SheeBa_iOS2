//
//  ChatUser.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import Foundation

struct ChatUser: Hashable, Identifiable {
    var id: String { uid }
    
    let uid: String
    let email: String
    let profileImageUrl: String
    let money: String
    let username: String
    let age: String
    let address: String
//    let isConfirmEmail: Bool
    let isFirstLogin: Bool
    let isStore: Bool
    let isOwner: Bool
    let isStoreOwner: Bool
    let os: String
    
    // 店舗ユーザーのみ
    let no: Int
    let isEnableScan: Bool
    let getPoint: Int
    let pointX: String
    let pointY: String
    let genre: String
    let phoneNumber: String
    let webURL: String
    let movieURL: String
    
    // DBに保存しないデータ
    let ranking: String
    
    init(data: [String: Any]) {
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.money = data[FirebaseConstants.money] as? String ?? ""
        self.username = data[FirebaseConstants.username] as? String ?? ""
        self.age = data[FirebaseConstants.age] as? String ?? ""
        self.address = data[FirebaseConstants.address] as? String ?? ""
//        self.isConfirmEmail = data[FirebaseConstants.isConfirmEmail] as? Bool ?? false
        self.isFirstLogin = data[FirebaseConstants.isFirstLogin] as? Bool ?? false
        self.isStore = data[FirebaseConstants.isStore] as? Bool ?? false
        self.isOwner = data[FirebaseConstants.isOwner] as? Bool ?? false
        self.isStoreOwner = data[FirebaseConstants.isStoreOwner] as? Bool ?? false
        self.os = data[FirebaseConstants.os] as? String ?? "iOS"
        self.no = data[FirebaseConstants.no] as? Int ?? 0
        self.ranking = data[FirebaseConstants.rankign] as? String ?? ""
        self.isEnableScan = data[FirebaseConstants.isEnableScan] as? Bool ?? false
        self.getPoint = data[FirebaseConstants.getPoint] as? Int ?? 0
        self.pointX = data[FirebaseConstants.pointX] as? String ?? ""
        self.pointY = data[FirebaseConstants.pointY] as? String ?? ""
        self.genre = data[FirebaseConstants.genre] as? String ?? ""
        self.phoneNumber = data[FirebaseConstants.phoneNumber] as? String ?? ""
        self.webURL = data[FirebaseConstants.webURL] as? String ?? ""
        self.movieURL = data[FirebaseConstants.movieURL] as? String ?? ""
    }
}

let previewOfChatUser = ChatUser.init(data: [
    FirebaseConstants.email: "test@gmail.com",
    FirebaseConstants.uid: "",
    FirebaseConstants.isStore: true,
    FirebaseConstants.getPoint: 1,
    FirebaseConstants.isEnableScan: true,
    FirebaseConstants.no: 1,
    FirebaseConstants.profileImageUrl: "",
    FirebaseConstants.username: "test"
])

let ages: [String] = [
    "",
    "〜19歳",
    "20代",
    "30代",
    "40代",
    "50代",
    "60歳〜",
]

let addresses: [String] = [
    "",
    "川口市（'芝'が付く地域）",
//    "芝新町",
//    "芝樋ノ爪",
//    "芝西",
//    "芝塚原",
//    "芝宮根町",
//    "芝中田",
//    "芝下",
//    "芝東町",
//    "芝園町",
//    "芝富士",
//    "大字芝",
    "川口市（'芝'が付かない地域）",
    "蕨市",
    "さいたま市",
    "その他",
]

let oses: [String] = [
    "",
    "iOS",
    "Android",
]
