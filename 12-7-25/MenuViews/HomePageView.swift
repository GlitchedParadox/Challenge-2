import SwiftUI
import Subsonic

struct HomePageView: View {
    var body: some View {
        ZStack() {
            Image("homepage")
                .resizable()
                .frame(width: 900, height: 430)
            
            Text("🎵 Rhythm Game 🎵")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)
                .position(x:450, y:150)
            
            NavigationLink(destination: SelectSongView()) {
                Text("Start Game")
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    play(sound: "Click-sound")
                }
            )
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}
#Preview {
    HomePageView()
}
