//
//  ScoreManager.swift
//  12-7-25
//
//  Created by T Krobot on 30/8/25.
//
import Foundation

class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    
    @Published var snapHits: Int = 0
    @Published var snapWrong: Int = 0
    @Published var snapMisses: Int = 0
    @Published var percentageHit: Double = 0.0
    @Published var score: Int = 0
    
    private init() {}
    
    func recordHit() {
        snapHits += 1
        score += 300
        updatePercentage()
    }
    
    func recordWrong() {
        snapWrong += 1
        score += 100
        updatePercentage()
    }
    
    func recordMiss() {
        snapMisses += 1
        updatePercentage()
    }
    
    func updatePercentage() {
        let total = snapHits + snapWrong + snapMisses
        if total > 0 {
            percentageHit = Double(snapHits) / Double(total) * 100
        }
    }
    
    /// NEW: Link with BeatManager results
    func updateScore(with rank: BeatManager.Rank) {
        switch rank {
        case .perfect:
            snapHits += 1
            score += 100
        case .great:
            snapHits += 1
            score += 70
        case .good:
            snapHits += 1
            score += 50
        case .miss:
            snapMisses += 1
        case .none:
            break
        }
        updatePercentage()
    }

}
