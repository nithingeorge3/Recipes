//
//  RatingBadge.swift
//  Recipes
//
//  Created by Nitin George on 23/03/2025.
//

import SwiftUI

public struct RatingBadge: View {
    public let count: Int
    public let label: String
    public let systemImage: String
    public let color: Color
    
    public init(count: Int, label: String, systemImage: String, color: Color) {
        self.count = count
        self.label = label
        self.systemImage = systemImage
        self.color = color
    }
    
    public var body: some View {
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

public struct ScoreIndicator: View {
    public let score: Double
    public let size: CGFloat
    
    public init(score: Double, size: CGFloat = 60) {
        self.score = score
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: CGFloat(score))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.black]),
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
