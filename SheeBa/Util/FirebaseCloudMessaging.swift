////
////  FirebaseCloudMessaging.swift
////  SheeBa
////
////  Created by 金子広樹 on 2025/01/24.
////
//
//import Foundation
////import GoogleAPIClientForREST
////import GTMSessionFetcher
//import GoogleAPIRuntime
//import GTMSessionFetcherCore
//
//class FirebaseCloudMessaging {
//    static let shared = FirebaseCloudMessaging()
//
//    // FCM HTTP v1 APIのURL
//    private let fcmURL = "https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send"
//    
//    // サービスアカウントの認証を行う
//    private var auth: GTMSessionFetcherAuthorizer?
//
//    init() {
//        // サービスアカウントの認証を設定
//        setupAuth()
//    }
//    
//    // サービスアカウント認証を設定する
//    private func setupAuth() {
//        // サービスアカウントJSONファイルを使って認証を行う
//        guard let serviceAccountURL = Bundle.main.url(forResource: "YOUR_SERVICE_ACCOUNT_JSON", withExtension: "json") else {
//            print("Service account file not found")
//            return
//        }
//
//        do {
//            let credentials = try GTMAppAuthFetcherAuthorization(fromJSON: serviceAccountURL)
//            self.auth = credentials
//        } catch {
//            print("Failed to authenticate with service account: \(error)")
//        }
//    }
//
//    // 通知を送信するメソッド
//    func sendPushNotification(to token: String, title: String, body: String) {
//        guard let auth = auth else {
//            print("Authentication is not set up.")
//            return
//        }
//
//        // HTTP v1 APIのリクエストのペイロード
//        let payload: [String: Any] = [
//            "message": [
//                "token": token,  // 送信先デバイストークン
//                "notification": [
//                    "title": title,
//                    "body": body
//                ]
//            ]
//        ]
//
//        guard let url = URL(string: fcmURL) else {
//            print("Invalid FCM URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(auth.accessToken)", forHTTPHeaderField: "Authorization")
//        
//        do {
//            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
//            request.httpBody = data
//            
//            let session = GTMSessionFetcherService()
//            let fetcher = session.fetcher(with: request)
//            
//            fetcher.beginFetch { (data, response, error) in
//                if let error = error {
//                    print("Error sending notification: \(error.localizedDescription)")
//                } else {
//                    print("Successfully sent notification: \(String(describing: data))")
//                }
//            }
//        } catch {
//            print("Failed to serialize notification data: \(error)")
//        }
//    }
//}
//
