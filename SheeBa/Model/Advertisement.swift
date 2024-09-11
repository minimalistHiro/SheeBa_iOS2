//
//  Advertisement.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/19.
//

import Foundation
import FirebaseFirestoreSwift

struct Advertisement: Hashable, Identifiable {
    @DocumentID var id: String?
    let title: String
    let text: String
    let url: String
    let imageUrl: String
    // TODO: - Timestamp型に変える
    let timestamp: Date
    
    init(data: [String: Any]) {
        self.title = data[FirebaseConstants.title] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.url = data[FirebaseConstants.url] as? String ?? ""
        self.imageUrl = data[FirebaseConstants.imageUrl] as? String ?? ""
        self.timestamp = data[FirebaseConstants.date] as? Date ?? Date()
    }
}

let previewOfAdvertisement = Advertisement.init(data: [
    FirebaseConstants.title: "タイトル",
    FirebaseConstants.text: "テキスト",
    FirebaseConstants.url: "",
    FirebaseConstants.imageUrl: "",
    FirebaseConstants.timestamp: Date()
])
