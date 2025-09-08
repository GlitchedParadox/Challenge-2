import SwiftUI
struct GamePlayView: View {
    @EnvironmentObject var beatManager: BeatManager
    @EnvironmentObject var scoreManager: ScoreManager
    @EnvironmentObject var gameManager: GameManager
    
    @State private var lastJudgeResult: BeatManager.JudgeResult? = nil
    @State private var showJudgement = false
    
    
    var body: some View {
        ZStack {
            Image("background1")
                .resizable()
                .frame(width: 900, height: 430)
            
            
            
            // Judging circle (target)
            Circle()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 80, height: 80)
                .position(x: 100, y: 300) // target position
            
            // Incoming notes
            ForEach(Array(beatManager.activeCircles.enumerated()), id: \.offset) { index, circle in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 60, height: 60)
                    .position(x: positionFor(progress: circle.progress), y: 300)
                    .animation(.linear(duration: 0.016), value: circle.progress)
            }
            .gesture(
                TapGesture()
                    .onEnded {
                        let result = beatManager.judgeSnap()
                        scoreManager.updateScore(with: result.rank) // <-- use .rank here
                        lastJudgeResult = result
                        showJudgement = true

                        // Hide after 0.5s
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showJudgement = false
                        }
                    }
            )

            
            if showJudgement, let result = lastJudgeResult {
                switch result.rank {
                case .perfect:
                    Image("perfect")
                        .resizable()
                        .frame(width: 150, height: 80)
                        .transition(.opacity)
                        .position(x: 250, y: 200)
                    
                    
                case .good:
                    Image("good")
                        .resizable()
                        .frame(width: 150, height: 80)
                        .transition(.opacity)
                        .position(x: 250, y: 200)
                    
                case .miss:
                    Image("miss")
                        .resizable()
                        .frame(width: 150, height: 80)
                        .transition(.opacity)
                        .position(x: 250, y: 200)
                    
                default:
                    EmptyView()
                }
            }
            
            
            Text("Score: \(scoreManager.score)")
                .font(.title)
                .foregroundColor(.white)
                .bold()
                .padding()
                .position(  x:200, y: 100)
            
        }
        
        
        
        
        
        
        .onAppear {
            beatManager.startBeat(
                sequence: [ [4], [8], [10], [12], [14], [18], [20], [22],[21], [24], [26], [28], [30],[31],[31.5], [32], [34.5], [36], [36.5], [37], [38.5], [40]], // spawn beats at 2s, 4s, etc
                musicFile: "notion"
            )
        }
        .navigationBarBackButtonHidden(true)
        
        if showJudgement, let result = lastJudgeResult {
            switch result.rank {
            case .perfect:
                Image("perfect")
                    .resizable()
                    .frame(width: 150, height: 80)
                    .transition(.opacity)
                    .position(x: 250, y: 100)
                
                
            case .good:
                Image("good")
                    .resizable()
                    .frame(width: 150, height: 80)
                    .transition(.opacity)
                    .position(x: 250, y: 100)
                
            case .miss:
                Image("miss")
                    .resizable()
                    .frame(width: 150, height: 80)
                    .transition(.opacity)
                    .position(x: 250, y: 100)
                
            default:
                EmptyView()
            }
        }
    }
    
    
    
    
    private func positionFor(progress: Double) -> CGFloat {
        let startX: CGFloat = 470   // right side
        let endX: CGFloat = 100     // judging circle x
        return startX - (startX - endX) * CGFloat(progress)
        
    }
    
    private func showJudgementFeedback() {
        showJudgement = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showJudgement = false
            }
            
        }
        
        
        #Preview {
            GamePlayView()
                .environmentObject(BeatManager.shared)
                .environmentObject(ScoreManager.shared)
                .environmentObject(GameManager())
        }
        
        
    }
}

