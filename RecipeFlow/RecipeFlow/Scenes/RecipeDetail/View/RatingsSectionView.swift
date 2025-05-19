//
//  RatingsSectionView.swift
//  Recipes
//
//  Created by Nitin George on 23/03/2025.
//

import SwiftUI
import RecipeUI
import RecipeCore

struct RatingsSectionView: View {
    let ratings: UserRatings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SubTitleView(title: "Community Ratings")
            
            HStack(spacing: 20) {
                RatingBadge(
                    count: ratings.countPositive,
                    label: "Positive",
                    systemImage: "hand.thumbsup.fill",
                    color: .green
                )
                
                RatingBadge(
                    count: ratings.countNegative,
                    label: "Negative",
                    systemImage: "hand.thumbsdown.fill",
                    color: .red
                )
                
                if ratings.score >= 0 {
                    ScoreIndicator(score: ratings.score)
                }
            }
            .frame(maxWidth: .infinity)
            
            if ratings.countPositive == 0 && ratings.countNegative == 0 {
                Text("Be the first to rate this recipe")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .background(Color(.secondarySystemBackground).opacity(0.7))
        .cornerRadius(15)
        .transition(.opacity.combined(with: .scale))
    }
}
