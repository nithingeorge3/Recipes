//
//  RecipeMetaInfoView.swift
//  Recipes
//
//  Created by Nitin George on 23/03/2025.
//

import SwiftUI

struct RecipeMetaInfoView: View {
    let createdAt: String?
    let servings: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let createdAt = createdAt {
                iconLabelSection(
                    icon: "calendar.badge.clock",
                    title: "Created",
                    value: createdAt
                )
            }
            
            Spacer()
            
            if let servings = servings, !servings.isEmpty {
                iconLabelSection(
                    icon: "fork.knife",
                    title: "Servings",
                    value: servings
                )
            }
            Spacer()
        }
        .background(Color(.secondarySystemBackground).opacity(0.7))
        .cornerRadius(15)
        .frame(maxWidth: .infinity)
    }
    
    private func iconLabelSection(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}
