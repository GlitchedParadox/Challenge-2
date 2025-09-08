
import Foundation
import AVFoundation
final class BeatManager: ObservableObject {
    
    static let shared = BeatManager()
    
    @Published var activeCircles: [CircleNote] = []
    
    private var currentTime: Double = 0.0
    private var timer: Timer?
 
    var beatSequence: [[Double]] = []
    
    struct JudgeConfig {
        var perfect: Double = 0.08
        var great:   Double = 0.16
        var good:    Double = 0.28
        var max:     Double = 0.36
        var latencyOffset: Double = 0.00
        var tapDebounce: Double = 0.05       }
    enum Rank { case perfect, great, good, miss, none }
    struct JudgeResult {
        let rank: Rank
        let offset: Double
        let consumedNoteID: UUID?
    }
    private var judge = JudgeConfig()
    private var lastTapTime: Double = -1
  
    struct CircleNote: Identifiable {
        var id: UUID = UUID()
        var spawnTime: Double
        var targetTime: Double
        var progress: Double
    }
    func startBeat(sequence: [[Double]], musicFile: String, approachTime: Double = 2.0) {
        stop()
        self.beatSequence = sequence
        self.currentTime = 0
        self.activeCircles = []
       
        AudioManger.shared.start_music(fileName: musicFile)
        
        let t = Timer(timeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = AudioManger.shared.getCurrentTime()
            self.updateGameLoop()
        }
        timer = t
        RunLoop.main.add(t, forMode: .common)
     
        for beat in sequence {
            for targetTime in beat {
                scheduleCircleSpawn(targetTime: targetTime, approachTime: approachTime)
            }
        }
    }
    func stop() {
        timer?.invalidate()
        timer = nil
        activeCircles.removeAll()
        beatSequence.removeAll()
        currentTime = 0
        lastTapTime = -1
    }
    func setLatencyOffset(seconds: Double) { judge.latencyOffset = seconds }
    func setTapDebounce(seconds: Double) { judge.tapDebounce = seconds }
    func setWindows(perfect: Double, great: Double, good: Double, max: Double) {
        judge.perfect = perfect
        judge.great = great
        judge.good = good
        judge.max = max
    }
   
    private func scheduleCircleSpawn(targetTime: Double, approachTime: Double = 2.0) {
        let spawnTime = targetTime - approachTime
        let now = AudioManger.shared.getCurrentTime()
        let delay = spawnTime - now
        let spawnBlock = { [weak self] in
            guard let self = self else { return }
            // Recompute at actual spawn to reduce drift
            let now2 = AudioManger.shared.getCurrentTime()
            let denom = max(0.0001, targetTime - spawnTime)
            let initial = max(0.0, (now2 - spawnTime) / denom)
            let note = CircleNote(spawnTime: spawnTime, targetTime: targetTime, progress: initial)
            self.activeCircles.append(note)
            // Keep list sorted by targetTime so judging can binary-search efficiently
            self.activeCircles.sort { $0.targetTime < $1.targetTime }
        }
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { spawnBlock() }
        } else {
            DispatchQueue.main.async { spawnBlock() }
        }
    }
  
    private func updateGameLoop() {
        currentTime = AudioManger.shared.getCurrentTime()
        // Update progress
        for i in 0..<activeCircles.count {
            var c = activeCircles[i]
            let denom = max(0.0001, c.targetTime - c.spawnTime)
            c.progress = (currentTime - c.spawnTime) / denom
            // Clamp to avoid runaway values
            c.progress = min(max(c.progress, 0.0), 1.2)
            activeCircles[i] = c
        }
       
        activeCircles.removeAll { $0.progress >= 1.2 }
    }
    func judgeSnap() -> JudgeResult {
        // Debounce against mashing
        let nowInput = AudioManger.shared.getCurrentTime()
        if lastTapTime >= 0, nowInput - lastTapTime < judge.tapDebounce {
            return JudgeResult(rank: .none, offset: 0, consumedNoteID: nil)
        }
        lastTapTime = nowInput
        // Use calibrated time
        let t = nowInput + judge.latencyOffset
        guard !activeCircles.isEmpty else {
            return JudgeResult(rank: .none, offset: 0, consumedNoteID: nil)
        }
        
        var lo = 0
        var hi = activeCircles.count
        while lo < hi {
            let mid = (lo + hi) >> 1
            if activeCircles[mid].targetTime < t {
                lo = mid + 1
            } else {
                hi = mid
            }
        }
        var bestIndex: Int? = nil
        var bestAbsDiff: Double = .infinity
        var bestDiff: Double = 0
        func consider(_ idx: Int) {
            guard idx >= 0 && idx < activeCircles.count else { return }
            let c = activeCircles[idx]
            let diff = t - c.targetTime     // negative = early, positive = late
            let ad = abs(diff)
            if ad < bestAbsDiff {
                bestAbsDiff = ad
                bestDiff = diff
                bestIndex = idx
            }
        }
        consider(lo - 1)
        consider(lo)
        guard let hitIdx = bestIndex else {
            return JudgeResult(rank: .none, offset: 0, consumedNoteID: nil)
        }
        // Only judge within max window
        if bestAbsDiff > judge.max {
            return JudgeResult(rank: .none, offset: bestDiff, consumedNoteID: nil)
        }
        // Assign rank
        let rank: Rank
        if bestAbsDiff <= judge.perfect { rank = .perfect }
        else if bestAbsDiff <= judge.great { rank = .great }
        else if bestAbsDiff <= judge.good { rank = .good }
        else { rank = .miss }
        // Consume the note since we judged it (including miss within window)
        let consumedID = activeCircles[hitIdx].id
        activeCircles.remove(at: hitIdx)
        return JudgeResult(rank: rank, offset: bestDiff, consumedNoteID: consumedID)
    }
}

