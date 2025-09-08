import Foundation
import QuartzCore
import AVFoundation

enum SnapSensor { case audio, vision }

final class GameManager: ObservableObject {
    static let shared = GameManager()

    private let audioManager = AudioManger.shared
    private let beatManager  = BeatManager.shared
    private let scoreManager = ScoreManager.shared

    struct FusionConfig {
        var fusionWindow: CFTimeInterval = 0.080
        var refractory:   CFTimeInterval = 0.120
    }
    private var cfg = FusionConfig()

    private var lastSnapTime: CFTimeInterval = 0
    private var lastSensor: SnapSensor = .audio

   
    func startGame() {
        
        beatManager.startBeat(
            sequence: [[0, 4], [0, 4], [0, 4], [0, 4]],
            musicFile: "notion.mp3"
        )

        // If you want to keep audioManager listening for the *old audio detection pipeline*:
        audioManager.startListening { [weak self] in
            self?.registerSnap(from: .audio, confidence: 1.0)
        }

            }

    func registerSnap(from sensor: SnapSensor,
                      confidence: Double,
                      at time: CFTimeInterval = CACurrentMediaTime()) {

        // Merge if both sensors fired nearly together
        let dt = time - lastSnapTime
        if dt < cfg.fusionWindow && sensor != lastSensor {
            return
        }

        // Refractory: block rapid repeats
        guard dt >= cfg.refractory else { return }

        lastSnapTime = time
        lastSensor = sensor

        // Ask BeatManager to judge this snap
        let res = beatManager.judgeSnap()
        DispatchQueue.main.async {
            switch res.rank {
            case .perfect, .great: self.scoreManager.recordHit()
            case .good:            self.scoreManager.recordWrong()
            case .miss:            self.scoreManager.recordMiss()
            case .none:            break
            }
        }
    }
}
import SoundAnalysis
import CoreML

final class SnapInputAudio: NSObject, SNResultsObserving {
    private let engine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer!

    // Use the generated class name from your .mlmodel
    private let model = try! MySoundClassifier_1(configuration: MLModelConfiguration())

    private let label = "snap"      // <-- match your training label
    private let threshold = 0.85    // tune per model

    func start() throws {
        let node = engine.inputNode
        let fmt = node.inputFormat(forBus: 0)

        analyzer = SNAudioStreamAnalyzer(format: fmt)
        let req = try SNClassifySoundRequest(mlModel: model.model)  // note: .model
        try analyzer.add(req, withObserver: self)

        node.installTap(onBus: 0, bufferSize: 2048, format: fmt) { [weak self] buf, when in
            self?.analyzer.analyze(buf, atAudioFramePosition: when.sampleTime)
        }
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        analyzer?.removeAllRequests()
    }

    // Call GameManager when we hear a snap
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let r = result as? SNClassificationResult,
              let top = r.classifications.first,
              top.identifier == label else { return }
        let conf = Double(top.confidence)
        if conf >= threshold {
            GameManager.shared.registerSnap(from: .audio, confidence: conf)
        }
    }
}
import Vision
import CoreML

final class SnapInputVision: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "vision.capture")

    // Use generated class name from your .mlmodel
    private let vnModel = try! VNCoreMLModel(for: MyHandActionClassifier(configuration: MLModelConfiguration()).model)

    private lazy var request: VNCoreMLRequest = {
        let r = VNCoreMLRequest(model: vnModel) { [weak self] req, _ in self?.handle(req: req) }
        r.imageCropAndScaleOption = .centerCrop
        return r
    }()

    // Use your labels (e.g., "snap", or "left_snap"/"right_snap")
    private let valid: Set<String> = ["snap", "left_snap", "right_snap"]
    private let threshold: Float = 0.80

    func start() throws {
        session.beginConfiguration()
        session.sessionPreset = .vga640x480

        guard let cam = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: cam) else {
            throw NSError(domain: "SnapInputVision", code: -1, userInfo: [NSLocalizedDescriptionKey: "No camera"])
        }
        if session.canAddInput(input) { session.addInput(input) }

        let out = AVCaptureVideoDataOutput()
        out.setSampleBufferDelegate(self, queue: queue)
        out.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(out) { session.addOutput(out) }

        session.commitConfiguration()
        session.startRunning()
    }

    func stop() { session.stopRunning() }

    private func handle(req: VNRequest) {
        guard let obs = req.results as? [VNClassificationObservation],
              let top = obs.first,
              valid.contains(top.identifier),
              top.confidence >= threshold else { return }

        GameManager.shared.registerSnap(from: .vision, confidence: Double(top.confidence))
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixel = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixel, orientation: .up)
        try? handler.perform([request])
    }
}
