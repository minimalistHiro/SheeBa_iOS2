//
//  Sounds.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/22.
//

import SwiftUI
import AVFoundation

class Sounds: NSObject {
    
    private let sound = try! AVAudioPlayer(data: NSDataAsset(name: "Sheep1")!.data)
    
    // ファイル名をInt型に変換
//    var fileNumberInt: Int {
//        get {
//            return Int(fileNumber) ?? 0
//        }
//    }
    
    // 音楽を再生
    func playSound(){
        self.sound.stop()
        self.sound.currentTime = 0.0
        self.sound.play()
    }
}
