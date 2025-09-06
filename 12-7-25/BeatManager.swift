//  BeatManager.swift
//  12-7-25
//
//  Created by T Krobot on 30/8/25.
//

import Foundation
import AVFoundation

class BeatManager: ObservableObject  {
    static let shared = BeatManager()
    @Published var activeCircles: [CircleNote] = []
    private var currentTime: Double = 0.0
    private var timer: Timer?
    
    var beatSequence: [[Double]] = []
    
    func StartBeat(sequence: [[Double]], musicFile: String) {
        self.beatSequence = sequence
        currentTime = 0
        
        AudioManger.shared.start_music(fileName: musicFile)
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.currentTime = AudioManger.shared.getCurrentTime()
            self?.updateGameLoop()
            
        }
        for beat in beatSequence {
            for targetTime in beat {
                schduleCircleSpawn(targetTime: targetTime)
            }
        }
    }
    
    private func scheduleAllCircle() {
        for note in beatSequence {
            if let targetTime = note.first {
                schduleCircleSpawn(targetTime: targetTime)
            }
        }
    }
    
    
    
    struct CircleNote: Identifiable{
        var id: UUID = UUID()
        var spawnTime: Double
        var targetTime: Double
        var progress: Double
    }
    
    
    
    private func schduleCircleSpawn(targetTime: Double, approachTime: Double = 2.0 ) {
        let spawnTime = targetTime - approachTime
        let now = AudioManger.shared.getCurrentTime()
        let delay = spawnTime - now
        
        if delay > 0{
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.activeCircles.append(CircleNote(spawnTime: spawnTime, targetTime: targetTime, progress: 0))
            }
        } else {
            let initialProgress = max(0.0, (now - spawnTime) / max(0.0001, targetTime - spawnTime))
            self.activeCircles.append(CircleNote(spawnTime: spawnTime, targetTime: targetTime, progress: initialProgress))
        }
        activeCircles.removeAll { $0.progress >= 1.2 }
    }
    
    private func updateGameLoop() {
        currentTime = AudioManger.shared.getCurrentTime()
        for i in 0..<activeCircles.count {
            var circle = activeCircles[i]
            let denom = max(0.0001, circle.targetTime - circle.spawnTime)
            circle.progress =  (currentTime - circle.spawnTime) / denom
            activeCircles[i] = circle
        }
        activeCircles.removeAll{ $0.progress >= 1.2 } //removes circles that passes the judging circle
    }
    
    func judgeSnap() -> SnapResult {
        guard let circle = activeCircles.min(by: {
            abs(currentTime - $0.targetTime) < abs(currentTime - $1.targetTime)
        }) else {
               return .none
           }
           
           let diff = abs(currentTime - circle.targetTime)
           activeCircles.removeAll { $0.id == circle.id }
           
           if diff <= 0.1 { return .perfect }
           else if diff <= 0.25 { return .good }
           else { return .miss }
       }
       
       enum SnapResult {
           case perfect, good, miss, none
       }
   }

