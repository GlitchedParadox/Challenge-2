import SwiftUI

struct SelectSongView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var beatManager: BeatManager

    let songs = ["notion", "song2", "song3"] // Example songs in your bundle

    var body: some View {
        VStack {
            Text("Select a Song")
                .font(.title)
                .padding()

            List(songs, id: \.self) { song in
                NavigationLink(destination: GamePlayView()) {
                    Button(action: {
                        gameManager.startGame()
                    }) {
                        Text("notion")
                    }
                }
            }
        }
    }
}
#Preview {
    SelectSongView()
}
