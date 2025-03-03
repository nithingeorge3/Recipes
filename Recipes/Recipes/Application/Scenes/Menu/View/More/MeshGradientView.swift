//
//  File.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//
import SwiftUI

struct MeshGradientView: View {
    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [1.0, 0.0], [0.8, 0.0], [1.0, 1.0],
                [0.0, 0.5], [0.8, 0.2], [0.0, 0.8],
                [0.0, 1.0], [0.5, 0.0], [1.0, 0.9]
            ],
            colors: [
                .black, .white, .black,
                .blue, .blue, .blue,
                .green, .green, .green
            ]
        )
        .edgesIgnoringSafeArea(.all)
        .withCustomBackButton()
    }
}
