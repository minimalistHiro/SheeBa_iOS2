//
//  Stores.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/09/17.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Stores: Hashable, Identifiable {
    var id: String { uid }
    let uid: String
    let storename: String
    let no: Int
    let genre: String
    let phoneNumber: String
    let webURL: String
    let movieURL: String
    let profileImageUrl: String
    let getPoint: Int
    let isEnableScan: Bool
    let isEvent: Bool
    let pointX: String
    let pointY: String
    
    init(data: [String: Any]) {
        self.uid = data[FirebaseConstants.uid] as? String ?? ""
        self.storename = data[FirebaseConstants.storename] as? String ?? ""
        self.no = data[FirebaseConstants.no] as? Int ?? 0
        self.genre = data[FirebaseConstants.genre] as? String ?? ""
        self.phoneNumber = data[FirebaseConstants.phoneNumber] as? String ?? ""
        self.webURL = data[FirebaseConstants.webURL] as? String ?? ""
        self.movieURL = data[FirebaseConstants.movieURL] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.getPoint = data[FirebaseConstants.getPoint] as? Int ?? 0
        self.isEnableScan = data[FirebaseConstants.isEnableScan] as? Bool ?? false
        self.isEvent = data[FirebaseConstants.isEvent] as? Bool ?? false
        self.pointX = data[FirebaseConstants.pointX] as? String ?? ""
        self.pointY = data[FirebaseConstants.pointY] as? String ?? ""
    }
}

let previewOfStores = Stores.init(data: [
    FirebaseConstants.uid: "",
    FirebaseConstants.storename: "しば店舗",
    FirebaseConstants.no: 1,
    FirebaseConstants.genre: "飲食店",
    FirebaseConstants.phoneNumber: "08060507194",
    FirebaseConstants.webURL: "",
    FirebaseConstants.movieURL: "",
    FirebaseConstants.profileImageUrl: "",
    FirebaseConstants.getPoint: 1,
    FirebaseConstants.isEnableScan: false,
    FirebaseConstants.isEvent: false,
    FirebaseConstants.pointX: "",
    FirebaseConstants.pointY: "",
])

let genres: [String] = [
    "",
    "飲食店",
    "雑貨・インテリア・家具",
    "ファッション",
    "花・ガーデニング",
    "家電・パソコン・携帯",
    "美容室・理容室",
    "エステ・ネイル",
    "住宅・ガーデン・不動産",
    "病院・診療所",
    "整体院",
    "薬局",
    "公園",
    "その他",
]
