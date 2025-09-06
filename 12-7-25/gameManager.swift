//
//  gameManager.swift
//  12-7-25
//
//  Created by T Krobot on 16/8/25.
//
import Foundation
import CoreML
import AVFoundation

class GameManager: ObservableObject {
    static let shared = GameManager()
    
    let audioManager = AudioManger.shared
    let beatManager = BeatManager()
    let scoreManager =  ScoreManager.shared
    func start_Game() {
        audioManager.start_music(fileName: "notion.mp3", loop: false)
        beatManager.StartBeat(sequence: [[0, 4], [0, 4], [0, 4], [0, 4],], musicFile: "notion.mp3" )
        audioManager.startListening {[weak self] in
            self?.handleSnap()
        }
    }
    
    private func handleSnap() {
        let result = beatManager.judgeSnap()
            if result == .perfect || result == .good {
                scoreManager.recordHit()
            } else {
                scoreManager.recordMiss()
            }
        }
    }

