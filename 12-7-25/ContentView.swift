//
//  ContentView.swift
//  12-7-25
//
//  Created by T Krobot on 12/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear{
            
        }
        
        
    }
    
}

#Preview {
    ContentView()
}
