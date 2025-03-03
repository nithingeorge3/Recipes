//
//  Transitions.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI

//ToDo: having a known crash
struct Transitions: View {
    @State var isVisible: Bool = true
    
    var body: some View {
        VStack {
            GroupBox {
                Toggle("Vissible", isOn: $isVisible.animation(
                    .linear(duration: 0.3).delay(0.25)
                ))
            }
                        
            if isVisible {
                Avatar()
//                    .transition(.scale.combined(with: .opacity))
                    .transition(Twirl())
                    .transaction { t in
                        t.disablesAnimations = false
                        t.animation = .linear(duration: 0.3)
                    }
            }
            
            Spacer()
        }
        .padding()
        .withCustomBackButton()
        .withCustomNavigationTitle(title: "Transitions")
    }
}

struct Avatar: View {
    var body: some View {
        Circle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: [Color.pink, Color.purple, Color.blue, Color.pink]),
                    center: .center
                )
            )
            .frame(width: 120, height: 120)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .overlay {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct Twirl: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .scaleEffect(phase.isIdentity ? 1 : 0.5)
            .opacity(phase.isIdentity ? 1 : 0)
            .blur(radius: phase.isIdentity ? 0 : 10)
            .rotationEffect(
                .degrees(
                    phase == .willAppear ? 360 :
                        phase == .didDisappear ? -360 : .zero
                )
            )
            .brightness(phase == .willAppear ? 1 : 0)
    }
}
