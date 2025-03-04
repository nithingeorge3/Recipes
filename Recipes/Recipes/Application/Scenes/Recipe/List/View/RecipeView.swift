//
//  RecipeView.swift
//  Recipes
//
//  Created by Nitin George on 01/03/2025.
//

import SwiftUI
import AVKit

struct RecipeView: View {
    let recipe: Recipe
    let gridSize: CGFloat

    var body: some View {
        VStack {
            if let url = recipe.thumbnailURL.validatedURL {
                RecipeImageView(imageURL: url, height: gridSize)
                    .cornerRadius(10)
            } else {
                Image(Constants.Recipe.placeholderImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: gridSize, height: gridSize)
                    .cornerRadius(10)
            }
            
            Text(recipe.name)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
    }
}
