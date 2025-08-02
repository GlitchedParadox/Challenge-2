//
//  SelectSongView.swift
//  12-7-25
//
//  Created by T Krobot on 12/7/25.
//

import SwiftUI

struct SelectSongView: View {
    @State private var isGamePlaySheetPresented: Bool = false
    var body: some View {
        Text("Select Song")
            .padding()
        Button{
            isGamePlaySheetPresented = true
        }label:{
            Text("Song")

        }
        .sheet(isPresented: $isGamePlaySheetPresented){
            GamePlayView()
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    SelectSongView()
}
