//
//  Notification.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/13.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationModel: Hashable, Equatable, Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    let title: String
    let text: String
    let username: String 
    let profileImageUrl: String 
    let isRead: Bool
    let url: String
    let imageUrl: String
    let timestamp: Timestamp
    
//    var date: String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .abbreviated
//        return formatter.localizedString(for: timestamp, relativeTo: Date())
//    }
    
//    init(data: [String: Any]) {
//        self.uid = data[FirebaseConstants.uid] as? String ?? ""
//        self.title = data[FirebaseConstants.title] as? String ?? ""
//        self.text = data[FirebaseConstants.text] as? String ?? ""
//        self.username = data[FirebaseConstants.username] as? String ?? ""
//        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
//        self.isRead = data[FirebaseConstants.isRead] as? Bool ?? false
//        self.url = data[FirebaseConstants.url] as? String ?? ""
//        self.imageUrl = data[FirebaseConstants.imageUrl] as? String ?? ""
//        self.timestamp = data[FirebaseConstants.timestamp] as? Timestamp ?? Timestamp()
//    }
}

let previewOfNotificationModel = NotificationModel(uid: "", title: "タイトル", text: "テキスト", username: "ユーザー名", profileImageUrl: "", isRead: false, url: "", imageUrl: "", timestamp: Timestamp())

//let previewOfNotificationModel = NotificationModel.init(data: [
//    FirebaseConstants.uid: "",
//    FirebaseConstants.title: "タイトル",
//    FirebaseConstants.text: "テキスト",
//    FirebaseConstants.username: "ユーザー名",
//    FirebaseConstants.profileImageUrl: "",
//    FirebaseConstants.isRead: false,
//    FirebaseConstants.url: "",
//    FirebaseConstants.imageUrl: "",
//    FirebaseConstants.timestamp: Timestamp()
//])
