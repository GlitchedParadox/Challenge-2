//
//  SoundManager.swift
//  12-7-25
//
//  Created by T Krobot on 23/8/25.
//
import Foundation
import AVFoundation


class CustomSoundPlayer: ObservableObject {
    static let shared = CustomSoundPlayer()
    
    var player: AVAudioPlayer?
    var soundpath: URL? = nil
    
    
    init(player: AVAudioPlayer? = nil, soundpath: URL? = nil){
        self.player = player
        self.soundpath = soundpath
        
        if let bundlePath = Bundle.main.path(forResource: "um3.mp3", ofType: nil) {
            self.soundpath = URL(fileURLWithPath: bundlePath)
            self.player = try? AVAudioPlayer(contentsOf:URL(fileURLWithPath: bundlePath),
                                             fileTypeHint: AVFileType.mp3.rawValue)
            self.player?.volume = 1.0
        }
    }
    func play(_ path: String = "") {
        player?.stop()
        player?.prepareToPlay()
        self.player?.volume = 1.0
        
        if path != "" {
            if let bundlePath = Bundle.main.path(forResource: "\(path).mp3", ofType: nil) {
                self.soundpath = URL(fileURLWithPath: bundlePath)
                self.player = try? AVAudioPlayer(contentsOf:URL(fileURLWithPath: bundlePath), fileTypeHint: AVFileType.mp3.rawValue)
                
                self.player?.volume = 1.0
            }
        }
        if self.soundpath != nil {
            player?.currentTime = 0
            self.player?.volume = 1.0
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch(let error) {
                print(error.localizedDescription)
            }
            player?.play()
        }
    }
    func changeSoundPath(to path: String){
        if let bundlePath = Bundle.main.path(forResource: "\(path).mp3", ofType: nil) {
            self.soundpath = URL(fileURLWithPath: bundlePath)
            self.player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: bundlePath),
                                             fileTypeHint: AVFileType.mp3.rawValue)
            self.player?.volume = 1.0
        }
    }
    
    func stopAllSounds() {
        player?.stop()
    }
}
