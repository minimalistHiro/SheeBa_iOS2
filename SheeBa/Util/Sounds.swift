//
//  Sounds.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/02/22.
//

import SwiftUI
import AVFoundation

class Sounds: NSObject {
    
    private let sheep1 = try! AVAudioPlayer(data: NSDataAsset(name: "Sheep1")!.data)
    private let sheep2 = try! AVAudioPlayer(data: NSDataAsset(name: "Sheep2")!.data)
    
    // 音楽を再生1
    func playSoundSheep1(){
        self.sheep1.stop()
        self.sheep1.currentTime = 0.0
        self.sheep1.play()
    }
    // 音楽を再生2
    func playSoundSheep2(){
        self.sheep2.stop()
        self.sheep2.currentTime = 0.0
        self.sheep2.play()
    }
}
