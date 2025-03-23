//
//  RatingBadge.swift
//  Recipes
//
//  Created by Nitin George on 23/03/2025.
//

import SwiftUI

struct RatingBadge: View {
    let count: Int
    let label: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
}

struct ScoreIndicator: View {
    let score: Double
    let size: CGFloat = 60
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: CGFloat(score))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.green]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack {
                Text("\(Int(score * 100))%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("Score")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
        .padding(4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Score: \(Int(score * 100)) percent")
    }
}
