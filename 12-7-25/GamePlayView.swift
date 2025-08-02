//
//  GamePlayView.swift
//  12-7-25
//
//  Created by T Krobot on 12/7/25.
//

import SwiftUI
import Subsonic

struct GamePlayView: View {
    @State private var isActive = false
    @State private var change = false
    @State private var offset = 0.0
    @State private var likeCount = 1

    
    private enum AnimationPhase: CaseIterable {
        case initial
        case move
        case scale
        
        var verticalOffset: Double {
            switch self {
            case .initial: 0
            case .move, .scale: 200
            }
        }
        
        var scaleEffect: Double {
            switch self {
            case .initial: 1
            case .move, .scale: 4
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: change ? .trailing : .leading){
            Image(systemName: "rectangle")
                .resizable()
                .frame(width: 150, height: 150)
                .offset(x: -200, y: 110)
            Image(systemName: "rectangle")
                .resizable()
                .frame(width: 150, height: 150)
                .offset(x: 0, y: 120)
            Image(systemName: "rectangle")
                .resizable()
                .frame(width: 150, height: 150)
                .offset(x: 200, y: 110)
            Image(systemName: "line.diagonal")
                .resizable()
                .frame(width: 150, height: 150)
                .offset(x: -200, y: -20)
            Image(systemName: "line.diagonal")
                .resizable()
                .frame(width: 150, height: 150)
                .offset(x:-20, y: -200)
                .rotationEffect(Angle(degrees: 90))
            
            
            RoundedRectangle(cornerRadius: change ? 50 : 0)
                
            
                .fill(change ? Color.red : Color.blue)
                .frame(width: change ? 150 : 50, height: change ? 150 : 50)
            
                .phaseAnimator(AnimationPhase.allCases, trigger: likeCount) { content, phase in
                content
                    .scaleEffect(phase.scaleEffect)
                    .offset(y: phase.verticalOffset)
            } animation: { phase in
                switch phase {
                case .initial: .smooth
                case .move: .linear(duration: 0.3)
                case .scale: .spring(duration: 0.3)
                }
            }
                    .onTapGesture {
                        likeCount += 1
                    }
            
            
            
        }
        
    }
    
    
}



#Preview {
    GamePlayView()
}
