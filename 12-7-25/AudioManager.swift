//
//  AudioManger.swift
//  12-7-25
//
//  Created by T Krobot on 30/8/25.
//

import Foundation
import AVFoundation

class AudioManger:ObservableObject {
    
    static let shared = AudioManger()
    let soundPlayer = CustomSoundPlayer.shared
    var player:AVAudioPlayer?

    private var audioEngine: AVAudioEngine!
    private var inputNode: AVAudioInputNode!
    private var islistening = false
    private let snapThreshold: Float = 0.6
    
    
    
    private init() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode
    }
    
    
    func startListening(onSnapDetected: @escaping () -> Void) {
        guard !islistening else { return }
        islistening = true
        
        let inputFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize:1024, format: inputFormat) { (buffer, when) in
            self.analyzeBuffer(buffer, onSnapDetected: onSnapDetected)
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioEngine.prepare()
            try audioEngine.start()
            print(">>> Listening...")
        } catch {
            print("Failed to start listening: \(error)")
        }
    }
    
    
    func stopListening() {
        guard islistening else { return }
        islistening = false
        inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        print("<<< Listening stopped.")
    }
    
    
    private func analyzeBuffer(_ buffer: AVAudioPCMBuffer, onSnapDetected: @escaping () -> Void){
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        var peak: Float = 0.0
        
        for i in 0..<frameLength{
            let value = abs(channelData[i])
            if value > peak {
                peak = value
            }
        }
        if peak > snapThreshold {
            DispatchQueue.main.async {
                print("Snap detected! Peak: \(peak)")
                onSnapDetected()
            }
        }
    }
    
    
    func start_music(fileName: String, fileType : String = ".mp3", loop: Bool = false) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Audio file Not Found ")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error playing Audio: \(error)")
        }
    }
    
    func stop_Music() {
        player?.stop()
    }
    
    func getCurrentTime () -> Double {
        return player?.currentTime ?? 0
        }
    }

