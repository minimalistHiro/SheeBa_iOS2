//
//  Setting.swift
//  CocoShibaTsuka
//
//  Created by 金子広樹 on 2023/10/14.
//

import SwiftUI
import MapKit

final class Setting {
    
//    static let isTest: Bool = false                              // テストモードか否か
    
    // MARK: - キャンペーン値
    static let newRegistrationBenefits: String = "20"           // 新規登録特典。プレゼントポイント
    static let getPointFromStore: String = "1"                  // 店舗からの取得ポイント
    static let rankingCount: Int = 10                           // ランキング表示ユーザー
    static let ownerRankingCount: Int = 30                      // オーナーアカウントランキング表示ユーザー
    static let mapLatitude: CLLocationDegrees = 35.83306        // Mapに表示する中心のY座標
    static let mapLongitude: CLLocationDegrees = 139.69230      // Mapに表示する中心のX座標
    
    // MARK: - URL
    static let privacyPolicyURL: String = "https://www.shibaginzadori.com/?page_id=1070"// プライバシーポリシーURL
    static let officialSiteURL: String = "https://www.shibaginzadori.com/?p=970"        // 公式サイトURL
    
    // MARK: - 各種設定
    // SendPayView
    static let minPasswordOfDigits = 8                          // パスワード最小桁数
    static let maxNumberOfDigits = 6                            // 最大送金桁数
    static let maxChatTextCount = 300                            // メッセージテキスト最大文字数
}

final class UserSetting: ObservableObject {
    @AppStorage("isShowPoint") var isShowPoint = true           // ポイントを表示する
    @AppStorage("badgeCount") var badgeCount = 0                // 通知バッジ数
}
