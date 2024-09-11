//
//  Alerts.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/31.
//

import Foundation
import FirebaseFirestoreSwift

struct AlertNotification: Hashable, Identifiable {
    @DocumentID var id: String?
    let title: String
    let text: String
    
    init(data: [String: Any]) {
        self.title = data[FirebaseConstants.title] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}
