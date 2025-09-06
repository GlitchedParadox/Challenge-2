import SwiftUI

struct HomePageView: View {
    var body: some View {
        ZStack() {
            Text("🎵 Rhythm Game 🎵")
                .font(.largeTitle)
                .bold()
            
            Image("homepage")
                .resizable()
                .scaledToFill()
            
            NavigationLink("Start Game") {
                SelectSongView()
            }
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
