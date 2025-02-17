//
//  NotificationManager.swift
//  SheeBa
//
//  Created by 金子広樹 on 2025/01/17.
//


import Foundation
import FirebaseMessaging
import FirebaseFirestore
import JWTKit

//extension ManagedAtomicLazyReference: @unchecked Sendable where Instance: Sendable {}
//extension URLSessionTask: @unchecked Sendable {}

//final class NotificationManager {
//   static let instance: NotificationManager = NotificationManager()
//
//    // Push通知送信処理
//    func sendPushNotification(accessToken: String, fcmToken: String, Title: String, Body: String) async {
//        guard let url = URL(string: "https://fcm.googleapis.com/v1/projects/sheeba-925a7/messages:send") else {
//            print("Invalid URL")
//            return
//        }
//        
//        let payload: [String: Any] = [
//            "message": [
//                "token": fcmToken,
//                "notification": [
//                    "title": Title,
//                    "body": Body
//                ]
//            ]
//        ]
//        
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
//            print("Failed to create JSON data")
//            return
//        }
//        
//        // トークンを生成
////        var token = ""
////        do {
////            token = try await generateAccessToken()
////            print("Access token: \(token)")
////        } catch {
////            print("Failed to generate access token: \(error)")
////        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        request.httpBody = jsonData
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    print("Error: \(error.localizedDescription)")
//                }
//                return
//            }
//            
//            if let httpResponse = response as? HTTPURLResponse {
//                DispatchQueue.main.async {
//                    print("Response: \(httpResponse.statusCode)")
//                }
//            }
//        }.resume()
//    }
//
//    // アクセストークン作成
//    func generateAccessToken() async throws {
//        // Replace with your actual service account private key and client email
//        let privateKey = """
//          -----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChbf9pmBytnWOB\nMUKJOt/6VfvflNFqh/ot/MVnzF7klsYIWuawTKijhS6WeLeEOamdO0pTjKTiyDJ/\nMUGDt8FIbrIeyU7wXRWpmFfpSEyHVwa5i+X5CNHFPKOFK13ZRN2tJ2hovwYAbL5P\nJgokRYQMiuOFb2tlvubjSeu6Pb1uMEGtNmnsE1yXvBTrCPAM7T5VXKxvW189qPE1\n0IHVb3z9+axJ+ziGeIgWS6sKrpw+Ri1BwySiJ4aVB66S3jbQam/Q9FGe2Fg+eKq1\nKFjrwskNXzm/bSS9OT0fkvEV/tqeMKWIg7Ky+cWmoPchqT+Yk/IrR0jxaYhMnJvg\n47OgqWNzAgMBAAECggEAK1ks2W+h39MgObx/F/ep1oDJYogFVhyOh1PVtKJSJwL/\nyZWTVes367UjRf/Dk+uiCtk1g8sEKevFd5dD9vlcmzUyeobnPi9Y1lJU5Q1nk35A\njYmuJxoBrnuyk1uKV4IhHtKyvFHzbCDHV9yoo4XRSEbxgs7hIZDKUmVyue/DUveP\nohEPbhHJdCBD0QIUjUpsddoiixCSVCMaRPKASOHjB1AYMqahEhH8cDD4QHXTW2Sc\nfGLTe0vej6k/8VWacgPD6eB3WvJ0zkwziqXEyK6gCo+9qjxmO0459KHuaASNjmSl\n76+R2cdtu0sbmmn06zS5tdlxF7qNRsWDPxCQuVdpvQKBgQDhRsrWpJrec4fpdauF\n8EX3in7ee+Fo+XxD+eMNkTGx8lbxY0O+xLLzCFGGC0N3StAwGSPZPFXIaXGJLd93\nmWKsXiKeOyGgCJULpY0s9cDWTX/1ssw1CI6Npshis5oRxkCsS05nZtcbEpyWhoWF\n/vdE4eeZnGw7wUOvisMVcaA2VwKBgQC3chV3WP8MoKekauKwwKc40tgJyxQdZrHf\n9wfNWE5ZPIo0RnkLlapX62amLkAgCc/2Q3ppzknfHF27g+JkL/NGhtZPBMFzi+G/\nRQCmhIBGmAvkS8oanZEz/okCGqKsIQ2qdsE7mLDLbb1kGM69Bf9RuofBLaVT6jAG\nX7dnnPhyRQKBgCVg06MNqMykKrbn2U/d8B4EksxjjaEXVDELM0s6/h3icd6Xc9Qh\nWvfMN4qgL8+JUEXKxhHzWuBn7niubdewUZj7/Y53jTq6cdB+5Y/CLv7f2Q1xX0Sl\naNHEDJej6TptxKlRzW6Gt8Y8LlMjeuAiz/BT81Ofiq3XgV2NDpVuRwD9AoGBALVS\n68rzSe8mYW5QRFAnrWKqbeaIOBKzroBNQgYEEjV8dLMlMYJ05lJPGUCLmNDSQiAO\nJNKumDATbsbpnn4fM1zz7KNgdQMMMhCIWRM/BzhAFAkNrPBP7PWy06QjxcVUSpjD\nF08cJyx9BWYKa1dFtVAIiyU0RCXE5sF2HOgqrRztAoGATNFo1f6raW1RMbO2HMPj\n7aiDJ8EJ6OXbLek3r2NvJasVDXYEvgD5ggwxXafJazb2GLrj593ycpDvqfGckguP\niO/O+O7l4pzHG6uhzoSGO9IFqbDP7YkBocoxth2jH2NUPSQskjFd3NJ4/58iheN+\nUxrSCdIuJIgBCKyudYPlVzY=\n-----END PRIVATE KEY-----\n
//        """
//        let clientEmail = "CLIENTEMAIL"
//
//        // Initialize JWTSigner for RS256 (RSA SHA-256)
//        let keys = await JWTKeyCollection().add(hmac: "secret", digestAlgorithm: .sha256)
////        let signers = JWTSigner.rs256(key: try .private(pem: privateKey))
//
//        let payload = PayloadData(
//            iss: clientEmail,
//            scope: "https://www.googleapis.com/auth/firebase.messaging",
//            aud: "https://oauth2.googleapis.com/token",
//            exp: Date().addingTimeInterval(3600), // 1 hour expiration
//            iat: Date()
//        )
//
//        // Generate JWT token
//        let jwt: String
//        do {
//            jwt = try await keys.sign(payload)
//        } catch {
////            print("Error sign payload data: \(error)")
//            throw error
//        }
//
//        // Exchange the JWT for an access token
//        let url = URL(string: "https://oauth2.googleapis.com/token")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)"
//        request.httpBody = body.data(using: .utf8)
//
////        let semaphore = DispatchSemaphore(value: 0)
////        var accessToken: String?
//        var requestError: Error?
//        
//        let task: Void = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                requestError = error
//                print("Error requesting access token: \(error)")
//            } else if let data = data {
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let token = json["access_token"] as? String {
////                        accessToken = token
//                    } else {
//                        print("Invalid response data: \(String(data: data, encoding: .utf8) ?? "nil")")
//                    }
//                } catch {
//                    requestError = error
//                    print("Error parsing response data: \(error)")
//                }
//            }
////            semaphore.signal()
//        }.resume()
//
////        await withTaskCancellationHandler {
////            let urlSessionTask = URLSession.shared.dataTask(with: request) { data, response, error in
////                if let error = error {
////                    requestError = error
////                    print("Error requesting access token: \(error)")
////                } else if let data = data {
////                    do {
////                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
////                           let token = json["access_token"] as? String {
////                            accessToken = token
////                        } else {
////                            print("Invalid response data: \(String(data: data, encoding: .utf8) ?? "nil")")
////                        }
////                    } catch {
////                        requestError = error
////                        print("Error parsing response data: \(error)")
////                    }
////                }
////                semaphore.signal()
////            }
////        } onCancel: {
////            urlSessionTask?.cancel()
////        }
//        
////        semaphore.wait()
//
//        if let error = requestError {
//            throw error
//        }
//
//        // Return the access token or handle error if nil
////        guard let token = accessToken else {
////            fatalError("Failed to retrieve access token")
////        }
////
////        return token
//    }
//}

struct PayloadData: JWTPayload {
    func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        // Add custom verification logic if needed
    }
    
    let iss: String
    let scope: String
    let aud: String
    let exp: Date
    let iat: Date
    
    // Conformance to JWTPayload requires this function
//    func verify(using signer: JWTSigner) throws {
//        // Add custom verification logic if needed
//    }
}
