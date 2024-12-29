//
//  AppDelegate.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/10/23.
//

import Foundation
import UIKit
import AudioToolbox

//class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        
//        // UNUserNotificationCenterDelegateの適応
//        UNUserNotificationCenter.current().delegate = self
//        
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                print("許可されました。")
//            }else{
//                print("拒否されました。")
//            }
//        }
//        
//        return true
//    }
//    
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//            incrementBadgeCount()
//            // バイブレーション
//            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
//            completionHandler([[.banner, .list, .sound, .badge]])
//        }
//    
//    /// バッジ数を更新する
//    private func incrementBadgeCount() {
//        // 現在のバッジ数を取得
//        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
//        // バッジ数を1増やす
//        UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1
//    }
//}
//
//extension AppDelegate {
//    
//    // タップ時の実行処理
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        didReceive response: UNNotificationResponse,
//        withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//        completionHandler()
//    }
//}
