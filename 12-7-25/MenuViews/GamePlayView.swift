import SwiftUI

struct GamePlayView: View {
    @EnvironmentObject var beatManager: BeatManager
    @EnvironmentObject var scoreManager: ScoreManager
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
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
                        scoreManager.updateScore(with: result)
                    }
            )
            
            VStack {
                Text("Score: \(scoreManager.score)")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }
        }
        
        
        
        .onAppear {
            beatManager.startBeat(
                sequence: [ [4], [8], [10], [12], [13], [17], [18 ], [20]], // spawn beats at 2s, 4s, etc
                musicFile: "notion"
            )
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func positionFor(progress: Double) -> CGFloat {
        let startX: CGFloat = 470   // right side
        let endX: CGFloat = 100     // judging circle x
        return startX - (startX - endX) * CGFloat(progress)
    }
}


    #Preview {
        GamePlayView()
            .environmentObject(BeatManager.shared)
            .environmentObject(ScoreManager.shared)
            .environmentObject(GameManager())
    }


