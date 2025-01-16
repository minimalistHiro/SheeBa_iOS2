//
//  AppDelegate.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/10/23.
//

import Foundation
import UIKit
import AudioToolbox
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    @ObservedObject var vm = ViewModel()
    
    // アプリ起動時に呼ばれる
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // プッシュ通知の許可要求(初回起動時のみ)
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }
    
    // テスト通知に必要なFCMトークンを出力する
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                
                print("FCM registration token: \(token)")
                if let uid = FirebaseManager.shared.auth.currentUser?.uid {
                    // fcmTokenがNULL若しくは空の場合、DBにfcmTokenを保存する。
                    print("DBにfcmTokenを更新しました: \(token)")
                    let data = [FirebaseConstants.fcmToken: token,]
                    self.vm.updateUser(document: uid, data: data)
                }
            }
        }
    }
    
    // Push通知押下時の処理
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//            incrementBadgeCount()
//            // バイブレーション
//            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
//            completionHandler([[.banner, .list, .sound, .badge]])
//        }
}

// MessagingDelegate
extension AppDelegate: MessagingDelegate {
    // FCMトークン受信時に呼ばれる
    @objc func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase token: \(String(describing: fcmToken))")
    }
}

// UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo["gcm.message_id"] {
            print("MessageID: \(messageID)")
        }
        print(userInfo)
        completionHandler(.newData)
    }
    
    // フォアグラウンドでの通知受信時に呼ばれる
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // バッジ数を更新する
//        incrementBadgeCount()
        completionHandler([[.banner, .list, .sound, .badge]])
    }

    // 受信した通知のタップ時に呼ばれる
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(
            name: Notification.Name("didReceiveRemoteNotification"),
            object: nil,
            userInfo: userInfo
        )
        completionHandler()
    }
    
    // バッジ数を更新する
    private func incrementBadgeCount() {
        // 現在のバッジ数を取得
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        // バッジ数を1増やす
        UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1
    }
}
