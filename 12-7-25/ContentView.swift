import SwiftUI

struct ContentView: View {
    @StateObject var audioManager = AudioManger.shared
    @StateObject var gameManager = GameManager()
    @StateObject var scoreManager = ScoreManager.shared
    @StateObject var beatManager = BeatManager()

    var body: some View {
        NavigationStack {
            HomePageView()
                .environmentObject(audioManager)
                .environmentObject(gameManager)
                .environmentObject(scoreManager)
                .environmentObject(beatManager)
        }
    }
}
