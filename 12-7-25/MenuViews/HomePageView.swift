//
//  HomePageView.swift
//  12-7-25
//
//  Created by T Krobot on 12/7/25.
//

import SwiftUI


struct HomePageView: View {
    @State private var isNewItemSheetPresented = false
    var body: some View {
        Spacer()
        Spacer()
        Button {
            isNewItemSheetPresented = true
        }label: {
            Text("Let's Play")
                .font(.system(size: 40))
                .padding(.horizontal, 200)
                .frame(height: 50)
        }
        .sheet(isPresented: $isNewItemSheetPresented) {
                    SelectSongView()
                }
        .buttonStyle(.borderedProminent)
        Spacer()
    }
}
#Preview {
    HomePageView()
}

